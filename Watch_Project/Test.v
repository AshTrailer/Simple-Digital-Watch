module Gate_Test;
	wire C1,C2,C3,C4,C5,C6;
	reg A, B;
	
	initial begin
        {A, B} = 0;
        repeat (4) begin
            #1 {A, B} = {A, B} + 1;
        end
    end
	
	initial begin
        $display("Time\tA B | AND OR NAND XOR NOR NOT");
        $monitor("%g\t%b %b |  %b   %b   %b    %b   %b   %b",
                 $time, A, B, C1, C2, C3, C4, C5, C6);
    end
	
	AND_gate and1(.A(A),.B(B),.C(C1));
	OR_gate or1(.A(A),.B(B),.C(C2));
	NAND_gate nand1(.A(A),.B(B),.C(C3));
	XOR_gate xor1(.A(A),.B(B),.C(C4));
	NOR_gate nor1(.A(A),.B(B),.C(C5));
	NOT_gate not1(.A(A),.B(C6));
	
endmodule

module COUNTER_DIRECTION_Test;
    reg clk = 0;
    always #1 clk = ~clk;
    reg enable = 0;
    reg reset = 0;
    reg direction = 1;

    wire [3:0] cnt;

    COUNTER_DIRECTION #(.MAX(9), .WIDTH(4)) 
		uut(.clk(clk),.enable(enable),.reset(reset),.direction(direction),.cnt(cnt));

    initial begin
        $display("Time\tclk\ten\tdir\treset\tcnt");
        $monitor("%4t\t%b\t%b\t%b\t%b\t%d", $time, clk, enable, direction, reset, cnt);
        reset = 1; enable = 0; direction = 1;
        #2;
        reset = 0;
        enable = 1;
        #20;
        direction = 0;
        #20;
        reset = 1;
        #2;
        reset = 0;
        direction = 1;
        #20;
        $finish;
    end
endmodule

`timescale 1ms/1ns
module Task5_Time_Test;
	reg clk = 0;
	initial forever #10 clk = !clk;

	wire [5:0] secs;
	Task6_Time t(.clk(clk),.secs(secs));
	initial begin
		#0 $display(secs);
		repeat (120)
			 #1000 $display(secs); // Test for 50Hz
		$stop;
	end
endmodule

`timescale 1ms/1ns
module Task6_Time_Test;
	reg clk = 0;
	initial forever #10 clk = !clk;
	wire [5:0] mins;
	wire [5:0] secs;
	Task6_Time t(.clk(clk),.mins(mins),.secs(secs));
	initial begin
		#0 $display(mins,,secs);
		repeat (120)
			 #1000 $display(mins,,secs); // Test for 50Hz
		$stop;
	end
endmodule

module Task7_Time_Test;
	reg clk = 0;
	initial forever #10 clk = !clk;
	wire [5:0] mins;
	wire [5:0] secs;
	wire [5:0] hours;
	Task7_Time t(.clk(clk),.hours(hours),.mins(mins),.secs(secs));
	initial begin
		#0 $display(hours,,mins,,secs);
		repeat (3600)
			 #1000 $display(hours,,mins,,secs); // Test for 50Hz
		$stop;
	end
endmodule

module Task15_Test;

	reg clk = 0;
	
	initial forever #1 clk = !clk;
	reg in;
	reg out;
	
	IFAdvance ifa(.clk(clk), .in(in), .out(out));
	initial $monitor(clk, in, out);
	
	initial begin
		// One-clock-cycle presses
		in = 0;
		repeat (4) #2 in = !in;
		
		// Two-clock-cycle presses
		repeat (4) #4 in = !in;
		
		// Three-clock-cycle presses
		repeat (4) #6 in = !in;
	
		// A 2 + 4 x 5 clock-cycle press
		in = 1; #44 in = 0;
		
		// A 3 + 4 x 5 clock-cycle press
		in = 1; #46 in = 0;
		
		#1 $stop;
		
	end
