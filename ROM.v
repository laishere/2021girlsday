module rom(clk, addr, dout);

	input clk; 
	input[10:0] addr;
	output reg[7:0] dout;
	
	reg[7:0] mem[32 * 4 * 6 - 1 : 0];
	
	initial begin
		$readmemh("mem.txt", mem);
	end
	
	always @(posedge clk) begin
		dout <= mem[addr];
	end

endmodule