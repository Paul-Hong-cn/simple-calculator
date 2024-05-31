module uart_receive(
    input clk,//输入时钟信号（假设为50MHz） 
    input rx,//UART接收信号，空闲状态为1
    output reg data_en,//数据准备好
    output reg [7:0] data_out//UART的8位输出数据
    );
    
	initial data_en <= 1'b0;//没有数据准备好
	initial data_out <= 8'd0;//输出数据为0
		
	parameter DIV_NUM = 1736; 
	/*时钟周期50MHz，9600波特率，发送一位需要5208个时钟周期，
	一个位周期采样3次，则采样1次需要1736个时钟周期*/
	parameter WIDTH = 11;

	reg  [1:0]rx_buf;
	reg [WIDTH-1:0] cnt;
	reg [1:0]state;

	reg [1:0]samples;
	reg [2:0]rev_cnt;
	reg [1:0]cnt3;
	reg [7:0]data_sfg;

	initial cnt <= {WIDTH{1'b0}};
	initial state <= 2'b00;
	initial rx_buf <= 2'b0;
	initial rev_cnt <= 3'b0; 
	initial data_sfg <= 8'd0;

	always @(posedge clk)
	begin
		rx_buf[1:0] <= {rx_buf[0],rx};//50MHz时钟周期每次都更新rx的值
		case(state)
		2'b00:begin//起始位检测
			if(rx_buf==2'b10)begin//检测到下降沿
				cnt <= (DIV_NUM-1)/2;
				cnt3 <= 2'b00;
				state <= 2'b01;//如果检测到起始位，则初始化计数器并转换到状态1
			end else begin
				cnt <= {WIDTH{1'b0}};
			end
			data_en <= 1'b0; 
		end
		2'b01:begin//起始位验证
			if(cnt == DIV_NUM-1)begin
				cnt <= {WIDTH{1'b0}};//将cnt置零
				samples <= {samples[0],rx_buf[1]};
				if(cnt3==2'b10)begin//(1/6+2/3)个位后检测
					if({samples[1:0],rx_buf[1]}==3'b000)begin//低电平，确认为起始位
						state <= 2'b10;
						cnt3 <= 2'b00;
						rev_cnt <= 4'd0;
					end else begin
						state <= 2'b00;
					end
				end else begin
					cnt3 <= cnt3 + 2'b01;
				end
			end else begin
				cnt <= cnt + {{(WIDTH-1){1'b0}},1'b1};//实现cnt递增
			end
		end
		2'b10:begin//数据位接收
			if(cnt == DIV_NUM-1)begin
				cnt <= {WIDTH{1'b0}};
				samples <= {samples[0],rx_buf[1]};
				if(cnt3==2'b10)begin//(1/6+2/3)个位后检测
					cnt3 <= 2'b00;
					data_sfg[6:0] <= data_sfg[7:1];//逐位右移
					case ({samples[1:0],rx_buf[1]})
						3'b011   : data_sfg[7] <= 1'b1;
						3'b101   : data_sfg[7] <= 1'b1;
						3'b110   : data_sfg[7] <= 1'b1;
						3'b111   : data_sfg[7] <= 1'b1;					
						default : data_sfg[7] <= 1'b0;
					endcase//只要最近3个采样中rx有两个高电平，就把data_sfg设置为1
					if(rev_cnt == 3'd7)begin
						rev_cnt <= 3'd0;
						state <= 2'b11;//传输数据为8位
					end else begin
						rev_cnt <= rev_cnt + 3'd1;
					end
				end else begin
					cnt3 <= cnt3 + 2'b01;
				end
			end else begin
				cnt <= cnt + {{(WIDTH-1){1'b0}},1'b1};
			end
		end
		2'b11:begin//数据就绪
			state <= 2'b00;
			data_en <= 1'b1;
			data_out <= data_sfg[7:0];//数据发送
		end
		endcase        
	end
endmodule 