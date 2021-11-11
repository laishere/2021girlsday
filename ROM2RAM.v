module rom2ram(clk, rst, mode, rom_dout, rom_clk, ram_clk, ram_we, ram_din, rom_addr, ram_addr, done);
	input clk, rst, mode;
	input[7:0] rom_dout;
	output reg rom_clk, ram_clk, ram_we;
	output[7:0] ram_din;
	output reg[10:0] rom_addr;
	output reg[7:0] ram_addr;
	output reg done;
	
	parameter ram_last_col_first_addr = 8'd128;
	parameter max_rom_addr = 11'd767;
	parameter max_ram_addr = 8'd159;
	
	reg[2:0] state;
	
	assign ram_din = rom_dout;
	
	initial begin
		rom_addr <= 0;
	end
	
	always @(posedge clk or negedge rst) begin
		if (!rst) begin
			rom_clk <= 0;
			ram_clk <= 0;
			done <= 0;
			state <= 0;
			if (mode == 0)
				ram_addr <= 0;
			else
				ram_addr <= ram_last_col_first_addr; // 最后一列的首地址
		end
		else begin
			case (state)
			
			0:begin
				rom_clk <= 1;
				state <= 1;
			end
			
			1:begin
				rom_clk <= 0;
				ram_we <= 1;
				state <= 2;
			end
			
			2:begin
				ram_clk <= 1;
				state <= 3;
			end
			
			3:begin
				ram_clk <= 0;
				ram_we <= 0;
				if (rom_addr == max_rom_addr)
					rom_addr <= 0;
				else
					rom_addr <= rom_addr + 1'b1;
					
				if (ram_addr == max_ram_addr)
					done <= 1;
				else
					ram_addr <= ram_addr + 1'b1;
				state <= 0;
			end
			
			endcase
		end
	end
	
endmodule