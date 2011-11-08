package float_pack; 
// Ajouter ici les définition des fonctions
// utilisée par votre coprocesseur
  parameter N_mantisse = `TB_MANT_SIZE; // entre 1 et 23
  parameter N_exposant = `TB_EXP_SIZE; // entre 2 et 8

  // struct for float
  typedef struct packed {
     bit                  signe;
     bit [0:N_exposant-1] exposant;
     bit [0:N_mantisse-1] mantisse;
  } float;

  // struct for float_ieee
  typedef struct packed {
     bit           signe; // signe
     bit [0:7]     exposant; // exposant
     bit [0:22]    mantisse; // mantisse 
  } float_ieee;

  /**
   * Convert shortreal to float_ieee
  **/
  function float_ieee real2float_ieee(shortreal s);
    real2float_ieee = $shortrealtobits(s);
  endfunction // real2float_ieee

  /**
   * Convert float_ieee to shortreal
  **/
  function shortreal float_ieee2real(float_ieee f);
    float_ieee2real = $bitstoshortreal(f);
  endfunction // float_ieee2real
   
  /**
   * Convert shortreal to float
  **/
  function float real2float(shortreal s);
    float_ieee tmp;
    int tmp_exp;

    tmp=real2float_ieee(s);
    real2float.signe = tmp.signe;
    tmp_exp = tmp.exposant;

    // if e > (2^N_exposant-1 - 1)
    if( tmp_exp > 127+(2**(N_exposant-1)-1)  ) begin 
        real2float.exposant=2**N_exposant - 2;
        real2float.mantisse = 2**N_mantisse-1; // ~0
    end else begin
      if( tmp_exp < 127+(-1)*2**(N_exposant-1)+2 ) begin
	    real2float.exposant = 0;
	    real2float.mantisse = 0;
      end else begin
        // r2f.exp = tmp.exp - 2^7 - 1
        real2float.exposant = tmp.exposant - 127 + 2**(N_exposant-1) - 1;
        real2float.mantisse = tmp.mantisse >> (23-N_mantisse);
      end // else: !if( (tmp.exposant - 127) < (-1)*2**(N_exposant-1)+2 )
    end // else: !if( (tmp.exposant - 127) > (2**(N_exposant-1)-1)  )

  endfunction // real2float

  /**
   * Convert float_ieee to shortreal
  **/
  function shortreal float2real(float s);
    float_ieee tmp;
    tmp.signe = s.signe;
    tmp.exposant = s.exposant-(2**(N_exposant-1)-1)+127;
    tmp.mantisse = s.mantisse << (23-N_mantisse);
     
    float2real = float_ieee2real(tmp);
  endfunction // float2real

  /**
   * multiplication de op1 et op2
  **/
  function float float_mult(float op1, float op2);
    // stockage temporaire pour les resultats du multiplication
    bit [0:N_exposant-1] exp;
    bit [0:(N_mantisse-1) * 2] mant; // Ca puet-être ne marchera pas...
                                     // Nous avons besoin d'un champs de 
                                     // bits assez grands de garder le
                                     // resultat de le multiplication du
                                     // mantisse

    // 1.x * 1.y = (1 + 0.x) + (1 + 0.y) 
    //   = 1 + 0.x + 0.y + 0.x*0.y = 1.(0.x + 0.y + 0.x*0.y) = 1.(mant)
    // mant = (0.x + 0.y + 0.x*0.y)
    mant = op1.mantisse + op2.mantisse + op1.mantisse*op2.mantisse;
    // if mant > 1
    //    mant = mant >> 1;
    //    exposant += 1;
    // else
    //    

    float_mult.signe = op1.signe ^ op2.signe; // XOR
    float_mult.exposant = 0;
    float_mult.mantisse = 0;
  endfunction

  /**
   * addition ou soustraction de op1 par op2
  **/
  function float_ieee float_addsub(float_ieee op1, float_ieee op2, bit sub);
    // addition ou soustraction de op1 de op2
    // if (sub), faire un soustraction
    // else, faire une addition

    // TODO: Write addition function

    float_addsub.signe = 0;
    float_addsub.exposant = 0;
    float_addsub.mantisse = 0;
  endfunction

endpackage : float_pack

