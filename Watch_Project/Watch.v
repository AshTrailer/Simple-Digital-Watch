module WATCH(input CLOCK_50, input [3:0] KEY, output [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, output [9:0] LEDR);

	localparam PRESS_TIME = 50_000_000;
	localparam BUTTOM_PRESS_COUNT_MAX = 3;
	localparam TIME = 20_000;
	localparam PERIOD_PULSE = 5_000_000;

	wire [6:0] HEX0_in1, HEX1_in1, HEX2_in1, HEX3_in1, HEX4_in1, HEX5_in1;
	wire [6:0] HEX0_in2, HEX1_in2, HEX2_in2, HEX3_in2, HEX4_in2, HEX5_in2;
	wire [6:0] HEX0_in3, HEX1_in3, HEX2_in3, HEX3_in3, HEX4_in3, HEX5_in3;
	wire [5:0] hours, hours_mode;
	wire key0_1, key0_2, key0_3;
	wire key1_1, key1_2, key1_3;
	wire key2_1, key2_2, key2_3;
	wire [5:0] secs, secs_mode;
	wire [5:0] mins, mins_mode;
	wire [2:0] mux_mode;
	wire [1:0] signal;
	wire key3, key0, key1, key2;

	HEX_3MUX_MODE mode(.mux_mode(mux_mode),.KEY1(key1),.KEY2(key2),.KEY0(key0),
		.key1_1(key1_1),.key1_2(key1_2),.key1_3(key1_3),
		.key2_1(key2_1),.key2_2(key2_2),.key2_3(key2_3),
		.key0_1(key0_1),.key0_2(key0_2),.key0_3(key0_3),
		.HEX0_in1(HEX0_in1),.HEX1_in1(HEX1_in1),.HEX2_in1(HEX2_in1),.HEX3_in1(HEX3_in1),.HEX4_in1(HEX4_in1),.HEX5_in1(HEX5_in1),
		.HEX0_in2(HEX0_in2),.HEX1_in2(HEX1_in2),.HEX2_in2(HEX2_in2),.HEX3_in2(HEX3_in2),.HEX4_in2(HEX4_in2),.HEX5_in2(HEX5_in2),
		.HEX0_in3(HEX0_in3),.HEX1_in3(HEX1_in3),.HEX2_in3(HEX2_in3),.HEX3_in3(HEX3_in3),.HEX4_in3(HEX4_in3),.HEX5_in3(HEX5_in3),
		.HEX0(HEX0),.HEX1(HEX1),.HEX2(HEX2),.HEX3(HEX3),.HEX4(HEX4),.HEX5(HEX5));
	
	DEBOUNCE #(TIME)
        debounce_key3(.clk(CLOCK_50),.noisy_in(!KEY[3]),.clean_out(key3));
	DEBOUNCE #(TIME)
        debounce_key0(.clk(CLOCK_50),.noisy_in(!KEY[0]),.clean_out(key0));
	DEBOUNCE #(TIME)
        debounce_key1(.clk(CLOCK_50),.noisy_in(!KEY[1]),.clean_out(key1));
	DEBOUNCE #(TIME)
        debounce_key2(.clk(CLOCK_50),.noisy_in(!KEY[2]),.clean_out(key2));
	 
	TIME t(.clk(CLOCK_50),.mode(signal),.hours_mode(hours_mode),.mins_mode(mins_mode),
		.secs_mode(secs_mode),.hours(hours),.mins(mins),.secs(secs));

	FLASH_CONTROL flash_control(.clk(CLOCK_50),.hours(hours),.mins(mins),.secs(secs),.signal(signal),
		.on_control(mux_mode),.HEX0(HEX0_in1),.HEX1(HEX1_in1),.HEX2(HEX2_in1),
		.HEX3(HEX3_in1),.HEX4(HEX4_in1),.HEX5(HEX5_in1));
    
	BUTTON_CONTROL #(.LONG_MODE(PRESS_TIME),.PRESS_COUNT_MAX(BUTTOM_PRESS_COUNT_MAX),.LONG_ADV(PRESS_TIME),
		.PERIOD_ADV(PERIOD_PULSE),.TIME(TIME))
		button_control(.clk(CLOCK_50),.flash_mode(signal),.secs(secs),.mins(mins),
		.hours(hours),.KEY1(key1_1),.KEY2(key2_1),.KEY0(key0_1),.secs_mode(secs_mode),
		.mins_mode(mins_mode),.hours_mode(hours_mode));
		
	STOPWATCH
		stopwatch(.CLOCK_50(CLOCK_50),.KEY2(key2_2),.KEY0(!key0_2),.on_control(mux_mode),
		.HEX5(HEX5_in2),.HEX4(HEX4_in2),.HEX3(HEX3_in2),.HEX2(HEX2_in2),
		.HEX1(HEX1_in2),.HEX0(HEX0_in2));
	 
	COUNTDOWN
		countdown(.CLOCK_50(CLOCK_50),.KEY1(key1_3),.KEY2(key2_3),.KEY0(!key0_3),.on_control(mux_mode),
		.HEX5(HEX5_in3),.HEX4(HEX4_in3),.HEX3(HEX3_in3),.HEX2(HEX2_in3),
		.HEX1(HEX1_in3),.HEX0(HEX0_in3),.LEDR(LEDR[0]));
	
	MODE_SWITCH #(.PRESS_COUNT_MAX(3))
		mode_switch(.clk(CLOCK_50),.in(key3),.mux_mode(mux_mode));
	
	assign LEDR[9:7] = mux_mode;
	
