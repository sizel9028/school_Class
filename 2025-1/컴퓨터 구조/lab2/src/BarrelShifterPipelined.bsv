import Multiplexer::*;
import FIFO::*;
import FIFOF::*;
import Vector::*;
import SpecialFIFOs::*;


/*typedef union tagged {
	void Invalid;
	data_T Valid;
} Maybe#(type data_T)
deriving (Bits);*/

function Tuple3#(Bit#(64), Bit#(6), Bit#(1)) f0(Tuple3#(Bit#(64), Bit#(6), Bit#(1)) val, Integer shiftInteger);
    Bit#(64) result = 0; 
    Bit#(64) operand = tpl_1(val);
    Bit#(6) shamt = tpl_2(val);
    Bit#(1) shiftValue = tpl_3(val);

    for (Integer i = 0; i < 2**shiftInteger; i = i + 1)
        result[63 - i] = shiftValue;

    for (Integer i = 0; i < 64 - 2**shiftInteger; i = i + 1) 
        result[i] = operand[i + 2**shiftInteger];

	result = multiplexer64(shamt[shiftInteger],operand,result);
    return tuple3(result, shamt, shiftValue);
endfunction

/* Interface of the basic right shifter module */
interface BarrelShifterRightPipelined;
	method Action shift_request(Bit#(64) operand, Bit#(6) shamt, Bit#(1) val);
	method ActionValue#(Bit#(64)) shift_response();
endinterface

module mkBarrelShifterRightPipelined(BarrelShifterRightPipelined);
	/* use mkFIFOF for request-response interface.	*/
	let inFifo <- mkFIFOF;
	let outFifo <- mkFIFOF;

	//elastic way
	
	let fifo1 <- mkFIFOF;
	let fifo2 <- mkFIFOF;
	let fifo3 <- mkFIFOF;
	let fifo4 <- mkFIFOF;
	let fifo5 <- mkFIFOF;

	rule stage1;
		fifo1.enq(f0(inFifo.first(),0));
		inFifo.deq();
	endrule

	rule stage2;
		fifo2.enq(f0(fifo1.first(),1));
		fifo1.deq();
	endrule
	  
	rule stage3;
		fifo3.enq(f0(fifo2.first(),2));
		fifo2.deq();
	endrule

	rule stage4;
		fifo4.enq(f0(fifo3.first(),3));
		fifo3.deq();
	endrule

	rule stage5;
		fifo5.enq(f0(fifo4.first(),4));
		fifo4.deq();
	endrule

	rule stage6;
		let tmp = f0(fifo5.first(),5);
		Bit#(64) result = tpl_1(tmp);
		outFifo.enq(result);
		fifo5.deq();
	endrule
	

	/*
	// inelastic way
	Reg#(Maybe#(Tuple3#(Bit#(64),Bit#(6),Bit#(1)))) sReg1 <- mkReg(tagged Invalid);
	Reg#(Maybe#(Tuple3#(Bit#(64),Bit#(6),Bit#(1)))) sReg2 <- mkReg(tagged Invalid);
	Reg#(Maybe#(Tuple3#(Bit#(64),Bit#(6),Bit#(1)))) sReg3 <- mkReg(tagged Invalid);
	Reg#(Maybe#(Tuple3#(Bit#(64),Bit#(6),Bit#(1)))) sReg4 <- mkReg(tagged Invalid);
	Reg#(Maybe#(Tuple3#(Bit#(64),Bit#(6),Bit#(1)))) sReg5 <- mkReg(tagged Invalid);

	function Maybe#(Tuple3#(Bit#(64),Bit#(6),Bit#(1))) docase(Maybe#(Tuple3#(Bit#(64),Bit#(6),Bit#(1))) sReg,Integer stage);
		case (sReg) matches
			tagged Valid .x:
				return tagged Valid f0(x,stage);
			tagged Invalid:
				return tagged Invalid;
		endcase
	endfunction

	rule pipe1;
		if(inFifo.notEmpty()) begin
			sReg1 <= tagged Valid f0(inFifo.first(),0);
			inFifo.deq();
		end
		else
			sReg1 <= tagged Invalid;
		sReg2 <= docase(sReg1,1);
		sReg3 <= docase(sReg2,2);
		sReg4 <= docase(sReg3,3);
		sReg5 <= docase(sReg4,4);
		//if(isValid(sReg2)) $display("%b",validValue(sReg2));  maybe type을 따로 정의해서 함수를 못썼음
		let tmp = docase(sReg5,5);
		case (tmp) matches
			tagged Valid .x:
				outFifo.enq(tpl_1(x));
			tagged Invalid: noAction;
		endcase
	endrule
	*/
	

	
	method Action shift_request(Bit#(64) operand, Bit#(6) shamt, Bit#(1) val);
		inFifo.enq(tuple3(operand, shamt, val));
	endmethod

	method ActionValue#(Bit#(64)) shift_response();
		outFifo.deq;
		return outFifo.first;
	endmethod
endmodule


/* Interface of the three shifter modules
 *
 * They have the same interface.
 * So, we just copy it using typedef declarations.
 */
interface BarrelShifterRightLogicalPipelined;
	method Action shift_request(Bit#(64) operand, Bit#(6) shamt);
	method ActionValue#(Bit#(64)) shift_response();
endinterface

typedef BarrelShifterRightLogicalPipelined BarrelShifterRightArithmeticPipelined;
typedef BarrelShifterRightLogicalPipelined BarrelShifterLeftPipelined;

module mkBarrelShifterLeftPipelined(BarrelShifterLeftPipelined);
	/* TODO: Implement left shifter using the pipelined right shifter. */
	let bsrp <- mkBarrelShifterRightPipelined;

	method Action shift_request(Bit#(64) operand, Bit#(6) shamt);
		Bit#(64) reverse=0;
		for(Integer i=0;i<64;i=i+1)
			reverse[i] = operand[63-i];
		bsrp.shift_request(reverse,shamt,0);
	endmethod

	method ActionValue#(Bit#(64)) shift_response();
		let operand <- bsrp.shift_response();
		Bit#(64) result = 0;
		for(Integer i=0;i<64;i=i+1)
			result[i] = operand[63-i];
		return result;
	endmethod
endmodule

module mkBarrelShifterRightLogicalPipelined(BarrelShifterRightLogicalPipelined);
	/* TODO: Implement right logical shifter using the pipelined right shifter. */
	let bsrp <- mkBarrelShifterRightPipelined;

	method Action shift_request(Bit#(64) operand, Bit#(6) shamt);
		bsrp.shift_request(operand,shamt,0);
	endmethod

	method ActionValue#(Bit#(64)) shift_response();
		let result <- bsrp.shift_response();
		return result;
	endmethod
endmodule

module mkBarrelShifterRightArithmeticPipelined(BarrelShifterRightArithmeticPipelined);
	/* TODO: Implement right arithmetic shifter using the pipelined right shifter. */
	let bsrp <- mkBarrelShifterRightPipelined;

	method Action shift_request(Bit#(64) operand, Bit#(6) shamt);
		bsrp.shift_request(operand,shamt,operand[63]);
	endmethod

	method ActionValue#(Bit#(64)) shift_response();
		let result <- bsrp.shift_response();
		return result;
	endmethod
endmodule