endmodule
		
module IFADVANCE_TOGGLE_ON_HOLD_TEST(input CLOCK_50, input [3:0] KEY, output [9:0] LEDR);

	wire x;
	assign LEDR[0] = x;
	localparam TIME = 50_000_000;
	
	IFADVANCE_TOGGLE_ON_HOLD #(TIME)
		testx(.clk(CLOCK_50),.in(!KEY[2]),.out(x));

endmodule	
		
module FLASH_TEST(input CLOCK_50, output [9:0] LEDR);

	wire x;
	assign LEDR[0] = x;
	localparam TOTAL_PERIOD = 24_999_999;
	localparam ON_TIME = 20_000_000;
	
	FLASH #(TOTAL_PERIOD,ON_TIME)
		testx(.clk(CLOCK_50),.flash(x));

endmodule

module FASTADVANCED_TEST(input CLOCK_50, input [3:0] KEY, output [9:0] LEDR);

    
    localparam TIME = 20_000;
    localparam LONG = 50_000_000;
    localparam PERIOD = 5;

    wire key2_debounced;
    wire pulse_out;
    wire hold;

    DEBOUNCE #(TIME)
		debounce_up(.clk(CLOCK_50),.noisy_in(!KEY[2]),.clean_out(key2_debounced));

    FASTADVANCE_1 #(LONG, PERIOD)
		fast_advance_inst(.clk(CLOCK_50),.in(key2_debounced),.out(pulse_out),.hold(hold));
    

    assign LEDR[0] = pulse_out;  // Pulse signal (short press and periodic pulse)
    assign LEDR[1] = hold;       // Hold signal (long press active)
  
    assign LEDR[2] = key2_debounced;  // Debounced button signal
    assign LEDR[3] = !KEY[2];         // Raw button signal
    
endmodule

module MODE_TEST(input CLOCK_50,input [3:0] KEY,output [9:0] LEDR);

    localparam LONG = 50_000_000;
    localparam PRESS_COUNT_MAX = 3;
    localparam DEBOUNCE_TIME = 20_000;

    wire clean_key;
    wire [1:0] flash_mode;

    DEBOUNCE #(DEBOUNCE_TIME)
		debounce_inst(.clk(CLOCK_50),.noisy_in(!KEY[0]),.clean_out(clean_key));

    MODE #(LONG, PRESS_COUNT_MAX)
		mode_inst(.clk(CLOCK_50),.in(clean_key),.flash_mode(flash_mode));

    assign LEDR[1:0] = flash_mode;

endmodule
		
module BUTTON_CONTROL_TEST #(parameter LONG_MODE = 50_000_000, PRESS_COUNT_MAX = 3, LONG_ADV = 50_000_000, PERIOD_ADV = 5_0)
    (input CLOCK_50, input [3:0] KEY, output [9:0] LEDR);

    wire clean_key0, clean_key1, clean_key2;
    wire [1:0] flash_mode;
    wire out_adv1, hold_adv1, out_adv2, hold_adv2;
    
    // Debounce for mode button (KEY[0])
    DEBOUNCE #(20_000)  
        debounce_mode(.clk(CLOCK_50), .noisy_in(!KEY[0]), .clean_out(clean_key0));
    
    // Debounce for fast advance button 1 (KEY[1])
    DEBOUNCE #(20_000)  
        debounce_adv1(.clk(CLOCK_50), .noisy_in(!KEY[1]), .clean_out(clean_key1));
    
    // Debounce for fast advance button 2 (KEY[2])
    DEBOUNCE #(20_000)  
        debounce_adv2(.clk(CLOCK_50), .noisy_in(!KEY[2]), .clean_out(clean_key2));

    // Button Control Module
    BUTTON_CONTROL #(LONG_MODE, PRESS_COUNT_MAX, LONG_ADV, PERIOD_ADV)
        button_ctrl(.clk(CLOCK_50), .in_mode(clean_key0), .in_adv1(clean_key1), .in_adv2(clean_key2),
                    .flash_mode(flash_mode), .out_adv1(out_adv1), .hold_adv1(hold_adv1), .out_adv2(out_adv2), .hold_adv2(hold_adv2));

    // LED Outputs
    assign LEDR[1:0] = flash_mode;   // Flash mode (2 LEDs)
    assign LEDR[2] = out_adv1;       // Fast Advance 1 Out
    assign LEDR[3] = hold_adv1;      // Fast Advance 1 Hold
    assign LEDR[4] = out_adv2;       // Fast Advance 2 Out
    assign LEDR[5] = hold_adv2;      // Fast Advance 2 Hold

