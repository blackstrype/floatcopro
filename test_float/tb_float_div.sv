import float_pack::*;
import tb_float_pack::*;
module tb_float_div;
// Les fonctions de conversion de référence
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
	integer of;//le fichier de sortie
	int i;
        shortreal max_pos_val ;
        shortreal max_neg_val ;
        shortreal min_pos_val ;
        shortreal min_neg_val ;
	int max_sat_case,max_sat_err=0;
	int zero_sat_case,zero_sat_err=0;
	int zero_out_case,zero_out_err=0;
	int sign_out_case,sign_out_err=0;
	int exp_out_case,exp_out_err=0;
	int mant_out_case,mant_out_err=0;
	int poids_err ;
	int tb_poids [`TB_MANT_SIZE:0] ;


localparam tb_float pos_inf_val = '{0,(2**`TB_EXP_SIZE)-1,0} ;
localparam tb_float neg_inf_val = '{1,(2**`TB_EXP_SIZE)-1,0} ;
localparam tb_float pos_zero_val = '{0,0,0} ;
localparam tb_float neg_zero_val = '{1,0,0} ;
localparam tb_float max_pos_float_val = '{0,(2**`TB_EXP_SIZE)-2,(2**`TB_MANT_SIZE)-1} ;
localparam tb_float max_neg_float_val = '{1,(2**`TB_EXP_SIZE)-2,(2**`TB_MANT_SIZE)-1} ;
localparam tb_float min_pos_float_val = '{0,1,0} ;
localparam tb_float min_neg_float_val = '{1,1,0} ;


initial begin
of = $fopen("div.dat");
for (i=0;i<`TB_MANT_SIZE+1;i++) 
  tb_poids[i] = 0 ;
//============================================================================
// 
//                       Test division
max_pos_val = tb_float2real(max_pos_float_val) ;
max_neg_val = tb_float2real(max_neg_float_val) ;
min_pos_val = tb_float2real(min_pos_float_val) ;
min_neg_val = tb_float2real(min_neg_float_val) ;
$fdisplay(of,"===Test Division===");
	for(i=0;i<Ntest;i++)begin
	#10
		A.`SIGN=$random() ;
		A.`EXP=$random()  ;
		A.`MANT=$random() ;
		if(A.`EXP == 0) A.`MANT = 0 ;
		if(A.`EXP == ((2**`TB_EXP_SIZE)-1)) A.`EXP = (2**`TB_EXP_SIZE)-2 ;
	        if(i<2000) 
		begin
		A.`SIGN=$random ;
		A.`EXP=0  ;
		A.`MANT=0 ;
		end
		B.`SIGN=$random() ;
		B.`EXP=$random()  ;
		B.`MANT=$random() ;
		if(B.`EXP == 0) A.`MANT = 0 ;
		if(B.`EXP == ((2**`TB_EXP_SIZE)-1)) B.`EXP = (2**`TB_EXP_SIZE)-2 ;
		if(B == pos_zero_val) B=min_pos_val ;
		if(B == neg_zero_val) B=min_neg_val ;
                 
		rA=tb_float2real(A);
		rB=tb_float2real(B);

		C=float_div(A,B);
		rC=tb_float2real(C);
		rD=rA/rB;
		D=tb_real2float(rD);
		// Verification des dépassements
		if (rD > max_pos_val)
		begin
		  max_sat_case++ ;
		  if ((rC != max_pos_val) && (C != pos_inf_val))  max_sat_err++ ;
		  //$fdisplay(of,"Dépassement maximal positif mal traité") ; 
		  //$fdisplay(of,"%e %e %e %e s:%x m:%x e:%x",rA,rB,rC,rD,C.`SIGN,C.`MANT,C.`EXP) ;
		end
		else
		if (rD < max_neg_val)
		begin
		  max_sat_case++ ;
		  if ((rC != max_neg_val)&& (C != neg_inf_val)) max_sat_err++ ;
		  //$fdisplay(of,"Dépassement maximal negatif mal traité") ; 
		  //$fdisplay(of,"%e %e %e %e s:%x m:%x e:%x",rA,rB,rC,rD,C.`SIGN,C.`MANT,C.`EXP) ;
		end
		else
		if (((rD > 0) && (rD <  min_pos_val)) || ((rD < 0) && (rD > min_neg_val)))
		begin
		  zero_sat_case++ ;
		  if (C != pos_zero_val && C!=neg_zero_val) zero_sat_err ++ ;
		  //$fdisplay(of,"Troncature à zero  positif mal traité") ; 
		  //$fdisplay(of,"%e %e %e %e s:%x m:%x e:%x",rA,rB,rC,rD,C.`SIGN,C.`MANT,C.`EXP) ;
		end
		else  // Le resultat nul
		if ((A == pos_zero_val) || (A == neg_zero_val))
	        begin
		  zero_out_case++ ;
		  if (!((C == pos_zero_val)|| (C== neg_zero_val))) zero_out_err++ ;
		  //$display("%e %e %e %e s:%x m:%x e:%x sr:%x mr:%x er:%x",rA,rB,rC,rD,C.`SIGN,C.`MANT,C.`EXP,neg_zero_val.`SIGN,neg_zero_val.`MANT,neg_zero_val.`EXP) ;
		end
		else // Le signe mauvais
		if (((A.`SIGN == B.`SIGN) && (C.`SIGN != 0)) ||((A.`SIGN != B.`SIGN) && (C.`SIGN != 1)))
		begin
		  sign_out_err++ ;
		end 
		else // exposant mauvais
		if ((C.`EXP != D.`EXP)) 
		begin
		  exp_out_err++ ;
		end 
		else // Le cas normal : calcul de l'erreur max et de l'erreur moyenne
		begin
		  tmp = real'(rC -rD)/real'(rD) ;
		  if(tmp < 0) tmp = -tmp ;
		  tmp = tmp*real'(2**`TB_MANT_SIZE) ;
		  poids_err = $clog2(int'(tmp)) ;
		  tb_poids[poids_err] = tb_poids[poids_err]+1 ;
		end

	end
	sign_out_case =  Ntest - max_sat_case -zero_sat_case -zero_out_case ;
	exp_out_case = sign_out_case - sign_out_err ;
		mant_out_case = exp_out_case - exp_out_err ;
	for(i=`TB_MANT_SIZE/2;i<`TB_MANT_SIZE;i++) 
	  mant_out_err = mant_out_err+tb_poids[i] ;
	// Les resultats
	$fdisplay(of,"Max_sat_case :%06d Max_sat_err :%06d",max_sat_case,max_sat_err) ;
	$fdisplay(of,"Zero_sat_case:%06d Zero_sat_err:%06d",zero_sat_case,zero_sat_err) ;
	$fdisplay(of,"Zero_out_case:%06d Zero_out_err:%06d",zero_out_case,zero_out_err) ;
	$fdisplay(of,"Rem_cases    :%06d Sign_out_err:%06d",sign_out_case,sign_out_err) ;
	$fdisplay(of,"Rem_cases    :%06d Exp_out_err :%06d",exp_out_case,exp_out_err) ;
	$fdisplay(of,"Rem_cases    :%06d Mant_our_err:%06d",mant_out_case,mant_out_err) ;
        $fdisplay(of,"===================================================================");
        $fdisplay(of,"=================Detail Mantisses =================================");
	for(i=0;i<`TB_MANT_SIZE+1;i++) 
	  $fdisplay(of,"Err poids: %03d Nb:%6d",i,tb_poids[i]) ;



	$fclose(of);
	$finish ;
end

endmodule;
