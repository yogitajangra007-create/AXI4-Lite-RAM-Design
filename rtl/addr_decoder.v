`timescale 1ns / 1ps

//-----------------------------------------------------------------------------
// Module: addr_decoder
// Description: Decodes byte address to word index for memory access and
//              checks if the address is valid and word-aligned.
//-----------------------------------------------------------------------------

module addr_decoder (
    input  wire [5:0] addr_in,     // Incoming AXI byte address (up to 0x3F)
    output wire [3:0] word_idx,    // Word index for 16x32 RAM
    output wire       valid_addr   // High if address is aligned
);

    // Byte address to word index (drop lower 2 bits)
    // addr_in[5:2] gives us a range of 0 to 15, matching our 16-word RAM
    assign word_idx = addr_in[5:2];

    // Check if aligned: lower 2 bits must be 0 for a 32-bit word aligned access
    // We assume the slave only responds to the lower 6 bits (64 bytes = 16 words).
    assign valid_addr = (addr_in[1:0] == 2'b00);

endmodule
