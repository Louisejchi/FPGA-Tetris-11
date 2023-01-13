 module Tetris(input left, right, rotation, pause, CLK, // output 7-seg, 8x8, voice, CLK, start, pause
					output reg [0:7] LED_R, LED_G, LED_B,
					output reg [6:0] seg7,
					output reg [3:0] COMM, COM,
					output beep);
	// divide frequency
	wire CLK_div_display, CLK_div_drop;
	wire CLK_div_display_f, CLK_div_drop_f;
	divfreqForDisplay F0(CLK, CLK_div_display);
	divfreqForDrop F1(CLK, CLK_div_drop_f);
	// get a new block
	reg get_block_enable;
	reg [2:0] blocknum;
	reg drop_block_enable;
	getBlock(get_block_enable, CLK, blocknum);
	// get score
	reg clear_line;
	reg [2:0] score;
	initial clear_line = 0;
	initial score = 0;
	score S2(clear_line, score, CLK, seg7, COM);
	bit [2:0] cnt;
	// matrixs
	reg [0:7] matrix [0:7];
	reg [0:7] dropping_block_matrix [0:7];
	reg [7:0] new_block_address [3:0]; 
	reg [7:0] dropping_block_address [3:0]; // x[7:5], y[4:2], Rotation[1:0]
	initial begin
		matrix = '{
			8'b11111111,
			8'b11111111,
			8'b11111111,
			8'b11111111,
			8'b11111111,
			8'b11111111,
			8'b11111111,
			8'b11111111
		};
	
	end

	// get new block
	always@(posedge get_block_enable, posedge start_anime) begin
		if(get_block_enable == 1) begin
		if(~start_anime) begin
		drop_block_enable = 0;
		case(blocknum)
			3'b000: 	begin new_block_address[0] <= 8'b01000000; // I
								new_block_address[1] <= 8'b01100000;
								new_block_address[2] <= 8'b10000000;
								new_block_address[3] <= 8'b10100000;
						end
			3'b001:  begin new_block_address[0] <= 8'b01000000; // J
								new_block_address[1] <= 8'b01000100;
								new_block_address[2] <= 8'b01100100;
								new_block_address[3] <= 8'b10000100;
						end
			3'b010:  begin new_block_address[0] <= 8'b01000100; // L
								new_block_address[1] <= 8'b01100100;
								new_block_address[2] <= 8'b10000100;
								new_block_address[3] <= 8'b10000000;
						end
			3'b011:  begin new_block_address[0] <= 8'b01100000; // O
								new_block_address[1] <= 8'b01100100;
								new_block_address[2] <= 8'b10000000;
								new_block_address[3] <= 8'b10000100;
						end
			3'b100:  begin new_block_address[0] <= 8'b01000100; // S
								new_block_address[1] <= 8'b01100100;
								new_block_address[2] <= 8'b01100000;
								new_block_address[3] <= 8'b10000000;
						end
			3'b101:  begin new_block_address[0] <= 8'b01000100; // T
								new_block_address[1] <= 8'b01100100;
								new_block_address[2] <= 8'b01100000;
								new_block_address[3] <= 8'b10000100;
						end
			3'b110:  begin new_block_address[0] <= 8'b01000000; // Z
								new_block_address[1] <= 8'b01100100;
								new_block_address[2] <= 8'b01100000;
								new_block_address[3] <= 8'b10000100;
						end
		endcase
		drop_block_enable = 1;
		end
		end
	end
	
	
	task insertBlock;
		for(integer i = 0; i < 4; i++) matrix[dropping_block_address[i][4:2]][dropping_block_address[i][7:5]] = 0;
		if (matrix[7] == 8'b0 || matrix[6] == 8'b0 || matrix[5] == 8'b0 || matrix[4] == 8'b0 || matrix[3] == 8'b0 || matrix[2] == 8'b0 || matrix[1] == 8'b0 || matrix[0] == 8'b0)
			step = 3;
		else 	get_block_enable = 1;
	endtask
	task clearLine;
		if (matrix[7] == 8'b00000000) begin
			matrix[7] = 8'b11111111;
			for(integer i = 7; i > 0; i--) matrix[i] = matrix[i - 1];
			score = score + 1;
		end
		if (matrix[6] == 8'b00000000) begin
			matrix[6] = 8'b11111111;
			for(integer i = 6; i > 0; i--) matrix[i] = matrix[i - 1];
			score = score + 1;
		end
		if (matrix[5] == 8'b00000000) begin
			matrix[5] = 8'b11111111;
			for(integer i = 5; i > 0; i--) matrix[i] = matrix[i - 1];
			score = score + 1;
		end
		if (matrix[4] == 8'b00000000) begin
			matrix[4] = 8'b11111111;
			for(integer i = 4; i > 0; i--) matrix[i] = matrix[i - 1];
			score = score + 1;
		end
		if (matrix[3] == 8'b00000000) begin
			matrix[3] = 8'b11111111;
			for(integer i = 3; i > 0; i--) matrix[i] = matrix[i - 1];
			score = score + 1;
		end
		if (matrix[2] == 8'b00000000) begin
			matrix[2] = 8'b11111111;
			for(integer i = 2; i > 0; i--) matrix[i] = matrix[i - 1];
			score = score + 1;
		end
		if (matrix[1] == 8'b00000000) begin
			matrix[1] = 8'b11111111;
			for(integer i = 1; i > 0; i--) matrix[i] = matrix[i - 1];
			score = score + 1;
		end
		if (matrix[0] == 8'b00000000) begin
			matrix[0] = 8'b00000000;
			for(integer i = 7; i > 0; i--) matrix[i] = matrix[i - 1];
			score = score + 1;
			end
		clear_line = 1;
		
	endtask
	task dropBlock;
		for(integer i = 0; i < 4; i++) dropping_block_address[i][4:2] = dropping_block_address[i][4:2] + 1'b1;
	endtask
	task leftShift;
		for(integer i = 0; i < 4; i++) dropping_block_address[i][7:5] = dropping_block_address[i][7:5] - 1'b1;
	endtask
	task rightSift;
		for(integer i = 0; i < 4; i++) dropping_block_address[i][7:5] = dropping_block_address[i][7:5] + 1'b1;
	endtask
	reg [1:0] step;
				
	// the block constantly moves
	initial step = 0;
	wire start_anime;
	always@(posedge CLK_div_drop) begin
		if(~start_anime) begin
			if(get_block_enable && drop_block_enable) begin 
				dropping_block_address = new_block_address;
				for(integer i = 0; i < 8; i++) dropping_block_matrix[i] = 8'b11111111;
				for(integer i = 0; i < 4; i++) dropping_block_matrix[dropping_block_address[i][4:2]][dropping_block_address[i][7:5]] <= 0;
				get_block_enable = 0;
				step = 1;
			end
			else begin
				if(step == 1) begin
					step = 2;
				end
				else if(step == 3) begin
					clearLine();
					get_block_enable = 1;
				end
				else if(dropping_block_address[1][4:2] < 7 && step == 2 && CLK_div_drop) begin
					for(integer i = 0; i < 8; i++) dropping_block_matrix[i] = 8'b11111111;
					for(integer i = 0; i < 4; i++) dropping_block_matrix[dropping_block_address[i][4:2]][dropping_block_address[i][7:5]] <= 0;
					case(blocknum)
						3'b000: 	case(dropping_block_address[0][1:0]) // I
										2'b00,
										2'b10:	if( matrix[dropping_block_address[0][4:2] + 1][dropping_block_address[0][7:5]] &
																	matrix[dropping_block_address[1][4:2] + 1][dropping_block_address[1][7:5]] &
																	matrix[dropping_block_address[2][4:2] + 1][dropping_block_address[2][7:5]] &
																	matrix[dropping_block_address[3][4:2] + 1][dropping_block_address[3][7:5]] )
															dropBlock();
													else 	insertBlock();
										2'b01,
										2'b11:	if( matrix[dropping_block_address[1][4:2] + 1][dropping_block_address[1][7:5]] )
															dropBlock();
													else 	insertBlock();
									endcase
						3'b001: 	case(dropping_block_address[0][1:0]) // J
										2'b00: 	if( matrix[dropping_block_address[1][4:2] + 1][dropping_block_address[1][7:5]] &
																matrix[dropping_block_address[2][4:2] + 1][dropping_block_address[2][7:5]] &
																matrix[dropping_block_address[3][4:2] + 1][dropping_block_address[3][7:5]] )
															dropBlock();
													else 	insertBlock();
										2'b01: 	if( matrix[dropping_block_address[1][4:2] + 1][dropping_block_address[1][7:5]] &
																matrix[dropping_block_address[3][4:2] + 1][dropping_block_address[3][7:5]] )
															dropBlock();
													else 	insertBlock();
										2'b10: 	if( matrix[dropping_block_address[0][4:2] + 1][dropping_block_address[0][7:5]] &
																matrix[dropping_block_address[1][4:2] + 1][dropping_block_address[1][7:5]] &
																matrix[dropping_block_address[2][4:2] + 1][dropping_block_address[2][7:5]] )
															dropBlock();
													else 	insertBlock();
										2'b11: 	if( matrix[dropping_block_address[0][4:2] + 1][dropping_block_address[0][7:5]] &
																matrix[dropping_block_address[1][4:2] + 1][dropping_block_address[1][7:5]] )
															dropBlock();
													else 	insertBlock();
									endcase
						3'b010: 	case(dropping_block_address[0][1:0]) // L
										2'b00:	if( matrix[dropping_block_address[0][4:2] + 1][dropping_block_address[0][7:5]] &
																matrix[dropping_block_address[1][4:2] + 1][dropping_block_address[1][7:5]] &
																matrix[dropping_block_address[2][4:2] + 1][dropping_block_address[2][7:5]] )
															dropBlock();
													else 	insertBlock();
										2'b01: 	if( matrix[dropping_block_address[1][4:2] + 1][dropping_block_address[1][7:5]] &
																matrix[dropping_block_address[3][4:2] + 1][dropping_block_address[3][7:5]] )
															dropBlock();
													else 	insertBlock();
										2'b10: 	if( matrix[dropping_block_address[1][4:2] + 1][dropping_block_address[1][7:5]] &
																matrix[dropping_block_address[2][4:2] + 1][dropping_block_address[2][7:5]] &
																matrix[dropping_block_address[3][4:2] + 1][dropping_block_address[3][7:5]] )
															dropBlock();
													else 	insertBlock();
										2'b11: 	if( matrix[dropping_block_address[0][4:2] + 1][dropping_block_address[0][7:5]] &
																matrix[dropping_block_address[1][4:2] + 1][dropping_block_address[1][7:5]] )
															dropBlock();
													else 	insertBlock();
									endcase
						3'b011: 	/* O */		if( matrix[dropping_block_address[1][4:2] + 1][dropping_block_address[1][7:5]] & 
																matrix[dropping_block_address[3][4:2] + 1][dropping_block_address[3][7:5]] )
															dropBlock();
													else 	insertBlock();
						3'b100: 	case(dropping_block_address[0][1:0]) // S
										2'b00,
										2'b10: 	if( matrix[dropping_block_address[0][4:2] + 1][dropping_block_address[0][7:5]] &
																matrix[dropping_block_address[1][4:2] + 1][dropping_block_address[1][7:5]] &
																matrix[dropping_block_address[3][4:2] + 1][dropping_block_address[3][7:5]] )
															dropBlock();
													else 	insertBlock();
										2'b01,
										2'b11:	if( matrix[dropping_block_address[0][4:2] + 1][dropping_block_address[0][7:5]] &
																matrix[dropping_block_address[1][4:2] + 1][dropping_block_address[1][7:5]] )
															dropBlock(); 
													else 	insertBlock();
									endcase
						3'b101: 	case(dropping_block_address[0][1:0]) // T
										2'b00,
										2'b10: 	if( matrix[dropping_block_address[0][4:2] + 1][dropping_block_address[0][7:5]] &
																matrix[dropping_block_address[1][4:2] + 1][dropping_block_address[1][7:5]] &
																matrix[dropping_block_address[3][4:2] + 1][dropping_block_address[3][7:5]] )
															dropBlock();
													else 	insertBlock();
										2'b01: 	if( matrix[dropping_block_address[1][4:2] + 1][dropping_block_address[1][7:5]] &
																matrix[dropping_block_address[3][4:2] + 1][dropping_block_address[3][7:5]] )
															dropBlock();
													else 	insertBlock();
										2'b11: 	if( matrix[dropping_block_address[0][4:2] + 1][dropping_block_address[0][7:5]] &
																matrix[dropping_block_address[1][4:2] + 1][dropping_block_address[1][7:5]] )
															dropBlock();
													else 	insertBlock();
									endcase
						3'b110: 	case(dropping_block_address[0][1:0]) // Z
										2'b00,
										2'b10: 	if( matrix[dropping_block_address[0][4:2] + 1][dropping_block_address[0][7:5]] &
															matrix[dropping_block_address[1][4:2] + 1][dropping_block_address[1][7:5]] &
															matrix[dropping_block_address[3][4:2] + 1][dropping_block_address[3][7:5]] )
														dropBlock();
													else 	insertBlock();
										2'b01,
										2'b11: 	if( matrix[dropping_block_address[0][4:2] + 1][dropping_block_address[0][7:5]] &
															matrix[dropping_block_address[1][4:2] + 1][dropping_block_address[1][7:5]] )
														dropBlock();
													else 	insertBlock();
									endcase
					endcase	
				end
				else if(dropping_block_address[1][4:2] == 7) insertBlock();
			end

		// left shift
		if(left) begin
			if(dropping_block_address[0][7:5] > 0) begin 	
				case(blocknum)
				3'b000:  case(dropping_block_address[0][1:0]) // I
								2'b00,
								2'b10: 	if( matrix[dropping_block_address[0][4:2]][dropping_block_address[0][7:5]-1])
												leftShift();
								2'b01,
								2'b11:	if( matrix[dropping_block_address[0][4:2]][dropping_block_address[0][7:5]-1] &
													matrix[dropping_block_address[1][4:2]][dropping_block_address[1][7:5]-1] &
													matrix[dropping_block_address[2][4:2]][dropping_block_address[2][7:5]-1] &
													matrix[dropping_block_address[3][4:2]][dropping_block_address[3][7:5]-1] )
												leftShift();
							endcase
				3'b001:  case(dropping_block_address[0][1:0]) // J
								2'b00,
								2'b10:	if( matrix[dropping_block_address[0][4:2]][dropping_block_address[0][7:5]-1] &
													matrix[dropping_block_address[1][4:2]][dropping_block_address[1][7:5]-1] )
												leftShift();
								2'b01:	if( matrix[dropping_block_address[0][4:2]][dropping_block_address[0][7:5]-1] &
													matrix[dropping_block_address[1][4:2]][dropping_block_address[1][7:5]-1] &
													matrix[dropping_block_address[2][4:2]][dropping_block_address[2][7:5]-1] )
												leftShift();	
								2'b11:	if( matrix[dropping_block_address[0][4:2]][dropping_block_address[0][7:5]-1] &
													matrix[dropping_block_address[2][4:2]][dropping_block_address[2][7:5]-1] &
													matrix[dropping_block_address[3][4:2]][dropping_block_address[3][7:5]-1])
												leftShift();
							endcase
				3'b010:  case(dropping_block_address[0][1:0]) // L
								2'b00:	if( matrix[dropping_block_address[0][4:2]][dropping_block_address[0][7:5] - 1] &
													matrix[dropping_block_address[3][4:2]][dropping_block_address[3][7:5] - 1] )
												leftShift();		
								2'b01:	if( matrix[dropping_block_address[0][4:2]][dropping_block_address[0][7:5]-1] &
													matrix[dropping_block_address[2][4:2]][dropping_block_address[2][7:5]-1] &
													matrix[dropping_block_address[1][4:2]][dropping_block_address[1][7:5]-1] )
												leftShift();
								2'b10:	if( matrix[dropping_block_address[1][4:2] ][dropping_block_address[1][7:5]-1] &
													matrix[dropping_block_address[0][4:2]][dropping_block_address[0][7:5]-1] )
												leftShift();
								2'b11:	if( matrix[dropping_block_address[0][4:2] + 1][dropping_block_address[0][7:5]+1] &
													matrix[dropping_block_address[1][4:2]][dropping_block_address[1][7:5]+1] &
													matrix[dropping_block_address[3][4:2]][dropping_block_address[3][7:5]+1] )
												leftShift();
							endcase
				3'b011:  /* O */  	if( matrix[dropping_block_address[0][4:2] ][dropping_block_address[0][7:5]-1] & 
												matrix[dropping_block_address[2][4:2]][dropping_block_address[2][7:5]-1] )
											leftShift();
					
				3'b100:  case(dropping_block_address[0][1:0]) // S
								2'b00,
								2'b10:	if( matrix[dropping_block_address[0][4:2] ][dropping_block_address[0][7:5]-1] &
													matrix[dropping_block_address[2][4:2] ][dropping_block_address[2][7:5]-1] )
												leftShift();
								2'b01,	
								2'b11:	if( matrix[dropping_block_address[0][4:2]][dropping_block_address[0][7:5]-1] &
													matrix[dropping_block_address[2][4:2]][dropping_block_address[2][7:5]-1] &
													matrix[dropping_block_address[1][4:2]][dropping_block_address[1][7:5]-1] )
												leftShift(); 
							endcase	
				3'b101:  case(dropping_block_address[0][1:0]) // T
								2'b00:	if( matrix[dropping_block_address[2][4:2]][dropping_block_address[2][7:5]-1] &
													matrix[dropping_block_address[0][4:2]][dropping_block_address[0][7:5]-1] )
												leftShift();
								2'b01,	
								2'b11:	if( matrix[dropping_block_address[1][4:2]][dropping_block_address[1][7:5]-1] &
													matrix[dropping_block_address[2][4:2]][dropping_block_address[2][7:5]-1] &
													matrix[dropping_block_address[0][4:2]][dropping_block_address[0][7:5]-1] )
												leftShift();
								2'b10:	if( matrix[dropping_block_address[0][4:2]][dropping_block_address[0][7:5]-1] &
													matrix[dropping_block_address[1][4:2]][dropping_block_address[1][7:5]-1] )
												leftShift();
							endcase
				3'b110:  case(dropping_block_address[0][1:0]) // Z
								2'b00,
								2'b10:	if( matrix[dropping_block_address[0][4:2]][dropping_block_address[0][7:5]-1] &
													matrix[dropping_block_address[1][4:2]][dropping_block_address[1][7:5]-1])
												leftShift();
								2'b01,	
								2'b11:	if( matrix[dropping_block_address[0][4:2]][dropping_block_address[0][7:5]-1] &
													matrix[dropping_block_address[1][4:2]][dropping_block_address[2][7:5]-1] &
													matrix[dropping_block_address[3][4:2]][dropping_block_address[3][7:5]-1])
												leftShift();
							endcase
				endcase
			end
		end	
		
		// right shift
		if(right) begin
			if(dropping_block_address[3][7:5] < 7 ) begin 
				//rightSift;	
				case(blocknum)
					3'b000:  case(dropping_block_address[0][1:0]) // I
									2'b00,
									2'b10: 	if( matrix[dropping_block_address[3][4:2]][dropping_block_address[3][7:5]+1])
													rightSift();    
									2'b01,
									2'b11: 	if( matrix[dropping_block_address[0][4:2]][dropping_block_address[0][7:5]+1] &
														matrix[dropping_block_address[1][4:2]][dropping_block_address[1][7:5]+1] &
														matrix[dropping_block_address[2][4:2]][dropping_block_address[2][7:5]+1] &
														matrix[dropping_block_address[3][4:2]][dropping_block_address[3][7:5]+1] )
													rightSift();
								endcase
					3'b001:  case(dropping_block_address[0][1:0]) // J
									2'b00:	if( matrix[dropping_block_address[0][4:2]][dropping_block_address[0][7:5]+1] &
														matrix[dropping_block_address[3][4:2]][dropping_block_address[3][7:5]+1] )
													rightSift();
									2'b01:	if( matrix[dropping_block_address[0][4:2]][dropping_block_address[0][7:5]+1] &
														matrix[dropping_block_address[1][4:2]][dropping_block_address[1][7:5]+1] &
														matrix[dropping_block_address[3][4:2]][dropping_block_address[3][7:5]+1] )
													rightSift();
									2'b10:  	if( matrix[dropping_block_address[1][4:2]][dropping_block_address[1][7:5]+1] &
														matrix[dropping_block_address[3][4:2]][dropping_block_address[3][7:5]+1] )
													rightSift();
									2'b11:  	if( matrix[dropping_block_address[1][4:2]][dropping_block_address[1][7:5]+1] &
														matrix[dropping_block_address[2][4:2]][dropping_block_address[2][7:5]+1] &
														matrix[dropping_block_address[3][4:2]][dropping_block_address[3][7:5]+1])
													rightSift();
								endcase
					3'b010: 	case(dropping_block_address[0][1:0]) // L
									2'b00: 	if( matrix[dropping_block_address[2][4:2]][dropping_block_address[2][7:5] + 1] &
														matrix[dropping_block_address[3][4:2]][dropping_block_address[3][7:5] + 1] )
													rightSift();
									2'b01:  	if( matrix[dropping_block_address[0][4:2]][dropping_block_address[0][7:5]+1] &
														matrix[dropping_block_address[2][4:2]][dropping_block_address[2][7:5]+1] &
														matrix[dropping_block_address[3][4:2]][dropping_block_address[3][7:5]+1] )
													rightSift();
									2'b10:  	if( matrix[dropping_block_address[1][4:2] ][dropping_block_address[1][7:5]+1] &
														matrix[dropping_block_address[3][4:2]][dropping_block_address[3][7:5]+1] )
													rightSift();
									2'b11:  	if( matrix[dropping_block_address[0][4:2] + 1][dropping_block_address[0][7:5]+1] &
														matrix[dropping_block_address[1][4:2]][dropping_block_address[1][7:5]+1] )
													rightSift();
								endcase
					3'b011:  /* O */  	if( matrix[dropping_block_address[1][4:2] ][dropping_block_address[1][7:5]+1] & 
														matrix[dropping_block_address[3][4:2]][dropping_block_address[3][7:5]+1] )
													rightSift();
					3'b100:  case(dropping_block_address[0][1:0]) // S
									2'b00,
									2'b10:	if( matrix[dropping_block_address[1][4:2] ][dropping_block_address[1][7:5]+1] &
														matrix[dropping_block_address[3][4:2] ][dropping_block_address[3][7:5]+1] )
													rightSift();
									2'b01,
									2'b11: 	if( matrix[dropping_block_address[1][4:2]][dropping_block_address[1][7:5]+1] &
														matrix[dropping_block_address[2][4:2]][dropping_block_address[2][7:5]+1] &
														matrix[dropping_block_address[3][4:2]][dropping_block_address[3][7:5]+1] )
													rightSift(); 
								endcase
					3'b101:  case(dropping_block_address[0][1:0]) // T
									2'b00:  	if( matrix[dropping_block_address[2][4:2]][dropping_block_address[2][7:5]+1] &
														matrix[dropping_block_address[3][4:2]][dropping_block_address[3][7:5]+1] )
													rightSift();
									2'b01, 
									2'b11:  	if( matrix[dropping_block_address[1][4:2]][dropping_block_address[1][7:5]+1] &
														matrix[dropping_block_address[2][4:2]][dropping_block_address[2][7:5]+1] &
														matrix[dropping_block_address[3][4:2]][dropping_block_address[3][7:5]+1] )
													rightSift();	
									2'b10:  	if( matrix[dropping_block_address[3][4:2]][dropping_block_address[3][7:5]+1] &
														matrix[dropping_block_address[1][4:2]][dropping_block_address[1][7:5]+1] )
													rightSift();
								endcase
					3'b110:  case(dropping_block_address[0][1:0]) // Z
									2'b00,
									2'b10:  	if( matrix[dropping_block_address[2][4:2]][dropping_block_address[2][7:5]+1] &
														matrix[dropping_block_address[3][4:2]][dropping_block_address[3][7:5]+1] )
													rightSift();
									2'b01,
									2'b11:	if( matrix[dropping_block_address[0][4:2]][dropping_block_address[0][7:5]+1] &
														matrix[dropping_block_address[1][4:2]][dropping_block_address[2][7:5]+1] &
														matrix[dropping_block_address[3][4:2]][dropping_block_address[3][7:5]+1] )
													rightSift();
								endcase
				endcase
			end
		end	
		
		// rotation
		if(rotation) begin
			case(blocknum)
				3'b000: 	case(dropping_block_address[0][1:0]) // I
								2'b00 :	if(matrix[dropping_block_address[0][4:2]+1][dropping_block_address[0][7:5]+2] & 
												matrix[dropping_block_address[1][4:2]+2][dropping_block_address[1][7:5]+1] &
												matrix[dropping_block_address[2][4:2]][dropping_block_address[2][7:5]-1] &
												matrix[dropping_block_address[3][4:2]-1][dropping_block_address[3][7:5]]
												)begin
												dropping_block_address[0][7:5] = dropping_block_address[0][7:5] + 2;
												dropping_block_address[0][4:2] = dropping_block_address[0][4:2] + 1;
												dropping_block_address[1][7:5] = dropping_block_address[1][7:5] + 1;
												dropping_block_address[1][4:2] = dropping_block_address[1][4:2] + 2;
												dropping_block_address[2][7:5] = dropping_block_address[2][7:5] - 1;
												dropping_block_address[2][4:2] = dropping_block_address[2][4:2] ;
												dropping_block_address[3][7:5] = dropping_block_address[3][7:5] ;
												dropping_block_address[3][4:2] = dropping_block_address[3][4:2] - 1 ;
												dropping_block_address[0][1:0] = dropping_block_address[0][1:0] - 1;
												end
					
								2'b01 :	if(matrix[dropping_block_address[0][4:2]+2][dropping_block_address[0][7:5]-2] & 
												matrix[dropping_block_address[1][4:2]+1][dropping_block_address[1][7:5]-1] &
												matrix[dropping_block_address[2][4:2]][dropping_block_address[2][7:5]] &
												matrix[dropping_block_address[3][4:2]-1][dropping_block_address[3][7:5]+1]
												)begin
												dropping_block_address[0][7:5] = dropping_block_address[0][7:5] - 2;
												dropping_block_address[0][4:2] = dropping_block_address[0][4:2] + 2;
												dropping_block_address[1][7:5] = dropping_block_address[1][7:5] - 1;
												dropping_block_address[1][4:2] = dropping_block_address[1][4:2] + 1;
												dropping_block_address[2][7:5] = dropping_block_address[2][7:5];
												dropping_block_address[2][4:2] = dropping_block_address[2][4:2];
												dropping_block_address[3][7:5] = dropping_block_address[3][7:5] + 1;
												dropping_block_address[3][4:2] = dropping_block_address[3][4:2] - 1;
												dropping_block_address[0][1:0] = dropping_block_address[0][1:0] + 1;
												end
												
								2'b10 :	if(matrix[dropping_block_address[0][4:2]][dropping_block_address[0][7:5]+1] & 
												matrix[dropping_block_address[1][4:2]+1][dropping_block_address[1][7:5]] &
												matrix[dropping_block_address[2][4:2]-2][dropping_block_address[2][7:5]-1] &
												matrix[dropping_block_address[3][4:2]-1][dropping_block_address[3][7:5]-2]
												)begin
												dropping_block_address[0][7:5] = dropping_block_address[0][7:5] + 1;
												dropping_block_address[0][4:2] = dropping_block_address[0][4:2];
												dropping_block_address[1][7:5] = dropping_block_address[1][7:5];
												dropping_block_address[1][4:2] = dropping_block_address[1][4:2] + 1;
												dropping_block_address[2][7:5] = dropping_block_address[2][7:5] - 1;
												dropping_block_address[2][4:2] = dropping_block_address[2][4:2] - 2;
												dropping_block_address[3][7:5] = dropping_block_address[3][7:5] - 2;
												dropping_block_address[3][4:2] = dropping_block_address[3][4:2] - 1;
												dropping_block_address[0][1:0] = dropping_block_address[0][1:0] + 1;
												end
					
								2'b11 :	if(matrix[dropping_block_address[0][4:2]-1][dropping_block_address[0][7:5]-1] & 
											matrix[dropping_block_address[1][4:2]-2][dropping_block_address[1][7:5]] &
											matrix[dropping_block_address[2][4:2]+1][dropping_block_address[2][7:5]+1] &
											matrix[dropping_block_address[3][4:2]][dropping_block_address[3][7:5]+2]
											)begin
											dropping_block_address[0][7:5] = dropping_block_address[0][7:5] - 1;
											dropping_block_address[0][4:2] = dropping_block_address[0][4:2] - 1;
											dropping_block_address[1][7:5] = dropping_block_address[1][7:5];
											dropping_block_address[1][4:2] = dropping_block_address[1][4:2] - 2;
											dropping_block_address[2][7:5] = dropping_block_address[2][7:5] + 1;
											dropping_block_address[2][4:2] = dropping_block_address[2][4:2] + 1;
											dropping_block_address[3][7:5] = dropping_block_address[3][7:5] + 2;
											dropping_block_address[3][4:2] = dropping_block_address[3][4:2];
											dropping_block_address[0][1:0] = 0;
											end
							endcase
				3'b001:  case(dropping_block_address[0][1:0]) // J
								2'b00 :	if(matrix[dropping_block_address[0][4:2]+1][dropping_block_address[0][7:5]+1] & 
												matrix[dropping_block_address[1][4:2]+1][dropping_block_address[1][7:5]+1] &
												matrix[dropping_block_address[2][4:2]-1][dropping_block_address[2][7:5]] &
												matrix[dropping_block_address[3][4:2]-1][dropping_block_address[3][7:5]]
												)begin
												dropping_block_address[0][7:5] = dropping_block_address[0][7:5] + 1;
												dropping_block_address[0][4:2] = dropping_block_address[0][4:2] + 1;
												dropping_block_address[1][7:5] = dropping_block_address[1][7:5] + 1;
												dropping_block_address[1][4:2] = dropping_block_address[1][4:2] + 1;
												dropping_block_address[2][7:5] = dropping_block_address[2][7:5];
												dropping_block_address[2][4:2] = dropping_block_address[2][4:2] - 1;
												dropping_block_address[3][7:5] = dropping_block_address[3][7:5];
												dropping_block_address[3][4:2] = dropping_block_address[3][4:2] - 1;
												dropping_block_address[0][1:0] = dropping_block_address[0][1:0] + 1;
												end
					
								2'b01 :	if(matrix[dropping_block_address[0][4:2]][dropping_block_address[0][7:5]-1] & 
												matrix[dropping_block_address[1][4:2]][dropping_block_address[1][7:5]+1] &
												matrix[dropping_block_address[2][4:2]+1][dropping_block_address[2][7:5]] &
												matrix[dropping_block_address[3][4:2]+1][dropping_block_address[3][7:5]]
												)begin
												dropping_block_address[0][7:5] = dropping_block_address[0][7:5] - 1;
												dropping_block_address[0][4:2] = dropping_block_address[0][4:2];
												dropping_block_address[1][7:5] = dropping_block_address[1][7:5] + 1;
												dropping_block_address[1][4:2] = dropping_block_address[1][4:2];
												dropping_block_address[2][7:5] = dropping_block_address[2][7:5];
												dropping_block_address[2][4:2] = dropping_block_address[2][4:2] + 1;
												dropping_block_address[3][7:5] = dropping_block_address[3][7:5];
												dropping_block_address[3][4:2] = dropping_block_address[3][4:2] + 1;
												dropping_block_address[0][1:0] = dropping_block_address[0][1:0] + 1;
												end
												
								2'b10 :	if(matrix[dropping_block_address[0][4:2]+1][dropping_block_address[0][7:5]] & 
												matrix[dropping_block_address[1][4:2]][dropping_block_address[1][7:5]-1] &
												matrix[dropping_block_address[2][4:2]-1][dropping_block_address[2][7:5]] &
												matrix[dropping_block_address[3][4:2]][dropping_block_address[3][7:5]-1]
												)begin
												dropping_block_address[0][7:5] = dropping_block_address[0][7:5];
												dropping_block_address[0][4:2] = dropping_block_address[0][4:2] + 1;
												dropping_block_address[1][7:5] = dropping_block_address[1][7:5] - 1;
												dropping_block_address[1][4:2] = dropping_block_address[1][4:2];
												dropping_block_address[2][7:5] = dropping_block_address[2][7:5];
												dropping_block_address[2][4:2] = dropping_block_address[2][4:2] - 1;
												dropping_block_address[3][7:5] = dropping_block_address[3][7:5] - 1;
												dropping_block_address[3][4:2] = dropping_block_address[3][4:2];
												dropping_block_address[0][1:0] = dropping_block_address[0][1:0] + 1;
												end
											
								2'b11 :	if(matrix[dropping_block_address[0][4:2]-2][dropping_block_address[0][7:5]] & 
									matrix[dropping_block_address[1][4:2]-1][dropping_block_address[1][7:5]-1] &
									matrix[dropping_block_address[2][4:2]+1][dropping_block_address[2][7:5]] &
									matrix[dropping_block_address[3][4:2]][dropping_block_address[3][7:5]+1]
									)begin
									dropping_block_address[0][7:5] = dropping_block_address[0][7:5];
									dropping_block_address[0][4:2] = dropping_block_address[0][4:2] - 2;
									dropping_block_address[1][7:5] = dropping_block_address[1][7:5] - 1;
									dropping_block_address[1][4:2] = dropping_block_address[1][4:2] - 1;
									dropping_block_address[2][7:5] = dropping_block_address[2][7:5];
									dropping_block_address[2][4:2] = dropping_block_address[2][4:2] + 1;
									dropping_block_address[3][7:5] = dropping_block_address[3][7:5] + 1;
									dropping_block_address[3][4:2] = dropping_block_address[3][4:2];
									dropping_block_address[0][1:0] = 0;
									end
							endcase	
				3'b010:  case(dropping_block_address[0][1:0]) // L
								2'b00 :	if(matrix[dropping_block_address[0][4:2]][dropping_block_address[0][7:5]+1] & 
												matrix[dropping_block_address[1][4:2]+1][dropping_block_address[1][7:5]] &
												matrix[dropping_block_address[2][4:2]-1][dropping_block_address[2][7:5]-1] &
												matrix[dropping_block_address[3][4:2]+2][dropping_block_address[3][7:5]]
												)begin
												dropping_block_address[0][7:5] = dropping_block_address[0][7:5] + 1;
												dropping_block_address[0][4:2] = dropping_block_address[0][4:2];
												dropping_block_address[1][7:5] = dropping_block_address[1][7:5];
												dropping_block_address[1][4:2] = dropping_block_address[1][4:2] + 1;
												dropping_block_address[2][7:5] = dropping_block_address[2][7:5] - 1;
												dropping_block_address[2][4:2] = dropping_block_address[2][4:2] - 1;
												dropping_block_address[3][7:5] = dropping_block_address[3][7:5];
												dropping_block_address[3][4:2] = dropping_block_address[3][4:2] + 2;
												dropping_block_address[0][1:0] = dropping_block_address[0][1:0] + 1;
												end
											
								2'b01 :	if(matrix[dropping_block_address[0][4:2]][dropping_block_address[0][7:5]-1] & 
												matrix[dropping_block_address[1][4:2]][dropping_block_address[1][7:5]-1] &
												matrix[dropping_block_address[2][4:2]+1][dropping_block_address[2][7:5]] &
												matrix[dropping_block_address[3][4:2]-1][dropping_block_address[3][7:5]]
												)begin
												dropping_block_address[0][7:5] = dropping_block_address[0][7:5] - 1;
												dropping_block_address[0][4:2] = dropping_block_address[0][4:2];
												dropping_block_address[1][7:5] = dropping_block_address[1][7:5] - 1;
												dropping_block_address[1][4:2] = dropping_block_address[1][4:2];
												dropping_block_address[2][7:5] = dropping_block_address[2][7:5];
												dropping_block_address[2][4:2] = dropping_block_address[2][4:2] + 1;
												dropping_block_address[3][7:5] = dropping_block_address[3][7:5];
												dropping_block_address[3][4:2] = dropping_block_address[3][4:2] - 1;
												dropping_block_address[0][1:0] = dropping_block_address[0][1:0] + 1;
												end
												
								2'b10 :	if(matrix[dropping_block_address[0][4:2]-1][dropping_block_address[0][7:5]] & 
												matrix[dropping_block_address[1][4:2]][dropping_block_address[1][7:5]+1] &
												matrix[dropping_block_address[2][4:2]-1][dropping_block_address[2][7:5]] &
												matrix[dropping_block_address[3][4:2]][dropping_block_address[3][7:5]-1]
												)begin
												dropping_block_address[0][7:5] = dropping_block_address[0][7:5] ;
												dropping_block_address[0][4:2] = dropping_block_address[0][4:2] - 1;
												dropping_block_address[1][7:5] = dropping_block_address[1][7:5] + 1;
												dropping_block_address[1][4:2] = dropping_block_address[1][4:2];
												dropping_block_address[2][7:5] = dropping_block_address[2][7:5];
												dropping_block_address[2][4:2] = dropping_block_address[2][4:2] - 1;
												dropping_block_address[3][7:5] = dropping_block_address[3][7:5] - 1;
												dropping_block_address[3][4:2] = dropping_block_address[3][4:2];
												dropping_block_address[0][1:0] = dropping_block_address[0][1:0] + 1;
												end
												
								2'b11 :	if(matrix[dropping_block_address[0][4:2]+1][dropping_block_address[0][7:5]] & 
												matrix[dropping_block_address[1][4:2]-1][dropping_block_address[1][7:5]] &
												matrix[dropping_block_address[2][4:2]+1][dropping_block_address[2][7:5]+1] &
												matrix[dropping_block_address[3][4:2]-1][dropping_block_address[3][7:5]+1]
												)begin
												dropping_block_address[0][7:5] = dropping_block_address[0][7:5];
												dropping_block_address[0][4:2] = dropping_block_address[0][4:2] + 1;
												dropping_block_address[1][7:5] = dropping_block_address[1][7:5];
												dropping_block_address[1][4:2] = dropping_block_address[1][4:2] - 1;
												dropping_block_address[2][7:5] = dropping_block_address[2][7:5] + 1;
												dropping_block_address[2][4:2] = dropping_block_address[2][4:2] + 1;
												dropping_block_address[3][7:5] = dropping_block_address[3][7:5] + 1;
												dropping_block_address[3][4:2] = dropping_block_address[3][4:2] - 1;
												dropping_block_address[0][1:0] = 0;
												end
							endcase		
				3'b011:/* O */	begin
									dropping_block_address[0][7:5] = dropping_block_address[0][7:5];
									dropping_block_address[0][4:2] = dropping_block_address[0][4:2];
									dropping_block_address[1][7:5] = dropping_block_address[1][7:5];
									dropping_block_address[1][4:2] = dropping_block_address[1][4:2];
									dropping_block_address[2][7:5] = dropping_block_address[2][7:5];
									dropping_block_address[2][4:2] = dropping_block_address[2][4:2];
									dropping_block_address[3][7:5] = dropping_block_address[3][7:5];
									dropping_block_address[3][4:2] = dropping_block_address[3][4:2];
									end
									
				3'b100:  case(dropping_block_address[0][1:0]) // S
								2'b00 :	if(matrix[dropping_block_address[0][4:2]][dropping_block_address[0][7:5]+1] & 
												matrix[dropping_block_address[1][4:2]+1][dropping_block_address[1][7:5]+1] &
												matrix[dropping_block_address[2][4:2]][dropping_block_address[2][7:5]] &
												matrix[dropping_block_address[3][4:2]+1][dropping_block_address[3][7:5]]
												)begin
												dropping_block_address[0][7:5] = dropping_block_address[0][7:5] + 1;
												dropping_block_address[0][4:2] = dropping_block_address[0][4:2];
												dropping_block_address[1][7:5] = dropping_block_address[1][7:5] + 1;
												dropping_block_address[1][4:2] = dropping_block_address[1][4:2] + 1;
												dropping_block_address[2][7:5] = dropping_block_address[2][7:5];
												dropping_block_address[2][4:2] = dropping_block_address[2][4:2];
												dropping_block_address[3][7:5] = dropping_block_address[3][7:5];
												dropping_block_address[3][4:2] = dropping_block_address[3][4:2] + 1;
												dropping_block_address[0][1:0] = dropping_block_address[0][1:0] + 1;
												end
												
								2'b01 :	if(matrix[dropping_block_address[0][4:2]+1][dropping_block_address[0][7:5]-1] & 
												matrix[dropping_block_address[1][4:2]][dropping_block_address[1][7:5]-1] &
												matrix[dropping_block_address[2][4:2]+1][dropping_block_address[2][7:5]] &
												matrix[dropping_block_address[3][4:2]][dropping_block_address[3][7:5]]
												)begin
												dropping_block_address[0][7:5] = dropping_block_address[0][7:5] - 1;
												dropping_block_address[0][4:2] = dropping_block_address[0][4:2] + 1;
												dropping_block_address[1][7:5] = dropping_block_address[1][7:5] - 1;
												dropping_block_address[1][4:2] = dropping_block_address[1][4:2];
												dropping_block_address[2][7:5] = dropping_block_address[2][7:5];
												dropping_block_address[2][4:2] = dropping_block_address[2][4:2] + 1;
												dropping_block_address[3][7:5] = dropping_block_address[3][7:5];
												dropping_block_address[3][4:2] = dropping_block_address[3][4:2];
												dropping_block_address[0][1:0] = dropping_block_address[0][1:0] + 1;
												end
												
								2'b10 :	if(matrix[dropping_block_address[0][4:2]-1][dropping_block_address[0][7:5]+1] & 
												matrix[dropping_block_address[1][4:2]+1][dropping_block_address[1][7:5]+1] &
												matrix[dropping_block_address[2][4:2]][dropping_block_address[2][7:5]] &
												matrix[dropping_block_address[3][4:2]+1][dropping_block_address[3][7:5]]
												)begin
												dropping_block_address[0][7:5] = dropping_block_address[0][7:5];
												dropping_block_address[0][4:2] = dropping_block_address[0][4:2] - 1;
												dropping_block_address[1][7:5] = dropping_block_address[1][7:5];
												dropping_block_address[1][4:2] = dropping_block_address[1][4:2];
												dropping_block_address[2][7:5] = dropping_block_address[2][7:5] - 1;
												dropping_block_address[2][4:2] = dropping_block_address[2][4:2] - 1;
												dropping_block_address[3][7:5] = dropping_block_address[3][7:5] - 1;
												dropping_block_address[3][4:2] = dropping_block_address[3][4:2];
												dropping_block_address[0][1:0] = dropping_block_address[0][1:0] + 1;
												end
												
								2'b11 :	if(matrix[dropping_block_address[0][4:2]][dropping_block_address[0][7:5]] & 
												matrix[dropping_block_address[1][4:2]-1][dropping_block_address[1][7:5]] &
												matrix[dropping_block_address[2][4:2]][dropping_block_address[2][7:5]+1] &
												matrix[dropping_block_address[3][4:2]-1][dropping_block_address[3][7:5]+1]
												)begin
												dropping_block_address[0][7:5] = dropping_block_address[0][7:5];
												dropping_block_address[0][4:2] = dropping_block_address[0][4:2];
												dropping_block_address[1][7:5] = dropping_block_address[1][7:5];
												dropping_block_address[1][4:2] = dropping_block_address[1][4:2] - 1;
												dropping_block_address[2][7:5] = dropping_block_address[2][7:5] + 1;
												dropping_block_address[2][4:2] = dropping_block_address[2][4:2];
												dropping_block_address[3][7:5] = dropping_block_address[3][7:5] + 1;
												dropping_block_address[3][4:2] = dropping_block_address[3][4:2] - 1;
												dropping_block_address[0][1:0] = 0;
												end
							endcase							
				3'b101:  case(dropping_block_address[0][1:0]) // T
								2'b00 :	if(matrix[dropping_block_address[0][4:2]][dropping_block_address[0][7:5]+1] & 
												matrix[dropping_block_address[1][4:2]+1][dropping_block_address[1][7:5]] &
												matrix[dropping_block_address[2][4:2]][dropping_block_address[2][7:5]] &
												matrix[dropping_block_address[3][4:2]][dropping_block_address[3][7:5]]
												)begin
												dropping_block_address[0][7:5] = dropping_block_address[0][7:5] + 1;
												dropping_block_address[0][4:2] = dropping_block_address[0][4:2];
												dropping_block_address[1][7:5] = dropping_block_address[1][7:5];
												dropping_block_address[1][4:2] = dropping_block_address[1][4:2] + 1;
												dropping_block_address[2][7:5] = dropping_block_address[2][7:5];
												dropping_block_address[2][4:2] = dropping_block_address[2][4:2];
												dropping_block_address[3][7:5] = dropping_block_address[3][7:5];
												dropping_block_address[3][4:2] = dropping_block_address[3][4:2];
												dropping_block_address[0][1:0] = dropping_block_address[0][1:0] + 1;
												end
												
								2'b01 :	if(matrix[dropping_block_address[0][4:2]][dropping_block_address[0][7:5]-1] & 
												matrix[dropping_block_address[1][4:2]][dropping_block_address[1][7:5]] &
												matrix[dropping_block_address[2][4:2]+1][dropping_block_address[2][7:5]] &
												matrix[dropping_block_address[3][4:2]][dropping_block_address[3][7:5]]
												)begin
												dropping_block_address[0][7:5] = dropping_block_address[0][7:5] - 1;
												dropping_block_address[0][4:2] = dropping_block_address[0][4:2];
												dropping_block_address[1][7:5] = dropping_block_address[1][7:5];
												dropping_block_address[1][4:2] = dropping_block_address[1][4:2];
												dropping_block_address[2][7:5] = dropping_block_address[2][7:5];
												dropping_block_address[2][4:2] = dropping_block_address[2][4:2] + 1;
												dropping_block_address[3][7:5] = dropping_block_address[3][7:5];
												dropping_block_address[3][4:2] = dropping_block_address[3][4:2];
												dropping_block_address[0][1:0] = dropping_block_address[0][1:0] + 1;
												end
												
								2'b10 :	if(matrix[dropping_block_address[0][4:2]][dropping_block_address[0][7:5]] & 
												matrix[dropping_block_address[1][4:2]][dropping_block_address[1][7:5]] &
												matrix[dropping_block_address[2][4:2]-1][dropping_block_address[2][7:5]] &
												matrix[dropping_block_address[3][4:2]][dropping_block_address[3][7:5]-1]
												)begin
												dropping_block_address[0][7:5] = dropping_block_address[0][7:5];
												dropping_block_address[0][4:2] = dropping_block_address[0][4:2];
												dropping_block_address[1][7:5] = dropping_block_address[1][7:5];
												dropping_block_address[1][4:2] = dropping_block_address[1][4:2];
												dropping_block_address[2][7:5] = dropping_block_address[2][7:5];
												dropping_block_address[2][4:2] = dropping_block_address[2][4:2] - 1;
												dropping_block_address[3][7:5] = dropping_block_address[3][7:5] - 1;
												dropping_block_address[3][4:2] = dropping_block_address[3][4:2];
												dropping_block_address[0][1:0] = dropping_block_address[0][1:0] + 1;
												end
												
								2'b11 :	if(matrix[dropping_block_address[0][4:2]][dropping_block_address[0][7:5]-1] & 
												matrix[dropping_block_address[1][4:2]][dropping_block_address[1][7:5]] &
												matrix[dropping_block_address[2][4:2]+1][dropping_block_address[2][7:5]] &
												matrix[dropping_block_address[3][4:2]][dropping_block_address[3][7:5]]
												)begin
												dropping_block_address[0][7:5] = dropping_block_address[0][7:5];
												dropping_block_address[0][4:2] = dropping_block_address[0][4:2];
												dropping_block_address[1][7:5] = dropping_block_address[1][7:5];
												dropping_block_address[1][4:2] = dropping_block_address[1][4:2] - 1;
												dropping_block_address[2][7:5] = dropping_block_address[2][7:5];
												dropping_block_address[2][4:2] = dropping_block_address[2][4:2];
												dropping_block_address[3][7:5] = dropping_block_address[3][7:5] + 1;
												dropping_block_address[3][4:2] = dropping_block_address[3][4:2];
												dropping_block_address[0][1:0] = 0;
												end
							endcase	
				3'b110:  case(dropping_block_address[0][1:0]) // Z
								2'b00 :	if(matrix[dropping_block_address[0][4:2]+2][dropping_block_address[0][7:5]+1] & 
												matrix[dropping_block_address[1][4:2]][dropping_block_address[1][7:5]+1] &
												matrix[dropping_block_address[2][4:2]+1][dropping_block_address[2][7:5]] &
												matrix[dropping_block_address[3][4:2]-1][dropping_block_address[3][7:5]]
												)begin
												dropping_block_address[0][7:5] = dropping_block_address[0][7:5] + 1;
												dropping_block_address[0][4:2] = dropping_block_address[0][4:2] + 2;
												dropping_block_address[1][7:5] = dropping_block_address[1][7:5] + 1;
												dropping_block_address[1][4:2] = dropping_block_address[1][4:2];
												dropping_block_address[2][7:5] = dropping_block_address[2][7:5];
												dropping_block_address[2][4:2] = dropping_block_address[2][4:2] + 1;
												dropping_block_address[3][7:5] = dropping_block_address[3][7:5];
												dropping_block_address[3][4:2] = dropping_block_address[3][4:2] - 1;
												dropping_block_address[0][1:0] = dropping_block_address[0][1:0] + 1;
												end
												
								2'b01 :	if(matrix[dropping_block_address[0][4:2]-1][dropping_block_address[0][7:5]-1] & 
												matrix[dropping_block_address[1][4:2]+1][dropping_block_address[1][7:5]-1] &
												matrix[dropping_block_address[2][4:2]][dropping_block_address[2][7:5]] &
												matrix[dropping_block_address[3][4:2]+2][dropping_block_address[3][7:5]]
												)begin
												dropping_block_address[0][7:5] = dropping_block_address[0][7:5] - 1;
												dropping_block_address[0][4:2] = dropping_block_address[0][4:2] - 1;
												dropping_block_address[1][7:5] = dropping_block_address[1][7:5] - 1;
												dropping_block_address[1][4:2] = dropping_block_address[1][4:2] + 1;
												dropping_block_address[2][7:5] = dropping_block_address[2][7:5];
												dropping_block_address[2][4:2] = dropping_block_address[2][4:2];
												dropping_block_address[3][7:5] = dropping_block_address[3][7:5];
												dropping_block_address[3][4:2] = dropping_block_address[3][4:2] + 2;
												dropping_block_address[0][1:0] = dropping_block_address[0][1:0] + 1;
												end
												
								2'b10 :	if(matrix[dropping_block_address[0][4:2]+1][dropping_block_address[0][7:5]] & 
												matrix[dropping_block_address[1][4:2]-1][dropping_block_address[1][7:5]] &
												matrix[dropping_block_address[2][4:2]][dropping_block_address[2][7:5]-1] &
												matrix[dropping_block_address[3][4:2]-2][dropping_block_address[3][7:5]-1]
												)begin
												dropping_block_address[0][7:5] = dropping_block_address[0][7:5];
												dropping_block_address[0][4:2] = dropping_block_address[0][4:2] + 1;
												dropping_block_address[1][7:5] = dropping_block_address[1][7:5];
												dropping_block_address[1][4:2] = dropping_block_address[1][4:2] - 1;
												dropping_block_address[2][7:5] = dropping_block_address[2][7:5] - 1;
												dropping_block_address[2][4:2] = dropping_block_address[2][4:2];
												dropping_block_address[3][7:5] = dropping_block_address[3][7:5] - 1;
												dropping_block_address[3][4:2] = dropping_block_address[3][4:2] - 2;
												dropping_block_address[0][1:0] = dropping_block_address[0][1:0] + 1;
												end
					
								2'b11 :	if(matrix[dropping_block_address[0][4:2]+1][dropping_block_address[0][7:5]] & 
												matrix[dropping_block_address[1][4:2]-1][dropping_block_address[1][7:5]] &
												matrix[dropping_block_address[2][4:2]][dropping_block_address[2][7:5]-1] &
												matrix[dropping_block_address[3][4:2]-2][dropping_block_address[3][7:5]-1]
												)begin
												dropping_block_address[0][7:5] = dropping_block_address[0][7:5];
												dropping_block_address[0][4:2] = dropping_block_address[0][4:2] - 2;
												dropping_block_address[1][7:5] = dropping_block_address[1][7:5];
												dropping_block_address[1][4:2] = dropping_block_address[1][4:2];
												dropping_block_address[2][7:5] = dropping_block_address[2][7:5] + 1;
												dropping_block_address[2][4:2] = dropping_block_address[2][4:2] - 1;
												dropping_block_address[3][7:5] = dropping_block_address[3][7:5] + 1;
												dropping_block_address[3][4:2] = dropping_block_address[3][4:2] + 1;
												dropping_block_address[0][1:0] = 0;
												end
							endcase
			endcase
		end
			
		if(matrix[0] != 8'b11111111) begin
			game_over = 1;
			for(integer i = 0; i < 8; i++) matrix[i] = 8'b0;
			for(integer i = 0; i < 8; i++) dropping_block_matrix[i] = 8'b0;
		end
		end
		end
	
	wire game_over, music_not_end;
	initial begin
	game_over = 0;
	music_not_end = 1;
	get_block_enable = 1;
	drop_block_enable = 0;
	blocknum = 3'b010;
   LED_R = 8'b11111111;
   LED_G = 8'b11111111;
   LED_B = 8'b11111111;
	start_anime_count = 3'b000;
	start_anime = 1;
	select_matrix = 2'b00;
	end

	// display on LED8x8
	always @ (posedge CLK_div_display) begin
			if (cnt >= 7) cnt = 0;
			else cnt = cnt+1;
			COMM = {1'b1, cnt};
			
			if(start_anime)
				case(start_anime_count)
					3'b001: 	begin for(integer i = 0; i < 8; i++) LED_R[i] = now[i][cnt];
										LED_G = 8'b11111111;
										LED_B = 8'b11111111;
										
								end
					3'b010: 	begin for(integer i = 0; i < 8; i++) LED_R[i] = now[i][cnt];
										for(integer i = 0; i < 8; i++) LED_G[i] = now[i][cnt];
										for(integer i = 0; i < 8; i++) LED_B[i] = now[i][cnt];
								end
					3'b011: 	begin for(integer i = 0; i < 8; i++) LED_R[i] = now[i][cnt];
										for(integer i = 0; i < 8; i++) LED_G[i] = now[i][cnt];
										LED_B = 8'b11111111;
								end
					3'b100: 	begin LED_R = 8'b11111111;
										for(integer i = 0; i < 8; i++) LED_G[i] = now[i][cnt];
										LED_B = 8'b11111111;
								end
					3'b101: 	begin LED_R = 8'b11111111;
										for(integer i = 0; i < 8; i++) LED_G[i] = now[i][cnt];
										for(integer i = 0; i < 8; i++) LED_B[i] = now[i][cnt];
								end
					3'b110: 	begin for(integer i = 0; i < 8; i++) LED_R[i] = now[i][cnt];
										LED_G = 8'b11111111;
										for(integer i = 0; i < 8; i++) LED_B[i] = now[i][cnt];					
								end
				endcase
			else begin
				LED_G = 8'b11111111;
				for(integer i = 0; i < 8; i++) LED_B[i] = matrix[i][cnt];
				for(integer i = 0; i < 8; i++) LED_R[i] = dropping_block_matrix[i][cnt];
			end
		end

	// start
		divfreqForStart F3(CLK, CLK_div_start);
	
	reg [0:7] now [0:7];
	reg [0:7] T1 [0:7];
	reg [0:7] E [0:7];
	reg [0:7] T2 [0:7];
	reg [0:7] R [0:7];
	reg [0:7] I [0:7];
	reg [0:7] S [0:7];
	reg [1:0] select_matrix;
	initial begin
		T1 = '{
				8'b00000001,
				8'b11101111,
				8'b11101111,
				8'b11101111,
				8'b11101111,
				8'b11101111,
				8'b11101111,
				8'b11111111
		};
		E = '{
				8'b00000001,
				8'b01111111,
				8'b01111111,
				8'b00000111,
				8'b01111111,
				8'b01111111,
				8'b00000001,
				8'b11111111
		};
		T2 = '{
				8'b00000001,
				8'b11101111,
				8'b11101111,
				8'b11101111,
				8'b11101111,
				8'b11101111,
				8'b11101111,
				8'b11111111
		};
		R = '{
				8'b00000001,
				8'b01111101,
				8'b01111101,
				8'b00000001,
				8'b01001111,
				8'b01110011,
				8'b01111100,
				8'b11111111
		};
		I = '{
				8'b00000001,
				8'b11101111,
				8'b11101111,
				8'b11101111,
				8'b11101111,
				8'b11101111,
				8'b00000001,
				8'b11111111
		};
		S = '{
				8'b10000001,
				8'b01111111,
				8'b00111111,
				8'b11000111,
				8'b11111001,
				8'b11111101,
				8'b00000011,
				8'b11111111
		};
	end
	
	reg [2:0]start_anime_count;
	always@(posedge CLK_div_start) begin
		start_anime_count = start_anime_count + 1;
		if(start_anime_count == 3'b111) start_anime = 0;
		case(start_anime_count)
			3'b001: now = T1;
			3'b010: now = E;
			3'b011: now = T2;
			3'b100: now = R;
			3'b101: now = I;
			3'b110: now = S;
			3'b111: select_matrix = 2'b01;
		endcase
	end
	
	
	
	//music
	reg beep_r; 
	reg[7:0] state; 
	reg[15:0]count, count_end;
	reg[23:0]count1;
	parameter 	M1 = 16'd47774,
					M2 = 16'd42568,
					M3 = 16'd37919,
					M4 = 16'd35791,
					M5 = 16'd31889,
					M6 = 16'd28409,
					M7 = 16'd25309;
	parameter TIME = 10000000; //音的長短
	assign beep = beep_r; //輸出音樂
	
	always@(posedge CLK) begin
		if(music_not_end && game_over) begin
		count <= count + 1'b1; //計數器加1
		if(count == count_end) begin
			count <= 16'd0; //計數器清零
			beep_r <=! beep_r; //輸出取反
		end
	end
	end
	
	always @(posedge CLK) begin
		if(music_not_end && game_over) begin
			if(count1 < TIME) //一個節拍 
				count1 = count1 + 1'b1;
			else begin
				count1 = 24'd0;
				if(state == 8'd29) // 結束
					music_not_end = 0;
				else
				state = state + 1'b1;
				case(state)
					8'd0, 8'd1 : count_end = M1; 
					8'd2, 8'd3 : count_end = M1;
					8'd4, 8'd5 : count_end = M5;
					8'd6, 8'd7 : count_end = M5;
					8'd8, 8'd9 : count_end = M6;
					8'd10, 8'd11 : count_end = M6;
					8'd12, 8'd13, 8'd14, 8'd15 : count_end = M5;
					8'd16, 8'd17 : count_end = M4; 
					8'd18, 8'd19 : count_end = M4;
					8'd20, 8'd21 : count_end = M3;
					8'd22, 8'd23 : count_end = M3;
					8'd24, 8'd25 : count_end = M2;
					8'd26, 8'd27 : count_end = M2;
					8'd28, 8'd29 : count_end = M1;
				endcase
			end
		end
	end
	
	// pause the game
	always@(pause) begin
		if(pause) begin
			CLK_div_drop <= 0;
		end
		else begin
			CLK_div_drop = CLK_div_drop_f;
		end
	end

endmodule