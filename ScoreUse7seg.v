module score( 	input enable, input [13:0] count, input CLK,
					output reg [6:0] seg7, output reg [3:0] COM); // 7-seg
	divfreq FO (CLK, CLK_div);
	parameter logic [6:0] number [0:9] = '{
		7'b0000001,
		7'b1001111,
		7'b0010010,
		7'b0000110,
		7'b1001100,
		7'b0100100,
		7'b0100000,
		7'b0001111,
		7'b0000000,
		7'b0000100
	};
	reg [13:0] score;
	reg [3:0] num [3:0];
	
	initial begin
		reg [13:0] score = 0;
		COM = 4'b1110;
		seg7 = 7'b0000001;
	end
	
	// score++
	always @(count) begin
		if (score >= 9999) score = 0;
		else score = count; //score + 25 * count;
		
		num[3] = score / 1000;
		num[2] = score / 100 - num[3] * 10;
		num[1] = score / 10 - num[3] * 100 - num[2] * 10;
		num[0] = score % 10;
	end
 
	// display  on 7-seg
	always @(posedge CLK_div) begin
		case(COM)
			4'b1110: COM <= 4'b1101;
			4'b1101: COM <= 4'b1011;
			4'b1011: COM <= 4'b0111;
			4'b0111: COM <= 4'b1110;
		endcase
		case(COM)
			4'b1011: seg7 <= number[num[0]];
			4'b1101: seg7 <= number[num[1]];
			4'b1110: seg7 <= number[num[2]];
			4'b0111: seg7 <= number[num[3]];
			default: seg7 <= 7'b1111111;
		endcase
	end
 
endmodule

module divfreq (input CLK, output reg CLK_div);
	reg [24:0] Count;
	always @(posedge CLK)begin
		if (Count > 2500) begin
			Count <= 25'b0;
			CLK_div <= ~CLK_div;
		end
		else Count <= Count + 1'b1;
	end

endmodule