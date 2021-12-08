module register_tb();
	logic clk;
	logic reset;

	logic[4:0] rAddrA, rAddrB, wAddr;
	logic[31:0] rDataA, rDataB, wData;
	logic write;

	localparam TEST_CYCLES = 50;

	initial begin
		$dumpfile("register_tb.vcd");
        $dumpvars(0, register_tb);

        clk = 0

        #10; //ensure low at start of simu

        repeat( 2* TEST_CYCLES + 10 ) begin
        	#5;
        	clk = !clk;
        end
        $fatal(1, "Testbench timed out"); //feelsbadman
	end

	logic[31:0] expected[31:0]; //expected values
	initial begin
		reset = 0;

		@(posedge clk)
		#1;
		reset = 1;

		@(posedge clk)
        #1; //ensure register is reset

        integer i; //looooping woooooooooo
        for(i=0; i<32; i++) begin
        	expected[i] == 0; //reset expected as well
        end

        integer j;
        repeat (TEST_CYCLES) begin
        	wAddr = j % 32;
        	rAddrA = (j+10) % 32;
        	rAddrB = (j+5) % 32;
        	wrData = $urandom();
        	write = $urandom_range(0,1)
        	reset = ($urandom_range(0,42)) == 0; //1/42 chance of reset 

        	@(posedge clk)
        	#1;

        	/*---Sets expected when writing---*/
        	if (reset == 1) begin
        		for(i=0; i<32; i++) begin
        		expected[i] == 0; //reset expected as well
        		end
        	end
        	else if (write == 1 && wAddr == 0) begin 
        	end //no writing to $0
        	else if (write == 1) begin
        		expected[wAddr] = wrData;
        	end
        	/*------*/

        	/*---Compare expected to register---*/
        	if (reset == 1) begin
        		assert (rDataA==0 && rDataB==0) else $error("readData not zero during reset.")
        	end
        	else begin
        		assert( rDataA == expected[rAddrA] && rDataB == expected[rAddrB]) else $error("mismatch between expected and register output")
        	end
        end : repeat (TEST_CYCLES)
        $finish;
	end : initial

	//add register initialisation

endmodule : register_tb