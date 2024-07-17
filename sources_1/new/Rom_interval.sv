module Rom_Interval #(
    localparam WIDTH = 16,
    localparam Interval = 8
) (
    output logic [1:0][Interval-1:0][WIDTH-1:0] Rom_o
);

  assign Rom_o = 0;

endmodule
