module Simple_Counter (
								CLOCK_50,
								ChA,
								FIFO_full,
								undersamp,
								counter_out,
								data_out,
								owrreq,
								stop_out
							 );

input 				CLOCK_50;
input 				ChA;
input 				FIFO_full;
input		[2:0] 	undersamp;
reg					p_state1 = 0;
reg					p_state2 = 0;
output 	[15:0] 	counter_out;
reg 		[15:0] 	counter_out;
reg 		[15:0] 	cnt2;
output	[15:0] 	data_out;
reg 		[15:0] 	data_out;
reg					reset =0;
reg					reset2 =0;
output				owrreq;
reg					write;
output reg			stop_out;

reg 		[2:0]	      undersamp_cnt;


initial
undersamp_cnt <= 0;

assign   owrreq   =  write;

always @ (posedge CLOCK_50) // on positive clock edge 
	begin
		if(!reset)
			if(counter_out == 16'hFFFF)
			begin
				counter_out <= 16'hFFFF;
				stop_out <= 1'b1;
			end
			else
			begin
				counter_out <= counter_out + 1; // increment counter
				stop_out <= 1'b0;
			end
		else
			begin
				counter_out <= 0;	 
			end
		if(!reset2)
			if(cnt2 == 16'hFFFF)
					cnt2 <= 16'hFFFF;
			else
					cnt2 <= cnt2 + 1; // increment counter
		else
			begin
				cnt2 <= 0;	 
			end
		p_state1 <= ChA;
		p_state2 <= p_state1;
	end
	


always @ (negedge CLOCK_50)
	begin
		if( p_state2==0 && p_state1==1 && cnt2>100) begin
			if (undersamp_cnt == undersamp) begin
					data_out <= counter_out;
					reset <= 1;
					reset2 <=1;
					undersamp_cnt <= 1'b0;
					if(!FIFO_full)
					begin write <= 1'b1; end
			end
			else begin
					undersamp_cnt<= undersamp_cnt + 1;
					reset <= 0;
					reset2 <= 1;
					write <= 1'b0;
			end
		end //If		
		else
			begin
				reset2 <= 0;
				reset <= 0;
				write <= 1'b0;
			end

	end
	

endmodule // end of module counter