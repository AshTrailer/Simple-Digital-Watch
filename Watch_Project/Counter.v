module INITIAL_COUNTER(input clk, output reg [3:0] cnt);
	wire [3:0] next_cnt;
	initial cnt = 1'b0;
		
	always @(posedge clk) 
		cnt <= next_cnt;
	assign next_cnt = cnt +1'b1;
endmodule


//Counter #(.MAX(n),.WIDTH(m)) cn(.clk(clk),.cnt(cnt));
//n <= 2^m
//if want to count 60, then set MAX = 59
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

module COUNTER_PARAMETER #(parameter MAX=1, WIDTH=1, HOLD=1) 
	(input clk, enable, hold, output reg [WIDTH-1:0] cnt, output reg pulse);
	
	initial cnt = 0;
	reg [WIDTH-1:0] next_cnt;
		
	always @(posedge clk) begin
		if (enable) begin
			cnt <= next_cnt;
			if (cnt == HOLD)
				pulse <= 1;
			else if (hold == 0)
				pulse <= 0;
		end
	end
		
	always @(*) begin
		if (hold)
			next_cnt = (cnt == MAX) ? 0 : cnt + 1'b1;
		else
			next_cnt = 0;
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

module COUNTER_RESET #(parameter MAX=1, WIDTH=1) 
	(input clk, enable, reset, output reg [WIDTH-1:0] cnt);
	
	initial cnt = 0;
	reg [WIDTH-1:0] next_cnt;
		
	always @(posedge clk) begin
		if (reset)
			cnt <= 0;
		else if (enable)
			cnt <= next_cnt;
		end
		
	always @(*)
		next_cnt = (cnt == MAX) ? 0 : cnt + 1'b1;
		
endmodule

module COUNTER_RESET_DELAY #(parameter MAX=500_000, WIDTH=20)
    (input clk, output reg reset);

    reg [WIDTH-1:0] cnt = 0;

    always @(posedge clk) begin
        if (cnt < MAX) begin
            cnt <= cnt + 1;
            reset <= 1'b1;
        end else begin
            reset <= 1'b0;
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
						cnt <= 0;  // Wrap around to 0 if counter reaches MAX
					else
						cnt <= cnt + 1;  // Increment counter by 1
					end
				else if (pulse_down) begin
					if (cnt == 0)
						cnt <= MAX;  // Wrap around to MAX if counter is 0
					else
						cnt <= cnt - 1;  // Decrement counter by 1
					end
				end
        
        prev_mode <= mode;
    end
endmodule

module COUNTER_UP_DOWN_SPEED_MODE #(parameter MAX = 1, WIDTH = 1, UP = 1)
    (input clk, enable, reset, input plus, minus,
     input pulse_up, pulse_down, input hold_up, hold_down,
     input [1:0] mode, output reg [WIDTH-1:0] cnt);

    initial cnt = 0;

    always @(posedge clk or posedge reset) begin
        if (reset)
            cnt <= 0;
        else if (enable) begin
            if (mode == 2'b00) begin
                if (UP)
                    cnt <= (cnt == MAX) ? 0 : cnt + 1;
                else
                    cnt <= (cnt == 0) ? MAX : cnt - 1;
            end
            else begin
                if (pulse_up)
                    cnt <= (cnt == MAX) ? 0 : cnt + 1;
                else if (pulse_down)
                    cnt <= (cnt == 0) ? MAX : cnt - 1;
                
                else if (plus && !minus && !hold_up)
                    cnt <= (cnt == MAX) ? 0 : cnt + 1;
                else if (minus && !plus && !hold_down)
                    cnt <= (cnt == 0) ? MAX : cnt - 1;
            end
        end
    end
endmodule


module COUNTER_HOLD #(parameter ZEROS = 1, WIDTH = $clog2(ZEROS+1))
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

module COUNTER_UP_DOWN #(parameter MAX = 1, WIDTH = 1, UP = 1) 
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

module COUNTER_DIRECTION #(parameter MAX=1, WIDTH=1) 
	(input clk, enable, reset, direction, output reg [WIDTH-1:0] cnt);
	
	initial cnt = 0;
	reg [WIDTH-1:0] next_cnt;
		
	always @(posedge clk) begin
		if (reset)
			cnt <= 0;
		else if (enable)
			cnt <= next_cnt;
		end
		
	always @(*) begin
		if (direction)
			next_cnt = (cnt == MAX) ? 0 : cnt + 1'b1;
		else
			next_cnt = (cnt == 1'b0) ? MAX : cnt - 1'b1;
	end
	
endmodule

