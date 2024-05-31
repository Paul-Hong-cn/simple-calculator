module calculator(
	input wire clk,
	input wire reset,
	input data_en,
	input busy,
	input wire[7:0] rx_data,//接收数据
	output reg[7:0] tx_data,//发送数据
	output reg tx_en//发送使能信号
);

reg signed[32:0]operator1,operator2;//两个操作数
reg [2:0]operation;//00-加法，01-减法，10-乘法，11-除法
reg signed[63:0]result;
reg signed[32:0] temp_operator;//临时操作数
reg signed [2:0] sign;//符号位标志

reg [7:0] ascii_buffer[0:21];//存储数字转换为ASCII的结果
reg [5:0] buffer_len;//存储结果的长度
reg signed [5:0] send_index;//发送索引
reg [3:0] i;


localparam CHECK_SIGN1 = 1,READ_OP1 = 2,CHECK_SIGN2 = 3,READ_OP2 = 4,
			  EMPTY1 = 5,EMPTY2 = 6,EMPTY3 = 7,EMPTY4 = 8,EMPTY5 = 9,
			  CALC = 10,CONVERT_RESULT1 = 11,CONVERT_RESULT2 = 12,
			  SEND_RESULT = 13,SEND_RESULT_WAIT = 14,
			  WAIT1 = 15,WAIT2 = 16,WAIT3 = 17,WAIT4 = 18,
			  WAIT5 = 19,WAIT6 = 20,WAIT7 = 21,WAIT8 = 22,
			  WAIT9 = 23,WAIT10 = 24,WAIT11 = 25,WAIT12 = 26,
			  WAIT13 = 27,WAIT14 = 28,WAIT15 = 29,WAIT16 = 30,
			  EMPTY6 = 31,EMPTY7 = 32,EMPTY8 = 33,EMPTY9 = 34,EMPTY10 = 35;
reg [6:0]state,next_state;//状态机定义
initial begin
	i = 0;
	buffer_len = 0;
	send_index = 0;
	for (i = 0; i < 11; i = i + 1) begin
		ascii_buffer[i] = 0;
		ascii_buffer[i+10] = 0;
   end
	result = 0;
	sign = 0;
	
end

always @(*) begin
	case(state)
		CHECK_SIGN1:next_state <= READ_OP1;
		READ_OP1:next_state <= CHECK_SIGN2;
		CHECK_SIGN2:next_state <= READ_OP2;
		READ_OP2:next_state <= EMPTY1;
		EMPTY1:next_state <= EMPTY2;
		EMPTY2:next_state <= EMPTY3;
		EMPTY3:next_state <= EMPTY4;
		EMPTY4:next_state <= EMPTY5;
		EMPTY5:next_state <= CALC;
		CALC:next_state <= CONVERT_RESULT1;
		CONVERT_RESULT1:next_state <= CONVERT_RESULT2;
		CONVERT_RESULT2:next_state <= SEND_RESULT;
		SEND_RESULT:next_state <= SEND_RESULT_WAIT;
		default:next_state <= CHECK_SIGN1;//计算逻辑状态转移
	endcase
end
wire signed [63:0] r_add;
wire signed [63:0] r_min;
wire signed [63:0] r_mul;
wire signed [63:0] r_div;
wire signed [32:0] temp_mul_add;
wire signed [32:0] signed_temp;
wire signed [63:0] result_end;

