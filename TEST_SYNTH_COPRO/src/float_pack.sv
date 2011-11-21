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
                (exp == 0 & !mant_carry);
    // exponant is too big if 
    exp_big = (exp == '1) |
              (exp == ('1 - 1)) |
              (exp == ('1 - 2) & mant_carry);

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

   /*************************************
    * Test area with overlapping functionality for the add_sub of Taha
   *************************************/

   /**
    * Soustraire de s1 par s2
   **
   function float float_sub(float s1,float s2);
     float_add(s1, {~s2.signe, s2.exposant, s2.mantisse}); // float_add(s1, -s2)
   endfunction // float_sub

   /**
    * Addition de s1 et s2
   **
   function float float_add(float s1, float s2);
     float big_operand, small_operand;
     
     if( s1_is_bigger(s1, s2) ) begin
       big_operand = s1;
       small_operand = s2;
     end else begin
       big_operand = s1;
       small_operand = s2;
     end
     //Unfinished functionality
   endfunction

   /**
    * Returns 1 if s1 is the bigger of the 2 numbers otherwise 0
   **
   function logic s1_is_bigger(float s1, float s2);
     logic s1_bigger_exponent;
     logic s1_bigger_mantissa;
     logic exponents_are_equal;
     
     exponents_are_equal = (s1.exposant == s2.exposant);
     s1_bigger_exponent = (s1.exposant > s2.exposant);
     s1_bigger_mantissa = (s1.mantisse > s2.mantisse);

     // then size of mantissa, if the exponents are equal.
     s1_is_bigger = exponents_are_equal ?
             (s1_bigger_mantissa ? 1 : 0) :
             (s1_bigger_exponent ? 1 : 0);
   endfunction // max_operand

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
    * 
    *
    * -Special cases
    *  -Zero (or not)
    *   -Resulting Exponent is less than min_exp
    *    if: Resulting Exponent == (min_exp-1) and resulting mantisse is > 1
    *    then: exp = min_exp, shift mantisse
    *    if: 
    *  -Infinite
   **/
   /***********************************
    * End of Test Area
   ***********************************/


   /**
    * float_add_sub decommenté pour synthèse de float_mul
   **

   function float float_sub(float s1,float s2);	
//A rajouter le test sur le signe dans float_sub!!!!!!!
     logic soustraire;
     soustraire = (s1.signe ^ s2.signe);

   if(s1.signe==s2.signe) // if the sign of s1 and s2 are the same
     if(s1.signe==0) // if sign of s1 is positive
     float_sub=float_add_sub(s1,s2,1); // perform s1 - s2
     else // if sign of s1 is negative
	begin
     float_sub=float_add_sub(s2,s1,1); // perform s2 - s1
     float_sub.signe=~float_sub.signe; // flip the resulting sign
	end
   else // if the sign of s1 and s2 are different
	if({s1.exposant,s1.mantisse}!=0) // if s1 != 0
     float_sub=float_add_sub(s1,s2,0); // perform s1 + s2
     else // if s1 == 0
	float_sub={~s2.signe,s2.exposant,s2.mantise}; // return -s2
   endfunction // float_sub

   /**
    * addition ou soustraction de op1 par op2
    * si opchoice = 1, soustraire
   **
   function float float_add_sub(float s1,float s2,bit opchoice);
     int delta=0;
     int mantisse_somme=0;
     int un_position =N_mantisse+1;
     if(opchoice==0) begin // if our operator is addition
       //signe du résultat
       //a chauqe fois que float_add est appelée dans float_add_sub le signe du
       //résultat est toujours le signe de s1
       float_add_sub.signe=s1.signe; // signe will be 
	   //addition
	   if({s1.exposant,s1.mantisse}==0)
	     float_add_sub=s2; 
	     	     
	   else
	     if({s2.exposant,s2.mantisse}==0)
	       float_add_sub=s1;
	     else
	       begin
		  if(s1.exposant>=s2.exposant)
		    begin
		       delta=s1.exposant-s2.exposant;//delta est la valeur absolue de la difference des exposants
       		       //addition des mantisses allignées
		       mantisse_somme=(s1.mantisse+2**N_mantisse);		   
		       mantisse_somme=mantisse_somme+((2**N_mantisse+s2.mantisse)>>delta);
		    end // if (s1.exposant>=s2.exposant)
		  else
		    begin
		       delta=s2.exposant-s1.exposant;
		       //addition des mantisses allignées
		       mantisse_somme=(s2.mantisse+2**N_mantisse);
		       mantisse_somme=mantisse_somme+((2**N_mantisse+s1.mantisse)>>delta);
		    end // else: !if(s1.exposant>=s2.exposant)
		  
		  //position du premier 1 dans la somme et génération de l'exposant  et génération de l'exposant
		  if(mantisse_somme[N_mantisse+1]==1)
      		    begin
		       if(s1.exposant>=s2.exposant)
			 begin
			    if(s1.exposant==2**N_exposant-2)
			      begin
				 float_add_sub.exposant=2**N_exposant-2;
				 float_add_sub.mantisse=2**N_mantisse-1;
			      end
			    else
			      begin
				 float_add_sub.exposant=s1.exposant+1;
				 un_position=N_mantisse+1;
				 mantisse_somme[un_position]=0;
				 float_add_sub.mantisse=mantisse_somme>>1;
			      end // else: !if(s1.exposant==2**N_exposant-1)
			 end // if (s1.exposant>=s2.exposant)
		       else
			 begin
			    if(s2.exposant==2**N_exposant-2)
			      begin
				 float_add_sub.exposant=2**N_exposant-2;
				 float_add_sub.mantisse=2**N_mantisse-1;
			      end
			    else
			      begin
				 float_add_sub.exposant=s2.exposant+1;
				 un_position=N_mantisse+1;
				 mantisse_somme[un_position]=0;
				 float_add_sub.mantisse=mantisse_somme>>1;
			      end 
			 end 		  
		    end
		  else 
		    begin
		       float_add_sub.exposant=(s1.exposant>=s2.exposant)?s1.exposant:s2.exposant;
		       un_position=N_mantisse;
		       mantisse_somme[un_position]=0;
		       float_add_sub.mantisse=mantisse_somme ;
		    end
	       end // else: !if(s2==0)
	end        
else
  begin

     if(s1==s2)
       float_add_sub=0;
     else
       begin
	  if({s2.exposant,s2.mantisse}==0)
	    float_add_sub=s1;
	  else
	    if({s1.exposant,s1.mantisse}==0)
	      begin
		 float_add_sub=s2;
		
	      end
	    else
	      begin
		 
		 if(s1.exposant>s2.exposant)
		   begin
		      float_add_sub.signe=s1.signe;//le signe est celui du float ayant le plus grand exposant
		      delta=s1.exposant-s2.exposant;//delta est la valeur absolue de la difference des exposant
		      mantisse_somme=(s1.mantisse+2**N_mantisse);		   
		      mantisse_somme=mantisse_somme-((2**N_mantisse+s2.mantisse)>>delta);
		   end
		 
		 else
		   if(s2.exposant>s1.exposant)
		     begin
			float_add_sub.signe= ~s1.signe;
			delta=s2.exposant-s1.exposant;
			mantisse_somme=(s2.mantisse+2**N_mantisse);
			mantisse_somme=mantisse_somme-((2**N_mantisse+s1.mantisse)>>delta);
		     end // else: !if(s1.exposant>=s2.exposant)
		   else
		     begin
			if(s1.mantisse>s2.mantisse)
			  begin
			     float_add_sub.signe=0;
			     mantisse_somme={0,s1.mantisse-s2.mantisse};
			  end
			else
			  if(s2.mantisse>s1.mantisse)
			    begin
			       float_add_sub.signe=1;
			       mantisse_somme={0,s2.mantisse-s1.mantisse};
			    end
			  else
			    float_add_sub=0;
		     end
		 
		 
		 //recherche du premier un dans la mantisse
		 un_position=N_mantisse;
		 while(mantisse_somme[un_position] !=1 && un_position >= 0 )
		   begin
		      un_position=un_position-1;
		   end
		 
		 if(s1.exposant>s2.exposant)
		   if(s1.exposant>=(N_mantisse-un_position))
		     float_add_sub.exposant=s1.exposant-(N_mantisse-un_position);
		   else
		     begin
			float_add_sub.exposant=0;
			mantisse_somme=0;
		     end
       		 else
		   if(s2.exposant>s1.exposant)
		     if(s2.exposant>=(N_mantisse-un_position))
		       float_add_sub.exposant=s2.exposant-(N_mantisse-un_position);
		     else
		       begin
			  float_add_sub.exposant=0;
			  mantisse_somme=0;
		       end
		   else
		     if(s1.mantisse!=s2.mantisse)
		       if(s1.exposant>=(N_mantisse-un_position))
	      		 float_add_sub.exposant=s1.exposant-(N_mantisse-un_position);
		       else
			 begin
			    float_add_sub.exposant=0;
			    mantisse_somme=0;
			 end
		 
		 //génération de la nouvelle mantisse avec troncature
		 mantisse_somme[un_position]=0;
		 mantisse_somme=mantisse_somme<<(N_mantisse-un_position);
		 float_add_sub.mantisse=mantisse_somme;
		 
	      end
       end 
  end      

     endfunction

   /**
    * float_add_sub decommenté pour synthèse de float_mul
   **/
   
   function float float_div(float s1,float s2);
      
     endfunction // float_div

endpackage : float_pack

