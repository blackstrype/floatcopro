#include <systemc>
#include "xtermtty.h" 

using namespace sc_core;

int _main(int argc, char*argv[])
{
    sc_time TX_periode(1000/115.2e3,SC_MS);
    sc_signal<bool> TX("TX");
    sc_signal<bool> RX("RX");
    unsigned char t[]="ABCDEF\r\nGHIJ\0" ;

    xtermtty tty0("tty0");
    tty0.TX_in (TX);
    tty0.RX_out(RX);

    TX = 1;
    sc_start(1,SC_US);
    for(int j = 0; j < 12; j++)
    {
        TX=0;
        sc_start(TX_periode);
        for (int i = 0; i< 8; i++)
        {
            TX =  bool(t[j] & (1<<i));
            sc_start(TX_periode);
        }
        TX = 1;
        sc_start(TX_periode);
    }

    sc_start(10000,SC_MS);
    
    for(int j = 0; j < 12; j++)
    {
        TX=0;
        sc_start(TX_periode);
        for (int i = 0; i< 8; i++)
        {
            TX =  bool(t[j] & (1<<i));
            sc_start(TX_periode);
        }
        TX = 1;
        sc_start(TX_periode);
    }

    sc_start(  );

    return 0;
}

int sc_main(int argc, char*argv[])
{
    return _main(argc, argv);
}
