#include <stdio.h>

/*******************************************************************************
 * appel de la fonction 'user' en asm pour acceder au coprocesseur
 * float data1,data2,resultat ;
 * data1    = (float) 1.0f ;
 * data2    = (float) -16.0f ;
 * resultat = (float) 0.0 ;
 * asm volatile("user %[dest],%[src1],%[src2],0x02":[dest] "=r" (resultat)
 *                                                 :[src1] "r" (data1),
 *                                                  [src2] "r" (data2)) ;
 *
 ******************************************************************************/

// nombres de cycles depuis le démarage du lm32
static inline unsigned int get_cc(void)
{
    int tmp;
    asm volatile (
            "rcsr %0, CC" :"=r"(tmp)
            );
    return tmp;
}

// CODE A MODIFIER
static inline float fmult(float x, float y)
{
    return x*y ;
}

static inline float fadd(float x, float y)
{
    return  x + y ;
}

static inline float fdiv(float x, float y)
{
    return x/y;
}
// FIN DU CODE A MODIFIER

// fonction calculant pi en utilisant le copro
float dev_lim_atn_copro ( float x , int n ) {
    float res ,x2, mem_puiss, memsuri;
    int i ;
    float  signe;
    signe  =1.0;
    res =0.0 ;

    mem_puiss = x ;
    x2 = fmult(x,x)  ;
    for ( i =1; i <= n ; i +=2) {
        memsuri = fdiv(fmult(signe , mem_puiss),(float) i);
        res = fadd(res,memsuri)  ;
        signe = fmult(-1.0,signe) ;
        mem_puiss = fmult(mem_puiss , x2) ;
    }
    return res ;
}


// fonction de reference
float dev_lim_atn_ref ( float x , int n ) {
    float res ,x2, mem_puiss ;
    int i ;
    float  signe;

    signe  =1.0;
    res =0.0 ;
    x2 = x*x;
    mem_puiss = x ;

    for ( i =1; i <= n ; i +=2) {
        res += signe * mem_puiss / (float)i  ;
        signe = -1.0 * signe  ;
        mem_puiss = mem_puiss * x2 ;
    }

    return res ;
}


#define FREQ 100.0f // in MHz

int main()
{
    unsigned int t0, t1;
    float pi ;
    int i ;
    // sans le copro
    for (i=1;i<100000;i*=10) {
        t0 = get_cc();
        pi = 4.0*dev_lim_atn_ref(1.0,i) ;
        t1 = get_cc();
        printf("Iterations :%10d Pi : %10.9f\n",i,pi) ;
        printf("Duration 1    %f ms\n\r", (t1-t0)/1000./FREQ);
    }
    printf("\nCalcul en utilisant le coprocesseur\n");
    // utilisant le copro
    for (i=1;i<100000;i*=10) {
        t0 = get_cc();
        pi = fmult(4.0,dev_lim_atn_copro(1.0,i)) ;
        t1 = get_cc();
        printf("Iterations :%10d Pi : %10.9f\n",i,pi) ;
        printf("Duration 1    %f ms\n\r", (t1-t0)/1000./FREQ);
    }
    return 0;
}

