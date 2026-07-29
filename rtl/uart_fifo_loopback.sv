module uart_fifo_loopback #(
    parameter int CLKS_PER_BIT = 16
) (
    input  logic clk,
    input  logic rst,
    input  logic rx,
    output logic tx
);
    logic [7:0] rx_data;
    logic       rx_valid;
    logic [7:0] fifo_data;
    logic       fifo_full;
    logic       fifo_empty;
    logic       tx_ready;
    logic       pop_fifo;

    uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_rx (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .data(rx_data),
        .valid(rx_valid)
    );

    sync_fifo #(.WIDTH(8), .DEPTH(16)) u_fifo (
        .clk(clk),
        .rst(rst),
        .wr_en(rx_valid && !fifo_full),
        .wr_data(rx_data),
        .rd_en(pop_fifo),
        .rd_data(fifo_data),
        .full(fifo_full),
        .empty(fifo_empty)
    );

    assign pop_fifo = tx_ready && !fifo_empty;

    uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_tx (
        .clk(clk),
        .rst(rst),
        .data(fifo_data),
        .valid(pop_fifo),
        .ready(tx_ready),
        .tx(tx)
    );
endmodule

