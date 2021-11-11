module LED(clk, sout, dout, synced);
	input clk;
	output[3:0] sout;
	output[7:0] dout;
	output synced;

	wire rom_clk;
	wire[10:0] rom_addr;
	wire[7:0] rom_dout;
	
	reg ram_clk, ram_we;
	reg[7:0] ram_addr;
	reg[7:0] ram_din;
	wire[7:0] ram_dout;
	
	reg clk1, rst1, mode1;
	wire rom_clk1, ram_clk1, ram_we1;
	wire[7:0] ram_din1;
	wire[10:0] rom_addr1;
	wire[7:0] ram_addr1;
	wire done1;
	
	reg clk2, rst2;
	wire ram_clk2, ram_we2;
	wire[7:0] ram_addr2;
	wire[7:0] ram_din2;
	wire done2;
	
	reg clk3, rst3;
	wire ram_clk3, ram_we3;
	wire[7:0] ram_addr3;
	wire done3;
	
	reg[3:0] state;
	reg[3:0] shift_cnt;
	reg[2:0] prog;
	
	rom rom(
		.clk(rom_clk),
		.addr(rom_addr),
		.dout(rom_dout)
	);
	
	ram ram(
		.clk(ram_clk),
		.we(ram_we),
		.addr(ram_addr),
		.din(ram_din),
		.dout(ram_dout)
	);
	
	rom2ram prog1(
		.clk(clk1),
		.rst(rst1),
		.mode(mode1),
		.rom_addr(rom_addr1),
		.rom_dout(rom_dout),
		.rom_clk(rom_clk1),
		.ram_clk(ram_clk1),
		.ram_we(ram_we1),
		.ram_din(ram_din1),
		.ram_addr(ram_addr1),
		.done(done1)
	);
	
	ram_shifting prog2(
		.clk(clk2),
		.rst(rst2),
		.ram_clk(ram_clk2),
		.ram_we(ram_we2),
		.ram_addr(ram_addr2),
		.ram_din(ram_din2),
		.ram_dout(ram_dout),
		.done(done2)
	);
	
	display display(
		.clk(clk3),
		.rst(rst3),
		.ram_clk(ram_clk3),
		.ram_we(ram_we3),
		.ram_addr(ram_addr3),
		.ram_dout(ram_dout),
		.dout(dout),
		.done(done3),
		.synced(synced)
	);
	
	assign rom_clk = rom_clk1;
	assign rom_addr = rom_addr1;
	assign sout = state;
	
	initial begin
		state <= 0;
		shift_cnt <= 0;
		prog <= 0;
		clk1 <= 0;
		clk2 <= 0;
		mode1 <= 0;
		rst1 <= 1;
		rst2 <= 1;
		rst3 <= 1;
	end
	
	always @* begin
		case (prog)
		0:begin
			ram_clk <= ram_clk1;
			ram_we <= ram_we1;
			ram_addr <= ram_addr1;
			ram_din <= ram_din1;
		end
		
		2:begin
			ram_clk <= ram_clk2;
			ram_we <= ram_we2;
			ram_addr <= ram_addr2;
			ram_din <= ram_din2;
		end
		
		1:begin
			ram_clk <= ram_clk3;
			ram_we <= ram_we3;
			ram_addr <= ram_addr3;
			ram_din <= 0;
		end
		endcase
	end
	
	always @(posedge clk) begin
	
		case (state)
		 0:begin
			rst1 <= 0;
			clk1 <= 0;
			prog <= 0;
			state <= 1;
		end
		
		1:begin
			rst1 <= 1;
			state <= 2;
		end
		
		2:begin
			clk1 <= ~clk1;
			if (done1)
				state <= 3;
				mode1 <= 1;
		end
		
		3:begin
			if (shift_cnt != 4'd8)
				state <= 6;
			else begin
				shift_cnt <= 0;
				rst1 <= 0;
				clk1 <= 0;
				prog <= 0;
				state <= 4;
			end
		end
		
		4:begin
			rst1 <= 1;
			state <= 5;
		end
		
		5:begin
			clk1 <= ~clk1;
			if (done1)
				state <= 6;
		end
		
		6:begin
			prog <= 1;
			rst3 <= 0;
			clk3 <= 0;
			state <= 7;
		end
		
		7:begin
			rst3 <= 1;
			state <= 8;
		end
		
		8:begin
			clk3 <= ~clk3;
			if (done3)
				state <= 9;
		end
		
		9:begin
			rst2 <= 0;
			clk2 <= 0;
			prog <= 2;
			state <= 10;
		end
		
		10:begin
			rst2 <= 1;
			state <= 11;
		end
		
		11:begin
			clk2 <= ~clk2;
			if (done2) begin
				shift_cnt <= shift_cnt + 1'b1;
				state <= 3;
			end
		end
		
		endcase
	end
	
endmodule