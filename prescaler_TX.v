module prescaler_TX (
clk_50,nRESET,
clk_bdr);

input clk_50,nRESET;
output reg clk_bdr;

integer cnt;

parameter BD=2604;

initial
clk_bdr=0;

always@(negedge clk_50 or negedge nRESET) begin
  if(!nRESET) 
		begin cnt=0; clk_bdr=0; end
  else begin
	  cnt=cnt+1; 
	  if(cnt==BD) begin
	  	clk_bdr=~clk_bdr;
		cnt=0;
		end //cnt
	end //else
end //always

endmodule

