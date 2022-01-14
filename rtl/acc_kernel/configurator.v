// ----------------------------------------------------------------------------
//
// Multi-Dataflow Composer tool - Platform Composer
// Configurator module 
// Date: 2022/01/14 11:05:46
//
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// Module Interface
// ----------------------------------------------------------------------------

module configurator(
	ID,
	sel
);


// ----------------------------------------------------------------------------
// Module Signals
// ----------------------------------------------------------------------------

// Input
input [7:0] ID;

// Ouptut(s)
output [13:0] sel;


// ----------------------------------------------------------------------------
// Body
// ----------------------------------------------------------------------------

reg [13:0] sel;

// case ID
always@(ID)
case(ID)
8'd1:	begin	// Roberts
sel[0]=1'b0;
sel[1]=1'b0;
sel[2]=1'b0;
sel[3]=1'b0;
sel[4]=1'b0;
sel[5]=1'b0;
sel[6]=1'b0;
sel[7]=1'b0;
sel[8]=1'b0;
sel[9]=1'b0;
sel[10]=1'b0;
sel[11]=1'b0;
sel[12]=1'b0;
sel[13]=1'b0;
			end
8'd2:	begin	// Sobel
sel[0]=1'b1;
sel[1]=1'b1;
sel[2]=1'b1;
sel[3]=1'b1;
sel[4]=1'b1;
sel[5]=1'b1;
sel[6]=1'b1;
sel[7]=1'b1;
sel[8]=1'b1;
sel[9]=1'b1;
sel[10]=1'b1;
sel[11]=1'b1;
sel[12]=1'b1;
sel[13]=1'b1;
			end
	default:	sel=14'bx;
endcase


endmodule
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
