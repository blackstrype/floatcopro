//---------------------------------------------------------------------------
// LatticeMico32 System On A Chip
//
// Top Level Design
//---------------------------------------------------------------------------

`include "system_conf.v"

module system
  #(
    parameter   bootram_file     = "soft.vm",
    parameter   clk_freq         = `CLK_FREQUENCY,
    parameter   uart_baud_rate   = `uartBAUD_RATE,
    parameter   b_ram_adddr_w    = `B_RAM_ADD_W
    ) (
    input                        clk,
    input                        rst,
       // UART
    input                        uart_rxd,
    output                       uart_txd,
       // SRAM
    output [17:0]                sram_adr,
    inout  [15:0]                sram_dat,
    output [1:0]                 sram_be_n,    // Byte   Enable
    output                       sram_ce_n,    // Chip   Enable
    output                       sram_oe_n,    // Output Enable
    output                       sram_we_n,    // Write  Enable
    // COPROCESSOR ACCESS
    input  [31:0]                copro_result,
    input                        copro_complete,
    output                       copro_valid,
    output                       copro_accept,
    output [31:0]                copro_op0,
    output [31:0]                copro_op1,
    output [10:0]                copro_opcode
       );

   //reset wire

   //------------------------------------------------------------------
   // Whishbone Wires
   //------------------------------------------------------------------
   wire             gnd   =  1'b0;
   wire [3:0]       gnd4  =  4'h0;
   wire [31:0]      gnd32 = 32'h00000000;


   wire [31:0]  lm32i_adr,
                lm32d_adr,
                uart0_adr,
                timer0_adr,
                bram0_adr,
                sram0_adr;


   wire [31:0]  lm32i_dat_r,
                lm32i_dat_w,
                lm32d_dat_r,
                lm32d_dat_w,
                uart0_dat_r,
                uart0_dat_w,
                timer0_dat_r,
                timer0_dat_w,
                bram0_dat_r,
                bram0_dat_w,
                sram0_dat_w,
                sram0_dat_r;

   wire [3:0]   lm32i_sel,
                lm32d_sel,
                uart0_sel,
                timer0_sel,
                bram0_sel,
                sram0_sel;

   wire         lm32i_we,
                lm32d_we,
                uart0_we,
                timer0_we,
                bram0_we,
                sram0_we;

   wire         lm32i_cyc,
                lm32d_cyc,
                uart0_cyc,
                timer0_cyc,
                bram0_cyc,
                sram0_cyc;

   wire         lm32i_stb,
                lm32d_stb,
                uart0_stb,
                timer0_stb,
                bram0_stb,
                sram0_stb;

   wire         lm32i_ack,
                lm32d_ack,
                uart0_ack,
                timer0_ack,
                bram0_ack,
                sram0_ack;

   wire         lm32i_rty,
                lm32d_rty;

   wire         lm32i_err,
                lm32d_err;

   wire         lm32i_lock,
                lm32d_lock;

   wire [2:0]   lm32i_cti,
                lm32d_cti,
                unused_cti;

   wire [1:0]   lm32i_bte,
                lm32d_bte,
                unused_bte;

   //---------------------------------------------------------------------------
   // Interrupts
   //---------------------------------------------------------------------------
   wire [31:0]   intr_n;
   wire          uart0_intr = 0;
   wire [1:0]    timer0_intr;

   assign        intr_n = { 29'hFFFFFFF, ~timer0_intr[1], ~timer0_intr[0], ~uart0_intr };

   //---------------------------------------------------------------------------
   // Wishbone Interconnect
   //---------------------------------------------------------------------------

   // Address mapping
   // Les address peuvent contenir des X pour limiter la taille
   // du décodeur
    localparam NUM_SLAVES = 4;
    localparam logic [32-1:0]  MAP_ADDR [NUM_SLAVES-1:0] = '{
                       32'hf01x_xxxx, // S3 timer0  f001_0000
                       32'hf00x_xxxx, // S2 uart0   f000_0000
                       32'b0000_0000_0001_0xxx_xxxx_xxxx_xxxx_xxxx, // S1 sram0   0010_0000->0017_ffff = 512K
                       32'h0000_xxxx  // S0 bram0   0000_0000->0000_3fff = 64K
                       };
   wb_conbus_top #(
            .NUM_MASTERS(2),
            .NUM_SLAVES(NUM_SLAVES),
            .s_ADDR(MAP_ADDR)
            )
            conbus_i
            (
                  .clk_i( clk ),
                  .rst_i( rst ),
                  // Masters
                  .m_dat_i( { lm32d_dat_w, lm32i_dat_w } ),
                  .m_dat_o( { lm32d_dat_r, lm32i_dat_r } ),
                  .m_adr_i( { lm32d_adr  , lm32i_adr   } ),
                  .m_we_i ( { lm32d_we   , lm32i_we    } ),
                  .m_sel_i( { lm32d_sel  , lm32i_sel   } ),
                  .m_cyc_i( { lm32d_cyc  , lm32i_cyc   } ),
                  .m_stb_i( { lm32d_stb  , lm32i_stb   } ),
                  .m_ack_o( { lm32d_ack  , lm32i_ack   } ),
                  .m_rty_o( { lm32d_rty  , lm32i_rty   } ),
                  .m_err_o( { lm32d_err  , lm32i_err   } ),
                  .m_cti_i( { lm32d_cti  , lm32i_cti   } ),
                  .m_bte_i( { lm32d_bte  , lm32i_bte   } ),
                  // Slaves
                  .s_dat_i( { timer0_dat_r, uart0_dat_r, sram0_dat_r, bram0_dat_r } ),
                  .s_dat_o( { timer0_dat_w, uart0_dat_w, sram0_dat_w, bram0_dat_w } ),
                  .s_adr_o( { timer0_adr  , uart0_adr  , sram0_adr  , bram0_adr   } ),
                  .s_sel_o( { timer0_sel  , uart0_sel  , sram0_sel  , bram0_sel   } ),
                  .s_we_o ( { timer0_we   , uart0_we   , sram0_we   , bram0_we    } ),
                  .s_cyc_o( { timer0_cyc  , uart0_cyc  , sram0_cyc  , bram0_cyc   } ),
                  .s_stb_o( { timer0_stb  , uart0_stb  , sram0_stb  , bram0_stb   } ),
                  .s_ack_i( { timer0_ack  , uart0_ack  , sram0_ack  , bram0_ack   } ),
                  .s_err_i( { gnd         , gnd        , gnd        , gnd         } ),
                  .s_rty_i( { gnd         , gnd        , gnd        , gnd         } ),
                  .s_cti_o( { unused_cti  , unused_cti , unused_cti , unused_cti  } ),
                  .s_bte_o( { unused_bte  , unused_bte , unused_bte , unused_bte  } )
                  );


   //---------------------------------------------------------------------------
   // LM32 CPU
   //---------------------------------------------------------------------------
   lm32_cpu lm32_cpu0 (
               .clk_i(  clk  ),
               .rst_i(  rst  ),
               .interrupt_n(  intr_n  ),
               // USER
               .user_valid    (copro_valid),
               .user_accept   (copro_accept),
               .user_opcode   (copro_opcode),
               .user_operand_0(copro_op0),
               .user_operand_1(copro_op1),
               .user_result   (copro_result),
               .user_complete (copro_complete),
               // WB
               .I_ADR_O(  lm32i_adr    ),
               .I_DAT_I(  lm32i_dat_r  ),
               .I_DAT_O(  lm32i_dat_w  ),
               .I_SEL_O(  lm32i_sel    ),
               .I_CYC_O(  lm32i_cyc    ),
               .I_STB_O(  lm32i_stb    ),
               .I_ACK_I(  lm32i_ack    ),
               .I_WE_O (  lm32i_we     ),
               .I_CTI_O(  lm32i_cti    ),
               .I_LOCK_O( lm32i_lock   ),
               .I_BTE_O(  lm32i_bte    ),
               .I_ERR_I(  lm32i_err    ),
               .I_RTY_I(  lm32i_rty    ),
               //
               .D_ADR_O(  lm32d_adr    ),
               .D_DAT_I(  lm32d_dat_r  ),
               .D_DAT_O(  lm32d_dat_w  ),
               .D_SEL_O(  lm32d_sel    ),
               .D_CYC_O(  lm32d_cyc    ),
               .D_STB_O(  lm32d_stb    ),
               .D_ACK_I(  lm32d_ack    ),
               .D_WE_O (  lm32d_we     ),
               .D_CTI_O(  lm32d_cti    ),
               .D_LOCK_O( lm32d_lock   ),
               .D_BTE_O(  lm32d_bte    ),
               .D_ERR_I(  lm32d_err    ),
               .D_RTY_I(  lm32d_rty    )
               );

   //---------------------------------------------------------------------------
   // Block RAM
   //---------------------------------------------------------------------------
   wb_bram #(
             .adr_width( b_ram_adddr_w ),
             .mem_file_name( bootram_file )
             ) bram0 (
              .clk_i(  clk  ),
              .rst_i(  rst  ),
              //
              .wb_adr_i(  bram0_adr    ),
              .wb_dat_o(  bram0_dat_r  ),
              .wb_dat_i(  bram0_dat_w  ),
              .wb_sel_i(  bram0_sel    ),
              .wb_stb_i(  bram0_stb    ),
              .wb_cyc_i(  bram0_cyc    ),
              .wb_ack_o(  bram0_ack    ),
              .wb_we_i(   bram0_we     )
              );

   //---------------------------------------------------------------------------
   // sram0
   //---------------------------------------------------------------------------
   wb_sram16 #(
               .adr_width(  18  ),
               .latency(    `sramLATENCY   ),
               .read_latency(    `sramREAD_LATENCY  ),
               .write_latency(    `sramWRITE_LATENCY   )
               ) sram0 (
            .clk(         clk           ),
            .reset(       rst           ),
            // Wishbone
            .wb_cyc_i(    sram0_cyc     ),
            .wb_stb_i(    sram0_stb     ),
            .wb_we_i(     sram0_we      ),
            .wb_adr_i(    sram0_adr     ),
            .wb_dat_o(    sram0_dat_r   ),
            .wb_dat_i(    sram0_dat_w   ),
            .wb_sel_i(    sram0_sel     ),
            .wb_ack_o(    sram0_ack     ),
            // SRAM
            .sram_adr(    sram_adr      ),
            .sram_dat(    sram_dat      ),
            .sram_be_n(   sram_be_n     ),
            .sram_ce_n(   sram_ce_n  ),
            .sram_oe_n(   sram_oe_n     ),
            .sram_we_n(   sram_we_n     )
            );

   //assign              sram_ce_n[1] = sram_ce_n[0];

   //---------------------------------------------------------------------------
   // uart0
   //---------------------------------------------------------------------------

   wb_uart #(
             .clk_freq( clk_freq        ),
             .baud(     uart_baud_rate  )
             ) uart0 (
              .clk( clk ),
              .reset( rst ),
              //
              .wb_adr_i( uart0_adr ),
              .wb_dat_i( uart0_dat_w ),
              .wb_dat_o( uart0_dat_r ),
              .wb_stb_i( uart0_stb ),
              .wb_cyc_i( uart0_cyc ),
              .wb_we_i(  uart0_we ),
              .wb_sel_i( uart0_sel ),
              .wb_ack_o( uart0_ack ),
              //   .intr(       uart0_intr ),
              .uart_rxd( uart_rxd ),
              .uart_txd( uart_txd )
              );

   //---------------------------------------------------------------------------
   // timer0
   //---------------------------------------------------------------------------
   wb_timer #(
              .clk_freq(   clk_freq  )
              ) timer0 (
            .clk(      clk          ),
            .reset(    rst          ),
            //
            .wb_adr_i( timer0_adr   ),
            .wb_dat_i( timer0_dat_w ),
            .wb_dat_o( timer0_dat_r ),
            .wb_stb_i( timer0_stb   ),
            .wb_cyc_i( timer0_cyc   ),
            .wb_we_i(  timer0_we    ),
            .wb_sel_i( timer0_sel   ),
            .wb_ack_o( timer0_ack   ),
            .intr(     timer0_intr  )
            );

endmodule


