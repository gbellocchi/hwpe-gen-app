// ----------------------------------------------------------------------------
//
// Multi-Dataflow Composer tool - Platform Composer
// Configurator module 
// Date: 2022/04/01 14:01:00
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
output [3:0] sel;


// ----------------------------------------------------------------------------
// Body
// ----------------------------------------------------------------------------

reg [3:0] sel;

// case ID
always@(ID)
case(ID)
8'd1:	begin	// FIR128network
sel[0]=1'b0;
sel[1]=1'b0;
sel[2]=1'b0;
sel[3]=1'b0;
			end
8'd2:	begin	// FIR64network
sel[0]=1'b1;
sel[1]=1'b1;
sel[2]=1'b0;
sel[3]=1'b0;
			end
8'd3:	begin	// CONVnetwork
sel[0]=1'b0;
sel[1]=1'b0;
sel[2]=1'b1;
sel[3]=1'b1;
			end
	default:	sel=4'bx;
endcase


endmodule
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
