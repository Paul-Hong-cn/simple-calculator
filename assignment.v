module assignment(
	input wire clk,
	input wire rxd,
	
	output txd
	
);
reg reset ;
wire rx_data_en;
wire [7:0] trans_data;
wire [7:0] result_data;
wire tx_en;
wire busy;


uart_receive inst3(
		.clk(clk),
		.rx(rxd),
		.data_en(rx_data_en),
		.data_out(trans_data)
);
calculator inst4(
		.clk(clk),
		.reset(reset),
		.data_en(rx_data_en),
		.busy(busy),
		.rx_data(trans_data),
		.tx_data(result_data),
		.tx_en(tx_en)
);
uart_send inst5(
		.clk(clk),
		.rst(1'b0),
		.data_in(result_data),
		.data_en(tx_en),
		.tx(txd),
		.busy(busy)
);  
endmodule 