/*Projet COMELEC Clanzig Kellya et TOVO Flavia

Module de simulation du système. Donne l'horloge et le reset puis laisse
évoluer le système pendant un certain temps. Il instancie de plus le module
sortie qui permet d'écrire dans la console les informations provenant de la
sortie uart_txd.

*/

`timescale 1ns/100ps

module test_bench_DE2(); 

// DE2 IOs
 reg         clock_27;            //   27 MHz
 reg         clock_50;            //   50 MHz
 reg         ext_clock;           //   External Clock
 reg   [3:0]   key;               //   Pushbutton[3:0]
 reg   [17:0]   sw;               //   Toggle Switch[17:0]
wire   [6:0]   hex0;               //   Seven Segment Digit 0
wire   [6:0]   hex1;               //   Seven Segment Digit 1
wire   [6:0]   hex2;               //   Seven Segment Digit 2
wire   [6:0]   hex3;               //   Seven Segment Digit 3
wire   [6:0]   hex4;               //   Seven Segment Digit 4
wire   [6:0]   hex5;               //   Seven Segment Digit 5
wire   [6:0]   hex6;               //   Seven Segment Digit 6
wire   [6:0]   hex7;               //   Seven Segment Digit 7
wire   [8:0]   ledg;               //   LED Green[8:0]
wire   [17:0]  ledr;               //   LED Red[17:0]
wire         uart_txd;             //   UART Transmitter
wire         uart_rxd;             //   UART Receiver
wire         irda_txd;             //   IRDA Transmitter
 reg         irda_rxd;             //   IRDA Receiver
wire   [15:0]   dram_dq;           //   SDRAM Data bus 16 Bits
wire   [11:0]   dram_addr;         //   SDRAM Address bus 12 Bits
wire         dram_ldqm;            //   SDRAM Low-byte Data Mask 
wire         dram_udqm;            //   SDRAM High-byte Data Mask
wire         dram_we_n;            //   SDRAM Write Enable
wire         dram_cas_n;           //   SDRAM Column Address Strobe
wire         dram_ras_n;           //   SDRAM Row Address Strobe
wire         dram_cs_n;            //   SDRAM Chip Select
wire         dram_ba_0;            //   SDRAM Bank Address 0
wire         dram_ba_1;            //   SDRAM Bank Address 0
wire         dram_clk;             //   SDRAM Clock
wire         dram_cke;             //   SDRAM Clock Enable
wire   [7:0]   fl_dq;              //   FLASH Data bus 8 Bits
wire   [21:0]  fl_addr;            //   FLASH Address bus 22 Bits
wire         fl_we_n;              //   FLASH Write Enable
wire         fl_rst_n;             //   FLASH Reset
wire         fl_oe_n;              //   FLASH Output Enable
wire         fl_ce_n;              //   FLASH Chip Enable
wire   [15:0]   sram_dq;           //   SRAM Data bus 16 Bits
wire   [17:0]   sram_addr;         //   SRAM Address bus 18 Bits
wire         sram_ub_n;            //   SRAM High-byte Data Mask 
wire         sram_lb_n;            //   SRAM Low-byte Data Mask 
wire         sram_we_n;            //   SRAM Write Enable
wire         sram_ce_n;            //   SRAM Chip Enable
wire         sram_oe_n;            //   SRAM Output Enable
wire   [15:0]  otg_data;           //   ISP1362 Data bus 16 Bits
wire   [1:0]   otg_addr;           //   ISP1362 Address 2 Bits
wire         otg_cs_n;             //   ISP1362 Chip Select
wire         otg_rd_n;             //   ISP1362 Write
wire         otg_wr_n;             //   ISP1362 Read
wire         otg_rst_n;            //   ISP1362 Reset
wire         otg_fspeed;           //   USB Full Speed,   0 = Enable, Z = Disable
wire         otg_lspeed;           //   USB Low Speed,    0 = Enable, Z = Disable
 reg         otg_int0;             //   ISP1362 Interrupt 0
 reg         otg_int1;             //   ISP1362 Interrupt 1
 reg         otg_dreq0;            //   ISP1362 DMA Request 0
 reg         otg_dreq1;            //   ISP1362 DMA Request 1
wire         otg_dack0_n;          //   ISP1362 DMA Acknowledge 0
wire         otg_dack1_n;          //   ISP1362 DMA Acknowledge 1
wire   [7:0]   lcd_data;           //   LCD Data bus 8 bits
wire         lcd_on;               //   LCD Power ON/OFF
wire         lcd_blon;             //   LCD Back Light ON/OFF
wire         lcd_rw;               //   LCD Read/Write Select, 0 = Write, 1 = Read
wire         lcd_en;               //   LCD Enable
wire         lcd_rs;               //   LCD Command/Data Select, 0 = Command, 1 = Data
wire         sd_dat;               //   SD Card Data
wire         sd_dat3;              //   SD Card Data 3
wire         sd_cmd;               //   SD Card Command Signal
wire         sd_clk;               //   SD Card Clock
wire         i2c_sdat;             //   I2C Data
wire         i2c_sclk;             //   I2C Clock
 reg          ps2_dat;             //   PS2 Data
 reg         ps2_clk;              //   PS2 Clock
 reg           tdi;                // CPLD -> FPGA (data in)
 reg           tck;                // CPLD -> FPGA (clk)
 reg           tcs;                // CPLD -> FPGA (CS)
wire          tdo;                 // FPGA -> CPLD (data out)
wire         vga_clk;              //   VGA Clock
wire         vga_hs;               //   VGA H_SYNC
wire         vga_vs;               //   VGA V_SYNC
wire         vga_blank;            //   VGA BLANK
wire         vga_sync;             //   VGA SYNC
wire   [9:0]   vga_r;              //   VGA Red[9:0]
wire   [9:0]   vga_g;              //   VGA Green[9:0]
wire   [9:0]   vga_b;              //   VGA Blue[9:0]
wire   [15:0]   enet_data;         //   DM9000A DATA bus 16Bits
wire         enet_cmd;             //   DM9000A Command/Data Select, 0 = Command, 1 = Data
wire         enet_cs_n;            //   DM9000A Chip Select
wire         enet_wr_n;            //   DM9000A Write
wire         enet_rd_n;            //   DM9000A Read
wire         enet_rst_n;           //   DM9000A Reset
 reg         enet_int;             //   DM9000A Interrupt
wire         enet_clk;             //   DM9000A Clock 25 MHz
wire         aud_adclrck;          //   Audio CODEC ADC LR Clock
 reg         aud_adcdat;           //   Audio CODEC ADC Data
wire         aud_daclrck;          //   Audio CODEC DAC LR Clock
wire         aud_dacdat;           //   Audio CODEC DAC Data
wire         aud_bclk;             //   Audio CODEC Bit-Stream Clock
wire         aud_xck;              //   Audio CODEC Chip Clock
 reg   [7:0]   td_data;            //   TV Decoder Data bus 8 bits
 reg         td_hs;                //   TV Decoder H_SYNC
 reg         td_vs;                //   TV Decoder V_SYNC
wire         td_reset;             //   TV Decoder Reset
 reg         td_clk;               //   TV Decoder Clock
wire   [35:0]   gpio_0;            //   GPIO Connection 0
wire   [35:0]   gpio_1;            //   GPIO Connection 1


reg reset;
assign key = {1'b0,1'b0,1'b0,~reset};

task stop_after (int n);
  begin
    repeat(n) @(negedge clock_50) ;
    $stop();
  end
endtask

initial begin
   clock_50 = 0;
   clock_27 = 0;
   reset = 1; 
   @(negedge clock_50);
   @(negedge clock_50);
   reset = 0;
   stop_after (10_000_000) ;
end

// This block generates a clock pulse
always #10ns clock_50 = ~ clock_50;


// instances

    DE2_TOP DE2(
            .CLOCK_27    ( clock_27 ),
            .CLOCK_50    ( clock_50 ),
            .EXT_CLOCK   ( ext_clock ),
            .KEY         ( key ),
            .SW          ( sw ),
            .HEX0        ( hex0 ),
            .HEX1        ( hex1 ),
            .HEX2        ( hex2 ),
            .HEX3        ( hex3 ),
            .HEX4        ( hex4 ),
            .HEX5        ( hex5 ),
            .HEX6        ( hex6 ),
            .HEX7        ( hex7 ),
            .LEDG        ( ledg ),
            .LEDR        ( ledr ),
            .UART_TXD    ( uart_txd ),
            .UART_RXD    ( uart_rxd ),
            .IRDA_TXD    ( irda_txd ),
            .IRDA_RXD    ( irda_rxd ),
            .DRAM_DQ     ( dram_dq ),
            .DRAM_ADDR   ( dram_addr ),
            .DRAM_LDQM   ( dram_ldqm ),
            .DRAM_UDQM   ( dram_udqm ),
            .DRAM_WE_N   ( dram_we_n ),
            .DRAM_CAS_N  ( dram_cas_n ),
            .DRAM_RAS_N  ( dram_ras_n ),
            .DRAM_CS_N   ( dram_cs_n ),
            .DRAM_BA_0   ( dram_ba_0 ),
            .DRAM_BA_1   ( dram_ba_1 ),
            .DRAM_CLK    ( dram_clk ),
            .DRAM_CKE    ( dram_cke ),
            .FL_DQ       ( fl_dq ),
            .FL_ADDR     ( fl_addr ),
            .FL_WE_N     ( fl_we_n ),
            .FL_RST_N    ( fl_rst_n ),
            .FL_OE_N     ( fl_oe_n ),
            .FL_CE_N     ( fl_ce_n ),
            .SRAM_DQ     ( sram_dq ),
            .SRAM_ADDR   ( sram_addr ),
            .SRAM_UB_N   ( sram_ub_n ),
            .SRAM_LB_N   ( sram_lb_n ),
            .SRAM_WE_N   ( sram_we_n ),
            .SRAM_CE_N   ( sram_ce_n ),
            .SRAM_OE_N   ( sram_oe_n ),
            .OTG_DATA    ( otg_data ),
            .OTG_ADDR    ( otg_addr ),
            .OTG_CS_N    ( otg_cs_n ),
            .OTG_RD_N    ( otg_rd_n ),
            .OTG_WR_N    ( otg_wr_n ),
            .OTG_RST_N   ( otg_rst_n ),
            .OTG_FSPEED  ( otg_fspeed ),
            .OTG_LSPEED  ( otg_lspeed ),
            .OTG_INT0    ( otg_int0 ),
            .OTG_INT1    ( otg_int1 ),
            .OTG_DREQ0   ( otg_dreq0 ),
            .OTG_DREQ1   ( otg_dreq1 ),
            .OTG_DACK0_N ( otg_dack0_n ),
            .OTG_DACK1_N ( otg_dack1_n ),
            .LCD_DATA    ( lcd_data ),
            .LCD_ON      ( lcd_on ),
            .LCD_BLON    ( lcd_blon ),
            .LCD_RW      ( lcd_rw ),
            .LCD_EN      ( lcd_en ),
            .LCD_RS      ( lcd_rs ),
            .SD_DAT      ( sd_dat ),
            .SD_DAT3     ( sd_dat3 ),
            .SD_CMD      ( sd_cmd ),
            .SD_CLK      ( sd_clk ),
            .I2C_SDAT    ( i2c_sdat ),
            .I2C_SCLK    ( i2c_sclk ),
            .PS2_DAT     ( ps2_dat ),
            .PS2_CLK     ( ps2_clk ),
            .TDI         ( tdi ),
            .TCK         ( tck ),
            .TCS         ( tcs ),
            .TDO         ( tdo ),
            .VGA_CLK     ( vga_clk ),
            .VGA_HS      ( vga_hs ),
            .VGA_VS      ( vga_vs ),
            .VGA_BLANK   ( vga_blank ),
            .VGA_SYNC    ( vga_sync ),
            .VGA_R       ( vga_r ),
            .VGA_G       ( vga_g ),
            .VGA_B       ( vga_b ),
            .ENET_DATA   ( enet_data ),
            .ENET_CMD    ( enet_cmd ),
            .ENET_CS_N   ( enet_cs_n ),
            .ENET_WR_N   ( enet_wr_n ),
            .ENET_RD_N   ( enet_rd_n ),
            .ENET_RST_N  ( enet_rst_n ),
            .ENET_INT    ( enet_int ),
            .ENET_CLK    ( enet_clk ),
            .AUD_ADCLRCK ( aud_adclrck ),
            .AUD_ADCDAT  ( aud_adcdat ),
            .AUD_DACLRCK ( aud_daclrck ),
            .AUD_DACDAT  ( aud_dacdat ),
            .AUD_BCLK    ( aud_bclk ),
            .AUD_XCK     ( aud_xck ),
            .TD_DATA     ( td_data ),
            .TD_HS       ( td_hs ),
            .TD_VS       ( td_vs ),
            .TD_RESET    ( td_reset ),
            .TD_CLK      ( td_clk ),
            .GPIO_0      ( gpio_0 ),
            .GPIO_1      ( gpio_1 )
    );

// uart 
xtermtty SORTIE(.TX_in(uart_txd), .RX_out(uart_rxd));

// sram
sram_model SRAM(
                 .A  (sram_addr),
                 .IO (sram_dq),
                 .CE_(sram_ce_n),
                 .OE_(sram_oe_n),
                 .WE_(sram_we_n),
                 .LB_(sram_lb_n),
                 .UB_(sram_ub_n)
        );

endmodule
