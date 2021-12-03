module mips_cpu_ALU(
    input reset,
    input clk,

    input logic[4:0] control, //ALU control <-- comes from decoder
    input logic[31:0] a, // from register
    input logic[31:0] b, //comes from decoded register/immediate
    input logic[5:0] sa, //decoder figures this out

    output logic[31:0] r,
    output logic zero //only unsigned instructions and no carry flags as dictated by the spec
);

    logic[4:0] saVar; //for variable shifts
    logic[15:0] lower; //for half word stuff

    assign zero = (result == 0) ? 1 : 0;
    assign lower = b[15:0];
    assign sav = (control == 6'b1010 || control == 6'b1011 || control == 6'b1101) ? a[4:0] : 5'b0; 

    always_ff  @(posedge clk) begin
        if(reset == 1) begin
            result <= 0;
        end
        else begin
            case (control)
                //00XX = bitwise operations + lower
                4'b0000: begin r <= a & b; end//and
                4'b0001: begin r <= a | b; end//or
                4'b0010: begin r <= a ^ b; end//xor
                4'b0011: begin r <= {lower,16'd0}; end//lower
                //01XX = unsigned operations;
                4'b0100: begin r <= a + b; end//add
                4'b0101: begin r <= a - b; end//sub
                4'b0110: begin r <= ($unsigned(a) < $unsigned(b)) ? 1 : 0; end//sltu
                4'b0111: begin r <= a; end//pogged JR and stuff idk what im doing lol
                //1XXX = shifts
                4'b1000: begin r <= b << sa; end//shift left lol
                4'b1001: begin r <= b >> sa; end//shift right
                4'b1010: begin r <= b << saVar; end//shift left var
                4'b1011: begin r <= b >> saVar; end//shift right var
                4'b1100: begin r <= $signed(b) >>> sa; end //shift right arithmetic
                4'b1101: begin r <= $signed(b) >>> saVar; end //shift right arithmetic var
                4'b1110: begin r <= ($signed(a) < $signed(b)) ? 1 : 0; end//slt
                default: begin end
            endcase
        end
    end
endmodule

/*
A+B < 0; A>= 0 and B>= 0
A+B >= 0; A < 0 and B < 0

A-B < 0; A >= 0 and B < 0
A-B >=0; A < 0 and B >= 0

add, addi, sub cause exeptions on overflow

addu,addiu,subu do not

(fun fact: addiu uses signed extention for the im stuff just like addi)
*/
/*
Arthimetic:
    ADD (u,s) x
    SUB (u,s) x
    MUL (u,s)
    DIV (u,s)

Bitwise:
    AND x
    OR x
    XOR x

Shift:
    shift right(logical, arthimetic) x
    shift left(logical) x

Move:
    Move to Hi ?
    Move to LO ?
*/

/*
R:000000|source1[25:21]|source2[20:16]|Dest.[15:11]|Shift amt[10:6]|Fn code[5:0]

addu $1 $2 $3 XXXXX ADD, ALU op is add

lw $1 4($2) <== 35/$2/$1/4
    Fetch(PC --> addr)
    Decode($2 --> a, ALU control signal + others)
    Execute(a+4)
    Memory Access((a+4)-->memory)
    Register Write(memory-->$1)

I:opcode[31:26]|source1[25:21]|source2/Dest.[20:16]|Address/Data[15:0]



Fncode for R or opcode for I determain op
opcode R: dest is 15:11 where as opcode I: dest is 20:16

*/
