"""Pin-level reference checks shared by RTL and gate-level simulation."""
import json
import os
import random
from pathlib import Path
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, Timer

HERE=Path(__file__).parent
INSTANCE=json.loads((HERE/'instance.json').read_text())
ROWS,TARGETS=INSTANCE['rows'],INSTANCE['targets']
PROTOCOL=json.loads((HERE/'protocol.json').read_text())
LATENCY=PROTOCOL['post_load_cycles']; STREAM=PROTOCOL['ordered_stream']

def sums(x):return [sum(c*((x>>j)&1) for j,c in enumerate(row)) for row in ROWS]
def expected(x):
 s=sums(x);syn=sum(((v-t)&1)<<r for r,(v,t) in enumerate(zip(s,TARGETS)))
 return syn|((syn==0)<<4)|(1<<5)|((s==TARGETS)<<6)

@cocotb.test()
async def test_matrix_and_protocol(dut):
 cocotb.start_soon(Clock(dut.clk,20,unit='ns').start())
 dut.ena.value=1;dut.ui_in.value=0;dut.uio_in.value=0;dut.rst_n.value=0
 async def step(we=0,sel=0,data=0,reset=False):
  await FallingEdge(dut.clk)
  dut.rst_n.value=0 if reset else 1
  dut.uio_in.value=0xa0|(we<<2)|sel;dut.ui_in.value=data
  await RisingEdge(dut.clk);await Timer(1,unit='ns')
  out=int(dut.uo_out.value)
  assert out>>7==0 and int(dut.uio_oe.value)==0 and int(dut.uio_out.value)==0
  return out
 async def load(x,gaps=False):
  for j in range(4):
   out=await step(1,j,((x>>(8*j))&255)|(192 if j==3 else 0))
   if j<3 or LATENCY:assert out&96==0,('early',j,out)
   if gaps and j<3:
    for _ in range(2):assert (await step())&96==0
  return out
 async def finish(x,out):
  assert out&31==expected(x)&31
  for c in range(1,LATENCY+1):
   out=await step()
   if c<LATENCY:assert out&96==0
  assert out==expected(x),(hex(x),out,expected(x))
  if os.environ.get('GATES')!='yes':
   assert [int(getattr(dut.user_project.exact,'acc'+str(r)).value) for r in range(4)]==sums(x)
  assert await step()==out
 async def reject():
  for _ in range(LATENCY+3):assert (await step())&96==0
 await step(reset=True)
 assert int(dut.uo_out.value)==13
 rng=random.Random(20260921)
 vectors=[int(v,16) for f in ['vectors.hex','special.hex'] for v in (HERE/f).read_text().split()]
 vectors += [0,(1<<30)-1]+[1<<j for j in range(30)]+[rng.getrandbits(30) for _ in range(10000)]
 hits=[x for x in vectors if sums(x)==TARGETS]; assert hits
 witness=hits[0]
 for x in vectors:await finish(x,await load(x))
 if STREAM:
  for order in [(1,2,3),(0,2,3),(0,1,1,2,3),(0,1,3),(0,1,2,2,3),(0,1,2,0,3)]:
   for sel in order:await step(1,sel,0)
   await reject();await finish(witness,await load(witness))
  await step(1,0,0);await step(1,1,0);await step(reset=True)
  await step(1,2,0);await step(1,3,0);await reject()
  await finish(witness,await load(witness,True))
  await step(1,3,witness>>24);await reject()
  await step(1,0,0);await step(1,1,0);await step(1,2,0)
  await finish(witness,await load(witness))
 else:
  await load(witness)
  for _ in range(LATENCY//2):await step()
  out=await step(1,0,(witness&255)^1);assert out&96==0
  await finish(witness^1,out)
  await load(witness)
  for _ in range(LATENCY//2):await step()
  out=await step(reset=True);assert out&96==0
  await finish(0,out)
 dut._log.info('Checked %d assignments plus protocol cases',len(vectors))
