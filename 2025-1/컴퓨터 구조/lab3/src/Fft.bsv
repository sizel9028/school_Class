import Vector::*;

import FftCommon::*;
import Fifo::*;

interface Fft;
  method Action enq(Vector#(FftPoints, ComplexData) in);
  method ActionValue#(Vector#(FftPoints, ComplexData)) deq;
endinterface

(* synthesize *)
module mkFftCombinational(Fft);
  Fifo#(2, Vector#(FftPoints, ComplexData)) inFifo <- mkCFFifo;
  Fifo#(2, Vector#(FftPoints, ComplexData)) outFifo <- mkCFFifo;
  Vector#(NumStages, Vector#(BflysPerStage, Bfly4)) bfly <- replicateM(replicateM(mkBfly4));

  function Vector#(FftPoints, ComplexData) stage_f(StageIdx stage, Vector#(FftPoints, ComplexData) stage_in);
    Vector#(FftPoints, ComplexData) stage_temp, stage_out;
    for (FftIdx i = 0; i < fromInteger(valueOf(BflysPerStage)); i = i + 1)
    begin
      FftIdx idx = i * 4;
      Vector#(4, ComplexData) x;
      Vector#(4, ComplexData) twid;
      for (FftIdx j = 0; j < 4; j = j + 1 )
      begin
        x[j] = stage_in[idx+j];
        twid[j] = getTwiddle(stage, idx+j);
      end
      let y = bfly[stage][i].bfly4(twid, x);    // bfly[stage][i] 를 여러개를 만듦 for문이 펼쳐지는거기 때문

      for(FftIdx j = 0; j < 4; j = j + 1 )
        stage_temp[idx+j] = y[j];
    end

    stage_out = permute(stage_temp);

    return stage_out;
  endfunction

  rule doFft;
    inFifo.deq;
    Vector#(4, Vector#(FftPoints, ComplexData)) stage_data;
    stage_data[0] = inFifo.first;

    for (StageIdx stage = 0; stage < 3; stage = stage + 1)
      stage_data[stage+1] = stage_f(stage, stage_data[stage]);
    outFifo.enq(stage_data[3]);
  endrule

  method Action enq(Vector#(FftPoints, ComplexData) in);
    inFifo.enq(in);
  endmethod

  method ActionValue#(Vector#(FftPoints, ComplexData)) deq;
    outFifo.deq;
    return outFifo.first;
  endmethod
endmodule

(* synthesize *)
module mkFftFolded(Fft);
  Fifo#(2, Vector#(FftPoints, ComplexData)) inFifo <- mkCFFifo;
  Fifo#(2, Vector#(FftPoints, ComplexData)) outFifo <- mkCFFifo;
  Vector#(BflysPerStage, Bfly4) bfly <- replicateM(mkBfly4);

  // super folded
  /*
  Reg#(Bit#(7)) currStage <- mkReg(0);
  Reg#(Vector#(FftPoints, ComplexData)) sReg <- mkRegU;

  function Vector#(FftPoints, ComplexData) f(Bit#(7) stagei, Vector#(FftPoints, ComplexData) stage_in);
    FftIdx i = truncate(stagei & 7'b0001111);
    FftIdx idx = i * 4;
    StageIdx stageIndex = truncateLSB(stagei);
    Vector#(4, ComplexData) x;
    Vector#(4, ComplexData) twid;
    for(FftIdx j=0;j<4;j=j+1) begin
      x[j] = stage_in[idx+j];
      twid[j] = getTwiddle(stageIndex,idx+j);
    end
    let y = bfly[0].bfly4(twid,x);
    Vector#(FftPoints, ComplexData) stage_tmp = stage_in;
    for(FftIdx j=0;j<4;j=j+1)  //왜 오류뜸? //let으로 선언한 변수는 for문으로 수정 불가능
      stage_tmp[idx+j] = y[j];
    Vector#(FftPoints, ComplexData) result = stage_tmp;
    if (i == 15)
      result = permute(stage_tmp);
    return(result);
  endfunction

  rule stage_1 (currStage == 0);
    sReg <= f(currStage,inFifo.first());
    currStage <= currStage + 1;
    inFifo.deq();
  endrule

  rule stage_2 (currStage!=0 && currStage<47);
    sReg <= f(currStage,sReg);
    currStage <= currStage + 1;
  endrule

  rule stage_3 (currStage == 47);
    outFifo.enq(f(currStage,sReg));
    currStage <= 0;
  endrule
  */

  
  // folded
  Reg#(StageIdx) currStage <- mkReg(0);
  Reg#(Vector#(FftPoints, ComplexData)) sReg <- mkRegU;

  // You can copy & modify the stage_f function in the combinational implementation.
  function Vector#(FftPoints, ComplexData) stage_f(StageIdx stage, Vector#(FftPoints, ComplexData) stage_in);
    Vector#(FftPoints, ComplexData) stage_temp, stage_out;
    for (FftIdx i = 0; i < fromInteger(valueOf(BflysPerStage)); i = i + 1)
    begin
      FftIdx idx = i * 4;
      Vector#(4, ComplexData) x;
      Vector#(4, ComplexData) twid;
      for (FftIdx j = 0; j < 4; j = j + 1 )
      begin
        x[j] = stage_in[idx+j];
        twid[j] = getTwiddle(stage, idx+j);
      end
      let y = bfly[i].bfly4(twid, x);

      for(FftIdx j = 0; j < 4; j = j + 1 )
        stage_temp[idx+j] = y[j];
    end

    stage_out = permute(stage_temp);

    return stage_out;
  endfunction

  rule doFft_1 (currStage == 0);
    //TODO: Remove below two lines and Implement the rest of this module
    sReg <= stage_f(currStage,inFifo.first());
    currStage <= currStage + 1;
	  inFifo.deq;
  endrule

  rule doFft_2 (currStage == 1);
    sReg <= stage_f(currStage,sReg);
    currStage <= currStage + 1;
  endrule

  rule doFft_3 (currStage == 2);
    outFifo.enq(stage_f(currStage,sReg));
    currStage <= 0;
  endrule
  

  method Action enq(Vector#(FftPoints, ComplexData) in);
    inFifo.enq(in);
  endmethod

  method ActionValue#(Vector#(FftPoints, ComplexData)) deq;
    outFifo.deq;
    return outFifo.first;
  endmethod
endmodule

(* synthesize *)
module mkFftPipelined(Fft);
  Fifo#(2, Vector#(FftPoints, ComplexData)) inFifo <- mkCFFifo;
  Fifo#(2, Vector#(FftPoints, ComplexData)) outFifo <- mkCFFifo;
  Vector#(NumStages, Vector#(BflysPerStage, Bfly4)) bfly <- replicateM(replicateM(mkBfly4));
  Reg#(Maybe#(Vector#(FftPoints,ComplexData))) sReg1 <- mkReg(tagged Invalid);
  Reg#(Maybe#(Vector#(FftPoints,ComplexData))) sReg2 <- mkReg(tagged Invalid);

  // You can copy & modify the stage_f function in the combinational implementation.
  function Vector#(FftPoints, ComplexData) stage_f(StageIdx stage, Vector#(FftPoints, ComplexData) stage_in);
    Vector#(FftPoints, ComplexData) stage_temp, stage_out;
    for (FftIdx i = 0; i < fromInteger(valueOf(BflysPerStage)); i = i + 1)
    begin
      FftIdx idx = i * 4;
      Vector#(4, ComplexData) x;
      Vector#(4, ComplexData) twid;
      for (FftIdx j = 0; j < 4; j = j + 1 )
      begin
        x[j] = stage_in[idx+j];
        twid[j] = getTwiddle(stage, idx+j);
      end
      let y = bfly[stage][i].bfly4(twid, x);    // bfly[stage][i] 를 여러개를 만듦 for문이 펼쳐지는거기 때문

      for(FftIdx j = 0; j < 4; j = j + 1 )
        stage_temp[idx+j] = y[j];
    end

    stage_out = permute(stage_temp);

    return stage_out;
  endfunction
  // There are no constrains on using rules as long as their functionality remains accurate.

  /*rule doFft;
    //TODO: Remove below two lines Implement the rest of this module
	outFifo.enq(inFifo.first);
	inFifo.deq;
  endrule
  */

  rule pipe1;
    if(inFifo.notEmpty()) begin
      sReg1 <= tagged Valid stage_f(0,inFifo.first());
      inFifo.deq();
    end
    else
      sReg1 <= tagged Invalid;
    sReg2 <= isValid(sReg1) ? tagged Valid stage_f(1,validValue(sReg1)) : tagged Invalid;
    if (isValid(sReg2)) outFifo.enq(stage_f(2,validValue(sReg2)));
  endrule
  
  method Action enq(Vector#(FftPoints, ComplexData) in);
    inFifo.enq(in);
  endmethod

  method ActionValue#(Vector#(FftPoints, ComplexData)) deq;
    outFifo.deq;
    return outFifo.first;
  endmethod
endmodule
