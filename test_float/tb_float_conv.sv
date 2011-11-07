// Ajuster ici les noms des champs utilisés dans le type float
// Le resultat du test est stocké dans un fichier conv.dat
import float_pack::*;
import tb_float_pack::*;
module tb_float_conv;
	parameter Ntest=1000000;
	tb_float A;
	tb_float B;
	tb_float C;
	tb_float D;
	shortreal rA;
	shortreal rB;
	shortreal rC;
	shortreal rD;
	shortreal rG;
	real tmp ;
	integer ofmul;//le fichier de sortie
	int i;
        shortreal max_pos_val ;
        shortreal max_neg_val ;
        shortreal min_pos_val ;
        shortreal min_neg_val ;
	int err=0;
	int normal_case = 0 ;
	int poids_err ;
	int tb_poids [$size(A.`MANT):0] ;


localparam float pos_inf_val = '{0,(2**$size(A.`EXP))-1,0} ;
localparam float neg_inf_val = '{1,(2**$size(A.`EXP))-1,0} ;
localparam float pos_zero_val = '{0,0,0} ;
localparam float neg_zero_val = '{1,0,0} ;
localparam float max_pos_float_val = '{0,(2**$size(A.`EXP))-2,(2**$size(A.`MANT))-1} ;
localparam float max_neg_float_val = '{1,(2**$size(A.`EXP))-2,(2**$size(A.`MANT))-1} ;
localparam float min_pos_float_val = '{0,1,0} ;
localparam float min_neg_float_val = '{1,1,0} ;


initial begin
ofmul = $fopen("conv.dat");
for (i=0;i<$size(A.`MANT)+1;i++) 
  tb_poids[i] = 0 ;
$fdisplay(ofmul,"===Test Conversions===");
	for(i=0;i<Ntest;i++)begin
	#10
		A.`SIGN=$random() ;
		A.`EXP=$random()  ;
		A.`MANT=$random() ;
		if(A.`EXP == 0) A.`MANT = 0 ;
		if(A.`EXP == ((2**$size(A.`EXP))-1)) A.`EXP = (2**$size(A.`EXP))-2 ;
	        if(i==1)  A =  max_pos_float_val ;
	        if(i==2)  A =  max_neg_float_val ;
	        if(i==3)  A =  min_pos_float_val ;
	        if(i==4)  A =  min_neg_float_val ;
	        if(i==5)  A =  pos_zero_val ;
	        if(i==6)  A =  neg_zero_val ;
		rA=float2real(A);
		B=real2float(rA);
		if (B != A) 
		begin
		   err++ ;
		 //  $display("Ref:signe:%x mantisse:%x exposant:%x Result:signe:%x mantisse:%x exposant:%x",A.`SIGN,A.`MANT,A.`EXP ,B.`SIGN,B.`MANT,B.`EXP) ;
		end
	end
	// Les resultats
	$fdisplay(ofmul,"Conv_case :%06d err:%06d Note sur 1:%5.2f",Ntest,err,1.0-(shortreal'(err)/shortreal'(Ntest))) ;
	$fclose(ofmul);
	$finish ;
end

endmodule;