endmodule

module TIME(input clk, input [1:0] mode,input [5:0] hours_mode, mins_mode, secs_mode,
	output reg [5:0] hours = 0, mins = 0, secs = 0);
	
	localparam N = 50_000_000;
	localparam BW = $clog2(N);
	wire [BW-1:0] tick;
	wire [5:0] secs_temp, mins_temp, hours_temp;
	
	COUNTER #(.MAX(N-1), .WIDTH(BW))
		divider(.clk(clk),.enable(mode == 2'b00),.cnt(tick));
		
	COUNTER_INPUT #(.MAX(59), .WIDTH(6))
		cs(.clk(clk),.in(secs_mode),.mode(mode),.enable(tick==0),.cnt(secs_temp));
		
	COUNTER_INPUT #(.MAX(59),.WIDTH(6))
		cm(.clk(clk),.in(mins_mode),.mode(mode),.enable(tick == 0 && secs_temp == 59),.cnt(mins_temp));

	COUNTER_INPUT #(.MAX(23),.WIDTH(6))
		ch(.clk(clk),.in(hours_mode),.mode(mode),.enable(tick == 0 && mins_temp == 59 && secs_temp == 59),.cnt(hours_temp));

	always @(posedge clk) begin
        hours <= hours_temp;
        mins <= mins_temp;
        secs <= secs_temp;
	end
	 
endmodule
	
module STOPWATCH
	(input CLOCK_50, input KEY2, KEY0, input [2:0] on_control, output [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);
	
	localparam N = 500_000;
	localparam BW = $clog2(N);
	wire [BW-1:0] tick;
	wire [6:0] hundredths;
	wire [5:0] secs, mins;
	wire stop;
	
	COUNTER_STOPWATCH_TICK #(.MAX(N-1),.WIDTH(BW))
		divider(.clk(CLOCK_50),.enable(!stop),.clear(KEY2),.cnt(tick));
		
	COUNTER_STOPWATCH #(.MAX(99), .WIDTH(7))
		chund(.clk(CLOCK_50),.enable(tick == N-1),.clear(KEY2),.cnt(hundredths));
		
	COUNTER_STOPWATCH #(.MAX(59), .WIDTH(6))
		cs(.clk(CLOCK_50),.enable(tick == N-1 && hundredths == 99),.clear(KEY2),.cnt(secs));
	
	COUNTER_STOPWATCH #(.MAX(59), .WIDTH(6))
		cm(.clk(CLOCK_50),.enable(tick == N-1 && secs == 59 && hundredths == 99),.clear(KEY2),.cnt(mins));
		
	BUTTOM_TOGGLED bt_stop(.clk(CLOCK_50),.key(KEY0),.toggled(stop));
		
	FLASH_CONTROL_STOPWATCH display_stopwatch(.hundredths(hundredths),.secs(secs),.mins(mins),.on_control(on_control),
		.HEX0(HEX0),.HEX1(HEX1),.HEX2(HEX2),.HEX3(HEX3),.HEX4(HEX4),.HEX5(HEX5));

endmodule

module COUNTDOWN
	(input CLOCK_50, input KEY1, KEY0, KEY2, input [2:0] on_control, output [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, output [9:0] LEDR);
    
	localparam N = 50_000_000;
	localparam LONG_ADV = 50_000_000;
	localparam PERIOD_ADV = 5_000_000;
	localparam TIME = 20_000;
	localparam BW = $clog2(N);
   
	wire key0;
	wire [BW-1:0] tick;
	wire up_min, up_hours;
	wire pulse_up, hold_up, hours_up;
	wire [5:0] secs, mins, hours;
	COUNTER_COUNTERDOWN_TICK #(.MAX(N-1),.WIDTH(BW))
		divider(.clk(CLOCK_50),.enable(!key0 && ((hours != 0 || mins != 0 || secs != 0))),.clear(KEY2),.cnt(tick));
		
	COUNTER_DOWN #(.MAX(59),.WIDTH(6))
		secs_counter(.clk(CLOCK_50),.enable(tick == N-1 && (hours != 0 || mins != 0 || secs != 0)),
		.clear(KEY2),.pulse_up(pulse_up),.up(up_min),.cnt(secs));
	
	COUNTER_DOWN #(.MAX(59),.WIDTH(6))
		mins_counter(.clk(CLOCK_50),.enable(tick == N-1 && secs == 0),.clear(KEY2),
		.pulse_up(up_min),.up(up_hours),.cnt(mins));
	
	COUNTER_DOWN #(.MAX(99),.WIDTH(6))
		hours_counter(.clk(CLOCK_50),.enable(tick == N-1 && secs == 0 && mins ==0),
		.clear(KEY2),.pulse_up(up_hours),.up(hours_up),.cnt(hours));

	BUTTOM_TOGGLED bt_stop(.clk(CLOCK_50),.key(KEY0),.toggled(key0));
        
	FASTADVANCE #(LONG_ADV, PERIOD_ADV)
		fast_countdown(.clk(CLOCK_50),.in(KEY1),.out(pulse_up),.hold(hold_up));
		  
	LED_CONTROL_FSM beeper(.clk(CLOCK_50),.reset(KEY2),.hours(hours),.mins(mins),.secs(secs),.LEDR(LEDR[0]));
    
	FLASH_CONTROL_COUNTDOWN display_countdown(.secs(secs),.mins(mins),.hours(hours),.on_control(on_control),
		.HEX0(HEX0),.HEX1(HEX1),.HEX2(HEX2),.HEX3(HEX3),.HEX4(HEX4),.HEX5(HEX5));
endmodule

module MODE_SWITCH #(parameter PRESS_COUNT_MAX = 3)
    (input clk, input in, output reg [2:0] mux_mode);

    reg in_d = 0;
    reg [1:0] press_count = 0;

    always @(posedge clk) begin
        if (!in_d && in) begin
            if (press_count == PRESS_COUNT_MAX - 1)
                press_count <= 0;
            else
                press_count <= press_count + 1;
        end
        in_d <= in;
        
        case (press_count)
            0: mux_mode <= 3'b001;
            1: mux_mode <= 3'b010;
            2: mux_mode <= 3'b100;
            default: mux_mode <= 3'b001;
        endcase
    end
endmodule

module DEBOUNCE #(parameter TIME = 20_000)
	(input clk, input noisy_in, output reg clean_out);
	
    reg [$clog2(TIME)-1:0] count = 0;
    reg stable = 0;

    always @(posedge clk) begin
        if (noisy_in == stable)
            count <= 0;
        else if (count == TIME-1) begin
            stable <= noisy_in;
            count <= 0;
        end else
            count <= count + 1;
    end

    always @(posedge clk)
        clean_out <= stable;
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

module BUTTON_CONTROL #(parameter LONG_MODE = 50_000_000, PRESS_COUNT_MAX = 3, LONG_ADV = 50_000_000, PERIOD_ADV = 5_000_000, TIME = 20_000)
	(input clk, input [5:0] secs, input [5:0] mins, input [5:0] hours, input KEY1, KEY2, KEY0, output [5:0] secs_mode, output [5:0] mins_mode,
	output [5:0] hours_mode, output [1:0] flash_mode);
	
	wire pulse_down, hold_down;
	wire pulse_up, hold_up;	

	MODE #(LONG_MODE, PRESS_COUNT_MAX)
		mode(.clk(clk),.in(KEY2),.flash_mode(flash_mode));

	FASTADVANCE #(LONG_ADV, PERIOD_ADV)
		fast1(.clk(clk),.in(KEY1),.out(pulse_up),.hold(hold_up));
    
	FASTADVANCE #(LONG_ADV, PERIOD_ADV)
		fast2(.clk(clk),.in(KEY0),.out(pulse_down),.hold(hold_down));

	COUNTER_UP_DOWN_SPEED #(.MAX(59), .WIDTH(6))
		secs_counter(.clk(clk),.enable(flash_mode == 2'b01),.mode(flash_mode),.in(secs),.pulse_up(pulse_up),.pulse_down(pulse_down),
			.cnt(secs_mode));

	COUNTER_UP_DOWN_SPEED #(.MAX(59), .WIDTH(6))
		mins_counter(.clk(clk),.enable(flash_mode == 2'b10),.mode(flash_mode),.in(mins),.pulse_up(pulse_up),.pulse_down(pulse_down),
			.cnt(mins_mode));
			
	COUNTER_UP_DOWN_SPEED #(.MAX(23), .WIDTH(6))
		hours_counter(.clk(clk),.enable(flash_mode == 2'b11),.mode(flash_mode),.in(hours),.pulse_up(pulse_up),.pulse_down(pulse_down),
			.cnt(hours_mode));

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

module BINTODEC (input [5:0] bin, output reg [3:0] tens, output reg [3:0] ones);

    always @(*) begin
        tens = bin / 10;
        ones = bin % 10;
    end
	 
endmodule

module COUNTER #(parameter MAX=1, WIDTH=1) 
	(input clk, enable, output reg [WIDTH-1:0] cnt);
	
	reg [WIDTH-1:0] next_cnt;
		
	always @(posedge clk) begin
		if (enable)
			cnt <= next_cnt;
	end
		
	always @(*)
		next_cnt = (cnt == MAX) ? 0 : cnt + 1'b1;
		
endmodule

module COUNTER_INPUT #(parameter MAX=1, WIDTH=1) 
    (input clk, input [WIDTH-1:0] in, input [1:0] mode, input enable, output reg [WIDTH-1:0] cnt);
    
    reg [WIDTH-1:0] next_cnt;
        
    always @(posedge clk) begin
        if (mode == 2'b00 && enable)
            cnt <= next_cnt;
        else if (mode != 2'b00)
            cnt <= in;
    end
        
    always @(*) begin
        if (mode == 2'b00)
            next_cnt = (cnt == MAX) ? 0 : cnt + 1'b1;
        else
            next_cnt = in;
    end
endmodule

module COUNTER_STOPWATCH_TICK #(parameter MAX=1, WIDTH=1) 
    (input clk, enable, clear, output reg [WIDTH-1:0] cnt);
    
    reg [WIDTH-1:0] next_cnt;
    
    always @(posedge clk) begin
        if (clear)
            cnt <= 1;
        else if (enable)
            cnt <= next_cnt;
    end
    
    always @(*) begin
        if (clear)
            next_cnt = 1;
        else if (cnt == MAX)
            next_cnt = 0;
        else
            next_cnt = cnt + 1'b1;
    end
    
endmodule

module COUNTER_STOPWATCH #(parameter MAX=1, WIDTH=1) 
    (input clk, enable, clear, output reg [WIDTH-1:0] cnt);
    
    reg [WIDTH-1:0] next_cnt;
    
    always @(posedge clk) begin
        if (clear)
            cnt <= 0;
        else if (enable)
            cnt <= next_cnt;
    end
    
    always @(*) begin
        if (clear)
            next_cnt = 0;
        else if (cnt == MAX)
            next_cnt = 0;
        else
            next_cnt = cnt + 1'b1;
    end
    
endmodule

module COUNTER_COUNTERDOWN_TICK #(parameter MAX=1, WIDTH=1) 
    (input clk, enable, clear, output reg [WIDTH-1:0] cnt);
    
    reg [WIDTH-1:0] next_cnt;
    
    always @(posedge clk) begin
        if (clear)
            cnt <= 1;
        else if (enable)
            cnt <= next_cnt;
    end
    
    always @(*) begin
        if (clear)
            next_cnt = 1;
        else if (cnt == MAX)
            next_cnt = 0;
        else
            next_cnt = cnt + 1'b1;
    end
    
endmodule

module COUNTER_DOWN #(parameter MAX=1, WIDTH=1) 
    (input clk, enable, clear, input pulse_up, output reg up, output reg [WIDTH-1:0] cnt);
    
    reg [WIDTH-1:0] next_cnt;
    
    always @(posedge clk) begin
        if (clear)
            cnt <= 0;
        else if (enable || pulse_up)
            cnt <= next_cnt;
    end
    
    always @(*) begin
        up = 0;
        
        if (clear) begin
            next_cnt = 0;
        end
        
        else if (pulse_up) begin
            if (cnt == MAX) begin
                next_cnt = 0;
                up = 1;
            end
            else begin
                next_cnt = cnt + 1'b1;
            end
        end
        
        else if (enable) begin
            if (cnt == 0)
                next_cnt = MAX;
            else
                next_cnt = cnt - 1'b1;
        end
        
        else begin
            next_cnt = cnt;
        end
    end

endmodule

module COUNTER_UP_DOWN_SPEED #(parameter MAX = 59, WIDTH = 6)
    (input clk, enable, input [1:0] mode, input [WIDTH-1:0] in, 
     input pulse_up, pulse_down, output reg [WIDTH-1:0] cnt);

    reg [1:0] prev_mode = 2'b00;

    always @(posedge clk) begin
        if (prev_mode == 2'b00 && mode != 2'b00) begin
            cnt <= in;
        end
        
        if (enable) begin
				if (pulse_up) begin
					if (cnt == MAX)
						cnt <= 0;
					else
						cnt <= cnt + 1;
					end
				else if (pulse_down) begin
					if (cnt == 0)
						cnt <= MAX;
					else
						cnt <= cnt - 1;
					end
				end
        
        prev_mode <= mode;
    end
endmodule

module RisingEdgeDetector(input clk, input in, output out);
	reg prev = 0;
	wire next_prev;
	
	always @(posedge clk)
		prev <= next_prev;
		
	assign next_prev = in;
	
	assign out  = (!prev && in);

endmodule

module Toggle(input clk, input in, output out);
	reg on = 0;
		
	always @(posedge clk)
		on  = in ? !on : on;
	
	assign out = on;

endmodule

// Buttom is 0 when push, is 1 when release, so take !KEY to detect rising edge
module BUTTOM_TOGGLED (input clk, input [0:0] key, output toggled);
	wire btn;
	RisingEdgeDetector red(.clk(clk),.in(!key[0]),.out(btn));
	Toggle toggle(.clk(clk),.in(btn),.out(toggled));

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
			

