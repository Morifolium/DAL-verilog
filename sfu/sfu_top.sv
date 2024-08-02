module sfu_top #(
    parameter int seq_size   = 1024,
    parameter int dim_size   = 128,
    parameter int data_width = 16
) (
    input logic clk,
    input logic rst,

    input logic [data_width-1:0] data_i[dim_size-1:0],
    input logic [1:0] op,
    output logic [data_width-1:0] data_o[dim_size-1:0],

    //! vpe ctrl signals, wait for adjustment
    output logic [data_width-1:0] vpe_vec1   [dim_size-1:0],
    output logic [data_width-1:0] vpe_vec2   [dim_size-1:0],
    output logic [data_width-1:0] vpe_sca1,
    output logic [data_width-1:0] vpe_sca2,
    output logic                  vpe_mode,
    input  logic [data_width-1:0] res_vpe_vec[dim_size-1:0],
    input  logic [data_width-1:0] res_vpe_sca,
    input  logic                  vpe_valid_i,
    output logic                  vpe_valid_o,

    //! HBM-interface signals, wait for adjustment
    input logic [data_width-1:0] gmma,
    input logic [data_width-1:0] beta,
    input logic [data_width-1:0] sines  [dim_size/2-1:0],
    input logic [data_width-1:0] cosines[dim_size/2-1:0]
);
  logic ln_en;
  logic rope_en;
  assign ln_en   = (op == 2'b00) ? 1'b1 : 1'b0;
  assign rope_en = (op == 2'b01) ? 1'b1 : 1'b0;

  // rope-data
  logic [data_width-1:0] data_i_reo [dim_size-1:0];
  logic [data_width-1:0] sines_reo  [dim_size-1:0];
  logic [data_width-1:0] cosines_reo[dim_size-1:0];

  always_comb begin : rope_loop
    integer k;
    for (k = 0; k < dim_size / 2; k++) begin
      data_i_reo[2*k] = {~data_i[2*k+1][15], data_i[2*k+1][14:0]};
      data_i_reo[2*k+1] = data_i[2*k];
      sines_reo[2*k] = sines[k];
      sines_reo[2*k+1] = sines[k];
      cosines_reo[2*k] = cosines[k];
      cosines_reo[2*k+1] = cosines[k];
    end
  end

  // ln-data
  logic [data_width-1:0] vari_remul;
  logic [data_width-1:0] equation;
  logic                  ln_valid;
  layernorm_pe inst_ln (
      .clk  (clk),
      .rst  (rst & ln_en & src_valid_i),
      .array(data_i),
      .gmma (gmma),

      .vari_remul(vari_remul),
      .equation  (equation),
      .ln_valid  (ln_valid)
  );

  // ALU - full of 128 adders
  logic [data_width-1:0] op_alu_a  [dim_size-1:0];
  logic [data_width-1:0] op_alu_b  [dim_size-1:0];
  logic [data_width-1:0] res_alu   [dim_size-1:0];
  logic                  op_alu;
  logic                  alu_valid;
  logic                  alu_rst_n;
  alu inst_alu (
      .clk  (clk),
      .rst  (alu_rst_n),
      .a_vec(op_alu_a),
      .b_vec(op_alu_b),
      .op   (op_alu),

      .res_o  (res_alu),
      .valid_o(alu_valid)
  );
  assign vpe_valid_o = rope_en | alu_valid;



  logic [2:0] vpe_cnt;
  always_ff @(posedge clk or posedge rst) begin : alu_ctrl
    if (rst) begin
      op_alu_a <= '{default: '0};
      op_alu_b <= '{default: '0};
      op_alu <= 0;
      vpe_cnt <= 0;
      alu_rst_n <= 0;
    end else begin
      if (ln_en) begin
        // calc molecule(alu) -> vec*sca (vpe) -> add beta(alu)
        alu_rst_n <= 1;
        if (ln_valid && !vpe_valid_o) begin
          op_alu_a <= data_i;
          // op_alu_b <= '{default: '{equation}};
          for (integer t = 0; t < dim_size; t++) begin
            op_alu_b[t] <= equation;
          end
          op_alu <= 1'b1;  // sub
        end else if (alu_valid && !vpe_valid_i) begin
          vpe_vec1 <= res_alu;
          vpe_sca1 <= vari_remul;
          vpe_mode <= 1'b0;  //vec * sca
        end else if (vpe_valid_i) begin
          op_alu_a <= res_vpe_vec;
          // op_alu_b <= '{default: '{beta}};
          for (integer u = 0; u < dim_size; u++) begin
            op_alu_b[u] <= equation;
          end
          op_alu <= 1'b0;
          data_o <= res_alu;
        end
      end else if (rope_en) begin
        // ��λ��ˣ�vpe�� -> ��λ��ˣ�vpe��-> sum(alu)
        if (vpe_cnt == 0) begin
          vpe_vec1 <= data_i;
          vpe_vec2 <= cosines_reo;
          vpe_mode <= 1'b1;  // ��λ���
          vpe_cnt  <= vpe_cnt + 1;
        end else if (vpe_cnt == 1 && vpe_valid_i == 1) begin
          vpe_vec1 <= data_i_reo;
          vpe_vec2 <= sines_reo;
          vpe_mode <= 1'b1;  // ��λ���
          vpe_cnt  <= vpe_cnt + 1;
          vpe_cnt  <= vpe_cnt + 1;
          op_alu_a <= res_vpe_vec;
        end else if (vpe_cnt == 2 && vpe_valid_i == 1) begin
          op_alu_b <= res_vpe_vec;
          op_alu <= 1'b0;     //���
          alu_rst_n <= 1;
          data_o   <= res_alu;
        end
      end
    end
  end

endmodule
