module MUX21 (input A, input B, input S0, output reg C);
	always @ (*) begin
		case (S0)
		0: C = A;
		1: C = B;
		default: C = A;
		endcase
	end
endmodule

module MUX42 (input A, input B, input C, input D, input S0, input S1, output reg E);
	always @(*) begin
		case ({S1, S0})
			2'b00: E = A;
			2'b01: E = B;
			2'b10: E = C;
			2'b11: E = D;
			default: E = A;
      endcase
   end
endmodule

module DEMUX4 (input in, input [1:0] sel, output reg [3:0] out);

    always @(*) begin
        out = 4'b0000;
        case (sel)
            2'b00: out = 4'b0001;
            2'b01: out = (in) ? 4'b0001 : 4'b0000;
            2'b10: out = (in) ? 4'b0010 : 4'b0000;
            2'b11: out = (in) ? 4'b0100 : 4'b0000;
            default: out = 4'b0000;
        endcase
    end

endmodule

module DEMUX6 (input in, input [1:0] sel, output reg [5:0] out);

    always @(*) begin
        out = 6'b111111;
        case (sel)
            2'b00: out = 6'b111111;
            2'b01: out = (in) ? 6'b000011 : 6'b111111;
            2'b10: out = (in) ? 6'b001100 : 6'b111111;
            2'b11: out = (in) ? 6'b110000 : 6'b111111;
            default: out = 6'b111111;
        endcase
    end

endmodule

module HEX_3MUX_MODE (input [2:0] mux_mode,
	input KEY1, KEY2, KEY0,
	input [6:0] HEX0_in1, HEX1_in1, HEX2_in1, HEX3_in1, HEX4_in1, HEX5_in1,
	input [6:0] HEX0_in2, HEX1_in2, HEX2_in2, HEX3_in2, HEX4_in2, HEX5_in2,
	input [6:0] HEX0_in3, HEX1_in3, HEX2_in3, HEX3_in3, HEX4_in3, HEX5_in3,
	output reg key1_1, key1_2, key1_3,
	output reg key2_1, key2_2, key2_3,
	output reg key0_1, key0_2, key0_3,
	output reg [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
	
	always @(*) begin
		case (mux_mode)
			3'b001: begin
				HEX0 = HEX0_in1;
				HEX1 = HEX1_in1;
				HEX2 = HEX2_in1;
				HEX3 = HEX3_in1;
				HEX4 = HEX4_in1;
				HEX5 = HEX5_in1;
				key1_1 = KEY1;
				key2_1 = KEY2;
				key0_1 = KEY0;
			end
			3'b010: begin
				HEX0 = HEX0_in2;
				HEX1 = HEX1_in2;
				HEX2 = HEX2_in2;
				HEX3 = HEX3_in2;
				HEX4 = HEX4_in2;
				HEX5 = HEX5_in2;
				key1_2 = KEY1;
				key2_2 = KEY2;
				key0_2 = KEY0;
			end
			3'b100: begin
				HEX0 = HEX0_in3;
				HEX1 = HEX1_in3;
				HEX2 = HEX2_in3;
				HEX3 = HEX3_in3;
				HEX4 = HEX4_in3;
				HEX5 = HEX5_in3;
				key1_3 = KEY1;
				key2_3 = KEY2;
				key0_3 = KEY0;
			end
			default: begin
				HEX0 = HEX0_in1;
				HEX1 = HEX1_in1;
				HEX2 = HEX2_in1;
				HEX3 = HEX3_in1;
				HEX4 = HEX4_in1;
				HEX5 = HEX5_in1;
				key1_1 = KEY1;
				key2_1 = KEY2;
				key0_1 = KEY0;
			end
		endcase
	end
endmodule



