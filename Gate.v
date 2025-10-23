 module AND_gate (input A, input B, output C);
 
	assign C = A & B;
 
 endmodule
 
 module OR_gate (input A, input B, output C);
 
	assign C = A | B;
 
 endmodule
 
 module NOR_gate (input A, input B, output C);
 
	 wire D;
	 assign D = A | B;
	 assign C = !D;
 
 endmodule
 
 module NOT_gate(input A, output B);
 
	assign B = !A;   
	
 endmodule
 
 module NAND_gate (input A, input B, output C);
 
	 wire D;
	 assign D = A & B;
	 assign C = !D;
 
 endmodule
 
 module XOR_gate (input A, input B, output C);
 
	assign C = A ^ B;
 
 endmodule
 
 
 
 