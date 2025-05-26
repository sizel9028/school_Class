import Multiplexer::*;

interface BarrelShifterRight;
  method ActionValue#(Bit#(64)) rightShift(Bit#(64) val, Bit#(6) shiftAmt, Bit#(1) shiftValue);
endinterface

module mkBarrelShifterRight(BarrelShifterRight);
  method ActionValue#(Bit#(64)) rightShift(Bit#(64) val, Bit#(6) shiftAmt, Bit#(1) shiftValue);
    /* TODO: Implement right barrel shifter using six multiplexers. */
    Bit#(64) result = val;
    Integer twice = 1;
    Integer j=0;
    for(Integer i=0;i<6;i=i+1) begin
      result = multiplexer64(shiftAmt[i],result,{shiftValue,result[63:(2**i)]});
      j=j*2;
      if(shiftAmt[5-i]==1) j=j+1;
    end
    for(Integer i=64-j;i<64;i=i+1)
      result[i] = result[i] | shiftValue;
    return result;
  endmethod
endmodule

interface BarrelShifterRightLogical;
  method ActionValue#(Bit#(64)) rightShift(Bit#(64) val, Bit#(6) shiftAmt);
endinterface

module mkBarrelShifterRightLogical(BarrelShifterRightLogical);
  let bsr <- mkBarrelShifterRight;
  method ActionValue#(Bit#(64)) rightShift(Bit#(64) val, Bit#(6) shiftAmt);
    /* TODO: Implement logical right shifter using the right shifter */
    Bit#(64) result <- bsr.rightShift(val,shiftAmt,1'b0);
    return result;
  endmethod
endmodule

typedef BarrelShifterRightLogical BarrelShifterRightArithmetic;

module mkBarrelShifterRightArithmetic(BarrelShifterRightArithmetic);
  let bsr <- mkBarrelShifterRight;
  method ActionValue#(Bit#(64)) rightShift(Bit#(64) val, Bit#(6) shiftAmt);
    /* TODO: Implement arithmetic right shifter using the right shifter */
    Bit#(64) result <- bsr.rightShift(val,shiftAmt,val[63]);
    return result;
  endmethod
endmodule
