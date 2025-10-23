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

