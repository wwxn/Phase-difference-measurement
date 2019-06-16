module frequency_detecion
(
	input clk_400M,
	input rst_n,
	input signal,
	output reg [27:0]high_level,
	output reg [27:0]low_level
);
reg [27:0]high_level_buff;
reg [27:0]low_level_buff;
reg state,state_last;
reg [1:0]step;
wire rising_edge=(!state_last)&&state;
wire falling_edge=(state_last)&&(!state);

always@(posedge clk_400M)
	if(!rst_n)
	begin
		state<=1'b0;
		state_last<=1'b0;
	end
	else
	begin
		state_last<=state;
		state<=signal;
	end

always@(posedge clk_400M)
begin
	if(!rst_n)
	begin
		step<=2'b0;
		high_level<=28'b0;
	end
	else
	begin
		case (step)
		0:
		begin
			if(rising_edge)
			begin
				step<=2'b1;
				high_level_buff<=28'd0;
				low_level_buff<=28'd0;
			end
		end
		1:
		begin
			if(falling_edge)
			begin
				step<=2'd2;
				high_level<=high_level_buff;
			end
			else
				high_level_buff<=high_level_buff+1'b1;
		end
		2:
			if(rising_edge)
			begin
				step<=2'd0;
				low_level<=low_level_buff;
			end
			else
				low_level_buff<=low_level_buff+1'b1;
		endcase
	end
end

endmodule