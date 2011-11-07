module tb_float_pack ();
   import float_pack::*;
     
   shortreal a ;
   float_ieee b ;
   float c;

  initial
    begin
       a = 2**(-7); // a est une valeur réelle
       b = real2float_ieee(a) ; // b est initialisé à a
       c = real2float(a);
       #10;
       
     //  b.exposant = b.exposant+1 ; // l'exposant est incrémenté de 1
      // a = float_ieee2real(b) ; // a prend la valeur modifiée..
         
	 
    end

   initial
     begin
//	$monitor("%f  %b   %b  %b",a,b,b.exposant,b.mantisse);
	$monitor("a:%f b.exposant:%b b.mantisse:%b c.exposant:%b c.mantisse:%b",a,b.exposant, b.mantisse, c.exposant,c.mantisse);
	
     end
   
endmodule
