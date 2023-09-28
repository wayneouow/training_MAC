module mac(in_a, in_b, in_valid_a, in_valid_b, clk, 
			reset, mac_out, out_valid);

//input output declartion			
input signed [3:0] 	 in_a, in_b;
input 			     in_valid_a, in_valid_b;
input			     clk, reset;
output reg signed [10:0] mac_out;
output reg out_valid;


//////////////////////////////////////////////////////////////////////////

reg [1:0] st, next;
reg [3:0] counter;

reg signed [3:0] a_saved, b_saved;

reg signed [10:0] sum;
reg signed [10:0] product;

reg signed [10:0] mac;

reg cplt;
reg valid_ab;


always@(*)begin
    valid_ab <= in_valid_a & in_valid_b;
end

always@(*)begin
	product <= a_saved * b_saved;
end


//FSM
// st   | state 
// 00   | idle
// 01   | waiting for signal A valid
// 10   | waiting for signal B valid
// 11   | MAC working
//
//

always@(*)begin
	case(st)
		2'b00: 
			if(valid_ab) 
				next = 2'b11;
			else if(in_valid_a) 
				next = 2'b10; 
			else if(in_valid_b) 
				next = 2'b01; 
			else	        
				next = 2'b00;
		
		2'b01:
			if(in_valid_a) 
				next = 2'b11; 
			else
				next = 2'b01;
			
		2'b10:
			if(in_valid_b) 
		        next = 2'b11; 
			else
				next = 2'b10;
		
		2'b11:
			if(valid_ab) 
				next = 2'b11; 
			else if(in_valid_a)
				next = 2'b10;
			else if(in_valid_b)
				next = 2'b01;
			else
				next = 2'b00;
				
		default :
			next = 2'bxx;
		
	endcase
end

always@(posedge clk)begin

	if(reset)
		st <= 2'b00;
		
	else
		st <= next;

end

always@(negedge clk)begin

	if(reset)
		counter <= 4'd0;
		
	else if((counter == 4'd8) && valid_ab)
		counter <= 4'd1;
		
	else if (counter == 4'd8)
		counter <= 4'd0;
	
	else if(st==2'b11)
		counter <= counter + 4'd1;
		
end

always@(negedge clk )begin

	if(reset)
		sum <= 11'd0;
		
	else if((counter == 4'd8) && valid_ab)
		sum <= product;
		
	else if(counter == 4'd8)
		sum <= 11'd0;
	
	else if(st == 2'b11)
		sum <= sum + product;
	
end

always@(posedge clk)begin

	if(in_valid_a)
		a_saved <= in_a;
		
	if(in_valid_b)
		b_saved <= in_b;	
			
end


always@(posedge clk)begin

	if(counter<=4'd8)
		mac <= sum;

end

always@(posedge clk)begin

	if(cplt)
		mac_out <= mac;
end

always@(posedge clk)begin

	if(counter==4'd8)
		cplt <= 1'b1;
		
	else
		cplt <= 1'b0;
		
end

always@(posedge clk)begin

	if(cplt)
		out_valid <= 1'b1;
	
	else
		out_valid <= 1'b0;
end


endmodule