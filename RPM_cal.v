module RPM_cal(
			clk_50,
			ChZ,
			RST,
			DIGITS
);


//----------------RPM MEASUREMENTS------------------------------------

//


input 				clk_50;
input					ChZ;
input					RST;

output reg [39:0] DIGITS;


reg 		[15:0] 	cnt = 1;
integer 				data_out;
reg					write;
reg					stop_out = 0;
reg					clk_1ms = 0;
reg					syn_chZ;
reg					rst_cnt = 0;
reg					p_state1 = 0;
reg					p_state2 = 0;
reg					RPM_clear = 0;
//
//
//
//

always @ (posedge clk_1ms) // on positive clock edge 
	begin
		if(!rst_cnt) begin
			RPM_clear<=0;
			if(cnt >= 16'h1388)
			begin
				cnt <= 16'h1388;
				data_out <= 0;
				stop_out <= 1'b1;
			end
			else
			begin
				cnt <= cnt + 1; // increment counter
				data_out <=60000/cnt;
				stop_out <= 1'b0;
			end
		end
		else
			begin
				RPM_clear<=1;
				data_out <= 0;
				cnt <= 1;
				stop_out <= 0; 		
			end
	end
	
always @ (posedge clk_50)begin
		p_state1 <= ChZ;
		p_state2 <= p_state1;

end
	


always @ (negedge clk_50 or posedge RST)
begin
	if(RST) begin
		   rst_cnt <= 1;
			DIGITS <= "00000";
	end
	else begin
		if((p_state2==0 && p_state1==1 && cnt>10) ^ stop_out)
		begin
			rst_cnt = 1;
			if(stop_out) begin
				DIGITS[39:0] = "00000";
			end
			else begin//////r
				  DIGITS[7:0] = "0" + data_out % 32'd10;
				  DIGITS[15:8] = "0" + (data_out/32'd10) % 32'd10; 
				  DIGITS[23:16] = "0" + (data_out/32'd100) % 32'd10; 
				  DIGITS[31:24] = "0" + (data_out/32'd1000) % 32'd10; 
				  DIGITS[39:32] = "0" + (data_out/32'd10000) % 32'd10; 
			end
		end
		else
		begin
			if(RPM_clear)
			rst_cnt <= 0;
			else
			rst_cnt <= rst_cnt;
			DIGITS <= DIGITS ;
		end
	end
end

	
	
	
parameter BaudGeneratorAccWidth = 31;
parameter BaudGeneratorInc =42950*2; // 1
reg [BaudGeneratorAccWidth:0] BaudGeneratorAcc;

always @(posedge clk_50)
begin
  BaudGeneratorAcc <= BaudGeneratorAcc[BaudGeneratorAccWidth-1:0] + BaudGeneratorInc;
end

wire BaudTick = BaudGeneratorAcc[BaudGeneratorAccWidth];

always@(posedge BaudTick)
clk_1ms=~clk_1ms;

endmodule 