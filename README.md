# Project 1: UART FIFO Loopback

## Goal

Build a small communication subsystem:

`UART RX -> RX FIFO -> UART TX`

The testbench sends bytes into the RX line, waits for loopback transmission, and checks that the output bytes match.

## Why this helps

This project demonstrates core junior FPGA skills:

- FSM design
- Serial protocol timing
- FIFO buffering
- Backpressure thinking
- Self-checking testbench

## Files

- `rtl/sync_fifo.sv`
- `rtl/uart_rx.sv`
- `rtl/uart_tx.sv`
- `rtl/uart_fifo_loopback.sv`
- `tb/tb_uart_fifo_loopback.sv`
- `run_iverilog.ps1`

## Run

```powershell
powershell -ExecutionPolicy Bypass -File .\run_iverilog.ps1
```

Expected result: simulation prints `PASS`.

## Next Improvements

- Add parity.
- Add framing error detection.
- Add AXI-Stream style interface around the UART.
- Synthesize in Vivado and add a timing/utilization report.

