module layernorm_pe#(
  parameter int dim_size = 128,
  parameter int data_width = 16)
  (
    input logic clk,
    input logic rst,

    input  logic [data_width-1:0] array[dim_size-1: 0],
    input  logic [data_width-1:0] gmma,
  
    output logic [data_width-1:0] vari_remul,
    output logic [data_width-1:0] equation,
    output logic                  ln_valid
  );
  logic [data_width-1:0] equation_squ;
  logic                  equat_valid;
  logic [data_width-1:0] vari_reverse;       

  ln_equation dut_equat(
      .clk    (clk),
      .rst  (rst),

      .Garray (array),

      .equat            (equation),
      .equat_square     (equation_squ),
      .equat_valid_o    (equat_valid)
  );
  ln_variance dut_vari(
      .clk            (clk),
      .rst          (rst),

      .Garray         (array),
      .equat_square   (equation_squ),
      .equat_valid_i  (equat_valid),
      .gmma           (gmma),
      
      .vari_remul     (vari_remul),
      .valid_vari_o   (ln_valid)
  );


endmodule