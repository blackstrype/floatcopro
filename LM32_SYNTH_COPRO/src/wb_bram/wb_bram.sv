//-----------------------------------------------------------------
// Wishbone BlockRAM
//-----------------------------------------------------------------

module wb_bram #(
    parameter mem_file_name = "none",
    parameter adr_width = 11
) (
    input             clk_i,
    input             rst_i,
    //
    input             wb_stb_i,
    input             wb_cyc_i,
    input             wb_we_i,
    output            wb_ack_o,
    input      [31:0] wb_adr_i,
    output reg [31:0] wb_dat_o,
    input      [31:0] wb_dat_i,
    input      [ 3:0] wb_sel_i
);

//-----------------------------------------------------------------
// Storage depth in 32 bit words
//-----------------------------------------------------------------
localparam word_adr_width = adr_width - 2;
localparam word_depth = (1 << word_adr_width);


//-----------------------------------------------------------------
//
//-----------------------------------------------------------------
reg         [31:0] ram [0:word_depth-1];    // actual RAM
reg                   ack;
wire [word_adr_width-1:0] adr;


assign adr        = wb_adr_i[adr_width-1:2];      // words
assign wb_ack_o   = wb_stb_i & ack;

always @(posedge clk_i)
begin:main_loop
    if (wb_stb_i && wb_cyc_i)
    begin
        if (wb_we_i)
        begin
            if (wb_sel_i[0]) ram[ adr ][7:0]   <= wb_dat_i[7:0];
            if (wb_sel_i[1]) ram[ adr ][15:8]  <= wb_dat_i[15:8];
            if (wb_sel_i[2]) ram[ adr ][23:16] <= wb_dat_i[23:16];
            if (wb_sel_i[3]) ram[ adr ][31:24] <= wb_dat_i[31:24];
        end

        wb_dat_o <= ram[ adr ];
        ack <= ~ack;
        end
        else
        ack <= 0;

end

initial
begin
    if (mem_file_name != "none")
    begin
        $readmemh("soft.vm", ram);
    end
end

endmodule

