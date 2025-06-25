import Types::*;
import ProcTypes::*;
import CMemTypes::*;
import MemInit::*;
import RFile::*;
import IMemory::*;
import DMemory::*;
import Decode::*;
import Exec::*;
import CsrFile::*;
import Fifo::*;
import GetPut::*;

/*typedef struct {
  Instruction inst;
  Addr pc;
  Addr ppc;
  Bool epoch;
} Fetch2Rest deriving(Bits, Eq); */

typedef struct {
  Instruction inst;
  Addr pc;
  Addr ppc;
  Bool epoch;
} Fetch2Decode deriving(Bits,Eq);

typedef struct {
  DecodedInst dInst;
  Addr pc;
  Addr ppc;
  Bool epoch;
} Decode2Execute deriving(Bits,Eq);

typedef struct {
  ExecInst eInst;
  Addr pc;
  Addr ppc;
  Bool epoch;
  Bool isKill;
} Execute2Memory deriving(Bits,Eq);

typedef struct {
  ExecInst eInst;
  Addr pc;
  Addr ppc;
  Bool epoch;
  Bool isKill;
} Memory2WriteBack deriving(Bits,Eq);

(*synthesize*)
module mkProc(Proc);
  Reg#(Addr)    pc  <- mkRegU;
  RFile         rf  <- mkBypassRFile; // Use the BypassRFile to handle the hazards. (wr < rd, Refer to M10.)
  //RFile         rf  <- mkRFile;
  IMemory     iMem  <- mkIMemory;
  DMemory     dMem  <- mkDMemory;
  CsrFile     csrf <- mkCsrFile;

  // The control hazard is handled using two Epoch registers and one BypassFifo.
  Reg#(Bool) fEpoch <- mkRegU;
  Reg#(Bool) eEpoch <- mkRegU;
  Fifo#(1, Addr) execRedirect <- mkBypassFifo;
   
  // PipelineFifo to construct the two-stage pipeline (Fetch stage and Rest stage).
  //Fifo#(1, Fetch2Rest)  f2r <- mkPipelineFifo;
  Fifo#(1, Fetch2Decode)  f2d <- mkPipelineFifo;
  Fifo#(1, Decode2Execute)  d2e <- mkPipelineFifo;
  Fifo#(1, Execute2Memory)  e2m <- mkPipelineFifo;
  Fifo#(1, Memory2WriteBack)  m2w <- mkPipelineFifo;

 /* Reg#(Maybe#(RIndx)) exMemRd <- mkReg(Invalid);
  Reg#(Maybe#(RIndx)) memWbRd <- mkReg(Invalid);
  Reg#(Data) exMemData <- mkRegU;
  Reg#(Data) memWbData <- mkRegU;
  Reg#(Bool) exMemRegWrite <- mkReg(False);
  Reg#(Bool) memWbRegWrite <- mkReg(False);

  Reg#(Bool) loadUseHazard <- mkReg(False); */

  Fifo#(1, Tuple3#(Maybe#(RIndx), Data, Bool)) exMemFwd <- mkBypassFifo;
  Fifo#(1, Tuple3#(Maybe#(RIndx), Data, Bool)) memWbFwd <- mkBypassFifo;
  //레지스터로 삽질했는데 약 2배 사이클이 나옴 왜 그런지는 모르겠음


  Fifo#(1,ExecInst) previousInst <- mkBypassFifo;
  //Reg#(DecodedInst) previousInst <- mkRegU;   // 유효한 명령어만 넘기기 위해서 FiFo 사용



  /*function Data forwardRs1(DecodedInst dInst, Data rVal1);
    Data result = rVal1;
    if (isValid(dInst.src1)) begin
        let src1 = validValue(dInst.src1);
        
        if (exMemRegWrite && isValid(exMemRd) && (validValue(exMemRd) == src1)) begin
            result = exMemData;
        end
        else if (memWbRegWrite && isValid(memWbRd) && (validValue(memWbRd) == src1)) begin
            result = memWbData;
        end
    end
    return result;
endfunction

function Data forwardRs2(DecodedInst dInst, Data rVal2);
    Data result = rVal2;
    if (isValid(dInst.src2)) begin
        let src2 = validValue(dInst.src2);
        
        if (exMemRegWrite && isValid(exMemRd) && (validValue(exMemRd) == src2)) begin
            result = exMemData;
        end
        else if (memWbRegWrite && isValid(memWbRd) && (validValue(memWbRd) == src2)) begin
            result = memWbData;
        end
    end
    return result;
endfunction */

function Data getForwardedValue(
    RIndx src,
    Data regVal,
    Tuple3#(Maybe#(RIndx), Data, Bool) exMemVal,
    Tuple3#(Maybe#(RIndx), Data, Bool) memWbVal
);
    // EX/MEM 우선 검사시킴
    if (tpl_3(exMemVal) && isValid(tpl_1(exMemVal)) && validValue(tpl_1(exMemVal)) == src) begin
        return tpl_2(exMemVal);
    end
    // MEM/WB 다음으로 검사시킴
    else if (tpl_3(memWbVal) && isValid(tpl_1(memWbVal)) && validValue(tpl_1(memWbVal)) == src) begin
        return tpl_2(memWbVal);
    end
    // 포워딩 없으면 기본 regVal값 아용
    else begin
        return regVal;
    end
