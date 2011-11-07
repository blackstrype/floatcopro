#ifndef TTY_H
#define TTY_H

#include <systemc>
#include <sys/types.h>

using namespace std;
using namespace sc_core;

class xtermtty
:sc_module
{
    public:
        // I/O signals
        sc_in <bool> TX_in;
        sc_out<bool> RX_out;

        SC_HAS_PROCESS(xtermtty);

        // Constructor
        xtermtty(    
                sc_module_name insname,
                const char* logname = "xtermtty.log",
                unsigned int bps = 115200,
                unsigned int bpw = 8);
        ~xtermtty();

    private:
        // Reception period
        sc_time tx_period;
        //sampling periode
        sc_time smpl_period;
        // bits per word
        const unsigned int BITS;
        // reception loop
        void receploop();
        // emission loop
        void emiloop();

        // xterm will be forked
        pid_t m_pid;
        // socket file descriptor
        int psocket;

};

#endif
