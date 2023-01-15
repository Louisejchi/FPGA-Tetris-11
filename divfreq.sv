// for Display
module divfreqForDisplay (input CLK, output reg CLK_div);
	reg [24:0] Count;
	always @(posedge CLK)begin
		if (Count > 2500) begin
			Count <= 25'b0;
			CLK_div <= ~CLK_div;
		end
		else	Count <= Count + 1'b1;
    end

endmodule

// for drop
module divfreqForDrop (input CLK, output reg CLK_div);
	reg [24:0] Count;
	always @(posedge CLK)begin
		if (Count > 25000000) begin
			Count <= 25'b0;
			CLK_div <= ~CLK_div;
		end
		else	Count <= Count + 1'b1;
    end

endmodule

// for start animation
module divfreqForStart (input CLK, output reg CLK_div);
	reg [24:0] Count;
	always @(posedge CLK)begin
		if (Count > 25000000) begin
			Count <= 25'b0;
			CLK_div <= ~CLK_div;
		end
		else	Count <= Count + 1'b1;
    end

endmodule
