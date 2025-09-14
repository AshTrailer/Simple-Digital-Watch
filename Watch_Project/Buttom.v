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

module BUTTON_CONTROL_STOPWATCH #(parameter LONG_MODE = 50_000_000,PRESS_COUNT_MAX = 3,LONG_ADV = 50_000_000,PERIOD_ADV = 5_000_000,TIME = 20_000)
	(input clk, input [5:0] secs, input [5:0] mins, input [5:0] hours, input [3:0] key,output [5:0] secs_mode, output [5:0] mins_mode,
	output [5:0] hours_mode, output [1:0] flash_mode);
	
	wire pulse_down, hold_down;
	wire pulse_up, hold_up;
	wire key1_out, key0_out, key2_out;
	
	DEBOUNCE #(TIME)
        debounce_key2(.clk(clk),.noisy_in(!key[2]),.clean_out(key2_out));
	DEBOUNCE #(TIME)
        debounce_key1(.clk(clk),.noisy_in(!key[1]),.clean_out(key1_out));
	DEBOUNCE #(TIME)
        debounce_key0(.clk(clk),.noisy_in(!key[0]),.clean_out(key0_out));

	MODE #(LONG_MODE, PRESS_COUNT_MAX)
		mode(.clk(clk),.in(key2_out),.flash_mode(flash_mode));

	FASTADVANCE #(LONG_ADV, PERIOD_ADV)
		fast1(.clk(clk),.in(key1_out),.out(pulse_up),.hold(hold_up));
    
	FASTADVANCE #(LONG_ADV, PERIOD_ADV)
		fast2(.clk(clk), .in(key0_out),.out(pulse_down),.hold(hold_down));

	COUNTER_UP_DOWN_SPEED #(.MAX(100), .WIDTH(7))
		secs_counter(.clk(clk),.enable(flash_mode == 2'b01),.mode(flash_mode),.in(secs),.pulse_up(pulse_up),.pulse_down(pulse_down),
			.cnt(secs_mode));

	COUNTER_UP_DOWN_SPEED #(.MAX(59), .WIDTH(6))
		mins_counter(.clk(clk),.enable(flash_mode == 2'b10),.mode(flash_mode),.in(mins),.pulse_up(pulse_up),.pulse_down(pulse_down),
			.cnt(mins_mode));
			
	COUNTER_UP_DOWN_SPEED #(.MAX(59), .WIDTH(6))
		hours_counter(.clk(clk),.enable(flash_mode == 2'b11),.mode(flash_mode),.in(hours),.pulse_up(pulse_up),.pulse_down(pulse_down),
			.cnt(hours_mode));

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

module FASTADVANCE #(parameter LONG=50_000_000, PERIOD=5_000_000)
    (input clk, input in, output reg out, output reg hold);
    
    localparam BWL = $clog2(LONG+1);
    localparam BWP = $clog2(PERIOD);

    reg [BWL-1:0] cl = 0, next_cl;
    reg [BWP-1:0] cp = 0, next_cp;
    reg in_d = 0;
    reg hold_active = 0;
    reg hold_pulse = 0;

    always @(posedge clk) begin
        {cl, cp} <= {next_cl, next_cp};
        in_d <= in;
        hold <= hold_active;
        out <= hold_pulse;
    end
    
    always @(*) begin
        next_cl = cl;
        next_cp = cp;
        hold_active = hold;
        hold_pulse = 0;
        
        if (in && !in_d) begin
            hold_pulse = 1;
        end
        
        if (in) begin
            if (cl < LONG) begin
                next_cl = cl + 1;
            end
            else begin
                hold_active = 1;
                
                if (cp == 0) begin
                    hold_pulse = 1;
                end
                
                next_cp = (cp == PERIOD - 1) ? 0 : cp + 1;
            end
        end
        else begin
            next_cl = 0;
            next_cp = 0;
            hold_active = 0;
        end
    end
endmodule

module MODE #(parameter LONG = 50_000_000, PRESS_COUNT_MAX = 3)
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

module IFADVANCE_TOGGLE_ON_HOLD_CYCLE #(parameter LONG = 50_000_000, PRESS_COUNT_MAX = 3)
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

module BUTTON_SHORT_PULSE_LONG_PULSE #(parameter LONG = 3, PERIOD = 5, TIME = 20_000)
    (input clk, input raw_btn, output pulse, output hold);

    wire debounced;

    DEBOUNCE #(TIME)
		debounce_inst (.clk(clk),.noisy_in(raw_btn),.clean_out(debounced));

    IFADVANCE #(LONG, PERIOD)
		ifadvance_inst (.clk(clk),.in(debounced),.out(pulse),.hold(hold));

endmodule

module IFADVANCE_TOGGLE_ON_HOLD #(parameter LONG = 3)
    (input clk, input in, output reg out);

    localparam BWL = $clog2(LONG + 1);

    reg [BWL-1:0] count = 0;
    reg in_d = 0;
    reg triggered = 0;

    always @(posedge clk) begin
        in_d <= in;

        if (in) begin
            if (count < LONG)
                count <= count + 1;
            else if (!triggered) begin
                out <= ~out;
                triggered <= 1;
            end
        end else begin
            count <= 0;
            triggered <= 0;
        end
    end
endmodule

module IFADVANCE #(parameter LONG=3, PERIOD=5)
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

module Bottom_Switch_SPEED_UP_DOWN_HOLD_1(input CLOCK_50, input [1:0] KEY, output [6:0] HEX1, HEX0);

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

	Task15_IFADVANCE #(LONG, PERIOD)
		up_1 (.clk(CLOCK_50),.in(up),.out(pulse_up),.hold(hold_up));
	Task15_IFADVANCE #(LONG, PERIOD)
		down_1 (.clk(CLOCK_50),.in(down),.out(pulse_down),.hold(hold_down));
		
	COUNTER_UP_DOWN_SPEED #(.MAX(59),.WIDTH(6),.UP(1))
		secs_counter(.clk(CLOCK_50),.enable((tick == 0) || pulse_up || pulse_down),.reset(reset_ready),.plus(up),
		.minus(down),.pulse_up(pulse_up),.pulse_down(pulse_down),.hold_up(hold_up),.hold_down(hold_down),.cnt(secs));
		
	SSEG ss1(.digit(secs_d1), .SSEG(HEX1));
	SSEG ss0(.digit(secs_d2), .SSEG(HEX0));
	
endmodule
	
module Buttom_toggled_hold(input clk, input [0:0] key, output reg toggled, output reg hold);

	localparam N = 49_999_999;
	localparam BW = $clog2(N);

    reg [27:0] count = 0;
    wire btn_rising;
    reg key_prev = 1;

    always @(posedge clk)
        key_prev <= key[0];

    assign btn_rising = ~key_prev & key[0];

    always @(posedge clk) begin
        if (!key[0]) begin
            if (count < N)
                count <= count + 1;
            else
                hold <= 1;
        end
        else begin
            count <= 0;
            hold <= 0;
        end
    end

    always @(posedge clk) begin
        if (btn_rising && !hold)
            toggled <= ~toggled;
    end
endmodule


module Bottom_Switch_SPEED_UP_DOWN_HOLD_2(input CLOCK_50, input [1:0] KEY, output [6:0] HEX1, HEX0);

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

	COUNTER_UP_DOWN_SPEED #(.MAX(59), .WIDTH(6))
		secs_counter(.clk(CLOCK_50),.enable((tick == 0) || pulse_up || pulse_down),.reset(reset_ready),.plus(up),
		.minus(down),.pulse_up(pulse_up),.pulse_down(pulse_down),.hold_up(hold_up),.hold_down(hold_down),.cnt(secs));

    SSEG ss1(.digit(secs_d1), .SSEG(HEX1));
    SSEG ss0(.digit(secs_d2), .SSEG(HEX0));

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
	