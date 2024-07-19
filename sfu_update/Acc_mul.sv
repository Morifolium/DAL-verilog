module Acc_mul #(
    parameter int data_width = 16,
    parameter int data_cnt   = 64
)(
    input  logic clk,
    input  logic rst_n,
    input  logic [data_width-1:0] array [data_cnt-1:0],
    output logic [data_width-1:0] sqarray[data_cnt-1:0],
    output logic done
);

logic [data_width-1:0] op_a, op_b, res_o;
logic [1:0] state;  //   ¥¶¿Ì—”≥Ÿ

integer i;

// Adder instance
multiplier_fp16 u_multier_fp16 (
    .clk    (clk),
    .rst_n  (rst_n),
    .op_a   (op_a),
    .op_b   (op_b),
    .res_o  (res_o),
    .done   ()
);

logic [data_width-1:0] index;
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        i <= 0;
        done <= 0;
        state <= 0;
    end
    else begin
        if (!done) begin
            if (state == 0) begin
                op_a <= array[i];
                op_b <= array[i];
                state <= 1;
                sqarray[index] <=  res_o;
            end
            else if (state == 2) begin
                if (i < data_cnt) begin
                    i <= i + 1;
                    index <= i;
                    state <= 0;
                end
                else begin
                    done <= 1;           
                end
            end
            else begin
                state <= state + 1;
            end
        end
    end
end

endmodule
