module refaverage (avg, a, b);
  output reg [7:0]  avg;
input [7:0] a, b;
reg [8:0] t;
always @* begin
  t = a + b + 1; // 9-bit result
  avg = t>>1;
    
   //$display("%d\t%d\t%d", a, b, avg);
  end
endmodule

module adder(sum, cout, a, b, cin);
output sum, cout;
input a, b, cin;
wire aorb, gen, prop;
xor(sum, a, b, cin); // sum
and(gen, a, b);      // generate
or(aorb, a, b);      // propogate
and(prop, aorb, cin);
or(cout, gen, prop); // cout
endmodule

module add9(s, a, b);
  output [8:0] s;
  input [8:0] a, b;
  wire [8:0] out;
adder add0(s[0], out[0], a[0], b[0], 0),
  add1(s[1], out[1], a[1], b[1], out[0]),
  add2(s[2], out[2], a[2], b[2], out[1]),
  add3(s[3], out[3], a[3], b[3], out[2]),
  add4(s[4], out[4], a[4], b[4], out[3]),
  add5(s[5], out[5], a[5], b[5], out[4]),
  add6(s[6], out[6], a[6], b[6], out[5]),
  add7(s[7], out[7], a[7], b[7], out[6]),
  add8(s[8], out[8], a[8], b[8], out[7]);
endmodule

module bitshiftR(s, a);
  input [8:0] a;
  output reg [8:0] s;
  reg [8:0] t;
  always @* begin
    t[0] = a[1];
    t[1] = a[2];
    t[2] = a[3];
    t[3] = a[4];
    t[4] = a[5]; 
    t[5] = a[6];
    t[6] = a[7];
    t[7] = a[8];
    s = t;
  end
endmodule

module average (s, a, b);
  input [8:0] a, b;
  output reg [7:0] s;
  wire [8:0] intres;
  wire [8:0] finshft;
  wire [8:0] res;
  
  reg [8:0] one = 8'b 00000001;
  
  add9 add(intres, a, b);
  add9 add1(res, one, intres);
  bitshiftR BS(finshft, res);

  always @* begin
 
    s=finshft[7:0];
  end
  
endmodule

module testbench;
  reg [8:0] a, b, s, sref;
integer correct = 0;
integer failed = 0;
wire [7:0] sw, swref;
average uut(sw, a, b);
refaverage oracle(swref, a, b);
initial begin
  a=0;
  repeat (256) begin
    b=0;
    repeat (256) #1 begin
      s = sw;
      sref = swref;
      //$display("A= %d, B=%d, Oracal=%b, Avg=%b", a, b, sref, s);
      if (s != sref) begin
        $display("Wrong: AVG(%d, %d)=%b, but got %b", a, b, sref, s);
        failed = failed + 1;
      end else begin
        correct = correct + 1;
      end
      b = b + 1;
    end
    a = a + 1;
  end
  $display("All cases tested; %d correct, %d failed", correct, failed);
end
endmodule