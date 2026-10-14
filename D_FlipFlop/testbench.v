`timescale 1ns / 1ps                 

module testbench;                    
reg D = 0, CLK = 0;                  
wire Q, QBAR;                        

reg expected;                        // the "answer key": what Q should be after each rising edge
integer errors = 0;                  // counts how many checks failed
integer checks = 0;                  // counts how many checks were performed

D_FlipFlop memory1bit(D, CLK, Q, QBAR);  

always #5 CLK = ~CLK;                // every 5 ns, flip the clock: 10 ns period, rising edges at 5, 15, 25, etc

initial                              // runs once at time 0
begin
$monitor($time, " D = %b, CLK = %b Q = %b, QBAR = %b",   // print a line every time any listed signal changes
                 D, CLK, Q, QBAR);   // the signals printed, in the order of the %b placeholders
end



//checker: compares Q to the expected value
always @(posedge CLK)                // runs every time CLK rises
begin
expected <= D;                       // record the D value present at the rising edge (<= : updates at end of this time step)
#4;                                  // wait 4 ns so the gate delays (about 2 ns) have settled
checks = checks + 1;                 // count this check
if (Q !== expected || QBAR !== ~expected) begin  // is Q wrong, or QBAR not the opposite? (!== also catches x)
    errors = errors + 1;             // yes: count an error
    $display("[%0t] ERROR after edge: D=%b Q=%b QBAR=%b expected Q=%b", $time, D, Q, QBAR, expected);  // and print details
end
#5;                                  // wait 5 more ns: now 9 ns after the edge, just before the next rising edge
checks = checks + 1;                 // count the second check
if (Q !== expected || QBAR !== ~expected) begin  // Q must still equal the same expected value (held all cycle)
    errors = errors + 1;             // mismatch: count an error
    $display("[%0t] ERROR end of cycle: D=%b Q=%b QBAR=%b expected Q=%b", $time, D, Q, QBAR, expected);  // print details
end
end

initial                              
begin
D = 0;                               // t=0:  D starts at 0
#12 D = 1;                           // t=12: wait 12 ns, set D to 1 (CLK is low); captured at the edge at 15, Q becomes 1
#6  D = 0;                           // t=18: wait 6 ns, set D to 0 while CLK is HIGH; Q must NOT change (master-slave test)
#14 D = 1;                           // t=32: wait 14 ns, set D to 1 (CLK low); captured at the edge at 35, Q becomes 1
#20 D = 0;                           // t=52: wait 20 ns, set D to 0 (CLK low); captured at the edge at 55, Q becomes 0
#25;                                 // t=77: wait long enough for the checks after the last edge (65) to run
$display("----------------------------------------");              
if (errors == 0) $display("PASS: %0d checks, no errors", checks);  // no mismatches found: report success
else             $display("FAIL: %0d errors in %0d checks", errors, checks);  // otherwise report how many failed
$finish;                             // stop the simulation (without this the clock would run forever)
end

endmodule                            // end of the testbench
