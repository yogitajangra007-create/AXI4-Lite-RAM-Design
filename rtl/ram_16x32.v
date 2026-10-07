`timescale 1ns / 1ps

//-----------------------------------------------------------------------------
// Module: ram_16x32
// Description: 16 x 32-bit synchronous RAM with byte write enable.
//-----------------------------------------------------------------------------

module ram_16x32 (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        we,       // Write enable
    input  wire [3:0]  wstrb,    // Byte-level write strobes
    input  wire [3:0]  addr,     // 4-bit word address for 16 words
    input  wire [31:0] din,      // 32-bit data input
    output reg  [31:0] dout      // 32-bit data output
);

    // 16 words of 32 bits memory array
    reg [31:0] mem [0:15];
    integer i;

    // Synchronous write and read operations
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dout <= 32'd0;
            // Initialize memory to zero
            for (i = 0; i < 16; i = i + 1) begin
                mem[i] <= 32'd0;
            end
        end else begin
            if (we) begin
                // Byte-wise write based on WSTRB
                if (wstrb[0]) mem[addr][7:0]   <= din[7:0];
                if (wstrb[1]) mem[addr][15:8]  <= din[15:8];
                if (wstrb[2]) mem[addr][23:16] <= din[23:16];
                if (wstrb[3]) mem[addr][31:24] <= din[31:24];
            end
            // Synchronous read (reads latest written data on next cycle)
            dout <= mem[addr];
        end
    end

endmodule
