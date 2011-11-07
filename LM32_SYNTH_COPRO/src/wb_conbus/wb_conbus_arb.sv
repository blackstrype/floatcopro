module wb_conbus_arb(clk, rst, reqs, gnt);

   parameter NUM_MASTERS = 8;

   input      clk;
   input      rst;
   input  [NUM_MASTERS-1:0] reqs;      // Requests from masters
   output [NUM_MASTERS-1:0]  gnt;      // which master is granted
   reg    [NUM_MASTERS-1:0]  gnt;


   always@(posedge clk or posedge rst)
   begin: RR
     int  i;
     if(rst)
       // grant master 0
       gnt = 1;
     else
       for ( i=0; i < NUM_MASTERS; i=i+1 )
     begin
        // if the already granted master still 
        // has a request, then grant him again
        if ( gnt & reqs ) break;

        // else try the next master
        gnt = {gnt[NUM_MASTERS-2:0],gnt[NUM_MASTERS-1]};
     end
   end: RR

endmodule


