`timescale 1ns/1ps
module sim_cal();

	reg clk;
	reg reset;
	reg [7:0]rx_data;
	reg data_en;
	reg busy;
	wire [7:0]tx_data;
	wire tx_data_en;

	initial begin
		reset <= 1'b1;
		clk <= 1'b0;
		rx_data <= 1'b0;
		data_en <= 1'b0;
		busy <= 1'b0;
		#100
		
		reset <= 1'b0;
		data_en <= 1'b1;
		rx_data <= 8'h32;//数字2
		#10
		
		data_en <= 1'b0;
		#100
		
		data_en <= 1'b1;
		rx_data <= 8'h31;//数字1
		#10
		
		data_en <= 1'b0;
		#100
		
		data_en <= 1'b1;
		rx_data <= 8'h34;//数字4
		#10
		
		data_en <= 1'b0;
		#100
		
		data_en <= 1'b1;
		rx_data <= 8'h37;//数字7
		#10
		
		data_en <= 1'b0;
		#100
		
		data_en <= 1'b1;
		rx_data <= 8'h34;//数字4
		#10
		
		data_en <= 1'b0;
		#100
		
		data_en <= 1'b1;
		rx_data <= 8'h38;//数字8
		#10
		
		data_en <= 1'b0;
		#100
		
		data_en <= 1'b1;
		rx_data <= 8'h33;//数字3
		#10
		
		data_en <= 1'b0;
		#100
		
		data_en <= 1'b1;
		rx_data <= 8'h36;//数字6
		#10
		
		data_en <= 1'b0;
		#100
		
		data_en <= 1'b1;
		rx_data <= 8'h34;//数字4
		#10
		
		data_en <= 1'b0;
		#100
		
		data_en <= 1'b1;
		rx_data <= 8'h38;//数字8
		#10
		
		data_en <= 1'b0;
		#100
		
		data_en <= 1'b1;
		rx_data <= 8'h2A;//乘法
		#10
		
		data_en <= 1'b0;
		#100
		
		data_en <= 1'b1;
		rx_data <= 8'h2D;//负号
		#10
		
		data_en <= 1'b0;
		#100
		
		data_en <= 1'b1;
		rx_data <= 8'h32;//数字2
		#10
		
		data_en <= 1'b0;
		#100
		
		data_en <= 1'b1;
		rx_data <= 8'h31;//数字1
		#10
		
		data_en <= 1'b0;
		#100
		
		data_en <= 1'b1;
		rx_data <= 8'h34;//数字4
		#10
		
		data_en <= 1'b0;
		#100
		
		data_en <= 1'b1;
		rx_data <= 8'h37;//数字7
		#10
		
		data_en <= 1'b0;
		#100
		
		data_en <= 1'b1;
		rx_data <= 8'h34;//数字4
		#10
		
		data_en <= 1'b0;
		#100
		
		data_en <= 1'b1;
		rx_data <= 8'h38;//数字8
		#10
		
		data_en <= 1'b0;
		#100
		
		data_en <= 1'b1;
		rx_data <= 8'h33;//数字3
		#10
		
		data_en <= 1'b0;
		#100
		
		data_en <= 1'b1;
		rx_data <= 8'h36;//数字6
		#10
		
		data_en <= 1'b0;
		#100
		
		data_en <= 1'b1;
		rx_data <= 8'h34;//数字4
		#10
		
		data_en <= 1'b0;
		#100
		
		data_en <= 1'b1;
		rx_data <= 8'h38;//数字8
		#10
		
		data_en <= 1'b0;
		#100
		
		data_en <= 1'b1;
		rx_data <= 8'h3D;//等号
		#10
		
		data_en <= 1'b0;
		
		
		
	end
	always #5 clk <= ~clk;
	always @(posedge clk)begin
		if(tx_data_en==1'b1)begin
		   #20
			busy <= 1'b1;
			#100
			busy <= 1'b0;
		end
	end
	calculator UUT(
		.clk(clk),
		.reset(reset),
		.data_en(data_en),
		.busy(busy),
		.rx_data(rx_data),//接收数据
		.tx_data(tx_data),//发送数据
		.tx_en(tx_data_en)//发送使能信号
	);
	
endmodule    