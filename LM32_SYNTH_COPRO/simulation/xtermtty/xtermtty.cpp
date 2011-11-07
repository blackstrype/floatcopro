#include "xtermtty.h"

#include <errno.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <signal.h>


#include <sys/socket.h>
#include <sys/wait.h>

xtermtty::xtermtty(sc_module_name insname, const char* logname ,
        unsigned int bps, unsigned int bpw):
    sc_core::sc_module(insname),
    TX_in("TX_in"), RX_out("RX_out"),
    tx_period(1e6/bps,SC_US),
    smpl_period(1e6/16.0/bps,SC_US),
    BITS(bpw)
{

    SC_THREAD(emiloop);
    SC_THREAD(receploop);
    //dont_initialize();

    // communication socket (bidir pipe)
    int socket[2];
    if ( socketpair( AF_UNIX, SOCK_STREAM, 0, socket ) < 0 )
    {
        perror("TTY socket");
        exit (-1);
    }
    // Process for the xterm
    if ((m_pid = fork())<0)
    {
        perror("TTY fork");
        exit (-1);
    }
    if (m_pid)
    { // parent (SystemC)
        psocket = socket[1];
        // close child side
        close(socket[0]);
        // flush the xterm
        char buff;
        do {
            read( psocket , &buff, 1 );
        } while( buff != '\n' && buff != '\r' );
        fcntl( psocket, F_SETFL, O_NONBLOCK );
        sleep(1);
    }
    else
    { // child (xterm)
        const int maxlen = 10;
        char xterm_fd[maxlen];
        int csocket = socket[0];

        // make xterm use the socket
        snprintf(xterm_fd, maxlen, "-S0/%d",csocket);

        // close parent side
        close(socket[1]);
        // unlink logfile
        unlink(logname);
        //exec xterm
        execlp("xterm", "xterm",
                xterm_fd,
                "-T", logname,
                "-bg", "blue",
                "-fg", "white",
                "-l", "-lf", logname,
                "-geometry", "80x25",
                NULL);
        // in case of exec error kill the parent
        perror("TTY execlp");
        // kill everything and exit
        kill(getppid(), SIGKILL);
        // _exit is supposed to close all file descriptors
        _exit(2);

    }

    cout << name() << " created successfully!" << endl;
}

xtermtty::~xtermtty()
{
    int status;
    fflush(NULL);
    close(psocket);
    kill (m_pid, SIGTERM);
    ::wait(&status);
}

void xtermtty::emiloop()
{
    unsigned char buff;
    int retval;

    while(true)
    {
        // stop bit
        RX_out = 1;

LABEL:
        wait(tx_period);

        // read socket from xterm
        retval = read(psocket , &buff, 1);
        //if (retval<0) perror("Xterm read");
        if (retval <= 0) goto LABEL;
#ifdef DEBUG
        cout << "##### Reading " << buff << " from xterm"<<endl;
#endif
        // start bit
        RX_out = 0;
        wait(tx_period);
        for (unsigned int i = 0; i< BITS ; i++)
        {
#ifdef DEBUG
            cout << "# Bit "<< i << " sent " << bool(buff & (1<<(7-i))) << endl;
#endif
            RX_out = bool(buff & (1<<i));
            wait(tx_period);
        }
    }
}

void xtermtty::receploop()
{
    bool start = false;
    unsigned char buff;


    while(true) // main loop
    {
        if (!start)
        {
            // wait for start bit
            wait(smpl_period);
            if (TX_in == false)
            {
                start = true;
                //cout << "start....!!" <<endl;
                // wait for next bit
                wait(tx_period);
                // timing margin
                wait(4*smpl_period);
            }
        } else {
            // We already have a start so we sample the datas
            for (unsigned int i = 0; i< BITS ; i++)
            {
#ifdef DEBUG
                cout << "Bit "<< i << " received " << TX_in.read() << endl;
#endif
                buff = (buff >> 1) | ((TX_in & 0x1)<<7);
                wait(tx_period);
            }
            start = false;
#ifdef DEBUG
            cout << "received : " << buff << endl;
#endif
            write(psocket , &buff, 1);
        }
    }
}

#ifdef MTI_SYSTEMC
    SC_MODULE_EXPORT(xtermtty);
#endif
#undef DEBUG
