// Arbitre pour le Coprocesseur flottant
// auteurs: Scott Messner, Taha Ghazouani
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


  // Montant de cycle d'horloge pour l'operation donnée (respectivement)
  parameter add_count = 3;
  parameter sub_count = 3;
  parameter mul_count = 1;
  parameter div_count = 4;

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

  // init = initilisation de machine d'etat, attente copro valid
  // attente_c = attente copro complete
  // attente_a = attente copro accept
  enum logic [2:0] {init,attente_c,attente_a} state;

  // TODO: changer taille de le champ selon du maximum valuer (div_count)
  logic [3:0] compteur;

  always_ff @(posedge clk) begin
    if(copro_valid==0) begin
      state<=init;
      copro_complete<=0;
    end else begin // step through state machine
      case (state)
        init:
          if(copro_valid==1) begin
            state<=attente_c;
            op0<=copro_op0;
            op1<=copro_op1;
            opcode <= copro_opcode;
            compteur <= choisir_compteur(copro_opcode);
          end else begin
            state<=init;
          end

        attente_c:
          if(compteur==0) begin
            state<=attente_a;
            copro_result <= resultat;
            copro_complete<=1;
          end else begin
            compteur <= compteur-1;
            state    <= attente_c;
          end // else: !if(compteur==0)

        attente_a:      
          if(copro_accept==0) begin
            state<=attente_a;
          end else begin
            state<=init;
            copro_complete<=0;
            
          end
      endcase
    end // if(copro_valid==0)
  end // always_ff @

  /**
   * retourn le valeur de compteur pour l'operation donnée.
   * @param opcode - 0 = add, 1 = sub, 2 = mul, 3 = div;
  **/
  function logic choisir_compteur(logic op_code);
    case (op_code)
      0: choisir_compteur = add_count;
      1: choisir_compteur = sub_count;
      2: choisir_compteur = mul_count;
      3: choisir_compteur = div_count;
      default: choisir_compteur = 0; // opcode is invalid
    endcase
  endfunction
    
endmodule