endfunction



 /* Lab 6-2: TODO) - Implement a 5-stage pipelined processor using a data forwarding (bypassing) logic. 
                   - To begin with, it is recommended that you reuse the code that you implemented in Lab 6-1.
                   - Define the correct bypassing units using BypassFiFo. */
               
  /*rule doFetch(csrf.started);
   	let inst = iMem.req(pc);
   	let ppc = pc + 4;

    if(execRedirect.notEmpty) begin
      execRedirect.deq;
      pc <= execRedirect.first;
      fEpoch <= !fEpoch;
    end
    else begin
      pc <= ppc;
    end

    f2r.enq(Fetch2Rest{inst:inst, pc:pc, ppc:ppc, epoch:fEpoch}); 
  endrule

  rule doRest(csrf.started);
    let inst   = f2r.first.inst;
    let pc   = f2r.first.pc;
    let ppc    = f2r.first.ppc;
    let iEpoch = f2r.first.epoch;
    f2r.deq;

    if(iEpoch == eEpoch) begin
      	// Decode 
   	    let dInst = decode(inst);

        // Register Read 
        let rVal1 = isValid(dInst.src1) ? rf.rd1(validValue(dInst.src1)) : ?;
        let rVal2 = isValid(dInst.src2) ? rf.rd2(validValue(dInst.src2)) : ?;
        let csrVal = isValid(dInst.csr) ? csrf.rd(validValue(dInst.csr)) : ?;

    		// Execute         
        let eInst = exec(dInst, rVal1, rVal2, pc, ppc, csrVal);               
        
        if(eInst.mispredict) begin
          eEpoch <= !eEpoch;
          execRedirect.enq(eInst.addr);
        end

      //Memory 
      let iType = eInst.iType;
      case(iType)
        Ld :
        begin
          let d <- dMem.req(MemReq{op: Ld, addr: eInst.addr, data: ?});
          eInst.data = d;
        end

        St:
        begin
          let d <- dMem.req(MemReq{op: St, addr: eInst.addr, data: eInst.data});
        end
        Unsupported :
        begin
          $fwrite(stderr, "ERROR: Executing unsupported instruction\n");
          $finish;
        end
      endcase

      //WriteBack 
      if (isValid(eInst.dst)) begin
          rf.wr(fromMaybe(?, eInst.dst), eInst.data);
      end
      csrf.wr(eInst.iType == Csrw ? eInst.csr : Invalid, eInst.data);

      
  end
  endrule */
