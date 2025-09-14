module Project1_Task1;

	reg clk = 0;
	initial forever #1 clk = !clk;
	
	// Change the value of N
	localparam N = 10;
	localparam BW = $clog2(N+1);
	wire [BW-1:0] cnt;
	
	COUNTER #(.MAX(N),.WIDTH(BW))
		cntr(.clk(clk),.enable(1'b1),.reset(1'b0),.cnt(cnt));

	initial begin
		#0 $display(cnt);
	repeat (2*N + 1)
		#2 $display(cnt);
		$stop;
	end
endmodule

module Project1_Task3 #(parameter MAX=1, WIDTH=1) 
	(input clk, enable, reset, direction, output reg [WIDTH-1:0] cnt);
	
	initial cnt = 0;
	reg [WIDTH-1:0] next_cnt;
		
	always @(posedge clk) begin
		if (reset)
			cnt <= 0;
		else if (enable)
			cnt <= next_cnt;
		end
		
	always @(*)
		if (direction)
			next_cnt = (cnt == MAX) ? 1'b0 : cnt + 1'b1;
		else
			next_cnt = (cnt == 1'b0) ? MAX : cnt - 1'b1;
endmodule

module Project1_Task4_Watch(input CLOCK_50);

	wire [5:0] secs;
	
	Time t(.clk(CLOCK_50),.secs(secs));
	
endmodule

module Project1_Task4_Time(input clk, output [5:0] secs);

	localparam N = 50;
	localparam BW = $clog2(N);
	
	wire [BW-1:0] tick;
	
	COUNTER #(.MAX(N-1), .WIDTH(BW))
		divider(.clk(clk), .enable(1'b1), .cnt(tick));
	COUNTER #(.MAX(59), .WIDTH(6))
		cs(.clk(clk), .enable(tick==0), .cnt(secs));
endmodule	

module Project1_Task5_jdoodle;	
	reg [5:0] sec;
	reg [3:0] d1, d2;
	initial begin
		sec = 32;
					    // making sure each number works
		d1 = sec/10; // Formula for determining first digit of sec
		d2 = sec%10; // Formula for determining second digit of sec
		$display("The first digit of ", sec, " is ", d1);
		$display("The second digit of ", sec, " is ", d2);
	end
endmodule	

module Project1_Task5_Watch(input CLOCK_50, output [6:0] HEX1, HEX0);
	wire [5:0] secs;
	wire [3:0] secs_d1 = secs/10;
	wire [3:0] secs_d2 = secs%10;
	Task5_Time t(.clk(CLOCK_50),.secs(secs));
	SSEG ss0(.digit(secs_d1),.SSEG(HEX1));
	SSEG ss1(.digit(secs_d2),.SSEG(HEX0));
endmodule

module Project1_Task5_Time(input clk, output [5:0] secs);

	localparam N = 49_999_999;
	localparam BW = $clog2(N);
	
	wire [BW-1:0] tick;
	
	COUNTER #(.MAX(N-1), .WIDTH(BW))
		divider(.clk(clk), .enable(1'b1), .cnt(tick));
	COUNTER #(.MAX(59), .WIDTH(6))
		cs(.clk(clk), .enable(tick==0), .cnt(secs));
endmodule

module Project1_Task6_Time(input clk, output [5:0] mins, secs);

	localparam N = 49_999_999;
	localparam BW = $clog2(N);
	wire [BW-1:0] tick;
	
	COUNTER #(.MAX(N-1),.WIDTH(BW))
		divider(.clk(clk), .enable(1'b1), .cnt(tick));
		
	COUNTER #(.MAX(59), .WIDTH(6))
		cs(.clk(clk), .enable(tick==0), .cnt(secs));
		
	COUNTER #(.MAX(59), .WIDTH(6))
		cm(.clk(clk), .enable(tick == 0 && secs == 59), .cnt(mins));
		
endmodule


module Project1_Task7_Time(input clk, output [5:0] hours, mins, secs);

	localparam N = 49_999_999;
	localparam BW = $clog2(N);
	wire [BW-1:0] tick;
	
	COUNTER #(.MAX(N-1),.WIDTH(BW))
		divider(.clk(clk), .enable(1'b1), .cnt(tick));
		
	COUNTER #(.MAX(59), .WIDTH(6))
		cs(.clk(clk), .enable(tick==0), .cnt(secs));
		
	COUNTER #(.MAX(59), .WIDTH(6))
		cm(.clk(clk), .enable(tick == 0 && secs == 59), .cnt(mins));
	
	COUNTER #(.MAX(59), .WIDTH(6))
		ch(.clk(clk), .enable(tick == 0 && mins == 59 && secs == 59), .cnt(hours));
		
endmodule

module Project1_Task8_Watch(input CLOCK_50, output [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);
	wire [5:0] secs;
	wire [5:0] mins;
	wire [5:0] hours;
	
	wire [3:0] secs_d1 = secs/10;
	wire [3:0] secs_d2 = secs%10;
	
	wire [3:0] mins_d1 = mins/10;
	wire [3:0] mins_d2 = mins%10;
	
	wire [3:0] hours_d1 = hours/10;
	wire [3:0] hours_d2 = hours%10;
	
	Task7_Time t(.clk(CLOCK_50),.hours(hours),.mins(mins),.secs(secs));
	SSEG ss0(.digit(secs_d1),.SSEG(HEX1));
	SSEG ss1(.digit(secs_d2),.SSEG(HEX0));
	
	SSEG ss2(.digit(mins_d1),.SSEG(HEX3));
	SSEG ss3(.digit(mins_d2),.SSEG(HEX2));
	
	SSEG ss4(.digit(hours_d1),.SSEG(HEX5));
	SSEG ss5(.digit(hours_d2),.SSEG(HEX4));
	
endmodule

module Project1_Tash10_COUNTER_UP_DOWN #(parameter MAX = 1, WIDTH = 1, UP = 1) 
	(input clk, enable, reset, plus, minus, output reg [WIDTH-1:0] cnt);
		
	initial cnt = 0;
	reg [WIDTH-1:0] next_cnt = 0;
	
	always @(posedge clk or posedge reset) begin
		if (reset)
			cnt <= 0;
		else if (enable)
			cnt <= next_cnt;
   end
		
	always @(*) begin
		if (plus == 1  && minus == 0)
			next_cnt = (cnt == MAX) ? 0 : cnt + 1'b1;
		else if (minus == 1 && plus == 0)
			next_cnt = (cnt == 0) ? MAX : cnt - 1'b1;
		else if (plus == 0 && minus == 0 && enable == 1) begin
			if (UP)
				next_cnt = (cnt == MAX) ? 0 : cnt + 1'b1;
			else
				next_cnt = (cnt == 0) ? MAX : cnt - 1'b1;
		end
		else
			next_cnt = cnt;
	end
	
endmodule

module Project1_Task11_Bottom_Switch_UP_DOWN_HOLD(input [1:0] KEY, input CLOCK_50, output [6:0] HEX1, HEX0);

	localparam N = 49_999_999;
	localparam BW = $clog2(N);
	wire reset_ready;

	COUNTER_RESET_DELAY #(.MAX(499_999), .WIDTH(20))
		delay_reset (.clk(CLOCK_50),.reset(reset_ready));

	wire up;
	wire down;
	wire [5:0] secs;
	wire [BW-1:0] tick;
	wire [3:0] secs_d1 = secs/10;
	wire [3:0] secs_d2 = secs%10;
	
	COUNTER #(.MAX(N-1),.WIDTH(BW))
		divider(.clk(CLOCK_50), .enable(1'b1), .cnt(tick));
	
	SSEG ss6(.digit(secs_d1),.SSEG(HEX1));
	
	SSEG ss7(.digit(secs_d2),.SSEG(HEX0));
	
	Tash10_COUNTER_UP_DOWN #(.MAX(59),.WIDTH(6),.UP(0))
		secs1(.clk(CLOCK_50),.enable(tick == 0),.reset(reset_ready),.plus(up),.minus(down),.cnt(secs));
	
	Buttom_toggled bt_up(.clk(CLOCK_50),.key(KEY[1]),.toggled(up));
	
	Buttom_toggled bt_down(.clk(CLOCK_50),.key(KEY[0]),.toggled(down));
	
endmodule

module Project1_Task12_COUNTER_HOLD #(parameter ZEROS = 1, WIDTH = $clog2(ZEROS+1))
    (input clk, enable, in, output reg pulse);
	
	reg [WIDTH-1:0] count = 0;

	always @(posedge clk) begin
		if (enable && in) begin
			if (count == ZEROS - 1) begin
				pulse <= 1;
				count <= 0;
			end
			else begin
				pulse <= 0;
				count <= count + 1;
			end
		end
		else begin
			count <= 0;
			pulse <= 0;
		end
	end
endmodule

module Project1_Task13_Bottom_Switch_SPEED_UP_DOWN_HOLD(input CLOCK_50, input [1:0] KEY, output [6:0] HEX1, HEX0, output [9:0] LEDR);

	localparam N = 49_999_999;
	localparam BW = $clog2(N);
	wire reset_ready;
	wire up, down;
	wire hold_up, hold_down;
	wire pulse_up, pulse_down;
	wire [5:0] secs;
	wire [BW-1:0] tick;
	wire [3:0] secs_d1 = secs / 10;
	wire [3:0] secs_d2 = secs % 10;
	wire auto_en = (tick == 0) && !(up || down);

	COUNTER_RESET_DELAY #(.MAX(499_999), .WIDTH(20))
		delay_reset(.clk(CLOCK_50),.reset(reset_ready));

	COUNTER #(.MAX(N-1), .WIDTH(BW))
		divider(.clk(CLOCK_50),.enable(1'b1),.cnt(tick));

	Buttom_toggled_hold bt_up(.clk(CLOCK_50),.key(KEY[1]),.toggled(up),.hold(hold_up));

	Buttom_toggled_hold bt_down(.clk(CLOCK_50),.key(KEY[0]),.toggled(down),.hold(hold_down));

	COUNTER_HOLD #(.ZEROS(9_999_999))
		pulse_up_gen(.clk(CLOCK_50),.enable(1'b1),.in(hold_up),.pulse(pulse_up));

	COUNTER_HOLD #(.ZEROS(9_999_999))
		pulse_down_gen(.clk(CLOCK_50),.enable(1'b1),.in(hold_down),.pulse(pulse_down));

	COUNTER_UP_DOWN_SPEED #(.MAX(59), .WIDTH(6),.UP(1))
		secs_counter(.clk(CLOCK_50),.enable((tick == 0) || pulse_up || pulse_down),.reset(reset_ready),.plus(up),
		.minus(down),.pulse_up(pulse_up),.pulse_down(pulse_down),.hold_up(hold_up),.hold_down(hold_down),.cnt(secs));

    SSEG ss1(.digit(secs_d1), .SSEG(HEX1));
    SSEG ss0(.digit(secs_d2), .SSEG(HEX0));
	 
	 assign LEDR[0] = tick;

endmodule

module Project1_Task15_IFADVANCE #(parameter LONG=3, PERIOD=5)
	(input clk, input in, output reg out, output reg hold);
	
	localparam BWL = $clog2(LONG+1);
	localparam BWP = $clog2(PERIOD);
	
	reg [BWL-1:0] cl = 0, next_cl;
	reg [BWP-1:0] cp = 0, next_cp;
	reg in_d = 0;
	
	 always @(posedge clk) begin
		{cl,cp} <= {next_cl,next_cp};
		in_d <= in;
	end
	
	always @(*) begin
        next_cl = cl;
        next_cp = cp;
        out = 0;
		  
		  if (in) begin
            if (cl < LONG)
                next_cl = cl + 1;
            else begin
					hold = 1;
					next_cl = LONG;
					next_cp = (cp == PERIOD - 1) ? 0 : cp + 1;
					if (cp == 0)
					out = 1;
				end
        end
		  else begin
            next_cl = 0;
            next_cp = 0;
				hold = 0;
        end

        if (in & ~in_d)
            out = 1;
    end
endmodule
	
module Project1_Task15_Bottom_Switch_SPEED_UP_DOWN_HOLD(input CLOCK_50, input [1:0] KEY, output [6:0] HEX1, HEX0);

	localparam LONG = 25_000_000;
	localparam PERIOD = 5_000_000;
	localparam N = 49_999_999;
	localparam BW = $clog2(N);
	localparam TIME = 20_000;
	
	wire [BW-1:0] tick;
	wire pulse_up, pulse_down;
	wire reset_ready;
	wire up, down;
	wire [5:0] secs;
	
	wire [3:0] secs_d1 = secs / 10;
	wire [3:0] secs_d2 = secs % 10;
	
	COUNTER #(.MAX(N-1), .WIDTH(BW))
		divider(.clk(CLOCK_50),.enable(1'b1),.cnt(tick));

	DEBOUNCE #(TIME)
		debounce_up(.clk(CLOCK_50),.noisy_in(!KEY[1]),.clean_out(up));
	DEBOUNCE #(TIME)
		debounce_down(.clk(CLOCK_50),.noisy_in(!KEY[0]),.clean_out(down));
	
	COUNTER_RESET_DELAY #(.MAX(499_999), .WIDTH(20))
		delay_reset(.clk(CLOCK_50),.reset(reset_ready));

	Project1_Task15_IFADVANCE #(LONG, PERIOD)
		up_1 (.clk(CLOCK_50),.in(up),.out(pulse_up),.hold(hold_up));
	Project1_Task15_IFADVANCE #(LONG, PERIOD)
		down_1 (.clk(CLOCK_50),.in(down),.out(pulse_down),.hold(hold_down));
		
	COUNTER_UP_DOWN_SPEED #(.MAX(59),.WIDTH(6),.UP(1))
		secs_counter(.clk(CLOCK_50),.enable((tick == 0) || pulse_up || pulse_down),.reset(reset_ready),.plus(up),
		.minus(down),.pulse_up(pulse_up),.pulse_down(pulse_down),.hold_up(hold_up),.hold_down(hold_down),.cnt(secs));
		
	SSEG ss1(.digit(secs_d1), .SSEG(HEX1));
	SSEG ss0(.digit(secs_d2), .SSEG(HEX0));
	
endmodule
	
	
module Task16_FLASH #(parameter TOTAL_PERIOD = 24_999_999, ON_TIME = 20_000_000)
	(input clk, output reg flash);

	localparam BW = $clog2(TOTAL_PERIOD);
	
	reg [BW-1:0] counter = 0;
	
	always @(posedge clk) begin
        if (counter < TOTAL_PERIOD - 1)
            counter <= counter + 1;
        else
            counter <= 0;

        if (counter < ON_TIME)
            flash <= 1;
        else
            flash <= 0;
    end

endmodule
	
	
module Project1_Task17_Watch(input CLOCK_50, input [3:0] KEY, output [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);

	localparam TOTAL_PERIOD = 24_999_999;
	localparam ON_TIME = 20_000_000;
	
	localparam PRESS_TIME = 50_000_000;
	
	
	wire [5:0] secs;
	wire [5:0] mins;
	wire [5:0] hours;
	wire flash;
	
	wire [3:0] secs_d1 = secs/10;
	wire [3:0] secs_d2 = secs%10;
	
	wire [3:0] mins_d1 = mins/10;
	wire [3:0] mins_d2 = mins%10;
	
	wire [3:0] hours_d1 = hours/10;
	wire [3:0] hours_d2 = hours%10;
	
	IFADVANCE_TOGGLE_ON_HOLD #(PRESS_TIME)
		testx(.clk(CLOCK_50),.in(!KEY[2]),.out(press_signal));
	
	FLASH #(TOTAL_PERIOD,ON_TIME)
		secs_flash(.clk(CLOCK_50),.signal(press_signal),.flash(flash));
	
	Task7_Time t(.clk(CLOCK_50),.hours(hours),.mins(mins),.secs(secs));
	
	SSEG_FLASH ss0(.digit(secs_d1),.flash(flash),.SSEG(HEX1));
	SSEG_FLASH ss1(.digit(secs_d2),.flash(flash),.SSEG(HEX0));
	
	SSEG ss2(.digit(mins_d1),.SSEG(HEX3));
	SSEG ss3(.digit(mins_d2),.SSEG(HEX2));
	
	SSEG ss4(.digit(hours_d1),.SSEG(HEX5));
	SSEG ss5(.digit(hours_d2),.SSEG(HEX4));
	
endmodule
	
module Project1_Task18_Watch(input CLOCK_50, input [3:0] KEY, input [9:0] SW, output [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);

	localparam TOTAL_PERIOD = 24_999_999;
	localparam ON_TIME = 20_000_000;
	
	localparam PRESS_TIME = 50_000_000;
	
	wire [5:0] secs;
	wire [5:0] mins;
	wire [5:0] hours;
	wire flash;
	
	wire [3:0] secs_d1 = secs/10;
	wire [3:0] secs_d2 = secs%10;
	
	wire [3:0] mins_d1 = mins/10;
	wire [3:0] mins_d2 = mins%10;
	
	wire [3:0] hours_d1 = hours/10;
	wire [3:0] hours_d2 = hours%10;
	
	IFADVANCE_TOGGLE_ON_HOLD #(PRESS_TIME)
		testx(.clk(CLOCK_50),.in(!KEY[2]),.out(press_signal));
	
	FLASH #(TOTAL_PERIOD, ON_TIME)
        secs_flash(.clk(CLOCK_50),.signal(press_signal & SW[0]),.flash(flash_sec));
    
    FLASH #(TOTAL_PERIOD, ON_TIME)
        mins_flash(.clk(CLOCK_50),.signal(press_signal & SW[1]),.flash(flash_min));
    
    FLASH #(TOTAL_PERIOD, ON_TIME)
        hours_flash(.clk(CLOCK_50),.signal(press_signal & SW[2]),.flash(flash_hour));
	
	Project1_Task7_Time t(.clk(CLOCK_50),.hours(hours),.mins(mins),.secs(secs));
	
	SSEG_FLASH ss0(.digit(secs_d1),.flash(flash_sec),.SSEG(HEX1));
	SSEG_FLASH ss1(.digit(secs_d2),.flash(flash_sec),.SSEG(HEX0));
	
	SSEG_FLASH ss2(.digit(mins_d1),.flash(flash_min),.SSEG(HEX3));
	SSEG_FLASH ss3(.digit(mins_d2),.flash(flash_min),.SSEG(HEX2));
	
	SSEG_FLASH ss4(.digit(hours_d1),.flash(flash_hour),.SSEG(HEX5));
	SSEG_FLASH ss5(.digit(hours_d2),.flash(flash_hour),.SSEG(HEX4));
	
endmodule
	
module Project1_Task19_IFADVANCE_TOGGLE_ON_HOLD_CYCLE #(parameter LONG = 50_000_000, PRESS_COUNT_MAX = 4)
    (input clk, input in, output reg [2:0] led_state);

    localparam BWL = $clog2(LONG + 1);

    reg [BWL-1:0] count = 0;
    reg in_d = 0;
    reg triggered = 0;
    reg [1:0] press_count = 0;

    always @(posedge clk) begin
        in_d <= in;

        if (in) begin
            if (count < LONG)
                count <= count + 1;
            else if (!triggered) begin
                triggered <= 1;
                press_count <= press_count + 1;
                if (press_count == PRESS_COUNT_MAX)
                    press_count <= 0;
            end
        end
        else begin
            count <= 0;
            triggered <= 0;
        end
		  
        case (press_count)
            0: led_state <= 3'b000;
            1: led_state <= 3'b001;
            2: led_state <= 3'b010;
            3: led_state <= 3'b100;
            default: led_state <= 3'b000;
        endcase
    end
endmodule
	
module Project1_Task20_Watch(input CLOCK_50, input [3:0] KEY, input [9:0] SW, output [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);

	localparam TOTAL_PERIOD = 24_999_999;
	localparam ON_TIME = 20_000_000;
	localparam PRESS_TIME = 50_000_000;
	localparam PRESS_COUNT_MAX = 4;
	
	wire [5:0] secs;
	wire [5:0] mins;
	wire [5:0] hours;
	wire [1:0]signal;
	wire flash_sec, flash_min, flash_hour;
	
	wire [3:0] secs_d1 = secs/10;
	wire [3:0] secs_d2 = secs%10;
	
	wire [3:0] mins_d1 = mins/10;
	wire [3:0] mins_d2 = mins%10;
	
	wire [3:0] hours_d1 = hours/10;
	wire [3:0] hours_d2 = hours%10;
	
	IFADVANCE_TOGGLE_ON_HOLD_CYCLE #(PRESS_TIME,PRESS_COUNT_MAX)
		press_detector(.clk(CLOCK_50),.in(!KEY[2]),.flash_mode(signal));
	
	FLASH #(TOTAL_PERIOD, ON_TIME)
		secs_flash(.clk(CLOCK_50),.signal(signal == 2'b01),.flash(flash_sec));
    
	FLASH #(TOTAL_PERIOD, ON_TIME)
		mins_flash(.clk(CLOCK_50),.signal(signal == 2'b10),.flash(flash_min));
    
	FLASH #(TOTAL_PERIOD, ON_TIME)
		hours_flash(.clk(CLOCK_50),.signal(signal == 2'b11),.flash(flash_hour));
	
	Project1_Task7_Time t(.clk(CLOCK_50),.hours(hours),.mins(mins),.secs(secs));
	
	SSEG_FLASH ss0(.digit(secs_d1),.flash(flash_sec),.SSEG(HEX1));
	SSEG_FLASH ss1(.digit(secs_d2),.flash(flash_sec),.SSEG(HEX0));
	
	SSEG_FLASH ss2(.digit(mins_d1),.flash(flash_min),.SSEG(HEX3));
	SSEG_FLASH ss3(.digit(mins_d2),.flash(flash_min),.SSEG(HEX2));
	
	SSEG_FLASH ss4(.digit(hours_d1),.flash(flash_hour),.SSEG(HEX5));
	SSEG_FLASH ss5(.digit(hours_d2),.flash(flash_hour),.SSEG(HEX4));
	
endmodule
	
module Project2_Task1_Watch(input CLOCK_50, input [3:0] KEY, input [9:0] SW, output [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);

	localparam TOTAL_PERIOD = 24_999_999;
	localparam ON_TIME = 20_000_000;
	localparam PRESS_TIME = 50_000_000;
	localparam PRESS_COUNT_MAX = 3;
	localparam TIME = 20_000;

	wire [5:0] secs;
	wire [5:0] mins;
	wire [5:0] hours;
	wire [1:0]signal;
	wire key2;
	wire flash_sec, flash_min, flash_hour;
	
	wire [3:0] secs_d1 = secs/10;
	wire [3:0] secs_d2 = secs%10;
	
	wire [3:0] mins_d1 = mins/10;
	wire [3:0] mins_d2 = mins%10;
	
	wire [3:0] hours_d1 = hours/10;
	wire [3:0] hours_d2 = hours%10;
	
	DEBOUNCE #(TIME)
		debounce_up(.clk(CLOCK_50),.noisy_in(!KEY[2]),.clean_out(key2));
	
	IFADVANCE_TOGGLE_ON_HOLD_CYCLE #(PRESS_TIME,PRESS_COUNT_MAX)
		press_detector(.clk(CLOCK_50),.in(key2),.flash_mode(signal));
	
	FLASH #(TOTAL_PERIOD, ON_TIME)
		secs_flash(.clk(CLOCK_50),.signal(signal == 2'b01),.flash(flash_sec));
    
	FLASH #(TOTAL_PERIOD, ON_TIME)
		mins_flash(.clk(CLOCK_50),.signal(signal == 2'b10),.flash(flash_min));
    
	FLASH #(TOTAL_PERIOD, ON_TIME)
		hours_flash(.clk(CLOCK_50),.signal(signal == 2'b11),.flash(flash_hour));
	
	Project1_Task7_Time t(.clk(CLOCK_50),.hours(hours),.mins(mins),.secs(secs));
	
	SSEG_FLASH ss0(.digit(secs_d1),.flash(flash_sec),.SSEG(HEX1));
	SSEG_FLASH ss1(.digit(secs_d2),.flash(flash_sec),.SSEG(HEX0));
	
	SSEG_FLASH ss2(.digit(mins_d1),.flash(flash_min),.SSEG(HEX3));
	SSEG_FLASH ss3(.digit(mins_d2),.flash(flash_min),.SSEG(HEX2));
	
	SSEG_FLASH ss4(.digit(hours_d1),.flash(flash_hour),.SSEG(HEX5));
	SSEG_FLASH ss5(.digit(hours_d2),.flash(flash_hour),.SSEG(HEX4));
	
endmodule
	
module Project2_Task2_BUTTON_CONTROL #(parameter LONG_MODE = 50_000_000, PRESS_COUNT_MAX = 3, LONG_ADV = 50_000_000, PERIOD_ADV = 5_000_000)
    (input clk, input in_mode, input in_adv1, input in_adv2, output [1:0] flash_mode, 
	 output out_adv1, output hold_adv1, output out_adv2, output hold_adv2);

    MODE #(LONG_MODE, PRESS_COUNT_MAX)
        mode_inst(.clk(clk), .in(in_mode), .flash_mode(flash_mode));

    FASTADVANCE #(LONG_ADV, PERIOD_ADV)
        fastadv1(.clk(clk), .in(in_adv1), .out(out_adv1), .hold(hold_adv1));

    FASTADVANCE #(LONG_ADV, PERIOD_ADV)
        fastadv2(.clk(clk), .in(in_adv2), .out(out_adv2), .hold(hold_adv2));

endmodule

module Project2_Task2_FASTADVANCE #(parameter LONG=3, PERIOD=5)
    (input clk, input in, output reg out, output reg hold);
    
    localparam BWL = $clog2(LONG+1);
    localparam BWP = $clog2(PERIOD);

    reg [BWL-1:0] cl = 0, next_cl;
    reg [BWP-1:0] cp = 0, next_cp;
    reg in_d = 0;
    reg hold_active = 0;
    
    always @(posedge clk) begin
        {cl, cp} <= {next_cl, next_cp};
        in_d <= in;
        hold <= hold_active;
    end
    
    always @(*) begin
        next_cl = cl;
        next_cp = cp;
        out = 0;
        hold_active = hold;
        
        if (in && !in_d)
            out = 1;
        
        if (in) begin
            if (cl < LONG) begin
                next_cl = cl + 1;
            end
            else begin
                hold_active = 1;
                
                if (cl == LONG) begin
                    out = 1;
                    next_cp = 1;
                end
                else begin
                    next_cp = (cp == PERIOD - 1) ? 0 : cp + 1;
                    if (cp == PERIOD - 1)
                        out = 1;
                end
            end
        end
        else begin
            next_cl = 0;
            next_cp = 0;
            hold_active = 0;
        end
    end
endmodule

module Project2_Tash2_MODE #(parameter LONG = 50_000_000, PRESS_COUNT_MAX = 3)
	(input clk, input in, output reg [1:0] flash_mode);

        localparam BWL = $clog2(LONG + 1);

    reg [BWL-1:0] count = 0;
    reg in_d = 0;
    reg triggered = 0;
    reg activated = 0;
    reg [1:0] press_count = 0;

    always @(posedge clk) begin
        in_d <= in;

        if (!activated) begin
            if (in) begin
                if (count < LONG)
                    count <= count + 1;
                else if (!triggered) begin
                    triggered <= 1;
                    activated <= 1;
                    press_count <= press_count + 1;
                    if (press_count == PRESS_COUNT_MAX) begin
                        press_count <= 0;
                        activated <= 0;
								triggered <= 0;
                    end
                end
            end
            else begin
                count <= 0;
                triggered <= 0;
            end
        end
        else if (in && !in_d) begin
            press_count <= press_count + 1;
            if (press_count == PRESS_COUNT_MAX) begin
                press_count <= 0;
                activated <= 0;
					 triggered <= 0;
            end
        end
		  
		  if (!in) begin
            count <= 0;
        end
		  
        case (press_count)
            0: flash_mode <= 2'b00;
            1: flash_mode <= 2'b01;
            2: flash_mode <= 2'b10;
            3: flash_mode <= 2'b11;
            default: flash_mode <= 2'b00;
        endcase
    end
endmodule
	
module Proect2_Task2_Flash_Control (input CLOCK_50, input [3:0] KEY, input signal, output [9:0] LEDR);
	 
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
		debounce_inst(.clk(CLOCK_50),.noisy_in(!KEY[2]),.clean_out(clean_key));

	MODE #(LONG, PRESS_COUNT_MAX)
		mode_inst(.clk(CLOCK_50),.in(clean_key),.flash_mode(flash_mode));
    
	FLASH #(TOTAL_PERIOD, ON_TIME)
		flash_inst (.clk(CLOCK_50), .signal(1'b1), .flash(flash_signal));

	DEMUX4 demux_inst (.in(flash_signal),.sel(flash_mode),.out(flash_out));
	
	assign LEDR[3:0] = flash_out;
	
endmodule
	
module Project2_Task3_BinToDec(input [6:0] bin, output reg [3:0] tens, output reg [3:0] ones);

    always @(*) begin
        tens = bin / 10;
        ones = bin % 10;
    end
	 
endmodule

module Project2_Task3_SSEG_DECODER(input [3:0] digit, output reg [6:0] SSEG);

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
	
module Project2_Task4_FLASH_CONTROL (input CLOCK_50, input [3:0] KEY, input [9:0] SW,
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
			
endmodule	
	
module Project2_Task5_WATCH(input CLOCK_50, input [3:0] KEY, output [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);

    localparam PRESS_TIME = 50_000_000;
    localparam PRESS_COUNT_MAX = 3;
    localparam TIME_SIGNAL = 20_000;
    localparam PERIOD_PULSE = 5_000_000;

    wire [5:0] secs, secs_mode;
    wire [5:0] mins, mins_mode;
    wire [5:0] hours, hours_mode;
    wire [1:0] signal;
	 
    PROJECT2_TASK5_TIME t(.clk(CLOCK_50),.mode(signal),.hours_mode(hours_mode),.mins_mode(mins_mode),
		.secs_mode(secs_mode),.hours(hours),.mins(mins),.secs(secs));

    FLASH_CONTROL flash_control(.clk(CLOCK_50),.hours(hours),.mins(mins),.secs(secs),.signal(signal),
        .HEX0(HEX0),.HEX1(HEX1),.HEX2(HEX2),.HEX3(HEX3),.HEX4(HEX4),.HEX5(HEX5));
    
    BUTTON_CONTROL #(.LONG_MODE(PRESS_TIME),.PRESS_COUNT_MAX(PRESS_COUNT_MAX),.LONG_ADV(PRESS_TIME),.PERIOD_ADV(PERIOD_PULSE),.TIME(TIME_SIGNAL))
        button_control(.clk(CLOCK_50),.flash_mode(signal),.secs(secs),.mins(mins),.hours(hours),.key(KEY),.secs_mode(secs_mode),
		  .mins_mode(mins_mode),.hours_mode(hours_mode));

endmodule

	
module PROJECT2_TASK5_TIME(input clk, input [1:0] mode,input [5:0] hours_mode, mins_mode, secs_mode,
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
	
module Project2_Task6_StopWatch
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

module Project2_Task7_COUNTDOWN
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

module Project3_Task1_WATCH(input CLOCK_50, input [3:0] KEY, output [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, output [9:0] LEDR);

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
	 
	PROJECT2_TASK5_TIME t(.clk(CLOCK_50),.mode(signal),.hours_mode(hours_mode),.mins_mode(mins_mode),
		.secs_mode(secs_mode),.hours(hours),.mins(mins),.secs(secs));

	FLASH_CONTROL flash_control(.clk(CLOCK_50),.hours(hours),.mins(mins),.secs(secs),.signal(signal),
		.on_control(mux_mode),.HEX0(HEX0_in1),.HEX1(HEX1_in1),.HEX2(HEX2_in1),
		.HEX3(HEX3_in1),.HEX4(HEX4_in1),.HEX5(HEX5_in1));
    
	BUTTON_CONTROL #(.LONG_MODE(PRESS_TIME),.PRESS_COUNT_MAX(BUTTOM_PRESS_COUNT_MAX),.LONG_ADV(PRESS_TIME),
		.PERIOD_ADV(PERIOD_PULSE),.TIME(TIME))
		button_control(.clk(CLOCK_50),.flash_mode(signal),.secs(secs),.mins(mins),
		.hours(hours),.KEY1(key1_1),.KEY2(key2_1),.KEY0(key0_1),.secs_mode(secs_mode),
		.mins_mode(mins_mode),.hours_mode(hours_mode));
		
	Project2_Task6_StopWatch
		stopwatch(.CLOCK_50(CLOCK_50),.KEY2(key2_2),.KEY0(!key0_2),.on_control(mux_mode),
		.HEX5(HEX5_in2),.HEX4(HEX4_in2),.HEX3(HEX3_in2),.HEX2(HEX2_in2),
		.HEX1(HEX1_in2),.HEX0(HEX0_in2));
	 
	Project2_Task7_COUNTDOWN
		countdown(.CLOCK_50(CLOCK_50),.KEY1(key1_3),.KEY2(key2_3),.KEY0(!key0_3),.on_control(mux_mode),
		.HEX5(HEX5_in3),.HEX4(HEX4_in3),.HEX3(HEX3_in3),.HEX2(HEX2_in3),
		.HEX1(HEX1_in3),.HEX0(HEX0_in3),.LEDR(LEDR[0]));
	
	MODE_SWITCH #(.PRESS_COUNT_MAX(3))
		mode_switch(.clk(CLOCK_50),.in(key3),.mux_mode(mux_mode));
	
	assign LEDR[9:7] = mux_mode;
	
endmodule




