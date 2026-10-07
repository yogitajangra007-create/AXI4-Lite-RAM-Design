`timescale 1ns / 1ps

//-----------------------------------------------------------------------------
// Module: axi4lite_slave
// Description: Handshake FSM for AXI4-Lite AW, W, B, AR, R channels.
//-----------------------------------------------------------------------------

module axi4lite_slave (
    input  wire        clk,
    input  wire        rst_n,

    // AXI4-Lite Write Address Channel
    input  wire [5:0]  awaddr,
    input  wire        awvalid,
    output reg         awready,

    // AXI4-Lite Write Data Channel
    input  wire [31:0] wdata,
    input  wire [3:0]  wstrb,
    input  wire        wvalid,
    output reg         wready,

    // AXI4-Lite Write Response Channel
    output reg  [1:0]  bresp,
    output reg         bvalid,
    input  wire        bready,

    // AXI4-Lite Read Address Channel
    input  wire [5:0]  araddr,
    input  wire        arvalid,
    output reg         arready,

    // AXI4-Lite Read Data Channel
    output reg  [31:0] rdata,
    output reg  [1:0]  rresp,
    output reg         rvalid,
    input  wire        rready,

    // Interfaces to Decoder / RAM
    output reg  [5:0]  mem_addr,
    output reg         mem_we,
    output reg  [31:0] mem_din,
    output reg  [3:0]  mem_wstrb,
    
    input  wire [31:0] ram_dout,
    input  wire        valid_addr_write, // decoded from awaddr
    input  wire        valid_addr_read   // decoded from araddr
);

    // States for Write FSM
    localparam W_IDLE  = 2'b00;
    localparam W_DATA  = 2'b01;
    localparam W_RESP  = 2'b10;

    // States for Read FSM
    localparam R_IDLE  = 1'b0;
    localparam R_DATA  = 1'b1;

    reg [1:0] w_state, w_next;
    reg r_state, r_next;

    reg awready_next, wready_next, bvalid_next;
    reg arready_next, rvalid_next;
    reg [1:0] bresp_next, rresp_next;
    reg mem_we_next;

    // AXI Write State Machine
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            w_state <= W_IDLE;
            awready <= 1'b0;
            wready  <= 1'b0;
            bvalid  <= 1'b0;
            bresp   <= 2'b00;
            mem_we  <= 1'b0;
        end else begin
            w_state <= w_next;
            awready <= awready_next;
            wready  <= wready_next;
            bvalid  <= bvalid_next;
            bresp   <= bresp_next;
            mem_we  <= mem_we_next;
            
            // Latch write address when valid
            if (awvalid && awready_next) begin
                mem_addr <= awaddr;
            end
            // Latch write data when valid
            if (wvalid && wready_next) begin
                mem_din   <= wdata;
                mem_wstrb <= wstrb;
            end
        end
    end

    // AXI Write Next State Logic
    always @(*) begin
        w_next       = w_state;
        awready_next = awready;
        wready_next  = wready;
        bvalid_next  = bvalid;
        bresp_next   = bresp;
        mem_we_next  = 1'b0;

        case (w_state)
            W_IDLE: begin
                // Accept write address
                if (awvalid && !awready) begin
                    awready_next = 1'b1;
                    w_next = W_DATA;
                end
            end
            
            W_DATA: begin
                awready_next = 1'b0; // Deassert awready
                // Accept write data
                if (wvalid && !wready) begin
                    wready_next = 1'b1;
                end else if (wready) begin
                    wready_next = 1'b0;
                    // Trigger write operation to RAM
                    mem_we_next = 1'b1;
                    w_next = W_RESP;
                end
            end

            W_RESP: begin
                // Send response
                if (!bvalid) begin
                    bvalid_next = 1'b1;
                    bresp_next  = valid_addr_write ? 2'b00 : 2'b10; // OKAY or SLVERR
                end else if (bvalid && bready) begin
                    bvalid_next = 1'b0;
                    w_next = W_IDLE;
                end
            end
            default: w_next = W_IDLE;
        endcase
    end

    // AXI Read State Machine
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_state <= R_IDLE;
            arready <= 1'b0;
            rvalid  <= 1'b0;
            rresp   <= 2'b00;
        end else begin
            r_state <= r_next;
            arready <= arready_next;
            rvalid  <= rvalid_next;
            rresp   <= rresp_next;
            
            // Latch read address
            if (arvalid && arready_next) begin
                mem_addr <= araddr;
            end
            
            // Latch read data (after RAM delay)
            if (r_state == R_IDLE && r_next == R_DATA) begin
                // The RAM takes 1 cycle, so data will be ready when rvalid is asserted
                // rdata is continuously assigned or latched
                rdata <= ram_dout; 
            end else if (r_state == R_DATA) begin
                 rdata <= ram_dout;
            end
        end
    end

    // AXI Read Next State Logic
    always @(*) begin
        r_next       = r_state;
        arready_next = arready;
        rvalid_next  = rvalid;
        rresp_next   = rresp;

        case (r_state)
            R_IDLE: begin
                if (arvalid && !arready) begin
                    arready_next = 1'b1;
                    r_next = R_DATA;
                end
            end

            R_DATA: begin
                arready_next = 1'b0;
                if (!rvalid) begin
                    rvalid_next = 1'b1;
                    rresp_next  = valid_addr_read ? 2'b00 : 2'b10; // OKAY or SLVERR
                end else if (rvalid && rready) begin
                    rvalid_next = 1'b0;
                    r_next = R_IDLE;
                end
            end
            default: r_next = R_IDLE;
        endcase
    end

endmodule
