#include<stdint.h>

char inbyte (void);
void outbyte (char);

int my_printf(const char *fmt, ...);


// le registre CC contient le nombres de cycles depuis le démarage du lm32
static inline unsigned int get_cc(void)
{
    int tmp;
    asm volatile (
            "rcsr %0, CC" :"=r"(tmp)
            );
    return tmp;
}

