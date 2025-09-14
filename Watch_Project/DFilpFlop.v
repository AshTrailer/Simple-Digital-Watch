module PosEdgeAsynDFF (input D, input clk, input reset, output reg Q);
	always @ (posedge clk or posedge reset) begin
	if (reset)
		Q <= 1'b0;
	else
		Q <= D;
	end
endmodule

module PosEdgeSynDFF (input D, input clk, input reset, output reg Q);
	always @ (posedge clk) begin
		if (reset)
			Q <= 1'b0;
		else
			Q <= D;
	end
endmodule
