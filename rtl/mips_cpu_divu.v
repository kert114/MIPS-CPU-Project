module mips_cpu_divu(
    input logic clk,
    input logic start, //start signal from main sheet
    input logic[31:0] divisor,
    input logic[31:0] dividend,
    input logic reset,

    output logic[31:0] quotient,
    output logic[31:0] remainder,
    output logic done, //timing purposes
    output logic dbz // dividing by 0
    );

    logic[31:0] y; //divisor store
    logic[31:0] q1, q1_next; //quotient
    logic[31:0] ac, ac_next; //accumulator
    logic[5:0] i; //counter

    always @(*) begin
        if(ac >= y) begin
            ac_next = ac - y;
            {ac_next, q1_next} = {ac_next[30:0], q1, 1'b1}; //go forward one cycle
        end
        else begin
            {ac_next, q1_next} = {ac,q1} << 1; //down
        end
    end

    //multicycle divider following textbook logic
    always_ff @(posedge clk) begin
        if(reset) begin
            quotient <= 0;
            remainder <= 0;
            done <= 0;
            dbz <= 0;
        end
        else if(start == 1) begin
            if(divisor == 0) begin
                dbz <= 1;
                quotient <= 0;
                remainder <= 0;
                done <= 1;
            end //catch dbz error

            else if(divisor > dividend) begin
                quotient <= 0;
                remainder <= 0;
                done <= 1;
            end //basic case

            else begin
                i <= 0;
                y <= divisor;
                {ac, q1} <= {{31{1'b0}}, dividend, 1'b0};
            end // initialisation
        end
        else if(done == 0) begin
            if(i == 31) begin //32 cycle divider
                done <= 1;
                quotient <= q1_next;
                remainder <= ac_next >> 1; //undo shift
            end
            else begin
                i <= i + 6'd000001; //iterate
                ac <= ac_next;
                q1 <= q1_next;
            end
        end
    end
endmodule

//someone double check this logic and delete this comment lol -- Jerry