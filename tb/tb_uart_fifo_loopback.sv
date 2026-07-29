`timescale 1ns/1ps

module tb_uart_fifo_loopback;
    localparam int CLKS_PER_BIT = 8;
    localparam int CLK_PERIOD_NS = 10;

    logic clk = 1'b0;
    logic rst = 1'b1;
    logic rx = 1'b1;
    logic tx;

    byte expected [0:3] = '{8'h55, 8'ha3, 8'h00, 8'hff};

    uart_fifo_loopback #(.CLKS_PER_BIT(CLKS_PER_BIT)) dut (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .tx(tx)
    );

    always #(CLK_PERIOD_NS / 2) clk = ~clk;

    task automatic send_uart_byte(input byte value);
        int i;
        begin
            rx = 1'b0;
            repeat (CLKS_PER_BIT) @(posedge clk);
            for (i = 0; i < 8; i++) begin
                rx = value[i];
                repeat (CLKS_PER_BIT) @(posedge clk);
            end
            rx = 1'b1;
            repeat (CLKS_PER_BIT) @(posedge clk);
        end
    endtask

    task automatic recv_uart_byte(output byte value);
        int i;
        begin
            wait (tx == 1'b0);
            repeat (CLKS_PER_BIT + CLKS_PER_BIT / 2) @(posedge clk);
            for (i = 0; i < 8; i++) begin
                value[i] = tx;
                repeat (CLKS_PER_BIT) @(posedge clk);
            end
            if (tx !== 1'b1) begin
                $fatal(1, "Stop bit error");
            end
            repeat (CLKS_PER_BIT) @(posedge clk);
        end
    endtask

    initial begin
        byte got;
        int i;

        $dumpfile("uart_fifo_loopback.vcd");
        $dumpvars(0, tb_uart_fifo_loopback);

        repeat (5) @(posedge clk);
        rst = 1'b0;
        repeat (5) @(posedge clk);

        fork
            begin
                for (i = 0; i < expected.size(); i++) begin
                    send_uart_byte(expected[i]);
                end
            end
            begin
                for (i = 0; i < expected.size(); i++) begin
                    recv_uart_byte(got);
                    if (got !== expected[i]) begin
                        $fatal(1, "Mismatch index %0d expected %02x got %02x", i, expected[i], got);
                    end
                end
            end
        join

        $display("PASS: UART FIFO loopback");
        $finish;
    end
endmodule

