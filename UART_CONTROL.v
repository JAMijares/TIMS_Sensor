module UART_CONTROL
(
	input clk,nRESET,tx_empty,rx_empty,
	input [7:0] Data_in,
	input [15:0] FIFO_Data,
	input 		 FIFO_full,
	input 		 FIFO_empty,
	output reg ld_tx_data,
	output [7:0]  Data_out,
	output reg tx_enable,uld_rx_data,rx_enable,
	output reg FIFO_rdreq,
	output reg FIFO_wrreq,
	output [5:0]  LED_out,
	output reg P_RESET
);

integer b_num;
reg	[7:0] Unk_Data;
reg	[7:0] TX_Data;
reg	[15:0] num_data;

initial
num_data<=0;


assign LED_out =Unk_Data [5:0];
assign Data_out=TX_Data;


	// Declare state register
	reg		[4:0] state;
	reg		[4:0] AfterTX_state;
	
	// Declare states
	parameter ACK = 8'h06, nACK = 8'h15, EoT = 8'h04, ACQ = 8'h01, ST = 8'h02, EQR = 8'h05, RST = 8'h20;
	parameter IDLE = 5'b00001, RX_read = 5'b00010, TX_set = 5'b00100, TX_send=5'b01000,
					ACQUIRE= 5'b10000, SEND_DATA= 5'b00011, READ_FIFO= 5'b00101, RESET= 5'b00111;
	
	// Determine the next state synchronously, based on the
	// current state and the input
	always @ (posedge clk or negedge nRESET) begin
		if (!nRESET) begin
			state <= IDLE;
			Unk_Data <=8'h00;
			b_num <=1;
			TX_Data <= 8'h00;
			num_data <=0;
		end
		else
			case (state)
				IDLE: begin
					if (rx_empty)
						state<= IDLE;
					else	begin
						num_data <=0;
						state <=RX_read;
					end //else
				end //IDLE
				RX_read: begin
					if (rx_empty && uld_rx_data)			
						case (Data_in)
							EQR: begin				//Enquire
								AfterTX_state <= IDLE;
								TX_Data <= ACK;
								state <=TX_set;
							end
							ACQ: begin
								state <= ACQUIRE;
							end
							ST: begin
								state <= READ_FIFO;
							end
							RST: begin
								state <=  RESET;
							end
							default: begin
								Unk_Data <=Data_in;
								TX_Data <= Data_in;
								state <= TX_set;
								AfterTX_state <= IDLE;
							end
						endcase

					else
						state<=RX_read;
				end
				TX_set: begin
					if (tx_empty)
						state <= TX_set;
					else
						state <= TX_send;
				end
				TX_send: begin
					if (tx_empty)begin
						state <= AfterTX_state;
						end
					else
						state <= TX_send;
				end
				ACQUIRE: begin
					if (FIFO_full)begin
						TX_Data <= ACK;
						AfterTX_state <= IDLE;
						state <= TX_set;
						end
					else
						begin
						state <= ACQUIRE;
						end
				end
				SEND_DATA: begin
					if (!FIFO_empty)
						case (b_num)
							1: begin 
								TX_Data <= FIFO_Data[15:8];
								AfterTX_state <= SEND_DATA;  
								state <= TX_set;
								b_num <= 2;
							end
							2: begin 
								TX_Data <= FIFO_Data[7:0];
								 
								state <= TX_set;
								b_num <= 1;
								if (num_data < 1024)
								AfterTX_state <= READ_FIFO;
								else begin
								num_data <= 0;	
								AfterTX_state <= IDLE;
								end
								
							end
						endcase
					else begin
						state <= IDLE;
					end
				end
				READ_FIFO: begin
					if (!FIFO_empty)begin
						num_data <= num_data + 1;
						state <= SEND_DATA;
						end
					else
						begin
						TX_Data <= EoT;
						state <= TX_set;
						AfterTX_state <= IDLE;  
						state <= IDLE; 
						end
				end
				RESET: state <= IDLE;
				default: state<=IDLE;
			endcase
	end
	
	// Determine the output based only on the current state
	always @ (state)
	begin
		case (state)
			IDLE: begin
				ld_tx_data=0;
				tx_enable=0;
				uld_rx_data=0;
				rx_enable=1;
				FIFO_wrreq <= 1'b0;
				FIFO_rdreq <= 1'b0;
				P_RESET =0;
			end
			RX_read: begin
				uld_rx_data=1;
				rx_enable=0;
				ld_tx_data=0;
				tx_enable=0;
				FIFO_wrreq <= 1'b0;
				FIFO_rdreq <= 1'b0;
				P_RESET =0;
			end
			TX_set:begin
				uld_rx_data=0;
				rx_enable=0;
				ld_tx_data=1;
				tx_enable=0;
				FIFO_wrreq <= 1'b0;
				FIFO_rdreq <= 1'b0;
				P_RESET =0;
			end
			TX_send:begin
				uld_rx_data=0;
				rx_enable=0;
				ld_tx_data=0;
				tx_enable=1;
				FIFO_wrreq <= 1'b0;
				FIFO_rdreq <= 1'b0;
				P_RESET =0;
			end
			ACQUIRE: begin
				uld_rx_data=0;
				rx_enable=0;
				ld_tx_data=0;
				tx_enable=0;
				FIFO_wrreq <= 1'b1;
				FIFO_rdreq <= 1'b0;
				P_RESET =0;
			end
			SEND_DATA: begin
				uld_rx_data=0;
				rx_enable=0;
				ld_tx_data=0;
				tx_enable=0;
				FIFO_wrreq <= 1'b0;
			   FIFO_rdreq <= 1'b0;
				P_RESET =0;
			end
			READ_FIFO: begin
				uld_rx_data=0;
				rx_enable=0;
				ld_tx_data=0;
				tx_enable=0;
				FIFO_wrreq <= 1'b0;
			   FIFO_rdreq <= 1'b1;
				P_RESET =0;
			end
			RESET: begin
				ld_tx_data=0;
				tx_enable=0;
				uld_rx_data=0;
				rx_enable=1;
				FIFO_wrreq <= 1'b0;
				FIFO_rdreq <= 1'b0;
				P_RESET =1;
			end
		endcase
	end


endmodule
