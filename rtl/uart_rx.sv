module uart_rx #(
    parameter int CLKS_PER_BIT = 16
) (
    input  logic       clk,
    input  logic       rst,
    input  logic       rx,
    output logic [7:0] data,
    output logic       valid
);
    typedef enum logic [1:0] {IDLE, START, DATA, STOP} state_t;

    state_t state;
    logic [$clog2(CLKS_PER_BIT)-1:0] clk_count;
    logic [2:0] bit_index;
    logic [7:0] shift;

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            clk_count <= '0;
            bit_index <= '0;
            shift <= '0;
            data <= '0;
            valid <= 1'b0;
        end else begin
            valid <= 1'b0;

            unique case (state)
                IDLE: begin
                    clk_count <= '0;
                    bit_index <= '0;
                    if (!rx) begin
                        state <= START;
                    end
                end

                START: begin
                    if (clk_count == (CLKS_PER_BIT / 2 - 1)) begin
                        clk_count <= '0;
                        state <= rx ? IDLE : DATA;
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                DATA: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= '0;
                        shift[bit_index] <= rx;
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
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= '0;
                        data <= shift;
                        valid <= rx;
                        state <= IDLE;
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end
            endcase
        end
    end
endmodule

