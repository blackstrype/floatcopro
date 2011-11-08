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
  function float float_mul(float op1, float op2);
    parameter MANTISSA_PRODUCT_BITS = N_mantisse * 2 + 2;
    // stockage temporaire pour les resultats du multiplication
    bit [0:N_exposant] exp;
    bit [0:MANTISSA_PRODUCT_BITS - 1] mant;
    bit mantissa_carry; // mantissa too big
    bit exponent_carry; // exponent too big

    // mant = 1.x * 1.y
    // where x = op1.mantisse, y = op2.mantisse
    assign mant = (op1.mantisse + 2**N_mantisse) * 
                  (op2.mantisse + 2**N_mantisse);
    // exponant calculated as...
    assign exp = op1.exposant + op2.exposant + mantissa_carry;

    assign mantissa_carry = mant[MANTISSA_PRODUCT_BITS - 1] |
                            mant[MANTISSA_PRODUCT_BITS - 2];
    assign exponent_carry = exp[N_exposant];

    // if there is carry (else block), shift mantissa and add to exponant
    if(exponent_carry) begin
      // if the exponant is too large, saturate
      float_mul.mantisse = 2**N_mantisse - 1;
      float_mul.exposant = 2**N_exposant - 2;
    end else begin
      float_mul.exposant = exp[0:N_exposant];
      if(mantissa_carry) begin
        float_mul.mantisse = mant[N_mantisse + 1:MANTISSA_PRODUCT_BITS - 2];
      end else begin
        float_mul.mantisse = mant[N_mantisse:MANTISSA_PRODUCT_BITS - 3];
      end
    end

    float_mul.signe = op1.signe ^ op2.signe; // XOR
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

