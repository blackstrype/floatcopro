// Squelette du coprocesseur flottant
module float_copro(
               input logic clk,
               input logic copro_valid,
               input logic copro_accept,
               input logic [10:0] copro_opcode,
               input logic [31:0] copro_op0,
               input logic [31:0] copro_op1,
               output logic copro_complete, 
               output logic[31:0] copro_result
               );

   //registres des opérandes
   logic [31:0]               op0;
   logic [31:0]               op1;
   logic [31:0]               resultat;

   //opération a réaliser
   logic [10:0]               opcode;

   //le datapath
   float_copro_dp datapath(opcode,op0,op1,resultat);
   
   //////////////////////////////////////////////////
   // Compléter en rajoutant registres et contrôle //
   //////////////////////////////////////////////////

   
   enum logic [2:0]  {init,attente_c,attente_a} state;

   
   
   parameter  N =  3;

   integer compteur;


   always_ff @(posedge clk)
     begin
	if(copro_valid==0)
	begin
	  state<=init;
	   copro_complete<=0;
	end
		
	else
	  case (state)
	    
	    init:

	      if(copro_valid==1)
		begin
		   state<=attente_c;
		   compteur<=N;
		end
	      else
		state<=init;

	    attente_c:

	      if(compteur==0)
		begin
		   state<=attente_a;
		   copro_complete<=1;
		end
	      else
		begin
		   compteur<=compteur-1;
		   state<=attente_c;
		   op0<=copro_op0;
		   op1<=copro_op1;
		   opcode<=copro_opcode;
		end // else: !if(compteur==0)

	    attente_a:
	      
	      if(copro_accept==0)
		state<=attente_a;
	      else
		begin
		state<=init;
		copro_complete<=0;
		end
	        
		  
	  endcase
     end // always_ff @
   
endmodule