assign r_add = operator1 + operator2;
assign r_min = operator1 - operator2;
assign r_mul = operator1 * operator2;
assign r_div = operator1 / operator2;
assign temp_mul_add  = (temp_operator * 10) + (rx_data - 8'h30);
assign signed_temp = temp_operator * sign;
assign result_end = (result % 10) + 8'h30;

always @(posedge clk)begin
	if (reset) begin
		state <= CHECK_SIGN1;//初始化状态
		
	end else begin
		case(state)
			CHECK_SIGN1:begin//状态1
				if (data_en) begin
					if(rx_data == 8'h2D)begin
						sign <= -1;
						temp_operator <= 0;
					end 
					else begin
						sign <= 1;
						temp_operator <= rx_data - 8'h30;
					end
					state <= next_state;
					tx_data <= 0;
					tx_en <= 0;
					operator1 <= 0;
					operator2 <= 1;
					operation <= 4;
					result <= 0;
					i <= 0;
					buffer_len <= 0;
				end
			end
			READ_OP1:begin//状态2
				if(data_en) begin
					if(rx_data >= 8'h30 && rx_data <= 8'h39)begin
						state <= WAIT1;
					end else if(rx_data == 8'h2B || rx_data == 8'h2D || rx_data == 8'h2A || rx_data == 8'h2F)begin
						operator1 <= signed_temp;//检测到运算符，第一个操作数取数结束
						case(rx_data)
							8'h2B:operation <= 2'b00;
							8'h2D:operation <= 2'b01;
							8'h2A:operation <= 2'b10;
							8'h2F:operation <= 2'b11;
						endcase//将运算符转换为所对应状态，便于后续运算
						temp_operator <= 0;//临时操作数归零
						state <= next_state;
					end
				end
			end
			WAIT1:begin//状态15
				state <= WAIT2;
			end
			WAIT2:begin//状态16
				temp_operator <= temp_mul_add;
				state <= WAIT3;
			end
			WAIT3:begin//状态17
				state <= WAIT4;
			end
			WAIT4:begin//状态18
				state <= READ_OP1;
			end
			CHECK_SIGN2:begin//状态3
				if(data_en) begin
					if(rx_data == 8'h2D)begin
						sign <= -1;
						temp_operator <= 0;
					end 
					else begin
						sign <= 1;
						temp_operator <= rx_data - 8'h30;
					end
					state <= next_state;
				end
			end
			READ_OP2:begin//状态4
				if(data_en) begin
					if(rx_data >= 8'h30 && rx_data <= 8'h39)begin
						state <= WAIT5;
					end else if(rx_data == 8'h3D) begin
						operator2 <= signed_temp;//检测到等号，第二个操作数取数结束
						state <= next_state;
					end
				end
			end
			WAIT5:begin//状态19
				state <= WAIT6;
			end
			WAIT6:begin//状态20
				temp_operator <= temp_mul_add;
				state <= WAIT7;
			end
			WAIT7:begin//状态21
				state <= WAIT8;
			end
			WAIT8:begin//状态22
				state <= READ_OP2;
			end
			
			
			EMPTY1:begin//状态5
				state <= next_state;
			end
			EMPTY2:begin//状态6
				state <= next_state;
			end
			EMPTY3:begin//状态7
				state <= next_state;
			end
			EMPTY4:begin//状态8
				state <= next_state;
			end
			EMPTY5:begin//状态9
				state <= next_state;
			end
			CALC:begin//状态10
					case(operation)
						2'b00:result <= r_add;
						2'b01:result <= r_min;
						2'b10:result <= r_mul;
						2'b11:result <= r_div;
					endcase
					state <= next_state;
			end
			CONVERT_RESULT1:begin//状态11
					buffer_len <= 0;
					if(result < 0) begin
						ascii_buffer[buffer_len] <= 8'h2D;
						result <= result * (-1);
						buffer_len <= buffer_len + 1;
					end//将结果转换为绝对数字
					if (result == 0) begin
						ascii_buffer[buffer_len] <= 8'h30;
						buffer_len <= buffer_len + 1;
					end
					state <= next_state;
			end	
			CONVERT_RESULT2:begin//状态12
					if(result != 0) begin
							state <= WAIT9;
					end
					else begin
							state <= next_state;
							send_index <= buffer_len;
					end
			end
			WAIT9:begin//状态23
				state <= WAIT10;
			end
			WAIT10:begin//状态24
				ascii_buffer[buffer_len] <= result_end;
				state <= WAIT11;
			end
			WAIT11:begin//状态25
				result <= result / 10;
				state <= WAIT12;
			end
			WAIT12:begin//状态26
				buffer_len <= buffer_len + 1;
				state <= CONVERT_RESULT2;
			end
			SEND_RESULT: begin//状态13
				if (!busy) begin
					// 检查是否第一个字符是负号
					if (send_index == buffer_len  && ascii_buffer[0] == 8'h2D) begin
						tx_data <= ascii_buffer[0];  // 发送负号
						tx_en <= 1;
						send_index <= send_index - 1;  // 递减索引，准备发送下一个字符
						state <= SEND_RESULT_WAIT;
					end else if (send_index > 0 && ascii_buffer[0] == 8'h2D) begin
            // 如果是负数
							tx_data <= ascii_buffer[send_index];
							tx_en <= 1;
							send_index <= send_index - 1;  // 递减索引
							state <= SEND_RESULT_WAIT;
					end else if(send_index >= 0 && ascii_buffer[0] != 8'h2D) begin
					//如果不是负数
							send_index <= send_index - 1;  // 递减索引
							tx_data <= ascii_buffer[send_index];
							if(send_index <= buffer_len - 1)begin
								tx_en <= 1;
							end
							state <= SEND_RESULT_WAIT;
					end
					else begin
						tx_en <= 0;  // 没有更多数据需要发送
						state <= next_state; // 转到下一个状态
						send_index <= send_index -1;
					end
				end
			end
			SEND_RESULT_WAIT:begin//状态14
				tx_en <= 0;
				if (send_index >= 0) begin
					state <= EMPTY6;
				end else begin
					state <= WAIT13;
					tx_data <= 0;
					tx_en <= 0;
					
				end
			end
			EMPTY6:begin
				state <= EMPTY7;
			end
			EMPTY7:begin
				state <= EMPTY8;
			end
			EMPTY8:begin
				state <= EMPTY9;
			end
			EMPTY9:begin
				state <= EMPTY10;
			end
			EMPTY10:begin
				state <= SEND_RESULT;
			end
			
			WAIT13:begin//状态27
				state <= WAIT14;
				operation <= 4;
				temp_operator <= 0;
			end
			WAIT14:begin//状态28
				state <= WAIT15;
				operator1 <= 0;
				operator2 <= 1;
				
				
			end
			WAIT15:begin//状态29
				state <= WAIT16;
				sign <= 0;
				i <= 0;
			end
			WAIT16:begin//状态30
				state <= CHECK_SIGN1;
				result <= 0;
				buffer_len <= 0;
			end
			default:state <= CHECK_SIGN1;
		endcase
	end
end

endmodule 