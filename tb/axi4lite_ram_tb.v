`timescale 1ns / 1ps

//-----------------------------------------------------------------------------
// Module: axi4lite_ram_tb
// Description: Testbench for the AXI4-Lite RAM module. Validates write and read
//              operations, and checks for PASS/FAIL conditions.
//-----------------------------------------------------------------------------

module axi4lite_ram_tb;

    // Testbench Signals
    reg clk;
    reg rst_n;

    // AXI signals
    reg [5:0]  awaddr;
    reg        awvalid;
    wire       awready;

    reg [31:0] wdata;
    reg [3:0]  wstrb;
    reg        wvalid;
    wire       wready;

    wire [1:0] bresp;
    wire       bvalid;
    reg        bready;

    reg [5:0]  araddr;
    reg        arvalid;
    wire       arready;

    wire [31:0] rdata;
    wire [1:0]  rresp;
    wire        rvalid;
    reg         rready;

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    // Device Under Test (DUT)
    axi4lite_ram dut (
        .s_axi_aclk(clk),
        .s_axi_aresetn(rst_n),

        .s_axi_awaddr(awaddr),
        .s_axi_awvalid(awvalid),
        .s_axi_awready(awready),

        .s_axi_wdata(wdata),
        .s_axi_wstrb(wstrb),
        .s_axi_wvalid(wvalid),
        .s_axi_wready(wready),

        .s_axi_bresp(bresp),
        .s_axi_bvalid(bvalid),
        .s_axi_bready(bready),

        .s_axi_araddr(araddr),
        .s_axi_arvalid(arvalid),
        .s_axi_arready(arready),

        .s_axi_rdata(rdata),
        .s_axi_rresp(rresp),
        .s_axi_rvalid(rvalid),
        .s_axi_rready(rready)
    );

    // AXI Write Task
    task axi_write;
        input [5:0]  addr;
        input [31:0] data;
        begin
            // Address phase
            @(posedge clk);
            awaddr  = addr;
            awvalid = 1;
            wait (awready == 1);
            @(posedge clk);
            awvalid = 0;

            // Data phase
            wdata  = data;
            wstrb  = 4'hF;
            wvalid = 1;
            wait (wready == 1);
            @(posedge clk);
            wvalid = 0;

            // Response phase
            bready = 1;
            wait (bvalid == 1);
            @(posedge clk);
            bready = 0;
        end
    endtask

    // AXI Read Task
    task axi_read;
        input  [5:0]  addr;
        output [31:0] data;
        begin
            // Address phase
            @(posedge clk);
            araddr  = addr;
            arvalid = 1;
            wait (arready == 1);
            @(posedge clk);
            arvalid = 0;

            // Data phase
            rready = 1;
            wait (rvalid == 1);
            data = rdata;
            @(posedge clk);
            rready = 0;
        end
    endtask

    // Test Stimulus
    reg [31:0] read_data;
    integer errors;

    initial begin
        // Initialize Signals
        rst_n   = 0;
        awaddr  = 0; awvalid = 0;
        wdata   = 0; wstrb   = 0; wvalid  = 0;
        bready  = 0;
        araddr  = 0; arvalid = 0;
        rready  = 0;
        errors  = 0;

        // Reset
        #20 rst_n = 1;
        #20;

        $display("-----------------------------------------");
        $display("Starting AXI4-Lite RAM Testbench...");
        $display("-----------------------------------------");

        // Write and Read Test 1
        $display("TEST 1: Write and Read at Address 0x00");
        axi_write(6'h00, 32'hDEADBEEF);
        axi_read(6'h00, read_data);
        if (read_data !== 32'hDEADBEEF) begin
            $display("FAIL: Expected DEADBEEF, got %h", read_data);
            errors = errors + 1;
        end else begin
            $display("PASS: Addr 0x00 Data = %h", read_data);
        end

        // Write and Read Test 2
        $display("TEST 2: Write and Read at Address 0x1C");
        axi_write(6'h1C, 32'h12345678);
        axi_read(6'h1C, read_data);
        if (read_data !== 32'h12345678) begin
            $display("FAIL: Expected 12345678, got %h", read_data);
            errors = errors + 1;
        end else begin
            $display("PASS: Addr 0x1C Data = %h", read_data);
        end

        // Write and Read Test 3
        $display("TEST 3: Write and Read at Address 0x3C (Last Word)");
        axi_write(6'h3C, 32'hCAFEF00D);
        axi_read(6'h3C, read_data);
        if (read_data !== 32'hCAFEF00D) begin
            $display("FAIL: Expected CAFEF00D, got %h", read_data);
            errors = errors + 1;
        end else begin
            $display("PASS: Addr 0x3C Data = %h", read_data);
        end

        $display("-----------------------------------------");
        if (errors == 0)
            $display("TEST RESULT: ALL TESTS PASSED!");
        else
            $display("TEST RESULT: %0d TESTS FAILED!", errors);
        $display("-----------------------------------------");

        #50 $finish;
    end

endmodule
