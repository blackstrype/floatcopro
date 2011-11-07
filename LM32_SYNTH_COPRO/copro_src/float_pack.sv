package float_pack; 
// Ajouter ici les définition des fonctions
// utilisée par votre coprocesseur
  parameter N_mantisse = 20; // entre 1 et 23
  parameter N_exposant = 4; // entre 2 et 8

  

   typedef struct packed {
      bit                  signe;
      bit [0:N_exposant-1] exposant;
      bit [0:N_mantisse-1] mantisse;
   } float;

   typedef struct packed {
      bit 		   signe; // signe
      bit [0:7] 	   exposant; // exposant
      bit [0:22] 	   mantisse; // mantisse 
   } float_ieee;

   
  function float_ieee real2float_ieee(shortreal s);
    real2float_ieee = $shortrealtobits(s);
  endfunction // real2float_ieee

   
  function shortreal float_ieee2real(float_ieee f);
    float_ieee2real = $bitstoshortreal(f);
  endfunction // float_ieee2real

   
  function float real2float(shortreal s);
      // TODO: convert s mantisse to the appropriate size for our float
      // TODO: convert s exposant to the appropriate size for our float
      
      float_ieee tmp;
      float tmp2;
      tmp=real2float_ieee(s);

      tmp2.signe = tmp.signe;
     if( tmp.exposant > 127+(2**(N_exposant-1)-1)  ) // e > (2^N_exposant-1 - 1)
	begin
	   tmp2.exposant=2**N_exposant - 2;
	   tmp2.mantisse = 2**N_mantisse-1; // ~0
	end
     else
       begin
	if( tmp.exposant < 127+(-1)*2**(N_exposant-1)+2 )
	begin
	   tmp2.exposant = 0;
	   tmp2.mantisse = 0;
	end
       else
	begin
	   tmp2.exposant = tmp.exposant - 127 + 2**(N_exposant-1) - 1; // r2f.exp = tmp.exp - 2^7 - 1
	   tmp2.mantisse = tmp.mantisse >> (23-N_mantisse);
	 
	end // else: !if( (tmp.exposant - 127) < (-1)*2**(N_exposant-1)+2 )
       end // else: !if( (tmp.exposant - 127) > (2**(N_exposant-1)-1)  )
      
      real2float=tmp2;
      
   endfunction // real2float

   


   function shortreal float2real(float s);
      float_ieee tmp;
      tmp.signe = s.signe;
      tmp.exposant = s.exposant-(2**(N_exposant-1)-1)+127;
      tmp.mantisse = s.mantisse << (23-N_mantisse);
      
      float2real = float_ieee2real(tmp);
   endfunction // float2real

endpackage : float_pack


   
   
