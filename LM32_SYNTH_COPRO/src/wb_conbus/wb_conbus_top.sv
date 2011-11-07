module wb_conbus_top (
            // Clock and Reset
            clk_i, rst_i,

            // Master Interfaces
            m_dat_i, m_dat_o, m_adr_i, m_sel_i, m_we_i, m_cyc_i,
            m_stb_i, m_ack_o, m_err_o, m_rty_o,
            m_cti_i, m_bte_i,

            // Slave Interfaces
            s_dat_i, s_dat_o, s_adr_o, s_sel_o, s_we_o, s_cyc_o,
            s_stb_o, s_ack_i, s_err_i, s_rty_i,
            s_cti_o, s_bte_o

            );

   localparam    DATA_W = 32; // Data bus Width
   localparam    ADD_W = 32;  // Address bus Width
   localparam    SEL_W = 4;   // Number of Select Lines
   // lm32 burst extension
   localparam CTI_W = 3;
   localparam BTE_W = 2;


   // parameters
   parameter NUM_MASTERS = 8;
   parameter NUM_SLAVES  = 8;
   parameter  logic [ADD_W-1:0]  s_ADDR [NUM_SLAVES-1:0] = '{NUM_SLAVES{'0}};

   input    clk_i, rst_i;

   // Master Interfaces
   input  [NUM_MASTERS*DATA_W-1:0] m_dat_i;
   output [NUM_MASTERS*DATA_W-1:0] m_dat_o;
   input  [NUM_MASTERS*ADD_W-1 :0] m_adr_i;
   input  [NUM_MASTERS*SEL_W-1 :0] m_sel_i;
   input  [NUM_MASTERS-1:0]        m_we_i;
   input  [NUM_MASTERS-1:0]        m_cyc_i;
   input  [NUM_MASTERS-1:0]        m_stb_i;
   output [NUM_MASTERS-1:0]        m_ack_o;
   output [NUM_MASTERS-1:0]        m_err_o;
   output [NUM_MASTERS-1:0]        m_rty_o;
   // lm32 burst extension
   input  [CTI_W*NUM_MASTERS-1:0]  m_cti_i;
   input  [BTE_W*NUM_MASTERS-1:0]  m_bte_i;

   // Slave Interfaces
   input  [NUM_SLAVES*DATA_W-1:0]  s_dat_i;
   output [NUM_SLAVES*DATA_W-1:0]  s_dat_o;
   output [NUM_SLAVES*ADD_W-1 :0]  s_adr_o;
   output [NUM_SLAVES*SEL_W-1 :0]  s_sel_o;
   output [NUM_SLAVES-1:0]         s_we_o;
   output [NUM_SLAVES-1:0]         s_cyc_o;
   output [NUM_SLAVES-1:0]         s_stb_o;
   input  [NUM_SLAVES-1:0]         s_ack_i;
   input  [NUM_SLAVES-1:0]         s_err_i;
   input  [NUM_SLAVES-1:0]         s_rty_i;
   // lm32 burst extension
   output [CTI_W*NUM_SLAVES-1:0]   s_cti_o;
   output [BTE_W*NUM_SLAVES-1:0]   s_bte_o;

   // Local wires
   wire [NUM_MASTERS-1:0]        reqs;
   wire [NUM_MASTERS-1:0]        gnt;

   assign reqs = m_cyc_i;

   // Round robin arbiter
   wb_conbus_arb    #(.NUM_MASTERS(NUM_MASTERS))
   Arbiter_i(
             .clk(clk_i),
             .rst(rst_i),
             .reqs(reqs),
             .gnt(gnt)
             );

   // Master selection

   int   gnted;

   always_comb
     begin: Gnted_master
     for (gnted=0;gnted<NUM_MASTERS;gnted++)
       if (gnt[gnted]) break;
     end

   // address to decode
   wire [ADD_W-1:0] gnted_m_adr;
   assign gnted_m_adr = m_adr_i[(gnted+1)*ADD_W-1 -: ADD_W];

   // Slave selection / address decode
   int selected_s;

   always_comb
   begin: Add_decode
     for (selected_s = 0; selected_s < NUM_SLAVES; selected_s++)
         if(gnted_m_adr ==? s_ADDR[selected_s]) break;
   end

   // Interconnection
   logic [NUM_MASTERS*DATA_W-1:0] m_dat_o;
   logic [NUM_MASTERS-1:0]        m_ack_o;
   logic [NUM_MASTERS-1:0]        m_err_o;
   logic [NUM_MASTERS-1:0]        m_rty_o;

   // Slave Interfaces
   logic [NUM_SLAVES*DATA_W-1:0]  s_dat_o;
   logic [NUM_SLAVES*ADD_W-1 :0]  s_adr_o;
   logic [NUM_SLAVES*SEL_W-1 :0]  s_sel_o;
   logic [NUM_SLAVES-1:0]         s_we_o;
   logic [NUM_SLAVES-1:0]         s_cyc_o;
   logic [NUM_SLAVES-1:0]         s_stb_o;
   logic [NUM_SLAVES*CTI_W-1:0]   s_cti_o;
   logic [NUM_SLAVES*BTE_W-1:0]   s_bte_o;

   always_comb
   begin: Interco
     // default output to slaves values
     s_dat_o <= '0;
     s_adr_o <= '0;
     s_sel_o <= '0;
     s_we_o  <= '0;
     s_cyc_o <= '0;
     s_stb_o <= '0;
     s_cti_o <= '0;
     s_bte_o <= '0;

   // From granted master to selected slave
     s_dat_o[(selected_s+1)*DATA_W-1 -: DATA_W] <= m_dat_i[(gnted+1)*DATA_W-1 -: DATA_W];
     s_adr_o[(selected_s+1)*ADD_W-1  -:  ADD_W] <= m_adr_i[(gnted+1)*ADD_W-1  -:  ADD_W];
     s_sel_o[(selected_s+1)*SEL_W-1  -:  SEL_W] <= m_sel_i[(gnted+1)*SEL_W-1  -:  SEL_W];
     s_we_o [selected_s]                    <= m_we_i [gnted];
     s_cyc_o[selected_s]                    <= m_cyc_i[gnted];
     s_stb_o[selected_s]                    <= m_stb_i[gnted];
     s_cti_o[selected_s]                    <= m_cti_i[gnted];
     s_bte_o[selected_s]                    <= m_bte_i[gnted];

     // default output to masters values
     m_dat_o <= '0;
     m_ack_o <= '0;
     m_err_o <= '0;
     m_rty_o <= '0;

    // From selected slave to granted master
     m_dat_o[(gnted+1)*DATA_W-1 -: DATA_W] <= s_dat_i[(selected_s+1)*DATA_W-1 -: DATA_W];
     m_ack_o[gnted]                    <= s_ack_i[selected_s];
     m_err_o[gnted]                    <= s_err_i[selected_s];
     m_rty_o[gnted]                    <= s_rty_i[selected_s];

   end

// synthesis translate_off
  // Check if we dont have conflicting addresses
  initial
  begin: CheckAddresses
  int i,j;
     for (i=0;i<NUM_SLAVES-1;i++) 
        for (j=i+1;j<NUM_SLAVES;j++) 
            if (s_ADDR[i] ==?  s_ADDR[j])
            begin
                $display("ERROR: Slave %d and slave %d have the same addresses %x and %x !!",
                i,j, s_ADDR[i], s_ADDR[j] );
                $stop();
            end
  end
// synthesis translate_on

endmodule
