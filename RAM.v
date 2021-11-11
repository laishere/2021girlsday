module ram(clk, addr, we, din, dout);
	input clk, we;
	input[7:0] addr;
	input[7:0] din;
	output reg[7:0] dout;
	
	reg[7:0] mem[32 * 5 - 1:0];
	
	always @(posedge clk) begin
		if (we)
			mem[addr] <= din;
		else
			dout <= mem[addr];
	end	
	
endmodule