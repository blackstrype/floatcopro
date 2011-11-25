package float_pack; 
// Ajouter ici les définition des fonctions
// utilisée par votre coprocesseur
  //parameter N_mantisse = `TB_MANT_SIZE; // entre 1 et 23
  //parameter N_exposant = `TB_EXP_SIZE; // entre 2 et 8
parameter N_mantisse=23;
parameter N_exposant=8;

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

  // synthesis translate_off
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
  // synthesis translate_on

  /**
   * multiplication de op1 et op2
  **/
  function float float_mul(float op1, float op2);
    parameter MANTISSA_PRODUCT_BITS = N_mantisse * 2 + 2;
    parameter D_e = (2**(N_exposant-1)-1);
    parameter EXP_MIN = 1; // minimum exponent value possible
    parameter EXP_MAX = 2**(N_exposant) - 2; // max exponent value possible

    // stockage temporaire pour les resultats du multiplication
    logic [N_mantisse:0] mant1, mant2;
    logic [MANTISSA_PRODUCT_BITS - 1:0] mant_product;
    logic [N_mantisse + 1:0] mant_final;
    logic mant_carry; // mantissa too big
    logic mant_round; // mantissa rounding condition

    logic signed [N_exposant+1:0] exp;
    logic exp_big; // exponent too big
    logic exp_small; // exponent too small

    // mantisse = 1.x
    mant1 = {1'b1, op1.mantisse};
    mant2 = {1'b1, op2.mantisse};

    // mantproduct
    mant_product = mant1 * mant2;
    mant_carry = mant_product[MANTISSA_PRODUCT_BITS - 1];
    //mant_round = mant_product[N_mantisse - 1:0] == '1;
    mant_final = mant_product[MANTISSA_PRODUCT_BITS - 1:N_mantisse] /* +
                        mant_round*/;

    // exponant calculated as...
    exp = op1.exposant + op2.exposant - D_e;
    exp_small = op1.exposant == 0 |
                op2.exposant == 0 |
                (exp == 0 && ~mant_carry) |
                (exp < 0);
    // exponant is too big if 
    exp_big = (exp > EXP_MAX) |
              ((exp > EXP_MAX - 1) && mant_carry);
    /*exp_big = (exp == '1) |
              (exp == ('1 - 1)) |
              (exp == ('1 - 2) & mant_carry);*/

    // if there is carry (else block), shift mantissa and add to exponant
    if(exp_small) begin
      // if the exponent is too small, saturate to zero
      float_mul.mantisse = '0;
      float_mul.exposant = '0;
    end else if(exp_big) begin
      // if the exponant is too large, saturate to infinity
      float_mul.mantisse = '1;
      float_mul.exposant = EXP_MAX;
    end else begin
      // Shift mantissa if it was found to be bigger than 1
      if(mant_carry) begin
        mant_final = mant_final >> 1;
        exp = exp + 1;
      end
      float_mul.exposant = exp[N_exposant - 1:0];
      float_mul.mantisse = mant_final[N_mantisse - 1:0];
    end 

    float_mul.signe = op1.signe ^ op2.signe; // XOR
  endfunction // float_mul

   /**
    * Notes:
    * -When to add the mantissas together (s1, s2, op) -> (resulting sign)
    *  -(0, 0, 0) -> (s1.sign)
    *  -(0, 1, 1) -> (s1.sign)
    *  -(1, 0, 1) -> (s1.sign)
    *  -(1, 1, 0) -> (s1.sign)
    * -When to subtract mantissas (s1, s2, op) -> (result)
    *  -(0, 0, 1) -> (s1 > s2 ? s1.sign : ~s1.sign)
    *  -(0, 1, 0) -> (s1 > s2 ? s1.sign : ~s1.sign)
    *  -(1, 0, 0) -> (s1 > s2 ? s1.sign : ~s1.sign)
    *  -(1, 1, 1) -> (s1 > s2 ? s1.sign : ~s1.sign)
    *
    * -Special cases
    *  -Zero (or not)
    *   -Resulting Exponent is less than min_exp
    *    if: Resulting Exponent == (min_exp-1) and resulting mantisse is > 1
    *    then: exp = min_exp, shift mantisse
    *    if: 
    *  -Infinite
   **/

  /**
   * Addition de s1 et s2
  **/
  function float float_add(float s1,float s2);   
    float_add=float_add_sub(s1,s2,0);
  endfunction // float_add

  /**
   * Soustraction de s1 par s2
  **/
  function float float_sub(float s1,float s2);	
    float_sub=float_add_sub(s1,s2,1);
  endfunction // float_sub

  /**
   * Addition ou soustraction de s1 par s2.
   * addition si opchoice = 0
   * soustraction si opchoice = 1
  **/
  function float float_add_sub(float s1,float s2,bit opchoice);     
    int delta;
    int un_position ;
    int tmp_int; 
      
    float s2S;
    float Max, Min;
    float res;
      
    logic [2*N_mantisse+1:0] MantMax, MantMin;
    logic [2*N_mantisse +2:0] MantSum;
    logic [N_exposant-1:0] 	 ExpSum;
                  
    if (opchoice) begin
      s2S = { ~s2.signe, s2.exposant, s2.mantisse};
    end else begin
      s2S = s2;
    end

    if ({s1.exposant,s1.mantisse}>{s2S.exposant,s2S.mantisse}) begin
      Max = s1;
      Min =s2S;
    end else begin
      Max = s2S;
      Min = s1;
    end

    if (Min.exposant  == 0 && Min.mantisse == 0)
      return Max;
      
    delta = Max.exposant - Min.exposant;
    MantMax = ({1'b1, Max.mantisse}<<N_mantisse+1);
    MantMin = ({1'b1, Min.mantisse}<<N_mantisse+1) >> delta;
      
    if (Max.signe != Min.signe)
      MantSum = MantMax - MantMin;
    else
      MantSum = MantMax + MantMin;
      
    un_position = 2*N_mantisse+1+1;

    while(MantSum[un_position] !=1 && un_position >= 0 ) begin
      un_position=un_position-1;
    end
           
    tmp_int=Max.exposant+ (un_position-(2*N_mantisse+1));

    if(tmp_int<=0) begin
      res.signe=Max.signe;
      res.exposant=0;
      res.mantisse=0;
      return res;
    end
     
    if(tmp_int > 2**N_exposant-2) begin
      res.signe = Max.signe;
      res.exposant=2**N_exposant-2;
      res.mantisse=2**N_mantisse-1;
      return res;
    end 
      
      
    MantSum = MantSum >> (un_position-N_mantisse);
    res.signe    = Max.signe;
    res.exposant = Max.exposant + (un_position-(2*N_mantisse+1));
    res.mantisse = MantSum[N_mantisse-1:0];
    return res;
    
  endfunction // float_mul
  
  /**
   * Division de s1 par s2
  **/
  function float float_div(float s1,float s2);
    return 0;    
  endfunction // float_div

endpackage : float_pack

