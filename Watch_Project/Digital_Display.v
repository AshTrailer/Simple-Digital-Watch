module SSEG(input [3:0] digit, output reg [6:0] SSEG);
	always @(*) begin
		case (digit)
			4'd0 : SSEG = 7'b1000000;
			4'd1 : SSEG = 7'b1111001;
			4'd2 : SSEG = 7'b0100100;
			4'd3 : SSEG = 7'b0110000;
			4'd4 : SSEG = 7'b0011001;
			4'd5 : SSEG = 7'b0010010;
			4'd6 : SSEG = 7'b0000010;
			4'd7 : SSEG = 7'b1111000;
			4'd8 : SSEG = 7'b0000000;
			4'd9 : SSEG = 7'b0010000;
			default : SSEG = 7'b1111111;
		endcase
	end
endmodule
			
module FLASH #(parameter TOTAL_PERIOD = 24_999_999, ON_TIME = 20_000_000)
    (input clk, input signal, output reg flash);

    localparam BW = $clog2(TOTAL_PERIOD);
    
    reg [BW-1:0] counter = 0;
    
    always @(posedge clk) begin
        if (signal) begin
            if (counter < TOTAL_PERIOD - 1)
                counter <= counter + 1;
            else
                counter <= 0;

            if (counter < ON_TIME)
                flash <= 1;
            else
                flash <= 0;
        end
		  else begin
            counter <= 0;
            flash <= 1;
        end
    end

endmodule

module SSEG_FLASH(input [3:0] digit, input flash, output reg [6:0] SSEG);
	always @(*) begin
		if (flash) begin
			case (digit)
				4'd0 : SSEG = 7'b1000000;
				4'd1 : SSEG = 7'b1111001;
				4'd2 : SSEG = 7'b0100100;
				4'd3 : SSEG = 7'b0110000;
				4'd4 : SSEG = 7'b0011001;
				4'd5 : SSEG = 7'b0010010;
				4'd6 : SSEG = 7'b0000010;
				4'd7 : SSEG = 7'b1111000;
				4'd8 : SSEG = 7'b0000000;
				4'd9 : SSEG = 7'b0010000;
				default : SSEG = 7'b1111111;
			endcase
		end
		else begin
			SSEG = 7'b1111111;
		end
	end
endmodule
	
