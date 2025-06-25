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
import Scoreboard::*;
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
} Fetch2Decode deriving(Bits, Eq);

typedef struct {
  DecodedInst dInst;
  Addr pc;
  Addr ppc;
  Bool epoch;
} Decode2Execute deriving(Bits, Eq);

typedef struct {
  ExecInst eInst;
  Addr pc;
  Addr ppc;
  Bool epoch;
  Bool isKill;
} Execute2Memory deriving(Bits, Eq);

typedef struct {
  ExecInst eInst;
  Addr pc;
  Addr ppc;
  Bool epoch;
  Bool isKill;
} Memory2WriteBack deriving(Bits, Eq);

(*synthesize*)
module mkProc(Proc);
  Reg#(Addr)    pc  <- mkRegU;
  RFile         rf  <- mkBypassRFile;  // Use the BypassRFile to handle the hazards. (wr < rd, Refer to M10.)
  //RFile         rf  <- mkRFile;
  IMemory     iMem  <- mkIMemory;
  DMemory     dMem  <- mkDMemory;
  CsrFile     csrf <- mkCsrFile;
  
  // The control hazard is handled using two Epoch registers and one BypassFifo.
  Reg#(Bool) fEpoch <- mkRegU;
  Reg#(Bool) eEpoch <- mkRegU;
  Fifo#(1, Addr) execRedirect <- mkBypassFifo; 

  //Fifo#(1, Bool) isStall <- mkBypassFifo;  쓸모없음
  
  // PipelineFifo to construct the two-stage pipeline (Fetch stage and Rest stage).
  //Fifo#(1, Fetch2Rest)  f2r <- mkPipelineFifo;
  Fifo#(1, Fetch2Decode)  f2d <- mkPipelineFifo;
  Fifo#(1, Decode2Execute)  d2e <- mkPipelineFifo;
  Fifo#(1, Execute2Memory)  e2m <- mkPipelineFifo;
  Fifo#(1, Memory2WriteBack)  m2w <- mkPipelineFifo;

  // Scoreboard instantiation. Use this module to address the data hazard. 
  // Refer to scoreboard.bsv in the 'common-lib' directory.
  Scoreboard#(4) sb <- mkPipelineScoreboard;


/* Lab 6-1: TODO) - Implement a 5-stage pipelined processor using the provided scoreboard.
                  - Refer to common-lib/scoreboard.bsv and the PowerPoint slides.
                  - Use the scoreboard interface properly. */
  
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

  rule doFetch(csrf.started);
    let inst = iMem.req(pc);
   	let ppc = pc + 4;

    /*if(isStall.notEmpty) begin
      isStall.deq;  //stall을 계속 빼줌 / 기존에는 else문에 아래 코드를 넣음 한 사이클 밀리는 듯 
    end */ // 다시 생각해보니 stall이라는 bypassfifo를 만들 필요가 없네 어차피 f2d.enq를 못하면 그게 stall이니깐
    
    if(execRedirect.notEmpty) begin  // isStall.deq를 할때는 pc를 바꾸면 안되는거 아닌가?
      execRedirect.deq;
      pc <= execRedirect.first;
      fEpoch <= !fEpoch;
      //f2d.enq(Fetch2Decode{inst:inst, pc:pc, ppc:ppc, epoch:fEpoch}); 이미 잘못된건데 넣을 필요가 없음
    end
    else begin
      f2d.enq(Fetch2Decode{inst:inst, pc:pc, ppc:ppc, epoch:fEpoch}); // 어차피 stall되면 f2d안에 못넣음
      pc <= ppc;
    end

  endrule

  rule doDecode(csrf.started);
    let dInst = decode(f2d.first.inst);
    //let stall = (isValid(dInst.src1) && sb.search1(dInst.src1)) || (isValid(dInst.src2) && sb.search2(dInst.src2));
    let stall = sb.search1(dInst.src1) || sb.search2(dInst.src2);
    let pc = f2d.first.pc;
    let ppc = f2d.first.ppc;
    let iEpoch = f2d.first.epoch;
    
    if(!stall) begin
      f2d.deq;
      d2e.enq(Decode2Execute{pc:pc, ppc:ppc,dInst:dInst,epoch:iEpoch});
      sb.insert(dInst.dst);
    end 
    //else isStall.enq(stall);

  endrule

  rule doExecute(csrf.started);
    let dInst = d2e.first.dInst;
    let pc = d2e.first.pc;
    let ppc = d2e.first.ppc;
    let inEp = d2e.first.epoch;
    d2e.deq;

    let rVal1 = isValid(dInst.src1) ? rf.rd1(validValue(dInst.src1)) : ?;
    let rVal2 = isValid(dInst.src2) ? rf.rd2(validValue(dInst.src2)) : ?;
    let csrVal = isValid(dInst.csr) ? csrf.rd(validValue(dInst.csr)) : ?;
 
    let eInst = exec(dInst, rVal1, rVal2, pc, ppc, csrVal);

    if (inEp == eEpoch) begin

      if(eInst.mispredict) begin
        eEpoch <= !eEpoch;
        execRedirect.enq(eInst.addr);
      end
      e2m.enq(Execute2Memory{pc:pc, ppc:ppc, epoch : inEp, eInst : eInst,isKill:False});
    end
    else e2m.enq(Execute2Memory{pc:pc, ppc:ppc, epoch : inEp, eInst : eInst,isKill:True});
    // else문에서 sb.remove하면 안됨!! sb에서 삭제하면 순서가 깨짐... 파이프라인 끝에서 sb.remove 해야된다다
  endrule

  rule doMemory(csrf.started);
    let eInst = e2m.first.eInst;
    let pc = e2m.first.pc;
    let ppc = e2m.first.ppc;
    let inEp = e2m.first.epoch;
    let isKill = e2m.first.isKill;
    e2m.deq;

    if(!isKill) begin
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

      m2w.enq(Memory2WriteBack{pc:pc, ppc:ppc, epoch : inEp, eInst : eInst,isKill:isKill});

  endrule

  rule doWriteBack(csrf.started);
    let eInst = m2w.first.eInst;
    let pc = m2w.first.pc;
    let ppc = m2w.first.ppc;
    let inEp = m2w.first.epoch;
    let isKill = m2w.first.isKill;
    m2w.deq;

    if (!isKill) begin
      if (isValid(eInst.dst)) begin
        rf.wr(fromMaybe(?, eInst.dst), eInst.data);
      end

      csrf.wr(eInst.iType == Csrw ? eInst.csr : Invalid, eInst.data);
    end

    sb.remove;
    
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
