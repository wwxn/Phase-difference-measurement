module usart_send_ctrl
(
	input [27:0] high_level,
	input [27:0] low_level,
	input clk,
	input rst_n,
	output [7:0] tx_data,
	output tx_valid,
	input tx_data_ready
);


reg [7:0] send_counter;
reg [7:0] tx_byte;
reg tx_valid_reg;
reg[4:0] state;
reg[4:0] state_next;
reg [31:0] wait_counter;


parameter START=5'b00000;
parameter SENDNUMBER=5'b00001;
parameter SENDDATA=5'b00011;
parameter WAIT=5'b00010;

assign tx_data=tx_byte;
assign tx_valid=(state==WAIT)?1'b0:1'b1;

always@(posedge clk)
	if(!rst_n)
		state<=START;
	else
		state<=state_next;


always@* begin
	state_next<=5'dx;
	if(tx_data_ready)
		case(state)
		START:
			state_next<=SENDNUMBER;
		SENDNUMBER:
			state_next<=SENDDATA;
		SENDDATA:
			if(send_counter>8'd9)
				state_next<=WAIT;
			else
				state_next<=SENDDATA;
		WAIT:
			if(wait_counter>=32'd25000000)
				state_next<=START;
			else
				state_next<=WAIT;
		endcase
end

always@(posedge clk)
	if(!rst_n)begin
		send_counter<=8'd0;
		wait_counter<=32'd0;
	end
	else
	if(tx_data_ready)
		case(state_next)
		START:begin
			send_counter<=8'd0;
			wait_counter<=32'd0;
		end
		SENDNUMBER:
			send_counter<=send_counter+1'b1;
		SENDDATA:
			send_counter<=send_counter+1'b1;
		WAIT:
			wait_counter<=wait_counter+1'b1;
		endcase

			
	


always@*
	case(send_counter)
	8'd0:tx_byte<="D";
	8'd1:tx_byte<=8'd8;
	8'd2:tx_byte<=(high_level>>24)&8'hff;
	8'd3:tx_byte<=(high_level>>16)&8'hff;
	8'd4:tx_byte<=(high_level>>8)&8'hff;
	8'd5:tx_byte<=high_level&8'hff;
	8'd6:tx_byte<=(low_level>>24)&8'hff;
	8'd7:tx_byte<=(low_level>>16)&8'hff;
	8'd8:tx_byte<=(low_level>>8)&8'hff;
	8'd9:tx_byte<=low_level&8'hff;
	endcase
	
endmodule 