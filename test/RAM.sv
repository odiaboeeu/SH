module RAM
#(
	parameter bios_file = "",
	parameter rom_file = ""
)
(
	input         CLK,
	input         RST_N,
	
	input   [1:0] DSZ,
	
	input  [26:0] WADDR,
	input  [31:0] DI,
	input   [3:0] WE,
	
	input  [26:0] RADDR,
	output [31:0] DO
);

	// synopsys translate_off
	`define SIM
	// synopsys translate_on
	
`ifdef SIM
	
	reg [15:0] MEM [256] = '{
		16'h0000,	//PCL
		16'h0070,	//PCH
		16'h0600,	//SRL
		16'h0000,	//SRH
		16'h0000,	//PCL
		16'h0070,	//PCH
		16'h0600,	//SRL
		16'h0000,	//SRH
		//10
		16'b1110_0011_00110100,		//MOV		#$34,R3
		16'b1110_0100_00101100,		//MOV		#$2C,R4
		16'b0010_1111_0011_0110,	//MOV.L  R3,@-R15
		16'b0010_1111_0100_0110,	//MOV.L  R4,@-R15
		16'b0100_1111_0001_0010,	//STS.L  MACL,@-R15
		16'b0100_1111_0010_0010,	//STS.L  PR,@-R15
		16'b0000_0000_0000_1001,	//NOP
		16'b0000_0000_0000_1001,	//NOP
		//20
		16'b1110_0010_01010000,		//MOV		#$50,R2
		16'b1110_0011_01110000,		//MOV		#$70,R3
		16'b0000_0000_0010_1000,	//CLRMAC
		16'b0000_0011_0010_1111,	//MAC.L  @R2+,@R3+
		16'b0000_0000_0000_1001,	//NOP
		16'b0000_0011_0010_1111,	//MAC.L  @R2+,@R3+
		16'b0000_0000_0000_1001,	//NOP
		16'b0000_0011_0010_1111,	//MAC.L  @R2+,@R3+
		//30
		16'b1110_0001_01010000,		//MOV		#$50,R1
		16'b0000_0000_0000_1001,	//NOP
		16'b1001_0000_00000010,		//MOV.W	@(#2,PC),R0
		16'b0000_0001_0001_1110,	//MOV.L  @(R0,R1),R1
		16'b0000_0000_0000_1001,	//NOP
		16'b0100_0001_0000_1010,	//LDS    R1,MACH
		16'b0000_0000_0000_1000,	//NOP
		16'b0000_0000_0000_1000,	//NOP
		//40
		16'b1000_1101_00000010,		//BT/S	#2
		16'b1110_0000_11111111,		//MOV		#$FF,R0
		16'b1000_1111_00000010,		//BF/S	#2
		16'b1110_0001_00011000,		//MOV		#$18,R1
		16'b0000_0000_0000_1001,	//NOP
		16'b0000_0000_0000_1001,	//NOP
		16'b1110_0010_00110100,		//MOV		#$34,R2
		16'b1110_0011_10011010,		//MOV		#$9A,R3
		//50
		16'b1110_0000_00100000,		//MOV		#20,R0
		16'b0110_1111_0000_0011,	//MOV		R0,R15
		16'b1110_0000_00000000,		//MOV		#00,R0
		16'b0100_0000_0000_1110,	//LDC    R0,SR
		16'b1110_0001_00010001,		//MOV		#11,R1
		16'b1110_0010_00010010,		//MOV		#12,R2
		16'b1110_0011_00010011,		//MOV		#13,R3
		16'b1000_1011_11111100,		//BF		#FC
		//60
		16'b1110_0000_00010000,		//MOV		#10,R0
		16'b1110_0001_00110100,		//MOV		#34,R1
		16'b0000_0000_0000_1001,	//NOP
		16'b0000_0000_0000_1001,	//NOP
		16'b0000_0000_0000_1001,	//NOP
		16'b0000_0000_0000_1001,	//NOP
		16'b0000_0000_0010_1011,	//RTE
		16'b0000_0000_0000_1001,	//NOP
		//70
		16'b1110_0000_00010000,		//MOV		#10,R0
		16'b1110_0001_00110100,		//MOV		#34,R1
		16'b0000_0001_0111_1100,	//MOV.B  @(R0,R7),R1
		16'b0011_0001_0011_0000,	//CMP/EQ R3,R1
		16'b1010_000000000001,		//BRA  	#1
		16'b0000_0000_0001_0111,	//MUL.L  R1,R0
		16'b0000_0000_0000_1001,	//NOP
		16'b0000_0001_0001_1010,	//STS		MACL,r1
		//80
		16'b1110_0011_01111000,		//MOV		#78,R3
		16'b1110_0010_01110100,		//MOV		#74,R2
		16'b1110_0001_01110000,		//MOV		#70,R1
		16'b0000_0000_0000_1001,	//NOP
		16'b0010_0001_0001_0010,	//MOV.L	R1,@R1
		16'b0010_0010_0010_0001,	//MOV.W	R2,@R2
		16'b0010_0011_0011_0000,	//MOV.B	R3,@R3
		16'b0000_0000_0000_1001,	//NOP
		16'b0000_0000_0000_1001,	//NOP
		16'b0110_0000_0001_0010,	//MOV.L	@R1,R0
		16'b0110_0011_0000_0011,	//MOV		R0,R3
		16'b0110_0001_0010_0101,	//MOV.W	@R2+,R1
		16'b0110_0001_0010_0100,	//MOV.B	@R2+,R1
		16'b1101_0010_00001000,		//MOV.L	@(8,PC),R2
		16'b1001_0010_00001000,		//MOV.W	@(8,PC),R2
		16'b1100_0111_00001000,		//MOVA	@(8,PC),R0
		//A0
		16'b0000_0001_0010_1110,	//MOV.L	@(R0,R2),R1
		16'b0000_0010_0011_0110,	//MOV.L	R3,@(R0,R2)
		16'b1000_0101_0010_0100,	//MOV.W	@(4,R2),R0
		16'b1000_0001_0011_0100,	//MOV.W	R0,@(4,R3)
		16'b0101_0001_0010_0100,	//MOV.L	@(4,R2),R1
		16'b0001_0010_0011_0100,	//MOV.L	R3,@(4,R2)
		16'b0000_0000_0000_1001,	//NOP
		16'b0000_0000_0000_1001,	//NOP
		16'b0000_0000_0000_1001,	//NOP
		16'b0000_0000_0000_1001,	//NOP
		16'b0000_0000_0000_1001,	//NOP
		16'b0000_0000_0000_1001,	//NOP
		16'b0000_0000_0000_1001,	//NOP
		16'b0000_0000_0000_1001,	//NOP
		16'b0000_0000_0000_1001,	//NOP
		16'b0000_0000_0000_1001,	//NOP
		//C0
		16'b1110_0001_10000000,		//MOV		#80,R1
		16'b0110_0001_0001_1100,	//EXTU.B	R1,R1
		16'b0011_1000_0001_1100,	//MOV		R1,R8
		16'b1110_0001_01110000,		//MOV		#70,R1
		16'b0011_1001_0001_1100,	//MOV		R1,R9
		16'b1110_0010_0000_0100,	//MOV		#04,R2
		16'b0110_0001_1000_0110,	//MOV.L	@R8+,R1
		16'b0010_1001_0001_0010,	//MOV.L	R1,@R9
		16'b0000_0000_0000_1001,	//NOP
		16'b0000_0000_0000_1001,	//NOP
		16'b0000_0000_0000_1001,	//NOP
		16'b0000_0000_0000_1001,	//NOP
		16'b0000_0000_0000_1001,	//NOP
		16'b0000_0000_0000_1001,	//NOP
		16'b0000_0000_0000_1001,	//NOP
		16'b0000_0000_0000_1001,	//NOP
		//E0
		16'h1111,
		16'h2222,
		16'h3333,
		16'h4444,
		16'h5555,
		16'h6666,
		16'h7777,
		16'h8888,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		//100
		16'h0000,
		16'h0060,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		//120
		16'h1111,
		16'h2222,
		16'h3333,
		16'h4444,
		16'h5555,
		16'h6666,
		16'h7777,
		16'h8888,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		//140
		16'h1111,
		16'h2222,
		16'h3333,
		16'h4444,
		16'h5555,
		16'h6666,
		16'h7777,
		16'h8888,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		//160
		16'h1111,
		16'h2222,
		16'h3333,
		16'h4444,
		16'h5555,
		16'h6666,
		16'h7777,
		16'h8888,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		//180
		16'h1111,
		16'h2222,
		16'h3333,
		16'h4444,
		16'h5555,
		16'h6666,
		16'h7777,
		16'h8888,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		//10
		16'h1111,
		16'h2222,
		16'h3333,
		16'h4444,
		16'h5555,
		16'h6666,
		16'h7777,
		16'h8888,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		//10
		16'h1111,
		16'h2222,
		16'h3333,
		16'h4444,
		16'h5555,
		16'h6666,
		16'h7777,
		16'h8888,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		//1E0
		16'h8888,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h0000,
		16'h1111,
		16'h2222,
		16'h3333,
		16'h4444,
		16'h5555,
		16'h6666,
		16'h7777
		
		};
	
	always @(posedge CLK or negedge RST_N) begin
		bit [31:0] temp;
		if (!RST_N) begin
			
		end
		else begin
			temp[ 7: 0] = WE[0] ? DI[ 7: 0] : DO[ 7: 0];
			temp[15: 8] = WE[1] ? DI[15: 8] : DO[15: 8];
			temp[23:16] = WE[2] ? DI[23:16] : DO[23:16];
			temp[31:24] = WE[3] ? DI[31:24] : DO[31:24];
			case (DSZ)
				2'b00: 
					case (WADDR[1:0])
						2'b00: if (WE[0]) MEM[{WADDR[11:2],1'b0}][15:8] <= DI[7:0];
						2'b01: if (WE[0]) MEM[{WADDR[11:2],1'b0}][ 7:0] <= DI[7:0];
						2'b10: if (WE[0]) MEM[{WADDR[11:2],1'b1}][15:8] <= DI[7:0];
						2'b11: if (WE[0]) MEM[{WADDR[11:2],1'b1}][ 7:0] <= DI[7:0];
					endcase
					
				2'b01: 
					case (WADDR[1])
						1'b0: begin
							if (WE[1]) MEM[{WADDR[11:2],1'b0}][15:8] <= DI[15:8];
							if (WE[0]) MEM[{WADDR[11:2],1'b0}][ 7:0] <= DI[7:0];
						end
						1'b1: begin
							if (WE[1]) MEM[{WADDR[11:2],1'b1}][15:8] <= DI[15:8];
							if (WE[0]) MEM[{WADDR[11:2],1'b1}][ 7:0] <= DI[7:0];
						end
					endcase
					
				default: begin
					if (WE[3]) MEM[{WADDR[11:2],1'b0}][15:8] <= DI[31:24];
					if (WE[2]) MEM[{WADDR[11:2],1'b0}][ 7:0] <= DI[23:16];
					if (WE[1]) MEM[{WADDR[11:2],1'b1}][15:8] <= DI[15:8];
					if (WE[0]) MEM[{WADDR[11:2],1'b1}][ 7:0] <= DI[7:0];
				end
			endcase
		end
	end
		
	assign DO = DSZ == 2'b00 ? {24'h000000,(!RADDR[0] ? MEM[RADDR[11:1]][15:8] : MEM[RADDR[11:1]][7:0])} :
	            DSZ == 2'b01 ? {16'h0000,MEM[RADDR[11:1]]} :
	            {MEM[{RADDR[11:2],1'b0}],MEM[{RADDR[11:2],1'b1}]};
	
`elsif SIM2

	reg [15:0] MEM [(128*1024*1024)/2];
	initial begin
		$readmemh(bios_file, MEM);
		$readmemh(rom_file, MEM, 'h2000000/2, ('h2400000/2)-1);
	end
		
	always @(posedge CLK or negedge RST_N) begin
		bit [15:0] temp;
		if (!RST_N) begin

		end
		else begin
			temp[ 7: 0] = WE[0] ? DI[ 7: 0] : DO[ 7: 0];
			temp[15: 8] = WE[1] ? DI[15: 8] : DO[15: 8];
			if (WE) begin
				MEM[WADDR[26:1]] <= temp;
			end
		end
	end
	
	assign DO = MEM[RADDR[26:1]];
	
`else
	
	

	
	
`endif

endmodule
