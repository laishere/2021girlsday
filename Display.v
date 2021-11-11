module display(clk, rst, ram_dout, dout, ram_clk, ram_we, ram_addr, done, synced);
	input[7:0] ram_dout;
	output[7:0] dout;
	output reg[7:0] ram_addr;
	output reg ram_clk, ram_we;
	output reg done;
	output reg synced;
	input clk, rst;
	
	assign dout = ram_dout;
	
	parameter max_ram_addr = 8'd127;

	reg state;
	
	initial ram_we = 0;
	
	always @(posedge clk or negedge rst) begin
		if (!rst) begin
			ram_addr <= 0;
			state <= 0;
			ram_clk <= 0;
			done <= 0;
		end
		else begin
			case (state)
			0: begin
				ram_clk <= 1;
				state <= 1;
				synced <= 0;
			end
			1:begin
				ram_clk <= 0;
				synced <= 1;
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