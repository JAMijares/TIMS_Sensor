module Simple_Encoder (
								CLOCK_50,
								oEncoder
							 );

input 				CLOCK_50;
output reg			oEncoder= 0;
reg	[15:0]		Counter;
integer 				value = 1230;
integer				toggle = 1;

always @ (posedge CLOCK_50)
	begin
		if (Counter == value/2)
			begin
			oEncoder <= !oEncoder;
			Counter <= 0;
			end
		else
			Counter <= Counter + 1;

	end

endmodule // end of module counter