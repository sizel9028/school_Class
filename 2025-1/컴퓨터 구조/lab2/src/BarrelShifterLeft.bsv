import BarrelShifterRight::*;

interface BarrelShifterLeft;
	method ActionValue#(Bit#(64)) leftShift(Bit#(64) val, Bit#(6) shiftAmt);
endinterface

module mkBarrelShifterLeft(BarrelShifterLeft);
	let bsr <- mkBarrelShifterRightLogical;
	method ActionValue#(Bit#(64)) leftShift(Bit#(64) val, Bit#(6) shiftAmt);
		/* TODO: Implement a left shifter using the given logical right shifter */
		Bit#(64) reverse = 0;
		Bit#(64) result = 0;

		for(Integer i=0;i<64;i=i+1)
			reverse[i] = val[63-i];

		//$display("%b",reverse); good
		reverse <- bsr.rightShift(reverse,shiftAmt);
		//$display("%b",reverse);

		for(Integer i=0;i<64;i=i+1)
			result[i] = reverse[63-i];

		return result;
	endmethod
endmodule
