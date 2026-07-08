module Mux #(
    parameter N = 2,
    parameter M = 18
)(
    input  logic [N-1:0] in [M-1:0],
    input  logic [$clog2(M)-1:0] sel,
    output logic [N-1:0] Out
);

	assign Out = in[sel];

endmodule