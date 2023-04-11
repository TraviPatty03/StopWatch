//One bit D Flip Flop//
module DFF0(data_in,clock,reset, data_out);
input data_in;
input clock,reset;

output reg data_out;

always@(posedge clock)
	begin
		if(reset)
			data_out<=1'b0;
		else
			data_out<=data_in;
	end	

endmodule

//T Flip Flop//
module TFF0 (
data  , // Data Input
clk   , // Clock Input
reset , // Reset input
q       // Q output
);
//-----------Input Ports---------------
input data, clk, reset ; 
//-----------Output Ports---------------
output q;
//------------Internal Variables--------
reg q;
//-------------Code Starts Here---------
always @ ( posedge clk or posedge reset)
if (reset) begin
  q <= 1'b0;
end else if (data) begin
  q <= !q;
end

endmodule

//Clock Divider//
module clk_divider(clock, rst, clk_out);
input clock, rst;
output clk_out;
 
wire [18:0] din;
wire [18:0] clkdiv;
 
DFF0 dff_inst0(
    .data_in(din[0]),
	 .clock(clock),
	 .reset(rst),
    .data_out(clkdiv[0])
);
 
genvar i;
generate
for (i = 1; i < 19; i=i+1) 
	begin : dff_gen_label
		 DFF0 dff_inst (
			  .data_in (din[i]),
			  .clock(clkdiv[i-1]),
			  .reset(rst),
			  .data_out(clkdiv[i])
		 );
		 end
endgenerate
 
assign din = ~clkdiv;
 
assign clk_out = clkdiv[18];
 
endmodule

//Design Half Adder//
module HA (A,B,Sum,Carry);
input A, B;
output Sum, Carry;

and g1(Carry, A, B);
xor g2(Sum, A, B);
endmodule

//Design Ripple Carry Adder(RCA)//
module RCA(A, Cin, S);
input [3:0]A, Cin;
output [3:0]S;
wire c0, c1, c2, c3;

HA g3(.A(A[0]), .B(Cin), .Sum(S[0]), .Carry(c0));
HA g4(.A(A[1]), .B(c0), .Sum(S[1]), .Carry(c1));
HA g5(.A(A[2]), .B(c1), .Sum(S[2]), .Carry(c2));
HA g6(.A(A[3]), .B(c2), .Sum(S[3]), .Carry(c3));

endmodule

//Design the 4-bit DFF module (DFF4)//
module DFF4(D, clock, reset, Q);
input [3:0]D;
input clock, reset;

output [3:0]Q;

DFF0 g7(.data_in(D[0]), .clock(clock), .reset(reset), .data_out(Q[0]));
DFF0 g8(.data_in(D[1]), .clock(clock), .reset(reset), .data_out(Q[1]));
DFF0 g9(.data_in(D[2]), .clock(clock), .reset(reset), .data_out(Q[2]));
DFF0 g10(.data_in(D[3]), .clock(clock), .reset(reset), .data_out(Q[3]));

endmodule

//Design the count 10 module using the RCA and DFF4 component//
module cnt10(clock, inc, reset, Count_eq_9, count);
input clock, inc, reset;
output Count_eq_9;
output [3:0]count;

wire a1, o1;
wire [3:0]b;

DFF4 g11(.D(b), .clock(clock), .reset(o1), .Q(count));

assign Count_eq_9 = (count==4'b1001)?1:0;

and g12(a1, inc, Count_eq_9);
or g13(o1, a1, reset);

RCA g14(.A(count), .Cin(inc), .S(b));

endmodule

//Design the count 6 module using the RCA and DFF4 component//
module cnt6(clock, inc, reset, Count_eq_6, count);
input clock, inc, reset;
output Count_eq_6;
output [3:0]count;

wire a1, o1;
wire [3:0]b;

DFF4 g14(.D(b), .clock(clock), .reset(o1), .Q(count));

assign Count_eq_6 = (count==4'b0101)?1:0;

and g15(a1, inc, Count_eq_6);
or g16(o1, a1, reset);

RCA g17(.A(count), .Cin(inc), .S(b));

endmodule


//Create the BCD_Display based on the equationsin Lab 5//
module BCD(O, S);
input [0:3]O;
output [6:0]S;

wire A, B, C, D;

assign A = O[0];
assign B = O[1];
assign C = O[2];
assign D = O[3];

assign S[0] = (B&~D) | (~A&~B&~C&D);
assign S[1] = (B&~C&D) | (B&C&~D);
assign S[2] = (~B&C&~D);
assign S[3] = (B&~C&~D) | (~B&~C&D) | (B&C&D);
assign S[4] = D | (B&~C);
assign S[5] = (C&D) | (~A&~B&D) | (~B&C);
assign S[6] = (B&C&D) | (~A&~B&~C);

endmodule

//Design the final Counter module using clock divider, BCD_display, and the Count(10&6) module//
module counter(clock, reset, inc, Out1, Out2, Out3, Out4);
input clock, reset, inc;
output [6:0]Out1, Out2, Out3, Out4;

wire clk, eq0, eq1, eq2, eq3, eq4, a1, a2, a3, q;
wire [3:0] num1, num2, num3, num4;

clk_divider g18(.clock(clock), .rst(1'b0), .clk_out(clk));

TFF0 g19(.data(1'b1), .clk(inc), .reset(1'b0), .q(q));

cnt10 g20(.clock(clk), .inc(q), .reset(reset), .Count_eq_9(eq0), .count(num1));
and g21(a1, eq0, q);

cnt10 g22(.clock(clk), .inc(a1), .reset(reset), .Count_eq_9(eq1), .count(num2));
and g23(a2, eq1, a1);

cnt10 g24(.clock(clk), .inc(a2), .reset(reset), .Count_eq_9(eq2), .count(num3));
and g25(a3, eq2, a2);

cnt6 g26(.clock(clk), .inc(a3), .reset(reset), .Count_eq_6(eq3), .count(num4));

BCD g27(.O(num1), .S(Out1));
BCD g28(.O(num2), .S(Out2));
BCD g29(.O(num3), .S(Out3));
BCD g30(.O(num4), .S(Out4));

endmodule
