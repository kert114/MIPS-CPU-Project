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
    logic [3:0] byteenable;
    logic [31:0] readdata;

    logic initialwrite;

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
    logic [1:0]  waitrequest_counter;

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
        waitrequest <= 0;

        initialwrite = 1;

        @(posedge clk);
        reset <= 1;
        @(posedge clk);
        reset <= 0;
        @(posedge clk);
        assert(active == 1);
        else $display("TB : CPU did not set active=1 after reset.");
        
        //check that read and write don't activate at the same time
        while(active == 1) begin
            assert(~(read && write));
            else $display("TB : CPU asserted read and write at the same time.");
            @(posedge clk);
        end

        $display("register_v0=%h", register_v0);
        $display("active=0");
        $finish;

    end


    always @(address or posedge read) 
    begin
        if (read)
        begin
            if (waitrequest_counter == 0) begin
                waitrequest = 1;
                #25;
                waitrequest = 0;
            end
            waitrequest_counter = waitrequest_counter + 1;
        end
    end

    // Uses waitrequest to make writes take 4 cycles
    always @(address or posedge write)   
    begin
        if (write == 1 && initialwrite == 1) begin
            waitrequest = 1;
            #35;
            waitrequest = 0;
            initialwrite = 0;
        end
    end
endmodule