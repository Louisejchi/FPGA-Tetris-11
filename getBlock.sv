module getBlock(	input enable, CLK,
						output [2:0] num);
	
	always@(posedge enable) begin
		if(enable == 1) begin
			num = count;
		end
		
	end
	
	// get seed
	reg [2:0] count;
	always@(posedge CLK)
		if (count >= 6)	count <= 0;
		else	count <= count + 1'b1;
	
endmodule
/*
module t(input enable, reset, CLK, // enable -> clock, CLK -> PIN_22
						output reg [6:0] seg7);
		wire [2:0] num;
		getBlock S(enable, reset, CLK, num);
		always@(posedge enable)
			case(num)
				3'b000: seg7 = 7'b0000001;
            3'b001: seg7 = 7'b1001111;
            3'b010: seg7 = 7'b0010010;
            3'b011: seg7 = 7'b0000110;
            3'b100: seg7 = 7'b1001100;
            3'b101: seg7 = 7'b0100100;
            3'b110: seg7 = 7'b0100000;
				default: seg7 = 7'b1111101;
			endcase
			
endmodule
*/