module uart_tx #(
    parameter int CLKS_PER_BIT = 16
) (
    input  logic       clk,
    input  logic       rst,
    input  logic [7:0] data,
    input  logic       valid,
    output logic       ready,
    output logic       tx
);
    typedef enum logic [1:0] {IDLE, START, DATA, STOP} state_t;

    state_t state;
    logic [$clog2(CLKS_PER_BIT)-1:0] clk_count;
    logic [2:0] bit_index;
    logic [7:0] shift;

    assign ready = (state == IDLE);

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            clk_count <= '0;
            bit_index <= '0;
            shift <= '0;
            tx <= 1'b1;
        end else begin
            unique case (state)
                IDLE: begin
                    tx <= 1'b1;
                    clk_count <= '0;
                    bit_index <= '0;
                    if (valid) begin
                        shift <= data;
                        state <= START;
                    end
                end

                START: begin
                    tx <= 1'b0;
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= '0;
                        state <= DATA;
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                DATA: begin
                    tx <= shift[bit_index];
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= '0;
                        if (bit_index == 3'd7) begin
                            bit_index <= '0;
                            state <= STOP;
                        end else begin
                            bit_index <= bit_index + 1'b1;
                        end
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                STOP: begin
                    tx <= 1'b1;
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= '0;
                        state <= IDLE;
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end
            endcase
        end
    end
endmodule

