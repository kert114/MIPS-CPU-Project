module mips_cpu_bus_tb();
	logic clk;
    logic reset;
    logic active;
    logic [31:0] register_v0;
    logic [31:0] address;
    logic write;
    logic read;
    logic waitrequest;
    logic [31:0] writedata;
    logic [31:0] byteenable;
    logic [31:0] readdata;

    mips_cpu_bus cpu(
        .clk            (clk),
        .reset          (reset),
        .active         (active),
        .register_v0    (register_v0),
        .address        (address),
        .write          (write),
        .read           (read),
        .waitrequest    (waitrequest),
        .writedata      (writedata),
        .byteenable     (byteenable),
        .readdata       (readdata)
    );

    parameter RAM_FILE = "";

    mips_cpu_bus_tb_mem #(RAM_FILE) mem(
        .clk(clk),
        .read(read),
        .write(write),
        .byteenable(byteenable),
        .addr(address),
        .writedata(writedata),
        .waitrequest(waitrequest),
        .readdata(readdata)
    );

    initial begin // writing the clock
        $dumpfile("mips_cpu_bus_tb.vcd");
        $dumpvars(0, mips_cpu_bus_tb);
        clk = 0;
        #5;
        repeat (100000) begin
            #10 clk = !clk;
        end
        $fatal(2, "Simulation did not finish within 100000 cycles.");
    end

    initial begin // test reset
        reset <= 0;
        waitrequest <=  0;

        

    end