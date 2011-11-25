import float_pack::*;
module float_copro_dp(opcode, op0, op1, result);

   input  logic[10:0]        opcode;
   input  logic[31:0]        op0;
   input  logic[31:0]        op1;
   output logic[31:0]        result;

// synthesis translate_off
 shortreal Fop0,Fop1,Fres;
 assign Fop0 = float_ieee2real(op0);
 assign Fop1 = float_ieee2real(op1);
 assign Fres = float_ieee2real(result);
// synthesis translate_on
     
   always_comb
     begin
        result <= '0;
        case (opcode)
          //somme
          11'd0:
            result <= float_add(op0, op1); // op0 + op2;
          //soustraction
          11'd1:
            result <= float_sub(op0, op1);
          //multiplication
          11'd2:
            result <= float_mul(op0, op1);
          //division
         
        endcase
     end
     
endmodule
