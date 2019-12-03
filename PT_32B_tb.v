`timescale 1ns / 10ps
module PT_32B_TB();
	reg[2:0] lookup_addr;
	reg lookup;
	wire lookup_complete;
	wire[5:0] lookup_trans;
	
	reg insert_rqst;
	reg[3:0] insert_indx;
	reg[5:0] insert_entry;

	reg clk;

	reg[5:0] completed_trans;

initial begin
	clk <= 0;
	lookup <= 0;
	insert_rqst <= 0;
end

PAGE_TABLE_32B pageTable (.LOOKUP_RQST(lookup),.LOOKUP_ADDR(lookup_addr),
	.LOOKUP_COMPLETE(lookup_complete),.LOOKUP_RETURN(lookup_trans),
	.PT_INSERT_RQST(insert_rqst),.PT_INSERT_INDX(insert_indx),
	.PT_INSERT_ENTRY(insert_entry),.clk(clk));

initial begin
	repeat (100) begin
		#1 clk <= ~clk;
	end
end
reg [4:0] indx;
initial begin
	insert_indx <= #1 15;
	insert_entry <= #1 6'b101010;
	insert_rqst <= #2 1;
	insert_rqst <= #4 0;

	lookup_addr <= #6 3'b101;
	lookup <= #7 1;
	lookup <= #9 0;
end

always @ * begin
	if (lookup_complete) begin
		completed_trans <= lookup_trans;
	end
end

endmodule