//

  rule doFetch(csrf.started);
    let inst = iMem.req(pc);
   	let ppc = pc + 4;

    if(execRedirect.notEmpty) begin
      execRedirect.deq;
      pc <= execRedirect.first;
      fEpoch <= !fEpoch;
    end
    else begin
      pc <= ppc;
      f2d.enq(Fetch2Decode{inst:inst, pc:pc, ppc:ppc, epoch:fEpoch});
    end

    //f2d.enq(Fetch2Decode{inst:inst, pc:pc, ppc:ppc, epoch:fEpoch});
  endrule

  rule doDecode(csrf.started);
    let inst = f2d.first.inst;
    let pc = f2d.first.pc;
    let ppc = f2d.first.ppc;
    let iEpoch = f2d.first.epoch;

    let dInst = decode(inst);

    let hazard = False;
    /*if (previousInst.iType == Ld) begin
      if(isValid(dInst.src1) && validValue(dInst.src1) == validValue(previousInst.dst)) hazard = True;
      if(isValid(dInst.src2) && validValue(dInst.src2) == validValue(previousInst.dst)) hazard = True;
    end*/
    //loadUseHazard <= hazard;

    if (previousInst.notEmpty) begin
      let eInst = previousInst.first;
      previousInst.deq;
      if (eInst.iType == Ld) begin
        if(isValid(dInst.src1) && validValue(dInst.src1) == validValue(eInst.dst)) hazard = True;
      if(isValid(dInst.src2) && validValue(dInst.src2) == validValue(eInst.dst)) hazard = True;
      end
    end

    //if (hazard) begin
      //previousInst.iType <= Unsupported;
    //end
    if (!hazard) begin
      f2d.deq;
      d2e.enq(Decode2Execute{
        pc: pc, ppc: ppc, 
        dInst: dInst, epoch: iEpoch
      });
      //previousInst <= dInst;
    end
  endrule

  rule doExecute(csrf.started);
    let entry = d2e.first;  // pc 다 치기 귀찮
    d2e.deq;
    let dInst = entry.dInst;

    // 레지스터 값 읽기
    /*let rVal1 = isValid(dInst.src1) ? rf.rd1(validValue(dInst.src1)) : 0;
    let rVal2 = isValid(dInst.src2) ? rf.rd2(validValue(dInst.src2)) : 0;
    let csrVal = isValid(dInst.csr) ? csrf.rd(validValue(dInst.csr)) : ?;
    
    // Forwarding 적용
    let fwdVal1 = forwardRs1(dInst, rVal1);
    let fwdVal2 = forwardRs2(dInst, rVal2);*/

    let exMemVal = exMemFwd.notEmpty ? exMemFwd.first : tuple3(Invalid, 0, False);
    let memWbVal = memWbFwd.notEmpty ? memWbFwd.first : tuple3(Invalid, 0, False);
    let csrVal = isValid(dInst.csr) ? csrf.rd(validValue(dInst.csr)) : ?;

    if (exMemFwd.notEmpty) exMemFwd.deq(); // forwarding 하려는 값을 받을때만 deq시킴
    if (memWbFwd.notEmpty) memWbFwd.deq();

    // 레지스터 값 읽기 + 포워딩 적용
    let rVal1 = isValid(dInst.src1) ? 
    getForwardedValue(validValue(dInst.src1), rf.rd1(validValue(dInst.src1)), exMemVal,memWbVal) : 0;
    
    let rVal2 = isValid(dInst.src2) ? 
    getForwardedValue(validValue(dInst.src2), rf.rd2(validValue(dInst.src2)), exMemVal, memWbVal) : 0;

    let eInst = exec(dInst, rVal1, rVal2, entry.pc, entry.ppc, csrVal);

    if (eInst.mispredict) begin
        eEpoch <= !eEpoch;
        execRedirect.enq(eInst.addr);
      end

    Bool kill = (entry.epoch != eEpoch);

    if (!kill)
      previousInst.enq(eInst);  // 유효한 명령어만 전송송


    Bool   isLoad = (eInst.iType == Ld);
    /*if (!kill) begin
      if (isLoad) begin
        exMemRd       <= tagged Invalid;
        exMemData     <= 0;
        exMemRegWrite <= False;
      end else begin
        exMemRd       <= eInst.dst;
        exMemData     <= eInst.data;
        exMemRegWrite <= isValid(eInst.dst);
      end
    end else begin
      exMemRd       <= tagged Invalid;
      exMemData     <= 0;
      exMemRegWrite <= False;
    end */ // 레지스터를 사용할때때

    e2m.enq(Execute2Memory{pc:entry.pc, ppc:entry.ppc, epoch:entry.epoch, eInst:eInst, isKill:kill});
  endrule

  rule doMemory(csrf.started);
    let entry = e2m.first;
    e2m.deq;
    let eInst = entry.eInst;
    let isKill = entry.isKill;
    //Bool isLoad = (eInst.iType == Ld);

    // 메모리 접근
    if (!isKill) begin
    let iType = eInst.iType;
      case(iType)
        Ld :
        begin
          let d <- dMem.req(MemReq{op: Ld, addr: eInst.addr, data: ?});
          eInst.data = d;
        end

        St:
        begin
          let d <- dMem.req(MemReq{op: St, addr: eInst.addr, data: eInst.data});
        end
        Unsupported :
        begin
          $fwrite(stderr, "ERROR: Executing unsupported instruction\n");
          $finish;
        end
      endcase
      end

    /*if (!isKill) begin
    memWbRd <= eInst.dst;
    memWbData <= eInst.data;
    memWbRegWrite <= isValid(eInst.dst);
      end 
      else begin
        memWbRd <= tagged Invalid;
    memWbData <= 0;
    memWbRegWrite <= False;
      end */


    if (!isKill) begin
        exMemFwd.enq(tuple3(eInst.dst, eInst.data, isValid(eInst.dst)));
    end
    else begin
        exMemFwd.enq(tuple3(Invalid, 0, False));
    end
    
    m2w.enq(Memory2WriteBack{pc: entry.pc, ppc: entry.ppc, epoch: entry.epoch, eInst: eInst, isKill : isKill});
  endrule

  rule doWriteBack(csrf.started);
    let wb = m2w.first;
    m2w.deq;
    let eInst = wb.eInst;

    if (!wb.isKill) begin
        memWbFwd.enq(tuple3(eInst.dst, eInst.data, isValid(eInst.dst)));
    end
    else begin
        memWbFwd.enq(tuple3(Invalid, 0, False));
    end

    if(!wb.isKill) begin
      if (isValid(eInst.dst)) begin
        rf.wr(fromMaybe(?, eInst.dst), eInst.data);
      end

      csrf.wr(eInst.iType == Csrw ? eInst.csr : Invalid, eInst.data);
    end
  endrule


  method ActionValue#(CpuToHostData) cpuToHost;
    let retV <- csrf.cpuToHost;
    return retV;
  endmethod

  method Action hostToCpu(Bit#(32) startpc) if (!csrf.started);
    csrf.start(0);
    eEpoch <= False;
    fEpoch <= False;
    pc <= startpc;
  endmethod

  interface iMemInit = iMem.init;
  interface dMemInit = dMem.init;

endmodule
