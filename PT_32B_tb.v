`timescale 1ns / 10ps
module PT_32B_TB#(parameter NUM_ADDRS = 2)();
reg[3:0] lookup_addr;
reg lookup;
wire lookup_complete;
wire[7:0] lookup_trans;
reg clk;
reg[7:0] completed_trans;
reg [1:0] state, nextState;

PAGE_TABLE_32B pageTable (
	.LOOKUP_RQST(lookup),
	.LOOKUP_ADDR(lookup_addr),
	.LOOKUP_COMPLETE(lookup_complete),
	.LOOKUP_RETURN(lookup_trans),
	.clk(clk)
);
reg [3:0] indx;
reg [8:0] LOOKUP_ADDRS[0:NUM_ADDRS-1];

initial begin
	$readmemh("ADDRS_TO_TRANSLATE.dat",LOOKUP_ADDRS);
	indx = 0;
	state = 0;
	nextState = 0;
	clk <= 0;
	lookup <= 0;
	repeat (100) begin
		#1 clk <= ~clk;
	end
end

//initial begin
//	lookup_addr <= #6 4'b0000;
//	lookup <= #7 1;
//	lookup <= #9 0;
//end

always @ * begin
	case (state) 
		2'b00: nextState = 2'b01;
		2'b01: if (indx < NUM_ADDRS) begin
			lookup_addr = LOOKUP_ADDRS[indx][8:5];
			lookup = 1;
			nextState = 2'b10;
		end else nextState = 2'b01;
		2'b10: if (lookup_complete) begin
			//completed_trans <= lookup_trans;
			nextState = 2'b01;
			end else begin 
				lookup = 0;
				nextState = 2'b10;
			end
	endcase
end

always @ (posedge lookup_complete) begin
	if (indx < NUM_ADDRS) indx = indx + 1;
	completed_trans = lookup_trans;
end

always @ (posedge clk) begin
	state = nextState;
end

endmodule