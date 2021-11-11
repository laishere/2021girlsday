module ram_shifting(clk, rst, ram_dout, ram_clk, ram_we, ram_addr, ram_din, done);
	input clk, rst;
	input[7:0] ram_dout;
	output reg ram_clk, ram_we;
	output reg[7:0] ram_addr;
	output reg[7:0] ram_din;
	output reg done;
	
	parameter max_col = 3'd7;
	parameter max_line = 5'd31;
	
	reg[3:0] state;
	reg cr;
	reg[7:0] ram_addr0;
	
	always @(ram_addr0) begin
	/* 地址译码逻辑
	默认编址（3位列号 + 5位行号）
	0 2
	1 3
	--------
	移位编址（5位行号 + 3位列号的取反）
	1 0
	3 2
	*/
	ram_addr <= {~ram_addr0[2:0], ram_addr0[7:3]};
	end
	
	always @(posedge clk or negedge rst) begin
		if (!rst) begin
			state <= 0;
			ram_addr0 <= 3; // 注意并不是从0开始，因为是从第5列开始，下标为4(100)，取反为3(011)
			ram_clk <= 0;
			ram_we <= 0;
			cr <= 0;
			done <= 0;
		end
		
		else begin
			case (state)
			
			0:begin
				ram_clk <= 1;
				state <= 1;
			end
			
			1:begin
				ram_clk <= 0;
				ram_din <= {ram_dout[6:0], cr};
				state <= 2;
			end
			
			2:begin
				cr <= ram_dout[7];
				ram_we <= 1;
				state <= 3;
			end
			
			3:begin
				ram_clk <= 1;
				state <= 4;
			end
			
			4:begin
				ram_clk <= 0;
				ram_we <= 0;
				state <= 0;
				if (ram_addr0[2:0] == max_col) begin
					if (ram_addr0[7:3] == max_line)
						done <= 1;
					else
						ram_addr0 <= {ram_addr0[7:3] + 1'b1, 3'd3};
						cr <= 0;
				end
				else begin
					ram_addr0 <= ram_addr0 + 1'b1;
				end
			end

			endcase
		end
	end
endmodule