module FLASH_CONTROL (input clk, input [5:0] hours, input [5:0] mins, input [5:0] secs, input [1:0] signal, input [2:0] on_control, 
	output [6:0] HEX0, output [6:0] HEX1, output [6:0] HEX2, output [6:0] HEX3, output [6:0] HEX4, output [6:0] HEX5);

	localparam TOTAL_PERIOD = 24_999_999;
	localparam ON_TIME = 20_000_000;

	wire [1:0] flash_mode;
	wire [5:0] flash_out;
	wire flash_sec, flash_min, flash_hour;

	wire [3:0] tens_0, ones_0;
	wire [3:0] tens_1, ones_1;
	wire [3:0] tens_2, ones_2;

	FLASH #(TOTAL_PERIOD, ON_TIME) flash_sec_inst (.clk(clk), .signal(signal == 2'b01), .flash(flash_sec));
	FLASH #(TOTAL_PERIOD, ON_TIME) flash_min_inst (.clk(clk), .signal(signal == 2'b10), .flash(flash_min));
	FLASH #(TOTAL_PERIOD, ON_TIME) flash_hour_inst (.clk(clk), .signal(signal == 2'b11), .flash(flash_hour));

	BINTODEC bin_to_dec_0(.bin(secs),.tens(tens_0),.ones(ones_0));
	BINTODEC bin_to_dec_1(.bin(mins),.tens(tens_1),.ones(ones_1));
	BINTODEC bin_to_dec_2(.bin(hours),.tens(tens_2),.ones(ones_2));

	SSEG_FLASH sseg_flash_0(.digit(ones_0),.flash(flash_sec && on_control == 3'b001),.SSEG(HEX0));
	SSEG_FLASH sseg_flash_1(.digit(tens_0),.flash(flash_sec && on_control == 3'b001),.SSEG(HEX1));

	SSEG_FLASH sseg_flash_2(.digit(ones_1),.flash(flash_min && on_control == 3'b001),.SSEG(HEX2));
	SSEG_FLASH sseg_flash_3(.digit(tens_1),.flash(flash_min && on_control == 3'b001),.SSEG(HEX3));

	SSEG_FLASH sseg_flash_4(.digit(ones_2),.flash(flash_hour && on_control == 3'b001),.SSEG(HEX4));
	SSEG_FLASH sseg_flash_5(.digit(tens_2),.flash(flash_hour && on_control == 3'b001),.SSEG(HEX5));

endmodule

module FLASH_CONTROL_STOPWATCH (input [6:0] hundredths, input [5:0] secs, mins, input [2:0] on_control,
	output [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);

	wire [3:0] tens_0, ones_0;
	wire [3:0] tens_1, ones_1;
	wire [3:0] tens_2, ones_2;

	BINTODEC_STOP #(7)
		bin_to_dec_0(.bin(hundredths), .tens(tens_0), .ones(ones_0));
	BINTODEC_STOP #(6)
		bin_to_dec_1(.bin(secs), .tens(tens_1), .ones(ones_1));
	BINTODEC_STOP #(6)
		bin_to_dec_2(.bin(mins), .tens(tens_2), .ones(ones_2));

	SSEG_FLASH sseg_flash_0(.digit(ones_0), .flash(on_control == 3'b010), .SSEG(HEX0));
	SSEG_FLASH sseg_flash_1(.digit(tens_0), .flash(on_control == 3'b010), .SSEG(HEX1));

	SSEG_FLASH sseg_flash_2(.digit(ones_1), .flash(on_control == 3'b010), .SSEG(HEX2));
	SSEG_FLASH sseg_flash_3(.digit(tens_1), .flash(on_control == 3'b010), .SSEG(HEX3));

	SSEG_FLASH sseg_flash_4(.digit(ones_2), .flash(on_control == 3'b010), .SSEG(HEX4));
	SSEG_FLASH sseg_flash_5(.digit(tens_2), .flash(on_control == 3'b010), .SSEG(HEX5));

endmodule

module FLASH_CONTROL_COUNTDOWN (input [5:0] secs, mins, hours, input [2:0] on_control,
	output [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);

	wire [3:0] tens_0, ones_0;
	wire [3:0] tens_1, ones_1;
	wire [3:0] tens_2, ones_2;

	BINTODEC bin_to_dec_0(.bin(secs), .tens(tens_0), .ones(ones_0));
	BINTODEC bin_to_dec_1(.bin(mins), .tens(tens_1), .ones(ones_1));
	BINTODEC bin_to_dec_2(.bin(hours), .tens(tens_2), .ones(ones_2));

	SSEG_FLASH sseg_flash_0(.digit(ones_0), .flash(on_control == 3'b100), .SSEG(HEX0));
	SSEG_FLASH sseg_flash_1(.digit(tens_0), .flash(on_control == 3'b100), .SSEG(HEX1));

	SSEG_FLASH sseg_flash_2(.digit(ones_1), .flash(on_control == 3'b100), .SSEG(HEX2));
	SSEG_FLASH sseg_flash_3(.digit(tens_1), .flash(on_control == 3'b100), .SSEG(HEX3));

	SSEG_FLASH sseg_flash_4(.digit(ones_2), .flash(on_control == 3'b100), .SSEG(HEX4));
	SSEG_FLASH sseg_flash_5(.digit(tens_2), .flash(on_control == 3'b100), .SSEG(HEX5));

endmodule

module BINTODEC (input [5:0] bin, output reg [3:0] tens, output reg [3:0] ones);

    always @(*) begin
        tens = bin / 10;
        ones = bin % 10;
    end
	 
endmodule
			
module BINTODEC_STOP #(parameter WIDTH = 7) 
	(input [WIDTH-1:0] bin, output reg [3:0] tens, output reg [3:0] ones);

    always @(*) begin
        tens = bin / 10;
        ones = bin % 10;
    end
	 
endmodule

module SSEG_DECODER(input [3:0] digit, output reg [6:0] SSEG);

    always @(*) begin
        case (digit)
            4'd0 : SSEG = 7'b1000000;
            4'd1 : SSEG = 7'b1111001;
            4'd2 : SSEG = 7'b0100100;
            4'd3 : SSEG = 7'b0110000;
            4'd4 : SSEG = 7'b0011001;
            4'd5 : SSEG = 7'b0010010;
            4'd6 : SSEG = 7'b0000010;
            4'd7 : SSEG = 7'b1111000;
            4'd8 : SSEG = 7'b0000000;
            4'd9 : SSEG = 7'b0010000;
            default: SSEG = 7'b1111111;
        endcase
    end
	 
endmodule		
			
module LED_CONTROL_FSM(input clk,input reset,input [5:0] hours,input [5:0] mins,input [5:0] secs,output reg LEDR);

	localparam INIT = 2'b00, OFF = 2'b01, ON = 2'b10, LOCK = 2'b11;
	reg [1:0] state, next_state;

	always @(posedge clk) begin
		state <= next_state;
	end
	 
	initial state = INIT;

	always @(*) begin
		case(state)
			INIT: begin
				if (hours != 0 || mins != 0 || secs != 0)
					next_state = OFF;
				else
					next_state = INIT;
				end
			OFF: begin
				if (hours == 0 && mins == 0 && secs == 0)
					next_state = ON;
				else
					next_state = OFF;
			end
			ON: begin
				if (reset)
					next_state = LOCK;
				else if (hours != 0 || mins != 0 || secs != 0)
					next_state = OFF;
				else
					next_state = ON;
            end
			LOCK: begin
				if (hours != 0 || mins != 0 || secs != 0)
					next_state = OFF;
				else
					next_state = LOCK;
			end
            default: next_state = OFF;
        endcase
    end

	always @(*) begin
		case(state)
			ON: LEDR = 1;
			default: LEDR = 0;
		endcase
	end
endmodule
			
			
			
			
			
			
			
			
			