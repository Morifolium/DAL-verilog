module Accumulator #(
    parameter int data_width = 16,
    parameter int data_cnt   = 64
)(
    input  logic clk,
    input  logic rst,
    input  logic [data_width-1:0] array [data_cnt-1:0],
    output logic [data_width-1:0] result,
    output logic done
);

logic [data_width-1:0] op_a, op_b, res_o;
logic [1:0] state;  //   处理加法器的延迟

integer i;

// Adder instance
adder_fp16 u_adder_fp16 (
    .clk    (clk),
    .rst  (rst),
    .mode   (1'b0),
    .op_a   (op_a),
    .op_b   (op_b),
    .res_o  (res_o),
    .done   ()
);
assign result = res_o;
always_ff @(posedge clk or negedge rst) begin
    if (!rst) begin
        i <= 0;
        done <= 0;
        state <= 0;
    end
    else begin
        if (!done) begin
            if (state == 0) begin
                if (i == 0) begin
                    op_a <= 16'b0;
                end
                else begin
                    op_a <= res_o;
                end
                op_b <= array[i];
                state <= 1;
            end
            else if (state == 2) begin
                if (i < data_cnt-1) begin
                    i <= i + 1;
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