endmodule
		
module Flash_Control_Test_1 (input CLOCK_50, input [3:0] KEY, input signal, output [9:0] LEDR);
	 
	localparam LONG = 50_000_000;
	localparam PRESS_COUNT_MAX = 3;
	localparam DEBOUNCE_TIME = 20_000;
	localparam TOTAL_PERIOD = 24_999_999;
	localparam ON_TIME = 20_000_000;
	 
	wire clean_key;
	wire [1:0] flash_mode;
	wire flash_signal;
	wire [3:0] flash_out;

	DEBOUNCE #(DEBOUNCE_TIME)
		debounce_inst(.clk(CLOCK_50),.noisy_in(!KEY[0]),.clean_out(clean_key));

	MODE #(LONG, PRESS_COUNT_MAX)
		mode_inst(.clk(CLOCK_50),.in(clean_key),.flash_mode(flash_mode));
    
	FLASH #(TOTAL_PERIOD, ON_TIME)
		flash_inst (.clk(CLOCK_50), .signal(1'b1), .flash(flash_signal));

	DEMUX4 demux_inst (.in(flash_signal),.sel(flash_mode),.out(flash_out));
	
	assign LEDR[1:0] = flash_mode;
	assign LEDR[9] = clean_key;
	
	assign LEDR[5:2] = flash_out;
	

endmodule
		
module Flash_Control_Test_2 (input CLOCK_50, input [3:0] KEY, input [9:0] SW,
	output [6:0] HEX0, output [6:0] HEX1, output [6:0] HEX2, output [6:0] HEX3,
	output [6:0] HEX4, output [6:0] HEX5, 
	output [9:0] LEDR);

	localparam LONG = 50_000_000;
	localparam PRESS_COUNT_MAX = 3;
	localparam DEBOUNCE_TIME = 20_000;
	localparam TOTAL_PERIOD = 24_999_999;
	localparam ON_TIME = 20_000_000;

	wire clean_key;
	wire [1:0] flash_mode;
	wire flash_signal;
	wire [2:0] flash_out;

	wire [3:0] tens_0, ones_0;
	wire [3:0] tens_1, ones_1;
	wire [3:0] tens_2, ones_2;

	DEBOUNCE #(DEBOUNCE_TIME)
		debounce_inst(.clk(CLOCK_50),.noisy_in(!KEY[2]),.clean_out(clean_key));
    
	MODE #(LONG, PRESS_COUNT_MAX)
		mode_inst(.clk(CLOCK_50),.in(clean_key),.flash_mode(flash_mode));

	FLASH #(TOTAL_PERIOD, ON_TIME)
		flash_inst (.clk(CLOCK_50),.signal(1'b1),.flash(flash_signal));

	DEMUX4 demux_inst (.in(flash_signal),.sel(flash_mode),.out(flash_out));

	BinToDec bin_to_dec_0(.bin(SW[6:0]),.tens(tens_0),.ones(ones_0));
	BinToDec bin_to_dec_1(.bin(SW[6:0]),.tens(tens_1),.ones(ones_1));
	BinToDec bin_to_dec_2(.bin(SW[6:0]),.tens(tens_2),.ones(ones_2));

	SSEG_FLASH sseg_flash_0(.digit(ones_0),.flash(flash_out[0]),.SSEG(HEX0));
	SSEG_FLASH sseg_flash_1(.digit(tens_0),.flash(flash_out[0]),.SSEG(HEX1));

	SSEG_FLASH sseg_flash_2(.digit(ones_1),.flash(flash_out[1]),.SSEG(HEX2));
	SSEG_FLASH sseg_flash_3(.digit(tens_1),.flash(flash_out[1]),.SSEG(HEX3));

	SSEG_FLASH sseg_flash_4(.digit(ones_2),.flash(flash_out[2]),.SSEG(HEX4));
	SSEG_FLASH sseg_flash_5(.digit(tens_2),.flash(flash_out[2]),.SSEG(HEX5));
	 
	assign LEDR[0] = flash_signal;
	assign LEDR[1] = flash_out[0];
	assign LEDR[2] = flash_out[1];
	assign LEDR[3] = flash_out[2];
	assign LEDR[4] = flash_mode[0];
	assign LEDR[5] = flash_mode[1];
			
endmodule
		
module Test2(input CLOCK_50, input [3:0] KEY, input [9:0] SW, output [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);

    localparam PRESS_TIME = 50_000_000;
    localparam PERIOD_PULSE = 5_000_000;

    wire key2, key1, key0;
    wire pulse_up, hold_up;
    wire pulse_down, hold_down;
    wire [5:0] secs_mode;
    wire [3:0] secs_d1, secs_d2;
    wire [1:0] flash_mode = 2'b01;
    wire [3:0] debug_counter;
    wire [3:0] debug_mode;

    assign secs_d1 = secs_mode / 10;
    assign secs_d2 = secs_mode % 10;

    DEBOUNCE #(20_000)
        debounce_key2(.clk(CLOCK_50), .noisy_in(!KEY[2]), .clean_out(key2));
    DEBOUNCE #(20_000)
        debounce_key1(.clk(CLOCK_50), .noisy_in(!KEY[1]), .clean_out(key1));
    DEBOUNCE #(20_000)
        debounce_key0(.clk(CLOCK_50), .noisy_in(!KEY[0]), .clean_out(key0));

    FASTADVANCE #(.LONG(PRESS_TIME), .PERIOD(PERIOD_PULSE))
        fast_advance_inst(.clk(CLOCK_50), .in(key1), .out(pulse_up), .hold(hold_up));
    FASTADVANCE #(.LONG(PRESS_TIME), .PERIOD(PERIOD_PULSE))
        fast_advance_inst2(.clk(CLOCK_50), .in(key0), .out(pulse_down), .hold(hold_down));

    COUNTER_UP_DOWN_SPEED_TEST2 #(.MAX(59), .WIDTH(6))
        secs_counter(.clk(CLOCK_50), .enable(flash_mode == 2'b01), .pulse_up(pulse_up), .pulse_down(pulse_down),
            .hold_up(hold_up), .hold_down(hold_down), .cnt(secs_mode));

    SSEG ss1(.digit(secs_d1), .SSEG(HEX1));
    SSEG ss0(.digit(secs_d2), .SSEG(HEX0));

endmodule		
		
module MODE_SWITCH_TEST(input CLOCK_50, input [3:0] KEY, output [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, output [9:0] LEDR);

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
	
	Project2_Task6_StopWatch
		stopwatch(.CLOCK_50(CLOCK_50),.KEY2(key2_2),.KEY0(key0_2),.on_control(mux_mode),
		.HEX5(HEX5_in2),.HEX4(HEX4_in2),.HEX3(HEX3_in2),.HEX2(HEX2_in2),
		.HEX1(HEX1_in2),.HEX0(HEX0_in2));
		
	MODE_SWITCH #(.PRESS_COUNT_MAX(3))
		mode_switch(.clk(CLOCK_50),.in(key3),.mux_mode(mux_mode));
	
	assign LEDR[9:7] = mux_mode;

endmodule	
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
