#include "my_includes.h"

#define USAGE  "USAGE:\r\n"\
               "\th : help\r\n"\
               "\tu : Upload program\r\n"\
               "\t    8 digit hex start @\r\n"\
               "\t    8 digit hex size \r\n"\
               "\tv : view memory \r\n"\
               "\t    8 digit hex start @\r\n"\
               "\t    8 digit hex size \r\n"\
               "\tg : go to address\r\n"\
               "\te : echo\r\n"

// reads hex from uart and convert it to
// int. nibbles is the number of char to 
// read.
uint32_t readint(uint8_t nibbles)
{
    uint32_t val = 0, i;
    uint8_t c;
    for (i = 0; i < nibbles; i++) {
        val <<= 4;
        c = inbyte();
        // outbyte(c);
        if (c <= '9')
            val |= (c - '0') & 0xf;
        else
            val |= (c - 'A' + 0xa) & 0xf; 
    }

    return val;
}
// Writes to uart an unsigned int value as an hex
// number. nibble is the number of hex digits.
void writeint(uint8_t nibbles, uint32_t val)
{
    uint32_t i, digit;

    for (i=0; i<8; i++) {
        if (i >= 8-nibbles) {
            digit = (val & 0xf0000000) >> 28;
            if (digit >= 0xA) 
                outbyte('A'+digit-10);
            else
                outbyte('0'+digit);
        }
        val <<= 4;
    }
}

// Goto to address
static inline void jump(unsigned int add) 
{
    my_printf ("Jumping to 0x%08x\r\n",add);
    asm volatile("b %0"::"r"(add));
}

// get cpu cycle counter
static inline uint32_t get_cfg(void) 
{
    uint32_t tmp;
    asm volatile (
            "rcsr %0, CFG" :"=r"(tmp)
            );
    return tmp;
}

// main loop
int main(int argc, char **argv)
{
    int8_t *p;
    int32_t *p32;

    my_printf("\r\n\r\n** TPT LM32 BOOTLOADER **");
    my_printf    ("\r\n** CFG REG  0x%08x **",get_cfg());
    for(;;) {
        uint32_t start, size, help;
        my_printf("\r\n>");
        uint8_t c = inbyte();

        switch (c) {
            case 'h': // help
                my_printf( USAGE );
                break;
            case 'r': // reset
                jump(0x00000000);
                break;
            case 'u': // Upload programm
                /* read start address */
                start = readint(8);
                /* read program size */
                size = readint(8);
                for (p = (int8_t *) start; p < (int8_t *) (start+size); p++) {
                    *p = readint(2);
                }
                break;
            case 'g': // go
                start = readint(8);
                jump(start);
                break; 
            case 'v': // view memory 
                //outbyte('@'); 
                /* read start address */
                start = readint(8);
                //outbyte('_'); 
                /* read dump size */
                size = readint(8);
                help = 0;
                for (p32 = (int32_t *) start; p32 < (int32_t *) (start+size); p32++) {
                    if (!(help++ & 3)) {
                        my_printf("\r\n[");
                        writeint(8, (uint32_t) p32);
                        outbyte(']'); 
                    }
                    outbyte(' '); 
                    writeint(8, *p32);
                }
                break;
            case 'e': // echo test
                while (1) {
                    outbyte(inbyte());
                }
                break;
        }
    }
}

