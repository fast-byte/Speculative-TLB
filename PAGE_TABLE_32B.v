// -----------------------------------------------------------------------------
// 32 BYTE PAGE TABLE
// USED FOR SPECULATIVE PAGE TRANSLATIONS
// WHEN ENTRY IS NOT PRESENT IN TLB
//
// Author: Calvin Jarrod Smith
// -----------------------------------------------------------------------------
module PAGE_TABLE_32B
	#(parameter [3:0]PT_32B_ENTRIES = 8)
	(
	// USED BY TLB TO REQUEST LOOKUP
	input LOOKUP_RQST, 
	input [3:0] LOOKUP_ADDR, 
	output reg LOOKUP_COMPLETE,
	output reg [7:0] LOOKUP_RETURN,

	input clk
);
reg [7:0] PT_32B[0:PT_32B_ENTRIES-1];
reg [2:0] indx;
reg [7:0] currentPTentry;
reg [1:0] state, nextState;
	
initial begin
	$readmemh("PT_32B_ENTRIES.dat",PT_32B);
	LOOKUP_COMPLETE = 0;
	LOOKUP_RETURN = 8'bZ;
	indx = 0;
	state = 0;
	nextState = 0;
end

// CHANGE CURRENT STATE BASED ON CLOCK
always @ (posedge clk) begin
	state = nextState;
	case (state)
		2'b01: if (LOOKUP_ADDR != currentPTentry[7:4]) indx = indx + 1;
		2'b10: indx = 0;
	endcase
end

always @ * begin
	case (state)
		2'b00: begin
			nextState = {1'b0,LOOKUP_RQST};
		end
		2'b01: begin
			currentPTentry = PT_32B[indx];
			//$display ("Current indx: %b",indx);
			if (LOOKUP_ADDR == currentPTentry[7:4]) begin
				LOOKUP_RETURN = currentPTentry;
				LOOKUP_COMPLETE = 1;	
				nextState = 2'b10;		
			end //else nextState = 2'b01;
		end
		// WAIT ONE CYCLE AFTER TRANSMITTING TRANSLATION
		2'b10: begin
			LOOKUP_COMPLETE = 1'b0;
			LOOKUP_RETURN = 8'bZ;
			nextState = 2'b00;
		end
	endcase
end 	
endmodule