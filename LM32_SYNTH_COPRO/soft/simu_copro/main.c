#include <my_includes.h>

#define FREQ 100

static inline int copro_add(int x, int y)
{
  int resultat;
  asm volatile("user %[dest],%[src1],%[src2],0x00"
                 :[dest] "=r" (resultat)
                 :[src1] "r" (x),
                 [src2] "r" (y)
                 ) ;
  return resultat;
}

static inline int copro_sub(int x, int y)
{
  int resultat;
  asm volatile("user %[dest],%[src1],%[src2],0x01"
                 :[dest] "=r" (resultat)
                 :[src1] "r" (x),
                 [src2] "r" (y)
                 ) ;
  return resultat;
}

static inline float copro_mult(float x, float y)
{
  float resultat;
  asm volatile("user %[dest],%[src1],%[src2],0x02"
                 :[dest] "=r" (resultat)
                 :[src1] "r" (x),
                 [src2] "r" (y)
                 ) ;
  return resultat;
}




int main()
{
    float a = .5;
    float b = 1.5e-1;
    float c;
    c = copro_mult (a,b);
    //my_printf ("a: 0x%x b: 0x%x -> c: 0x%x\r\n",a,b,c);

    return 0;
}

