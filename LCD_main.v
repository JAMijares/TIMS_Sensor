module LCD_main(
						CLK,
						LCD_RDY,
						DIGITS,
						RST,
						DATA,
						OPER,
						ENB
);

input CLK;			
	
input LCD_RDY;
input [39:0] DIGITS;	
input RST;

output [7:0] DATA;			// Indicates that the module is Idle and ready to take more data
output [1:0] OPER;
output ENB;


wire LCD_RDY;
wire [39:0] DIGITS;	

reg [7:0] DATA=0;
reg [1:0] OPER=0;			
reg ENB;

//
//reg [7:0] DIGIT1_temp="1";
//reg [7:0] DIGIT2_temp="2";
//reg [7:0] DIGIT3_temp="3";
//reg [7:0] DIGIT4_temp="4";


parameter [7:0] DISP_ON		= 8'b00001100;	//Execution time = 42us, Turn ON Display
parameter [7:0] ALL_ON		= 8'b00001111;	//Execution time = 42us, Turn ON All Display
parameter [7:0] ALL_OFF		= 8'b00001000;	//Execution time = 42us, Turn OFF All Display
parameter [7:0] CLEAR 		= 8'b00000001; 	//Execution time = 1.64ms, Clear Display
parameter [7:0] ENTRY_N		= 8'b00000110;	//Execution time = 42us, Normal Entry, Cursor increments, Display is not shifted
parameter [7:0] HOME 		= 8'b00000010; 	//Execution time = 1.64ms, Return Home
parameter [7:0] C_SHIFT_L 	= 8'b00010000; 	//Execution time = 42us, Cursor Shift
parameter [7:0] C_SHIFT_R 	= 8'b00010100; 	//Execution time = 42us, Cursor Shift
parameter [7:0] D_SHIFT_L 	= 8'b00011000; 	//Execution time = 42us, Display Shift
parameter [7:0] D_SHIFT_R 	= 8'b00011100; 	//Execution time = 42us, Display Shift

parameter [25:0] t_500ms	= 25000000/10;	//500ms 


reg		[25:0] cnt_timer;
reg		[2:0] state;
reg		[1:0] substate;
reg		[3:0] msg_cnt;
reg		LCD_clear=0;
reg      [7:0] INSTR = CLEAR;

parameter IDLE = 3'b001, WC = 3'b010, WI = 3'b011, RESET = 3'b100, FINISH = 3'b101;
	always @ (posedge CLK or posedge RST) begin
		if (RST) begin
			state <= IDLE;
			DATA<=0;
			substate<=0;
			msg_cnt <= 1;
			LCD_clear<=0;
			cnt_timer<= 0;
		end
		else
			case (state)
				//-------------------------------------------------------------------------------------
				IDLE: begin//----------This is the IDLE STATE, DO NOTHING UNTIL RPM is ready-----------
					if (LCD_RDY) 			//Create RPM Ready function
					begin
						if(!LCD_clear)begin
							state<= WI;
							INSTR<= CLEAR;
						end
						else
							state<= WC;
						DATA<=DATA;
						substate<=0;
					end
					else begin
						state<= IDLE;
						DATA<=DATA;
					end
				end //IDLE
				//---------------------------------------------------------------------------------------
				WC: begin //----------------------------- WRITE CHARACTER -------------------------------
					if (substate==0)begin  //Wait 1 cycle
						state<=state;
						substate<=1;
						case (msg_cnt)
							1:	DATA<=" ";
							2:	DATA<=DIGITS[31:24];
							3:	DATA<=DIGITS[23:16];
							4:	DATA<=DIGITS[15:8];
							5:	DATA<=DIGITS[7:0];
							6:	DATA<=" ";
							7:	DATA<="R";
							8:	DATA<="P";
							9:	DATA<="M";
						endcase
					end// substate==0
				   if (substate==1)begin			
						if(msg_cnt == 9) begin		//Check if is the last letter
							msg_cnt <= 1;				//Reset MSG counter
							LCD_clear<=0;
							state <=FINISH;				//Go back to IDLE (wait for refresh)
						end
						else begin
							state <=state;
							if (!LCD_RDY) begin
								msg_cnt <= msg_cnt;
								substate<=1;
							end
							else begin
								msg_cnt <= msg_cnt +1;
								substate<=0;
							end
						end
						DATA<=DATA;
					end// substate==1
				end//WC
				//---------------------------------------------------------------------------------------
				WI: begin //----------------------------- WRITE INSTRUCTION -----------------------------
					if (substate==0)begin  //Wait 1 cycle
						state<=state;
						substate<=1;
					   DATA<=INSTR;
					end// substate==0
				   if (substate==1)begin			
						state <= IDLE;
						substate<=0;
						DATA<=DATA;
						LCD_clear<=1;
					end// substate==1
				end//WI
				RESET: begin
					if (!LCD_RDY) begin
						state<= IDLE;
						DATA<=DATA;
					end
				end //IDLE
				FINISH: begin//----------This is the IDLE STATE, DO NOTHING UNTIL RPM is ready-----------
					DATA<=DATA;
					if (cnt_timer>=t_500ms)begin
						state<=IDLE;
						cnt_timer<= 0;
					end
					else begin
						state<=state;
						cnt_timer<= cnt_timer +1;

					end
					
				end //IDLE
				
				default: state<=IDLE;
			endcase
	end
	
	// Determine the output based only on the current state
	always @ (state)
	begin
		case (state)
			IDLE: begin
				ENB<=0;
				OPER[1:0]<=2'b00;
			end
			WC: begin
				ENB<=1;
				OPER[1:0]<=2'b01;
			end
			WI: begin
				ENB<=1;
				OPER[1:0]<=2'b10;
			end
			RESET: begin
				ENB<=1;
				OPER[1:0]<=2'b11;
			end
			FINISH: begin
				ENB<=0;
				OPER[1:0]<=2'b00;
			end
		endcase
	end



	

endmodule 