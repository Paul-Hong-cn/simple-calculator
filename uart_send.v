module uart_send(
    input clk,//50MHz时钟周期
    input rst,//复位信号
    input [7:0] data_in,//8位数据输入
	 input data_en,//数据有效信号
    output tx,//发送引脚
	 output reg busy// 忙信号
);

parameter STOP = 1;
parameter DIV_NUM = 5208;//传输一位所需要的时钟周期
parameter WIDTH = 13;//DIV_NUM的位宽

reg [8:0]sfg;//数据移位寄存器
reg [3:0]cnt;//位计数器
reg send_en;//发送使能信号
reg [WIDTH-1:0]send_cnt;//发送计数器
//一位起始位0,8位ASCII码，一位停止位1
initial begin
    busy <= 1'b0;
    cnt <= 4'd0;
    sfg = 9'b1_1111_1111;
	 send_en <= 1'b0;
	 send_cnt <= 1'b0;
end

always @(posedge clk)
begin
    if(rst)begin
        busy <= 1'b0;
        sfg = 9'b1_1111_1111;
        cnt <= 4'd0; 
		  send_en <= 1'b0;
		  send_cnt <= 1'b0;
    end else begin
        if({busy,data_en}==2'b01)begin
            sfg[8:0] <= {data_in[7:0],1'b0};//加在起始位0，并设置busy标志
            busy <= 1'b1;
            cnt <= 4'd0; 
				send_cnt <= 1'b0;
        end else  if(send_cnt==DIV_NUM)begin
		  //当send_cnt达到DIV_NUM时，表示一个位周期结束
		      send_cnt <= 1'b0;
            if(cnt == 4'd8+STOP)begin
				//当cnt达到8加上STOP时，表示一个字节发送完成，消除忙信号
                cnt <= 4'd0; 
                busy <= 1'b0;//发送完成，消除忙信号
            end else begin
                cnt <= cnt + 4'd1;                
            end
            sfg[8:0] <= {1'b1,sfg[8:1]};//从低位到高位逐次发送
		  end else begin
				send_cnt <= send_cnt + 1'b1;
        end
    end
end

assign tx = sfg[0];//输出当前要发送的位

endmodule 