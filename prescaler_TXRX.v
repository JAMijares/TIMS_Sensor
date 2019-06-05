module prescaler_TXRX (
				clk_50,
				nRESET,
				RXclk_bdr,
				TXclk_bdr,
				RXclk_bdr2,
				TXclk_bdr2				
				);

input clk_50,nRESET;
output reg RXclk_bdr;
output reg TXclk_bdr;
output reg RXclk_bdr2;
output reg TXclk_bdr2;

integer RXcnt,TXcnt,BDTX,BDRX;


parameter f_clock=50000000;
parameter baudrate=9600;
parameter integer TXBD=2604;  //TXBD=(f_clock/baudrate)/2;
parameter integer RXBD=160;   //RXBD=(f_clock/(baudrate*16)-1)/2;


initial begin
RXclk_bdr=0;
TXclk_bdr=0;
RXclk_bdr2=0;
TXclk_bdr2=0;
end

always@(negedge clk_50 or negedge nRESET) begin
  if(!nRESET) 
		begin 
				RXcnt=0; TXcnt=0; 
				RXclk_bdr=0; TXclk_bdr=0;
		end
  else begin
	  RXcnt=RXcnt+1; 
	  TXcnt=TXcnt+1; 
	  if(RXcnt==RXBD) begin
	  	RXclk_bdr=~RXclk_bdr;
		RXcnt=0;
	   end //ifRX
	 if(TXcnt==TXBD) begin
	  	TXclk_bdr=~TXclk_bdr;
		TXcnt=0;
	   end //ifTX
	end //else
end //always

//parameter ClkFrequency = 50000000; // 25MHz
//parameter BaudTx = 9600;
//parameter BaudRx = 9600*16;
parameter BaudGeneratorAccWidth = 31;
parameter BaudGeneratorIncTX =9895605*2; // 115200 <= 4947802*2;
parameter BaudGeneratorIncRX =158329674*2; // 115200 <= 79164837*2;
reg [BaudGeneratorAccWidth:0] BaudGeneratorAccTX;
reg [BaudGeneratorAccWidth:0] BaudGeneratorAccRX;

always @(negedge clk_50)
begin
  BaudGeneratorAccTX <= BaudGeneratorAccTX[BaudGeneratorAccWidth-1:0] + BaudGeneratorIncTX;
  BaudGeneratorAccRX <= BaudGeneratorAccRX[BaudGeneratorAccWidth-1:0] + BaudGeneratorIncRX;
end

wire BaudTick_TX = BaudGeneratorAccTX[BaudGeneratorAccWidth];
wire BaudTick_RX = BaudGeneratorAccRX[BaudGeneratorAccWidth];

 

always@(posedge BaudTick_TX)
TXclk_bdr2=~TXclk_bdr2;

always@(posedge BaudTick_RX)
RXclk_bdr2=~RXclk_bdr2;


endmodule

