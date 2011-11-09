module tb_float_pack ();
   import float_pack::*;

   integer of;//le fichier de sortie
     
   shortreal a ;
   float_ieee b ;
   float c;
   float d;

   shortreal op1real;
   shortreal op2real;
   float op1;
   float op2;
   float p;

  initial
    begin
      of = $fopen("test.dat");
      /*
      a = 2**(8); // a est une valeur réelle
      b = real2float_ieee(a) ; // b est initialisé à a
      c = real2float(a);
      #10;
      b = float2real(c);
      a = float_ieee2real(b);
      */

      #10;
      op1real = 0;
      op2real = 0;
      op1 = real2float(op1real);
      op2 = real2float(op2real);
      p = float_mul(op1, op2);
      a = float2real(p);
      #10;
      op1real = 0;
      op2real = 1;
      op1 = real2float(op1real);
      op2 = real2float(op2real);
      p = float_mul(op1, op2);
      a = float2real(p);
      #10;
      op1real = 1;
      op2real = 1;
      op1 = real2float(op1real);
      op2 = real2float(op2real);
      p = float_mul(op1, op2);
      a = float2real(p);
      #10;
      op1real = 1;
      op2real = 2;
      op1 = real2float(op1real);
      op2 = real2float(op2real);
      p = float_mul(op1, op2);
      a = float2real(p);
      
      $fclose(of);
      $finish ;
    end

   initial
     begin
//	$monitor("%f  %b   %b  %b",a,b,b.exposant,b.mantisse);
	//$monitor("a:%f b.exposant:%b b.mantisse:%b c.exposant:%b c.mantisse:%b",a,b.exposant, b.mantisse, c.exposant,c.mantisse);
        $fmonitor(of, "p:%b p.exposant:%b p.mantisse:%b a:%f expadded:%d",
                  p, p.exposant,
                  p.mantisse,
                  a,
                  op1.exposant+op2.exposant);
     end
   
endmodule
