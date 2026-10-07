`timescale 1ns / 1ps

//-----------------------------------------------------------------------------
// Module: axi4lite_ram
// Description: Top module combining AXI4-Lite slave interface and 16x32 RAM.
//-----------------------------------------------------------------------------

module axi4lite_ram (
    // Clock and Reset
    input  wire        s_axi_aclk,
    input  wire        s_axi_aresetn,

    // Write Address Channel
    input  wire [5:0]  s_axi_awaddr,
    input  wire        s_axi_awvalid,
    output wire        s_axi_awready,

    // Write Data Channel
    input  wire [31:0] s_axi_wdata,
    input  wire [3:0]  s_axi_wstrb,
    input  wire        s_axi_wvalid,
    output wire        s_axi_wready,

    // Write Response Channel
    output wire [1:0]  s_axi_bresp,
    output wire        s_axi_bvalid,
    input  wire        s_axi_bready,

    // Read Address Channel
    input  wire [5:0]  s_axi_araddr,
    input  wire        s_axi_arvalid,
    output wire        s_axi_arready,

    // Read Data Channel
    output wire [31:0] s_axi_rdata,
    output wire [1:0]  s_axi_rresp,
    output wire        s_axi_rvalid,
    input  wire        s_axi_rready
);

    // Internal signals
    wire [5:0]  mem_addr;
    wire [31:0] mem_din;
    wire [3:0]  mem_wstrb;
    wire        mem_we;
    wire [31:0] mem_dout;
    
    wire [3:0]  word_idx;
    wire        valid_addr_rw;

    // Instantiate AXI4-Lite Slave FSM
    axi4lite_slave u_axi4lite_slave (
        .clk(s_axi_aclk),
        .rst_n(s_axi_aresetn),

        .awaddr(s_axi_awaddr),
        .awvalid(s_axi_awvalid),
        .awready(s_axi_awready),

        .wdata(s_axi_wdata),
        .wstrb(s_axi_wstrb),
        .wvalid(s_axi_wvalid),
        .wready(s_axi_wready),

        .bresp(s_axi_bresp),
        .bvalid(s_axi_bvalid),
        .bready(s_axi_bready),

        .araddr(s_axi_araddr),
        .arvalid(s_axi_arvalid),
        .arready(s_axi_arready),

        .rdata(s_axi_rdata),
        .rresp(s_axi_rresp),
        .rvalid(s_axi_rvalid),
        .rready(s_axi_rready),

        .mem_addr(mem_addr),
        .mem_we(mem_we),
        .mem_din(mem_din),
        .mem_wstrb(mem_wstrb),
        .ram_dout(mem_dout),
        
        .valid_addr_write(valid_addr_rw),
        .valid_addr_read(valid_addr_rw)
    );

    // Instantiate Address Decoder
    addr_decoder u_addr_decoder (
        .addr_in(mem_addr),
        .word_idx(word_idx),
        .valid_addr(valid_addr_rw)
    );

    // Instantiate 16x32 Synchronous RAM
    ram_16x32 u_ram_16x32 (
        .clk(s_axi_aclk),
        .rst_n(s_axi_aresetn),
        .we(mem_we & valid_addr_rw), // Only write if address is valid
        .wstrb(mem_wstrb),
        .addr(word_idx),
        .din(mem_din),
        .dout(mem_dout)
    );

endmodule
