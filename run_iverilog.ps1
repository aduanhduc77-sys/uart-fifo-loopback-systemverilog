$ErrorActionPreference = "Stop"
$rtl = @(
  "rtl/sync_fifo.sv",
  "rtl/uart_rx.sv",
  "rtl/uart_tx.sv",
  "rtl/uart_fifo_loopback.sv",
  "tb/tb_uart_fifo_loopback.sv"
)
iverilog -g2012 -o sim_uart_fifo_loopback.vvp $rtl
vvp sim_uart_fifo_loopback.vvp

