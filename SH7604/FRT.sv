import SH7604_PKG::*;

module FRT (
	input             CLK,
	input             RST_N,
	input             CE_R,
	input             CE_F,
	
	input             RES_N,
	
	output reg        FTOA,
	output reg        FTOB,
	input             FTCI,
	input             FTI,
	
	input             CLK8_CE,
	input             CLK32_CE,
	input             CLK128_CE,
	
	input      [31:0] IBUS_A,
	input      [31:0] IBUS_DI,
	output     [31:0] IBUS_DO,
	input       [3:0] IBUS_BA,
	input             IBUS_WE,
	input             IBUS_REQ,
	output            IBUS_BUSY,
	output            IBUS_ACT,
	
	output            ICI_IRQ,
	output            OCIA_IRQ,
	output            OCIB_IRQ,
	output            OVI_IRQ
);

	FRC_t       FRC;
	OCR_t       OCRA;
	OCR_t       OCRB;
	FICR_t      ICR;
	TIER_t      TIER;
	FTCSR_t     FTCSR;
	TCR_t       TCR;
	TOCR_t      TOCR;
	
	//Clock selector
	bit         FRC_CE;
	always @(posedge CLK or negedge RST_N) begin
		bit         FTCI_OLD;
		
		if (!RST_N) begin
			FRC_CE <= 0;
			FTCI_OLD <= 0;
		end
		else if (CE_R) begin
			FTCI_OLD <= FTCI;
			case (TCR.CKS)
				2'b00: FRC_CE <= CLK8_CE;
				2'b01: FRC_CE <= CLK32_CE;
				2'b10: FRC_CE <= CLK128_CE;
				2'b11: FRC_CE <= FTCI & ~FTCI_OLD;
			endcase
		end
	end
	
	wire REG_SEL = (IBUS_A >= 32'hFFFFFE10 && IBUS_A <= 32'hFFFFFE19);
	wire FTCSR_WRITE = REG_SEL && IBUS_A[3:0] == 4'h1 && IBUS_WE && IBUS_REQ;
	always @(posedge CLK or negedge RST_N) begin
		if (!RST_N) begin
			FTCSR.OCFA <= 0;
			FTCSR.OCFB <= 0;
			FTCSR.OVF <= 0;
		end
		else if (CE_R) begin
			if (FRC_CE) begin
				if (FRC == OCRA) begin
					FTOA <= TOCR.OLVLA;
					FTCSR.OCFA <= 1;
				end
				if (FRC == OCRB) begin
					FTOB <= TOCR.OLVLB;
					FTCSR.OCFB <= 1;
				end
				
				if (FRC == 16'hFFFF) begin
					FTCSR.OVF <= 1;
				end
			end
			
			if (FTCSR_WRITE) begin
				if (!IBUS_DI[19] && FTCSR.OCFA) FTCSR.OCFA <= 0;
				if (!IBUS_DI[18] && FTCSR.OCFB) FTCSR.OCFB <= 0;
				if (!IBUS_DI[17] && FTCSR.OVF) FTCSR.OVF <= 0;
			end
		end
	end
	
	wire ICR_READ = REG_SEL && IBUS_A[3:0] == 4'h9 && !IBUS_WE && IBUS_REQ;
	always @(posedge CLK or negedge RST_N) begin
		bit         FTI_OLD;
		bit         CAPT;
		
		if (!RST_N) begin
			ICR <= 16'h0000;
			FTI_OLD <= 0;
			CAPT <= 0;
		end
		else if (CE_R) begin
			FTI_OLD <= FTI;
			CAPT <= (FTI ^ TCR.IEDG) & (~FTI_OLD ^ TCR.IEDG);
			
			if (ICR_READ && CAPT) begin
				CAPT <= 1;
			end
			else if (CAPT) begin
				ICR <= FRC;
				FTCSR.ICF <= 1;
			end
			
			if (FTCSR_WRITE) begin
				if (!IBUS_DI[23] && FTCSR.ICF) FTCSR.ICF <= 0;
			end
		end
	end
	
	assign ICI_IRQ = FTCSR.ICF & TIER.ICIE;
	assign OCIA_IRQ = FTCSR.OCFA & TIER.OCIAE;
	assign OCIB_IRQ = FTCSR.OCFB & TIER.OCIBE;
	assign OVI_IRQ = FTCSR.OVF & TIER.OVIE;
	
	//Registers
	always @(posedge CLK or negedge RST_N) begin
		bit [7:0] TEMP;
		
		if (!RST_N) begin
			TIER <= TIER_INIT;
			FRC  <= FRC_INIT;
			OCRA <= OCR_INIT;
			OCRB <= OCR_INIT;
			TCR  <= TCR_INIT;
			TOCR <= TOCR_INIT;
			FTCSR.CCLRA <= 0;
			FTCSR.UNUSED <= '0;
			// synopsys translate_off
			
			// synopsys translate_on
			TEMP <= 8'h00;
		end
		else if (CE_R) begin
			if (FRC_CE) begin
				FRC <= FRC + 16'd1;
			end
			
			if (!RES_N) begin
				TIER <= TIER_INIT;
				FRC  <= FRC_INIT;
				OCRA <= OCR_INIT;
				OCRB <= OCR_INIT;
				TCR  <= TCR_INIT;
				TOCR <= TOCR_INIT;
				FTCSR.CCLRA <= 0;
				FTCSR.UNUSED <= '0;
			end
			else if (REG_SEL && IBUS_WE && IBUS_REQ) begin
				case (IBUS_A[3:0])
					4'h0: TIER <= IBUS_DI[31:24] & TIER_WMASK;
					4'h1: FTCSR.CCLRA <= IBUS_DI[16];
					4'h2: TEMP <= IBUS_DI[15:8];
					4'h3: FRC <= {TEMP,IBUS_DI[7:0]} & FRC_WMASK;
					4'h4: TEMP <= IBUS_DI[31:24];
					4'h5: if (!TOCR.OCRS) OCRA <= {TEMP,IBUS_DI[23:16]} & OCR_WMASK; 
					      else OCRB <= {TEMP,IBUS_DI[23:16]} & OCR_WMASK;
					4'h6: TCR <= IBUS_DI[15:8] & TCR_WMASK;
					4'h7: TOCR <= (IBUS_DI[7:0] & TOCR_WMASK) | TOCR_INIT;
					default:;
				endcase
			end
			
			if (FRC == OCRA && FTCSR.CCLRA && FRC_CE) begin
				FRC <= 16'h0000;
			end
		end
	end
	
	bit [31:0] REG_DO;
	always @(posedge CLK or negedge RST_N) begin
		bit [7:0] TEMP;
		bit [31:0] OCR;
		
		if (!RST_N) begin
			REG_DO <= '0;
		end
		else if (CE_F) begin
			if (REG_SEL && !IBUS_WE && IBUS_REQ) begin
				OCR = !TOCR.OCRS ? OCRA : OCRB;
				case (IBUS_A[3:0])
					4'h0:       REG_DO <= {4{TIER & TIER_RMASK}};
					4'h1:       REG_DO <= {4{FTCSR & FTCSR_RMASK}};
					4'h2: begin REG_DO <= {4{FRC[15:8]}}; 
					            TEMP   <= FRC[7:0]; end
					4'h3:       REG_DO <= {4{TEMP}};
					4'h4: begin REG_DO <= {4{OCR[15:8]}}; 
					            TEMP   <= OCR[7:0]; end
					4'h5:       REG_DO <= {4{TEMP}};
					4'h6:       REG_DO <= {4{TCR & TCR_RMASK}};
					4'h7:       REG_DO <= {4{(TOCR & TOCR_RMASK) | TOCR_INIT}};
					4'h8:       REG_DO <= {4{TEMP}};
					4'h9: begin REG_DO <= {4{ICR[15:8]}}; 
					            TEMP   <= ICR[7:0]; end
					default:;
				endcase
			end
		end
	end
	
	assign IBUS_DO = REG_SEL ? REG_DO : 8'h00;
	assign IBUS_BUSY = 0;
	assign IBUS_ACT = REG_SEL;
	
endmodule
