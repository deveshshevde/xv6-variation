
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00008117          	auipc	sp,0x8
    80000004:	91010113          	add	sp,sp,-1776 # 80007910 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	add	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	04a000ef          	jal	80000060 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	add	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	add	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000022:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000026:	0207e793          	or	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002a:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    8000002e:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000032:	577d                	li	a4,-1
    80000034:	177e                	sll	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80000038:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003c:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000040:	0027e793          	or	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000044:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    80000048:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	add	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000056:	14d79073          	csrw	stimecmp,a5

}
    8000005a:	6422                	ld	s0,8(sp)
    8000005c:	0141                	add	sp,sp,16
    8000005e:	8082                	ret

0000000080000060 <start>:
{
    80000060:	1141                	add	sp,sp,-16
    80000062:	e406                	sd	ra,8(sp)
    80000064:	e022                	sd	s0,0(sp)
    80000066:	0800                	add	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	add	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffddbbf>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	add	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	de278793          	add	a5,a5,-542 # 80000e62 <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	add	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80000096:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000009e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000a2:	2227e793          	or	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000a6:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srl	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b8:	f65ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000bc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c4:	30200073          	mret
}
    800000c8:	60a2                	ld	ra,8(sp)
    800000ca:	6402                	ld	s0,0(sp)
    800000cc:	0141                	add	sp,sp,16
    800000ce:	8082                	ret

00000000800000d0 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	715d                	add	sp,sp,-80
    800000d2:	e486                	sd	ra,72(sp)
    800000d4:	e0a2                	sd	s0,64(sp)
    800000d6:	f84a                	sd	s2,48(sp)
    800000d8:	0880                	add	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    800000da:	04c05263          	blez	a2,8000011e <consolewrite+0x4e>
    800000de:	fc26                	sd	s1,56(sp)
    800000e0:	f44e                	sd	s3,40(sp)
    800000e2:	f052                	sd	s4,32(sp)
    800000e4:	ec56                	sd	s5,24(sp)
    800000e6:	8a2a                	mv	s4,a0
    800000e8:	84ae                	mv	s1,a1
    800000ea:	89b2                	mv	s3,a2
    800000ec:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    800000ee:	5afd                	li	s5,-1
    800000f0:	4685                	li	a3,1
    800000f2:	8626                	mv	a2,s1
    800000f4:	85d2                	mv	a1,s4
    800000f6:	fbf40513          	add	a0,s0,-65
    800000fa:	16c020ef          	jal	80002266 <either_copyin>
    800000fe:	03550263          	beq	a0,s5,80000122 <consolewrite+0x52>
      break;
    uartputc(c);
    80000102:	fbf44503          	lbu	a0,-65(s0)
    80000106:	035000ef          	jal	8000093a <uartputc>
  for(i = 0; i < n; i++){
    8000010a:	2905                	addw	s2,s2,1
    8000010c:	0485                	add	s1,s1,1
    8000010e:	ff2991e3          	bne	s3,s2,800000f0 <consolewrite+0x20>
    80000112:	894e                	mv	s2,s3
    80000114:	74e2                	ld	s1,56(sp)
    80000116:	79a2                	ld	s3,40(sp)
    80000118:	7a02                	ld	s4,32(sp)
    8000011a:	6ae2                	ld	s5,24(sp)
    8000011c:	a039                	j	8000012a <consolewrite+0x5a>
    8000011e:	4901                	li	s2,0
    80000120:	a029                	j	8000012a <consolewrite+0x5a>
    80000122:	74e2                	ld	s1,56(sp)
    80000124:	79a2                	ld	s3,40(sp)
    80000126:	7a02                	ld	s4,32(sp)
    80000128:	6ae2                	ld	s5,24(sp)
  }

  return i;
}
    8000012a:	854a                	mv	a0,s2
    8000012c:	60a6                	ld	ra,72(sp)
    8000012e:	6406                	ld	s0,64(sp)
    80000130:	7942                	ld	s2,48(sp)
    80000132:	6161                	add	sp,sp,80
    80000134:	8082                	ret

0000000080000136 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000136:	711d                	add	sp,sp,-96
    80000138:	ec86                	sd	ra,88(sp)
    8000013a:	e8a2                	sd	s0,80(sp)
    8000013c:	e4a6                	sd	s1,72(sp)
    8000013e:	e0ca                	sd	s2,64(sp)
    80000140:	fc4e                	sd	s3,56(sp)
    80000142:	f852                	sd	s4,48(sp)
    80000144:	f456                	sd	s5,40(sp)
    80000146:	f05a                	sd	s6,32(sp)
    80000148:	1080                	add	s0,sp,96
    8000014a:	8aaa                	mv	s5,a0
    8000014c:	8a2e                	mv	s4,a1
    8000014e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000150:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000154:	0000f517          	auipc	a0,0xf
    80000158:	7bc50513          	add	a0,a0,1980 # 8000f910 <cons>
    8000015c:	299000ef          	jal	80000bf4 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000160:	0000f497          	auipc	s1,0xf
    80000164:	7b048493          	add	s1,s1,1968 # 8000f910 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000168:	00010917          	auipc	s2,0x10
    8000016c:	84090913          	add	s2,s2,-1984 # 8000f9a8 <cons+0x98>
  while(n > 0){
    80000170:	0b305d63          	blez	s3,8000022a <consoleread+0xf4>
    while(cons.r == cons.w){
    80000174:	0984a783          	lw	a5,152(s1)
    80000178:	09c4a703          	lw	a4,156(s1)
    8000017c:	0af71263          	bne	a4,a5,80000220 <consoleread+0xea>
      if(killed(myproc())){
    80000180:	772010ef          	jal	800018f2 <myproc>
    80000184:	775010ef          	jal	800020f8 <killed>
    80000188:	e12d                	bnez	a0,800001ea <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    8000018a:	85a6                	mv	a1,s1
    8000018c:	854a                	mv	a0,s2
    8000018e:	533010ef          	jal	80001ec0 <sleep>
    while(cons.r == cons.w){
    80000192:	0984a783          	lw	a5,152(s1)
    80000196:	09c4a703          	lw	a4,156(s1)
    8000019a:	fef703e3          	beq	a4,a5,80000180 <consoleread+0x4a>
    8000019e:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001a0:	0000f717          	auipc	a4,0xf
    800001a4:	77070713          	add	a4,a4,1904 # 8000f910 <cons>
    800001a8:	0017869b          	addw	a3,a5,1
    800001ac:	08d72c23          	sw	a3,152(a4)
    800001b0:	07f7f693          	and	a3,a5,127
    800001b4:	9736                	add	a4,a4,a3
    800001b6:	01874703          	lbu	a4,24(a4)
    800001ba:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001be:	4691                	li	a3,4
    800001c0:	04db8663          	beq	s7,a3,8000020c <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800001c4:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001c8:	4685                	li	a3,1
    800001ca:	faf40613          	add	a2,s0,-81
    800001ce:	85d2                	mv	a1,s4
    800001d0:	8556                	mv	a0,s5
    800001d2:	04a020ef          	jal	8000221c <either_copyout>
    800001d6:	57fd                	li	a5,-1
    800001d8:	04f50863          	beq	a0,a5,80000228 <consoleread+0xf2>
      break;

    dst++;
    800001dc:	0a05                	add	s4,s4,1
    --n;
    800001de:	39fd                	addw	s3,s3,-1

    if(c == '\n'){
    800001e0:	47a9                	li	a5,10
    800001e2:	04fb8d63          	beq	s7,a5,8000023c <consoleread+0x106>
    800001e6:	6be2                	ld	s7,24(sp)
    800001e8:	b761                	j	80000170 <consoleread+0x3a>
        release(&cons.lock);
    800001ea:	0000f517          	auipc	a0,0xf
    800001ee:	72650513          	add	a0,a0,1830 # 8000f910 <cons>
    800001f2:	29b000ef          	jal	80000c8c <release>
        return -1;
    800001f6:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    800001f8:	60e6                	ld	ra,88(sp)
    800001fa:	6446                	ld	s0,80(sp)
    800001fc:	64a6                	ld	s1,72(sp)
    800001fe:	6906                	ld	s2,64(sp)
    80000200:	79e2                	ld	s3,56(sp)
    80000202:	7a42                	ld	s4,48(sp)
    80000204:	7aa2                	ld	s5,40(sp)
    80000206:	7b02                	ld	s6,32(sp)
    80000208:	6125                	add	sp,sp,96
    8000020a:	8082                	ret
      if(n < target){
    8000020c:	0009871b          	sext.w	a4,s3
    80000210:	01677a63          	bgeu	a4,s6,80000224 <consoleread+0xee>
        cons.r--;
    80000214:	0000f717          	auipc	a4,0xf
    80000218:	78f72a23          	sw	a5,1940(a4) # 8000f9a8 <cons+0x98>
    8000021c:	6be2                	ld	s7,24(sp)
    8000021e:	a031                	j	8000022a <consoleread+0xf4>
    80000220:	ec5e                	sd	s7,24(sp)
    80000222:	bfbd                	j	800001a0 <consoleread+0x6a>
    80000224:	6be2                	ld	s7,24(sp)
    80000226:	a011                	j	8000022a <consoleread+0xf4>
    80000228:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    8000022a:	0000f517          	auipc	a0,0xf
    8000022e:	6e650513          	add	a0,a0,1766 # 8000f910 <cons>
    80000232:	25b000ef          	jal	80000c8c <release>
  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	bf7d                	j	800001f8 <consoleread+0xc2>
    8000023c:	6be2                	ld	s7,24(sp)
    8000023e:	b7f5                	j	8000022a <consoleread+0xf4>

0000000080000240 <consputc>:
{
    80000240:	1141                	add	sp,sp,-16
    80000242:	e406                	sd	ra,8(sp)
    80000244:	e022                	sd	s0,0(sp)
    80000246:	0800                	add	s0,sp,16
  if(c == BACKSPACE){
    80000248:	10000793          	li	a5,256
    8000024c:	00f50863          	beq	a0,a5,8000025c <consputc+0x1c>
    uartputc_sync(c);
    80000250:	604000ef          	jal	80000854 <uartputc_sync>
}
    80000254:	60a2                	ld	ra,8(sp)
    80000256:	6402                	ld	s0,0(sp)
    80000258:	0141                	add	sp,sp,16
    8000025a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000025c:	4521                	li	a0,8
    8000025e:	5f6000ef          	jal	80000854 <uartputc_sync>
    80000262:	02000513          	li	a0,32
    80000266:	5ee000ef          	jal	80000854 <uartputc_sync>
    8000026a:	4521                	li	a0,8
    8000026c:	5e8000ef          	jal	80000854 <uartputc_sync>
    80000270:	b7d5                	j	80000254 <consputc+0x14>

0000000080000272 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80000272:	1101                	add	sp,sp,-32
    80000274:	ec06                	sd	ra,24(sp)
    80000276:	e822                	sd	s0,16(sp)
    80000278:	e426                	sd	s1,8(sp)
    8000027a:	1000                	add	s0,sp,32
    8000027c:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    8000027e:	0000f517          	auipc	a0,0xf
    80000282:	69250513          	add	a0,a0,1682 # 8000f910 <cons>
    80000286:	16f000ef          	jal	80000bf4 <acquire>

  switch(c){
    8000028a:	47d5                	li	a5,21
    8000028c:	08f48f63          	beq	s1,a5,8000032a <consoleintr+0xb8>
    80000290:	0297c563          	blt	a5,s1,800002ba <consoleintr+0x48>
    80000294:	47a1                	li	a5,8
    80000296:	0ef48463          	beq	s1,a5,8000037e <consoleintr+0x10c>
    8000029a:	47c1                	li	a5,16
    8000029c:	10f49563          	bne	s1,a5,800003a6 <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    800002a0:	010020ef          	jal	800022b0 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002a4:	0000f517          	auipc	a0,0xf
    800002a8:	66c50513          	add	a0,a0,1644 # 8000f910 <cons>
    800002ac:	1e1000ef          	jal	80000c8c <release>
}
    800002b0:	60e2                	ld	ra,24(sp)
    800002b2:	6442                	ld	s0,16(sp)
    800002b4:	64a2                	ld	s1,8(sp)
    800002b6:	6105                	add	sp,sp,32
    800002b8:	8082                	ret
  switch(c){
    800002ba:	07f00793          	li	a5,127
    800002be:	0cf48063          	beq	s1,a5,8000037e <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002c2:	0000f717          	auipc	a4,0xf
    800002c6:	64e70713          	add	a4,a4,1614 # 8000f910 <cons>
    800002ca:	0a072783          	lw	a5,160(a4)
    800002ce:	09872703          	lw	a4,152(a4)
    800002d2:	9f99                	subw	a5,a5,a4
    800002d4:	07f00713          	li	a4,127
    800002d8:	fcf766e3          	bltu	a4,a5,800002a4 <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    800002dc:	47b5                	li	a5,13
    800002de:	0cf48763          	beq	s1,a5,800003ac <consoleintr+0x13a>
      consputc(c);
    800002e2:	8526                	mv	a0,s1
    800002e4:	f5dff0ef          	jal	80000240 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800002e8:	0000f797          	auipc	a5,0xf
    800002ec:	62878793          	add	a5,a5,1576 # 8000f910 <cons>
    800002f0:	0a07a683          	lw	a3,160(a5)
    800002f4:	0016871b          	addw	a4,a3,1
    800002f8:	0007061b          	sext.w	a2,a4
    800002fc:	0ae7a023          	sw	a4,160(a5)
    80000300:	07f6f693          	and	a3,a3,127
    80000304:	97b6                	add	a5,a5,a3
    80000306:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000030a:	47a9                	li	a5,10
    8000030c:	0cf48563          	beq	s1,a5,800003d6 <consoleintr+0x164>
    80000310:	4791                	li	a5,4
    80000312:	0cf48263          	beq	s1,a5,800003d6 <consoleintr+0x164>
    80000316:	0000f797          	auipc	a5,0xf
    8000031a:	6927a783          	lw	a5,1682(a5) # 8000f9a8 <cons+0x98>
    8000031e:	9f1d                	subw	a4,a4,a5
    80000320:	08000793          	li	a5,128
    80000324:	f8f710e3          	bne	a4,a5,800002a4 <consoleintr+0x32>
    80000328:	a07d                	j	800003d6 <consoleintr+0x164>
    8000032a:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    8000032c:	0000f717          	auipc	a4,0xf
    80000330:	5e470713          	add	a4,a4,1508 # 8000f910 <cons>
    80000334:	0a072783          	lw	a5,160(a4)
    80000338:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000033c:	0000f497          	auipc	s1,0xf
    80000340:	5d448493          	add	s1,s1,1492 # 8000f910 <cons>
    while(cons.e != cons.w &&
    80000344:	4929                	li	s2,10
    80000346:	02f70863          	beq	a4,a5,80000376 <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000034a:	37fd                	addw	a5,a5,-1
    8000034c:	07f7f713          	and	a4,a5,127
    80000350:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80000352:	01874703          	lbu	a4,24(a4)
    80000356:	03270263          	beq	a4,s2,8000037a <consoleintr+0x108>
      cons.e--;
    8000035a:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    8000035e:	10000513          	li	a0,256
    80000362:	edfff0ef          	jal	80000240 <consputc>
    while(cons.e != cons.w &&
    80000366:	0a04a783          	lw	a5,160(s1)
    8000036a:	09c4a703          	lw	a4,156(s1)
    8000036e:	fcf71ee3          	bne	a4,a5,8000034a <consoleintr+0xd8>
    80000372:	6902                	ld	s2,0(sp)
    80000374:	bf05                	j	800002a4 <consoleintr+0x32>
    80000376:	6902                	ld	s2,0(sp)
    80000378:	b735                	j	800002a4 <consoleintr+0x32>
    8000037a:	6902                	ld	s2,0(sp)
    8000037c:	b725                	j	800002a4 <consoleintr+0x32>
    if(cons.e != cons.w){
    8000037e:	0000f717          	auipc	a4,0xf
    80000382:	59270713          	add	a4,a4,1426 # 8000f910 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f0f70be3          	beq	a4,a5,800002a4 <consoleintr+0x32>
      cons.e--;
    80000392:	37fd                	addw	a5,a5,-1
    80000394:	0000f717          	auipc	a4,0xf
    80000398:	60f72e23          	sw	a5,1564(a4) # 8000f9b0 <cons+0xa0>
      consputc(BACKSPACE);
    8000039c:	10000513          	li	a0,256
    800003a0:	ea1ff0ef          	jal	80000240 <consputc>
    800003a4:	b701                	j	800002a4 <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003a6:	ee048fe3          	beqz	s1,800002a4 <consoleintr+0x32>
    800003aa:	bf21                	j	800002c2 <consoleintr+0x50>
      consputc(c);
    800003ac:	4529                	li	a0,10
    800003ae:	e93ff0ef          	jal	80000240 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003b2:	0000f797          	auipc	a5,0xf
    800003b6:	55e78793          	add	a5,a5,1374 # 8000f910 <cons>
    800003ba:	0a07a703          	lw	a4,160(a5)
    800003be:	0017069b          	addw	a3,a4,1
    800003c2:	0006861b          	sext.w	a2,a3
    800003c6:	0ad7a023          	sw	a3,160(a5)
    800003ca:	07f77713          	and	a4,a4,127
    800003ce:	97ba                	add	a5,a5,a4
    800003d0:	4729                	li	a4,10
    800003d2:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800003d6:	0000f797          	auipc	a5,0xf
    800003da:	5cc7ab23          	sw	a2,1494(a5) # 8000f9ac <cons+0x9c>
        wakeup(&cons.r);
    800003de:	0000f517          	auipc	a0,0xf
    800003e2:	5ca50513          	add	a0,a0,1482 # 8000f9a8 <cons+0x98>
    800003e6:	327010ef          	jal	80001f0c <wakeup>
    800003ea:	bd6d                	j	800002a4 <consoleintr+0x32>

00000000800003ec <consoleinit>:

void
consoleinit(void)
{
    800003ec:	1141                	add	sp,sp,-16
    800003ee:	e406                	sd	ra,8(sp)
    800003f0:	e022                	sd	s0,0(sp)
    800003f2:	0800                	add	s0,sp,16
  initlock(&cons.lock, "cons");
    800003f4:	00007597          	auipc	a1,0x7
    800003f8:	c0c58593          	add	a1,a1,-1012 # 80007000 <etext>
    800003fc:	0000f517          	auipc	a0,0xf
    80000400:	51450513          	add	a0,a0,1300 # 8000f910 <cons>
    80000404:	770000ef          	jal	80000b74 <initlock>

  uartinit();
    80000408:	3f4000ef          	jal	800007fc <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	0001f797          	auipc	a5,0x1f
    80000410:	69c78793          	add	a5,a5,1692 # 8001faa8 <devsw>
    80000414:	00000717          	auipc	a4,0x0
    80000418:	d2270713          	add	a4,a4,-734 # 80000136 <consoleread>
    8000041c:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000041e:	00000717          	auipc	a4,0x0
    80000422:	cb270713          	add	a4,a4,-846 # 800000d0 <consolewrite>
    80000426:	ef98                	sd	a4,24(a5)
}
    80000428:	60a2                	ld	ra,8(sp)
    8000042a:	6402                	ld	s0,0(sp)
    8000042c:	0141                	add	sp,sp,16
    8000042e:	8082                	ret

0000000080000430 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000430:	7179                	add	sp,sp,-48
    80000432:	f406                	sd	ra,40(sp)
    80000434:	f022                	sd	s0,32(sp)
    80000436:	1800                	add	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000438:	c219                	beqz	a2,8000043e <printint+0xe>
    8000043a:	08054063          	bltz	a0,800004ba <printint+0x8a>
    x = -xx;
  else
    x = xx;
    8000043e:	4881                	li	a7,0
    80000440:	fd040693          	add	a3,s0,-48

  i = 0;
    80000444:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80000446:	00007617          	auipc	a2,0x7
    8000044a:	31a60613          	add	a2,a2,794 # 80007760 <digits>
    8000044e:	883e                	mv	a6,a5
    80000450:	2785                	addw	a5,a5,1
    80000452:	02b57733          	remu	a4,a0,a1
    80000456:	9732                	add	a4,a4,a2
    80000458:	00074703          	lbu	a4,0(a4)
    8000045c:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000460:	872a                	mv	a4,a0
    80000462:	02b55533          	divu	a0,a0,a1
    80000466:	0685                	add	a3,a3,1
    80000468:	feb773e3          	bgeu	a4,a1,8000044e <printint+0x1e>

  if(sign)
    8000046c:	00088a63          	beqz	a7,80000480 <printint+0x50>
    buf[i++] = '-';
    80000470:	1781                	add	a5,a5,-32
    80000472:	97a2                	add	a5,a5,s0
    80000474:	02d00713          	li	a4,45
    80000478:	fee78823          	sb	a4,-16(a5)
    8000047c:	0028079b          	addw	a5,a6,2

  while(--i >= 0)
    80000480:	02f05963          	blez	a5,800004b2 <printint+0x82>
    80000484:	ec26                	sd	s1,24(sp)
    80000486:	e84a                	sd	s2,16(sp)
    80000488:	fd040713          	add	a4,s0,-48
    8000048c:	00f704b3          	add	s1,a4,a5
    80000490:	fff70913          	add	s2,a4,-1
    80000494:	993e                	add	s2,s2,a5
    80000496:	37fd                	addw	a5,a5,-1
    80000498:	1782                	sll	a5,a5,0x20
    8000049a:	9381                	srl	a5,a5,0x20
    8000049c:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004a0:	fff4c503          	lbu	a0,-1(s1)
    800004a4:	d9dff0ef          	jal	80000240 <consputc>
  while(--i >= 0)
    800004a8:	14fd                	add	s1,s1,-1
    800004aa:	ff249be3          	bne	s1,s2,800004a0 <printint+0x70>
    800004ae:	64e2                	ld	s1,24(sp)
    800004b0:	6942                	ld	s2,16(sp)
}
    800004b2:	70a2                	ld	ra,40(sp)
    800004b4:	7402                	ld	s0,32(sp)
    800004b6:	6145                	add	sp,sp,48
    800004b8:	8082                	ret
    x = -xx;
    800004ba:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004be:	4885                	li	a7,1
    x = -xx;
    800004c0:	b741                	j	80000440 <printint+0x10>

00000000800004c2 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004c2:	7155                	add	sp,sp,-208
    800004c4:	e506                	sd	ra,136(sp)
    800004c6:	e122                	sd	s0,128(sp)
    800004c8:	f0d2                	sd	s4,96(sp)
    800004ca:	0900                	add	s0,sp,144
    800004cc:	8a2a                	mv	s4,a0
    800004ce:	e40c                	sd	a1,8(s0)
    800004d0:	e810                	sd	a2,16(s0)
    800004d2:	ec14                	sd	a3,24(s0)
    800004d4:	f018                	sd	a4,32(s0)
    800004d6:	f41c                	sd	a5,40(s0)
    800004d8:	03043823          	sd	a6,48(s0)
    800004dc:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    800004e0:	0000f797          	auipc	a5,0xf
    800004e4:	4f07a783          	lw	a5,1264(a5) # 8000f9d0 <pr+0x18>
    800004e8:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    800004ec:	e3a1                	bnez	a5,8000052c <printf+0x6a>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800004ee:	00840793          	add	a5,s0,8
    800004f2:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    800004f6:	00054503          	lbu	a0,0(a0)
    800004fa:	26050763          	beqz	a0,80000768 <printf+0x2a6>
    800004fe:	fca6                	sd	s1,120(sp)
    80000500:	f8ca                	sd	s2,112(sp)
    80000502:	f4ce                	sd	s3,104(sp)
    80000504:	ecd6                	sd	s5,88(sp)
    80000506:	e8da                	sd	s6,80(sp)
    80000508:	e0e2                	sd	s8,64(sp)
    8000050a:	fc66                	sd	s9,56(sp)
    8000050c:	f86a                	sd	s10,48(sp)
    8000050e:	f46e                	sd	s11,40(sp)
    80000510:	4981                	li	s3,0
    if(cx != '%'){
    80000512:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80000516:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000051a:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000051e:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000522:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000526:	07000d93          	li	s11,112
    8000052a:	a815                	j	8000055e <printf+0x9c>
    acquire(&pr.lock);
    8000052c:	0000f517          	auipc	a0,0xf
    80000530:	48c50513          	add	a0,a0,1164 # 8000f9b8 <pr>
    80000534:	6c0000ef          	jal	80000bf4 <acquire>
  va_start(ap, fmt);
    80000538:	00840793          	add	a5,s0,8
    8000053c:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000540:	000a4503          	lbu	a0,0(s4)
    80000544:	fd4d                	bnez	a0,800004fe <printf+0x3c>
    80000546:	a481                	j	80000786 <printf+0x2c4>
      consputc(cx);
    80000548:	cf9ff0ef          	jal	80000240 <consputc>
      continue;
    8000054c:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000054e:	0014899b          	addw	s3,s1,1
    80000552:	013a07b3          	add	a5,s4,s3
    80000556:	0007c503          	lbu	a0,0(a5)
    8000055a:	1e050b63          	beqz	a0,80000750 <printf+0x28e>
    if(cx != '%'){
    8000055e:	ff5515e3          	bne	a0,s5,80000548 <printf+0x86>
    i++;
    80000562:	0019849b          	addw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    80000566:	009a07b3          	add	a5,s4,s1
    8000056a:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    8000056e:	1e090163          	beqz	s2,80000750 <printf+0x28e>
    80000572:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80000576:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    80000578:	c789                	beqz	a5,80000582 <printf+0xc0>
    8000057a:	009a0733          	add	a4,s4,s1
    8000057e:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    80000582:	03690763          	beq	s2,s6,800005b0 <printf+0xee>
    } else if(c0 == 'l' && c1 == 'd'){
    80000586:	05890163          	beq	s2,s8,800005c8 <printf+0x106>
    } else if(c0 == 'u'){
    8000058a:	0d990b63          	beq	s2,s9,80000660 <printf+0x19e>
    } else if(c0 == 'x'){
    8000058e:	13a90163          	beq	s2,s10,800006b0 <printf+0x1ee>
    } else if(c0 == 'p'){
    80000592:	13b90b63          	beq	s2,s11,800006c8 <printf+0x206>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 's'){
    80000596:	07300793          	li	a5,115
    8000059a:	16f90a63          	beq	s2,a5,8000070e <printf+0x24c>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    8000059e:	1b590463          	beq	s2,s5,80000746 <printf+0x284>
      consputc('%');
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    800005a2:	8556                	mv	a0,s5
    800005a4:	c9dff0ef          	jal	80000240 <consputc>
      consputc(c0);
    800005a8:	854a                	mv	a0,s2
    800005aa:	c97ff0ef          	jal	80000240 <consputc>
    800005ae:	b745                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 10, 1);
    800005b0:	f8843783          	ld	a5,-120(s0)
    800005b4:	00878713          	add	a4,a5,8
    800005b8:	f8e43423          	sd	a4,-120(s0)
    800005bc:	4605                	li	a2,1
    800005be:	45a9                	li	a1,10
    800005c0:	4388                	lw	a0,0(a5)
    800005c2:	e6fff0ef          	jal	80000430 <printint>
    800005c6:	b761                	j	8000054e <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'd'){
    800005c8:	03678663          	beq	a5,s6,800005f4 <printf+0x132>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005cc:	05878263          	beq	a5,s8,80000610 <printf+0x14e>
    } else if(c0 == 'l' && c1 == 'u'){
    800005d0:	0b978463          	beq	a5,s9,80000678 <printf+0x1b6>
    } else if(c0 == 'l' && c1 == 'x'){
    800005d4:	fda797e3          	bne	a5,s10,800005a2 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    800005d8:	f8843783          	ld	a5,-120(s0)
    800005dc:	00878713          	add	a4,a5,8
    800005e0:	f8e43423          	sd	a4,-120(s0)
    800005e4:	4601                	li	a2,0
    800005e6:	45c1                	li	a1,16
    800005e8:	6388                	ld	a0,0(a5)
    800005ea:	e47ff0ef          	jal	80000430 <printint>
      i += 1;
    800005ee:	0029849b          	addw	s1,s3,2
    800005f2:	bfb1                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    800005f4:	f8843783          	ld	a5,-120(s0)
    800005f8:	00878713          	add	a4,a5,8
    800005fc:	f8e43423          	sd	a4,-120(s0)
    80000600:	4605                	li	a2,1
    80000602:	45a9                	li	a1,10
    80000604:	6388                	ld	a0,0(a5)
    80000606:	e2bff0ef          	jal	80000430 <printint>
      i += 1;
    8000060a:	0029849b          	addw	s1,s3,2
    8000060e:	b781                	j	8000054e <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80000610:	06400793          	li	a5,100
    80000614:	02f68863          	beq	a3,a5,80000644 <printf+0x182>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000618:	07500793          	li	a5,117
    8000061c:	06f68c63          	beq	a3,a5,80000694 <printf+0x1d2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    80000620:	07800793          	li	a5,120
    80000624:	f6f69fe3          	bne	a3,a5,800005a2 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    80000628:	f8843783          	ld	a5,-120(s0)
    8000062c:	00878713          	add	a4,a5,8
    80000630:	f8e43423          	sd	a4,-120(s0)
    80000634:	4601                	li	a2,0
    80000636:	45c1                	li	a1,16
    80000638:	6388                	ld	a0,0(a5)
    8000063a:	df7ff0ef          	jal	80000430 <printint>
      i += 2;
    8000063e:	0039849b          	addw	s1,s3,3
    80000642:	b731                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	add	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4605                	li	a2,1
    80000652:	45a9                	li	a1,10
    80000654:	6388                	ld	a0,0(a5)
    80000656:	ddbff0ef          	jal	80000430 <printint>
      i += 2;
    8000065a:	0039849b          	addw	s1,s3,3
    8000065e:	bdc5                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 10, 0);
    80000660:	f8843783          	ld	a5,-120(s0)
    80000664:	00878713          	add	a4,a5,8
    80000668:	f8e43423          	sd	a4,-120(s0)
    8000066c:	4601                	li	a2,0
    8000066e:	45a9                	li	a1,10
    80000670:	4388                	lw	a0,0(a5)
    80000672:	dbfff0ef          	jal	80000430 <printint>
    80000676:	bde1                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80000678:	f8843783          	ld	a5,-120(s0)
    8000067c:	00878713          	add	a4,a5,8
    80000680:	f8e43423          	sd	a4,-120(s0)
    80000684:	4601                	li	a2,0
    80000686:	45a9                	li	a1,10
    80000688:	6388                	ld	a0,0(a5)
    8000068a:	da7ff0ef          	jal	80000430 <printint>
      i += 1;
    8000068e:	0029849b          	addw	s1,s3,2
    80000692:	bd75                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80000694:	f8843783          	ld	a5,-120(s0)
    80000698:	00878713          	add	a4,a5,8
    8000069c:	f8e43423          	sd	a4,-120(s0)
    800006a0:	4601                	li	a2,0
    800006a2:	45a9                	li	a1,10
    800006a4:	6388                	ld	a0,0(a5)
    800006a6:	d8bff0ef          	jal	80000430 <printint>
      i += 2;
    800006aa:	0039849b          	addw	s1,s3,3
    800006ae:	b545                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 16, 0);
    800006b0:	f8843783          	ld	a5,-120(s0)
    800006b4:	00878713          	add	a4,a5,8
    800006b8:	f8e43423          	sd	a4,-120(s0)
    800006bc:	4601                	li	a2,0
    800006be:	45c1                	li	a1,16
    800006c0:	4388                	lw	a0,0(a5)
    800006c2:	d6fff0ef          	jal	80000430 <printint>
    800006c6:	b561                	j	8000054e <printf+0x8c>
    800006c8:	e4de                	sd	s7,72(sp)
      printptr(va_arg(ap, uint64));
    800006ca:	f8843783          	ld	a5,-120(s0)
    800006ce:	00878713          	add	a4,a5,8
    800006d2:	f8e43423          	sd	a4,-120(s0)
    800006d6:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006da:	03000513          	li	a0,48
    800006de:	b63ff0ef          	jal	80000240 <consputc>
  consputc('x');
    800006e2:	07800513          	li	a0,120
    800006e6:	b5bff0ef          	jal	80000240 <consputc>
    800006ea:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006ec:	00007b97          	auipc	s7,0x7
    800006f0:	074b8b93          	add	s7,s7,116 # 80007760 <digits>
    800006f4:	03c9d793          	srl	a5,s3,0x3c
    800006f8:	97de                	add	a5,a5,s7
    800006fa:	0007c503          	lbu	a0,0(a5)
    800006fe:	b43ff0ef          	jal	80000240 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80000702:	0992                	sll	s3,s3,0x4
    80000704:	397d                	addw	s2,s2,-1
    80000706:	fe0917e3          	bnez	s2,800006f4 <printf+0x232>
    8000070a:	6ba6                	ld	s7,72(sp)
    8000070c:	b589                	j	8000054e <printf+0x8c>
      if((s = va_arg(ap, char*)) == 0)
    8000070e:	f8843783          	ld	a5,-120(s0)
    80000712:	00878713          	add	a4,a5,8
    80000716:	f8e43423          	sd	a4,-120(s0)
    8000071a:	0007b903          	ld	s2,0(a5)
    8000071e:	00090d63          	beqz	s2,80000738 <printf+0x276>
      for(; *s; s++)
    80000722:	00094503          	lbu	a0,0(s2)
    80000726:	e20504e3          	beqz	a0,8000054e <printf+0x8c>
        consputc(*s);
    8000072a:	b17ff0ef          	jal	80000240 <consputc>
      for(; *s; s++)
    8000072e:	0905                	add	s2,s2,1
    80000730:	00094503          	lbu	a0,0(s2)
    80000734:	f97d                	bnez	a0,8000072a <printf+0x268>
    80000736:	bd21                	j	8000054e <printf+0x8c>
        s = "(null)";
    80000738:	00007917          	auipc	s2,0x7
    8000073c:	8d090913          	add	s2,s2,-1840 # 80007008 <etext+0x8>
      for(; *s; s++)
    80000740:	02800513          	li	a0,40
    80000744:	b7dd                	j	8000072a <printf+0x268>
      consputc('%');
    80000746:	02500513          	li	a0,37
    8000074a:	af7ff0ef          	jal	80000240 <consputc>
    8000074e:	b501                	j	8000054e <printf+0x8c>
    }
#endif
  }
  va_end(ap);

  if(locking)
    80000750:	f7843783          	ld	a5,-136(s0)
    80000754:	e385                	bnez	a5,80000774 <printf+0x2b2>
    80000756:	74e6                	ld	s1,120(sp)
    80000758:	7946                	ld	s2,112(sp)
    8000075a:	79a6                	ld	s3,104(sp)
    8000075c:	6ae6                	ld	s5,88(sp)
    8000075e:	6b46                	ld	s6,80(sp)
    80000760:	6c06                	ld	s8,64(sp)
    80000762:	7ce2                	ld	s9,56(sp)
    80000764:	7d42                	ld	s10,48(sp)
    80000766:	7da2                	ld	s11,40(sp)
    release(&pr.lock);

  return 0;
}
    80000768:	4501                	li	a0,0
    8000076a:	60aa                	ld	ra,136(sp)
    8000076c:	640a                	ld	s0,128(sp)
    8000076e:	7a06                	ld	s4,96(sp)
    80000770:	6169                	add	sp,sp,208
    80000772:	8082                	ret
    80000774:	74e6                	ld	s1,120(sp)
    80000776:	7946                	ld	s2,112(sp)
    80000778:	79a6                	ld	s3,104(sp)
    8000077a:	6ae6                	ld	s5,88(sp)
    8000077c:	6b46                	ld	s6,80(sp)
    8000077e:	6c06                	ld	s8,64(sp)
    80000780:	7ce2                	ld	s9,56(sp)
    80000782:	7d42                	ld	s10,48(sp)
    80000784:	7da2                	ld	s11,40(sp)
    release(&pr.lock);
    80000786:	0000f517          	auipc	a0,0xf
    8000078a:	23250513          	add	a0,a0,562 # 8000f9b8 <pr>
    8000078e:	4fe000ef          	jal	80000c8c <release>
    80000792:	bfd9                	j	80000768 <printf+0x2a6>

0000000080000794 <panic>:

void
panic(char *s)
{
    80000794:	1101                	add	sp,sp,-32
    80000796:	ec06                	sd	ra,24(sp)
    80000798:	e822                	sd	s0,16(sp)
    8000079a:	e426                	sd	s1,8(sp)
    8000079c:	1000                	add	s0,sp,32
    8000079e:	84aa                	mv	s1,a0
  pr.locking = 0;
    800007a0:	0000f797          	auipc	a5,0xf
    800007a4:	2207a823          	sw	zero,560(a5) # 8000f9d0 <pr+0x18>
  printf("panic: ");
    800007a8:	00007517          	auipc	a0,0x7
    800007ac:	87050513          	add	a0,a0,-1936 # 80007018 <etext+0x18>
    800007b0:	d13ff0ef          	jal	800004c2 <printf>
  printf("%s\n", s);
    800007b4:	85a6                	mv	a1,s1
    800007b6:	00007517          	auipc	a0,0x7
    800007ba:	86a50513          	add	a0,a0,-1942 # 80007020 <etext+0x20>
    800007be:	d05ff0ef          	jal	800004c2 <printf>
  panicked = 1; // freeze uart output from other CPUs
    800007c2:	4785                	li	a5,1
    800007c4:	00007717          	auipc	a4,0x7
    800007c8:	10f72623          	sw	a5,268(a4) # 800078d0 <panicked>
  for(;;)
    800007cc:	a001                	j	800007cc <panic+0x38>

00000000800007ce <printfinit>:
    ;
}

void
printfinit(void)
{
    800007ce:	1101                	add	sp,sp,-32
    800007d0:	ec06                	sd	ra,24(sp)
    800007d2:	e822                	sd	s0,16(sp)
    800007d4:	e426                	sd	s1,8(sp)
    800007d6:	1000                	add	s0,sp,32
  initlock(&pr.lock, "pr");
    800007d8:	0000f497          	auipc	s1,0xf
    800007dc:	1e048493          	add	s1,s1,480 # 8000f9b8 <pr>
    800007e0:	00007597          	auipc	a1,0x7
    800007e4:	84858593          	add	a1,a1,-1976 # 80007028 <etext+0x28>
    800007e8:	8526                	mv	a0,s1
    800007ea:	38a000ef          	jal	80000b74 <initlock>
  pr.locking = 1;
    800007ee:	4785                	li	a5,1
    800007f0:	cc9c                	sw	a5,24(s1)
}
    800007f2:	60e2                	ld	ra,24(sp)
    800007f4:	6442                	ld	s0,16(sp)
    800007f6:	64a2                	ld	s1,8(sp)
    800007f8:	6105                	add	sp,sp,32
    800007fa:	8082                	ret

00000000800007fc <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007fc:	1141                	add	sp,sp,-16
    800007fe:	e406                	sd	ra,8(sp)
    80000800:	e022                	sd	s0,0(sp)
    80000802:	0800                	add	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000804:	100007b7          	lui	a5,0x10000
    80000808:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000080c:	10000737          	lui	a4,0x10000
    80000810:	f8000693          	li	a3,-128
    80000814:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000818:	468d                	li	a3,3
    8000081a:	10000637          	lui	a2,0x10000
    8000081e:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000822:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000826:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000082a:	10000737          	lui	a4,0x10000
    8000082e:	461d                	li	a2,7
    80000830:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000834:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000838:	00006597          	auipc	a1,0x6
    8000083c:	7f858593          	add	a1,a1,2040 # 80007030 <etext+0x30>
    80000840:	0000f517          	auipc	a0,0xf
    80000844:	19850513          	add	a0,a0,408 # 8000f9d8 <uart_tx_lock>
    80000848:	32c000ef          	jal	80000b74 <initlock>
}
    8000084c:	60a2                	ld	ra,8(sp)
    8000084e:	6402                	ld	s0,0(sp)
    80000850:	0141                	add	sp,sp,16
    80000852:	8082                	ret

0000000080000854 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000854:	1101                	add	sp,sp,-32
    80000856:	ec06                	sd	ra,24(sp)
    80000858:	e822                	sd	s0,16(sp)
    8000085a:	e426                	sd	s1,8(sp)
    8000085c:	1000                	add	s0,sp,32
    8000085e:	84aa                	mv	s1,a0
  push_off();
    80000860:	354000ef          	jal	80000bb4 <push_off>

  if(panicked){
    80000864:	00007797          	auipc	a5,0x7
    80000868:	06c7a783          	lw	a5,108(a5) # 800078d0 <panicked>
    8000086c:	e795                	bnez	a5,80000898 <uartputc_sync+0x44>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000086e:	10000737          	lui	a4,0x10000
    80000872:	0715                	add	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000874:	00074783          	lbu	a5,0(a4)
    80000878:	0207f793          	and	a5,a5,32
    8000087c:	dfe5                	beqz	a5,80000874 <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    8000087e:	0ff4f513          	zext.b	a0,s1
    80000882:	100007b7          	lui	a5,0x10000
    80000886:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000088a:	3ae000ef          	jal	80000c38 <pop_off>
}
    8000088e:	60e2                	ld	ra,24(sp)
    80000890:	6442                	ld	s0,16(sp)
    80000892:	64a2                	ld	s1,8(sp)
    80000894:	6105                	add	sp,sp,32
    80000896:	8082                	ret
    for(;;)
    80000898:	a001                	j	80000898 <uartputc_sync+0x44>

000000008000089a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000089a:	00007797          	auipc	a5,0x7
    8000089e:	03e7b783          	ld	a5,62(a5) # 800078d8 <uart_tx_r>
    800008a2:	00007717          	auipc	a4,0x7
    800008a6:	03e73703          	ld	a4,62(a4) # 800078e0 <uart_tx_w>
    800008aa:	08f70263          	beq	a4,a5,8000092e <uartstart+0x94>
{
    800008ae:	7139                	add	sp,sp,-64
    800008b0:	fc06                	sd	ra,56(sp)
    800008b2:	f822                	sd	s0,48(sp)
    800008b4:	f426                	sd	s1,40(sp)
    800008b6:	f04a                	sd	s2,32(sp)
    800008b8:	ec4e                	sd	s3,24(sp)
    800008ba:	e852                	sd	s4,16(sp)
    800008bc:	e456                	sd	s5,8(sp)
    800008be:	e05a                	sd	s6,0(sp)
    800008c0:	0080                	add	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008c2:	10000937          	lui	s2,0x10000
    800008c6:	0915                	add	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008c8:	0000fa97          	auipc	s5,0xf
    800008cc:	110a8a93          	add	s5,s5,272 # 8000f9d8 <uart_tx_lock>
    uart_tx_r += 1;
    800008d0:	00007497          	auipc	s1,0x7
    800008d4:	00848493          	add	s1,s1,8 # 800078d8 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008d8:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008dc:	00007997          	auipc	s3,0x7
    800008e0:	00498993          	add	s3,s3,4 # 800078e0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008e4:	00094703          	lbu	a4,0(s2)
    800008e8:	02077713          	and	a4,a4,32
    800008ec:	c71d                	beqz	a4,8000091a <uartstart+0x80>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008ee:	01f7f713          	and	a4,a5,31
    800008f2:	9756                	add	a4,a4,s5
    800008f4:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800008f8:	0785                	add	a5,a5,1
    800008fa:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    800008fc:	8526                	mv	a0,s1
    800008fe:	60e010ef          	jal	80001f0c <wakeup>
    WriteReg(THR, c);
    80000902:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    80000906:	609c                	ld	a5,0(s1)
    80000908:	0009b703          	ld	a4,0(s3)
    8000090c:	fcf71ce3          	bne	a4,a5,800008e4 <uartstart+0x4a>
      ReadReg(ISR);
    80000910:	100007b7          	lui	a5,0x10000
    80000914:	0789                	add	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80000916:	0007c783          	lbu	a5,0(a5)
  }
}
    8000091a:	70e2                	ld	ra,56(sp)
    8000091c:	7442                	ld	s0,48(sp)
    8000091e:	74a2                	ld	s1,40(sp)
    80000920:	7902                	ld	s2,32(sp)
    80000922:	69e2                	ld	s3,24(sp)
    80000924:	6a42                	ld	s4,16(sp)
    80000926:	6aa2                	ld	s5,8(sp)
    80000928:	6b02                	ld	s6,0(sp)
    8000092a:	6121                	add	sp,sp,64
    8000092c:	8082                	ret
      ReadReg(ISR);
    8000092e:	100007b7          	lui	a5,0x10000
    80000932:	0789                	add	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80000934:	0007c783          	lbu	a5,0(a5)
      return;
    80000938:	8082                	ret

000000008000093a <uartputc>:
{
    8000093a:	7179                	add	sp,sp,-48
    8000093c:	f406                	sd	ra,40(sp)
    8000093e:	f022                	sd	s0,32(sp)
    80000940:	ec26                	sd	s1,24(sp)
    80000942:	e84a                	sd	s2,16(sp)
    80000944:	e44e                	sd	s3,8(sp)
    80000946:	e052                	sd	s4,0(sp)
    80000948:	1800                	add	s0,sp,48
    8000094a:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    8000094c:	0000f517          	auipc	a0,0xf
    80000950:	08c50513          	add	a0,a0,140 # 8000f9d8 <uart_tx_lock>
    80000954:	2a0000ef          	jal	80000bf4 <acquire>
  if(panicked){
    80000958:	00007797          	auipc	a5,0x7
    8000095c:	f787a783          	lw	a5,-136(a5) # 800078d0 <panicked>
    80000960:	efbd                	bnez	a5,800009de <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000962:	00007717          	auipc	a4,0x7
    80000966:	f7e73703          	ld	a4,-130(a4) # 800078e0 <uart_tx_w>
    8000096a:	00007797          	auipc	a5,0x7
    8000096e:	f6e7b783          	ld	a5,-146(a5) # 800078d8 <uart_tx_r>
    80000972:	02078793          	add	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000976:	0000f997          	auipc	s3,0xf
    8000097a:	06298993          	add	s3,s3,98 # 8000f9d8 <uart_tx_lock>
    8000097e:	00007497          	auipc	s1,0x7
    80000982:	f5a48493          	add	s1,s1,-166 # 800078d8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000986:	00007917          	auipc	s2,0x7
    8000098a:	f5a90913          	add	s2,s2,-166 # 800078e0 <uart_tx_w>
    8000098e:	00e79d63          	bne	a5,a4,800009a8 <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000992:	85ce                	mv	a1,s3
    80000994:	8526                	mv	a0,s1
    80000996:	52a010ef          	jal	80001ec0 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000099a:	00093703          	ld	a4,0(s2)
    8000099e:	609c                	ld	a5,0(s1)
    800009a0:	02078793          	add	a5,a5,32
    800009a4:	fee787e3          	beq	a5,a4,80000992 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009a8:	0000f497          	auipc	s1,0xf
    800009ac:	03048493          	add	s1,s1,48 # 8000f9d8 <uart_tx_lock>
    800009b0:	01f77793          	and	a5,a4,31
    800009b4:	97a6                	add	a5,a5,s1
    800009b6:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009ba:	0705                	add	a4,a4,1
    800009bc:	00007797          	auipc	a5,0x7
    800009c0:	f2e7b223          	sd	a4,-220(a5) # 800078e0 <uart_tx_w>
  uartstart();
    800009c4:	ed7ff0ef          	jal	8000089a <uartstart>
  release(&uart_tx_lock);
    800009c8:	8526                	mv	a0,s1
    800009ca:	2c2000ef          	jal	80000c8c <release>
}
    800009ce:	70a2                	ld	ra,40(sp)
    800009d0:	7402                	ld	s0,32(sp)
    800009d2:	64e2                	ld	s1,24(sp)
    800009d4:	6942                	ld	s2,16(sp)
    800009d6:	69a2                	ld	s3,8(sp)
    800009d8:	6a02                	ld	s4,0(sp)
    800009da:	6145                	add	sp,sp,48
    800009dc:	8082                	ret
    for(;;)
    800009de:	a001                	j	800009de <uartputc+0xa4>

00000000800009e0 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009e0:	1141                	add	sp,sp,-16
    800009e2:	e422                	sd	s0,8(sp)
    800009e4:	0800                	add	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009e6:	100007b7          	lui	a5,0x10000
    800009ea:	0795                	add	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009ec:	0007c783          	lbu	a5,0(a5)
    800009f0:	8b85                	and	a5,a5,1
    800009f2:	cb81                	beqz	a5,80000a02 <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    800009f4:	100007b7          	lui	a5,0x10000
    800009f8:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009fc:	6422                	ld	s0,8(sp)
    800009fe:	0141                	add	sp,sp,16
    80000a00:	8082                	ret
    return -1;
    80000a02:	557d                	li	a0,-1
    80000a04:	bfe5                	j	800009fc <uartgetc+0x1c>

0000000080000a06 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000a06:	1101                	add	sp,sp,-32
    80000a08:	ec06                	sd	ra,24(sp)
    80000a0a:	e822                	sd	s0,16(sp)
    80000a0c:	e426                	sd	s1,8(sp)
    80000a0e:	1000                	add	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a10:	54fd                	li	s1,-1
    80000a12:	a019                	j	80000a18 <uartintr+0x12>
      break;
    consoleintr(c);
    80000a14:	85fff0ef          	jal	80000272 <consoleintr>
    int c = uartgetc();
    80000a18:	fc9ff0ef          	jal	800009e0 <uartgetc>
    if(c == -1)
    80000a1c:	fe951ce3          	bne	a0,s1,80000a14 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a20:	0000f497          	auipc	s1,0xf
    80000a24:	fb848493          	add	s1,s1,-72 # 8000f9d8 <uart_tx_lock>
    80000a28:	8526                	mv	a0,s1
    80000a2a:	1ca000ef          	jal	80000bf4 <acquire>
  uartstart();
    80000a2e:	e6dff0ef          	jal	8000089a <uartstart>
  release(&uart_tx_lock);
    80000a32:	8526                	mv	a0,s1
    80000a34:	258000ef          	jal	80000c8c <release>
}
    80000a38:	60e2                	ld	ra,24(sp)
    80000a3a:	6442                	ld	s0,16(sp)
    80000a3c:	64a2                	ld	s1,8(sp)
    80000a3e:	6105                	add	sp,sp,32
    80000a40:	8082                	ret

0000000080000a42 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a42:	1101                	add	sp,sp,-32
    80000a44:	ec06                	sd	ra,24(sp)
    80000a46:	e822                	sd	s0,16(sp)
    80000a48:	e426                	sd	s1,8(sp)
    80000a4a:	e04a                	sd	s2,0(sp)
    80000a4c:	1000                	add	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a4e:	03451793          	sll	a5,a0,0x34
    80000a52:	e7a9                	bnez	a5,80000a9c <kfree+0x5a>
    80000a54:	84aa                	mv	s1,a0
    80000a56:	00020797          	auipc	a5,0x20
    80000a5a:	1ea78793          	add	a5,a5,490 # 80020c40 <end>
    80000a5e:	02f56f63          	bltu	a0,a5,80000a9c <kfree+0x5a>
    80000a62:	47c5                	li	a5,17
    80000a64:	07ee                	sll	a5,a5,0x1b
    80000a66:	02f57b63          	bgeu	a0,a5,80000a9c <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a6a:	6605                	lui	a2,0x1
    80000a6c:	4585                	li	a1,1
    80000a6e:	25a000ef          	jal	80000cc8 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a72:	0000f917          	auipc	s2,0xf
    80000a76:	f9e90913          	add	s2,s2,-98 # 8000fa10 <kmem>
    80000a7a:	854a                	mv	a0,s2
    80000a7c:	178000ef          	jal	80000bf4 <acquire>
  r->next = kmem.freelist;
    80000a80:	01893783          	ld	a5,24(s2)
    80000a84:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a86:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a8a:	854a                	mv	a0,s2
    80000a8c:	200000ef          	jal	80000c8c <release>
}
    80000a90:	60e2                	ld	ra,24(sp)
    80000a92:	6442                	ld	s0,16(sp)
    80000a94:	64a2                	ld	s1,8(sp)
    80000a96:	6902                	ld	s2,0(sp)
    80000a98:	6105                	add	sp,sp,32
    80000a9a:	8082                	ret
    panic("kfree");
    80000a9c:	00006517          	auipc	a0,0x6
    80000aa0:	59c50513          	add	a0,a0,1436 # 80007038 <etext+0x38>
    80000aa4:	cf1ff0ef          	jal	80000794 <panic>

0000000080000aa8 <freerange>:
{
    80000aa8:	7179                	add	sp,sp,-48
    80000aaa:	f406                	sd	ra,40(sp)
    80000aac:	f022                	sd	s0,32(sp)
    80000aae:	ec26                	sd	s1,24(sp)
    80000ab0:	1800                	add	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ab2:	6785                	lui	a5,0x1
    80000ab4:	fff78713          	add	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ab8:	00e504b3          	add	s1,a0,a4
    80000abc:	777d                	lui	a4,0xfffff
    80000abe:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ac0:	94be                	add	s1,s1,a5
    80000ac2:	0295e263          	bltu	a1,s1,80000ae6 <freerange+0x3e>
    80000ac6:	e84a                	sd	s2,16(sp)
    80000ac8:	e44e                	sd	s3,8(sp)
    80000aca:	e052                	sd	s4,0(sp)
    80000acc:	892e                	mv	s2,a1
    kfree(p);
    80000ace:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ad0:	6985                	lui	s3,0x1
    kfree(p);
    80000ad2:	01448533          	add	a0,s1,s4
    80000ad6:	f6dff0ef          	jal	80000a42 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ada:	94ce                	add	s1,s1,s3
    80000adc:	fe997be3          	bgeu	s2,s1,80000ad2 <freerange+0x2a>
    80000ae0:	6942                	ld	s2,16(sp)
    80000ae2:	69a2                	ld	s3,8(sp)
    80000ae4:	6a02                	ld	s4,0(sp)
}
    80000ae6:	70a2                	ld	ra,40(sp)
    80000ae8:	7402                	ld	s0,32(sp)
    80000aea:	64e2                	ld	s1,24(sp)
    80000aec:	6145                	add	sp,sp,48
    80000aee:	8082                	ret

0000000080000af0 <kinit>:
{
    80000af0:	1141                	add	sp,sp,-16
    80000af2:	e406                	sd	ra,8(sp)
    80000af4:	e022                	sd	s0,0(sp)
    80000af6:	0800                	add	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000af8:	00006597          	auipc	a1,0x6
    80000afc:	54858593          	add	a1,a1,1352 # 80007040 <etext+0x40>
    80000b00:	0000f517          	auipc	a0,0xf
    80000b04:	f1050513          	add	a0,a0,-240 # 8000fa10 <kmem>
    80000b08:	06c000ef          	jal	80000b74 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b0c:	45c5                	li	a1,17
    80000b0e:	05ee                	sll	a1,a1,0x1b
    80000b10:	00020517          	auipc	a0,0x20
    80000b14:	13050513          	add	a0,a0,304 # 80020c40 <end>
    80000b18:	f91ff0ef          	jal	80000aa8 <freerange>
}
    80000b1c:	60a2                	ld	ra,8(sp)
    80000b1e:	6402                	ld	s0,0(sp)
    80000b20:	0141                	add	sp,sp,16
    80000b22:	8082                	ret

0000000080000b24 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b24:	1101                	add	sp,sp,-32
    80000b26:	ec06                	sd	ra,24(sp)
    80000b28:	e822                	sd	s0,16(sp)
    80000b2a:	e426                	sd	s1,8(sp)
    80000b2c:	1000                	add	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b2e:	0000f497          	auipc	s1,0xf
    80000b32:	ee248493          	add	s1,s1,-286 # 8000fa10 <kmem>
    80000b36:	8526                	mv	a0,s1
    80000b38:	0bc000ef          	jal	80000bf4 <acquire>
  r = kmem.freelist;
    80000b3c:	6c84                	ld	s1,24(s1)
  if(r)
    80000b3e:	c485                	beqz	s1,80000b66 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b40:	609c                	ld	a5,0(s1)
    80000b42:	0000f517          	auipc	a0,0xf
    80000b46:	ece50513          	add	a0,a0,-306 # 8000fa10 <kmem>
    80000b4a:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b4c:	140000ef          	jal	80000c8c <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b50:	6605                	lui	a2,0x1
    80000b52:	4595                	li	a1,5
    80000b54:	8526                	mv	a0,s1
    80000b56:	172000ef          	jal	80000cc8 <memset>
  return (void*)r;
}
    80000b5a:	8526                	mv	a0,s1
    80000b5c:	60e2                	ld	ra,24(sp)
    80000b5e:	6442                	ld	s0,16(sp)
    80000b60:	64a2                	ld	s1,8(sp)
    80000b62:	6105                	add	sp,sp,32
    80000b64:	8082                	ret
  release(&kmem.lock);
    80000b66:	0000f517          	auipc	a0,0xf
    80000b6a:	eaa50513          	add	a0,a0,-342 # 8000fa10 <kmem>
    80000b6e:	11e000ef          	jal	80000c8c <release>
  if(r)
    80000b72:	b7e5                	j	80000b5a <kalloc+0x36>

0000000080000b74 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b74:	1141                	add	sp,sp,-16
    80000b76:	e422                	sd	s0,8(sp)
    80000b78:	0800                	add	s0,sp,16
  lk->name = name;
    80000b7a:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b7c:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b80:	00053823          	sd	zero,16(a0)
}
    80000b84:	6422                	ld	s0,8(sp)
    80000b86:	0141                	add	sp,sp,16
    80000b88:	8082                	ret

0000000080000b8a <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b8a:	411c                	lw	a5,0(a0)
    80000b8c:	e399                	bnez	a5,80000b92 <holding+0x8>
    80000b8e:	4501                	li	a0,0
  return r;
}
    80000b90:	8082                	ret
{
    80000b92:	1101                	add	sp,sp,-32
    80000b94:	ec06                	sd	ra,24(sp)
    80000b96:	e822                	sd	s0,16(sp)
    80000b98:	e426                	sd	s1,8(sp)
    80000b9a:	1000                	add	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b9c:	6904                	ld	s1,16(a0)
    80000b9e:	539000ef          	jal	800018d6 <mycpu>
    80000ba2:	40a48533          	sub	a0,s1,a0
    80000ba6:	00153513          	seqz	a0,a0
}
    80000baa:	60e2                	ld	ra,24(sp)
    80000bac:	6442                	ld	s0,16(sp)
    80000bae:	64a2                	ld	s1,8(sp)
    80000bb0:	6105                	add	sp,sp,32
    80000bb2:	8082                	ret

0000000080000bb4 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bb4:	1101                	add	sp,sp,-32
    80000bb6:	ec06                	sd	ra,24(sp)
    80000bb8:	e822                	sd	s0,16(sp)
    80000bba:	e426                	sd	s1,8(sp)
    80000bbc:	1000                	add	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bbe:	100024f3          	csrr	s1,sstatus
    80000bc2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bc6:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bc8:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bcc:	50b000ef          	jal	800018d6 <mycpu>
    80000bd0:	5d3c                	lw	a5,120(a0)
    80000bd2:	cb99                	beqz	a5,80000be8 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bd4:	503000ef          	jal	800018d6 <mycpu>
    80000bd8:	5d3c                	lw	a5,120(a0)
    80000bda:	2785                	addw	a5,a5,1
    80000bdc:	dd3c                	sw	a5,120(a0)
}
    80000bde:	60e2                	ld	ra,24(sp)
    80000be0:	6442                	ld	s0,16(sp)
    80000be2:	64a2                	ld	s1,8(sp)
    80000be4:	6105                	add	sp,sp,32
    80000be6:	8082                	ret
    mycpu()->intena = old;
    80000be8:	4ef000ef          	jal	800018d6 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bec:	8085                	srl	s1,s1,0x1
    80000bee:	8885                	and	s1,s1,1
    80000bf0:	dd64                	sw	s1,124(a0)
    80000bf2:	b7cd                	j	80000bd4 <push_off+0x20>

0000000080000bf4 <acquire>:
{
    80000bf4:	1101                	add	sp,sp,-32
    80000bf6:	ec06                	sd	ra,24(sp)
    80000bf8:	e822                	sd	s0,16(sp)
    80000bfa:	e426                	sd	s1,8(sp)
    80000bfc:	1000                	add	s0,sp,32
    80000bfe:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c00:	fb5ff0ef          	jal	80000bb4 <push_off>
  if(holding(lk))
    80000c04:	8526                	mv	a0,s1
    80000c06:	f85ff0ef          	jal	80000b8a <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c0a:	4705                	li	a4,1
  if(holding(lk))
    80000c0c:	e105                	bnez	a0,80000c2c <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c0e:	87ba                	mv	a5,a4
    80000c10:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c14:	2781                	sext.w	a5,a5
    80000c16:	ffe5                	bnez	a5,80000c0e <acquire+0x1a>
  __sync_synchronize();
    80000c18:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c1c:	4bb000ef          	jal	800018d6 <mycpu>
    80000c20:	e888                	sd	a0,16(s1)
}
    80000c22:	60e2                	ld	ra,24(sp)
    80000c24:	6442                	ld	s0,16(sp)
    80000c26:	64a2                	ld	s1,8(sp)
    80000c28:	6105                	add	sp,sp,32
    80000c2a:	8082                	ret
    panic("acquire");
    80000c2c:	00006517          	auipc	a0,0x6
    80000c30:	41c50513          	add	a0,a0,1052 # 80007048 <etext+0x48>
    80000c34:	b61ff0ef          	jal	80000794 <panic>

0000000080000c38 <pop_off>:

void
pop_off(void)
{
    80000c38:	1141                	add	sp,sp,-16
    80000c3a:	e406                	sd	ra,8(sp)
    80000c3c:	e022                	sd	s0,0(sp)
    80000c3e:	0800                	add	s0,sp,16
  struct cpu *c = mycpu();
    80000c40:	497000ef          	jal	800018d6 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c44:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c48:	8b89                	and	a5,a5,2
  if(intr_get())
    80000c4a:	e78d                	bnez	a5,80000c74 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c4c:	5d3c                	lw	a5,120(a0)
    80000c4e:	02f05963          	blez	a5,80000c80 <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000c52:	37fd                	addw	a5,a5,-1
    80000c54:	0007871b          	sext.w	a4,a5
    80000c58:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c5a:	eb09                	bnez	a4,80000c6c <pop_off+0x34>
    80000c5c:	5d7c                	lw	a5,124(a0)
    80000c5e:	c799                	beqz	a5,80000c6c <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c60:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c64:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c68:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c6c:	60a2                	ld	ra,8(sp)
    80000c6e:	6402                	ld	s0,0(sp)
    80000c70:	0141                	add	sp,sp,16
    80000c72:	8082                	ret
    panic("pop_off - interruptible");
    80000c74:	00006517          	auipc	a0,0x6
    80000c78:	3dc50513          	add	a0,a0,988 # 80007050 <etext+0x50>
    80000c7c:	b19ff0ef          	jal	80000794 <panic>
    panic("pop_off");
    80000c80:	00006517          	auipc	a0,0x6
    80000c84:	3e850513          	add	a0,a0,1000 # 80007068 <etext+0x68>
    80000c88:	b0dff0ef          	jal	80000794 <panic>

0000000080000c8c <release>:
{
    80000c8c:	1101                	add	sp,sp,-32
    80000c8e:	ec06                	sd	ra,24(sp)
    80000c90:	e822                	sd	s0,16(sp)
    80000c92:	e426                	sd	s1,8(sp)
    80000c94:	1000                	add	s0,sp,32
    80000c96:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c98:	ef3ff0ef          	jal	80000b8a <holding>
    80000c9c:	c105                	beqz	a0,80000cbc <release+0x30>
  lk->cpu = 0;
    80000c9e:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca2:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca6:	0f50000f          	fence	iorw,ow
    80000caa:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cae:	f8bff0ef          	jal	80000c38 <pop_off>
}
    80000cb2:	60e2                	ld	ra,24(sp)
    80000cb4:	6442                	ld	s0,16(sp)
    80000cb6:	64a2                	ld	s1,8(sp)
    80000cb8:	6105                	add	sp,sp,32
    80000cba:	8082                	ret
    panic("release");
    80000cbc:	00006517          	auipc	a0,0x6
    80000cc0:	3b450513          	add	a0,a0,948 # 80007070 <etext+0x70>
    80000cc4:	ad1ff0ef          	jal	80000794 <panic>

0000000080000cc8 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cc8:	1141                	add	sp,sp,-16
    80000cca:	e422                	sd	s0,8(sp)
    80000ccc:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cce:	ca19                	beqz	a2,80000ce4 <memset+0x1c>
    80000cd0:	87aa                	mv	a5,a0
    80000cd2:	1602                	sll	a2,a2,0x20
    80000cd4:	9201                	srl	a2,a2,0x20
    80000cd6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cda:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cde:	0785                	add	a5,a5,1
    80000ce0:	fee79de3          	bne	a5,a4,80000cda <memset+0x12>
  }
  return dst;
}
    80000ce4:	6422                	ld	s0,8(sp)
    80000ce6:	0141                	add	sp,sp,16
    80000ce8:	8082                	ret

0000000080000cea <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cea:	1141                	add	sp,sp,-16
    80000cec:	e422                	sd	s0,8(sp)
    80000cee:	0800                	add	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cf0:	ca05                	beqz	a2,80000d20 <memcmp+0x36>
    80000cf2:	fff6069b          	addw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cf6:	1682                	sll	a3,a3,0x20
    80000cf8:	9281                	srl	a3,a3,0x20
    80000cfa:	0685                	add	a3,a3,1
    80000cfc:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000cfe:	00054783          	lbu	a5,0(a0)
    80000d02:	0005c703          	lbu	a4,0(a1)
    80000d06:	00e79863          	bne	a5,a4,80000d16 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d0a:	0505                	add	a0,a0,1
    80000d0c:	0585                	add	a1,a1,1
  while(n-- > 0){
    80000d0e:	fed518e3          	bne	a0,a3,80000cfe <memcmp+0x14>
  }

  return 0;
    80000d12:	4501                	li	a0,0
    80000d14:	a019                	j	80000d1a <memcmp+0x30>
      return *s1 - *s2;
    80000d16:	40e7853b          	subw	a0,a5,a4
}
    80000d1a:	6422                	ld	s0,8(sp)
    80000d1c:	0141                	add	sp,sp,16
    80000d1e:	8082                	ret
  return 0;
    80000d20:	4501                	li	a0,0
    80000d22:	bfe5                	j	80000d1a <memcmp+0x30>

0000000080000d24 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d24:	1141                	add	sp,sp,-16
    80000d26:	e422                	sd	s0,8(sp)
    80000d28:	0800                	add	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d2a:	c205                	beqz	a2,80000d4a <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d2c:	02a5e263          	bltu	a1,a0,80000d50 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d30:	1602                	sll	a2,a2,0x20
    80000d32:	9201                	srl	a2,a2,0x20
    80000d34:	00c587b3          	add	a5,a1,a2
{
    80000d38:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d3a:	0585                	add	a1,a1,1
    80000d3c:	0705                	add	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffde3c1>
    80000d3e:	fff5c683          	lbu	a3,-1(a1)
    80000d42:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d46:	feb79ae3          	bne	a5,a1,80000d3a <memmove+0x16>

  return dst;
}
    80000d4a:	6422                	ld	s0,8(sp)
    80000d4c:	0141                	add	sp,sp,16
    80000d4e:	8082                	ret
  if(s < d && s + n > d){
    80000d50:	02061693          	sll	a3,a2,0x20
    80000d54:	9281                	srl	a3,a3,0x20
    80000d56:	00d58733          	add	a4,a1,a3
    80000d5a:	fce57be3          	bgeu	a0,a4,80000d30 <memmove+0xc>
    d += n;
    80000d5e:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d60:	fff6079b          	addw	a5,a2,-1
    80000d64:	1782                	sll	a5,a5,0x20
    80000d66:	9381                	srl	a5,a5,0x20
    80000d68:	fff7c793          	not	a5,a5
    80000d6c:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d6e:	177d                	add	a4,a4,-1
    80000d70:	16fd                	add	a3,a3,-1
    80000d72:	00074603          	lbu	a2,0(a4)
    80000d76:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d7a:	fef71ae3          	bne	a4,a5,80000d6e <memmove+0x4a>
    80000d7e:	b7f1                	j	80000d4a <memmove+0x26>

0000000080000d80 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d80:	1141                	add	sp,sp,-16
    80000d82:	e406                	sd	ra,8(sp)
    80000d84:	e022                	sd	s0,0(sp)
    80000d86:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
    80000d88:	f9dff0ef          	jal	80000d24 <memmove>
}
    80000d8c:	60a2                	ld	ra,8(sp)
    80000d8e:	6402                	ld	s0,0(sp)
    80000d90:	0141                	add	sp,sp,16
    80000d92:	8082                	ret

0000000080000d94 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d94:	1141                	add	sp,sp,-16
    80000d96:	e422                	sd	s0,8(sp)
    80000d98:	0800                	add	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d9a:	ce11                	beqz	a2,80000db6 <strncmp+0x22>
    80000d9c:	00054783          	lbu	a5,0(a0)
    80000da0:	cf89                	beqz	a5,80000dba <strncmp+0x26>
    80000da2:	0005c703          	lbu	a4,0(a1)
    80000da6:	00f71a63          	bne	a4,a5,80000dba <strncmp+0x26>
    n--, p++, q++;
    80000daa:	367d                	addw	a2,a2,-1
    80000dac:	0505                	add	a0,a0,1
    80000dae:	0585                	add	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000db0:	f675                	bnez	a2,80000d9c <strncmp+0x8>
  if(n == 0)
    return 0;
    80000db2:	4501                	li	a0,0
    80000db4:	a801                	j	80000dc4 <strncmp+0x30>
    80000db6:	4501                	li	a0,0
    80000db8:	a031                	j	80000dc4 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000dba:	00054503          	lbu	a0,0(a0)
    80000dbe:	0005c783          	lbu	a5,0(a1)
    80000dc2:	9d1d                	subw	a0,a0,a5
}
    80000dc4:	6422                	ld	s0,8(sp)
    80000dc6:	0141                	add	sp,sp,16
    80000dc8:	8082                	ret

0000000080000dca <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dca:	1141                	add	sp,sp,-16
    80000dcc:	e422                	sd	s0,8(sp)
    80000dce:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dd0:	87aa                	mv	a5,a0
    80000dd2:	86b2                	mv	a3,a2
    80000dd4:	367d                	addw	a2,a2,-1
    80000dd6:	02d05563          	blez	a3,80000e00 <strncpy+0x36>
    80000dda:	0785                	add	a5,a5,1
    80000ddc:	0005c703          	lbu	a4,0(a1)
    80000de0:	fee78fa3          	sb	a4,-1(a5)
    80000de4:	0585                	add	a1,a1,1
    80000de6:	f775                	bnez	a4,80000dd2 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000de8:	873e                	mv	a4,a5
    80000dea:	9fb5                	addw	a5,a5,a3
    80000dec:	37fd                	addw	a5,a5,-1
    80000dee:	00c05963          	blez	a2,80000e00 <strncpy+0x36>
    *s++ = 0;
    80000df2:	0705                	add	a4,a4,1
    80000df4:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000df8:	40e786bb          	subw	a3,a5,a4
    80000dfc:	fed04be3          	bgtz	a3,80000df2 <strncpy+0x28>
  return os;
}
    80000e00:	6422                	ld	s0,8(sp)
    80000e02:	0141                	add	sp,sp,16
    80000e04:	8082                	ret

0000000080000e06 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e06:	1141                	add	sp,sp,-16
    80000e08:	e422                	sd	s0,8(sp)
    80000e0a:	0800                	add	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e0c:	02c05363          	blez	a2,80000e32 <safestrcpy+0x2c>
    80000e10:	fff6069b          	addw	a3,a2,-1
    80000e14:	1682                	sll	a3,a3,0x20
    80000e16:	9281                	srl	a3,a3,0x20
    80000e18:	96ae                	add	a3,a3,a1
    80000e1a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e1c:	00d58963          	beq	a1,a3,80000e2e <safestrcpy+0x28>
    80000e20:	0585                	add	a1,a1,1
    80000e22:	0785                	add	a5,a5,1
    80000e24:	fff5c703          	lbu	a4,-1(a1)
    80000e28:	fee78fa3          	sb	a4,-1(a5)
    80000e2c:	fb65                	bnez	a4,80000e1c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e2e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e32:	6422                	ld	s0,8(sp)
    80000e34:	0141                	add	sp,sp,16
    80000e36:	8082                	ret

0000000080000e38 <strlen>:

int
strlen(const char *s)
{
    80000e38:	1141                	add	sp,sp,-16
    80000e3a:	e422                	sd	s0,8(sp)
    80000e3c:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e3e:	00054783          	lbu	a5,0(a0)
    80000e42:	cf91                	beqz	a5,80000e5e <strlen+0x26>
    80000e44:	0505                	add	a0,a0,1
    80000e46:	87aa                	mv	a5,a0
    80000e48:	86be                	mv	a3,a5
    80000e4a:	0785                	add	a5,a5,1
    80000e4c:	fff7c703          	lbu	a4,-1(a5)
    80000e50:	ff65                	bnez	a4,80000e48 <strlen+0x10>
    80000e52:	40a6853b          	subw	a0,a3,a0
    80000e56:	2505                	addw	a0,a0,1
    ;
  return n;
}
    80000e58:	6422                	ld	s0,8(sp)
    80000e5a:	0141                	add	sp,sp,16
    80000e5c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e5e:	4501                	li	a0,0
    80000e60:	bfe5                	j	80000e58 <strlen+0x20>

0000000080000e62 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e62:	1141                	add	sp,sp,-16
    80000e64:	e406                	sd	ra,8(sp)
    80000e66:	e022                	sd	s0,0(sp)
    80000e68:	0800                	add	s0,sp,16
  if(cpuid() == 0){
    80000e6a:	25d000ef          	jal	800018c6 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e6e:	00007717          	auipc	a4,0x7
    80000e72:	a7a70713          	add	a4,a4,-1414 # 800078e8 <started>
  if(cpuid() == 0){
    80000e76:	c51d                	beqz	a0,80000ea4 <main+0x42>
    while(started == 0)
    80000e78:	431c                	lw	a5,0(a4)
    80000e7a:	2781                	sext.w	a5,a5
    80000e7c:	dff5                	beqz	a5,80000e78 <main+0x16>
      ;
    __sync_synchronize();
    80000e7e:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e82:	245000ef          	jal	800018c6 <cpuid>
    80000e86:	85aa                	mv	a1,a0
    80000e88:	00006517          	auipc	a0,0x6
    80000e8c:	21050513          	add	a0,a0,528 # 80007098 <etext+0x98>
    80000e90:	e32ff0ef          	jal	800004c2 <printf>
    kvminithart();    // turn on paging
    80000e94:	080000ef          	jal	80000f14 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e98:	54a010ef          	jal	800023e2 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e9c:	3dc040ef          	jal	80005278 <plicinithart>
  }

  scheduler();        
    80000ea0:	687000ef          	jal	80001d26 <scheduler>
    consoleinit();
    80000ea4:	d48ff0ef          	jal	800003ec <consoleinit>
    printfinit();
    80000ea8:	927ff0ef          	jal	800007ce <printfinit>
    printf("\n");
    80000eac:	00006517          	auipc	a0,0x6
    80000eb0:	1cc50513          	add	a0,a0,460 # 80007078 <etext+0x78>
    80000eb4:	e0eff0ef          	jal	800004c2 <printf>
    printf("xv6 kernel is booting\n");
    80000eb8:	00006517          	auipc	a0,0x6
    80000ebc:	1c850513          	add	a0,a0,456 # 80007080 <etext+0x80>
    80000ec0:	e02ff0ef          	jal	800004c2 <printf>
    printf("\n");
    80000ec4:	00006517          	auipc	a0,0x6
    80000ec8:	1b450513          	add	a0,a0,436 # 80007078 <etext+0x78>
    80000ecc:	df6ff0ef          	jal	800004c2 <printf>
    kinit();         // physical page allocator
    80000ed0:	c21ff0ef          	jal	80000af0 <kinit>
    kvminit();       // create kernel page table
    80000ed4:	2dc000ef          	jal	800011b0 <kvminit>
    kvminithart();   // turn on paging
    80000ed8:	03c000ef          	jal	80000f14 <kvminithart>
    procinit();      // process table
    80000edc:	135000ef          	jal	80001810 <procinit>
    trapinit();      // trap vectors
    80000ee0:	4de010ef          	jal	800023be <trapinit>
    trapinithart();  // install kernel trap vector
    80000ee4:	4fe010ef          	jal	800023e2 <trapinithart>
    plicinit();      // set up interrupt controller
    80000ee8:	376040ef          	jal	8000525e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000eec:	38c040ef          	jal	80005278 <plicinithart>
    binit();         // buffer cache
    80000ef0:	325010ef          	jal	80002a14 <binit>
    iinit();         // inode table
    80000ef4:	116020ef          	jal	8000300a <iinit>
    fileinit();      // file table
    80000ef8:	6c3020ef          	jal	80003dba <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000efc:	494040ef          	jal	80005390 <virtio_disk_init>
    userinit();      // first user process
    80000f00:	45b000ef          	jal	80001b5a <userinit>
    __sync_synchronize();
    80000f04:	0ff0000f          	fence
    started = 1;
    80000f08:	4785                	li	a5,1
    80000f0a:	00007717          	auipc	a4,0x7
    80000f0e:	9cf72f23          	sw	a5,-1570(a4) # 800078e8 <started>
    80000f12:	b779                	j	80000ea0 <main+0x3e>

0000000080000f14 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f14:	1141                	add	sp,sp,-16
    80000f16:	e422                	sd	s0,8(sp)
    80000f18:	0800                	add	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f1a:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f1e:	00007797          	auipc	a5,0x7
    80000f22:	9d27b783          	ld	a5,-1582(a5) # 800078f0 <kernel_pagetable>
    80000f26:	83b1                	srl	a5,a5,0xc
    80000f28:	577d                	li	a4,-1
    80000f2a:	177e                	sll	a4,a4,0x3f
    80000f2c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f2e:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f32:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f36:	6422                	ld	s0,8(sp)
    80000f38:	0141                	add	sp,sp,16
    80000f3a:	8082                	ret

0000000080000f3c <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f3c:	7139                	add	sp,sp,-64
    80000f3e:	fc06                	sd	ra,56(sp)
    80000f40:	f822                	sd	s0,48(sp)
    80000f42:	f426                	sd	s1,40(sp)
    80000f44:	f04a                	sd	s2,32(sp)
    80000f46:	ec4e                	sd	s3,24(sp)
    80000f48:	e852                	sd	s4,16(sp)
    80000f4a:	e456                	sd	s5,8(sp)
    80000f4c:	e05a                	sd	s6,0(sp)
    80000f4e:	0080                	add	s0,sp,64
    80000f50:	84aa                	mv	s1,a0
    80000f52:	89ae                	mv	s3,a1
    80000f54:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000f56:	57fd                	li	a5,-1
    80000f58:	83e9                	srl	a5,a5,0x1a
    80000f5a:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000f5c:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000f5e:	02b7fc63          	bgeu	a5,a1,80000f96 <walk+0x5a>
    panic("walk");
    80000f62:	00006517          	auipc	a0,0x6
    80000f66:	14e50513          	add	a0,a0,334 # 800070b0 <etext+0xb0>
    80000f6a:	82bff0ef          	jal	80000794 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000f6e:	060a8263          	beqz	s5,80000fd2 <walk+0x96>
    80000f72:	bb3ff0ef          	jal	80000b24 <kalloc>
    80000f76:	84aa                	mv	s1,a0
    80000f78:	c139                	beqz	a0,80000fbe <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000f7a:	6605                	lui	a2,0x1
    80000f7c:	4581                	li	a1,0
    80000f7e:	d4bff0ef          	jal	80000cc8 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f82:	00c4d793          	srl	a5,s1,0xc
    80000f86:	07aa                	sll	a5,a5,0xa
    80000f88:	0017e793          	or	a5,a5,1
    80000f8c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000f90:	3a5d                	addw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffde3b7>
    80000f92:	036a0063          	beq	s4,s6,80000fb2 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f96:	0149d933          	srl	s2,s3,s4
    80000f9a:	1ff97913          	and	s2,s2,511
    80000f9e:	090e                	sll	s2,s2,0x3
    80000fa0:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000fa2:	00093483          	ld	s1,0(s2)
    80000fa6:	0014f793          	and	a5,s1,1
    80000faa:	d3f1                	beqz	a5,80000f6e <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000fac:	80a9                	srl	s1,s1,0xa
    80000fae:	04b2                	sll	s1,s1,0xc
    80000fb0:	b7c5                	j	80000f90 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000fb2:	00c9d513          	srl	a0,s3,0xc
    80000fb6:	1ff57513          	and	a0,a0,511
    80000fba:	050e                	sll	a0,a0,0x3
    80000fbc:	9526                	add	a0,a0,s1
}
    80000fbe:	70e2                	ld	ra,56(sp)
    80000fc0:	7442                	ld	s0,48(sp)
    80000fc2:	74a2                	ld	s1,40(sp)
    80000fc4:	7902                	ld	s2,32(sp)
    80000fc6:	69e2                	ld	s3,24(sp)
    80000fc8:	6a42                	ld	s4,16(sp)
    80000fca:	6aa2                	ld	s5,8(sp)
    80000fcc:	6b02                	ld	s6,0(sp)
    80000fce:	6121                	add	sp,sp,64
    80000fd0:	8082                	ret
        return 0;
    80000fd2:	4501                	li	a0,0
    80000fd4:	b7ed                	j	80000fbe <walk+0x82>

0000000080000fd6 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000fd6:	57fd                	li	a5,-1
    80000fd8:	83e9                	srl	a5,a5,0x1a
    80000fda:	00b7f463          	bgeu	a5,a1,80000fe2 <walkaddr+0xc>
    return 0;
    80000fde:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000fe0:	8082                	ret
{
    80000fe2:	1141                	add	sp,sp,-16
    80000fe4:	e406                	sd	ra,8(sp)
    80000fe6:	e022                	sd	s0,0(sp)
    80000fe8:	0800                	add	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000fea:	4601                	li	a2,0
    80000fec:	f51ff0ef          	jal	80000f3c <walk>
  if(pte == 0)
    80000ff0:	c105                	beqz	a0,80001010 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000ff2:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000ff4:	0117f693          	and	a3,a5,17
    80000ff8:	4745                	li	a4,17
    return 0;
    80000ffa:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000ffc:	00e68663          	beq	a3,a4,80001008 <walkaddr+0x32>
}
    80001000:	60a2                	ld	ra,8(sp)
    80001002:	6402                	ld	s0,0(sp)
    80001004:	0141                	add	sp,sp,16
    80001006:	8082                	ret
  pa = PTE2PA(*pte);
    80001008:	83a9                	srl	a5,a5,0xa
    8000100a:	00c79513          	sll	a0,a5,0xc
  return pa;
    8000100e:	bfcd                	j	80001000 <walkaddr+0x2a>
    return 0;
    80001010:	4501                	li	a0,0
    80001012:	b7fd                	j	80001000 <walkaddr+0x2a>

0000000080001014 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001014:	715d                	add	sp,sp,-80
    80001016:	e486                	sd	ra,72(sp)
    80001018:	e0a2                	sd	s0,64(sp)
    8000101a:	fc26                	sd	s1,56(sp)
    8000101c:	f84a                	sd	s2,48(sp)
    8000101e:	f44e                	sd	s3,40(sp)
    80001020:	f052                	sd	s4,32(sp)
    80001022:	ec56                	sd	s5,24(sp)
    80001024:	e85a                	sd	s6,16(sp)
    80001026:	e45e                	sd	s7,8(sp)
    80001028:	0880                	add	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000102a:	03459793          	sll	a5,a1,0x34
    8000102e:	e7a9                	bnez	a5,80001078 <mappages+0x64>
    80001030:	8aaa                	mv	s5,a0
    80001032:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80001034:	03461793          	sll	a5,a2,0x34
    80001038:	e7b1                	bnez	a5,80001084 <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    8000103a:	ca39                	beqz	a2,80001090 <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    8000103c:	77fd                	lui	a5,0xfffff
    8000103e:	963e                	add	a2,a2,a5
    80001040:	00b609b3          	add	s3,a2,a1
  a = va;
    80001044:	892e                	mv	s2,a1
    80001046:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000104a:	6b85                	lui	s7,0x1
    8000104c:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    80001050:	4605                	li	a2,1
    80001052:	85ca                	mv	a1,s2
    80001054:	8556                	mv	a0,s5
    80001056:	ee7ff0ef          	jal	80000f3c <walk>
    8000105a:	c539                	beqz	a0,800010a8 <mappages+0x94>
    if(*pte & PTE_V)
    8000105c:	611c                	ld	a5,0(a0)
    8000105e:	8b85                	and	a5,a5,1
    80001060:	ef95                	bnez	a5,8000109c <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001062:	80b1                	srl	s1,s1,0xc
    80001064:	04aa                	sll	s1,s1,0xa
    80001066:	0164e4b3          	or	s1,s1,s6
    8000106a:	0014e493          	or	s1,s1,1
    8000106e:	e104                	sd	s1,0(a0)
    if(a == last)
    80001070:	05390863          	beq	s2,s3,800010c0 <mappages+0xac>
    a += PGSIZE;
    80001074:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001076:	bfd9                	j	8000104c <mappages+0x38>
    panic("mappages: va not aligned");
    80001078:	00006517          	auipc	a0,0x6
    8000107c:	04050513          	add	a0,a0,64 # 800070b8 <etext+0xb8>
    80001080:	f14ff0ef          	jal	80000794 <panic>
    panic("mappages: size not aligned");
    80001084:	00006517          	auipc	a0,0x6
    80001088:	05450513          	add	a0,a0,84 # 800070d8 <etext+0xd8>
    8000108c:	f08ff0ef          	jal	80000794 <panic>
    panic("mappages: size");
    80001090:	00006517          	auipc	a0,0x6
    80001094:	06850513          	add	a0,a0,104 # 800070f8 <etext+0xf8>
    80001098:	efcff0ef          	jal	80000794 <panic>
      panic("mappages: remap");
    8000109c:	00006517          	auipc	a0,0x6
    800010a0:	06c50513          	add	a0,a0,108 # 80007108 <etext+0x108>
    800010a4:	ef0ff0ef          	jal	80000794 <panic>
      return -1;
    800010a8:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010aa:	60a6                	ld	ra,72(sp)
    800010ac:	6406                	ld	s0,64(sp)
    800010ae:	74e2                	ld	s1,56(sp)
    800010b0:	7942                	ld	s2,48(sp)
    800010b2:	79a2                	ld	s3,40(sp)
    800010b4:	7a02                	ld	s4,32(sp)
    800010b6:	6ae2                	ld	s5,24(sp)
    800010b8:	6b42                	ld	s6,16(sp)
    800010ba:	6ba2                	ld	s7,8(sp)
    800010bc:	6161                	add	sp,sp,80
    800010be:	8082                	ret
  return 0;
    800010c0:	4501                	li	a0,0
    800010c2:	b7e5                	j	800010aa <mappages+0x96>

00000000800010c4 <kvmmap>:
{
    800010c4:	1141                	add	sp,sp,-16
    800010c6:	e406                	sd	ra,8(sp)
    800010c8:	e022                	sd	s0,0(sp)
    800010ca:	0800                	add	s0,sp,16
    800010cc:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800010ce:	86b2                	mv	a3,a2
    800010d0:	863e                	mv	a2,a5
    800010d2:	f43ff0ef          	jal	80001014 <mappages>
    800010d6:	e509                	bnez	a0,800010e0 <kvmmap+0x1c>
}
    800010d8:	60a2                	ld	ra,8(sp)
    800010da:	6402                	ld	s0,0(sp)
    800010dc:	0141                	add	sp,sp,16
    800010de:	8082                	ret
    panic("kvmmap");
    800010e0:	00006517          	auipc	a0,0x6
    800010e4:	03850513          	add	a0,a0,56 # 80007118 <etext+0x118>
    800010e8:	eacff0ef          	jal	80000794 <panic>

00000000800010ec <kvmmake>:
{
    800010ec:	1101                	add	sp,sp,-32
    800010ee:	ec06                	sd	ra,24(sp)
    800010f0:	e822                	sd	s0,16(sp)
    800010f2:	e426                	sd	s1,8(sp)
    800010f4:	e04a                	sd	s2,0(sp)
    800010f6:	1000                	add	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800010f8:	a2dff0ef          	jal	80000b24 <kalloc>
    800010fc:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800010fe:	6605                	lui	a2,0x1
    80001100:	4581                	li	a1,0
    80001102:	bc7ff0ef          	jal	80000cc8 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001106:	4719                	li	a4,6
    80001108:	6685                	lui	a3,0x1
    8000110a:	10000637          	lui	a2,0x10000
    8000110e:	100005b7          	lui	a1,0x10000
    80001112:	8526                	mv	a0,s1
    80001114:	fb1ff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001118:	4719                	li	a4,6
    8000111a:	6685                	lui	a3,0x1
    8000111c:	10001637          	lui	a2,0x10001
    80001120:	100015b7          	lui	a1,0x10001
    80001124:	8526                	mv	a0,s1
    80001126:	f9fff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    8000112a:	4719                	li	a4,6
    8000112c:	040006b7          	lui	a3,0x4000
    80001130:	0c000637          	lui	a2,0xc000
    80001134:	0c0005b7          	lui	a1,0xc000
    80001138:	8526                	mv	a0,s1
    8000113a:	f8bff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000113e:	00006917          	auipc	s2,0x6
    80001142:	ec290913          	add	s2,s2,-318 # 80007000 <etext>
    80001146:	4729                	li	a4,10
    80001148:	80006697          	auipc	a3,0x80006
    8000114c:	eb868693          	add	a3,a3,-328 # 7000 <_entry-0x7fff9000>
    80001150:	4605                	li	a2,1
    80001152:	067e                	sll	a2,a2,0x1f
    80001154:	85b2                	mv	a1,a2
    80001156:	8526                	mv	a0,s1
    80001158:	f6dff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000115c:	46c5                	li	a3,17
    8000115e:	06ee                	sll	a3,a3,0x1b
    80001160:	4719                	li	a4,6
    80001162:	412686b3          	sub	a3,a3,s2
    80001166:	864a                	mv	a2,s2
    80001168:	85ca                	mv	a1,s2
    8000116a:	8526                	mv	a0,s1
    8000116c:	f59ff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001170:	4729                	li	a4,10
    80001172:	6685                	lui	a3,0x1
    80001174:	00005617          	auipc	a2,0x5
    80001178:	e8c60613          	add	a2,a2,-372 # 80006000 <_trampoline>
    8000117c:	040005b7          	lui	a1,0x4000
    80001180:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001182:	05b2                	sll	a1,a1,0xc
    80001184:	8526                	mv	a0,s1
    80001186:	f3fff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl , SHUTDOWN , SHUTDOWN , PGSIZE , PTE_R | PTE_W);
    8000118a:	4719                	li	a4,6
    8000118c:	6685                	lui	a3,0x1
    8000118e:	00100637          	lui	a2,0x100
    80001192:	001005b7          	lui	a1,0x100
    80001196:	8526                	mv	a0,s1
    80001198:	f2dff0ef          	jal	800010c4 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000119c:	8526                	mv	a0,s1
    8000119e:	5da000ef          	jal	80001778 <proc_mapstacks>
}
    800011a2:	8526                	mv	a0,s1
    800011a4:	60e2                	ld	ra,24(sp)
    800011a6:	6442                	ld	s0,16(sp)
    800011a8:	64a2                	ld	s1,8(sp)
    800011aa:	6902                	ld	s2,0(sp)
    800011ac:	6105                	add	sp,sp,32
    800011ae:	8082                	ret

00000000800011b0 <kvminit>:
{
    800011b0:	1141                	add	sp,sp,-16
    800011b2:	e406                	sd	ra,8(sp)
    800011b4:	e022                	sd	s0,0(sp)
    800011b6:	0800                	add	s0,sp,16
  kernel_pagetable = kvmmake();
    800011b8:	f35ff0ef          	jal	800010ec <kvmmake>
    800011bc:	00006797          	auipc	a5,0x6
    800011c0:	72a7ba23          	sd	a0,1844(a5) # 800078f0 <kernel_pagetable>
}
    800011c4:	60a2                	ld	ra,8(sp)
    800011c6:	6402                	ld	s0,0(sp)
    800011c8:	0141                	add	sp,sp,16
    800011ca:	8082                	ret

00000000800011cc <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011cc:	715d                	add	sp,sp,-80
    800011ce:	e486                	sd	ra,72(sp)
    800011d0:	e0a2                	sd	s0,64(sp)
    800011d2:	0880                	add	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800011d4:	03459793          	sll	a5,a1,0x34
    800011d8:	e39d                	bnez	a5,800011fe <uvmunmap+0x32>
    800011da:	f84a                	sd	s2,48(sp)
    800011dc:	f44e                	sd	s3,40(sp)
    800011de:	f052                	sd	s4,32(sp)
    800011e0:	ec56                	sd	s5,24(sp)
    800011e2:	e85a                	sd	s6,16(sp)
    800011e4:	e45e                	sd	s7,8(sp)
    800011e6:	8a2a                	mv	s4,a0
    800011e8:	892e                	mv	s2,a1
    800011ea:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011ec:	0632                	sll	a2,a2,0xc
    800011ee:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800011f2:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011f4:	6b05                	lui	s6,0x1
    800011f6:	0735ff63          	bgeu	a1,s3,80001274 <uvmunmap+0xa8>
    800011fa:	fc26                	sd	s1,56(sp)
    800011fc:	a0a9                	j	80001246 <uvmunmap+0x7a>
    800011fe:	fc26                	sd	s1,56(sp)
    80001200:	f84a                	sd	s2,48(sp)
    80001202:	f44e                	sd	s3,40(sp)
    80001204:	f052                	sd	s4,32(sp)
    80001206:	ec56                	sd	s5,24(sp)
    80001208:	e85a                	sd	s6,16(sp)
    8000120a:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    8000120c:	00006517          	auipc	a0,0x6
    80001210:	f1450513          	add	a0,a0,-236 # 80007120 <etext+0x120>
    80001214:	d80ff0ef          	jal	80000794 <panic>
      panic("uvmunmap: walk");
    80001218:	00006517          	auipc	a0,0x6
    8000121c:	f2050513          	add	a0,a0,-224 # 80007138 <etext+0x138>
    80001220:	d74ff0ef          	jal	80000794 <panic>
      panic("uvmunmap: not mapped");
    80001224:	00006517          	auipc	a0,0x6
    80001228:	f2450513          	add	a0,a0,-220 # 80007148 <etext+0x148>
    8000122c:	d68ff0ef          	jal	80000794 <panic>
      panic("uvmunmap: not a leaf");
    80001230:	00006517          	auipc	a0,0x6
    80001234:	f3050513          	add	a0,a0,-208 # 80007160 <etext+0x160>
    80001238:	d5cff0ef          	jal	80000794 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    8000123c:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001240:	995a                	add	s2,s2,s6
    80001242:	03397863          	bgeu	s2,s3,80001272 <uvmunmap+0xa6>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001246:	4601                	li	a2,0
    80001248:	85ca                	mv	a1,s2
    8000124a:	8552                	mv	a0,s4
    8000124c:	cf1ff0ef          	jal	80000f3c <walk>
    80001250:	84aa                	mv	s1,a0
    80001252:	d179                	beqz	a0,80001218 <uvmunmap+0x4c>
    if((*pte & PTE_V) == 0)
    80001254:	6108                	ld	a0,0(a0)
    80001256:	00157793          	and	a5,a0,1
    8000125a:	d7e9                	beqz	a5,80001224 <uvmunmap+0x58>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000125c:	3ff57793          	and	a5,a0,1023
    80001260:	fd7788e3          	beq	a5,s7,80001230 <uvmunmap+0x64>
    if(do_free){
    80001264:	fc0a8ce3          	beqz	s5,8000123c <uvmunmap+0x70>
      uint64 pa = PTE2PA(*pte);
    80001268:	8129                	srl	a0,a0,0xa
      kfree((void*)pa);
    8000126a:	0532                	sll	a0,a0,0xc
    8000126c:	fd6ff0ef          	jal	80000a42 <kfree>
    80001270:	b7f1                	j	8000123c <uvmunmap+0x70>
    80001272:	74e2                	ld	s1,56(sp)
    80001274:	7942                	ld	s2,48(sp)
    80001276:	79a2                	ld	s3,40(sp)
    80001278:	7a02                	ld	s4,32(sp)
    8000127a:	6ae2                	ld	s5,24(sp)
    8000127c:	6b42                	ld	s6,16(sp)
    8000127e:	6ba2                	ld	s7,8(sp)
  }
}
    80001280:	60a6                	ld	ra,72(sp)
    80001282:	6406                	ld	s0,64(sp)
    80001284:	6161                	add	sp,sp,80
    80001286:	8082                	ret

0000000080001288 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001288:	1101                	add	sp,sp,-32
    8000128a:	ec06                	sd	ra,24(sp)
    8000128c:	e822                	sd	s0,16(sp)
    8000128e:	e426                	sd	s1,8(sp)
    80001290:	1000                	add	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001292:	893ff0ef          	jal	80000b24 <kalloc>
    80001296:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001298:	c509                	beqz	a0,800012a2 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000129a:	6605                	lui	a2,0x1
    8000129c:	4581                	li	a1,0
    8000129e:	a2bff0ef          	jal	80000cc8 <memset>
  return pagetable;
}
    800012a2:	8526                	mv	a0,s1
    800012a4:	60e2                	ld	ra,24(sp)
    800012a6:	6442                	ld	s0,16(sp)
    800012a8:	64a2                	ld	s1,8(sp)
    800012aa:	6105                	add	sp,sp,32
    800012ac:	8082                	ret

00000000800012ae <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    800012ae:	7179                	add	sp,sp,-48
    800012b0:	f406                	sd	ra,40(sp)
    800012b2:	f022                	sd	s0,32(sp)
    800012b4:	ec26                	sd	s1,24(sp)
    800012b6:	e84a                	sd	s2,16(sp)
    800012b8:	e44e                	sd	s3,8(sp)
    800012ba:	e052                	sd	s4,0(sp)
    800012bc:	1800                	add	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800012be:	6785                	lui	a5,0x1
    800012c0:	04f67063          	bgeu	a2,a5,80001300 <uvmfirst+0x52>
    800012c4:	8a2a                	mv	s4,a0
    800012c6:	89ae                	mv	s3,a1
    800012c8:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800012ca:	85bff0ef          	jal	80000b24 <kalloc>
    800012ce:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800012d0:	6605                	lui	a2,0x1
    800012d2:	4581                	li	a1,0
    800012d4:	9f5ff0ef          	jal	80000cc8 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800012d8:	4779                	li	a4,30
    800012da:	86ca                	mv	a3,s2
    800012dc:	6605                	lui	a2,0x1
    800012de:	4581                	li	a1,0
    800012e0:	8552                	mv	a0,s4
    800012e2:	d33ff0ef          	jal	80001014 <mappages>
  memmove(mem, src, sz);
    800012e6:	8626                	mv	a2,s1
    800012e8:	85ce                	mv	a1,s3
    800012ea:	854a                	mv	a0,s2
    800012ec:	a39ff0ef          	jal	80000d24 <memmove>
}
    800012f0:	70a2                	ld	ra,40(sp)
    800012f2:	7402                	ld	s0,32(sp)
    800012f4:	64e2                	ld	s1,24(sp)
    800012f6:	6942                	ld	s2,16(sp)
    800012f8:	69a2                	ld	s3,8(sp)
    800012fa:	6a02                	ld	s4,0(sp)
    800012fc:	6145                	add	sp,sp,48
    800012fe:	8082                	ret
    panic("uvmfirst: more than a page");
    80001300:	00006517          	auipc	a0,0x6
    80001304:	e7850513          	add	a0,a0,-392 # 80007178 <etext+0x178>
    80001308:	c8cff0ef          	jal	80000794 <panic>

000000008000130c <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000130c:	1101                	add	sp,sp,-32
    8000130e:	ec06                	sd	ra,24(sp)
    80001310:	e822                	sd	s0,16(sp)
    80001312:	e426                	sd	s1,8(sp)
    80001314:	1000                	add	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001316:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001318:	00b67d63          	bgeu	a2,a1,80001332 <uvmdealloc+0x26>
    8000131c:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000131e:	6785                	lui	a5,0x1
    80001320:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001322:	00f60733          	add	a4,a2,a5
    80001326:	76fd                	lui	a3,0xfffff
    80001328:	8f75                	and	a4,a4,a3
    8000132a:	97ae                	add	a5,a5,a1
    8000132c:	8ff5                	and	a5,a5,a3
    8000132e:	00f76863          	bltu	a4,a5,8000133e <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001332:	8526                	mv	a0,s1
    80001334:	60e2                	ld	ra,24(sp)
    80001336:	6442                	ld	s0,16(sp)
    80001338:	64a2                	ld	s1,8(sp)
    8000133a:	6105                	add	sp,sp,32
    8000133c:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000133e:	8f99                	sub	a5,a5,a4
    80001340:	83b1                	srl	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001342:	4685                	li	a3,1
    80001344:	0007861b          	sext.w	a2,a5
    80001348:	85ba                	mv	a1,a4
    8000134a:	e83ff0ef          	jal	800011cc <uvmunmap>
    8000134e:	b7d5                	j	80001332 <uvmdealloc+0x26>

0000000080001350 <uvmalloc>:
  if(newsz < oldsz)
    80001350:	08b66f63          	bltu	a2,a1,800013ee <uvmalloc+0x9e>
{
    80001354:	7139                	add	sp,sp,-64
    80001356:	fc06                	sd	ra,56(sp)
    80001358:	f822                	sd	s0,48(sp)
    8000135a:	ec4e                	sd	s3,24(sp)
    8000135c:	e852                	sd	s4,16(sp)
    8000135e:	e456                	sd	s5,8(sp)
    80001360:	0080                	add	s0,sp,64
    80001362:	8aaa                	mv	s5,a0
    80001364:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001366:	6785                	lui	a5,0x1
    80001368:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000136a:	95be                	add	a1,a1,a5
    8000136c:	77fd                	lui	a5,0xfffff
    8000136e:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001372:	08c9f063          	bgeu	s3,a2,800013f2 <uvmalloc+0xa2>
    80001376:	f426                	sd	s1,40(sp)
    80001378:	f04a                	sd	s2,32(sp)
    8000137a:	e05a                	sd	s6,0(sp)
    8000137c:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000137e:	0126eb13          	or	s6,a3,18
    mem = kalloc();
    80001382:	fa2ff0ef          	jal	80000b24 <kalloc>
    80001386:	84aa                	mv	s1,a0
    if(mem == 0){
    80001388:	c515                	beqz	a0,800013b4 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000138a:	6605                	lui	a2,0x1
    8000138c:	4581                	li	a1,0
    8000138e:	93bff0ef          	jal	80000cc8 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001392:	875a                	mv	a4,s6
    80001394:	86a6                	mv	a3,s1
    80001396:	6605                	lui	a2,0x1
    80001398:	85ca                	mv	a1,s2
    8000139a:	8556                	mv	a0,s5
    8000139c:	c79ff0ef          	jal	80001014 <mappages>
    800013a0:	e915                	bnez	a0,800013d4 <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800013a2:	6785                	lui	a5,0x1
    800013a4:	993e                	add	s2,s2,a5
    800013a6:	fd496ee3          	bltu	s2,s4,80001382 <uvmalloc+0x32>
  return newsz;
    800013aa:	8552                	mv	a0,s4
    800013ac:	74a2                	ld	s1,40(sp)
    800013ae:	7902                	ld	s2,32(sp)
    800013b0:	6b02                	ld	s6,0(sp)
    800013b2:	a811                	j	800013c6 <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    800013b4:	864e                	mv	a2,s3
    800013b6:	85ca                	mv	a1,s2
    800013b8:	8556                	mv	a0,s5
    800013ba:	f53ff0ef          	jal	8000130c <uvmdealloc>
      return 0;
    800013be:	4501                	li	a0,0
    800013c0:	74a2                	ld	s1,40(sp)
    800013c2:	7902                	ld	s2,32(sp)
    800013c4:	6b02                	ld	s6,0(sp)
}
    800013c6:	70e2                	ld	ra,56(sp)
    800013c8:	7442                	ld	s0,48(sp)
    800013ca:	69e2                	ld	s3,24(sp)
    800013cc:	6a42                	ld	s4,16(sp)
    800013ce:	6aa2                	ld	s5,8(sp)
    800013d0:	6121                	add	sp,sp,64
    800013d2:	8082                	ret
      kfree(mem);
    800013d4:	8526                	mv	a0,s1
    800013d6:	e6cff0ef          	jal	80000a42 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800013da:	864e                	mv	a2,s3
    800013dc:	85ca                	mv	a1,s2
    800013de:	8556                	mv	a0,s5
    800013e0:	f2dff0ef          	jal	8000130c <uvmdealloc>
      return 0;
    800013e4:	4501                	li	a0,0
    800013e6:	74a2                	ld	s1,40(sp)
    800013e8:	7902                	ld	s2,32(sp)
    800013ea:	6b02                	ld	s6,0(sp)
    800013ec:	bfe9                	j	800013c6 <uvmalloc+0x76>
    return oldsz;
    800013ee:	852e                	mv	a0,a1
}
    800013f0:	8082                	ret
  return newsz;
    800013f2:	8532                	mv	a0,a2
    800013f4:	bfc9                	j	800013c6 <uvmalloc+0x76>

00000000800013f6 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800013f6:	7179                	add	sp,sp,-48
    800013f8:	f406                	sd	ra,40(sp)
    800013fa:	f022                	sd	s0,32(sp)
    800013fc:	ec26                	sd	s1,24(sp)
    800013fe:	e84a                	sd	s2,16(sp)
    80001400:	e44e                	sd	s3,8(sp)
    80001402:	e052                	sd	s4,0(sp)
    80001404:	1800                	add	s0,sp,48
    80001406:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001408:	84aa                	mv	s1,a0
    8000140a:	6905                	lui	s2,0x1
    8000140c:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000140e:	4985                	li	s3,1
    80001410:	a819                	j	80001426 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001412:	83a9                	srl	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001414:	00c79513          	sll	a0,a5,0xc
    80001418:	fdfff0ef          	jal	800013f6 <freewalk>
      pagetable[i] = 0;
    8000141c:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001420:	04a1                	add	s1,s1,8
    80001422:	01248f63          	beq	s1,s2,80001440 <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80001426:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001428:	00f7f713          	and	a4,a5,15
    8000142c:	ff3703e3          	beq	a4,s3,80001412 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001430:	8b85                	and	a5,a5,1
    80001432:	d7fd                	beqz	a5,80001420 <freewalk+0x2a>
      panic("freewalk: leaf");
    80001434:	00006517          	auipc	a0,0x6
    80001438:	d6450513          	add	a0,a0,-668 # 80007198 <etext+0x198>
    8000143c:	b58ff0ef          	jal	80000794 <panic>
    }
  }
  kfree((void*)pagetable);
    80001440:	8552                	mv	a0,s4
    80001442:	e00ff0ef          	jal	80000a42 <kfree>
}
    80001446:	70a2                	ld	ra,40(sp)
    80001448:	7402                	ld	s0,32(sp)
    8000144a:	64e2                	ld	s1,24(sp)
    8000144c:	6942                	ld	s2,16(sp)
    8000144e:	69a2                	ld	s3,8(sp)
    80001450:	6a02                	ld	s4,0(sp)
    80001452:	6145                	add	sp,sp,48
    80001454:	8082                	ret

0000000080001456 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001456:	1101                	add	sp,sp,-32
    80001458:	ec06                	sd	ra,24(sp)
    8000145a:	e822                	sd	s0,16(sp)
    8000145c:	e426                	sd	s1,8(sp)
    8000145e:	1000                	add	s0,sp,32
    80001460:	84aa                	mv	s1,a0
  if(sz > 0)
    80001462:	e989                	bnez	a1,80001474 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001464:	8526                	mv	a0,s1
    80001466:	f91ff0ef          	jal	800013f6 <freewalk>
}
    8000146a:	60e2                	ld	ra,24(sp)
    8000146c:	6442                	ld	s0,16(sp)
    8000146e:	64a2                	ld	s1,8(sp)
    80001470:	6105                	add	sp,sp,32
    80001472:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001474:	6785                	lui	a5,0x1
    80001476:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001478:	95be                	add	a1,a1,a5
    8000147a:	4685                	li	a3,1
    8000147c:	00c5d613          	srl	a2,a1,0xc
    80001480:	4581                	li	a1,0
    80001482:	d4bff0ef          	jal	800011cc <uvmunmap>
    80001486:	bff9                	j	80001464 <uvmfree+0xe>

0000000080001488 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001488:	c65d                	beqz	a2,80001536 <uvmcopy+0xae>
{
    8000148a:	715d                	add	sp,sp,-80
    8000148c:	e486                	sd	ra,72(sp)
    8000148e:	e0a2                	sd	s0,64(sp)
    80001490:	fc26                	sd	s1,56(sp)
    80001492:	f84a                	sd	s2,48(sp)
    80001494:	f44e                	sd	s3,40(sp)
    80001496:	f052                	sd	s4,32(sp)
    80001498:	ec56                	sd	s5,24(sp)
    8000149a:	e85a                	sd	s6,16(sp)
    8000149c:	e45e                	sd	s7,8(sp)
    8000149e:	0880                	add	s0,sp,80
    800014a0:	8b2a                	mv	s6,a0
    800014a2:	8aae                	mv	s5,a1
    800014a4:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800014a6:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800014a8:	4601                	li	a2,0
    800014aa:	85ce                	mv	a1,s3
    800014ac:	855a                	mv	a0,s6
    800014ae:	a8fff0ef          	jal	80000f3c <walk>
    800014b2:	c121                	beqz	a0,800014f2 <uvmcopy+0x6a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800014b4:	6118                	ld	a4,0(a0)
    800014b6:	00177793          	and	a5,a4,1
    800014ba:	c3b1                	beqz	a5,800014fe <uvmcopy+0x76>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800014bc:	00a75593          	srl	a1,a4,0xa
    800014c0:	00c59b93          	sll	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800014c4:	3ff77493          	and	s1,a4,1023
    if((mem = kalloc()) == 0)
    800014c8:	e5cff0ef          	jal	80000b24 <kalloc>
    800014cc:	892a                	mv	s2,a0
    800014ce:	c129                	beqz	a0,80001510 <uvmcopy+0x88>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800014d0:	6605                	lui	a2,0x1
    800014d2:	85de                	mv	a1,s7
    800014d4:	851ff0ef          	jal	80000d24 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800014d8:	8726                	mv	a4,s1
    800014da:	86ca                	mv	a3,s2
    800014dc:	6605                	lui	a2,0x1
    800014de:	85ce                	mv	a1,s3
    800014e0:	8556                	mv	a0,s5
    800014e2:	b33ff0ef          	jal	80001014 <mappages>
    800014e6:	e115                	bnez	a0,8000150a <uvmcopy+0x82>
  for(i = 0; i < sz; i += PGSIZE){
    800014e8:	6785                	lui	a5,0x1
    800014ea:	99be                	add	s3,s3,a5
    800014ec:	fb49eee3          	bltu	s3,s4,800014a8 <uvmcopy+0x20>
    800014f0:	a805                	j	80001520 <uvmcopy+0x98>
      panic("uvmcopy: pte should exist");
    800014f2:	00006517          	auipc	a0,0x6
    800014f6:	cb650513          	add	a0,a0,-842 # 800071a8 <etext+0x1a8>
    800014fa:	a9aff0ef          	jal	80000794 <panic>
      panic("uvmcopy: page not present");
    800014fe:	00006517          	auipc	a0,0x6
    80001502:	cca50513          	add	a0,a0,-822 # 800071c8 <etext+0x1c8>
    80001506:	a8eff0ef          	jal	80000794 <panic>
      kfree(mem);
    8000150a:	854a                	mv	a0,s2
    8000150c:	d36ff0ef          	jal	80000a42 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001510:	4685                	li	a3,1
    80001512:	00c9d613          	srl	a2,s3,0xc
    80001516:	4581                	li	a1,0
    80001518:	8556                	mv	a0,s5
    8000151a:	cb3ff0ef          	jal	800011cc <uvmunmap>
  return -1;
    8000151e:	557d                	li	a0,-1
}
    80001520:	60a6                	ld	ra,72(sp)
    80001522:	6406                	ld	s0,64(sp)
    80001524:	74e2                	ld	s1,56(sp)
    80001526:	7942                	ld	s2,48(sp)
    80001528:	79a2                	ld	s3,40(sp)
    8000152a:	7a02                	ld	s4,32(sp)
    8000152c:	6ae2                	ld	s5,24(sp)
    8000152e:	6b42                	ld	s6,16(sp)
    80001530:	6ba2                	ld	s7,8(sp)
    80001532:	6161                	add	sp,sp,80
    80001534:	8082                	ret
  return 0;
    80001536:	4501                	li	a0,0
}
    80001538:	8082                	ret

000000008000153a <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000153a:	1141                	add	sp,sp,-16
    8000153c:	e406                	sd	ra,8(sp)
    8000153e:	e022                	sd	s0,0(sp)
    80001540:	0800                	add	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001542:	4601                	li	a2,0
    80001544:	9f9ff0ef          	jal	80000f3c <walk>
  if(pte == 0)
    80001548:	c901                	beqz	a0,80001558 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000154a:	611c                	ld	a5,0(a0)
    8000154c:	9bbd                	and	a5,a5,-17
    8000154e:	e11c                	sd	a5,0(a0)
}
    80001550:	60a2                	ld	ra,8(sp)
    80001552:	6402                	ld	s0,0(sp)
    80001554:	0141                	add	sp,sp,16
    80001556:	8082                	ret
    panic("uvmclear");
    80001558:	00006517          	auipc	a0,0x6
    8000155c:	c9050513          	add	a0,a0,-880 # 800071e8 <etext+0x1e8>
    80001560:	a34ff0ef          	jal	80000794 <panic>

0000000080001564 <copyout>:
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    80001564:	cad1                	beqz	a3,800015f8 <copyout+0x94>
{
    80001566:	711d                	add	sp,sp,-96
    80001568:	ec86                	sd	ra,88(sp)
    8000156a:	e8a2                	sd	s0,80(sp)
    8000156c:	e4a6                	sd	s1,72(sp)
    8000156e:	fc4e                	sd	s3,56(sp)
    80001570:	f456                	sd	s5,40(sp)
    80001572:	f05a                	sd	s6,32(sp)
    80001574:	ec5e                	sd	s7,24(sp)
    80001576:	1080                	add	s0,sp,96
    80001578:	8baa                	mv	s7,a0
    8000157a:	8aae                	mv	s5,a1
    8000157c:	8b32                	mv	s6,a2
    8000157e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001580:	74fd                	lui	s1,0xfffff
    80001582:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80001584:	57fd                	li	a5,-1
    80001586:	83e9                	srl	a5,a5,0x1a
    80001588:	0697ea63          	bltu	a5,s1,800015fc <copyout+0x98>
    8000158c:	e0ca                	sd	s2,64(sp)
    8000158e:	f852                	sd	s4,48(sp)
    80001590:	e862                	sd	s8,16(sp)
    80001592:	e466                	sd	s9,8(sp)
    80001594:	e06a                	sd	s10,0(sp)
      return -1;
    pte = walk(pagetable, va0, 0);
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    80001596:	4cd5                	li	s9,21
    80001598:	6d05                	lui	s10,0x1
    if(va0 >= MAXVA)
    8000159a:	8c3e                	mv	s8,a5
    8000159c:	a025                	j	800015c4 <copyout+0x60>
       (*pte & PTE_W) == 0)
      return -1;
    pa0 = PTE2PA(*pte);
    8000159e:	83a9                	srl	a5,a5,0xa
    800015a0:	07b2                	sll	a5,a5,0xc
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800015a2:	409a8533          	sub	a0,s5,s1
    800015a6:	0009061b          	sext.w	a2,s2
    800015aa:	85da                	mv	a1,s6
    800015ac:	953e                	add	a0,a0,a5
    800015ae:	f76ff0ef          	jal	80000d24 <memmove>

    len -= n;
    800015b2:	412989b3          	sub	s3,s3,s2
    src += n;
    800015b6:	9b4a                	add	s6,s6,s2
  while(len > 0){
    800015b8:	02098963          	beqz	s3,800015ea <copyout+0x86>
    if(va0 >= MAXVA)
    800015bc:	054c6263          	bltu	s8,s4,80001600 <copyout+0x9c>
    800015c0:	84d2                	mv	s1,s4
    800015c2:	8ad2                	mv	s5,s4
    pte = walk(pagetable, va0, 0);
    800015c4:	4601                	li	a2,0
    800015c6:	85a6                	mv	a1,s1
    800015c8:	855e                	mv	a0,s7
    800015ca:	973ff0ef          	jal	80000f3c <walk>
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    800015ce:	c121                	beqz	a0,8000160e <copyout+0xaa>
    800015d0:	611c                	ld	a5,0(a0)
    800015d2:	0157f713          	and	a4,a5,21
    800015d6:	05971b63          	bne	a4,s9,8000162c <copyout+0xc8>
    n = PGSIZE - (dstva - va0);
    800015da:	01a48a33          	add	s4,s1,s10
    800015de:	415a0933          	sub	s2,s4,s5
    if(n > len)
    800015e2:	fb29fee3          	bgeu	s3,s2,8000159e <copyout+0x3a>
    800015e6:	894e                	mv	s2,s3
    800015e8:	bf5d                	j	8000159e <copyout+0x3a>
    dstva = va0 + PGSIZE;
  }
  return 0;
    800015ea:	4501                	li	a0,0
    800015ec:	6906                	ld	s2,64(sp)
    800015ee:	7a42                	ld	s4,48(sp)
    800015f0:	6c42                	ld	s8,16(sp)
    800015f2:	6ca2                	ld	s9,8(sp)
    800015f4:	6d02                	ld	s10,0(sp)
    800015f6:	a015                	j	8000161a <copyout+0xb6>
    800015f8:	4501                	li	a0,0
}
    800015fa:	8082                	ret
      return -1;
    800015fc:	557d                	li	a0,-1
    800015fe:	a831                	j	8000161a <copyout+0xb6>
    80001600:	557d                	li	a0,-1
    80001602:	6906                	ld	s2,64(sp)
    80001604:	7a42                	ld	s4,48(sp)
    80001606:	6c42                	ld	s8,16(sp)
    80001608:	6ca2                	ld	s9,8(sp)
    8000160a:	6d02                	ld	s10,0(sp)
    8000160c:	a039                	j	8000161a <copyout+0xb6>
      return -1;
    8000160e:	557d                	li	a0,-1
    80001610:	6906                	ld	s2,64(sp)
    80001612:	7a42                	ld	s4,48(sp)
    80001614:	6c42                	ld	s8,16(sp)
    80001616:	6ca2                	ld	s9,8(sp)
    80001618:	6d02                	ld	s10,0(sp)
}
    8000161a:	60e6                	ld	ra,88(sp)
    8000161c:	6446                	ld	s0,80(sp)
    8000161e:	64a6                	ld	s1,72(sp)
    80001620:	79e2                	ld	s3,56(sp)
    80001622:	7aa2                	ld	s5,40(sp)
    80001624:	7b02                	ld	s6,32(sp)
    80001626:	6be2                	ld	s7,24(sp)
    80001628:	6125                	add	sp,sp,96
    8000162a:	8082                	ret
      return -1;
    8000162c:	557d                	li	a0,-1
    8000162e:	6906                	ld	s2,64(sp)
    80001630:	7a42                	ld	s4,48(sp)
    80001632:	6c42                	ld	s8,16(sp)
    80001634:	6ca2                	ld	s9,8(sp)
    80001636:	6d02                	ld	s10,0(sp)
    80001638:	b7cd                	j	8000161a <copyout+0xb6>

000000008000163a <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000163a:	c6a5                	beqz	a3,800016a2 <copyin+0x68>
{
    8000163c:	715d                	add	sp,sp,-80
    8000163e:	e486                	sd	ra,72(sp)
    80001640:	e0a2                	sd	s0,64(sp)
    80001642:	fc26                	sd	s1,56(sp)
    80001644:	f84a                	sd	s2,48(sp)
    80001646:	f44e                	sd	s3,40(sp)
    80001648:	f052                	sd	s4,32(sp)
    8000164a:	ec56                	sd	s5,24(sp)
    8000164c:	e85a                	sd	s6,16(sp)
    8000164e:	e45e                	sd	s7,8(sp)
    80001650:	e062                	sd	s8,0(sp)
    80001652:	0880                	add	s0,sp,80
    80001654:	8b2a                	mv	s6,a0
    80001656:	8a2e                	mv	s4,a1
    80001658:	8c32                	mv	s8,a2
    8000165a:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000165c:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000165e:	6a85                	lui	s5,0x1
    80001660:	a00d                	j	80001682 <copyin+0x48>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001662:	018505b3          	add	a1,a0,s8
    80001666:	0004861b          	sext.w	a2,s1
    8000166a:	412585b3          	sub	a1,a1,s2
    8000166e:	8552                	mv	a0,s4
    80001670:	eb4ff0ef          	jal	80000d24 <memmove>

    len -= n;
    80001674:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001678:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000167a:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000167e:	02098063          	beqz	s3,8000169e <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    80001682:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001686:	85ca                	mv	a1,s2
    80001688:	855a                	mv	a0,s6
    8000168a:	94dff0ef          	jal	80000fd6 <walkaddr>
    if(pa0 == 0)
    8000168e:	cd01                	beqz	a0,800016a6 <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    80001690:	418904b3          	sub	s1,s2,s8
    80001694:	94d6                	add	s1,s1,s5
    if(n > len)
    80001696:	fc99f6e3          	bgeu	s3,s1,80001662 <copyin+0x28>
    8000169a:	84ce                	mv	s1,s3
    8000169c:	b7d9                	j	80001662 <copyin+0x28>
  }
  return 0;
    8000169e:	4501                	li	a0,0
    800016a0:	a021                	j	800016a8 <copyin+0x6e>
    800016a2:	4501                	li	a0,0
}
    800016a4:	8082                	ret
      return -1;
    800016a6:	557d                	li	a0,-1
}
    800016a8:	60a6                	ld	ra,72(sp)
    800016aa:	6406                	ld	s0,64(sp)
    800016ac:	74e2                	ld	s1,56(sp)
    800016ae:	7942                	ld	s2,48(sp)
    800016b0:	79a2                	ld	s3,40(sp)
    800016b2:	7a02                	ld	s4,32(sp)
    800016b4:	6ae2                	ld	s5,24(sp)
    800016b6:	6b42                	ld	s6,16(sp)
    800016b8:	6ba2                	ld	s7,8(sp)
    800016ba:	6c02                	ld	s8,0(sp)
    800016bc:	6161                	add	sp,sp,80
    800016be:	8082                	ret

00000000800016c0 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800016c0:	c6dd                	beqz	a3,8000176e <copyinstr+0xae>
{
    800016c2:	715d                	add	sp,sp,-80
    800016c4:	e486                	sd	ra,72(sp)
    800016c6:	e0a2                	sd	s0,64(sp)
    800016c8:	fc26                	sd	s1,56(sp)
    800016ca:	f84a                	sd	s2,48(sp)
    800016cc:	f44e                	sd	s3,40(sp)
    800016ce:	f052                	sd	s4,32(sp)
    800016d0:	ec56                	sd	s5,24(sp)
    800016d2:	e85a                	sd	s6,16(sp)
    800016d4:	e45e                	sd	s7,8(sp)
    800016d6:	0880                	add	s0,sp,80
    800016d8:	8a2a                	mv	s4,a0
    800016da:	8b2e                	mv	s6,a1
    800016dc:	8bb2                	mv	s7,a2
    800016de:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    800016e0:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800016e2:	6985                	lui	s3,0x1
    800016e4:	a825                	j	8000171c <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800016e6:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800016ea:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800016ec:	37fd                	addw	a5,a5,-1
    800016ee:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800016f2:	60a6                	ld	ra,72(sp)
    800016f4:	6406                	ld	s0,64(sp)
    800016f6:	74e2                	ld	s1,56(sp)
    800016f8:	7942                	ld	s2,48(sp)
    800016fa:	79a2                	ld	s3,40(sp)
    800016fc:	7a02                	ld	s4,32(sp)
    800016fe:	6ae2                	ld	s5,24(sp)
    80001700:	6b42                	ld	s6,16(sp)
    80001702:	6ba2                	ld	s7,8(sp)
    80001704:	6161                	add	sp,sp,80
    80001706:	8082                	ret
    80001708:	fff90713          	add	a4,s2,-1 # fff <_entry-0x7ffff001>
    8000170c:	9742                	add	a4,a4,a6
      --max;
    8000170e:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80001712:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80001716:	04e58463          	beq	a1,a4,8000175e <copyinstr+0x9e>
{
    8000171a:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    8000171c:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001720:	85a6                	mv	a1,s1
    80001722:	8552                	mv	a0,s4
    80001724:	8b3ff0ef          	jal	80000fd6 <walkaddr>
    if(pa0 == 0)
    80001728:	cd0d                	beqz	a0,80001762 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    8000172a:	417486b3          	sub	a3,s1,s7
    8000172e:	96ce                	add	a3,a3,s3
    if(n > max)
    80001730:	00d97363          	bgeu	s2,a3,80001736 <copyinstr+0x76>
    80001734:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80001736:	955e                	add	a0,a0,s7
    80001738:	8d05                	sub	a0,a0,s1
    while(n > 0){
    8000173a:	c695                	beqz	a3,80001766 <copyinstr+0xa6>
    8000173c:	87da                	mv	a5,s6
    8000173e:	885a                	mv	a6,s6
      if(*p == '\0'){
    80001740:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80001744:	96da                	add	a3,a3,s6
    80001746:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001748:	00f60733          	add	a4,a2,a5
    8000174c:	00074703          	lbu	a4,0(a4)
    80001750:	db59                	beqz	a4,800016e6 <copyinstr+0x26>
        *dst = *p;
    80001752:	00e78023          	sb	a4,0(a5)
      dst++;
    80001756:	0785                	add	a5,a5,1
    while(n > 0){
    80001758:	fed797e3          	bne	a5,a3,80001746 <copyinstr+0x86>
    8000175c:	b775                	j	80001708 <copyinstr+0x48>
    8000175e:	4781                	li	a5,0
    80001760:	b771                	j	800016ec <copyinstr+0x2c>
      return -1;
    80001762:	557d                	li	a0,-1
    80001764:	b779                	j	800016f2 <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    80001766:	6b85                	lui	s7,0x1
    80001768:	9ba6                	add	s7,s7,s1
    8000176a:	87da                	mv	a5,s6
    8000176c:	b77d                	j	8000171a <copyinstr+0x5a>
  int got_null = 0;
    8000176e:	4781                	li	a5,0
  if(got_null){
    80001770:	37fd                	addw	a5,a5,-1
    80001772:	0007851b          	sext.w	a0,a5
}
    80001776:	8082                	ret

0000000080001778 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001778:	7139                	add	sp,sp,-64
    8000177a:	fc06                	sd	ra,56(sp)
    8000177c:	f822                	sd	s0,48(sp)
    8000177e:	f426                	sd	s1,40(sp)
    80001780:	f04a                	sd	s2,32(sp)
    80001782:	ec4e                	sd	s3,24(sp)
    80001784:	e852                	sd	s4,16(sp)
    80001786:	e456                	sd	s5,8(sp)
    80001788:	e05a                	sd	s6,0(sp)
    8000178a:	0080                	add	s0,sp,64
    8000178c:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000178e:	0000e497          	auipc	s1,0xe
    80001792:	6d248493          	add	s1,s1,1746 # 8000fe60 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001796:	8b26                	mv	s6,s1
    80001798:	04fa5937          	lui	s2,0x4fa5
    8000179c:	fa590913          	add	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    800017a0:	0932                	sll	s2,s2,0xc
    800017a2:	fa590913          	add	s2,s2,-91
    800017a6:	0932                	sll	s2,s2,0xc
    800017a8:	fa590913          	add	s2,s2,-91
    800017ac:	0932                	sll	s2,s2,0xc
    800017ae:	fa590913          	add	s2,s2,-91
    800017b2:	040009b7          	lui	s3,0x4000
    800017b6:	19fd                	add	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017b8:	09b2                	sll	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800017ba:	00014a97          	auipc	s5,0x14
    800017be:	0a6a8a93          	add	s5,s5,166 # 80015860 <tickslock>
    char *pa = kalloc();
    800017c2:	b62ff0ef          	jal	80000b24 <kalloc>
    800017c6:	862a                	mv	a2,a0
    if(pa == 0)
    800017c8:	cd15                	beqz	a0,80001804 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    800017ca:	416485b3          	sub	a1,s1,s6
    800017ce:	858d                	sra	a1,a1,0x3
    800017d0:	032585b3          	mul	a1,a1,s2
    800017d4:	2585                	addw	a1,a1,1 # 100001 <_entry-0x7fefffff>
    800017d6:	00d5959b          	sllw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017da:	4719                	li	a4,6
    800017dc:	6685                	lui	a3,0x1
    800017de:	40b985b3          	sub	a1,s3,a1
    800017e2:	8552                	mv	a0,s4
    800017e4:	8e1ff0ef          	jal	800010c4 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800017e8:	16848493          	add	s1,s1,360
    800017ec:	fd549be3          	bne	s1,s5,800017c2 <proc_mapstacks+0x4a>
  }
}
    800017f0:	70e2                	ld	ra,56(sp)
    800017f2:	7442                	ld	s0,48(sp)
    800017f4:	74a2                	ld	s1,40(sp)
    800017f6:	7902                	ld	s2,32(sp)
    800017f8:	69e2                	ld	s3,24(sp)
    800017fa:	6a42                	ld	s4,16(sp)
    800017fc:	6aa2                	ld	s5,8(sp)
    800017fe:	6b02                	ld	s6,0(sp)
    80001800:	6121                	add	sp,sp,64
    80001802:	8082                	ret
      panic("kalloc");
    80001804:	00006517          	auipc	a0,0x6
    80001808:	9f450513          	add	a0,a0,-1548 # 800071f8 <etext+0x1f8>
    8000180c:	f89fe0ef          	jal	80000794 <panic>

0000000080001810 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001810:	7139                	add	sp,sp,-64
    80001812:	fc06                	sd	ra,56(sp)
    80001814:	f822                	sd	s0,48(sp)
    80001816:	f426                	sd	s1,40(sp)
    80001818:	f04a                	sd	s2,32(sp)
    8000181a:	ec4e                	sd	s3,24(sp)
    8000181c:	e852                	sd	s4,16(sp)
    8000181e:	e456                	sd	s5,8(sp)
    80001820:	e05a                	sd	s6,0(sp)
    80001822:	0080                	add	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001824:	00006597          	auipc	a1,0x6
    80001828:	9dc58593          	add	a1,a1,-1572 # 80007200 <etext+0x200>
    8000182c:	0000e517          	auipc	a0,0xe
    80001830:	20450513          	add	a0,a0,516 # 8000fa30 <pid_lock>
    80001834:	b40ff0ef          	jal	80000b74 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001838:	00006597          	auipc	a1,0x6
    8000183c:	9d058593          	add	a1,a1,-1584 # 80007208 <etext+0x208>
    80001840:	0000e517          	auipc	a0,0xe
    80001844:	20850513          	add	a0,a0,520 # 8000fa48 <wait_lock>
    80001848:	b2cff0ef          	jal	80000b74 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000184c:	0000e497          	auipc	s1,0xe
    80001850:	61448493          	add	s1,s1,1556 # 8000fe60 <proc>
      initlock(&p->lock, "proc");
    80001854:	00006b17          	auipc	s6,0x6
    80001858:	9c4b0b13          	add	s6,s6,-1596 # 80007218 <etext+0x218>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000185c:	8aa6                	mv	s5,s1
    8000185e:	04fa5937          	lui	s2,0x4fa5
    80001862:	fa590913          	add	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001866:	0932                	sll	s2,s2,0xc
    80001868:	fa590913          	add	s2,s2,-91
    8000186c:	0932                	sll	s2,s2,0xc
    8000186e:	fa590913          	add	s2,s2,-91
    80001872:	0932                	sll	s2,s2,0xc
    80001874:	fa590913          	add	s2,s2,-91
    80001878:	040009b7          	lui	s3,0x4000
    8000187c:	19fd                	add	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000187e:	09b2                	sll	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001880:	00014a17          	auipc	s4,0x14
    80001884:	fe0a0a13          	add	s4,s4,-32 # 80015860 <tickslock>
      initlock(&p->lock, "proc");
    80001888:	85da                	mv	a1,s6
    8000188a:	8526                	mv	a0,s1
    8000188c:	ae8ff0ef          	jal	80000b74 <initlock>
      p->state = UNUSED;
    80001890:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001894:	415487b3          	sub	a5,s1,s5
    80001898:	878d                	sra	a5,a5,0x3
    8000189a:	032787b3          	mul	a5,a5,s2
    8000189e:	2785                	addw	a5,a5,1
    800018a0:	00d7979b          	sllw	a5,a5,0xd
    800018a4:	40f987b3          	sub	a5,s3,a5
    800018a8:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800018aa:	16848493          	add	s1,s1,360
    800018ae:	fd449de3          	bne	s1,s4,80001888 <procinit+0x78>
  }
}
    800018b2:	70e2                	ld	ra,56(sp)
    800018b4:	7442                	ld	s0,48(sp)
    800018b6:	74a2                	ld	s1,40(sp)
    800018b8:	7902                	ld	s2,32(sp)
    800018ba:	69e2                	ld	s3,24(sp)
    800018bc:	6a42                	ld	s4,16(sp)
    800018be:	6aa2                	ld	s5,8(sp)
    800018c0:	6b02                	ld	s6,0(sp)
    800018c2:	6121                	add	sp,sp,64
    800018c4:	8082                	ret

00000000800018c6 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018c6:	1141                	add	sp,sp,-16
    800018c8:	e422                	sd	s0,8(sp)
    800018ca:	0800                	add	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800018cc:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018ce:	2501                	sext.w	a0,a0
    800018d0:	6422                	ld	s0,8(sp)
    800018d2:	0141                	add	sp,sp,16
    800018d4:	8082                	ret

00000000800018d6 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800018d6:	1141                	add	sp,sp,-16
    800018d8:	e422                	sd	s0,8(sp)
    800018da:	0800                	add	s0,sp,16
    800018dc:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800018de:	2781                	sext.w	a5,a5
    800018e0:	079e                	sll	a5,a5,0x7
  return c;
}
    800018e2:	0000e517          	auipc	a0,0xe
    800018e6:	17e50513          	add	a0,a0,382 # 8000fa60 <cpus>
    800018ea:	953e                	add	a0,a0,a5
    800018ec:	6422                	ld	s0,8(sp)
    800018ee:	0141                	add	sp,sp,16
    800018f0:	8082                	ret

00000000800018f2 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800018f2:	1101                	add	sp,sp,-32
    800018f4:	ec06                	sd	ra,24(sp)
    800018f6:	e822                	sd	s0,16(sp)
    800018f8:	e426                	sd	s1,8(sp)
    800018fa:	1000                	add	s0,sp,32
  push_off();
    800018fc:	ab8ff0ef          	jal	80000bb4 <push_off>
    80001900:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001902:	2781                	sext.w	a5,a5
    80001904:	079e                	sll	a5,a5,0x7
    80001906:	0000e717          	auipc	a4,0xe
    8000190a:	12a70713          	add	a4,a4,298 # 8000fa30 <pid_lock>
    8000190e:	97ba                	add	a5,a5,a4
    80001910:	7b84                	ld	s1,48(a5)
  pop_off();
    80001912:	b26ff0ef          	jal	80000c38 <pop_off>
  return p;
}
    80001916:	8526                	mv	a0,s1
    80001918:	60e2                	ld	ra,24(sp)
    8000191a:	6442                	ld	s0,16(sp)
    8000191c:	64a2                	ld	s1,8(sp)
    8000191e:	6105                	add	sp,sp,32
    80001920:	8082                	ret

0000000080001922 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001922:	1141                	add	sp,sp,-16
    80001924:	e406                	sd	ra,8(sp)
    80001926:	e022                	sd	s0,0(sp)
    80001928:	0800                	add	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    8000192a:	fc9ff0ef          	jal	800018f2 <myproc>
    8000192e:	b5eff0ef          	jal	80000c8c <release>

  if (first) {
    80001932:	00006797          	auipc	a5,0x6
    80001936:	f4e7a783          	lw	a5,-178(a5) # 80007880 <first.1>
    8000193a:	e799                	bnez	a5,80001948 <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    8000193c:	2bf000ef          	jal	800023fa <usertrapret>
}
    80001940:	60a2                	ld	ra,8(sp)
    80001942:	6402                	ld	s0,0(sp)
    80001944:	0141                	add	sp,sp,16
    80001946:	8082                	ret
    fsinit(ROOTDEV);
    80001948:	4505                	li	a0,1
    8000194a:	654010ef          	jal	80002f9e <fsinit>
    first = 0;
    8000194e:	00006797          	auipc	a5,0x6
    80001952:	f207a923          	sw	zero,-206(a5) # 80007880 <first.1>
    __sync_synchronize();
    80001956:	0ff0000f          	fence
    8000195a:	b7cd                	j	8000193c <forkret+0x1a>

000000008000195c <allocpid>:
{
    8000195c:	1101                	add	sp,sp,-32
    8000195e:	ec06                	sd	ra,24(sp)
    80001960:	e822                	sd	s0,16(sp)
    80001962:	e426                	sd	s1,8(sp)
    80001964:	e04a                	sd	s2,0(sp)
    80001966:	1000                	add	s0,sp,32
  acquire(&pid_lock);
    80001968:	0000e917          	auipc	s2,0xe
    8000196c:	0c890913          	add	s2,s2,200 # 8000fa30 <pid_lock>
    80001970:	854a                	mv	a0,s2
    80001972:	a82ff0ef          	jal	80000bf4 <acquire>
  pid = nextpid;
    80001976:	00006797          	auipc	a5,0x6
    8000197a:	f0e78793          	add	a5,a5,-242 # 80007884 <nextpid>
    8000197e:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001980:	0014871b          	addw	a4,s1,1
    80001984:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001986:	854a                	mv	a0,s2
    80001988:	b04ff0ef          	jal	80000c8c <release>
}
    8000198c:	8526                	mv	a0,s1
    8000198e:	60e2                	ld	ra,24(sp)
    80001990:	6442                	ld	s0,16(sp)
    80001992:	64a2                	ld	s1,8(sp)
    80001994:	6902                	ld	s2,0(sp)
    80001996:	6105                	add	sp,sp,32
    80001998:	8082                	ret

000000008000199a <proc_pagetable>:
{
    8000199a:	1101                	add	sp,sp,-32
    8000199c:	ec06                	sd	ra,24(sp)
    8000199e:	e822                	sd	s0,16(sp)
    800019a0:	e426                	sd	s1,8(sp)
    800019a2:	e04a                	sd	s2,0(sp)
    800019a4:	1000                	add	s0,sp,32
    800019a6:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    800019a8:	8e1ff0ef          	jal	80001288 <uvmcreate>
    800019ac:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800019ae:	cd05                	beqz	a0,800019e6 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    800019b0:	4729                	li	a4,10
    800019b2:	00004697          	auipc	a3,0x4
    800019b6:	64e68693          	add	a3,a3,1614 # 80006000 <_trampoline>
    800019ba:	6605                	lui	a2,0x1
    800019bc:	040005b7          	lui	a1,0x4000
    800019c0:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019c2:	05b2                	sll	a1,a1,0xc
    800019c4:	e50ff0ef          	jal	80001014 <mappages>
    800019c8:	02054663          	bltz	a0,800019f4 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    800019cc:	4719                	li	a4,6
    800019ce:	05893683          	ld	a3,88(s2)
    800019d2:	6605                	lui	a2,0x1
    800019d4:	020005b7          	lui	a1,0x2000
    800019d8:	15fd                	add	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800019da:	05b6                	sll	a1,a1,0xd
    800019dc:	8526                	mv	a0,s1
    800019de:	e36ff0ef          	jal	80001014 <mappages>
    800019e2:	00054f63          	bltz	a0,80001a00 <proc_pagetable+0x66>
}
    800019e6:	8526                	mv	a0,s1
    800019e8:	60e2                	ld	ra,24(sp)
    800019ea:	6442                	ld	s0,16(sp)
    800019ec:	64a2                	ld	s1,8(sp)
    800019ee:	6902                	ld	s2,0(sp)
    800019f0:	6105                	add	sp,sp,32
    800019f2:	8082                	ret
    uvmfree(pagetable, 0);
    800019f4:	4581                	li	a1,0
    800019f6:	8526                	mv	a0,s1
    800019f8:	a5fff0ef          	jal	80001456 <uvmfree>
    return 0;
    800019fc:	4481                	li	s1,0
    800019fe:	b7e5                	j	800019e6 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a00:	4681                	li	a3,0
    80001a02:	4605                	li	a2,1
    80001a04:	040005b7          	lui	a1,0x4000
    80001a08:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a0a:	05b2                	sll	a1,a1,0xc
    80001a0c:	8526                	mv	a0,s1
    80001a0e:	fbeff0ef          	jal	800011cc <uvmunmap>
    uvmfree(pagetable, 0);
    80001a12:	4581                	li	a1,0
    80001a14:	8526                	mv	a0,s1
    80001a16:	a41ff0ef          	jal	80001456 <uvmfree>
    return 0;
    80001a1a:	4481                	li	s1,0
    80001a1c:	b7e9                	j	800019e6 <proc_pagetable+0x4c>

0000000080001a1e <proc_freepagetable>:
{
    80001a1e:	1101                	add	sp,sp,-32
    80001a20:	ec06                	sd	ra,24(sp)
    80001a22:	e822                	sd	s0,16(sp)
    80001a24:	e426                	sd	s1,8(sp)
    80001a26:	e04a                	sd	s2,0(sp)
    80001a28:	1000                	add	s0,sp,32
    80001a2a:	84aa                	mv	s1,a0
    80001a2c:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a2e:	4681                	li	a3,0
    80001a30:	4605                	li	a2,1
    80001a32:	040005b7          	lui	a1,0x4000
    80001a36:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a38:	05b2                	sll	a1,a1,0xc
    80001a3a:	f92ff0ef          	jal	800011cc <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001a3e:	4681                	li	a3,0
    80001a40:	4605                	li	a2,1
    80001a42:	020005b7          	lui	a1,0x2000
    80001a46:	15fd                	add	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a48:	05b6                	sll	a1,a1,0xd
    80001a4a:	8526                	mv	a0,s1
    80001a4c:	f80ff0ef          	jal	800011cc <uvmunmap>
  uvmfree(pagetable, sz);
    80001a50:	85ca                	mv	a1,s2
    80001a52:	8526                	mv	a0,s1
    80001a54:	a03ff0ef          	jal	80001456 <uvmfree>
}
    80001a58:	60e2                	ld	ra,24(sp)
    80001a5a:	6442                	ld	s0,16(sp)
    80001a5c:	64a2                	ld	s1,8(sp)
    80001a5e:	6902                	ld	s2,0(sp)
    80001a60:	6105                	add	sp,sp,32
    80001a62:	8082                	ret

0000000080001a64 <freeproc>:
{
    80001a64:	1101                	add	sp,sp,-32
    80001a66:	ec06                	sd	ra,24(sp)
    80001a68:	e822                	sd	s0,16(sp)
    80001a6a:	e426                	sd	s1,8(sp)
    80001a6c:	1000                	add	s0,sp,32
    80001a6e:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001a70:	6d28                	ld	a0,88(a0)
    80001a72:	c119                	beqz	a0,80001a78 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001a74:	fcffe0ef          	jal	80000a42 <kfree>
  p->trapframe = 0;
    80001a78:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001a7c:	68a8                	ld	a0,80(s1)
    80001a7e:	c501                	beqz	a0,80001a86 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001a80:	64ac                	ld	a1,72(s1)
    80001a82:	f9dff0ef          	jal	80001a1e <proc_freepagetable>
  p->pagetable = 0;
    80001a86:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001a8a:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001a8e:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001a92:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001a96:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001a9a:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001a9e:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001aa2:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001aa6:	0004ac23          	sw	zero,24(s1)
}
    80001aaa:	60e2                	ld	ra,24(sp)
    80001aac:	6442                	ld	s0,16(sp)
    80001aae:	64a2                	ld	s1,8(sp)
    80001ab0:	6105                	add	sp,sp,32
    80001ab2:	8082                	ret

0000000080001ab4 <allocproc>:
{
    80001ab4:	1101                	add	sp,sp,-32
    80001ab6:	ec06                	sd	ra,24(sp)
    80001ab8:	e822                	sd	s0,16(sp)
    80001aba:	e426                	sd	s1,8(sp)
    80001abc:	e04a                	sd	s2,0(sp)
    80001abe:	1000                	add	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ac0:	0000e497          	auipc	s1,0xe
    80001ac4:	3a048493          	add	s1,s1,928 # 8000fe60 <proc>
    80001ac8:	00014917          	auipc	s2,0x14
    80001acc:	d9890913          	add	s2,s2,-616 # 80015860 <tickslock>
    acquire(&p->lock);
    80001ad0:	8526                	mv	a0,s1
    80001ad2:	922ff0ef          	jal	80000bf4 <acquire>
    if(p->state == UNUSED) {
    80001ad6:	4c9c                	lw	a5,24(s1)
    80001ad8:	cb91                	beqz	a5,80001aec <allocproc+0x38>
      release(&p->lock);
    80001ada:	8526                	mv	a0,s1
    80001adc:	9b0ff0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ae0:	16848493          	add	s1,s1,360
    80001ae4:	ff2496e3          	bne	s1,s2,80001ad0 <allocproc+0x1c>
  return 0;
    80001ae8:	4481                	li	s1,0
    80001aea:	a089                	j	80001b2c <allocproc+0x78>
  p->pid = allocpid();
    80001aec:	e71ff0ef          	jal	8000195c <allocpid>
    80001af0:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001af2:	4785                	li	a5,1
    80001af4:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001af6:	82eff0ef          	jal	80000b24 <kalloc>
    80001afa:	892a                	mv	s2,a0
    80001afc:	eca8                	sd	a0,88(s1)
    80001afe:	cd15                	beqz	a0,80001b3a <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001b00:	8526                	mv	a0,s1
    80001b02:	e99ff0ef          	jal	8000199a <proc_pagetable>
    80001b06:	892a                	mv	s2,a0
    80001b08:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001b0a:	c121                	beqz	a0,80001b4a <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001b0c:	07000613          	li	a2,112
    80001b10:	4581                	li	a1,0
    80001b12:	06048513          	add	a0,s1,96
    80001b16:	9b2ff0ef          	jal	80000cc8 <memset>
  p->context.ra = (uint64)forkret;
    80001b1a:	00000797          	auipc	a5,0x0
    80001b1e:	e0878793          	add	a5,a5,-504 # 80001922 <forkret>
    80001b22:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b24:	60bc                	ld	a5,64(s1)
    80001b26:	6705                	lui	a4,0x1
    80001b28:	97ba                	add	a5,a5,a4
    80001b2a:	f4bc                	sd	a5,104(s1)
}
    80001b2c:	8526                	mv	a0,s1
    80001b2e:	60e2                	ld	ra,24(sp)
    80001b30:	6442                	ld	s0,16(sp)
    80001b32:	64a2                	ld	s1,8(sp)
    80001b34:	6902                	ld	s2,0(sp)
    80001b36:	6105                	add	sp,sp,32
    80001b38:	8082                	ret
    freeproc(p);
    80001b3a:	8526                	mv	a0,s1
    80001b3c:	f29ff0ef          	jal	80001a64 <freeproc>
    release(&p->lock);
    80001b40:	8526                	mv	a0,s1
    80001b42:	94aff0ef          	jal	80000c8c <release>
    return 0;
    80001b46:	84ca                	mv	s1,s2
    80001b48:	b7d5                	j	80001b2c <allocproc+0x78>
    freeproc(p);
    80001b4a:	8526                	mv	a0,s1
    80001b4c:	f19ff0ef          	jal	80001a64 <freeproc>
    release(&p->lock);
    80001b50:	8526                	mv	a0,s1
    80001b52:	93aff0ef          	jal	80000c8c <release>
    return 0;
    80001b56:	84ca                	mv	s1,s2
    80001b58:	bfd1                	j	80001b2c <allocproc+0x78>

0000000080001b5a <userinit>:
{
    80001b5a:	1101                	add	sp,sp,-32
    80001b5c:	ec06                	sd	ra,24(sp)
    80001b5e:	e822                	sd	s0,16(sp)
    80001b60:	e426                	sd	s1,8(sp)
    80001b62:	1000                	add	s0,sp,32
  p = allocproc();
    80001b64:	f51ff0ef          	jal	80001ab4 <allocproc>
    80001b68:	84aa                	mv	s1,a0
  initproc = p;
    80001b6a:	00006797          	auipc	a5,0x6
    80001b6e:	d8a7b723          	sd	a0,-626(a5) # 800078f8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001b72:	03400613          	li	a2,52
    80001b76:	00006597          	auipc	a1,0x6
    80001b7a:	d1a58593          	add	a1,a1,-742 # 80007890 <initcode>
    80001b7e:	6928                	ld	a0,80(a0)
    80001b80:	f2eff0ef          	jal	800012ae <uvmfirst>
  p->sz = PGSIZE;
    80001b84:	6785                	lui	a5,0x1
    80001b86:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001b88:	6cb8                	ld	a4,88(s1)
    80001b8a:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001b8e:	6cb8                	ld	a4,88(s1)
    80001b90:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001b92:	4641                	li	a2,16
    80001b94:	00005597          	auipc	a1,0x5
    80001b98:	68c58593          	add	a1,a1,1676 # 80007220 <etext+0x220>
    80001b9c:	15848513          	add	a0,s1,344
    80001ba0:	a66ff0ef          	jal	80000e06 <safestrcpy>
  p->cwd = namei("/");
    80001ba4:	00005517          	auipc	a0,0x5
    80001ba8:	68c50513          	add	a0,a0,1676 # 80007230 <etext+0x230>
    80001bac:	501010ef          	jal	800038ac <namei>
    80001bb0:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001bb4:	478d                	li	a5,3
    80001bb6:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001bb8:	8526                	mv	a0,s1
    80001bba:	8d2ff0ef          	jal	80000c8c <release>
}
    80001bbe:	60e2                	ld	ra,24(sp)
    80001bc0:	6442                	ld	s0,16(sp)
    80001bc2:	64a2                	ld	s1,8(sp)
    80001bc4:	6105                	add	sp,sp,32
    80001bc6:	8082                	ret

0000000080001bc8 <growproc>:
{
    80001bc8:	1101                	add	sp,sp,-32
    80001bca:	ec06                	sd	ra,24(sp)
    80001bcc:	e822                	sd	s0,16(sp)
    80001bce:	e426                	sd	s1,8(sp)
    80001bd0:	e04a                	sd	s2,0(sp)
    80001bd2:	1000                	add	s0,sp,32
    80001bd4:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001bd6:	d1dff0ef          	jal	800018f2 <myproc>
    80001bda:	84aa                	mv	s1,a0
  sz = p->sz;
    80001bdc:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001bde:	01204c63          	bgtz	s2,80001bf6 <growproc+0x2e>
  } else if(n < 0){
    80001be2:	02094463          	bltz	s2,80001c0a <growproc+0x42>
  p->sz = sz;
    80001be6:	e4ac                	sd	a1,72(s1)
  return 0;
    80001be8:	4501                	li	a0,0
}
    80001bea:	60e2                	ld	ra,24(sp)
    80001bec:	6442                	ld	s0,16(sp)
    80001bee:	64a2                	ld	s1,8(sp)
    80001bf0:	6902                	ld	s2,0(sp)
    80001bf2:	6105                	add	sp,sp,32
    80001bf4:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001bf6:	4691                	li	a3,4
    80001bf8:	00b90633          	add	a2,s2,a1
    80001bfc:	6928                	ld	a0,80(a0)
    80001bfe:	f52ff0ef          	jal	80001350 <uvmalloc>
    80001c02:	85aa                	mv	a1,a0
    80001c04:	f16d                	bnez	a0,80001be6 <growproc+0x1e>
      return -1;
    80001c06:	557d                	li	a0,-1
    80001c08:	b7cd                	j	80001bea <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c0a:	00b90633          	add	a2,s2,a1
    80001c0e:	6928                	ld	a0,80(a0)
    80001c10:	efcff0ef          	jal	8000130c <uvmdealloc>
    80001c14:	85aa                	mv	a1,a0
    80001c16:	bfc1                	j	80001be6 <growproc+0x1e>

0000000080001c18 <fork>:
{
    80001c18:	7139                	add	sp,sp,-64
    80001c1a:	fc06                	sd	ra,56(sp)
    80001c1c:	f822                	sd	s0,48(sp)
    80001c1e:	f04a                	sd	s2,32(sp)
    80001c20:	e456                	sd	s5,8(sp)
    80001c22:	0080                	add	s0,sp,64
  struct proc *p = myproc();
    80001c24:	ccfff0ef          	jal	800018f2 <myproc>
    80001c28:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001c2a:	e8bff0ef          	jal	80001ab4 <allocproc>
    80001c2e:	0e050a63          	beqz	a0,80001d22 <fork+0x10a>
    80001c32:	e852                	sd	s4,16(sp)
    80001c34:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001c36:	048ab603          	ld	a2,72(s5)
    80001c3a:	692c                	ld	a1,80(a0)
    80001c3c:	050ab503          	ld	a0,80(s5)
    80001c40:	849ff0ef          	jal	80001488 <uvmcopy>
    80001c44:	04054a63          	bltz	a0,80001c98 <fork+0x80>
    80001c48:	f426                	sd	s1,40(sp)
    80001c4a:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001c4c:	048ab783          	ld	a5,72(s5)
    80001c50:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001c54:	058ab683          	ld	a3,88(s5)
    80001c58:	87b6                	mv	a5,a3
    80001c5a:	058a3703          	ld	a4,88(s4)
    80001c5e:	12068693          	add	a3,a3,288
    80001c62:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001c66:	6788                	ld	a0,8(a5)
    80001c68:	6b8c                	ld	a1,16(a5)
    80001c6a:	6f90                	ld	a2,24(a5)
    80001c6c:	01073023          	sd	a6,0(a4)
    80001c70:	e708                	sd	a0,8(a4)
    80001c72:	eb0c                	sd	a1,16(a4)
    80001c74:	ef10                	sd	a2,24(a4)
    80001c76:	02078793          	add	a5,a5,32
    80001c7a:	02070713          	add	a4,a4,32
    80001c7e:	fed792e3          	bne	a5,a3,80001c62 <fork+0x4a>
  np->trapframe->a0 = 0;
    80001c82:	058a3783          	ld	a5,88(s4)
    80001c86:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001c8a:	0d0a8493          	add	s1,s5,208
    80001c8e:	0d0a0913          	add	s2,s4,208
    80001c92:	150a8993          	add	s3,s5,336
    80001c96:	a831                	j	80001cb2 <fork+0x9a>
    freeproc(np);
    80001c98:	8552                	mv	a0,s4
    80001c9a:	dcbff0ef          	jal	80001a64 <freeproc>
    release(&np->lock);
    80001c9e:	8552                	mv	a0,s4
    80001ca0:	fedfe0ef          	jal	80000c8c <release>
    return -1;
    80001ca4:	597d                	li	s2,-1
    80001ca6:	6a42                	ld	s4,16(sp)
    80001ca8:	a0b5                	j	80001d14 <fork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001caa:	04a1                	add	s1,s1,8
    80001cac:	0921                	add	s2,s2,8
    80001cae:	01348963          	beq	s1,s3,80001cc0 <fork+0xa8>
    if(p->ofile[i])
    80001cb2:	6088                	ld	a0,0(s1)
    80001cb4:	d97d                	beqz	a0,80001caa <fork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001cb6:	186020ef          	jal	80003e3c <filedup>
    80001cba:	00a93023          	sd	a0,0(s2)
    80001cbe:	b7f5                	j	80001caa <fork+0x92>
  np->cwd = idup(p->cwd);
    80001cc0:	150ab503          	ld	a0,336(s5)
    80001cc4:	4d8010ef          	jal	8000319c <idup>
    80001cc8:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ccc:	4641                	li	a2,16
    80001cce:	158a8593          	add	a1,s5,344
    80001cd2:	158a0513          	add	a0,s4,344
    80001cd6:	930ff0ef          	jal	80000e06 <safestrcpy>
  pid = np->pid;
    80001cda:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001cde:	8552                	mv	a0,s4
    80001ce0:	fadfe0ef          	jal	80000c8c <release>
  acquire(&wait_lock);
    80001ce4:	0000e497          	auipc	s1,0xe
    80001ce8:	d6448493          	add	s1,s1,-668 # 8000fa48 <wait_lock>
    80001cec:	8526                	mv	a0,s1
    80001cee:	f07fe0ef          	jal	80000bf4 <acquire>
  np->parent = p;
    80001cf2:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001cf6:	8526                	mv	a0,s1
    80001cf8:	f95fe0ef          	jal	80000c8c <release>
  acquire(&np->lock);
    80001cfc:	8552                	mv	a0,s4
    80001cfe:	ef7fe0ef          	jal	80000bf4 <acquire>
  np->state = RUNNABLE;
    80001d02:	478d                	li	a5,3
    80001d04:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001d08:	8552                	mv	a0,s4
    80001d0a:	f83fe0ef          	jal	80000c8c <release>
  return pid;
    80001d0e:	74a2                	ld	s1,40(sp)
    80001d10:	69e2                	ld	s3,24(sp)
    80001d12:	6a42                	ld	s4,16(sp)
}
    80001d14:	854a                	mv	a0,s2
    80001d16:	70e2                	ld	ra,56(sp)
    80001d18:	7442                	ld	s0,48(sp)
    80001d1a:	7902                	ld	s2,32(sp)
    80001d1c:	6aa2                	ld	s5,8(sp)
    80001d1e:	6121                	add	sp,sp,64
    80001d20:	8082                	ret
    return -1;
    80001d22:	597d                	li	s2,-1
    80001d24:	bfc5                	j	80001d14 <fork+0xfc>

0000000080001d26 <scheduler>:
{
    80001d26:	715d                	add	sp,sp,-80
    80001d28:	e486                	sd	ra,72(sp)
    80001d2a:	e0a2                	sd	s0,64(sp)
    80001d2c:	fc26                	sd	s1,56(sp)
    80001d2e:	f84a                	sd	s2,48(sp)
    80001d30:	f44e                	sd	s3,40(sp)
    80001d32:	f052                	sd	s4,32(sp)
    80001d34:	ec56                	sd	s5,24(sp)
    80001d36:	e85a                	sd	s6,16(sp)
    80001d38:	e45e                	sd	s7,8(sp)
    80001d3a:	e062                	sd	s8,0(sp)
    80001d3c:	0880                	add	s0,sp,80
    80001d3e:	8792                	mv	a5,tp
  int id = r_tp();
    80001d40:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d42:	00779b13          	sll	s6,a5,0x7
    80001d46:	0000e717          	auipc	a4,0xe
    80001d4a:	cea70713          	add	a4,a4,-790 # 8000fa30 <pid_lock>
    80001d4e:	975a                	add	a4,a4,s6
    80001d50:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001d54:	0000e717          	auipc	a4,0xe
    80001d58:	d1470713          	add	a4,a4,-748 # 8000fa68 <cpus+0x8>
    80001d5c:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001d5e:	4c11                	li	s8,4
        c->proc = p;
    80001d60:	079e                	sll	a5,a5,0x7
    80001d62:	0000ea17          	auipc	s4,0xe
    80001d66:	ccea0a13          	add	s4,s4,-818 # 8000fa30 <pid_lock>
    80001d6a:	9a3e                	add	s4,s4,a5
        found = 1;
    80001d6c:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d6e:	00014997          	auipc	s3,0x14
    80001d72:	af298993          	add	s3,s3,-1294 # 80015860 <tickslock>
    80001d76:	a0a9                	j	80001dc0 <scheduler+0x9a>
      release(&p->lock);
    80001d78:	8526                	mv	a0,s1
    80001d7a:	f13fe0ef          	jal	80000c8c <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d7e:	16848493          	add	s1,s1,360
    80001d82:	03348563          	beq	s1,s3,80001dac <scheduler+0x86>
      acquire(&p->lock);
    80001d86:	8526                	mv	a0,s1
    80001d88:	e6dfe0ef          	jal	80000bf4 <acquire>
      if(p->state == RUNNABLE) {
    80001d8c:	4c9c                	lw	a5,24(s1)
    80001d8e:	ff2795e3          	bne	a5,s2,80001d78 <scheduler+0x52>
        p->state = RUNNING;
    80001d92:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001d96:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001d9a:	06048593          	add	a1,s1,96
    80001d9e:	855a                	mv	a0,s6
    80001da0:	5b4000ef          	jal	80002354 <swtch>
        c->proc = 0;
    80001da4:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001da8:	8ade                	mv	s5,s7
    80001daa:	b7f9                	j	80001d78 <scheduler+0x52>
    if(found == 0) {
    80001dac:	000a9a63          	bnez	s5,80001dc0 <scheduler+0x9a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001db0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001db4:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001db8:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001dbc:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dc0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001dc4:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001dc8:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001dcc:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001dce:	0000e497          	auipc	s1,0xe
    80001dd2:	09248493          	add	s1,s1,146 # 8000fe60 <proc>
      if(p->state == RUNNABLE) {
    80001dd6:	490d                	li	s2,3
    80001dd8:	b77d                	j	80001d86 <scheduler+0x60>

0000000080001dda <sched>:
{
    80001dda:	7179                	add	sp,sp,-48
    80001ddc:	f406                	sd	ra,40(sp)
    80001dde:	f022                	sd	s0,32(sp)
    80001de0:	ec26                	sd	s1,24(sp)
    80001de2:	e84a                	sd	s2,16(sp)
    80001de4:	e44e                	sd	s3,8(sp)
    80001de6:	1800                	add	s0,sp,48
  struct proc *p = myproc();
    80001de8:	b0bff0ef          	jal	800018f2 <myproc>
    80001dec:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001dee:	d9dfe0ef          	jal	80000b8a <holding>
    80001df2:	c92d                	beqz	a0,80001e64 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001df4:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001df6:	2781                	sext.w	a5,a5
    80001df8:	079e                	sll	a5,a5,0x7
    80001dfa:	0000e717          	auipc	a4,0xe
    80001dfe:	c3670713          	add	a4,a4,-970 # 8000fa30 <pid_lock>
    80001e02:	97ba                	add	a5,a5,a4
    80001e04:	0a87a703          	lw	a4,168(a5)
    80001e08:	4785                	li	a5,1
    80001e0a:	06f71363          	bne	a4,a5,80001e70 <sched+0x96>
  if(p->state == RUNNING)
    80001e0e:	4c98                	lw	a4,24(s1)
    80001e10:	4791                	li	a5,4
    80001e12:	06f70563          	beq	a4,a5,80001e7c <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e16:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e1a:	8b89                	and	a5,a5,2
  if(intr_get())
    80001e1c:	e7b5                	bnez	a5,80001e88 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e1e:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e20:	0000e917          	auipc	s2,0xe
    80001e24:	c1090913          	add	s2,s2,-1008 # 8000fa30 <pid_lock>
    80001e28:	2781                	sext.w	a5,a5
    80001e2a:	079e                	sll	a5,a5,0x7
    80001e2c:	97ca                	add	a5,a5,s2
    80001e2e:	0ac7a983          	lw	s3,172(a5)
    80001e32:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e34:	2781                	sext.w	a5,a5
    80001e36:	079e                	sll	a5,a5,0x7
    80001e38:	0000e597          	auipc	a1,0xe
    80001e3c:	c3058593          	add	a1,a1,-976 # 8000fa68 <cpus+0x8>
    80001e40:	95be                	add	a1,a1,a5
    80001e42:	06048513          	add	a0,s1,96
    80001e46:	50e000ef          	jal	80002354 <swtch>
    80001e4a:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001e4c:	2781                	sext.w	a5,a5
    80001e4e:	079e                	sll	a5,a5,0x7
    80001e50:	993e                	add	s2,s2,a5
    80001e52:	0b392623          	sw	s3,172(s2)
}
    80001e56:	70a2                	ld	ra,40(sp)
    80001e58:	7402                	ld	s0,32(sp)
    80001e5a:	64e2                	ld	s1,24(sp)
    80001e5c:	6942                	ld	s2,16(sp)
    80001e5e:	69a2                	ld	s3,8(sp)
    80001e60:	6145                	add	sp,sp,48
    80001e62:	8082                	ret
    panic("sched p->lock");
    80001e64:	00005517          	auipc	a0,0x5
    80001e68:	3d450513          	add	a0,a0,980 # 80007238 <etext+0x238>
    80001e6c:	929fe0ef          	jal	80000794 <panic>
    panic("sched locks");
    80001e70:	00005517          	auipc	a0,0x5
    80001e74:	3d850513          	add	a0,a0,984 # 80007248 <etext+0x248>
    80001e78:	91dfe0ef          	jal	80000794 <panic>
    panic("sched running");
    80001e7c:	00005517          	auipc	a0,0x5
    80001e80:	3dc50513          	add	a0,a0,988 # 80007258 <etext+0x258>
    80001e84:	911fe0ef          	jal	80000794 <panic>
    panic("sched interruptible");
    80001e88:	00005517          	auipc	a0,0x5
    80001e8c:	3e050513          	add	a0,a0,992 # 80007268 <etext+0x268>
    80001e90:	905fe0ef          	jal	80000794 <panic>

0000000080001e94 <yield>:
{
    80001e94:	1101                	add	sp,sp,-32
    80001e96:	ec06                	sd	ra,24(sp)
    80001e98:	e822                	sd	s0,16(sp)
    80001e9a:	e426                	sd	s1,8(sp)
    80001e9c:	1000                	add	s0,sp,32
  struct proc *p = myproc();
    80001e9e:	a55ff0ef          	jal	800018f2 <myproc>
    80001ea2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001ea4:	d51fe0ef          	jal	80000bf4 <acquire>
  p->state = RUNNABLE;
    80001ea8:	478d                	li	a5,3
    80001eaa:	cc9c                	sw	a5,24(s1)
  sched();
    80001eac:	f2fff0ef          	jal	80001dda <sched>
  release(&p->lock);
    80001eb0:	8526                	mv	a0,s1
    80001eb2:	ddbfe0ef          	jal	80000c8c <release>
}
    80001eb6:	60e2                	ld	ra,24(sp)
    80001eb8:	6442                	ld	s0,16(sp)
    80001eba:	64a2                	ld	s1,8(sp)
    80001ebc:	6105                	add	sp,sp,32
    80001ebe:	8082                	ret

0000000080001ec0 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001ec0:	7179                	add	sp,sp,-48
    80001ec2:	f406                	sd	ra,40(sp)
    80001ec4:	f022                	sd	s0,32(sp)
    80001ec6:	ec26                	sd	s1,24(sp)
    80001ec8:	e84a                	sd	s2,16(sp)
    80001eca:	e44e                	sd	s3,8(sp)
    80001ecc:	1800                	add	s0,sp,48
    80001ece:	89aa                	mv	s3,a0
    80001ed0:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001ed2:	a21ff0ef          	jal	800018f2 <myproc>
    80001ed6:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001ed8:	d1dfe0ef          	jal	80000bf4 <acquire>
  release(lk);
    80001edc:	854a                	mv	a0,s2
    80001ede:	daffe0ef          	jal	80000c8c <release>

  // Go to sleep.
  p->chan = chan;
    80001ee2:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001ee6:	4789                	li	a5,2
    80001ee8:	cc9c                	sw	a5,24(s1)

  sched();
    80001eea:	ef1ff0ef          	jal	80001dda <sched>

  // Tidy up.
  p->chan = 0;
    80001eee:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001ef2:	8526                	mv	a0,s1
    80001ef4:	d99fe0ef          	jal	80000c8c <release>
  acquire(lk);
    80001ef8:	854a                	mv	a0,s2
    80001efa:	cfbfe0ef          	jal	80000bf4 <acquire>
}
    80001efe:	70a2                	ld	ra,40(sp)
    80001f00:	7402                	ld	s0,32(sp)
    80001f02:	64e2                	ld	s1,24(sp)
    80001f04:	6942                	ld	s2,16(sp)
    80001f06:	69a2                	ld	s3,8(sp)
    80001f08:	6145                	add	sp,sp,48
    80001f0a:	8082                	ret

0000000080001f0c <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80001f0c:	7139                	add	sp,sp,-64
    80001f0e:	fc06                	sd	ra,56(sp)
    80001f10:	f822                	sd	s0,48(sp)
    80001f12:	f426                	sd	s1,40(sp)
    80001f14:	f04a                	sd	s2,32(sp)
    80001f16:	ec4e                	sd	s3,24(sp)
    80001f18:	e852                	sd	s4,16(sp)
    80001f1a:	e456                	sd	s5,8(sp)
    80001f1c:	0080                	add	s0,sp,64
    80001f1e:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001f20:	0000e497          	auipc	s1,0xe
    80001f24:	f4048493          	add	s1,s1,-192 # 8000fe60 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001f28:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f2a:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f2c:	00014917          	auipc	s2,0x14
    80001f30:	93490913          	add	s2,s2,-1740 # 80015860 <tickslock>
    80001f34:	a801                	j	80001f44 <wakeup+0x38>
      }
      release(&p->lock);
    80001f36:	8526                	mv	a0,s1
    80001f38:	d55fe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f3c:	16848493          	add	s1,s1,360
    80001f40:	03248263          	beq	s1,s2,80001f64 <wakeup+0x58>
    if(p != myproc()){
    80001f44:	9afff0ef          	jal	800018f2 <myproc>
    80001f48:	fea48ae3          	beq	s1,a0,80001f3c <wakeup+0x30>
      acquire(&p->lock);
    80001f4c:	8526                	mv	a0,s1
    80001f4e:	ca7fe0ef          	jal	80000bf4 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001f52:	4c9c                	lw	a5,24(s1)
    80001f54:	ff3791e3          	bne	a5,s3,80001f36 <wakeup+0x2a>
    80001f58:	709c                	ld	a5,32(s1)
    80001f5a:	fd479ee3          	bne	a5,s4,80001f36 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001f5e:	0154ac23          	sw	s5,24(s1)
    80001f62:	bfd1                	j	80001f36 <wakeup+0x2a>
    }
  }
}
    80001f64:	70e2                	ld	ra,56(sp)
    80001f66:	7442                	ld	s0,48(sp)
    80001f68:	74a2                	ld	s1,40(sp)
    80001f6a:	7902                	ld	s2,32(sp)
    80001f6c:	69e2                	ld	s3,24(sp)
    80001f6e:	6a42                	ld	s4,16(sp)
    80001f70:	6aa2                	ld	s5,8(sp)
    80001f72:	6121                	add	sp,sp,64
    80001f74:	8082                	ret

0000000080001f76 <reparent>:
{
    80001f76:	7179                	add	sp,sp,-48
    80001f78:	f406                	sd	ra,40(sp)
    80001f7a:	f022                	sd	s0,32(sp)
    80001f7c:	ec26                	sd	s1,24(sp)
    80001f7e:	e84a                	sd	s2,16(sp)
    80001f80:	e44e                	sd	s3,8(sp)
    80001f82:	e052                	sd	s4,0(sp)
    80001f84:	1800                	add	s0,sp,48
    80001f86:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f88:	0000e497          	auipc	s1,0xe
    80001f8c:	ed848493          	add	s1,s1,-296 # 8000fe60 <proc>
      pp->parent = initproc;
    80001f90:	00006a17          	auipc	s4,0x6
    80001f94:	968a0a13          	add	s4,s4,-1688 # 800078f8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f98:	00014997          	auipc	s3,0x14
    80001f9c:	8c898993          	add	s3,s3,-1848 # 80015860 <tickslock>
    80001fa0:	a029                	j	80001faa <reparent+0x34>
    80001fa2:	16848493          	add	s1,s1,360
    80001fa6:	01348b63          	beq	s1,s3,80001fbc <reparent+0x46>
    if(pp->parent == p){
    80001faa:	7c9c                	ld	a5,56(s1)
    80001fac:	ff279be3          	bne	a5,s2,80001fa2 <reparent+0x2c>
      pp->parent = initproc;
    80001fb0:	000a3503          	ld	a0,0(s4)
    80001fb4:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001fb6:	f57ff0ef          	jal	80001f0c <wakeup>
    80001fba:	b7e5                	j	80001fa2 <reparent+0x2c>
}
    80001fbc:	70a2                	ld	ra,40(sp)
    80001fbe:	7402                	ld	s0,32(sp)
    80001fc0:	64e2                	ld	s1,24(sp)
    80001fc2:	6942                	ld	s2,16(sp)
    80001fc4:	69a2                	ld	s3,8(sp)
    80001fc6:	6a02                	ld	s4,0(sp)
    80001fc8:	6145                	add	sp,sp,48
    80001fca:	8082                	ret

0000000080001fcc <exit>:
{
    80001fcc:	7179                	add	sp,sp,-48
    80001fce:	f406                	sd	ra,40(sp)
    80001fd0:	f022                	sd	s0,32(sp)
    80001fd2:	ec26                	sd	s1,24(sp)
    80001fd4:	e84a                	sd	s2,16(sp)
    80001fd6:	e44e                	sd	s3,8(sp)
    80001fd8:	e052                	sd	s4,0(sp)
    80001fda:	1800                	add	s0,sp,48
    80001fdc:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001fde:	915ff0ef          	jal	800018f2 <myproc>
    80001fe2:	89aa                	mv	s3,a0
  if(p == initproc)
    80001fe4:	00006797          	auipc	a5,0x6
    80001fe8:	9147b783          	ld	a5,-1772(a5) # 800078f8 <initproc>
    80001fec:	0d050493          	add	s1,a0,208
    80001ff0:	15050913          	add	s2,a0,336
    80001ff4:	00a79f63          	bne	a5,a0,80002012 <exit+0x46>
    panic("init exiting");
    80001ff8:	00005517          	auipc	a0,0x5
    80001ffc:	28850513          	add	a0,a0,648 # 80007280 <etext+0x280>
    80002000:	f94fe0ef          	jal	80000794 <panic>
      fileclose(f);
    80002004:	67f010ef          	jal	80003e82 <fileclose>
      p->ofile[fd] = 0;
    80002008:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000200c:	04a1                	add	s1,s1,8
    8000200e:	01248563          	beq	s1,s2,80002018 <exit+0x4c>
    if(p->ofile[fd]){
    80002012:	6088                	ld	a0,0(s1)
    80002014:	f965                	bnez	a0,80002004 <exit+0x38>
    80002016:	bfdd                	j	8000200c <exit+0x40>
  begin_op();
    80002018:	251010ef          	jal	80003a68 <begin_op>
  iput(p->cwd);
    8000201c:	1509b503          	ld	a0,336(s3)
    80002020:	334010ef          	jal	80003354 <iput>
  end_op();
    80002024:	2af010ef          	jal	80003ad2 <end_op>
  p->cwd = 0;
    80002028:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000202c:	0000e497          	auipc	s1,0xe
    80002030:	a1c48493          	add	s1,s1,-1508 # 8000fa48 <wait_lock>
    80002034:	8526                	mv	a0,s1
    80002036:	bbffe0ef          	jal	80000bf4 <acquire>
  reparent(p);
    8000203a:	854e                	mv	a0,s3
    8000203c:	f3bff0ef          	jal	80001f76 <reparent>
  wakeup(p->parent);
    80002040:	0389b503          	ld	a0,56(s3)
    80002044:	ec9ff0ef          	jal	80001f0c <wakeup>
  acquire(&p->lock);
    80002048:	854e                	mv	a0,s3
    8000204a:	babfe0ef          	jal	80000bf4 <acquire>
  p->xstate = status;
    8000204e:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002052:	4795                	li	a5,5
    80002054:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002058:	8526                	mv	a0,s1
    8000205a:	c33fe0ef          	jal	80000c8c <release>
  sched();
    8000205e:	d7dff0ef          	jal	80001dda <sched>
  panic("zombie exit");
    80002062:	00005517          	auipc	a0,0x5
    80002066:	22e50513          	add	a0,a0,558 # 80007290 <etext+0x290>
    8000206a:	f2afe0ef          	jal	80000794 <panic>

000000008000206e <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000206e:	7179                	add	sp,sp,-48
    80002070:	f406                	sd	ra,40(sp)
    80002072:	f022                	sd	s0,32(sp)
    80002074:	ec26                	sd	s1,24(sp)
    80002076:	e84a                	sd	s2,16(sp)
    80002078:	e44e                	sd	s3,8(sp)
    8000207a:	1800                	add	s0,sp,48
    8000207c:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000207e:	0000e497          	auipc	s1,0xe
    80002082:	de248493          	add	s1,s1,-542 # 8000fe60 <proc>
    80002086:	00013997          	auipc	s3,0x13
    8000208a:	7da98993          	add	s3,s3,2010 # 80015860 <tickslock>
    acquire(&p->lock);
    8000208e:	8526                	mv	a0,s1
    80002090:	b65fe0ef          	jal	80000bf4 <acquire>
    if(p->pid == pid){
    80002094:	589c                	lw	a5,48(s1)
    80002096:	01278b63          	beq	a5,s2,800020ac <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000209a:	8526                	mv	a0,s1
    8000209c:	bf1fe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800020a0:	16848493          	add	s1,s1,360
    800020a4:	ff3495e3          	bne	s1,s3,8000208e <kill+0x20>
  }
  return -1;
    800020a8:	557d                	li	a0,-1
    800020aa:	a819                	j	800020c0 <kill+0x52>
      p->killed = 1;
    800020ac:	4785                	li	a5,1
    800020ae:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800020b0:	4c98                	lw	a4,24(s1)
    800020b2:	4789                	li	a5,2
    800020b4:	00f70d63          	beq	a4,a5,800020ce <kill+0x60>
      release(&p->lock);
    800020b8:	8526                	mv	a0,s1
    800020ba:	bd3fe0ef          	jal	80000c8c <release>
      return 0;
    800020be:	4501                	li	a0,0
}
    800020c0:	70a2                	ld	ra,40(sp)
    800020c2:	7402                	ld	s0,32(sp)
    800020c4:	64e2                	ld	s1,24(sp)
    800020c6:	6942                	ld	s2,16(sp)
    800020c8:	69a2                	ld	s3,8(sp)
    800020ca:	6145                	add	sp,sp,48
    800020cc:	8082                	ret
        p->state = RUNNABLE;
    800020ce:	478d                	li	a5,3
    800020d0:	cc9c                	sw	a5,24(s1)
    800020d2:	b7dd                	j	800020b8 <kill+0x4a>

00000000800020d4 <setkilled>:

void
setkilled(struct proc *p)
{
    800020d4:	1101                	add	sp,sp,-32
    800020d6:	ec06                	sd	ra,24(sp)
    800020d8:	e822                	sd	s0,16(sp)
    800020da:	e426                	sd	s1,8(sp)
    800020dc:	1000                	add	s0,sp,32
    800020de:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020e0:	b15fe0ef          	jal	80000bf4 <acquire>
  p->killed = 1;
    800020e4:	4785                	li	a5,1
    800020e6:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800020e8:	8526                	mv	a0,s1
    800020ea:	ba3fe0ef          	jal	80000c8c <release>
}
    800020ee:	60e2                	ld	ra,24(sp)
    800020f0:	6442                	ld	s0,16(sp)
    800020f2:	64a2                	ld	s1,8(sp)
    800020f4:	6105                	add	sp,sp,32
    800020f6:	8082                	ret

00000000800020f8 <killed>:

int
killed(struct proc *p)
{
    800020f8:	1101                	add	sp,sp,-32
    800020fa:	ec06                	sd	ra,24(sp)
    800020fc:	e822                	sd	s0,16(sp)
    800020fe:	e426                	sd	s1,8(sp)
    80002100:	e04a                	sd	s2,0(sp)
    80002102:	1000                	add	s0,sp,32
    80002104:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002106:	aeffe0ef          	jal	80000bf4 <acquire>
  k = p->killed;
    8000210a:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000210e:	8526                	mv	a0,s1
    80002110:	b7dfe0ef          	jal	80000c8c <release>
  return k;
}
    80002114:	854a                	mv	a0,s2
    80002116:	60e2                	ld	ra,24(sp)
    80002118:	6442                	ld	s0,16(sp)
    8000211a:	64a2                	ld	s1,8(sp)
    8000211c:	6902                	ld	s2,0(sp)
    8000211e:	6105                	add	sp,sp,32
    80002120:	8082                	ret

0000000080002122 <wait>:
{
    80002122:	715d                	add	sp,sp,-80
    80002124:	e486                	sd	ra,72(sp)
    80002126:	e0a2                	sd	s0,64(sp)
    80002128:	fc26                	sd	s1,56(sp)
    8000212a:	f84a                	sd	s2,48(sp)
    8000212c:	f44e                	sd	s3,40(sp)
    8000212e:	f052                	sd	s4,32(sp)
    80002130:	ec56                	sd	s5,24(sp)
    80002132:	e85a                	sd	s6,16(sp)
    80002134:	e45e                	sd	s7,8(sp)
    80002136:	e062                	sd	s8,0(sp)
    80002138:	0880                	add	s0,sp,80
    8000213a:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000213c:	fb6ff0ef          	jal	800018f2 <myproc>
    80002140:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002142:	0000e517          	auipc	a0,0xe
    80002146:	90650513          	add	a0,a0,-1786 # 8000fa48 <wait_lock>
    8000214a:	aabfe0ef          	jal	80000bf4 <acquire>
    havekids = 0;
    8000214e:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002150:	4a15                	li	s4,5
        havekids = 1;
    80002152:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002154:	00013997          	auipc	s3,0x13
    80002158:	70c98993          	add	s3,s3,1804 # 80015860 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000215c:	0000ec17          	auipc	s8,0xe
    80002160:	8ecc0c13          	add	s8,s8,-1812 # 8000fa48 <wait_lock>
    80002164:	a871                	j	80002200 <wait+0xde>
          pid = pp->pid;
    80002166:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000216a:	000b0c63          	beqz	s6,80002182 <wait+0x60>
    8000216e:	4691                	li	a3,4
    80002170:	02c48613          	add	a2,s1,44
    80002174:	85da                	mv	a1,s6
    80002176:	05093503          	ld	a0,80(s2)
    8000217a:	beaff0ef          	jal	80001564 <copyout>
    8000217e:	02054b63          	bltz	a0,800021b4 <wait+0x92>
          freeproc(pp);
    80002182:	8526                	mv	a0,s1
    80002184:	8e1ff0ef          	jal	80001a64 <freeproc>
          release(&pp->lock);
    80002188:	8526                	mv	a0,s1
    8000218a:	b03fe0ef          	jal	80000c8c <release>
          release(&wait_lock);
    8000218e:	0000e517          	auipc	a0,0xe
    80002192:	8ba50513          	add	a0,a0,-1862 # 8000fa48 <wait_lock>
    80002196:	af7fe0ef          	jal	80000c8c <release>
}
    8000219a:	854e                	mv	a0,s3
    8000219c:	60a6                	ld	ra,72(sp)
    8000219e:	6406                	ld	s0,64(sp)
    800021a0:	74e2                	ld	s1,56(sp)
    800021a2:	7942                	ld	s2,48(sp)
    800021a4:	79a2                	ld	s3,40(sp)
    800021a6:	7a02                	ld	s4,32(sp)
    800021a8:	6ae2                	ld	s5,24(sp)
    800021aa:	6b42                	ld	s6,16(sp)
    800021ac:	6ba2                	ld	s7,8(sp)
    800021ae:	6c02                	ld	s8,0(sp)
    800021b0:	6161                	add	sp,sp,80
    800021b2:	8082                	ret
            release(&pp->lock);
    800021b4:	8526                	mv	a0,s1
    800021b6:	ad7fe0ef          	jal	80000c8c <release>
            release(&wait_lock);
    800021ba:	0000e517          	auipc	a0,0xe
    800021be:	88e50513          	add	a0,a0,-1906 # 8000fa48 <wait_lock>
    800021c2:	acbfe0ef          	jal	80000c8c <release>
            return -1;
    800021c6:	59fd                	li	s3,-1
    800021c8:	bfc9                	j	8000219a <wait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021ca:	16848493          	add	s1,s1,360
    800021ce:	03348063          	beq	s1,s3,800021ee <wait+0xcc>
      if(pp->parent == p){
    800021d2:	7c9c                	ld	a5,56(s1)
    800021d4:	ff279be3          	bne	a5,s2,800021ca <wait+0xa8>
        acquire(&pp->lock);
    800021d8:	8526                	mv	a0,s1
    800021da:	a1bfe0ef          	jal	80000bf4 <acquire>
        if(pp->state == ZOMBIE){
    800021de:	4c9c                	lw	a5,24(s1)
    800021e0:	f94783e3          	beq	a5,s4,80002166 <wait+0x44>
        release(&pp->lock);
    800021e4:	8526                	mv	a0,s1
    800021e6:	aa7fe0ef          	jal	80000c8c <release>
        havekids = 1;
    800021ea:	8756                	mv	a4,s5
    800021ec:	bff9                	j	800021ca <wait+0xa8>
    if(!havekids || killed(p)){
    800021ee:	cf19                	beqz	a4,8000220c <wait+0xea>
    800021f0:	854a                	mv	a0,s2
    800021f2:	f07ff0ef          	jal	800020f8 <killed>
    800021f6:	e919                	bnez	a0,8000220c <wait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800021f8:	85e2                	mv	a1,s8
    800021fa:	854a                	mv	a0,s2
    800021fc:	cc5ff0ef          	jal	80001ec0 <sleep>
    havekids = 0;
    80002200:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002202:	0000e497          	auipc	s1,0xe
    80002206:	c5e48493          	add	s1,s1,-930 # 8000fe60 <proc>
    8000220a:	b7e1                	j	800021d2 <wait+0xb0>
      release(&wait_lock);
    8000220c:	0000e517          	auipc	a0,0xe
    80002210:	83c50513          	add	a0,a0,-1988 # 8000fa48 <wait_lock>
    80002214:	a79fe0ef          	jal	80000c8c <release>
      return -1;
    80002218:	59fd                	li	s3,-1
    8000221a:	b741                	j	8000219a <wait+0x78>

000000008000221c <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000221c:	7179                	add	sp,sp,-48
    8000221e:	f406                	sd	ra,40(sp)
    80002220:	f022                	sd	s0,32(sp)
    80002222:	ec26                	sd	s1,24(sp)
    80002224:	e84a                	sd	s2,16(sp)
    80002226:	e44e                	sd	s3,8(sp)
    80002228:	e052                	sd	s4,0(sp)
    8000222a:	1800                	add	s0,sp,48
    8000222c:	84aa                	mv	s1,a0
    8000222e:	892e                	mv	s2,a1
    80002230:	89b2                	mv	s3,a2
    80002232:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002234:	ebeff0ef          	jal	800018f2 <myproc>
  if(user_dst){
    80002238:	cc99                	beqz	s1,80002256 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    8000223a:	86d2                	mv	a3,s4
    8000223c:	864e                	mv	a2,s3
    8000223e:	85ca                	mv	a1,s2
    80002240:	6928                	ld	a0,80(a0)
    80002242:	b22ff0ef          	jal	80001564 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002246:	70a2                	ld	ra,40(sp)
    80002248:	7402                	ld	s0,32(sp)
    8000224a:	64e2                	ld	s1,24(sp)
    8000224c:	6942                	ld	s2,16(sp)
    8000224e:	69a2                	ld	s3,8(sp)
    80002250:	6a02                	ld	s4,0(sp)
    80002252:	6145                	add	sp,sp,48
    80002254:	8082                	ret
    memmove((char *)dst, src, len);
    80002256:	000a061b          	sext.w	a2,s4
    8000225a:	85ce                	mv	a1,s3
    8000225c:	854a                	mv	a0,s2
    8000225e:	ac7fe0ef          	jal	80000d24 <memmove>
    return 0;
    80002262:	8526                	mv	a0,s1
    80002264:	b7cd                	j	80002246 <either_copyout+0x2a>

0000000080002266 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002266:	7179                	add	sp,sp,-48
    80002268:	f406                	sd	ra,40(sp)
    8000226a:	f022                	sd	s0,32(sp)
    8000226c:	ec26                	sd	s1,24(sp)
    8000226e:	e84a                	sd	s2,16(sp)
    80002270:	e44e                	sd	s3,8(sp)
    80002272:	e052                	sd	s4,0(sp)
    80002274:	1800                	add	s0,sp,48
    80002276:	892a                	mv	s2,a0
    80002278:	84ae                	mv	s1,a1
    8000227a:	89b2                	mv	s3,a2
    8000227c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000227e:	e74ff0ef          	jal	800018f2 <myproc>
  if(user_src){
    80002282:	cc99                	beqz	s1,800022a0 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002284:	86d2                	mv	a3,s4
    80002286:	864e                	mv	a2,s3
    80002288:	85ca                	mv	a1,s2
    8000228a:	6928                	ld	a0,80(a0)
    8000228c:	baeff0ef          	jal	8000163a <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002290:	70a2                	ld	ra,40(sp)
    80002292:	7402                	ld	s0,32(sp)
    80002294:	64e2                	ld	s1,24(sp)
    80002296:	6942                	ld	s2,16(sp)
    80002298:	69a2                	ld	s3,8(sp)
    8000229a:	6a02                	ld	s4,0(sp)
    8000229c:	6145                	add	sp,sp,48
    8000229e:	8082                	ret
    memmove(dst, (char*)src, len);
    800022a0:	000a061b          	sext.w	a2,s4
    800022a4:	85ce                	mv	a1,s3
    800022a6:	854a                	mv	a0,s2
    800022a8:	a7dfe0ef          	jal	80000d24 <memmove>
    return 0;
    800022ac:	8526                	mv	a0,s1
    800022ae:	b7cd                	j	80002290 <either_copyin+0x2a>

00000000800022b0 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800022b0:	715d                	add	sp,sp,-80
    800022b2:	e486                	sd	ra,72(sp)
    800022b4:	e0a2                	sd	s0,64(sp)
    800022b6:	fc26                	sd	s1,56(sp)
    800022b8:	f84a                	sd	s2,48(sp)
    800022ba:	f44e                	sd	s3,40(sp)
    800022bc:	f052                	sd	s4,32(sp)
    800022be:	ec56                	sd	s5,24(sp)
    800022c0:	e85a                	sd	s6,16(sp)
    800022c2:	e45e                	sd	s7,8(sp)
    800022c4:	0880                	add	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800022c6:	00005517          	auipc	a0,0x5
    800022ca:	db250513          	add	a0,a0,-590 # 80007078 <etext+0x78>
    800022ce:	9f4fe0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800022d2:	0000e497          	auipc	s1,0xe
    800022d6:	ce648493          	add	s1,s1,-794 # 8000ffb8 <proc+0x158>
    800022da:	00013917          	auipc	s2,0x13
    800022de:	6de90913          	add	s2,s2,1758 # 800159b8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022e2:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800022e4:	00005997          	auipc	s3,0x5
    800022e8:	fbc98993          	add	s3,s3,-68 # 800072a0 <etext+0x2a0>
    printf("%d %s %s", p->pid, state, p->name);
    800022ec:	00005a97          	auipc	s5,0x5
    800022f0:	fbca8a93          	add	s5,s5,-68 # 800072a8 <etext+0x2a8>
    printf("\n");
    800022f4:	00005a17          	auipc	s4,0x5
    800022f8:	d84a0a13          	add	s4,s4,-636 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022fc:	00005b97          	auipc	s7,0x5
    80002300:	47cb8b93          	add	s7,s7,1148 # 80007778 <states.0>
    80002304:	a829                	j	8000231e <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002306:	ed86a583          	lw	a1,-296(a3)
    8000230a:	8556                	mv	a0,s5
    8000230c:	9b6fe0ef          	jal	800004c2 <printf>
    printf("\n");
    80002310:	8552                	mv	a0,s4
    80002312:	9b0fe0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002316:	16848493          	add	s1,s1,360
    8000231a:	03248263          	beq	s1,s2,8000233e <procdump+0x8e>
    if(p->state == UNUSED)
    8000231e:	86a6                	mv	a3,s1
    80002320:	ec04a783          	lw	a5,-320(s1)
    80002324:	dbed                	beqz	a5,80002316 <procdump+0x66>
      state = "???";
    80002326:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002328:	fcfb6fe3          	bltu	s6,a5,80002306 <procdump+0x56>
    8000232c:	02079713          	sll	a4,a5,0x20
    80002330:	01d75793          	srl	a5,a4,0x1d
    80002334:	97de                	add	a5,a5,s7
    80002336:	6390                	ld	a2,0(a5)
    80002338:	f679                	bnez	a2,80002306 <procdump+0x56>
      state = "???";
    8000233a:	864e                	mv	a2,s3
    8000233c:	b7e9                	j	80002306 <procdump+0x56>
  }
}
    8000233e:	60a6                	ld	ra,72(sp)
    80002340:	6406                	ld	s0,64(sp)
    80002342:	74e2                	ld	s1,56(sp)
    80002344:	7942                	ld	s2,48(sp)
    80002346:	79a2                	ld	s3,40(sp)
    80002348:	7a02                	ld	s4,32(sp)
    8000234a:	6ae2                	ld	s5,24(sp)
    8000234c:	6b42                	ld	s6,16(sp)
    8000234e:	6ba2                	ld	s7,8(sp)
    80002350:	6161                	add	sp,sp,80
    80002352:	8082                	ret

0000000080002354 <swtch>:
    80002354:	00153023          	sd	ra,0(a0)
    80002358:	00253423          	sd	sp,8(a0)
    8000235c:	e900                	sd	s0,16(a0)
    8000235e:	ed04                	sd	s1,24(a0)
    80002360:	03253023          	sd	s2,32(a0)
    80002364:	03353423          	sd	s3,40(a0)
    80002368:	03453823          	sd	s4,48(a0)
    8000236c:	03553c23          	sd	s5,56(a0)
    80002370:	05653023          	sd	s6,64(a0)
    80002374:	05753423          	sd	s7,72(a0)
    80002378:	05853823          	sd	s8,80(a0)
    8000237c:	05953c23          	sd	s9,88(a0)
    80002380:	07a53023          	sd	s10,96(a0)
    80002384:	07b53423          	sd	s11,104(a0)
    80002388:	0005b083          	ld	ra,0(a1)
    8000238c:	0085b103          	ld	sp,8(a1)
    80002390:	6980                	ld	s0,16(a1)
    80002392:	6d84                	ld	s1,24(a1)
    80002394:	0205b903          	ld	s2,32(a1)
    80002398:	0285b983          	ld	s3,40(a1)
    8000239c:	0305ba03          	ld	s4,48(a1)
    800023a0:	0385ba83          	ld	s5,56(a1)
    800023a4:	0405bb03          	ld	s6,64(a1)
    800023a8:	0485bb83          	ld	s7,72(a1)
    800023ac:	0505bc03          	ld	s8,80(a1)
    800023b0:	0585bc83          	ld	s9,88(a1)
    800023b4:	0605bd03          	ld	s10,96(a1)
    800023b8:	0685bd83          	ld	s11,104(a1)
    800023bc:	8082                	ret

00000000800023be <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800023be:	1141                	add	sp,sp,-16
    800023c0:	e406                	sd	ra,8(sp)
    800023c2:	e022                	sd	s0,0(sp)
    800023c4:	0800                	add	s0,sp,16
  initlock(&tickslock, "time");
    800023c6:	00005597          	auipc	a1,0x5
    800023ca:	f2258593          	add	a1,a1,-222 # 800072e8 <etext+0x2e8>
    800023ce:	00013517          	auipc	a0,0x13
    800023d2:	49250513          	add	a0,a0,1170 # 80015860 <tickslock>
    800023d6:	f9efe0ef          	jal	80000b74 <initlock>
}
    800023da:	60a2                	ld	ra,8(sp)
    800023dc:	6402                	ld	s0,0(sp)
    800023de:	0141                	add	sp,sp,16
    800023e0:	8082                	ret

00000000800023e2 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800023e2:	1141                	add	sp,sp,-16
    800023e4:	e422                	sd	s0,8(sp)
    800023e6:	0800                	add	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800023e8:	00003797          	auipc	a5,0x3
    800023ec:	e1878793          	add	a5,a5,-488 # 80005200 <kernelvec>
    800023f0:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800023f4:	6422                	ld	s0,8(sp)
    800023f6:	0141                	add	sp,sp,16
    800023f8:	8082                	ret

00000000800023fa <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800023fa:	1141                	add	sp,sp,-16
    800023fc:	e406                	sd	ra,8(sp)
    800023fe:	e022                	sd	s0,0(sp)
    80002400:	0800                	add	s0,sp,16
  struct proc *p = myproc();
    80002402:	cf0ff0ef          	jal	800018f2 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002406:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000240a:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000240c:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002410:	00004697          	auipc	a3,0x4
    80002414:	bf068693          	add	a3,a3,-1040 # 80006000 <_trampoline>
    80002418:	00004717          	auipc	a4,0x4
    8000241c:	be870713          	add	a4,a4,-1048 # 80006000 <_trampoline>
    80002420:	8f15                	sub	a4,a4,a3
    80002422:	040007b7          	lui	a5,0x4000
    80002426:	17fd                	add	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002428:	07b2                	sll	a5,a5,0xc
    8000242a:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000242c:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002430:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002432:	18002673          	csrr	a2,satp
    80002436:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002438:	6d30                	ld	a2,88(a0)
    8000243a:	6138                	ld	a4,64(a0)
    8000243c:	6585                	lui	a1,0x1
    8000243e:	972e                	add	a4,a4,a1
    80002440:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002442:	6d38                	ld	a4,88(a0)
    80002444:	00000617          	auipc	a2,0x0
    80002448:	12660613          	add	a2,a2,294 # 8000256a <usertrap>
    8000244c:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000244e:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002450:	8612                	mv	a2,tp
    80002452:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002454:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002458:	eff77713          	and	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000245c:	02076713          	or	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002460:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002464:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002466:	6f18                	ld	a4,24(a4)
    80002468:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000246c:	6928                	ld	a0,80(a0)
    8000246e:	8131                	srl	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002470:	00004717          	auipc	a4,0x4
    80002474:	c2c70713          	add	a4,a4,-980 # 8000609c <userret>
    80002478:	8f15                	sub	a4,a4,a3
    8000247a:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    8000247c:	577d                	li	a4,-1
    8000247e:	177e                	sll	a4,a4,0x3f
    80002480:	8d59                	or	a0,a0,a4
    80002482:	9782                	jalr	a5
}
    80002484:	60a2                	ld	ra,8(sp)
    80002486:	6402                	ld	s0,0(sp)
    80002488:	0141                	add	sp,sp,16
    8000248a:	8082                	ret

000000008000248c <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000248c:	1101                	add	sp,sp,-32
    8000248e:	ec06                	sd	ra,24(sp)
    80002490:	e822                	sd	s0,16(sp)
    80002492:	1000                	add	s0,sp,32
  if(cpuid() == 0){
    80002494:	c32ff0ef          	jal	800018c6 <cpuid>
    80002498:	cd11                	beqz	a0,800024b4 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    8000249a:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    8000249e:	000f4737          	lui	a4,0xf4
    800024a2:	24070713          	add	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800024a6:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800024a8:	14d79073          	csrw	stimecmp,a5
}
    800024ac:	60e2                	ld	ra,24(sp)
    800024ae:	6442                	ld	s0,16(sp)
    800024b0:	6105                	add	sp,sp,32
    800024b2:	8082                	ret
    800024b4:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    800024b6:	00013497          	auipc	s1,0x13
    800024ba:	3aa48493          	add	s1,s1,938 # 80015860 <tickslock>
    800024be:	8526                	mv	a0,s1
    800024c0:	f34fe0ef          	jal	80000bf4 <acquire>
    ticks++;
    800024c4:	00005517          	auipc	a0,0x5
    800024c8:	43c50513          	add	a0,a0,1084 # 80007900 <ticks>
    800024cc:	411c                	lw	a5,0(a0)
    800024ce:	2785                	addw	a5,a5,1
    800024d0:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800024d2:	a3bff0ef          	jal	80001f0c <wakeup>
    release(&tickslock);
    800024d6:	8526                	mv	a0,s1
    800024d8:	fb4fe0ef          	jal	80000c8c <release>
    800024dc:	64a2                	ld	s1,8(sp)
    800024de:	bf75                	j	8000249a <clockintr+0xe>

00000000800024e0 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800024e0:	1101                	add	sp,sp,-32
    800024e2:	ec06                	sd	ra,24(sp)
    800024e4:	e822                	sd	s0,16(sp)
    800024e6:	1000                	add	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800024e8:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    800024ec:	57fd                	li	a5,-1
    800024ee:	17fe                	sll	a5,a5,0x3f
    800024f0:	07a5                	add	a5,a5,9
    800024f2:	00f70f63          	beq	a4,a5,80002510 <devintr+0x30>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    800024f6:	57fd                	li	a5,-1
    800024f8:	17fe                	sll	a5,a5,0x3f
    800024fa:	0795                	add	a5,a5,5
    800024fc:	04f70b63          	beq	a4,a5,80002552 <devintr+0x72>
    // timer interrupt.
    clockintr();
    return 2;
  }
  else if( scause == 0x2){
    80002500:	4789                	li	a5,2
    printf("Rebooting the system");
  }
  else
  {
    return 0;
    80002502:	4501                	li	a0,0
  else if( scause == 0x2){
    80002504:	04f70b63          	beq	a4,a5,8000255a <devintr+0x7a>
  }

  return 0;
}
    80002508:	60e2                	ld	ra,24(sp)
    8000250a:	6442                	ld	s0,16(sp)
    8000250c:	6105                	add	sp,sp,32
    8000250e:	8082                	ret
    80002510:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002512:	59b020ef          	jal	800052ac <plic_claim>
    80002516:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002518:	47a9                	li	a5,10
    8000251a:	00f50963          	beq	a0,a5,8000252c <devintr+0x4c>
    } else if(irq == VIRTIO0_IRQ){
    8000251e:	4785                	li	a5,1
    80002520:	00f50963          	beq	a0,a5,80002532 <devintr+0x52>
    return 1;
    80002524:	4505                	li	a0,1
    } else if(irq){
    80002526:	e889                	bnez	s1,80002538 <devintr+0x58>
    80002528:	64a2                	ld	s1,8(sp)
    8000252a:	bff9                	j	80002508 <devintr+0x28>
      uartintr();
    8000252c:	cdafe0ef          	jal	80000a06 <uartintr>
    if(irq)
    80002530:	a819                	j	80002546 <devintr+0x66>
      virtio_disk_intr();
    80002532:	268030ef          	jal	8000579a <virtio_disk_intr>
    if(irq)
    80002536:	a801                	j	80002546 <devintr+0x66>
      printf("unexpected interrupt irq=%d\n", irq);
    80002538:	85a6                	mv	a1,s1
    8000253a:	00005517          	auipc	a0,0x5
    8000253e:	db650513          	add	a0,a0,-586 # 800072f0 <etext+0x2f0>
    80002542:	f81fd0ef          	jal	800004c2 <printf>
      plic_complete(irq);
    80002546:	8526                	mv	a0,s1
    80002548:	585020ef          	jal	800052cc <plic_complete>
    return 1;
    8000254c:	4505                	li	a0,1
    8000254e:	64a2                	ld	s1,8(sp)
    80002550:	bf65                	j	80002508 <devintr+0x28>
    clockintr();
    80002552:	f3bff0ef          	jal	8000248c <clockintr>
    return 2;
    80002556:	4509                	li	a0,2
    80002558:	bf45                	j	80002508 <devintr+0x28>
    printf("Rebooting the system");
    8000255a:	00005517          	auipc	a0,0x5
    8000255e:	db650513          	add	a0,a0,-586 # 80007310 <etext+0x310>
    80002562:	f61fd0ef          	jal	800004c2 <printf>
  return 0;
    80002566:	4501                	li	a0,0
    80002568:	b745                	j	80002508 <devintr+0x28>

000000008000256a <usertrap>:
{
    8000256a:	1101                	add	sp,sp,-32
    8000256c:	ec06                	sd	ra,24(sp)
    8000256e:	e822                	sd	s0,16(sp)
    80002570:	e426                	sd	s1,8(sp)
    80002572:	e04a                	sd	s2,0(sp)
    80002574:	1000                	add	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002576:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000257a:	1007f793          	and	a5,a5,256
    8000257e:	ef85                	bnez	a5,800025b6 <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002580:	00003797          	auipc	a5,0x3
    80002584:	c8078793          	add	a5,a5,-896 # 80005200 <kernelvec>
    80002588:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000258c:	b66ff0ef          	jal	800018f2 <myproc>
    80002590:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002592:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002594:	14102773          	csrr	a4,sepc
    80002598:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000259a:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000259e:	47a1                	li	a5,8
    800025a0:	02f70163          	beq	a4,a5,800025c2 <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    800025a4:	f3dff0ef          	jal	800024e0 <devintr>
    800025a8:	892a                	mv	s2,a0
    800025aa:	c135                	beqz	a0,8000260e <usertrap+0xa4>
  if(killed(p))
    800025ac:	8526                	mv	a0,s1
    800025ae:	b4bff0ef          	jal	800020f8 <killed>
    800025b2:	cd1d                	beqz	a0,800025f0 <usertrap+0x86>
    800025b4:	a81d                	j	800025ea <usertrap+0x80>
    panic("usertrap: not from user mode");
    800025b6:	00005517          	auipc	a0,0x5
    800025ba:	d7250513          	add	a0,a0,-654 # 80007328 <etext+0x328>
    800025be:	9d6fe0ef          	jal	80000794 <panic>
    if(killed(p))
    800025c2:	b37ff0ef          	jal	800020f8 <killed>
    800025c6:	e121                	bnez	a0,80002606 <usertrap+0x9c>
    p->trapframe->epc += 4;
    800025c8:	6cb8                	ld	a4,88(s1)
    800025ca:	6f1c                	ld	a5,24(a4)
    800025cc:	0791                	add	a5,a5,4
    800025ce:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025d0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800025d4:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800025d8:	10079073          	csrw	sstatus,a5
    syscall();
    800025dc:	232000ef          	jal	8000280e <syscall>
  if(killed(p))
    800025e0:	8526                	mv	a0,s1
    800025e2:	b17ff0ef          	jal	800020f8 <killed>
    800025e6:	c901                	beqz	a0,800025f6 <usertrap+0x8c>
    800025e8:	4901                	li	s2,0
    exit(-1);
    800025ea:	557d                	li	a0,-1
    800025ec:	9e1ff0ef          	jal	80001fcc <exit>
  if(which_dev == 2)
    800025f0:	4789                	li	a5,2
    800025f2:	04f90563          	beq	s2,a5,8000263c <usertrap+0xd2>
  usertrapret();
    800025f6:	e05ff0ef          	jal	800023fa <usertrapret>
}
    800025fa:	60e2                	ld	ra,24(sp)
    800025fc:	6442                	ld	s0,16(sp)
    800025fe:	64a2                	ld	s1,8(sp)
    80002600:	6902                	ld	s2,0(sp)
    80002602:	6105                	add	sp,sp,32
    80002604:	8082                	ret
      exit(-1);
    80002606:	557d                	li	a0,-1
    80002608:	9c5ff0ef          	jal	80001fcc <exit>
    8000260c:	bf75                	j	800025c8 <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000260e:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002612:	5890                	lw	a2,48(s1)
    80002614:	00005517          	auipc	a0,0x5
    80002618:	d3450513          	add	a0,a0,-716 # 80007348 <etext+0x348>
    8000261c:	ea7fd0ef          	jal	800004c2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002620:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002624:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002628:	00005517          	auipc	a0,0x5
    8000262c:	d5050513          	add	a0,a0,-688 # 80007378 <etext+0x378>
    80002630:	e93fd0ef          	jal	800004c2 <printf>
    setkilled(p);
    80002634:	8526                	mv	a0,s1
    80002636:	a9fff0ef          	jal	800020d4 <setkilled>
    8000263a:	b75d                	j	800025e0 <usertrap+0x76>
    yield();
    8000263c:	859ff0ef          	jal	80001e94 <yield>
    80002640:	bf5d                	j	800025f6 <usertrap+0x8c>

0000000080002642 <kerneltrap>:
{
    80002642:	7179                	add	sp,sp,-48
    80002644:	f406                	sd	ra,40(sp)
    80002646:	f022                	sd	s0,32(sp)
    80002648:	ec26                	sd	s1,24(sp)
    8000264a:	e84a                	sd	s2,16(sp)
    8000264c:	e44e                	sd	s3,8(sp)
    8000264e:	1800                	add	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002650:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002654:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002658:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000265c:	1004f793          	and	a5,s1,256
    80002660:	c795                	beqz	a5,8000268c <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002662:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002666:	8b89                	and	a5,a5,2
  if(intr_get() != 0)
    80002668:	eb85                	bnez	a5,80002698 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    8000266a:	e77ff0ef          	jal	800024e0 <devintr>
    8000266e:	ed15                	bnez	a0,800026aa <kerneltrap+0x68>
    if(scause == 0x2){
    80002670:	4789                	li	a5,2
    80002672:	02f98963          	beq	s3,a5,800026a4 <kerneltrap+0x62>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002676:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000267a:	10049073          	csrw	sstatus,s1
}
    8000267e:	70a2                	ld	ra,40(sp)
    80002680:	7402                	ld	s0,32(sp)
    80002682:	64e2                	ld	s1,24(sp)
    80002684:	6942                	ld	s2,16(sp)
    80002686:	69a2                	ld	s3,8(sp)
    80002688:	6145                	add	sp,sp,48
    8000268a:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000268c:	00005517          	auipc	a0,0x5
    80002690:	d1450513          	add	a0,a0,-748 # 800073a0 <etext+0x3a0>
    80002694:	900fe0ef          	jal	80000794 <panic>
    panic("kerneltrap: interrupts enabled");
    80002698:	00005517          	auipc	a0,0x5
    8000269c:	d3050513          	add	a0,a0,-720 # 800073c8 <etext+0x3c8>
    800026a0:	8f4fe0ef          	jal	80000794 <panic>
      sys_off();
    800026a4:	347020ef          	jal	800051ea <sys_off>
    800026a8:	b7f9                	j	80002676 <kerneltrap+0x34>
  if(which_dev == 2 && myproc() != 0)
    800026aa:	4789                	li	a5,2
    800026ac:	fcf515e3          	bne	a0,a5,80002676 <kerneltrap+0x34>
    800026b0:	a42ff0ef          	jal	800018f2 <myproc>
    800026b4:	d169                	beqz	a0,80002676 <kerneltrap+0x34>
    yield();
    800026b6:	fdeff0ef          	jal	80001e94 <yield>
    800026ba:	bf75                	j	80002676 <kerneltrap+0x34>

00000000800026bc <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800026bc:	1101                	add	sp,sp,-32
    800026be:	ec06                	sd	ra,24(sp)
    800026c0:	e822                	sd	s0,16(sp)
    800026c2:	e426                	sd	s1,8(sp)
    800026c4:	1000                	add	s0,sp,32
    800026c6:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800026c8:	a2aff0ef          	jal	800018f2 <myproc>
  switch (n) {
    800026cc:	4795                	li	a5,5
    800026ce:	0497e163          	bltu	a5,s1,80002710 <argraw+0x54>
    800026d2:	048a                	sll	s1,s1,0x2
    800026d4:	00005717          	auipc	a4,0x5
    800026d8:	0d470713          	add	a4,a4,212 # 800077a8 <states.0+0x30>
    800026dc:	94ba                	add	s1,s1,a4
    800026de:	409c                	lw	a5,0(s1)
    800026e0:	97ba                	add	a5,a5,a4
    800026e2:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800026e4:	6d3c                	ld	a5,88(a0)
    800026e6:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800026e8:	60e2                	ld	ra,24(sp)
    800026ea:	6442                	ld	s0,16(sp)
    800026ec:	64a2                	ld	s1,8(sp)
    800026ee:	6105                	add	sp,sp,32
    800026f0:	8082                	ret
    return p->trapframe->a1;
    800026f2:	6d3c                	ld	a5,88(a0)
    800026f4:	7fa8                	ld	a0,120(a5)
    800026f6:	bfcd                	j	800026e8 <argraw+0x2c>
    return p->trapframe->a2;
    800026f8:	6d3c                	ld	a5,88(a0)
    800026fa:	63c8                	ld	a0,128(a5)
    800026fc:	b7f5                	j	800026e8 <argraw+0x2c>
    return p->trapframe->a3;
    800026fe:	6d3c                	ld	a5,88(a0)
    80002700:	67c8                	ld	a0,136(a5)
    80002702:	b7dd                	j	800026e8 <argraw+0x2c>
    return p->trapframe->a4;
    80002704:	6d3c                	ld	a5,88(a0)
    80002706:	6bc8                	ld	a0,144(a5)
    80002708:	b7c5                	j	800026e8 <argraw+0x2c>
    return p->trapframe->a5;
    8000270a:	6d3c                	ld	a5,88(a0)
    8000270c:	6fc8                	ld	a0,152(a5)
    8000270e:	bfe9                	j	800026e8 <argraw+0x2c>
  panic("argraw");
    80002710:	00005517          	auipc	a0,0x5
    80002714:	cd850513          	add	a0,a0,-808 # 800073e8 <etext+0x3e8>
    80002718:	87cfe0ef          	jal	80000794 <panic>

000000008000271c <fetchaddr>:
{
    8000271c:	1101                	add	sp,sp,-32
    8000271e:	ec06                	sd	ra,24(sp)
    80002720:	e822                	sd	s0,16(sp)
    80002722:	e426                	sd	s1,8(sp)
    80002724:	e04a                	sd	s2,0(sp)
    80002726:	1000                	add	s0,sp,32
    80002728:	84aa                	mv	s1,a0
    8000272a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000272c:	9c6ff0ef          	jal	800018f2 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002730:	653c                	ld	a5,72(a0)
    80002732:	02f4f663          	bgeu	s1,a5,8000275e <fetchaddr+0x42>
    80002736:	00848713          	add	a4,s1,8
    8000273a:	02e7e463          	bltu	a5,a4,80002762 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000273e:	46a1                	li	a3,8
    80002740:	8626                	mv	a2,s1
    80002742:	85ca                	mv	a1,s2
    80002744:	6928                	ld	a0,80(a0)
    80002746:	ef5fe0ef          	jal	8000163a <copyin>
    8000274a:	00a03533          	snez	a0,a0
    8000274e:	40a00533          	neg	a0,a0
}
    80002752:	60e2                	ld	ra,24(sp)
    80002754:	6442                	ld	s0,16(sp)
    80002756:	64a2                	ld	s1,8(sp)
    80002758:	6902                	ld	s2,0(sp)
    8000275a:	6105                	add	sp,sp,32
    8000275c:	8082                	ret
    return -1;
    8000275e:	557d                	li	a0,-1
    80002760:	bfcd                	j	80002752 <fetchaddr+0x36>
    80002762:	557d                	li	a0,-1
    80002764:	b7fd                	j	80002752 <fetchaddr+0x36>

0000000080002766 <fetchstr>:
{
    80002766:	7179                	add	sp,sp,-48
    80002768:	f406                	sd	ra,40(sp)
    8000276a:	f022                	sd	s0,32(sp)
    8000276c:	ec26                	sd	s1,24(sp)
    8000276e:	e84a                	sd	s2,16(sp)
    80002770:	e44e                	sd	s3,8(sp)
    80002772:	1800                	add	s0,sp,48
    80002774:	892a                	mv	s2,a0
    80002776:	84ae                	mv	s1,a1
    80002778:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    8000277a:	978ff0ef          	jal	800018f2 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    8000277e:	86ce                	mv	a3,s3
    80002780:	864a                	mv	a2,s2
    80002782:	85a6                	mv	a1,s1
    80002784:	6928                	ld	a0,80(a0)
    80002786:	f3bfe0ef          	jal	800016c0 <copyinstr>
    8000278a:	00054c63          	bltz	a0,800027a2 <fetchstr+0x3c>
  return strlen(buf);
    8000278e:	8526                	mv	a0,s1
    80002790:	ea8fe0ef          	jal	80000e38 <strlen>
}
    80002794:	70a2                	ld	ra,40(sp)
    80002796:	7402                	ld	s0,32(sp)
    80002798:	64e2                	ld	s1,24(sp)
    8000279a:	6942                	ld	s2,16(sp)
    8000279c:	69a2                	ld	s3,8(sp)
    8000279e:	6145                	add	sp,sp,48
    800027a0:	8082                	ret
    return -1;
    800027a2:	557d                	li	a0,-1
    800027a4:	bfc5                	j	80002794 <fetchstr+0x2e>

00000000800027a6 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800027a6:	1101                	add	sp,sp,-32
    800027a8:	ec06                	sd	ra,24(sp)
    800027aa:	e822                	sd	s0,16(sp)
    800027ac:	e426                	sd	s1,8(sp)
    800027ae:	1000                	add	s0,sp,32
    800027b0:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800027b2:	f0bff0ef          	jal	800026bc <argraw>
    800027b6:	c088                	sw	a0,0(s1)
}
    800027b8:	60e2                	ld	ra,24(sp)
    800027ba:	6442                	ld	s0,16(sp)
    800027bc:	64a2                	ld	s1,8(sp)
    800027be:	6105                	add	sp,sp,32
    800027c0:	8082                	ret

00000000800027c2 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800027c2:	1101                	add	sp,sp,-32
    800027c4:	ec06                	sd	ra,24(sp)
    800027c6:	e822                	sd	s0,16(sp)
    800027c8:	e426                	sd	s1,8(sp)
    800027ca:	1000                	add	s0,sp,32
    800027cc:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800027ce:	eefff0ef          	jal	800026bc <argraw>
    800027d2:	e088                	sd	a0,0(s1)
}
    800027d4:	60e2                	ld	ra,24(sp)
    800027d6:	6442                	ld	s0,16(sp)
    800027d8:	64a2                	ld	s1,8(sp)
    800027da:	6105                	add	sp,sp,32
    800027dc:	8082                	ret

00000000800027de <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800027de:	7179                	add	sp,sp,-48
    800027e0:	f406                	sd	ra,40(sp)
    800027e2:	f022                	sd	s0,32(sp)
    800027e4:	ec26                	sd	s1,24(sp)
    800027e6:	e84a                	sd	s2,16(sp)
    800027e8:	1800                	add	s0,sp,48
    800027ea:	84ae                	mv	s1,a1
    800027ec:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    800027ee:	fd840593          	add	a1,s0,-40
    800027f2:	fd1ff0ef          	jal	800027c2 <argaddr>
  return fetchstr(addr, buf, max);
    800027f6:	864a                	mv	a2,s2
    800027f8:	85a6                	mv	a1,s1
    800027fa:	fd843503          	ld	a0,-40(s0)
    800027fe:	f69ff0ef          	jal	80002766 <fetchstr>
}
    80002802:	70a2                	ld	ra,40(sp)
    80002804:	7402                	ld	s0,32(sp)
    80002806:	64e2                	ld	s1,24(sp)
    80002808:	6942                	ld	s2,16(sp)
    8000280a:	6145                	add	sp,sp,48
    8000280c:	8082                	ret

000000008000280e <syscall>:
[SYS_off]     sys_off,
};

void
syscall(void)
{
    8000280e:	1101                	add	sp,sp,-32
    80002810:	ec06                	sd	ra,24(sp)
    80002812:	e822                	sd	s0,16(sp)
    80002814:	e426                	sd	s1,8(sp)
    80002816:	e04a                	sd	s2,0(sp)
    80002818:	1000                	add	s0,sp,32
  int num;
  struct proc *p = myproc();
    8000281a:	8d8ff0ef          	jal	800018f2 <myproc>
    8000281e:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002820:	05853903          	ld	s2,88(a0)
    80002824:	0a893783          	ld	a5,168(s2)
    80002828:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000282c:	37fd                	addw	a5,a5,-1
    8000282e:	4755                	li	a4,21
    80002830:	00f76f63          	bltu	a4,a5,8000284e <syscall+0x40>
    80002834:	00369713          	sll	a4,a3,0x3
    80002838:	00005797          	auipc	a5,0x5
    8000283c:	f8878793          	add	a5,a5,-120 # 800077c0 <syscalls>
    80002840:	97ba                	add	a5,a5,a4
    80002842:	639c                	ld	a5,0(a5)
    80002844:	c789                	beqz	a5,8000284e <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002846:	9782                	jalr	a5
    80002848:	06a93823          	sd	a0,112(s2)
    8000284c:	a829                	j	80002866 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    8000284e:	15848613          	add	a2,s1,344
    80002852:	588c                	lw	a1,48(s1)
    80002854:	00005517          	auipc	a0,0x5
    80002858:	b9c50513          	add	a0,a0,-1124 # 800073f0 <etext+0x3f0>
    8000285c:	c67fd0ef          	jal	800004c2 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002860:	6cbc                	ld	a5,88(s1)
    80002862:	577d                	li	a4,-1
    80002864:	fbb8                	sd	a4,112(a5)
  }
}
    80002866:	60e2                	ld	ra,24(sp)
    80002868:	6442                	ld	s0,16(sp)
    8000286a:	64a2                	ld	s1,8(sp)
    8000286c:	6902                	ld	s2,0(sp)
    8000286e:	6105                	add	sp,sp,32
    80002870:	8082                	ret

0000000080002872 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002872:	1101                	add	sp,sp,-32
    80002874:	ec06                	sd	ra,24(sp)
    80002876:	e822                	sd	s0,16(sp)
    80002878:	1000                	add	s0,sp,32
  int n;
  argint(0, &n);
    8000287a:	fec40593          	add	a1,s0,-20
    8000287e:	4501                	li	a0,0
    80002880:	f27ff0ef          	jal	800027a6 <argint>
  exit(n);
    80002884:	fec42503          	lw	a0,-20(s0)
    80002888:	f44ff0ef          	jal	80001fcc <exit>
  return 0;  // not reached
}
    8000288c:	4501                	li	a0,0
    8000288e:	60e2                	ld	ra,24(sp)
    80002890:	6442                	ld	s0,16(sp)
    80002892:	6105                	add	sp,sp,32
    80002894:	8082                	ret

0000000080002896 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002896:	1141                	add	sp,sp,-16
    80002898:	e406                	sd	ra,8(sp)
    8000289a:	e022                	sd	s0,0(sp)
    8000289c:	0800                	add	s0,sp,16
  return myproc()->pid;
    8000289e:	854ff0ef          	jal	800018f2 <myproc>
}
    800028a2:	5908                	lw	a0,48(a0)
    800028a4:	60a2                	ld	ra,8(sp)
    800028a6:	6402                	ld	s0,0(sp)
    800028a8:	0141                	add	sp,sp,16
    800028aa:	8082                	ret

00000000800028ac <sys_fork>:

uint64
sys_fork(void)
{
    800028ac:	1141                	add	sp,sp,-16
    800028ae:	e406                	sd	ra,8(sp)
    800028b0:	e022                	sd	s0,0(sp)
    800028b2:	0800                	add	s0,sp,16
  return fork();
    800028b4:	b64ff0ef          	jal	80001c18 <fork>
}
    800028b8:	60a2                	ld	ra,8(sp)
    800028ba:	6402                	ld	s0,0(sp)
    800028bc:	0141                	add	sp,sp,16
    800028be:	8082                	ret

00000000800028c0 <sys_wait>:

uint64
sys_wait(void)
{
    800028c0:	1101                	add	sp,sp,-32
    800028c2:	ec06                	sd	ra,24(sp)
    800028c4:	e822                	sd	s0,16(sp)
    800028c6:	1000                	add	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800028c8:	fe840593          	add	a1,s0,-24
    800028cc:	4501                	li	a0,0
    800028ce:	ef5ff0ef          	jal	800027c2 <argaddr>
  return wait(p);
    800028d2:	fe843503          	ld	a0,-24(s0)
    800028d6:	84dff0ef          	jal	80002122 <wait>
}
    800028da:	60e2                	ld	ra,24(sp)
    800028dc:	6442                	ld	s0,16(sp)
    800028de:	6105                	add	sp,sp,32
    800028e0:	8082                	ret

00000000800028e2 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800028e2:	7179                	add	sp,sp,-48
    800028e4:	f406                	sd	ra,40(sp)
    800028e6:	f022                	sd	s0,32(sp)
    800028e8:	ec26                	sd	s1,24(sp)
    800028ea:	1800                	add	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    800028ec:	fdc40593          	add	a1,s0,-36
    800028f0:	4501                	li	a0,0
    800028f2:	eb5ff0ef          	jal	800027a6 <argint>
  addr = myproc()->sz;
    800028f6:	ffdfe0ef          	jal	800018f2 <myproc>
    800028fa:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    800028fc:	fdc42503          	lw	a0,-36(s0)
    80002900:	ac8ff0ef          	jal	80001bc8 <growproc>
    80002904:	00054863          	bltz	a0,80002914 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80002908:	8526                	mv	a0,s1
    8000290a:	70a2                	ld	ra,40(sp)
    8000290c:	7402                	ld	s0,32(sp)
    8000290e:	64e2                	ld	s1,24(sp)
    80002910:	6145                	add	sp,sp,48
    80002912:	8082                	ret
    return -1;
    80002914:	54fd                	li	s1,-1
    80002916:	bfcd                	j	80002908 <sys_sbrk+0x26>

0000000080002918 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002918:	7139                	add	sp,sp,-64
    8000291a:	fc06                	sd	ra,56(sp)
    8000291c:	f822                	sd	s0,48(sp)
    8000291e:	f04a                	sd	s2,32(sp)
    80002920:	0080                	add	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002922:	fcc40593          	add	a1,s0,-52
    80002926:	4501                	li	a0,0
    80002928:	e7fff0ef          	jal	800027a6 <argint>
  if(n < 0)
    8000292c:	fcc42783          	lw	a5,-52(s0)
    80002930:	0607c763          	bltz	a5,8000299e <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80002934:	00013517          	auipc	a0,0x13
    80002938:	f2c50513          	add	a0,a0,-212 # 80015860 <tickslock>
    8000293c:	ab8fe0ef          	jal	80000bf4 <acquire>
  ticks0 = ticks;
    80002940:	00005917          	auipc	s2,0x5
    80002944:	fc092903          	lw	s2,-64(s2) # 80007900 <ticks>
  while(ticks - ticks0 < n){
    80002948:	fcc42783          	lw	a5,-52(s0)
    8000294c:	cf8d                	beqz	a5,80002986 <sys_sleep+0x6e>
    8000294e:	f426                	sd	s1,40(sp)
    80002950:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002952:	00013997          	auipc	s3,0x13
    80002956:	f0e98993          	add	s3,s3,-242 # 80015860 <tickslock>
    8000295a:	00005497          	auipc	s1,0x5
    8000295e:	fa648493          	add	s1,s1,-90 # 80007900 <ticks>
    if(killed(myproc())){
    80002962:	f91fe0ef          	jal	800018f2 <myproc>
    80002966:	f92ff0ef          	jal	800020f8 <killed>
    8000296a:	ed0d                	bnez	a0,800029a4 <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    8000296c:	85ce                	mv	a1,s3
    8000296e:	8526                	mv	a0,s1
    80002970:	d50ff0ef          	jal	80001ec0 <sleep>
  while(ticks - ticks0 < n){
    80002974:	409c                	lw	a5,0(s1)
    80002976:	412787bb          	subw	a5,a5,s2
    8000297a:	fcc42703          	lw	a4,-52(s0)
    8000297e:	fee7e2e3          	bltu	a5,a4,80002962 <sys_sleep+0x4a>
    80002982:	74a2                	ld	s1,40(sp)
    80002984:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002986:	00013517          	auipc	a0,0x13
    8000298a:	eda50513          	add	a0,a0,-294 # 80015860 <tickslock>
    8000298e:	afefe0ef          	jal	80000c8c <release>
  return 0;
    80002992:	4501                	li	a0,0
}
    80002994:	70e2                	ld	ra,56(sp)
    80002996:	7442                	ld	s0,48(sp)
    80002998:	7902                	ld	s2,32(sp)
    8000299a:	6121                	add	sp,sp,64
    8000299c:	8082                	ret
    n = 0;
    8000299e:	fc042623          	sw	zero,-52(s0)
    800029a2:	bf49                	j	80002934 <sys_sleep+0x1c>
      release(&tickslock);
    800029a4:	00013517          	auipc	a0,0x13
    800029a8:	ebc50513          	add	a0,a0,-324 # 80015860 <tickslock>
    800029ac:	ae0fe0ef          	jal	80000c8c <release>
      return -1;
    800029b0:	557d                	li	a0,-1
    800029b2:	74a2                	ld	s1,40(sp)
    800029b4:	69e2                	ld	s3,24(sp)
    800029b6:	bff9                	j	80002994 <sys_sleep+0x7c>

00000000800029b8 <sys_kill>:

uint64
sys_kill(void)
{
    800029b8:	1101                	add	sp,sp,-32
    800029ba:	ec06                	sd	ra,24(sp)
    800029bc:	e822                	sd	s0,16(sp)
    800029be:	1000                	add	s0,sp,32
  int pid;

  argint(0, &pid);
    800029c0:	fec40593          	add	a1,s0,-20
    800029c4:	4501                	li	a0,0
    800029c6:	de1ff0ef          	jal	800027a6 <argint>
  return kill(pid);
    800029ca:	fec42503          	lw	a0,-20(s0)
    800029ce:	ea0ff0ef          	jal	8000206e <kill>
}
    800029d2:	60e2                	ld	ra,24(sp)
    800029d4:	6442                	ld	s0,16(sp)
    800029d6:	6105                	add	sp,sp,32
    800029d8:	8082                	ret

00000000800029da <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800029da:	1101                	add	sp,sp,-32
    800029dc:	ec06                	sd	ra,24(sp)
    800029de:	e822                	sd	s0,16(sp)
    800029e0:	e426                	sd	s1,8(sp)
    800029e2:	1000                	add	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800029e4:	00013517          	auipc	a0,0x13
    800029e8:	e7c50513          	add	a0,a0,-388 # 80015860 <tickslock>
    800029ec:	a08fe0ef          	jal	80000bf4 <acquire>
  xticks = ticks;
    800029f0:	00005497          	auipc	s1,0x5
    800029f4:	f104a483          	lw	s1,-240(s1) # 80007900 <ticks>
  release(&tickslock);
    800029f8:	00013517          	auipc	a0,0x13
    800029fc:	e6850513          	add	a0,a0,-408 # 80015860 <tickslock>
    80002a00:	a8cfe0ef          	jal	80000c8c <release>
  return xticks;
}
    80002a04:	02049513          	sll	a0,s1,0x20
    80002a08:	9101                	srl	a0,a0,0x20
    80002a0a:	60e2                	ld	ra,24(sp)
    80002a0c:	6442                	ld	s0,16(sp)
    80002a0e:	64a2                	ld	s1,8(sp)
    80002a10:	6105                	add	sp,sp,32
    80002a12:	8082                	ret

0000000080002a14 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002a14:	7179                	add	sp,sp,-48
    80002a16:	f406                	sd	ra,40(sp)
    80002a18:	f022                	sd	s0,32(sp)
    80002a1a:	ec26                	sd	s1,24(sp)
    80002a1c:	e84a                	sd	s2,16(sp)
    80002a1e:	e44e                	sd	s3,8(sp)
    80002a20:	e052                	sd	s4,0(sp)
    80002a22:	1800                	add	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002a24:	00005597          	auipc	a1,0x5
    80002a28:	9ec58593          	add	a1,a1,-1556 # 80007410 <etext+0x410>
    80002a2c:	00013517          	auipc	a0,0x13
    80002a30:	e4c50513          	add	a0,a0,-436 # 80015878 <bcache>
    80002a34:	940fe0ef          	jal	80000b74 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002a38:	0001b797          	auipc	a5,0x1b
    80002a3c:	e4078793          	add	a5,a5,-448 # 8001d878 <bcache+0x8000>
    80002a40:	0001b717          	auipc	a4,0x1b
    80002a44:	0a070713          	add	a4,a4,160 # 8001dae0 <bcache+0x8268>
    80002a48:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002a4c:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002a50:	00013497          	auipc	s1,0x13
    80002a54:	e4048493          	add	s1,s1,-448 # 80015890 <bcache+0x18>
    b->next = bcache.head.next;
    80002a58:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002a5a:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002a5c:	00005a17          	auipc	s4,0x5
    80002a60:	9bca0a13          	add	s4,s4,-1604 # 80007418 <etext+0x418>
    b->next = bcache.head.next;
    80002a64:	2b893783          	ld	a5,696(s2)
    80002a68:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002a6a:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002a6e:	85d2                	mv	a1,s4
    80002a70:	01048513          	add	a0,s1,16
    80002a74:	248010ef          	jal	80003cbc <initsleeplock>
    bcache.head.next->prev = b;
    80002a78:	2b893783          	ld	a5,696(s2)
    80002a7c:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002a7e:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002a82:	45848493          	add	s1,s1,1112
    80002a86:	fd349fe3          	bne	s1,s3,80002a64 <binit+0x50>
  }
}
    80002a8a:	70a2                	ld	ra,40(sp)
    80002a8c:	7402                	ld	s0,32(sp)
    80002a8e:	64e2                	ld	s1,24(sp)
    80002a90:	6942                	ld	s2,16(sp)
    80002a92:	69a2                	ld	s3,8(sp)
    80002a94:	6a02                	ld	s4,0(sp)
    80002a96:	6145                	add	sp,sp,48
    80002a98:	8082                	ret

0000000080002a9a <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002a9a:	7179                	add	sp,sp,-48
    80002a9c:	f406                	sd	ra,40(sp)
    80002a9e:	f022                	sd	s0,32(sp)
    80002aa0:	ec26                	sd	s1,24(sp)
    80002aa2:	e84a                	sd	s2,16(sp)
    80002aa4:	e44e                	sd	s3,8(sp)
    80002aa6:	1800                	add	s0,sp,48
    80002aa8:	892a                	mv	s2,a0
    80002aaa:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002aac:	00013517          	auipc	a0,0x13
    80002ab0:	dcc50513          	add	a0,a0,-564 # 80015878 <bcache>
    80002ab4:	940fe0ef          	jal	80000bf4 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002ab8:	0001b497          	auipc	s1,0x1b
    80002abc:	0784b483          	ld	s1,120(s1) # 8001db30 <bcache+0x82b8>
    80002ac0:	0001b797          	auipc	a5,0x1b
    80002ac4:	02078793          	add	a5,a5,32 # 8001dae0 <bcache+0x8268>
    80002ac8:	02f48b63          	beq	s1,a5,80002afe <bread+0x64>
    80002acc:	873e                	mv	a4,a5
    80002ace:	a021                	j	80002ad6 <bread+0x3c>
    80002ad0:	68a4                	ld	s1,80(s1)
    80002ad2:	02e48663          	beq	s1,a4,80002afe <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002ad6:	449c                	lw	a5,8(s1)
    80002ad8:	ff279ce3          	bne	a5,s2,80002ad0 <bread+0x36>
    80002adc:	44dc                	lw	a5,12(s1)
    80002ade:	ff3799e3          	bne	a5,s3,80002ad0 <bread+0x36>
      b->refcnt++;
    80002ae2:	40bc                	lw	a5,64(s1)
    80002ae4:	2785                	addw	a5,a5,1
    80002ae6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ae8:	00013517          	auipc	a0,0x13
    80002aec:	d9050513          	add	a0,a0,-624 # 80015878 <bcache>
    80002af0:	99cfe0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80002af4:	01048513          	add	a0,s1,16
    80002af8:	1fa010ef          	jal	80003cf2 <acquiresleep>
      return b;
    80002afc:	a889                	j	80002b4e <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002afe:	0001b497          	auipc	s1,0x1b
    80002b02:	02a4b483          	ld	s1,42(s1) # 8001db28 <bcache+0x82b0>
    80002b06:	0001b797          	auipc	a5,0x1b
    80002b0a:	fda78793          	add	a5,a5,-38 # 8001dae0 <bcache+0x8268>
    80002b0e:	00f48863          	beq	s1,a5,80002b1e <bread+0x84>
    80002b12:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002b14:	40bc                	lw	a5,64(s1)
    80002b16:	cb91                	beqz	a5,80002b2a <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002b18:	64a4                	ld	s1,72(s1)
    80002b1a:	fee49de3          	bne	s1,a4,80002b14 <bread+0x7a>
  panic("bget: no buffers");
    80002b1e:	00005517          	auipc	a0,0x5
    80002b22:	90250513          	add	a0,a0,-1790 # 80007420 <etext+0x420>
    80002b26:	c6ffd0ef          	jal	80000794 <panic>
      b->dev = dev;
    80002b2a:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002b2e:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002b32:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002b36:	4785                	li	a5,1
    80002b38:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002b3a:	00013517          	auipc	a0,0x13
    80002b3e:	d3e50513          	add	a0,a0,-706 # 80015878 <bcache>
    80002b42:	94afe0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80002b46:	01048513          	add	a0,s1,16
    80002b4a:	1a8010ef          	jal	80003cf2 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002b4e:	409c                	lw	a5,0(s1)
    80002b50:	cb89                	beqz	a5,80002b62 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002b52:	8526                	mv	a0,s1
    80002b54:	70a2                	ld	ra,40(sp)
    80002b56:	7402                	ld	s0,32(sp)
    80002b58:	64e2                	ld	s1,24(sp)
    80002b5a:	6942                	ld	s2,16(sp)
    80002b5c:	69a2                	ld	s3,8(sp)
    80002b5e:	6145                	add	sp,sp,48
    80002b60:	8082                	ret
    virtio_disk_rw(b, 0);
    80002b62:	4581                	li	a1,0
    80002b64:	8526                	mv	a0,s1
    80002b66:	223020ef          	jal	80005588 <virtio_disk_rw>
    b->valid = 1;
    80002b6a:	4785                	li	a5,1
    80002b6c:	c09c                	sw	a5,0(s1)
  return b;
    80002b6e:	b7d5                	j	80002b52 <bread+0xb8>

0000000080002b70 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002b70:	1101                	add	sp,sp,-32
    80002b72:	ec06                	sd	ra,24(sp)
    80002b74:	e822                	sd	s0,16(sp)
    80002b76:	e426                	sd	s1,8(sp)
    80002b78:	1000                	add	s0,sp,32
    80002b7a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002b7c:	0541                	add	a0,a0,16
    80002b7e:	1f2010ef          	jal	80003d70 <holdingsleep>
    80002b82:	c911                	beqz	a0,80002b96 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002b84:	4585                	li	a1,1
    80002b86:	8526                	mv	a0,s1
    80002b88:	201020ef          	jal	80005588 <virtio_disk_rw>
}
    80002b8c:	60e2                	ld	ra,24(sp)
    80002b8e:	6442                	ld	s0,16(sp)
    80002b90:	64a2                	ld	s1,8(sp)
    80002b92:	6105                	add	sp,sp,32
    80002b94:	8082                	ret
    panic("bwrite");
    80002b96:	00005517          	auipc	a0,0x5
    80002b9a:	8a250513          	add	a0,a0,-1886 # 80007438 <etext+0x438>
    80002b9e:	bf7fd0ef          	jal	80000794 <panic>

0000000080002ba2 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002ba2:	1101                	add	sp,sp,-32
    80002ba4:	ec06                	sd	ra,24(sp)
    80002ba6:	e822                	sd	s0,16(sp)
    80002ba8:	e426                	sd	s1,8(sp)
    80002baa:	e04a                	sd	s2,0(sp)
    80002bac:	1000                	add	s0,sp,32
    80002bae:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002bb0:	01050913          	add	s2,a0,16
    80002bb4:	854a                	mv	a0,s2
    80002bb6:	1ba010ef          	jal	80003d70 <holdingsleep>
    80002bba:	c135                	beqz	a0,80002c1e <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002bbc:	854a                	mv	a0,s2
    80002bbe:	17a010ef          	jal	80003d38 <releasesleep>

  acquire(&bcache.lock);
    80002bc2:	00013517          	auipc	a0,0x13
    80002bc6:	cb650513          	add	a0,a0,-842 # 80015878 <bcache>
    80002bca:	82afe0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    80002bce:	40bc                	lw	a5,64(s1)
    80002bd0:	37fd                	addw	a5,a5,-1
    80002bd2:	0007871b          	sext.w	a4,a5
    80002bd6:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002bd8:	e71d                	bnez	a4,80002c06 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002bda:	68b8                	ld	a4,80(s1)
    80002bdc:	64bc                	ld	a5,72(s1)
    80002bde:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002be0:	68b8                	ld	a4,80(s1)
    80002be2:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002be4:	0001b797          	auipc	a5,0x1b
    80002be8:	c9478793          	add	a5,a5,-876 # 8001d878 <bcache+0x8000>
    80002bec:	2b87b703          	ld	a4,696(a5)
    80002bf0:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002bf2:	0001b717          	auipc	a4,0x1b
    80002bf6:	eee70713          	add	a4,a4,-274 # 8001dae0 <bcache+0x8268>
    80002bfa:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002bfc:	2b87b703          	ld	a4,696(a5)
    80002c00:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002c02:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002c06:	00013517          	auipc	a0,0x13
    80002c0a:	c7250513          	add	a0,a0,-910 # 80015878 <bcache>
    80002c0e:	87efe0ef          	jal	80000c8c <release>
}
    80002c12:	60e2                	ld	ra,24(sp)
    80002c14:	6442                	ld	s0,16(sp)
    80002c16:	64a2                	ld	s1,8(sp)
    80002c18:	6902                	ld	s2,0(sp)
    80002c1a:	6105                	add	sp,sp,32
    80002c1c:	8082                	ret
    panic("brelse");
    80002c1e:	00005517          	auipc	a0,0x5
    80002c22:	82250513          	add	a0,a0,-2014 # 80007440 <etext+0x440>
    80002c26:	b6ffd0ef          	jal	80000794 <panic>

0000000080002c2a <bpin>:

void
bpin(struct buf *b) {
    80002c2a:	1101                	add	sp,sp,-32
    80002c2c:	ec06                	sd	ra,24(sp)
    80002c2e:	e822                	sd	s0,16(sp)
    80002c30:	e426                	sd	s1,8(sp)
    80002c32:	1000                	add	s0,sp,32
    80002c34:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002c36:	00013517          	auipc	a0,0x13
    80002c3a:	c4250513          	add	a0,a0,-958 # 80015878 <bcache>
    80002c3e:	fb7fd0ef          	jal	80000bf4 <acquire>
  b->refcnt++;
    80002c42:	40bc                	lw	a5,64(s1)
    80002c44:	2785                	addw	a5,a5,1
    80002c46:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002c48:	00013517          	auipc	a0,0x13
    80002c4c:	c3050513          	add	a0,a0,-976 # 80015878 <bcache>
    80002c50:	83cfe0ef          	jal	80000c8c <release>
}
    80002c54:	60e2                	ld	ra,24(sp)
    80002c56:	6442                	ld	s0,16(sp)
    80002c58:	64a2                	ld	s1,8(sp)
    80002c5a:	6105                	add	sp,sp,32
    80002c5c:	8082                	ret

0000000080002c5e <bunpin>:

void
bunpin(struct buf *b) {
    80002c5e:	1101                	add	sp,sp,-32
    80002c60:	ec06                	sd	ra,24(sp)
    80002c62:	e822                	sd	s0,16(sp)
    80002c64:	e426                	sd	s1,8(sp)
    80002c66:	1000                	add	s0,sp,32
    80002c68:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002c6a:	00013517          	auipc	a0,0x13
    80002c6e:	c0e50513          	add	a0,a0,-1010 # 80015878 <bcache>
    80002c72:	f83fd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    80002c76:	40bc                	lw	a5,64(s1)
    80002c78:	37fd                	addw	a5,a5,-1
    80002c7a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002c7c:	00013517          	auipc	a0,0x13
    80002c80:	bfc50513          	add	a0,a0,-1028 # 80015878 <bcache>
    80002c84:	808fe0ef          	jal	80000c8c <release>
}
    80002c88:	60e2                	ld	ra,24(sp)
    80002c8a:	6442                	ld	s0,16(sp)
    80002c8c:	64a2                	ld	s1,8(sp)
    80002c8e:	6105                	add	sp,sp,32
    80002c90:	8082                	ret

0000000080002c92 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002c92:	1101                	add	sp,sp,-32
    80002c94:	ec06                	sd	ra,24(sp)
    80002c96:	e822                	sd	s0,16(sp)
    80002c98:	e426                	sd	s1,8(sp)
    80002c9a:	e04a                	sd	s2,0(sp)
    80002c9c:	1000                	add	s0,sp,32
    80002c9e:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002ca0:	00d5d59b          	srlw	a1,a1,0xd
    80002ca4:	0001b797          	auipc	a5,0x1b
    80002ca8:	2b07a783          	lw	a5,688(a5) # 8001df54 <sb+0x1c>
    80002cac:	9dbd                	addw	a1,a1,a5
    80002cae:	dedff0ef          	jal	80002a9a <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002cb2:	0074f713          	and	a4,s1,7
    80002cb6:	4785                	li	a5,1
    80002cb8:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002cbc:	14ce                	sll	s1,s1,0x33
    80002cbe:	90d9                	srl	s1,s1,0x36
    80002cc0:	00950733          	add	a4,a0,s1
    80002cc4:	05874703          	lbu	a4,88(a4)
    80002cc8:	00e7f6b3          	and	a3,a5,a4
    80002ccc:	c29d                	beqz	a3,80002cf2 <bfree+0x60>
    80002cce:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002cd0:	94aa                	add	s1,s1,a0
    80002cd2:	fff7c793          	not	a5,a5
    80002cd6:	8f7d                	and	a4,a4,a5
    80002cd8:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002cdc:	711000ef          	jal	80003bec <log_write>
  brelse(bp);
    80002ce0:	854a                	mv	a0,s2
    80002ce2:	ec1ff0ef          	jal	80002ba2 <brelse>
}
    80002ce6:	60e2                	ld	ra,24(sp)
    80002ce8:	6442                	ld	s0,16(sp)
    80002cea:	64a2                	ld	s1,8(sp)
    80002cec:	6902                	ld	s2,0(sp)
    80002cee:	6105                	add	sp,sp,32
    80002cf0:	8082                	ret
    panic("freeing free block");
    80002cf2:	00004517          	auipc	a0,0x4
    80002cf6:	75650513          	add	a0,a0,1878 # 80007448 <etext+0x448>
    80002cfa:	a9bfd0ef          	jal	80000794 <panic>

0000000080002cfe <balloc>:
{
    80002cfe:	711d                	add	sp,sp,-96
    80002d00:	ec86                	sd	ra,88(sp)
    80002d02:	e8a2                	sd	s0,80(sp)
    80002d04:	e4a6                	sd	s1,72(sp)
    80002d06:	1080                	add	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002d08:	0001b797          	auipc	a5,0x1b
    80002d0c:	2347a783          	lw	a5,564(a5) # 8001df3c <sb+0x4>
    80002d10:	0e078f63          	beqz	a5,80002e0e <balloc+0x110>
    80002d14:	e0ca                	sd	s2,64(sp)
    80002d16:	fc4e                	sd	s3,56(sp)
    80002d18:	f852                	sd	s4,48(sp)
    80002d1a:	f456                	sd	s5,40(sp)
    80002d1c:	f05a                	sd	s6,32(sp)
    80002d1e:	ec5e                	sd	s7,24(sp)
    80002d20:	e862                	sd	s8,16(sp)
    80002d22:	e466                	sd	s9,8(sp)
    80002d24:	8baa                	mv	s7,a0
    80002d26:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002d28:	0001bb17          	auipc	s6,0x1b
    80002d2c:	210b0b13          	add	s6,s6,528 # 8001df38 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002d30:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002d32:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002d34:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002d36:	6c89                	lui	s9,0x2
    80002d38:	a0b5                	j	80002da4 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002d3a:	97ca                	add	a5,a5,s2
    80002d3c:	8e55                	or	a2,a2,a3
    80002d3e:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002d42:	854a                	mv	a0,s2
    80002d44:	6a9000ef          	jal	80003bec <log_write>
        brelse(bp);
    80002d48:	854a                	mv	a0,s2
    80002d4a:	e59ff0ef          	jal	80002ba2 <brelse>
  bp = bread(dev, bno);
    80002d4e:	85a6                	mv	a1,s1
    80002d50:	855e                	mv	a0,s7
    80002d52:	d49ff0ef          	jal	80002a9a <bread>
    80002d56:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002d58:	40000613          	li	a2,1024
    80002d5c:	4581                	li	a1,0
    80002d5e:	05850513          	add	a0,a0,88
    80002d62:	f67fd0ef          	jal	80000cc8 <memset>
  log_write(bp);
    80002d66:	854a                	mv	a0,s2
    80002d68:	685000ef          	jal	80003bec <log_write>
  brelse(bp);
    80002d6c:	854a                	mv	a0,s2
    80002d6e:	e35ff0ef          	jal	80002ba2 <brelse>
}
    80002d72:	6906                	ld	s2,64(sp)
    80002d74:	79e2                	ld	s3,56(sp)
    80002d76:	7a42                	ld	s4,48(sp)
    80002d78:	7aa2                	ld	s5,40(sp)
    80002d7a:	7b02                	ld	s6,32(sp)
    80002d7c:	6be2                	ld	s7,24(sp)
    80002d7e:	6c42                	ld	s8,16(sp)
    80002d80:	6ca2                	ld	s9,8(sp)
}
    80002d82:	8526                	mv	a0,s1
    80002d84:	60e6                	ld	ra,88(sp)
    80002d86:	6446                	ld	s0,80(sp)
    80002d88:	64a6                	ld	s1,72(sp)
    80002d8a:	6125                	add	sp,sp,96
    80002d8c:	8082                	ret
    brelse(bp);
    80002d8e:	854a                	mv	a0,s2
    80002d90:	e13ff0ef          	jal	80002ba2 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002d94:	015c87bb          	addw	a5,s9,s5
    80002d98:	00078a9b          	sext.w	s5,a5
    80002d9c:	004b2703          	lw	a4,4(s6)
    80002da0:	04eaff63          	bgeu	s5,a4,80002dfe <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80002da4:	41fad79b          	sraw	a5,s5,0x1f
    80002da8:	0137d79b          	srlw	a5,a5,0x13
    80002dac:	015787bb          	addw	a5,a5,s5
    80002db0:	40d7d79b          	sraw	a5,a5,0xd
    80002db4:	01cb2583          	lw	a1,28(s6)
    80002db8:	9dbd                	addw	a1,a1,a5
    80002dba:	855e                	mv	a0,s7
    80002dbc:	cdfff0ef          	jal	80002a9a <bread>
    80002dc0:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002dc2:	004b2503          	lw	a0,4(s6)
    80002dc6:	000a849b          	sext.w	s1,s5
    80002dca:	8762                	mv	a4,s8
    80002dcc:	fca4f1e3          	bgeu	s1,a0,80002d8e <balloc+0x90>
      m = 1 << (bi % 8);
    80002dd0:	00777693          	and	a3,a4,7
    80002dd4:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002dd8:	41f7579b          	sraw	a5,a4,0x1f
    80002ddc:	01d7d79b          	srlw	a5,a5,0x1d
    80002de0:	9fb9                	addw	a5,a5,a4
    80002de2:	4037d79b          	sraw	a5,a5,0x3
    80002de6:	00f90633          	add	a2,s2,a5
    80002dea:	05864603          	lbu	a2,88(a2)
    80002dee:	00c6f5b3          	and	a1,a3,a2
    80002df2:	d5a1                	beqz	a1,80002d3a <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002df4:	2705                	addw	a4,a4,1
    80002df6:	2485                	addw	s1,s1,1
    80002df8:	fd471ae3          	bne	a4,s4,80002dcc <balloc+0xce>
    80002dfc:	bf49                	j	80002d8e <balloc+0x90>
    80002dfe:	6906                	ld	s2,64(sp)
    80002e00:	79e2                	ld	s3,56(sp)
    80002e02:	7a42                	ld	s4,48(sp)
    80002e04:	7aa2                	ld	s5,40(sp)
    80002e06:	7b02                	ld	s6,32(sp)
    80002e08:	6be2                	ld	s7,24(sp)
    80002e0a:	6c42                	ld	s8,16(sp)
    80002e0c:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80002e0e:	00004517          	auipc	a0,0x4
    80002e12:	65250513          	add	a0,a0,1618 # 80007460 <etext+0x460>
    80002e16:	eacfd0ef          	jal	800004c2 <printf>
  return 0;
    80002e1a:	4481                	li	s1,0
    80002e1c:	b79d                	j	80002d82 <balloc+0x84>

0000000080002e1e <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002e1e:	7179                	add	sp,sp,-48
    80002e20:	f406                	sd	ra,40(sp)
    80002e22:	f022                	sd	s0,32(sp)
    80002e24:	ec26                	sd	s1,24(sp)
    80002e26:	e84a                	sd	s2,16(sp)
    80002e28:	e44e                	sd	s3,8(sp)
    80002e2a:	1800                	add	s0,sp,48
    80002e2c:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002e2e:	47ad                	li	a5,11
    80002e30:	02b7e663          	bltu	a5,a1,80002e5c <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80002e34:	02059793          	sll	a5,a1,0x20
    80002e38:	01e7d593          	srl	a1,a5,0x1e
    80002e3c:	00b504b3          	add	s1,a0,a1
    80002e40:	0504a903          	lw	s2,80(s1)
    80002e44:	06091a63          	bnez	s2,80002eb8 <bmap+0x9a>
      addr = balloc(ip->dev);
    80002e48:	4108                	lw	a0,0(a0)
    80002e4a:	eb5ff0ef          	jal	80002cfe <balloc>
    80002e4e:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002e52:	06090363          	beqz	s2,80002eb8 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80002e56:	0524a823          	sw	s2,80(s1)
    80002e5a:	a8b9                	j	80002eb8 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002e5c:	ff45849b          	addw	s1,a1,-12
    80002e60:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002e64:	0ff00793          	li	a5,255
    80002e68:	06e7ee63          	bltu	a5,a4,80002ee4 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002e6c:	08052903          	lw	s2,128(a0)
    80002e70:	00091d63          	bnez	s2,80002e8a <bmap+0x6c>
      addr = balloc(ip->dev);
    80002e74:	4108                	lw	a0,0(a0)
    80002e76:	e89ff0ef          	jal	80002cfe <balloc>
    80002e7a:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002e7e:	02090d63          	beqz	s2,80002eb8 <bmap+0x9a>
    80002e82:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002e84:	0929a023          	sw	s2,128(s3)
    80002e88:	a011                	j	80002e8c <bmap+0x6e>
    80002e8a:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002e8c:	85ca                	mv	a1,s2
    80002e8e:	0009a503          	lw	a0,0(s3)
    80002e92:	c09ff0ef          	jal	80002a9a <bread>
    80002e96:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002e98:	05850793          	add	a5,a0,88
    if((addr = a[bn]) == 0){
    80002e9c:	02049713          	sll	a4,s1,0x20
    80002ea0:	01e75593          	srl	a1,a4,0x1e
    80002ea4:	00b784b3          	add	s1,a5,a1
    80002ea8:	0004a903          	lw	s2,0(s1)
    80002eac:	00090e63          	beqz	s2,80002ec8 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002eb0:	8552                	mv	a0,s4
    80002eb2:	cf1ff0ef          	jal	80002ba2 <brelse>
    return addr;
    80002eb6:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002eb8:	854a                	mv	a0,s2
    80002eba:	70a2                	ld	ra,40(sp)
    80002ebc:	7402                	ld	s0,32(sp)
    80002ebe:	64e2                	ld	s1,24(sp)
    80002ec0:	6942                	ld	s2,16(sp)
    80002ec2:	69a2                	ld	s3,8(sp)
    80002ec4:	6145                	add	sp,sp,48
    80002ec6:	8082                	ret
      addr = balloc(ip->dev);
    80002ec8:	0009a503          	lw	a0,0(s3)
    80002ecc:	e33ff0ef          	jal	80002cfe <balloc>
    80002ed0:	0005091b          	sext.w	s2,a0
      if(addr){
    80002ed4:	fc090ee3          	beqz	s2,80002eb0 <bmap+0x92>
        a[bn] = addr;
    80002ed8:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80002edc:	8552                	mv	a0,s4
    80002ede:	50f000ef          	jal	80003bec <log_write>
    80002ee2:	b7f9                	j	80002eb0 <bmap+0x92>
    80002ee4:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80002ee6:	00004517          	auipc	a0,0x4
    80002eea:	59250513          	add	a0,a0,1426 # 80007478 <etext+0x478>
    80002eee:	8a7fd0ef          	jal	80000794 <panic>

0000000080002ef2 <iget>:
{
    80002ef2:	7179                	add	sp,sp,-48
    80002ef4:	f406                	sd	ra,40(sp)
    80002ef6:	f022                	sd	s0,32(sp)
    80002ef8:	ec26                	sd	s1,24(sp)
    80002efa:	e84a                	sd	s2,16(sp)
    80002efc:	e44e                	sd	s3,8(sp)
    80002efe:	e052                	sd	s4,0(sp)
    80002f00:	1800                	add	s0,sp,48
    80002f02:	89aa                	mv	s3,a0
    80002f04:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002f06:	0001b517          	auipc	a0,0x1b
    80002f0a:	05250513          	add	a0,a0,82 # 8001df58 <itable>
    80002f0e:	ce7fd0ef          	jal	80000bf4 <acquire>
  empty = 0;
    80002f12:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002f14:	0001b497          	auipc	s1,0x1b
    80002f18:	05c48493          	add	s1,s1,92 # 8001df70 <itable+0x18>
    80002f1c:	0001d697          	auipc	a3,0x1d
    80002f20:	ae468693          	add	a3,a3,-1308 # 8001fa00 <log>
    80002f24:	a039                	j	80002f32 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002f26:	02090963          	beqz	s2,80002f58 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002f2a:	08848493          	add	s1,s1,136
    80002f2e:	02d48863          	beq	s1,a3,80002f5e <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80002f32:	449c                	lw	a5,8(s1)
    80002f34:	fef059e3          	blez	a5,80002f26 <iget+0x34>
    80002f38:	4098                	lw	a4,0(s1)
    80002f3a:	ff3716e3          	bne	a4,s3,80002f26 <iget+0x34>
    80002f3e:	40d8                	lw	a4,4(s1)
    80002f40:	ff4713e3          	bne	a4,s4,80002f26 <iget+0x34>
      ip->ref++;
    80002f44:	2785                	addw	a5,a5,1
    80002f46:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002f48:	0001b517          	auipc	a0,0x1b
    80002f4c:	01050513          	add	a0,a0,16 # 8001df58 <itable>
    80002f50:	d3dfd0ef          	jal	80000c8c <release>
      return ip;
    80002f54:	8926                	mv	s2,s1
    80002f56:	a02d                	j	80002f80 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002f58:	fbe9                	bnez	a5,80002f2a <iget+0x38>
      empty = ip;
    80002f5a:	8926                	mv	s2,s1
    80002f5c:	b7f9                	j	80002f2a <iget+0x38>
  if(empty == 0)
    80002f5e:	02090a63          	beqz	s2,80002f92 <iget+0xa0>
  ip->dev = dev;
    80002f62:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80002f66:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80002f6a:	4785                	li	a5,1
    80002f6c:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80002f70:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80002f74:	0001b517          	auipc	a0,0x1b
    80002f78:	fe450513          	add	a0,a0,-28 # 8001df58 <itable>
    80002f7c:	d11fd0ef          	jal	80000c8c <release>
}
    80002f80:	854a                	mv	a0,s2
    80002f82:	70a2                	ld	ra,40(sp)
    80002f84:	7402                	ld	s0,32(sp)
    80002f86:	64e2                	ld	s1,24(sp)
    80002f88:	6942                	ld	s2,16(sp)
    80002f8a:	69a2                	ld	s3,8(sp)
    80002f8c:	6a02                	ld	s4,0(sp)
    80002f8e:	6145                	add	sp,sp,48
    80002f90:	8082                	ret
    panic("iget: no inodes");
    80002f92:	00004517          	auipc	a0,0x4
    80002f96:	4fe50513          	add	a0,a0,1278 # 80007490 <etext+0x490>
    80002f9a:	ffafd0ef          	jal	80000794 <panic>

0000000080002f9e <fsinit>:
fsinit(int dev) {
    80002f9e:	7179                	add	sp,sp,-48
    80002fa0:	f406                	sd	ra,40(sp)
    80002fa2:	f022                	sd	s0,32(sp)
    80002fa4:	ec26                	sd	s1,24(sp)
    80002fa6:	e84a                	sd	s2,16(sp)
    80002fa8:	e44e                	sd	s3,8(sp)
    80002faa:	1800                	add	s0,sp,48
    80002fac:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80002fae:	4585                	li	a1,1
    80002fb0:	aebff0ef          	jal	80002a9a <bread>
    80002fb4:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80002fb6:	0001b997          	auipc	s3,0x1b
    80002fba:	f8298993          	add	s3,s3,-126 # 8001df38 <sb>
    80002fbe:	02000613          	li	a2,32
    80002fc2:	05850593          	add	a1,a0,88
    80002fc6:	854e                	mv	a0,s3
    80002fc8:	d5dfd0ef          	jal	80000d24 <memmove>
  brelse(bp);
    80002fcc:	8526                	mv	a0,s1
    80002fce:	bd5ff0ef          	jal	80002ba2 <brelse>
  if(sb.magic != FSMAGIC)
    80002fd2:	0009a703          	lw	a4,0(s3)
    80002fd6:	102037b7          	lui	a5,0x10203
    80002fda:	04078793          	add	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80002fde:	02f71063          	bne	a4,a5,80002ffe <fsinit+0x60>
  initlog(dev, &sb);
    80002fe2:	0001b597          	auipc	a1,0x1b
    80002fe6:	f5658593          	add	a1,a1,-170 # 8001df38 <sb>
    80002fea:	854a                	mv	a0,s2
    80002fec:	1f9000ef          	jal	800039e4 <initlog>
}
    80002ff0:	70a2                	ld	ra,40(sp)
    80002ff2:	7402                	ld	s0,32(sp)
    80002ff4:	64e2                	ld	s1,24(sp)
    80002ff6:	6942                	ld	s2,16(sp)
    80002ff8:	69a2                	ld	s3,8(sp)
    80002ffa:	6145                	add	sp,sp,48
    80002ffc:	8082                	ret
    panic("invalid file system");
    80002ffe:	00004517          	auipc	a0,0x4
    80003002:	4a250513          	add	a0,a0,1186 # 800074a0 <etext+0x4a0>
    80003006:	f8efd0ef          	jal	80000794 <panic>

000000008000300a <iinit>:
{
    8000300a:	7179                	add	sp,sp,-48
    8000300c:	f406                	sd	ra,40(sp)
    8000300e:	f022                	sd	s0,32(sp)
    80003010:	ec26                	sd	s1,24(sp)
    80003012:	e84a                	sd	s2,16(sp)
    80003014:	e44e                	sd	s3,8(sp)
    80003016:	1800                	add	s0,sp,48
  initlock(&itable.lock, "itable");
    80003018:	00004597          	auipc	a1,0x4
    8000301c:	4a058593          	add	a1,a1,1184 # 800074b8 <etext+0x4b8>
    80003020:	0001b517          	auipc	a0,0x1b
    80003024:	f3850513          	add	a0,a0,-200 # 8001df58 <itable>
    80003028:	b4dfd0ef          	jal	80000b74 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000302c:	0001b497          	auipc	s1,0x1b
    80003030:	f5448493          	add	s1,s1,-172 # 8001df80 <itable+0x28>
    80003034:	0001d997          	auipc	s3,0x1d
    80003038:	9dc98993          	add	s3,s3,-1572 # 8001fa10 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000303c:	00004917          	auipc	s2,0x4
    80003040:	48490913          	add	s2,s2,1156 # 800074c0 <etext+0x4c0>
    80003044:	85ca                	mv	a1,s2
    80003046:	8526                	mv	a0,s1
    80003048:	475000ef          	jal	80003cbc <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000304c:	08848493          	add	s1,s1,136
    80003050:	ff349ae3          	bne	s1,s3,80003044 <iinit+0x3a>
}
    80003054:	70a2                	ld	ra,40(sp)
    80003056:	7402                	ld	s0,32(sp)
    80003058:	64e2                	ld	s1,24(sp)
    8000305a:	6942                	ld	s2,16(sp)
    8000305c:	69a2                	ld	s3,8(sp)
    8000305e:	6145                	add	sp,sp,48
    80003060:	8082                	ret

0000000080003062 <ialloc>:
{
    80003062:	7139                	add	sp,sp,-64
    80003064:	fc06                	sd	ra,56(sp)
    80003066:	f822                	sd	s0,48(sp)
    80003068:	0080                	add	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    8000306a:	0001b717          	auipc	a4,0x1b
    8000306e:	eda72703          	lw	a4,-294(a4) # 8001df44 <sb+0xc>
    80003072:	4785                	li	a5,1
    80003074:	06e7f063          	bgeu	a5,a4,800030d4 <ialloc+0x72>
    80003078:	f426                	sd	s1,40(sp)
    8000307a:	f04a                	sd	s2,32(sp)
    8000307c:	ec4e                	sd	s3,24(sp)
    8000307e:	e852                	sd	s4,16(sp)
    80003080:	e456                	sd	s5,8(sp)
    80003082:	e05a                	sd	s6,0(sp)
    80003084:	8aaa                	mv	s5,a0
    80003086:	8b2e                	mv	s6,a1
    80003088:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000308a:	0001ba17          	auipc	s4,0x1b
    8000308e:	eaea0a13          	add	s4,s4,-338 # 8001df38 <sb>
    80003092:	00495593          	srl	a1,s2,0x4
    80003096:	018a2783          	lw	a5,24(s4)
    8000309a:	9dbd                	addw	a1,a1,a5
    8000309c:	8556                	mv	a0,s5
    8000309e:	9fdff0ef          	jal	80002a9a <bread>
    800030a2:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800030a4:	05850993          	add	s3,a0,88
    800030a8:	00f97793          	and	a5,s2,15
    800030ac:	079a                	sll	a5,a5,0x6
    800030ae:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800030b0:	00099783          	lh	a5,0(s3)
    800030b4:	cb9d                	beqz	a5,800030ea <ialloc+0x88>
    brelse(bp);
    800030b6:	aedff0ef          	jal	80002ba2 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800030ba:	0905                	add	s2,s2,1
    800030bc:	00ca2703          	lw	a4,12(s4)
    800030c0:	0009079b          	sext.w	a5,s2
    800030c4:	fce7e7e3          	bltu	a5,a4,80003092 <ialloc+0x30>
    800030c8:	74a2                	ld	s1,40(sp)
    800030ca:	7902                	ld	s2,32(sp)
    800030cc:	69e2                	ld	s3,24(sp)
    800030ce:	6a42                	ld	s4,16(sp)
    800030d0:	6aa2                	ld	s5,8(sp)
    800030d2:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800030d4:	00004517          	auipc	a0,0x4
    800030d8:	3f450513          	add	a0,a0,1012 # 800074c8 <etext+0x4c8>
    800030dc:	be6fd0ef          	jal	800004c2 <printf>
  return 0;
    800030e0:	4501                	li	a0,0
}
    800030e2:	70e2                	ld	ra,56(sp)
    800030e4:	7442                	ld	s0,48(sp)
    800030e6:	6121                	add	sp,sp,64
    800030e8:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800030ea:	04000613          	li	a2,64
    800030ee:	4581                	li	a1,0
    800030f0:	854e                	mv	a0,s3
    800030f2:	bd7fd0ef          	jal	80000cc8 <memset>
      dip->type = type;
    800030f6:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800030fa:	8526                	mv	a0,s1
    800030fc:	2f1000ef          	jal	80003bec <log_write>
      brelse(bp);
    80003100:	8526                	mv	a0,s1
    80003102:	aa1ff0ef          	jal	80002ba2 <brelse>
      return iget(dev, inum);
    80003106:	0009059b          	sext.w	a1,s2
    8000310a:	8556                	mv	a0,s5
    8000310c:	de7ff0ef          	jal	80002ef2 <iget>
    80003110:	74a2                	ld	s1,40(sp)
    80003112:	7902                	ld	s2,32(sp)
    80003114:	69e2                	ld	s3,24(sp)
    80003116:	6a42                	ld	s4,16(sp)
    80003118:	6aa2                	ld	s5,8(sp)
    8000311a:	6b02                	ld	s6,0(sp)
    8000311c:	b7d9                	j	800030e2 <ialloc+0x80>

000000008000311e <iupdate>:
{
    8000311e:	1101                	add	sp,sp,-32
    80003120:	ec06                	sd	ra,24(sp)
    80003122:	e822                	sd	s0,16(sp)
    80003124:	e426                	sd	s1,8(sp)
    80003126:	e04a                	sd	s2,0(sp)
    80003128:	1000                	add	s0,sp,32
    8000312a:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000312c:	415c                	lw	a5,4(a0)
    8000312e:	0047d79b          	srlw	a5,a5,0x4
    80003132:	0001b597          	auipc	a1,0x1b
    80003136:	e1e5a583          	lw	a1,-482(a1) # 8001df50 <sb+0x18>
    8000313a:	9dbd                	addw	a1,a1,a5
    8000313c:	4108                	lw	a0,0(a0)
    8000313e:	95dff0ef          	jal	80002a9a <bread>
    80003142:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003144:	05850793          	add	a5,a0,88
    80003148:	40d8                	lw	a4,4(s1)
    8000314a:	8b3d                	and	a4,a4,15
    8000314c:	071a                	sll	a4,a4,0x6
    8000314e:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003150:	04449703          	lh	a4,68(s1)
    80003154:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003158:	04649703          	lh	a4,70(s1)
    8000315c:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003160:	04849703          	lh	a4,72(s1)
    80003164:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003168:	04a49703          	lh	a4,74(s1)
    8000316c:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003170:	44f8                	lw	a4,76(s1)
    80003172:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003174:	03400613          	li	a2,52
    80003178:	05048593          	add	a1,s1,80
    8000317c:	00c78513          	add	a0,a5,12
    80003180:	ba5fd0ef          	jal	80000d24 <memmove>
  log_write(bp);
    80003184:	854a                	mv	a0,s2
    80003186:	267000ef          	jal	80003bec <log_write>
  brelse(bp);
    8000318a:	854a                	mv	a0,s2
    8000318c:	a17ff0ef          	jal	80002ba2 <brelse>
}
    80003190:	60e2                	ld	ra,24(sp)
    80003192:	6442                	ld	s0,16(sp)
    80003194:	64a2                	ld	s1,8(sp)
    80003196:	6902                	ld	s2,0(sp)
    80003198:	6105                	add	sp,sp,32
    8000319a:	8082                	ret

000000008000319c <idup>:
{
    8000319c:	1101                	add	sp,sp,-32
    8000319e:	ec06                	sd	ra,24(sp)
    800031a0:	e822                	sd	s0,16(sp)
    800031a2:	e426                	sd	s1,8(sp)
    800031a4:	1000                	add	s0,sp,32
    800031a6:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800031a8:	0001b517          	auipc	a0,0x1b
    800031ac:	db050513          	add	a0,a0,-592 # 8001df58 <itable>
    800031b0:	a45fd0ef          	jal	80000bf4 <acquire>
  ip->ref++;
    800031b4:	449c                	lw	a5,8(s1)
    800031b6:	2785                	addw	a5,a5,1
    800031b8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800031ba:	0001b517          	auipc	a0,0x1b
    800031be:	d9e50513          	add	a0,a0,-610 # 8001df58 <itable>
    800031c2:	acbfd0ef          	jal	80000c8c <release>
}
    800031c6:	8526                	mv	a0,s1
    800031c8:	60e2                	ld	ra,24(sp)
    800031ca:	6442                	ld	s0,16(sp)
    800031cc:	64a2                	ld	s1,8(sp)
    800031ce:	6105                	add	sp,sp,32
    800031d0:	8082                	ret

00000000800031d2 <ilock>:
{
    800031d2:	1101                	add	sp,sp,-32
    800031d4:	ec06                	sd	ra,24(sp)
    800031d6:	e822                	sd	s0,16(sp)
    800031d8:	e426                	sd	s1,8(sp)
    800031da:	1000                	add	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800031dc:	cd19                	beqz	a0,800031fa <ilock+0x28>
    800031de:	84aa                	mv	s1,a0
    800031e0:	451c                	lw	a5,8(a0)
    800031e2:	00f05c63          	blez	a5,800031fa <ilock+0x28>
  acquiresleep(&ip->lock);
    800031e6:	0541                	add	a0,a0,16
    800031e8:	30b000ef          	jal	80003cf2 <acquiresleep>
  if(ip->valid == 0){
    800031ec:	40bc                	lw	a5,64(s1)
    800031ee:	cf89                	beqz	a5,80003208 <ilock+0x36>
}
    800031f0:	60e2                	ld	ra,24(sp)
    800031f2:	6442                	ld	s0,16(sp)
    800031f4:	64a2                	ld	s1,8(sp)
    800031f6:	6105                	add	sp,sp,32
    800031f8:	8082                	ret
    800031fa:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800031fc:	00004517          	auipc	a0,0x4
    80003200:	2e450513          	add	a0,a0,740 # 800074e0 <etext+0x4e0>
    80003204:	d90fd0ef          	jal	80000794 <panic>
    80003208:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000320a:	40dc                	lw	a5,4(s1)
    8000320c:	0047d79b          	srlw	a5,a5,0x4
    80003210:	0001b597          	auipc	a1,0x1b
    80003214:	d405a583          	lw	a1,-704(a1) # 8001df50 <sb+0x18>
    80003218:	9dbd                	addw	a1,a1,a5
    8000321a:	4088                	lw	a0,0(s1)
    8000321c:	87fff0ef          	jal	80002a9a <bread>
    80003220:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003222:	05850593          	add	a1,a0,88
    80003226:	40dc                	lw	a5,4(s1)
    80003228:	8bbd                	and	a5,a5,15
    8000322a:	079a                	sll	a5,a5,0x6
    8000322c:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000322e:	00059783          	lh	a5,0(a1)
    80003232:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003236:	00259783          	lh	a5,2(a1)
    8000323a:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000323e:	00459783          	lh	a5,4(a1)
    80003242:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003246:	00659783          	lh	a5,6(a1)
    8000324a:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000324e:	459c                	lw	a5,8(a1)
    80003250:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003252:	03400613          	li	a2,52
    80003256:	05b1                	add	a1,a1,12
    80003258:	05048513          	add	a0,s1,80
    8000325c:	ac9fd0ef          	jal	80000d24 <memmove>
    brelse(bp);
    80003260:	854a                	mv	a0,s2
    80003262:	941ff0ef          	jal	80002ba2 <brelse>
    ip->valid = 1;
    80003266:	4785                	li	a5,1
    80003268:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000326a:	04449783          	lh	a5,68(s1)
    8000326e:	c399                	beqz	a5,80003274 <ilock+0xa2>
    80003270:	6902                	ld	s2,0(sp)
    80003272:	bfbd                	j	800031f0 <ilock+0x1e>
      panic("ilock: no type");
    80003274:	00004517          	auipc	a0,0x4
    80003278:	27450513          	add	a0,a0,628 # 800074e8 <etext+0x4e8>
    8000327c:	d18fd0ef          	jal	80000794 <panic>

0000000080003280 <iunlock>:
{
    80003280:	1101                	add	sp,sp,-32
    80003282:	ec06                	sd	ra,24(sp)
    80003284:	e822                	sd	s0,16(sp)
    80003286:	e426                	sd	s1,8(sp)
    80003288:	e04a                	sd	s2,0(sp)
    8000328a:	1000                	add	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000328c:	c505                	beqz	a0,800032b4 <iunlock+0x34>
    8000328e:	84aa                	mv	s1,a0
    80003290:	01050913          	add	s2,a0,16
    80003294:	854a                	mv	a0,s2
    80003296:	2db000ef          	jal	80003d70 <holdingsleep>
    8000329a:	cd09                	beqz	a0,800032b4 <iunlock+0x34>
    8000329c:	449c                	lw	a5,8(s1)
    8000329e:	00f05b63          	blez	a5,800032b4 <iunlock+0x34>
  releasesleep(&ip->lock);
    800032a2:	854a                	mv	a0,s2
    800032a4:	295000ef          	jal	80003d38 <releasesleep>
}
    800032a8:	60e2                	ld	ra,24(sp)
    800032aa:	6442                	ld	s0,16(sp)
    800032ac:	64a2                	ld	s1,8(sp)
    800032ae:	6902                	ld	s2,0(sp)
    800032b0:	6105                	add	sp,sp,32
    800032b2:	8082                	ret
    panic("iunlock");
    800032b4:	00004517          	auipc	a0,0x4
    800032b8:	24450513          	add	a0,a0,580 # 800074f8 <etext+0x4f8>
    800032bc:	cd8fd0ef          	jal	80000794 <panic>

00000000800032c0 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800032c0:	7179                	add	sp,sp,-48
    800032c2:	f406                	sd	ra,40(sp)
    800032c4:	f022                	sd	s0,32(sp)
    800032c6:	ec26                	sd	s1,24(sp)
    800032c8:	e84a                	sd	s2,16(sp)
    800032ca:	e44e                	sd	s3,8(sp)
    800032cc:	1800                	add	s0,sp,48
    800032ce:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800032d0:	05050493          	add	s1,a0,80
    800032d4:	08050913          	add	s2,a0,128
    800032d8:	a021                	j	800032e0 <itrunc+0x20>
    800032da:	0491                	add	s1,s1,4
    800032dc:	01248b63          	beq	s1,s2,800032f2 <itrunc+0x32>
    if(ip->addrs[i]){
    800032e0:	408c                	lw	a1,0(s1)
    800032e2:	dde5                	beqz	a1,800032da <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800032e4:	0009a503          	lw	a0,0(s3)
    800032e8:	9abff0ef          	jal	80002c92 <bfree>
      ip->addrs[i] = 0;
    800032ec:	0004a023          	sw	zero,0(s1)
    800032f0:	b7ed                	j	800032da <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800032f2:	0809a583          	lw	a1,128(s3)
    800032f6:	ed89                	bnez	a1,80003310 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800032f8:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800032fc:	854e                	mv	a0,s3
    800032fe:	e21ff0ef          	jal	8000311e <iupdate>
}
    80003302:	70a2                	ld	ra,40(sp)
    80003304:	7402                	ld	s0,32(sp)
    80003306:	64e2                	ld	s1,24(sp)
    80003308:	6942                	ld	s2,16(sp)
    8000330a:	69a2                	ld	s3,8(sp)
    8000330c:	6145                	add	sp,sp,48
    8000330e:	8082                	ret
    80003310:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003312:	0009a503          	lw	a0,0(s3)
    80003316:	f84ff0ef          	jal	80002a9a <bread>
    8000331a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000331c:	05850493          	add	s1,a0,88
    80003320:	45850913          	add	s2,a0,1112
    80003324:	a021                	j	8000332c <itrunc+0x6c>
    80003326:	0491                	add	s1,s1,4
    80003328:	01248963          	beq	s1,s2,8000333a <itrunc+0x7a>
      if(a[j])
    8000332c:	408c                	lw	a1,0(s1)
    8000332e:	dde5                	beqz	a1,80003326 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003330:	0009a503          	lw	a0,0(s3)
    80003334:	95fff0ef          	jal	80002c92 <bfree>
    80003338:	b7fd                	j	80003326 <itrunc+0x66>
    brelse(bp);
    8000333a:	8552                	mv	a0,s4
    8000333c:	867ff0ef          	jal	80002ba2 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003340:	0809a583          	lw	a1,128(s3)
    80003344:	0009a503          	lw	a0,0(s3)
    80003348:	94bff0ef          	jal	80002c92 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000334c:	0809a023          	sw	zero,128(s3)
    80003350:	6a02                	ld	s4,0(sp)
    80003352:	b75d                	j	800032f8 <itrunc+0x38>

0000000080003354 <iput>:
{
    80003354:	1101                	add	sp,sp,-32
    80003356:	ec06                	sd	ra,24(sp)
    80003358:	e822                	sd	s0,16(sp)
    8000335a:	e426                	sd	s1,8(sp)
    8000335c:	1000                	add	s0,sp,32
    8000335e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003360:	0001b517          	auipc	a0,0x1b
    80003364:	bf850513          	add	a0,a0,-1032 # 8001df58 <itable>
    80003368:	88dfd0ef          	jal	80000bf4 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000336c:	4498                	lw	a4,8(s1)
    8000336e:	4785                	li	a5,1
    80003370:	02f70063          	beq	a4,a5,80003390 <iput+0x3c>
  ip->ref--;
    80003374:	449c                	lw	a5,8(s1)
    80003376:	37fd                	addw	a5,a5,-1
    80003378:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000337a:	0001b517          	auipc	a0,0x1b
    8000337e:	bde50513          	add	a0,a0,-1058 # 8001df58 <itable>
    80003382:	90bfd0ef          	jal	80000c8c <release>
}
    80003386:	60e2                	ld	ra,24(sp)
    80003388:	6442                	ld	s0,16(sp)
    8000338a:	64a2                	ld	s1,8(sp)
    8000338c:	6105                	add	sp,sp,32
    8000338e:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003390:	40bc                	lw	a5,64(s1)
    80003392:	d3ed                	beqz	a5,80003374 <iput+0x20>
    80003394:	04a49783          	lh	a5,74(s1)
    80003398:	fff1                	bnez	a5,80003374 <iput+0x20>
    8000339a:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    8000339c:	01048913          	add	s2,s1,16
    800033a0:	854a                	mv	a0,s2
    800033a2:	151000ef          	jal	80003cf2 <acquiresleep>
    release(&itable.lock);
    800033a6:	0001b517          	auipc	a0,0x1b
    800033aa:	bb250513          	add	a0,a0,-1102 # 8001df58 <itable>
    800033ae:	8dffd0ef          	jal	80000c8c <release>
    itrunc(ip);
    800033b2:	8526                	mv	a0,s1
    800033b4:	f0dff0ef          	jal	800032c0 <itrunc>
    ip->type = 0;
    800033b8:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800033bc:	8526                	mv	a0,s1
    800033be:	d61ff0ef          	jal	8000311e <iupdate>
    ip->valid = 0;
    800033c2:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800033c6:	854a                	mv	a0,s2
    800033c8:	171000ef          	jal	80003d38 <releasesleep>
    acquire(&itable.lock);
    800033cc:	0001b517          	auipc	a0,0x1b
    800033d0:	b8c50513          	add	a0,a0,-1140 # 8001df58 <itable>
    800033d4:	821fd0ef          	jal	80000bf4 <acquire>
    800033d8:	6902                	ld	s2,0(sp)
    800033da:	bf69                	j	80003374 <iput+0x20>

00000000800033dc <iunlockput>:
{
    800033dc:	1101                	add	sp,sp,-32
    800033de:	ec06                	sd	ra,24(sp)
    800033e0:	e822                	sd	s0,16(sp)
    800033e2:	e426                	sd	s1,8(sp)
    800033e4:	1000                	add	s0,sp,32
    800033e6:	84aa                	mv	s1,a0
  iunlock(ip);
    800033e8:	e99ff0ef          	jal	80003280 <iunlock>
  iput(ip);
    800033ec:	8526                	mv	a0,s1
    800033ee:	f67ff0ef          	jal	80003354 <iput>
}
    800033f2:	60e2                	ld	ra,24(sp)
    800033f4:	6442                	ld	s0,16(sp)
    800033f6:	64a2                	ld	s1,8(sp)
    800033f8:	6105                	add	sp,sp,32
    800033fa:	8082                	ret

00000000800033fc <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800033fc:	1141                	add	sp,sp,-16
    800033fe:	e422                	sd	s0,8(sp)
    80003400:	0800                	add	s0,sp,16
  st->dev = ip->dev;
    80003402:	411c                	lw	a5,0(a0)
    80003404:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003406:	415c                	lw	a5,4(a0)
    80003408:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000340a:	04451783          	lh	a5,68(a0)
    8000340e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003412:	04a51783          	lh	a5,74(a0)
    80003416:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000341a:	04c56783          	lwu	a5,76(a0)
    8000341e:	e99c                	sd	a5,16(a1)
}
    80003420:	6422                	ld	s0,8(sp)
    80003422:	0141                	add	sp,sp,16
    80003424:	8082                	ret

0000000080003426 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003426:	457c                	lw	a5,76(a0)
    80003428:	0ed7eb63          	bltu	a5,a3,8000351e <readi+0xf8>
{
    8000342c:	7159                	add	sp,sp,-112
    8000342e:	f486                	sd	ra,104(sp)
    80003430:	f0a2                	sd	s0,96(sp)
    80003432:	eca6                	sd	s1,88(sp)
    80003434:	e0d2                	sd	s4,64(sp)
    80003436:	fc56                	sd	s5,56(sp)
    80003438:	f85a                	sd	s6,48(sp)
    8000343a:	f45e                	sd	s7,40(sp)
    8000343c:	1880                	add	s0,sp,112
    8000343e:	8b2a                	mv	s6,a0
    80003440:	8bae                	mv	s7,a1
    80003442:	8a32                	mv	s4,a2
    80003444:	84b6                	mv	s1,a3
    80003446:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003448:	9f35                	addw	a4,a4,a3
    return 0;
    8000344a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000344c:	0cd76063          	bltu	a4,a3,8000350c <readi+0xe6>
    80003450:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003452:	00e7f463          	bgeu	a5,a4,8000345a <readi+0x34>
    n = ip->size - off;
    80003456:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000345a:	080a8f63          	beqz	s5,800034f8 <readi+0xd2>
    8000345e:	e8ca                	sd	s2,80(sp)
    80003460:	f062                	sd	s8,32(sp)
    80003462:	ec66                	sd	s9,24(sp)
    80003464:	e86a                	sd	s10,16(sp)
    80003466:	e46e                	sd	s11,8(sp)
    80003468:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000346a:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000346e:	5c7d                	li	s8,-1
    80003470:	a80d                	j	800034a2 <readi+0x7c>
    80003472:	020d1d93          	sll	s11,s10,0x20
    80003476:	020ddd93          	srl	s11,s11,0x20
    8000347a:	05890613          	add	a2,s2,88
    8000347e:	86ee                	mv	a3,s11
    80003480:	963a                	add	a2,a2,a4
    80003482:	85d2                	mv	a1,s4
    80003484:	855e                	mv	a0,s7
    80003486:	d97fe0ef          	jal	8000221c <either_copyout>
    8000348a:	05850763          	beq	a0,s8,800034d8 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000348e:	854a                	mv	a0,s2
    80003490:	f12ff0ef          	jal	80002ba2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003494:	013d09bb          	addw	s3,s10,s3
    80003498:	009d04bb          	addw	s1,s10,s1
    8000349c:	9a6e                	add	s4,s4,s11
    8000349e:	0559f763          	bgeu	s3,s5,800034ec <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    800034a2:	00a4d59b          	srlw	a1,s1,0xa
    800034a6:	855a                	mv	a0,s6
    800034a8:	977ff0ef          	jal	80002e1e <bmap>
    800034ac:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800034b0:	c5b1                	beqz	a1,800034fc <readi+0xd6>
    bp = bread(ip->dev, addr);
    800034b2:	000b2503          	lw	a0,0(s6)
    800034b6:	de4ff0ef          	jal	80002a9a <bread>
    800034ba:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800034bc:	3ff4f713          	and	a4,s1,1023
    800034c0:	40ec87bb          	subw	a5,s9,a4
    800034c4:	413a86bb          	subw	a3,s5,s3
    800034c8:	8d3e                	mv	s10,a5
    800034ca:	2781                	sext.w	a5,a5
    800034cc:	0006861b          	sext.w	a2,a3
    800034d0:	faf671e3          	bgeu	a2,a5,80003472 <readi+0x4c>
    800034d4:	8d36                	mv	s10,a3
    800034d6:	bf71                	j	80003472 <readi+0x4c>
      brelse(bp);
    800034d8:	854a                	mv	a0,s2
    800034da:	ec8ff0ef          	jal	80002ba2 <brelse>
      tot = -1;
    800034de:	59fd                	li	s3,-1
      break;
    800034e0:	6946                	ld	s2,80(sp)
    800034e2:	7c02                	ld	s8,32(sp)
    800034e4:	6ce2                	ld	s9,24(sp)
    800034e6:	6d42                	ld	s10,16(sp)
    800034e8:	6da2                	ld	s11,8(sp)
    800034ea:	a831                	j	80003506 <readi+0xe0>
    800034ec:	6946                	ld	s2,80(sp)
    800034ee:	7c02                	ld	s8,32(sp)
    800034f0:	6ce2                	ld	s9,24(sp)
    800034f2:	6d42                	ld	s10,16(sp)
    800034f4:	6da2                	ld	s11,8(sp)
    800034f6:	a801                	j	80003506 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800034f8:	89d6                	mv	s3,s5
    800034fa:	a031                	j	80003506 <readi+0xe0>
    800034fc:	6946                	ld	s2,80(sp)
    800034fe:	7c02                	ld	s8,32(sp)
    80003500:	6ce2                	ld	s9,24(sp)
    80003502:	6d42                	ld	s10,16(sp)
    80003504:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003506:	0009851b          	sext.w	a0,s3
    8000350a:	69a6                	ld	s3,72(sp)
}
    8000350c:	70a6                	ld	ra,104(sp)
    8000350e:	7406                	ld	s0,96(sp)
    80003510:	64e6                	ld	s1,88(sp)
    80003512:	6a06                	ld	s4,64(sp)
    80003514:	7ae2                	ld	s5,56(sp)
    80003516:	7b42                	ld	s6,48(sp)
    80003518:	7ba2                	ld	s7,40(sp)
    8000351a:	6165                	add	sp,sp,112
    8000351c:	8082                	ret
    return 0;
    8000351e:	4501                	li	a0,0
}
    80003520:	8082                	ret

0000000080003522 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003522:	457c                	lw	a5,76(a0)
    80003524:	10d7e063          	bltu	a5,a3,80003624 <writei+0x102>
{
    80003528:	7159                	add	sp,sp,-112
    8000352a:	f486                	sd	ra,104(sp)
    8000352c:	f0a2                	sd	s0,96(sp)
    8000352e:	e8ca                	sd	s2,80(sp)
    80003530:	e0d2                	sd	s4,64(sp)
    80003532:	fc56                	sd	s5,56(sp)
    80003534:	f85a                	sd	s6,48(sp)
    80003536:	f45e                	sd	s7,40(sp)
    80003538:	1880                	add	s0,sp,112
    8000353a:	8aaa                	mv	s5,a0
    8000353c:	8bae                	mv	s7,a1
    8000353e:	8a32                	mv	s4,a2
    80003540:	8936                	mv	s2,a3
    80003542:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003544:	00e687bb          	addw	a5,a3,a4
    80003548:	0ed7e063          	bltu	a5,a3,80003628 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000354c:	00043737          	lui	a4,0x43
    80003550:	0cf76e63          	bltu	a4,a5,8000362c <writei+0x10a>
    80003554:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003556:	0a0b0f63          	beqz	s6,80003614 <writei+0xf2>
    8000355a:	eca6                	sd	s1,88(sp)
    8000355c:	f062                	sd	s8,32(sp)
    8000355e:	ec66                	sd	s9,24(sp)
    80003560:	e86a                	sd	s10,16(sp)
    80003562:	e46e                	sd	s11,8(sp)
    80003564:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003566:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000356a:	5c7d                	li	s8,-1
    8000356c:	a825                	j	800035a4 <writei+0x82>
    8000356e:	020d1d93          	sll	s11,s10,0x20
    80003572:	020ddd93          	srl	s11,s11,0x20
    80003576:	05848513          	add	a0,s1,88
    8000357a:	86ee                	mv	a3,s11
    8000357c:	8652                	mv	a2,s4
    8000357e:	85de                	mv	a1,s7
    80003580:	953a                	add	a0,a0,a4
    80003582:	ce5fe0ef          	jal	80002266 <either_copyin>
    80003586:	05850a63          	beq	a0,s8,800035da <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000358a:	8526                	mv	a0,s1
    8000358c:	660000ef          	jal	80003bec <log_write>
    brelse(bp);
    80003590:	8526                	mv	a0,s1
    80003592:	e10ff0ef          	jal	80002ba2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003596:	013d09bb          	addw	s3,s10,s3
    8000359a:	012d093b          	addw	s2,s10,s2
    8000359e:	9a6e                	add	s4,s4,s11
    800035a0:	0569f063          	bgeu	s3,s6,800035e0 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800035a4:	00a9559b          	srlw	a1,s2,0xa
    800035a8:	8556                	mv	a0,s5
    800035aa:	875ff0ef          	jal	80002e1e <bmap>
    800035ae:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800035b2:	c59d                	beqz	a1,800035e0 <writei+0xbe>
    bp = bread(ip->dev, addr);
    800035b4:	000aa503          	lw	a0,0(s5)
    800035b8:	ce2ff0ef          	jal	80002a9a <bread>
    800035bc:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800035be:	3ff97713          	and	a4,s2,1023
    800035c2:	40ec87bb          	subw	a5,s9,a4
    800035c6:	413b06bb          	subw	a3,s6,s3
    800035ca:	8d3e                	mv	s10,a5
    800035cc:	2781                	sext.w	a5,a5
    800035ce:	0006861b          	sext.w	a2,a3
    800035d2:	f8f67ee3          	bgeu	a2,a5,8000356e <writei+0x4c>
    800035d6:	8d36                	mv	s10,a3
    800035d8:	bf59                	j	8000356e <writei+0x4c>
      brelse(bp);
    800035da:	8526                	mv	a0,s1
    800035dc:	dc6ff0ef          	jal	80002ba2 <brelse>
  }

  if(off > ip->size)
    800035e0:	04caa783          	lw	a5,76(s5)
    800035e4:	0327fa63          	bgeu	a5,s2,80003618 <writei+0xf6>
    ip->size = off;
    800035e8:	052aa623          	sw	s2,76(s5)
    800035ec:	64e6                	ld	s1,88(sp)
    800035ee:	7c02                	ld	s8,32(sp)
    800035f0:	6ce2                	ld	s9,24(sp)
    800035f2:	6d42                	ld	s10,16(sp)
    800035f4:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800035f6:	8556                	mv	a0,s5
    800035f8:	b27ff0ef          	jal	8000311e <iupdate>

  return tot;
    800035fc:	0009851b          	sext.w	a0,s3
    80003600:	69a6                	ld	s3,72(sp)
}
    80003602:	70a6                	ld	ra,104(sp)
    80003604:	7406                	ld	s0,96(sp)
    80003606:	6946                	ld	s2,80(sp)
    80003608:	6a06                	ld	s4,64(sp)
    8000360a:	7ae2                	ld	s5,56(sp)
    8000360c:	7b42                	ld	s6,48(sp)
    8000360e:	7ba2                	ld	s7,40(sp)
    80003610:	6165                	add	sp,sp,112
    80003612:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003614:	89da                	mv	s3,s6
    80003616:	b7c5                	j	800035f6 <writei+0xd4>
    80003618:	64e6                	ld	s1,88(sp)
    8000361a:	7c02                	ld	s8,32(sp)
    8000361c:	6ce2                	ld	s9,24(sp)
    8000361e:	6d42                	ld	s10,16(sp)
    80003620:	6da2                	ld	s11,8(sp)
    80003622:	bfd1                	j	800035f6 <writei+0xd4>
    return -1;
    80003624:	557d                	li	a0,-1
}
    80003626:	8082                	ret
    return -1;
    80003628:	557d                	li	a0,-1
    8000362a:	bfe1                	j	80003602 <writei+0xe0>
    return -1;
    8000362c:	557d                	li	a0,-1
    8000362e:	bfd1                	j	80003602 <writei+0xe0>

0000000080003630 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003630:	1141                	add	sp,sp,-16
    80003632:	e406                	sd	ra,8(sp)
    80003634:	e022                	sd	s0,0(sp)
    80003636:	0800                	add	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003638:	4639                	li	a2,14
    8000363a:	f5afd0ef          	jal	80000d94 <strncmp>
}
    8000363e:	60a2                	ld	ra,8(sp)
    80003640:	6402                	ld	s0,0(sp)
    80003642:	0141                	add	sp,sp,16
    80003644:	8082                	ret

0000000080003646 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003646:	7139                	add	sp,sp,-64
    80003648:	fc06                	sd	ra,56(sp)
    8000364a:	f822                	sd	s0,48(sp)
    8000364c:	f426                	sd	s1,40(sp)
    8000364e:	f04a                	sd	s2,32(sp)
    80003650:	ec4e                	sd	s3,24(sp)
    80003652:	e852                	sd	s4,16(sp)
    80003654:	0080                	add	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003656:	04451703          	lh	a4,68(a0)
    8000365a:	4785                	li	a5,1
    8000365c:	00f71a63          	bne	a4,a5,80003670 <dirlookup+0x2a>
    80003660:	892a                	mv	s2,a0
    80003662:	89ae                	mv	s3,a1
    80003664:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003666:	457c                	lw	a5,76(a0)
    80003668:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000366a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000366c:	e39d                	bnez	a5,80003692 <dirlookup+0x4c>
    8000366e:	a095                	j	800036d2 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003670:	00004517          	auipc	a0,0x4
    80003674:	e9050513          	add	a0,a0,-368 # 80007500 <etext+0x500>
    80003678:	91cfd0ef          	jal	80000794 <panic>
      panic("dirlookup read");
    8000367c:	00004517          	auipc	a0,0x4
    80003680:	e9c50513          	add	a0,a0,-356 # 80007518 <etext+0x518>
    80003684:	910fd0ef          	jal	80000794 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003688:	24c1                	addw	s1,s1,16
    8000368a:	04c92783          	lw	a5,76(s2)
    8000368e:	04f4f163          	bgeu	s1,a5,800036d0 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003692:	4741                	li	a4,16
    80003694:	86a6                	mv	a3,s1
    80003696:	fc040613          	add	a2,s0,-64
    8000369a:	4581                	li	a1,0
    8000369c:	854a                	mv	a0,s2
    8000369e:	d89ff0ef          	jal	80003426 <readi>
    800036a2:	47c1                	li	a5,16
    800036a4:	fcf51ce3          	bne	a0,a5,8000367c <dirlookup+0x36>
    if(de.inum == 0)
    800036a8:	fc045783          	lhu	a5,-64(s0)
    800036ac:	dff1                	beqz	a5,80003688 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    800036ae:	fc240593          	add	a1,s0,-62
    800036b2:	854e                	mv	a0,s3
    800036b4:	f7dff0ef          	jal	80003630 <namecmp>
    800036b8:	f961                	bnez	a0,80003688 <dirlookup+0x42>
      if(poff)
    800036ba:	000a0463          	beqz	s4,800036c2 <dirlookup+0x7c>
        *poff = off;
    800036be:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800036c2:	fc045583          	lhu	a1,-64(s0)
    800036c6:	00092503          	lw	a0,0(s2)
    800036ca:	829ff0ef          	jal	80002ef2 <iget>
    800036ce:	a011                	j	800036d2 <dirlookup+0x8c>
  return 0;
    800036d0:	4501                	li	a0,0
}
    800036d2:	70e2                	ld	ra,56(sp)
    800036d4:	7442                	ld	s0,48(sp)
    800036d6:	74a2                	ld	s1,40(sp)
    800036d8:	7902                	ld	s2,32(sp)
    800036da:	69e2                	ld	s3,24(sp)
    800036dc:	6a42                	ld	s4,16(sp)
    800036de:	6121                	add	sp,sp,64
    800036e0:	8082                	ret

00000000800036e2 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800036e2:	711d                	add	sp,sp,-96
    800036e4:	ec86                	sd	ra,88(sp)
    800036e6:	e8a2                	sd	s0,80(sp)
    800036e8:	e4a6                	sd	s1,72(sp)
    800036ea:	e0ca                	sd	s2,64(sp)
    800036ec:	fc4e                	sd	s3,56(sp)
    800036ee:	f852                	sd	s4,48(sp)
    800036f0:	f456                	sd	s5,40(sp)
    800036f2:	f05a                	sd	s6,32(sp)
    800036f4:	ec5e                	sd	s7,24(sp)
    800036f6:	e862                	sd	s8,16(sp)
    800036f8:	e466                	sd	s9,8(sp)
    800036fa:	1080                	add	s0,sp,96
    800036fc:	84aa                	mv	s1,a0
    800036fe:	8b2e                	mv	s6,a1
    80003700:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003702:	00054703          	lbu	a4,0(a0)
    80003706:	02f00793          	li	a5,47
    8000370a:	00f70e63          	beq	a4,a5,80003726 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000370e:	9e4fe0ef          	jal	800018f2 <myproc>
    80003712:	15053503          	ld	a0,336(a0)
    80003716:	a87ff0ef          	jal	8000319c <idup>
    8000371a:	8a2a                	mv	s4,a0
  while(*path == '/')
    8000371c:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003720:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003722:	4b85                	li	s7,1
    80003724:	a871                	j	800037c0 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80003726:	4585                	li	a1,1
    80003728:	4505                	li	a0,1
    8000372a:	fc8ff0ef          	jal	80002ef2 <iget>
    8000372e:	8a2a                	mv	s4,a0
    80003730:	b7f5                	j	8000371c <namex+0x3a>
      iunlockput(ip);
    80003732:	8552                	mv	a0,s4
    80003734:	ca9ff0ef          	jal	800033dc <iunlockput>
      return 0;
    80003738:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    8000373a:	8552                	mv	a0,s4
    8000373c:	60e6                	ld	ra,88(sp)
    8000373e:	6446                	ld	s0,80(sp)
    80003740:	64a6                	ld	s1,72(sp)
    80003742:	6906                	ld	s2,64(sp)
    80003744:	79e2                	ld	s3,56(sp)
    80003746:	7a42                	ld	s4,48(sp)
    80003748:	7aa2                	ld	s5,40(sp)
    8000374a:	7b02                	ld	s6,32(sp)
    8000374c:	6be2                	ld	s7,24(sp)
    8000374e:	6c42                	ld	s8,16(sp)
    80003750:	6ca2                	ld	s9,8(sp)
    80003752:	6125                	add	sp,sp,96
    80003754:	8082                	ret
      iunlock(ip);
    80003756:	8552                	mv	a0,s4
    80003758:	b29ff0ef          	jal	80003280 <iunlock>
      return ip;
    8000375c:	bff9                	j	8000373a <namex+0x58>
      iunlockput(ip);
    8000375e:	8552                	mv	a0,s4
    80003760:	c7dff0ef          	jal	800033dc <iunlockput>
      return 0;
    80003764:	8a4e                	mv	s4,s3
    80003766:	bfd1                	j	8000373a <namex+0x58>
  len = path - s;
    80003768:	40998633          	sub	a2,s3,s1
    8000376c:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003770:	099c5063          	bge	s8,s9,800037f0 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80003774:	4639                	li	a2,14
    80003776:	85a6                	mv	a1,s1
    80003778:	8556                	mv	a0,s5
    8000377a:	daafd0ef          	jal	80000d24 <memmove>
    8000377e:	84ce                	mv	s1,s3
  while(*path == '/')
    80003780:	0004c783          	lbu	a5,0(s1)
    80003784:	01279763          	bne	a5,s2,80003792 <namex+0xb0>
    path++;
    80003788:	0485                	add	s1,s1,1
  while(*path == '/')
    8000378a:	0004c783          	lbu	a5,0(s1)
    8000378e:	ff278de3          	beq	a5,s2,80003788 <namex+0xa6>
    ilock(ip);
    80003792:	8552                	mv	a0,s4
    80003794:	a3fff0ef          	jal	800031d2 <ilock>
    if(ip->type != T_DIR){
    80003798:	044a1783          	lh	a5,68(s4)
    8000379c:	f9779be3          	bne	a5,s7,80003732 <namex+0x50>
    if(nameiparent && *path == '\0'){
    800037a0:	000b0563          	beqz	s6,800037aa <namex+0xc8>
    800037a4:	0004c783          	lbu	a5,0(s1)
    800037a8:	d7dd                	beqz	a5,80003756 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    800037aa:	4601                	li	a2,0
    800037ac:	85d6                	mv	a1,s5
    800037ae:	8552                	mv	a0,s4
    800037b0:	e97ff0ef          	jal	80003646 <dirlookup>
    800037b4:	89aa                	mv	s3,a0
    800037b6:	d545                	beqz	a0,8000375e <namex+0x7c>
    iunlockput(ip);
    800037b8:	8552                	mv	a0,s4
    800037ba:	c23ff0ef          	jal	800033dc <iunlockput>
    ip = next;
    800037be:	8a4e                	mv	s4,s3
  while(*path == '/')
    800037c0:	0004c783          	lbu	a5,0(s1)
    800037c4:	01279763          	bne	a5,s2,800037d2 <namex+0xf0>
    path++;
    800037c8:	0485                	add	s1,s1,1
  while(*path == '/')
    800037ca:	0004c783          	lbu	a5,0(s1)
    800037ce:	ff278de3          	beq	a5,s2,800037c8 <namex+0xe6>
  if(*path == 0)
    800037d2:	cb8d                	beqz	a5,80003804 <namex+0x122>
  while(*path != '/' && *path != 0)
    800037d4:	0004c783          	lbu	a5,0(s1)
    800037d8:	89a6                	mv	s3,s1
  len = path - s;
    800037da:	4c81                	li	s9,0
    800037dc:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    800037de:	01278963          	beq	a5,s2,800037f0 <namex+0x10e>
    800037e2:	d3d9                	beqz	a5,80003768 <namex+0x86>
    path++;
    800037e4:	0985                	add	s3,s3,1
  while(*path != '/' && *path != 0)
    800037e6:	0009c783          	lbu	a5,0(s3)
    800037ea:	ff279ce3          	bne	a5,s2,800037e2 <namex+0x100>
    800037ee:	bfad                	j	80003768 <namex+0x86>
    memmove(name, s, len);
    800037f0:	2601                	sext.w	a2,a2
    800037f2:	85a6                	mv	a1,s1
    800037f4:	8556                	mv	a0,s5
    800037f6:	d2efd0ef          	jal	80000d24 <memmove>
    name[len] = 0;
    800037fa:	9cd6                	add	s9,s9,s5
    800037fc:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003800:	84ce                	mv	s1,s3
    80003802:	bfbd                	j	80003780 <namex+0x9e>
  if(nameiparent){
    80003804:	f20b0be3          	beqz	s6,8000373a <namex+0x58>
    iput(ip);
    80003808:	8552                	mv	a0,s4
    8000380a:	b4bff0ef          	jal	80003354 <iput>
    return 0;
    8000380e:	4a01                	li	s4,0
    80003810:	b72d                	j	8000373a <namex+0x58>

0000000080003812 <dirlink>:
{
    80003812:	7139                	add	sp,sp,-64
    80003814:	fc06                	sd	ra,56(sp)
    80003816:	f822                	sd	s0,48(sp)
    80003818:	f04a                	sd	s2,32(sp)
    8000381a:	ec4e                	sd	s3,24(sp)
    8000381c:	e852                	sd	s4,16(sp)
    8000381e:	0080                	add	s0,sp,64
    80003820:	892a                	mv	s2,a0
    80003822:	8a2e                	mv	s4,a1
    80003824:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003826:	4601                	li	a2,0
    80003828:	e1fff0ef          	jal	80003646 <dirlookup>
    8000382c:	e535                	bnez	a0,80003898 <dirlink+0x86>
    8000382e:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003830:	04c92483          	lw	s1,76(s2)
    80003834:	c48d                	beqz	s1,8000385e <dirlink+0x4c>
    80003836:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003838:	4741                	li	a4,16
    8000383a:	86a6                	mv	a3,s1
    8000383c:	fc040613          	add	a2,s0,-64
    80003840:	4581                	li	a1,0
    80003842:	854a                	mv	a0,s2
    80003844:	be3ff0ef          	jal	80003426 <readi>
    80003848:	47c1                	li	a5,16
    8000384a:	04f51b63          	bne	a0,a5,800038a0 <dirlink+0x8e>
    if(de.inum == 0)
    8000384e:	fc045783          	lhu	a5,-64(s0)
    80003852:	c791                	beqz	a5,8000385e <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003854:	24c1                	addw	s1,s1,16
    80003856:	04c92783          	lw	a5,76(s2)
    8000385a:	fcf4efe3          	bltu	s1,a5,80003838 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    8000385e:	4639                	li	a2,14
    80003860:	85d2                	mv	a1,s4
    80003862:	fc240513          	add	a0,s0,-62
    80003866:	d64fd0ef          	jal	80000dca <strncpy>
  de.inum = inum;
    8000386a:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000386e:	4741                	li	a4,16
    80003870:	86a6                	mv	a3,s1
    80003872:	fc040613          	add	a2,s0,-64
    80003876:	4581                	li	a1,0
    80003878:	854a                	mv	a0,s2
    8000387a:	ca9ff0ef          	jal	80003522 <writei>
    8000387e:	1541                	add	a0,a0,-16
    80003880:	00a03533          	snez	a0,a0
    80003884:	40a00533          	neg	a0,a0
    80003888:	74a2                	ld	s1,40(sp)
}
    8000388a:	70e2                	ld	ra,56(sp)
    8000388c:	7442                	ld	s0,48(sp)
    8000388e:	7902                	ld	s2,32(sp)
    80003890:	69e2                	ld	s3,24(sp)
    80003892:	6a42                	ld	s4,16(sp)
    80003894:	6121                	add	sp,sp,64
    80003896:	8082                	ret
    iput(ip);
    80003898:	abdff0ef          	jal	80003354 <iput>
    return -1;
    8000389c:	557d                	li	a0,-1
    8000389e:	b7f5                	j	8000388a <dirlink+0x78>
      panic("dirlink read");
    800038a0:	00004517          	auipc	a0,0x4
    800038a4:	c8850513          	add	a0,a0,-888 # 80007528 <etext+0x528>
    800038a8:	eedfc0ef          	jal	80000794 <panic>

00000000800038ac <namei>:

struct inode*
namei(char *path)
{
    800038ac:	1101                	add	sp,sp,-32
    800038ae:	ec06                	sd	ra,24(sp)
    800038b0:	e822                	sd	s0,16(sp)
    800038b2:	1000                	add	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800038b4:	fe040613          	add	a2,s0,-32
    800038b8:	4581                	li	a1,0
    800038ba:	e29ff0ef          	jal	800036e2 <namex>
}
    800038be:	60e2                	ld	ra,24(sp)
    800038c0:	6442                	ld	s0,16(sp)
    800038c2:	6105                	add	sp,sp,32
    800038c4:	8082                	ret

00000000800038c6 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800038c6:	1141                	add	sp,sp,-16
    800038c8:	e406                	sd	ra,8(sp)
    800038ca:	e022                	sd	s0,0(sp)
    800038cc:	0800                	add	s0,sp,16
    800038ce:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800038d0:	4585                	li	a1,1
    800038d2:	e11ff0ef          	jal	800036e2 <namex>
}
    800038d6:	60a2                	ld	ra,8(sp)
    800038d8:	6402                	ld	s0,0(sp)
    800038da:	0141                	add	sp,sp,16
    800038dc:	8082                	ret

00000000800038de <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800038de:	1101                	add	sp,sp,-32
    800038e0:	ec06                	sd	ra,24(sp)
    800038e2:	e822                	sd	s0,16(sp)
    800038e4:	e426                	sd	s1,8(sp)
    800038e6:	e04a                	sd	s2,0(sp)
    800038e8:	1000                	add	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800038ea:	0001c917          	auipc	s2,0x1c
    800038ee:	11690913          	add	s2,s2,278 # 8001fa00 <log>
    800038f2:	01892583          	lw	a1,24(s2)
    800038f6:	02892503          	lw	a0,40(s2)
    800038fa:	9a0ff0ef          	jal	80002a9a <bread>
    800038fe:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003900:	02c92603          	lw	a2,44(s2)
    80003904:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003906:	00c05f63          	blez	a2,80003924 <write_head+0x46>
    8000390a:	0001c717          	auipc	a4,0x1c
    8000390e:	12670713          	add	a4,a4,294 # 8001fa30 <log+0x30>
    80003912:	87aa                	mv	a5,a0
    80003914:	060a                	sll	a2,a2,0x2
    80003916:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003918:	4314                	lw	a3,0(a4)
    8000391a:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    8000391c:	0711                	add	a4,a4,4
    8000391e:	0791                	add	a5,a5,4
    80003920:	fec79ce3          	bne	a5,a2,80003918 <write_head+0x3a>
  }
  bwrite(buf);
    80003924:	8526                	mv	a0,s1
    80003926:	a4aff0ef          	jal	80002b70 <bwrite>
  brelse(buf);
    8000392a:	8526                	mv	a0,s1
    8000392c:	a76ff0ef          	jal	80002ba2 <brelse>
}
    80003930:	60e2                	ld	ra,24(sp)
    80003932:	6442                	ld	s0,16(sp)
    80003934:	64a2                	ld	s1,8(sp)
    80003936:	6902                	ld	s2,0(sp)
    80003938:	6105                	add	sp,sp,32
    8000393a:	8082                	ret

000000008000393c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000393c:	0001c797          	auipc	a5,0x1c
    80003940:	0f07a783          	lw	a5,240(a5) # 8001fa2c <log+0x2c>
    80003944:	08f05f63          	blez	a5,800039e2 <install_trans+0xa6>
{
    80003948:	7139                	add	sp,sp,-64
    8000394a:	fc06                	sd	ra,56(sp)
    8000394c:	f822                	sd	s0,48(sp)
    8000394e:	f426                	sd	s1,40(sp)
    80003950:	f04a                	sd	s2,32(sp)
    80003952:	ec4e                	sd	s3,24(sp)
    80003954:	e852                	sd	s4,16(sp)
    80003956:	e456                	sd	s5,8(sp)
    80003958:	e05a                	sd	s6,0(sp)
    8000395a:	0080                	add	s0,sp,64
    8000395c:	8b2a                	mv	s6,a0
    8000395e:	0001ca97          	auipc	s5,0x1c
    80003962:	0d2a8a93          	add	s5,s5,210 # 8001fa30 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003966:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003968:	0001c997          	auipc	s3,0x1c
    8000396c:	09898993          	add	s3,s3,152 # 8001fa00 <log>
    80003970:	a829                	j	8000398a <install_trans+0x4e>
    brelse(lbuf);
    80003972:	854a                	mv	a0,s2
    80003974:	a2eff0ef          	jal	80002ba2 <brelse>
    brelse(dbuf);
    80003978:	8526                	mv	a0,s1
    8000397a:	a28ff0ef          	jal	80002ba2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000397e:	2a05                	addw	s4,s4,1
    80003980:	0a91                	add	s5,s5,4
    80003982:	02c9a783          	lw	a5,44(s3)
    80003986:	04fa5463          	bge	s4,a5,800039ce <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000398a:	0189a583          	lw	a1,24(s3)
    8000398e:	014585bb          	addw	a1,a1,s4
    80003992:	2585                	addw	a1,a1,1
    80003994:	0289a503          	lw	a0,40(s3)
    80003998:	902ff0ef          	jal	80002a9a <bread>
    8000399c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000399e:	000aa583          	lw	a1,0(s5)
    800039a2:	0289a503          	lw	a0,40(s3)
    800039a6:	8f4ff0ef          	jal	80002a9a <bread>
    800039aa:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800039ac:	40000613          	li	a2,1024
    800039b0:	05890593          	add	a1,s2,88
    800039b4:	05850513          	add	a0,a0,88
    800039b8:	b6cfd0ef          	jal	80000d24 <memmove>
    bwrite(dbuf);  // write dst to disk
    800039bc:	8526                	mv	a0,s1
    800039be:	9b2ff0ef          	jal	80002b70 <bwrite>
    if(recovering == 0)
    800039c2:	fa0b18e3          	bnez	s6,80003972 <install_trans+0x36>
      bunpin(dbuf);
    800039c6:	8526                	mv	a0,s1
    800039c8:	a96ff0ef          	jal	80002c5e <bunpin>
    800039cc:	b75d                	j	80003972 <install_trans+0x36>
}
    800039ce:	70e2                	ld	ra,56(sp)
    800039d0:	7442                	ld	s0,48(sp)
    800039d2:	74a2                	ld	s1,40(sp)
    800039d4:	7902                	ld	s2,32(sp)
    800039d6:	69e2                	ld	s3,24(sp)
    800039d8:	6a42                	ld	s4,16(sp)
    800039da:	6aa2                	ld	s5,8(sp)
    800039dc:	6b02                	ld	s6,0(sp)
    800039de:	6121                	add	sp,sp,64
    800039e0:	8082                	ret
    800039e2:	8082                	ret

00000000800039e4 <initlog>:
{
    800039e4:	7179                	add	sp,sp,-48
    800039e6:	f406                	sd	ra,40(sp)
    800039e8:	f022                	sd	s0,32(sp)
    800039ea:	ec26                	sd	s1,24(sp)
    800039ec:	e84a                	sd	s2,16(sp)
    800039ee:	e44e                	sd	s3,8(sp)
    800039f0:	1800                	add	s0,sp,48
    800039f2:	892a                	mv	s2,a0
    800039f4:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800039f6:	0001c497          	auipc	s1,0x1c
    800039fa:	00a48493          	add	s1,s1,10 # 8001fa00 <log>
    800039fe:	00004597          	auipc	a1,0x4
    80003a02:	b3a58593          	add	a1,a1,-1222 # 80007538 <etext+0x538>
    80003a06:	8526                	mv	a0,s1
    80003a08:	96cfd0ef          	jal	80000b74 <initlock>
  log.start = sb->logstart;
    80003a0c:	0149a583          	lw	a1,20(s3)
    80003a10:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003a12:	0109a783          	lw	a5,16(s3)
    80003a16:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003a18:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003a1c:	854a                	mv	a0,s2
    80003a1e:	87cff0ef          	jal	80002a9a <bread>
  log.lh.n = lh->n;
    80003a22:	4d30                	lw	a2,88(a0)
    80003a24:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003a26:	00c05f63          	blez	a2,80003a44 <initlog+0x60>
    80003a2a:	87aa                	mv	a5,a0
    80003a2c:	0001c717          	auipc	a4,0x1c
    80003a30:	00470713          	add	a4,a4,4 # 8001fa30 <log+0x30>
    80003a34:	060a                	sll	a2,a2,0x2
    80003a36:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003a38:	4ff4                	lw	a3,92(a5)
    80003a3a:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003a3c:	0791                	add	a5,a5,4
    80003a3e:	0711                	add	a4,a4,4
    80003a40:	fec79ce3          	bne	a5,a2,80003a38 <initlog+0x54>
  brelse(buf);
    80003a44:	95eff0ef          	jal	80002ba2 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003a48:	4505                	li	a0,1
    80003a4a:	ef3ff0ef          	jal	8000393c <install_trans>
  log.lh.n = 0;
    80003a4e:	0001c797          	auipc	a5,0x1c
    80003a52:	fc07af23          	sw	zero,-34(a5) # 8001fa2c <log+0x2c>
  write_head(); // clear the log
    80003a56:	e89ff0ef          	jal	800038de <write_head>
}
    80003a5a:	70a2                	ld	ra,40(sp)
    80003a5c:	7402                	ld	s0,32(sp)
    80003a5e:	64e2                	ld	s1,24(sp)
    80003a60:	6942                	ld	s2,16(sp)
    80003a62:	69a2                	ld	s3,8(sp)
    80003a64:	6145                	add	sp,sp,48
    80003a66:	8082                	ret

0000000080003a68 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003a68:	1101                	add	sp,sp,-32
    80003a6a:	ec06                	sd	ra,24(sp)
    80003a6c:	e822                	sd	s0,16(sp)
    80003a6e:	e426                	sd	s1,8(sp)
    80003a70:	e04a                	sd	s2,0(sp)
    80003a72:	1000                	add	s0,sp,32
  acquire(&log.lock);
    80003a74:	0001c517          	auipc	a0,0x1c
    80003a78:	f8c50513          	add	a0,a0,-116 # 8001fa00 <log>
    80003a7c:	978fd0ef          	jal	80000bf4 <acquire>
  while(1){
    if(log.committing){
    80003a80:	0001c497          	auipc	s1,0x1c
    80003a84:	f8048493          	add	s1,s1,-128 # 8001fa00 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003a88:	4979                	li	s2,30
    80003a8a:	a029                	j	80003a94 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003a8c:	85a6                	mv	a1,s1
    80003a8e:	8526                	mv	a0,s1
    80003a90:	c30fe0ef          	jal	80001ec0 <sleep>
    if(log.committing){
    80003a94:	50dc                	lw	a5,36(s1)
    80003a96:	fbfd                	bnez	a5,80003a8c <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003a98:	5098                	lw	a4,32(s1)
    80003a9a:	2705                	addw	a4,a4,1
    80003a9c:	0027179b          	sllw	a5,a4,0x2
    80003aa0:	9fb9                	addw	a5,a5,a4
    80003aa2:	0017979b          	sllw	a5,a5,0x1
    80003aa6:	54d4                	lw	a3,44(s1)
    80003aa8:	9fb5                	addw	a5,a5,a3
    80003aaa:	00f95763          	bge	s2,a5,80003ab8 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003aae:	85a6                	mv	a1,s1
    80003ab0:	8526                	mv	a0,s1
    80003ab2:	c0efe0ef          	jal	80001ec0 <sleep>
    80003ab6:	bff9                	j	80003a94 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003ab8:	0001c517          	auipc	a0,0x1c
    80003abc:	f4850513          	add	a0,a0,-184 # 8001fa00 <log>
    80003ac0:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80003ac2:	9cafd0ef          	jal	80000c8c <release>
      break;
    }
  }
}
    80003ac6:	60e2                	ld	ra,24(sp)
    80003ac8:	6442                	ld	s0,16(sp)
    80003aca:	64a2                	ld	s1,8(sp)
    80003acc:	6902                	ld	s2,0(sp)
    80003ace:	6105                	add	sp,sp,32
    80003ad0:	8082                	ret

0000000080003ad2 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003ad2:	7139                	add	sp,sp,-64
    80003ad4:	fc06                	sd	ra,56(sp)
    80003ad6:	f822                	sd	s0,48(sp)
    80003ad8:	f426                	sd	s1,40(sp)
    80003ada:	f04a                	sd	s2,32(sp)
    80003adc:	0080                	add	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003ade:	0001c497          	auipc	s1,0x1c
    80003ae2:	f2248493          	add	s1,s1,-222 # 8001fa00 <log>
    80003ae6:	8526                	mv	a0,s1
    80003ae8:	90cfd0ef          	jal	80000bf4 <acquire>
  log.outstanding -= 1;
    80003aec:	509c                	lw	a5,32(s1)
    80003aee:	37fd                	addw	a5,a5,-1
    80003af0:	0007891b          	sext.w	s2,a5
    80003af4:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003af6:	50dc                	lw	a5,36(s1)
    80003af8:	ef9d                	bnez	a5,80003b36 <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003afa:	04091763          	bnez	s2,80003b48 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003afe:	0001c497          	auipc	s1,0x1c
    80003b02:	f0248493          	add	s1,s1,-254 # 8001fa00 <log>
    80003b06:	4785                	li	a5,1
    80003b08:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003b0a:	8526                	mv	a0,s1
    80003b0c:	980fd0ef          	jal	80000c8c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003b10:	54dc                	lw	a5,44(s1)
    80003b12:	04f04b63          	bgtz	a5,80003b68 <end_op+0x96>
    acquire(&log.lock);
    80003b16:	0001c497          	auipc	s1,0x1c
    80003b1a:	eea48493          	add	s1,s1,-278 # 8001fa00 <log>
    80003b1e:	8526                	mv	a0,s1
    80003b20:	8d4fd0ef          	jal	80000bf4 <acquire>
    log.committing = 0;
    80003b24:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003b28:	8526                	mv	a0,s1
    80003b2a:	be2fe0ef          	jal	80001f0c <wakeup>
    release(&log.lock);
    80003b2e:	8526                	mv	a0,s1
    80003b30:	95cfd0ef          	jal	80000c8c <release>
}
    80003b34:	a025                	j	80003b5c <end_op+0x8a>
    80003b36:	ec4e                	sd	s3,24(sp)
    80003b38:	e852                	sd	s4,16(sp)
    80003b3a:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003b3c:	00004517          	auipc	a0,0x4
    80003b40:	a0450513          	add	a0,a0,-1532 # 80007540 <etext+0x540>
    80003b44:	c51fc0ef          	jal	80000794 <panic>
    wakeup(&log);
    80003b48:	0001c497          	auipc	s1,0x1c
    80003b4c:	eb848493          	add	s1,s1,-328 # 8001fa00 <log>
    80003b50:	8526                	mv	a0,s1
    80003b52:	bbafe0ef          	jal	80001f0c <wakeup>
  release(&log.lock);
    80003b56:	8526                	mv	a0,s1
    80003b58:	934fd0ef          	jal	80000c8c <release>
}
    80003b5c:	70e2                	ld	ra,56(sp)
    80003b5e:	7442                	ld	s0,48(sp)
    80003b60:	74a2                	ld	s1,40(sp)
    80003b62:	7902                	ld	s2,32(sp)
    80003b64:	6121                	add	sp,sp,64
    80003b66:	8082                	ret
    80003b68:	ec4e                	sd	s3,24(sp)
    80003b6a:	e852                	sd	s4,16(sp)
    80003b6c:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b6e:	0001ca97          	auipc	s5,0x1c
    80003b72:	ec2a8a93          	add	s5,s5,-318 # 8001fa30 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003b76:	0001ca17          	auipc	s4,0x1c
    80003b7a:	e8aa0a13          	add	s4,s4,-374 # 8001fa00 <log>
    80003b7e:	018a2583          	lw	a1,24(s4)
    80003b82:	012585bb          	addw	a1,a1,s2
    80003b86:	2585                	addw	a1,a1,1
    80003b88:	028a2503          	lw	a0,40(s4)
    80003b8c:	f0ffe0ef          	jal	80002a9a <bread>
    80003b90:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003b92:	000aa583          	lw	a1,0(s5)
    80003b96:	028a2503          	lw	a0,40(s4)
    80003b9a:	f01fe0ef          	jal	80002a9a <bread>
    80003b9e:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003ba0:	40000613          	li	a2,1024
    80003ba4:	05850593          	add	a1,a0,88
    80003ba8:	05848513          	add	a0,s1,88
    80003bac:	978fd0ef          	jal	80000d24 <memmove>
    bwrite(to);  // write the log
    80003bb0:	8526                	mv	a0,s1
    80003bb2:	fbffe0ef          	jal	80002b70 <bwrite>
    brelse(from);
    80003bb6:	854e                	mv	a0,s3
    80003bb8:	febfe0ef          	jal	80002ba2 <brelse>
    brelse(to);
    80003bbc:	8526                	mv	a0,s1
    80003bbe:	fe5fe0ef          	jal	80002ba2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003bc2:	2905                	addw	s2,s2,1
    80003bc4:	0a91                	add	s5,s5,4
    80003bc6:	02ca2783          	lw	a5,44(s4)
    80003bca:	faf94ae3          	blt	s2,a5,80003b7e <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003bce:	d11ff0ef          	jal	800038de <write_head>
    install_trans(0); // Now install writes to home locations
    80003bd2:	4501                	li	a0,0
    80003bd4:	d69ff0ef          	jal	8000393c <install_trans>
    log.lh.n = 0;
    80003bd8:	0001c797          	auipc	a5,0x1c
    80003bdc:	e407aa23          	sw	zero,-428(a5) # 8001fa2c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003be0:	cffff0ef          	jal	800038de <write_head>
    80003be4:	69e2                	ld	s3,24(sp)
    80003be6:	6a42                	ld	s4,16(sp)
    80003be8:	6aa2                	ld	s5,8(sp)
    80003bea:	b735                	j	80003b16 <end_op+0x44>

0000000080003bec <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003bec:	1101                	add	sp,sp,-32
    80003bee:	ec06                	sd	ra,24(sp)
    80003bf0:	e822                	sd	s0,16(sp)
    80003bf2:	e426                	sd	s1,8(sp)
    80003bf4:	e04a                	sd	s2,0(sp)
    80003bf6:	1000                	add	s0,sp,32
    80003bf8:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003bfa:	0001c917          	auipc	s2,0x1c
    80003bfe:	e0690913          	add	s2,s2,-506 # 8001fa00 <log>
    80003c02:	854a                	mv	a0,s2
    80003c04:	ff1fc0ef          	jal	80000bf4 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003c08:	02c92603          	lw	a2,44(s2)
    80003c0c:	47f5                	li	a5,29
    80003c0e:	06c7c363          	blt	a5,a2,80003c74 <log_write+0x88>
    80003c12:	0001c797          	auipc	a5,0x1c
    80003c16:	e0a7a783          	lw	a5,-502(a5) # 8001fa1c <log+0x1c>
    80003c1a:	37fd                	addw	a5,a5,-1
    80003c1c:	04f65c63          	bge	a2,a5,80003c74 <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003c20:	0001c797          	auipc	a5,0x1c
    80003c24:	e007a783          	lw	a5,-512(a5) # 8001fa20 <log+0x20>
    80003c28:	04f05c63          	blez	a5,80003c80 <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003c2c:	4781                	li	a5,0
    80003c2e:	04c05f63          	blez	a2,80003c8c <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003c32:	44cc                	lw	a1,12(s1)
    80003c34:	0001c717          	auipc	a4,0x1c
    80003c38:	dfc70713          	add	a4,a4,-516 # 8001fa30 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003c3c:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003c3e:	4314                	lw	a3,0(a4)
    80003c40:	04b68663          	beq	a3,a1,80003c8c <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    80003c44:	2785                	addw	a5,a5,1
    80003c46:	0711                	add	a4,a4,4
    80003c48:	fef61be3          	bne	a2,a5,80003c3e <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003c4c:	0621                	add	a2,a2,8
    80003c4e:	060a                	sll	a2,a2,0x2
    80003c50:	0001c797          	auipc	a5,0x1c
    80003c54:	db078793          	add	a5,a5,-592 # 8001fa00 <log>
    80003c58:	97b2                	add	a5,a5,a2
    80003c5a:	44d8                	lw	a4,12(s1)
    80003c5c:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003c5e:	8526                	mv	a0,s1
    80003c60:	fcbfe0ef          	jal	80002c2a <bpin>
    log.lh.n++;
    80003c64:	0001c717          	auipc	a4,0x1c
    80003c68:	d9c70713          	add	a4,a4,-612 # 8001fa00 <log>
    80003c6c:	575c                	lw	a5,44(a4)
    80003c6e:	2785                	addw	a5,a5,1
    80003c70:	d75c                	sw	a5,44(a4)
    80003c72:	a80d                	j	80003ca4 <log_write+0xb8>
    panic("too big a transaction");
    80003c74:	00004517          	auipc	a0,0x4
    80003c78:	8dc50513          	add	a0,a0,-1828 # 80007550 <etext+0x550>
    80003c7c:	b19fc0ef          	jal	80000794 <panic>
    panic("log_write outside of trans");
    80003c80:	00004517          	auipc	a0,0x4
    80003c84:	8e850513          	add	a0,a0,-1816 # 80007568 <etext+0x568>
    80003c88:	b0dfc0ef          	jal	80000794 <panic>
  log.lh.block[i] = b->blockno;
    80003c8c:	00878693          	add	a3,a5,8
    80003c90:	068a                	sll	a3,a3,0x2
    80003c92:	0001c717          	auipc	a4,0x1c
    80003c96:	d6e70713          	add	a4,a4,-658 # 8001fa00 <log>
    80003c9a:	9736                	add	a4,a4,a3
    80003c9c:	44d4                	lw	a3,12(s1)
    80003c9e:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003ca0:	faf60fe3          	beq	a2,a5,80003c5e <log_write+0x72>
  }
  release(&log.lock);
    80003ca4:	0001c517          	auipc	a0,0x1c
    80003ca8:	d5c50513          	add	a0,a0,-676 # 8001fa00 <log>
    80003cac:	fe1fc0ef          	jal	80000c8c <release>
}
    80003cb0:	60e2                	ld	ra,24(sp)
    80003cb2:	6442                	ld	s0,16(sp)
    80003cb4:	64a2                	ld	s1,8(sp)
    80003cb6:	6902                	ld	s2,0(sp)
    80003cb8:	6105                	add	sp,sp,32
    80003cba:	8082                	ret

0000000080003cbc <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003cbc:	1101                	add	sp,sp,-32
    80003cbe:	ec06                	sd	ra,24(sp)
    80003cc0:	e822                	sd	s0,16(sp)
    80003cc2:	e426                	sd	s1,8(sp)
    80003cc4:	e04a                	sd	s2,0(sp)
    80003cc6:	1000                	add	s0,sp,32
    80003cc8:	84aa                	mv	s1,a0
    80003cca:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003ccc:	00004597          	auipc	a1,0x4
    80003cd0:	8bc58593          	add	a1,a1,-1860 # 80007588 <etext+0x588>
    80003cd4:	0521                	add	a0,a0,8
    80003cd6:	e9ffc0ef          	jal	80000b74 <initlock>
  lk->name = name;
    80003cda:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003cde:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003ce2:	0204a423          	sw	zero,40(s1)
}
    80003ce6:	60e2                	ld	ra,24(sp)
    80003ce8:	6442                	ld	s0,16(sp)
    80003cea:	64a2                	ld	s1,8(sp)
    80003cec:	6902                	ld	s2,0(sp)
    80003cee:	6105                	add	sp,sp,32
    80003cf0:	8082                	ret

0000000080003cf2 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003cf2:	1101                	add	sp,sp,-32
    80003cf4:	ec06                	sd	ra,24(sp)
    80003cf6:	e822                	sd	s0,16(sp)
    80003cf8:	e426                	sd	s1,8(sp)
    80003cfa:	e04a                	sd	s2,0(sp)
    80003cfc:	1000                	add	s0,sp,32
    80003cfe:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003d00:	00850913          	add	s2,a0,8
    80003d04:	854a                	mv	a0,s2
    80003d06:	eeffc0ef          	jal	80000bf4 <acquire>
  while (lk->locked) {
    80003d0a:	409c                	lw	a5,0(s1)
    80003d0c:	c799                	beqz	a5,80003d1a <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003d0e:	85ca                	mv	a1,s2
    80003d10:	8526                	mv	a0,s1
    80003d12:	9aefe0ef          	jal	80001ec0 <sleep>
  while (lk->locked) {
    80003d16:	409c                	lw	a5,0(s1)
    80003d18:	fbfd                	bnez	a5,80003d0e <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003d1a:	4785                	li	a5,1
    80003d1c:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003d1e:	bd5fd0ef          	jal	800018f2 <myproc>
    80003d22:	591c                	lw	a5,48(a0)
    80003d24:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003d26:	854a                	mv	a0,s2
    80003d28:	f65fc0ef          	jal	80000c8c <release>
}
    80003d2c:	60e2                	ld	ra,24(sp)
    80003d2e:	6442                	ld	s0,16(sp)
    80003d30:	64a2                	ld	s1,8(sp)
    80003d32:	6902                	ld	s2,0(sp)
    80003d34:	6105                	add	sp,sp,32
    80003d36:	8082                	ret

0000000080003d38 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003d38:	1101                	add	sp,sp,-32
    80003d3a:	ec06                	sd	ra,24(sp)
    80003d3c:	e822                	sd	s0,16(sp)
    80003d3e:	e426                	sd	s1,8(sp)
    80003d40:	e04a                	sd	s2,0(sp)
    80003d42:	1000                	add	s0,sp,32
    80003d44:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003d46:	00850913          	add	s2,a0,8
    80003d4a:	854a                	mv	a0,s2
    80003d4c:	ea9fc0ef          	jal	80000bf4 <acquire>
  lk->locked = 0;
    80003d50:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003d54:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003d58:	8526                	mv	a0,s1
    80003d5a:	9b2fe0ef          	jal	80001f0c <wakeup>
  release(&lk->lk);
    80003d5e:	854a                	mv	a0,s2
    80003d60:	f2dfc0ef          	jal	80000c8c <release>
}
    80003d64:	60e2                	ld	ra,24(sp)
    80003d66:	6442                	ld	s0,16(sp)
    80003d68:	64a2                	ld	s1,8(sp)
    80003d6a:	6902                	ld	s2,0(sp)
    80003d6c:	6105                	add	sp,sp,32
    80003d6e:	8082                	ret

0000000080003d70 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003d70:	7179                	add	sp,sp,-48
    80003d72:	f406                	sd	ra,40(sp)
    80003d74:	f022                	sd	s0,32(sp)
    80003d76:	ec26                	sd	s1,24(sp)
    80003d78:	e84a                	sd	s2,16(sp)
    80003d7a:	1800                	add	s0,sp,48
    80003d7c:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003d7e:	00850913          	add	s2,a0,8
    80003d82:	854a                	mv	a0,s2
    80003d84:	e71fc0ef          	jal	80000bf4 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003d88:	409c                	lw	a5,0(s1)
    80003d8a:	ef81                	bnez	a5,80003da2 <holdingsleep+0x32>
    80003d8c:	4481                	li	s1,0
  release(&lk->lk);
    80003d8e:	854a                	mv	a0,s2
    80003d90:	efdfc0ef          	jal	80000c8c <release>
  return r;
}
    80003d94:	8526                	mv	a0,s1
    80003d96:	70a2                	ld	ra,40(sp)
    80003d98:	7402                	ld	s0,32(sp)
    80003d9a:	64e2                	ld	s1,24(sp)
    80003d9c:	6942                	ld	s2,16(sp)
    80003d9e:	6145                	add	sp,sp,48
    80003da0:	8082                	ret
    80003da2:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80003da4:	0284a983          	lw	s3,40(s1)
    80003da8:	b4bfd0ef          	jal	800018f2 <myproc>
    80003dac:	5904                	lw	s1,48(a0)
    80003dae:	413484b3          	sub	s1,s1,s3
    80003db2:	0014b493          	seqz	s1,s1
    80003db6:	69a2                	ld	s3,8(sp)
    80003db8:	bfd9                	j	80003d8e <holdingsleep+0x1e>

0000000080003dba <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003dba:	1141                	add	sp,sp,-16
    80003dbc:	e406                	sd	ra,8(sp)
    80003dbe:	e022                	sd	s0,0(sp)
    80003dc0:	0800                	add	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003dc2:	00003597          	auipc	a1,0x3
    80003dc6:	7d658593          	add	a1,a1,2006 # 80007598 <etext+0x598>
    80003dca:	0001c517          	auipc	a0,0x1c
    80003dce:	d7e50513          	add	a0,a0,-642 # 8001fb48 <ftable>
    80003dd2:	da3fc0ef          	jal	80000b74 <initlock>
}
    80003dd6:	60a2                	ld	ra,8(sp)
    80003dd8:	6402                	ld	s0,0(sp)
    80003dda:	0141                	add	sp,sp,16
    80003ddc:	8082                	ret

0000000080003dde <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003dde:	1101                	add	sp,sp,-32
    80003de0:	ec06                	sd	ra,24(sp)
    80003de2:	e822                	sd	s0,16(sp)
    80003de4:	e426                	sd	s1,8(sp)
    80003de6:	1000                	add	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003de8:	0001c517          	auipc	a0,0x1c
    80003dec:	d6050513          	add	a0,a0,-672 # 8001fb48 <ftable>
    80003df0:	e05fc0ef          	jal	80000bf4 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003df4:	0001c497          	auipc	s1,0x1c
    80003df8:	d6c48493          	add	s1,s1,-660 # 8001fb60 <ftable+0x18>
    80003dfc:	0001d717          	auipc	a4,0x1d
    80003e00:	d0470713          	add	a4,a4,-764 # 80020b00 <disk>
    if(f->ref == 0){
    80003e04:	40dc                	lw	a5,4(s1)
    80003e06:	cf89                	beqz	a5,80003e20 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003e08:	02848493          	add	s1,s1,40
    80003e0c:	fee49ce3          	bne	s1,a4,80003e04 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003e10:	0001c517          	auipc	a0,0x1c
    80003e14:	d3850513          	add	a0,a0,-712 # 8001fb48 <ftable>
    80003e18:	e75fc0ef          	jal	80000c8c <release>
  return 0;
    80003e1c:	4481                	li	s1,0
    80003e1e:	a809                	j	80003e30 <filealloc+0x52>
      f->ref = 1;
    80003e20:	4785                	li	a5,1
    80003e22:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003e24:	0001c517          	auipc	a0,0x1c
    80003e28:	d2450513          	add	a0,a0,-732 # 8001fb48 <ftable>
    80003e2c:	e61fc0ef          	jal	80000c8c <release>
}
    80003e30:	8526                	mv	a0,s1
    80003e32:	60e2                	ld	ra,24(sp)
    80003e34:	6442                	ld	s0,16(sp)
    80003e36:	64a2                	ld	s1,8(sp)
    80003e38:	6105                	add	sp,sp,32
    80003e3a:	8082                	ret

0000000080003e3c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003e3c:	1101                	add	sp,sp,-32
    80003e3e:	ec06                	sd	ra,24(sp)
    80003e40:	e822                	sd	s0,16(sp)
    80003e42:	e426                	sd	s1,8(sp)
    80003e44:	1000                	add	s0,sp,32
    80003e46:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003e48:	0001c517          	auipc	a0,0x1c
    80003e4c:	d0050513          	add	a0,a0,-768 # 8001fb48 <ftable>
    80003e50:	da5fc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    80003e54:	40dc                	lw	a5,4(s1)
    80003e56:	02f05063          	blez	a5,80003e76 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80003e5a:	2785                	addw	a5,a5,1
    80003e5c:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003e5e:	0001c517          	auipc	a0,0x1c
    80003e62:	cea50513          	add	a0,a0,-790 # 8001fb48 <ftable>
    80003e66:	e27fc0ef          	jal	80000c8c <release>
  return f;
}
    80003e6a:	8526                	mv	a0,s1
    80003e6c:	60e2                	ld	ra,24(sp)
    80003e6e:	6442                	ld	s0,16(sp)
    80003e70:	64a2                	ld	s1,8(sp)
    80003e72:	6105                	add	sp,sp,32
    80003e74:	8082                	ret
    panic("filedup");
    80003e76:	00003517          	auipc	a0,0x3
    80003e7a:	72a50513          	add	a0,a0,1834 # 800075a0 <etext+0x5a0>
    80003e7e:	917fc0ef          	jal	80000794 <panic>

0000000080003e82 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003e82:	7139                	add	sp,sp,-64
    80003e84:	fc06                	sd	ra,56(sp)
    80003e86:	f822                	sd	s0,48(sp)
    80003e88:	f426                	sd	s1,40(sp)
    80003e8a:	0080                	add	s0,sp,64
    80003e8c:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003e8e:	0001c517          	auipc	a0,0x1c
    80003e92:	cba50513          	add	a0,a0,-838 # 8001fb48 <ftable>
    80003e96:	d5ffc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    80003e9a:	40dc                	lw	a5,4(s1)
    80003e9c:	04f05a63          	blez	a5,80003ef0 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80003ea0:	37fd                	addw	a5,a5,-1
    80003ea2:	0007871b          	sext.w	a4,a5
    80003ea6:	c0dc                	sw	a5,4(s1)
    80003ea8:	04e04e63          	bgtz	a4,80003f04 <fileclose+0x82>
    80003eac:	f04a                	sd	s2,32(sp)
    80003eae:	ec4e                	sd	s3,24(sp)
    80003eb0:	e852                	sd	s4,16(sp)
    80003eb2:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80003eb4:	0004a903          	lw	s2,0(s1)
    80003eb8:	0094ca83          	lbu	s5,9(s1)
    80003ebc:	0104ba03          	ld	s4,16(s1)
    80003ec0:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80003ec4:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003ec8:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80003ecc:	0001c517          	auipc	a0,0x1c
    80003ed0:	c7c50513          	add	a0,a0,-900 # 8001fb48 <ftable>
    80003ed4:	db9fc0ef          	jal	80000c8c <release>

  if(ff.type == FD_PIPE){
    80003ed8:	4785                	li	a5,1
    80003eda:	04f90063          	beq	s2,a5,80003f1a <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003ede:	3979                	addw	s2,s2,-2
    80003ee0:	4785                	li	a5,1
    80003ee2:	0527f563          	bgeu	a5,s2,80003f2c <fileclose+0xaa>
    80003ee6:	7902                	ld	s2,32(sp)
    80003ee8:	69e2                	ld	s3,24(sp)
    80003eea:	6a42                	ld	s4,16(sp)
    80003eec:	6aa2                	ld	s5,8(sp)
    80003eee:	a00d                	j	80003f10 <fileclose+0x8e>
    80003ef0:	f04a                	sd	s2,32(sp)
    80003ef2:	ec4e                	sd	s3,24(sp)
    80003ef4:	e852                	sd	s4,16(sp)
    80003ef6:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80003ef8:	00003517          	auipc	a0,0x3
    80003efc:	6b050513          	add	a0,a0,1712 # 800075a8 <etext+0x5a8>
    80003f00:	895fc0ef          	jal	80000794 <panic>
    release(&ftable.lock);
    80003f04:	0001c517          	auipc	a0,0x1c
    80003f08:	c4450513          	add	a0,a0,-956 # 8001fb48 <ftable>
    80003f0c:	d81fc0ef          	jal	80000c8c <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80003f10:	70e2                	ld	ra,56(sp)
    80003f12:	7442                	ld	s0,48(sp)
    80003f14:	74a2                	ld	s1,40(sp)
    80003f16:	6121                	add	sp,sp,64
    80003f18:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003f1a:	85d6                	mv	a1,s5
    80003f1c:	8552                	mv	a0,s4
    80003f1e:	336000ef          	jal	80004254 <pipeclose>
    80003f22:	7902                	ld	s2,32(sp)
    80003f24:	69e2                	ld	s3,24(sp)
    80003f26:	6a42                	ld	s4,16(sp)
    80003f28:	6aa2                	ld	s5,8(sp)
    80003f2a:	b7dd                	j	80003f10 <fileclose+0x8e>
    begin_op();
    80003f2c:	b3dff0ef          	jal	80003a68 <begin_op>
    iput(ff.ip);
    80003f30:	854e                	mv	a0,s3
    80003f32:	c22ff0ef          	jal	80003354 <iput>
    end_op();
    80003f36:	b9dff0ef          	jal	80003ad2 <end_op>
    80003f3a:	7902                	ld	s2,32(sp)
    80003f3c:	69e2                	ld	s3,24(sp)
    80003f3e:	6a42                	ld	s4,16(sp)
    80003f40:	6aa2                	ld	s5,8(sp)
    80003f42:	b7f9                	j	80003f10 <fileclose+0x8e>

0000000080003f44 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80003f44:	715d                	add	sp,sp,-80
    80003f46:	e486                	sd	ra,72(sp)
    80003f48:	e0a2                	sd	s0,64(sp)
    80003f4a:	fc26                	sd	s1,56(sp)
    80003f4c:	f44e                	sd	s3,40(sp)
    80003f4e:	0880                	add	s0,sp,80
    80003f50:	84aa                	mv	s1,a0
    80003f52:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80003f54:	99ffd0ef          	jal	800018f2 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003f58:	409c                	lw	a5,0(s1)
    80003f5a:	37f9                	addw	a5,a5,-2
    80003f5c:	4705                	li	a4,1
    80003f5e:	04f76063          	bltu	a4,a5,80003f9e <filestat+0x5a>
    80003f62:	f84a                	sd	s2,48(sp)
    80003f64:	892a                	mv	s2,a0
    ilock(f->ip);
    80003f66:	6c88                	ld	a0,24(s1)
    80003f68:	a6aff0ef          	jal	800031d2 <ilock>
    stati(f->ip, &st);
    80003f6c:	fb840593          	add	a1,s0,-72
    80003f70:	6c88                	ld	a0,24(s1)
    80003f72:	c8aff0ef          	jal	800033fc <stati>
    iunlock(f->ip);
    80003f76:	6c88                	ld	a0,24(s1)
    80003f78:	b08ff0ef          	jal	80003280 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80003f7c:	46e1                	li	a3,24
    80003f7e:	fb840613          	add	a2,s0,-72
    80003f82:	85ce                	mv	a1,s3
    80003f84:	05093503          	ld	a0,80(s2)
    80003f88:	ddcfd0ef          	jal	80001564 <copyout>
    80003f8c:	41f5551b          	sraw	a0,a0,0x1f
    80003f90:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80003f92:	60a6                	ld	ra,72(sp)
    80003f94:	6406                	ld	s0,64(sp)
    80003f96:	74e2                	ld	s1,56(sp)
    80003f98:	79a2                	ld	s3,40(sp)
    80003f9a:	6161                	add	sp,sp,80
    80003f9c:	8082                	ret
  return -1;
    80003f9e:	557d                	li	a0,-1
    80003fa0:	bfcd                	j	80003f92 <filestat+0x4e>

0000000080003fa2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80003fa2:	7179                	add	sp,sp,-48
    80003fa4:	f406                	sd	ra,40(sp)
    80003fa6:	f022                	sd	s0,32(sp)
    80003fa8:	e84a                	sd	s2,16(sp)
    80003faa:	1800                	add	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80003fac:	00854783          	lbu	a5,8(a0)
    80003fb0:	cfd1                	beqz	a5,8000404c <fileread+0xaa>
    80003fb2:	ec26                	sd	s1,24(sp)
    80003fb4:	e44e                	sd	s3,8(sp)
    80003fb6:	84aa                	mv	s1,a0
    80003fb8:	89ae                	mv	s3,a1
    80003fba:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80003fbc:	411c                	lw	a5,0(a0)
    80003fbe:	4705                	li	a4,1
    80003fc0:	04e78363          	beq	a5,a4,80004006 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003fc4:	470d                	li	a4,3
    80003fc6:	04e78763          	beq	a5,a4,80004014 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80003fca:	4709                	li	a4,2
    80003fcc:	06e79a63          	bne	a5,a4,80004040 <fileread+0x9e>
    ilock(f->ip);
    80003fd0:	6d08                	ld	a0,24(a0)
    80003fd2:	a00ff0ef          	jal	800031d2 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80003fd6:	874a                	mv	a4,s2
    80003fd8:	5094                	lw	a3,32(s1)
    80003fda:	864e                	mv	a2,s3
    80003fdc:	4585                	li	a1,1
    80003fde:	6c88                	ld	a0,24(s1)
    80003fe0:	c46ff0ef          	jal	80003426 <readi>
    80003fe4:	892a                	mv	s2,a0
    80003fe6:	00a05563          	blez	a0,80003ff0 <fileread+0x4e>
      f->off += r;
    80003fea:	509c                	lw	a5,32(s1)
    80003fec:	9fa9                	addw	a5,a5,a0
    80003fee:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80003ff0:	6c88                	ld	a0,24(s1)
    80003ff2:	a8eff0ef          	jal	80003280 <iunlock>
    80003ff6:	64e2                	ld	s1,24(sp)
    80003ff8:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80003ffa:	854a                	mv	a0,s2
    80003ffc:	70a2                	ld	ra,40(sp)
    80003ffe:	7402                	ld	s0,32(sp)
    80004000:	6942                	ld	s2,16(sp)
    80004002:	6145                	add	sp,sp,48
    80004004:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004006:	6908                	ld	a0,16(a0)
    80004008:	388000ef          	jal	80004390 <piperead>
    8000400c:	892a                	mv	s2,a0
    8000400e:	64e2                	ld	s1,24(sp)
    80004010:	69a2                	ld	s3,8(sp)
    80004012:	b7e5                	j	80003ffa <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004014:	02451783          	lh	a5,36(a0)
    80004018:	03079693          	sll	a3,a5,0x30
    8000401c:	92c1                	srl	a3,a3,0x30
    8000401e:	4725                	li	a4,9
    80004020:	02d76863          	bltu	a4,a3,80004050 <fileread+0xae>
    80004024:	0792                	sll	a5,a5,0x4
    80004026:	0001c717          	auipc	a4,0x1c
    8000402a:	a8270713          	add	a4,a4,-1406 # 8001faa8 <devsw>
    8000402e:	97ba                	add	a5,a5,a4
    80004030:	639c                	ld	a5,0(a5)
    80004032:	c39d                	beqz	a5,80004058 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    80004034:	4505                	li	a0,1
    80004036:	9782                	jalr	a5
    80004038:	892a                	mv	s2,a0
    8000403a:	64e2                	ld	s1,24(sp)
    8000403c:	69a2                	ld	s3,8(sp)
    8000403e:	bf75                	j	80003ffa <fileread+0x58>
    panic("fileread");
    80004040:	00003517          	auipc	a0,0x3
    80004044:	57850513          	add	a0,a0,1400 # 800075b8 <etext+0x5b8>
    80004048:	f4cfc0ef          	jal	80000794 <panic>
    return -1;
    8000404c:	597d                	li	s2,-1
    8000404e:	b775                	j	80003ffa <fileread+0x58>
      return -1;
    80004050:	597d                	li	s2,-1
    80004052:	64e2                	ld	s1,24(sp)
    80004054:	69a2                	ld	s3,8(sp)
    80004056:	b755                	j	80003ffa <fileread+0x58>
    80004058:	597d                	li	s2,-1
    8000405a:	64e2                	ld	s1,24(sp)
    8000405c:	69a2                	ld	s3,8(sp)
    8000405e:	bf71                	j	80003ffa <fileread+0x58>

0000000080004060 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004060:	00954783          	lbu	a5,9(a0)
    80004064:	10078b63          	beqz	a5,8000417a <filewrite+0x11a>
{
    80004068:	715d                	add	sp,sp,-80
    8000406a:	e486                	sd	ra,72(sp)
    8000406c:	e0a2                	sd	s0,64(sp)
    8000406e:	f84a                	sd	s2,48(sp)
    80004070:	f052                	sd	s4,32(sp)
    80004072:	e85a                	sd	s6,16(sp)
    80004074:	0880                	add	s0,sp,80
    80004076:	892a                	mv	s2,a0
    80004078:	8b2e                	mv	s6,a1
    8000407a:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000407c:	411c                	lw	a5,0(a0)
    8000407e:	4705                	li	a4,1
    80004080:	02e78763          	beq	a5,a4,800040ae <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004084:	470d                	li	a4,3
    80004086:	02e78863          	beq	a5,a4,800040b6 <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000408a:	4709                	li	a4,2
    8000408c:	0ce79c63          	bne	a5,a4,80004164 <filewrite+0x104>
    80004090:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004092:	0ac05863          	blez	a2,80004142 <filewrite+0xe2>
    80004096:	fc26                	sd	s1,56(sp)
    80004098:	ec56                	sd	s5,24(sp)
    8000409a:	e45e                	sd	s7,8(sp)
    8000409c:	e062                	sd	s8,0(sp)
    int i = 0;
    8000409e:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    800040a0:	6b85                	lui	s7,0x1
    800040a2:	c00b8b93          	add	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800040a6:	6c05                	lui	s8,0x1
    800040a8:	c00c0c1b          	addw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800040ac:	a8b5                	j	80004128 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    800040ae:	6908                	ld	a0,16(a0)
    800040b0:	1fc000ef          	jal	800042ac <pipewrite>
    800040b4:	a04d                	j	80004156 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800040b6:	02451783          	lh	a5,36(a0)
    800040ba:	03079693          	sll	a3,a5,0x30
    800040be:	92c1                	srl	a3,a3,0x30
    800040c0:	4725                	li	a4,9
    800040c2:	0ad76e63          	bltu	a4,a3,8000417e <filewrite+0x11e>
    800040c6:	0792                	sll	a5,a5,0x4
    800040c8:	0001c717          	auipc	a4,0x1c
    800040cc:	9e070713          	add	a4,a4,-1568 # 8001faa8 <devsw>
    800040d0:	97ba                	add	a5,a5,a4
    800040d2:	679c                	ld	a5,8(a5)
    800040d4:	c7dd                	beqz	a5,80004182 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    800040d6:	4505                	li	a0,1
    800040d8:	9782                	jalr	a5
    800040da:	a8b5                	j	80004156 <filewrite+0xf6>
      if(n1 > max)
    800040dc:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    800040e0:	989ff0ef          	jal	80003a68 <begin_op>
      ilock(f->ip);
    800040e4:	01893503          	ld	a0,24(s2)
    800040e8:	8eaff0ef          	jal	800031d2 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800040ec:	8756                	mv	a4,s5
    800040ee:	02092683          	lw	a3,32(s2)
    800040f2:	01698633          	add	a2,s3,s6
    800040f6:	4585                	li	a1,1
    800040f8:	01893503          	ld	a0,24(s2)
    800040fc:	c26ff0ef          	jal	80003522 <writei>
    80004100:	84aa                	mv	s1,a0
    80004102:	00a05763          	blez	a0,80004110 <filewrite+0xb0>
        f->off += r;
    80004106:	02092783          	lw	a5,32(s2)
    8000410a:	9fa9                	addw	a5,a5,a0
    8000410c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004110:	01893503          	ld	a0,24(s2)
    80004114:	96cff0ef          	jal	80003280 <iunlock>
      end_op();
    80004118:	9bbff0ef          	jal	80003ad2 <end_op>

      if(r != n1){
    8000411c:	029a9563          	bne	s5,s1,80004146 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    80004120:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004124:	0149da63          	bge	s3,s4,80004138 <filewrite+0xd8>
      int n1 = n - i;
    80004128:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    8000412c:	0004879b          	sext.w	a5,s1
    80004130:	fafbd6e3          	bge	s7,a5,800040dc <filewrite+0x7c>
    80004134:	84e2                	mv	s1,s8
    80004136:	b75d                	j	800040dc <filewrite+0x7c>
    80004138:	74e2                	ld	s1,56(sp)
    8000413a:	6ae2                	ld	s5,24(sp)
    8000413c:	6ba2                	ld	s7,8(sp)
    8000413e:	6c02                	ld	s8,0(sp)
    80004140:	a039                	j	8000414e <filewrite+0xee>
    int i = 0;
    80004142:	4981                	li	s3,0
    80004144:	a029                	j	8000414e <filewrite+0xee>
    80004146:	74e2                	ld	s1,56(sp)
    80004148:	6ae2                	ld	s5,24(sp)
    8000414a:	6ba2                	ld	s7,8(sp)
    8000414c:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    8000414e:	033a1c63          	bne	s4,s3,80004186 <filewrite+0x126>
    80004152:	8552                	mv	a0,s4
    80004154:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004156:	60a6                	ld	ra,72(sp)
    80004158:	6406                	ld	s0,64(sp)
    8000415a:	7942                	ld	s2,48(sp)
    8000415c:	7a02                	ld	s4,32(sp)
    8000415e:	6b42                	ld	s6,16(sp)
    80004160:	6161                	add	sp,sp,80
    80004162:	8082                	ret
    80004164:	fc26                	sd	s1,56(sp)
    80004166:	f44e                	sd	s3,40(sp)
    80004168:	ec56                	sd	s5,24(sp)
    8000416a:	e45e                	sd	s7,8(sp)
    8000416c:	e062                	sd	s8,0(sp)
    panic("filewrite");
    8000416e:	00003517          	auipc	a0,0x3
    80004172:	45a50513          	add	a0,a0,1114 # 800075c8 <etext+0x5c8>
    80004176:	e1efc0ef          	jal	80000794 <panic>
    return -1;
    8000417a:	557d                	li	a0,-1
}
    8000417c:	8082                	ret
      return -1;
    8000417e:	557d                	li	a0,-1
    80004180:	bfd9                	j	80004156 <filewrite+0xf6>
    80004182:	557d                	li	a0,-1
    80004184:	bfc9                	j	80004156 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    80004186:	557d                	li	a0,-1
    80004188:	79a2                	ld	s3,40(sp)
    8000418a:	b7f1                	j	80004156 <filewrite+0xf6>

000000008000418c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000418c:	7179                	add	sp,sp,-48
    8000418e:	f406                	sd	ra,40(sp)
    80004190:	f022                	sd	s0,32(sp)
    80004192:	ec26                	sd	s1,24(sp)
    80004194:	e052                	sd	s4,0(sp)
    80004196:	1800                	add	s0,sp,48
    80004198:	84aa                	mv	s1,a0
    8000419a:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000419c:	0005b023          	sd	zero,0(a1)
    800041a0:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800041a4:	c3bff0ef          	jal	80003dde <filealloc>
    800041a8:	e088                	sd	a0,0(s1)
    800041aa:	c549                	beqz	a0,80004234 <pipealloc+0xa8>
    800041ac:	c33ff0ef          	jal	80003dde <filealloc>
    800041b0:	00aa3023          	sd	a0,0(s4)
    800041b4:	cd25                	beqz	a0,8000422c <pipealloc+0xa0>
    800041b6:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800041b8:	96dfc0ef          	jal	80000b24 <kalloc>
    800041bc:	892a                	mv	s2,a0
    800041be:	c12d                	beqz	a0,80004220 <pipealloc+0x94>
    800041c0:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800041c2:	4985                	li	s3,1
    800041c4:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800041c8:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800041cc:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800041d0:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800041d4:	00003597          	auipc	a1,0x3
    800041d8:	40458593          	add	a1,a1,1028 # 800075d8 <etext+0x5d8>
    800041dc:	999fc0ef          	jal	80000b74 <initlock>
  (*f0)->type = FD_PIPE;
    800041e0:	609c                	ld	a5,0(s1)
    800041e2:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800041e6:	609c                	ld	a5,0(s1)
    800041e8:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800041ec:	609c                	ld	a5,0(s1)
    800041ee:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800041f2:	609c                	ld	a5,0(s1)
    800041f4:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800041f8:	000a3783          	ld	a5,0(s4)
    800041fc:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004200:	000a3783          	ld	a5,0(s4)
    80004204:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004208:	000a3783          	ld	a5,0(s4)
    8000420c:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004210:	000a3783          	ld	a5,0(s4)
    80004214:	0127b823          	sd	s2,16(a5)
  return 0;
    80004218:	4501                	li	a0,0
    8000421a:	6942                	ld	s2,16(sp)
    8000421c:	69a2                	ld	s3,8(sp)
    8000421e:	a01d                	j	80004244 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004220:	6088                	ld	a0,0(s1)
    80004222:	c119                	beqz	a0,80004228 <pipealloc+0x9c>
    80004224:	6942                	ld	s2,16(sp)
    80004226:	a029                	j	80004230 <pipealloc+0xa4>
    80004228:	6942                	ld	s2,16(sp)
    8000422a:	a029                	j	80004234 <pipealloc+0xa8>
    8000422c:	6088                	ld	a0,0(s1)
    8000422e:	c10d                	beqz	a0,80004250 <pipealloc+0xc4>
    fileclose(*f0);
    80004230:	c53ff0ef          	jal	80003e82 <fileclose>
  if(*f1)
    80004234:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004238:	557d                	li	a0,-1
  if(*f1)
    8000423a:	c789                	beqz	a5,80004244 <pipealloc+0xb8>
    fileclose(*f1);
    8000423c:	853e                	mv	a0,a5
    8000423e:	c45ff0ef          	jal	80003e82 <fileclose>
  return -1;
    80004242:	557d                	li	a0,-1
}
    80004244:	70a2                	ld	ra,40(sp)
    80004246:	7402                	ld	s0,32(sp)
    80004248:	64e2                	ld	s1,24(sp)
    8000424a:	6a02                	ld	s4,0(sp)
    8000424c:	6145                	add	sp,sp,48
    8000424e:	8082                	ret
  return -1;
    80004250:	557d                	li	a0,-1
    80004252:	bfcd                	j	80004244 <pipealloc+0xb8>

0000000080004254 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004254:	1101                	add	sp,sp,-32
    80004256:	ec06                	sd	ra,24(sp)
    80004258:	e822                	sd	s0,16(sp)
    8000425a:	e426                	sd	s1,8(sp)
    8000425c:	e04a                	sd	s2,0(sp)
    8000425e:	1000                	add	s0,sp,32
    80004260:	84aa                	mv	s1,a0
    80004262:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004264:	991fc0ef          	jal	80000bf4 <acquire>
  if(writable){
    80004268:	02090763          	beqz	s2,80004296 <pipeclose+0x42>
    pi->writeopen = 0;
    8000426c:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004270:	21848513          	add	a0,s1,536
    80004274:	c99fd0ef          	jal	80001f0c <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004278:	2204b783          	ld	a5,544(s1)
    8000427c:	e785                	bnez	a5,800042a4 <pipeclose+0x50>
    release(&pi->lock);
    8000427e:	8526                	mv	a0,s1
    80004280:	a0dfc0ef          	jal	80000c8c <release>
    kfree((char*)pi);
    80004284:	8526                	mv	a0,s1
    80004286:	fbcfc0ef          	jal	80000a42 <kfree>
  } else
    release(&pi->lock);
}
    8000428a:	60e2                	ld	ra,24(sp)
    8000428c:	6442                	ld	s0,16(sp)
    8000428e:	64a2                	ld	s1,8(sp)
    80004290:	6902                	ld	s2,0(sp)
    80004292:	6105                	add	sp,sp,32
    80004294:	8082                	ret
    pi->readopen = 0;
    80004296:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000429a:	21c48513          	add	a0,s1,540
    8000429e:	c6ffd0ef          	jal	80001f0c <wakeup>
    800042a2:	bfd9                	j	80004278 <pipeclose+0x24>
    release(&pi->lock);
    800042a4:	8526                	mv	a0,s1
    800042a6:	9e7fc0ef          	jal	80000c8c <release>
}
    800042aa:	b7c5                	j	8000428a <pipeclose+0x36>

00000000800042ac <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800042ac:	711d                	add	sp,sp,-96
    800042ae:	ec86                	sd	ra,88(sp)
    800042b0:	e8a2                	sd	s0,80(sp)
    800042b2:	e4a6                	sd	s1,72(sp)
    800042b4:	e0ca                	sd	s2,64(sp)
    800042b6:	fc4e                	sd	s3,56(sp)
    800042b8:	f852                	sd	s4,48(sp)
    800042ba:	f456                	sd	s5,40(sp)
    800042bc:	1080                	add	s0,sp,96
    800042be:	84aa                	mv	s1,a0
    800042c0:	8aae                	mv	s5,a1
    800042c2:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800042c4:	e2efd0ef          	jal	800018f2 <myproc>
    800042c8:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800042ca:	8526                	mv	a0,s1
    800042cc:	929fc0ef          	jal	80000bf4 <acquire>
  while(i < n){
    800042d0:	0b405a63          	blez	s4,80004384 <pipewrite+0xd8>
    800042d4:	f05a                	sd	s6,32(sp)
    800042d6:	ec5e                	sd	s7,24(sp)
    800042d8:	e862                	sd	s8,16(sp)
  int i = 0;
    800042da:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800042dc:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800042de:	21848c13          	add	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800042e2:	21c48b93          	add	s7,s1,540
    800042e6:	a81d                	j	8000431c <pipewrite+0x70>
      release(&pi->lock);
    800042e8:	8526                	mv	a0,s1
    800042ea:	9a3fc0ef          	jal	80000c8c <release>
      return -1;
    800042ee:	597d                	li	s2,-1
    800042f0:	7b02                	ld	s6,32(sp)
    800042f2:	6be2                	ld	s7,24(sp)
    800042f4:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800042f6:	854a                	mv	a0,s2
    800042f8:	60e6                	ld	ra,88(sp)
    800042fa:	6446                	ld	s0,80(sp)
    800042fc:	64a6                	ld	s1,72(sp)
    800042fe:	6906                	ld	s2,64(sp)
    80004300:	79e2                	ld	s3,56(sp)
    80004302:	7a42                	ld	s4,48(sp)
    80004304:	7aa2                	ld	s5,40(sp)
    80004306:	6125                	add	sp,sp,96
    80004308:	8082                	ret
      wakeup(&pi->nread);
    8000430a:	8562                	mv	a0,s8
    8000430c:	c01fd0ef          	jal	80001f0c <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004310:	85a6                	mv	a1,s1
    80004312:	855e                	mv	a0,s7
    80004314:	badfd0ef          	jal	80001ec0 <sleep>
  while(i < n){
    80004318:	05495b63          	bge	s2,s4,8000436e <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    8000431c:	2204a783          	lw	a5,544(s1)
    80004320:	d7e1                	beqz	a5,800042e8 <pipewrite+0x3c>
    80004322:	854e                	mv	a0,s3
    80004324:	dd5fd0ef          	jal	800020f8 <killed>
    80004328:	f161                	bnez	a0,800042e8 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000432a:	2184a783          	lw	a5,536(s1)
    8000432e:	21c4a703          	lw	a4,540(s1)
    80004332:	2007879b          	addw	a5,a5,512
    80004336:	fcf70ae3          	beq	a4,a5,8000430a <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000433a:	4685                	li	a3,1
    8000433c:	01590633          	add	a2,s2,s5
    80004340:	faf40593          	add	a1,s0,-81
    80004344:	0509b503          	ld	a0,80(s3)
    80004348:	af2fd0ef          	jal	8000163a <copyin>
    8000434c:	03650e63          	beq	a0,s6,80004388 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004350:	21c4a783          	lw	a5,540(s1)
    80004354:	0017871b          	addw	a4,a5,1
    80004358:	20e4ae23          	sw	a4,540(s1)
    8000435c:	1ff7f793          	and	a5,a5,511
    80004360:	97a6                	add	a5,a5,s1
    80004362:	faf44703          	lbu	a4,-81(s0)
    80004366:	00e78c23          	sb	a4,24(a5)
      i++;
    8000436a:	2905                	addw	s2,s2,1
    8000436c:	b775                	j	80004318 <pipewrite+0x6c>
    8000436e:	7b02                	ld	s6,32(sp)
    80004370:	6be2                	ld	s7,24(sp)
    80004372:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004374:	21848513          	add	a0,s1,536
    80004378:	b95fd0ef          	jal	80001f0c <wakeup>
  release(&pi->lock);
    8000437c:	8526                	mv	a0,s1
    8000437e:	90ffc0ef          	jal	80000c8c <release>
  return i;
    80004382:	bf95                	j	800042f6 <pipewrite+0x4a>
  int i = 0;
    80004384:	4901                	li	s2,0
    80004386:	b7fd                	j	80004374 <pipewrite+0xc8>
    80004388:	7b02                	ld	s6,32(sp)
    8000438a:	6be2                	ld	s7,24(sp)
    8000438c:	6c42                	ld	s8,16(sp)
    8000438e:	b7dd                	j	80004374 <pipewrite+0xc8>

0000000080004390 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004390:	715d                	add	sp,sp,-80
    80004392:	e486                	sd	ra,72(sp)
    80004394:	e0a2                	sd	s0,64(sp)
    80004396:	fc26                	sd	s1,56(sp)
    80004398:	f84a                	sd	s2,48(sp)
    8000439a:	f44e                	sd	s3,40(sp)
    8000439c:	f052                	sd	s4,32(sp)
    8000439e:	ec56                	sd	s5,24(sp)
    800043a0:	0880                	add	s0,sp,80
    800043a2:	84aa                	mv	s1,a0
    800043a4:	892e                	mv	s2,a1
    800043a6:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800043a8:	d4afd0ef          	jal	800018f2 <myproc>
    800043ac:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800043ae:	8526                	mv	a0,s1
    800043b0:	845fc0ef          	jal	80000bf4 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800043b4:	2184a703          	lw	a4,536(s1)
    800043b8:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800043bc:	21848993          	add	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800043c0:	02f71563          	bne	a4,a5,800043ea <piperead+0x5a>
    800043c4:	2244a783          	lw	a5,548(s1)
    800043c8:	cb85                	beqz	a5,800043f8 <piperead+0x68>
    if(killed(pr)){
    800043ca:	8552                	mv	a0,s4
    800043cc:	d2dfd0ef          	jal	800020f8 <killed>
    800043d0:	ed19                	bnez	a0,800043ee <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800043d2:	85a6                	mv	a1,s1
    800043d4:	854e                	mv	a0,s3
    800043d6:	aebfd0ef          	jal	80001ec0 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800043da:	2184a703          	lw	a4,536(s1)
    800043de:	21c4a783          	lw	a5,540(s1)
    800043e2:	fef701e3          	beq	a4,a5,800043c4 <piperead+0x34>
    800043e6:	e85a                	sd	s6,16(sp)
    800043e8:	a809                	j	800043fa <piperead+0x6a>
    800043ea:	e85a                	sd	s6,16(sp)
    800043ec:	a039                	j	800043fa <piperead+0x6a>
      release(&pi->lock);
    800043ee:	8526                	mv	a0,s1
    800043f0:	89dfc0ef          	jal	80000c8c <release>
      return -1;
    800043f4:	59fd                	li	s3,-1
    800043f6:	a8b1                	j	80004452 <piperead+0xc2>
    800043f8:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800043fa:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800043fc:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800043fe:	05505263          	blez	s5,80004442 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004402:	2184a783          	lw	a5,536(s1)
    80004406:	21c4a703          	lw	a4,540(s1)
    8000440a:	02f70c63          	beq	a4,a5,80004442 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000440e:	0017871b          	addw	a4,a5,1
    80004412:	20e4ac23          	sw	a4,536(s1)
    80004416:	1ff7f793          	and	a5,a5,511
    8000441a:	97a6                	add	a5,a5,s1
    8000441c:	0187c783          	lbu	a5,24(a5)
    80004420:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004424:	4685                	li	a3,1
    80004426:	fbf40613          	add	a2,s0,-65
    8000442a:	85ca                	mv	a1,s2
    8000442c:	050a3503          	ld	a0,80(s4)
    80004430:	934fd0ef          	jal	80001564 <copyout>
    80004434:	01650763          	beq	a0,s6,80004442 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004438:	2985                	addw	s3,s3,1
    8000443a:	0905                	add	s2,s2,1
    8000443c:	fd3a93e3          	bne	s5,s3,80004402 <piperead+0x72>
    80004440:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004442:	21c48513          	add	a0,s1,540
    80004446:	ac7fd0ef          	jal	80001f0c <wakeup>
  release(&pi->lock);
    8000444a:	8526                	mv	a0,s1
    8000444c:	841fc0ef          	jal	80000c8c <release>
    80004450:	6b42                	ld	s6,16(sp)
  return i;
}
    80004452:	854e                	mv	a0,s3
    80004454:	60a6                	ld	ra,72(sp)
    80004456:	6406                	ld	s0,64(sp)
    80004458:	74e2                	ld	s1,56(sp)
    8000445a:	7942                	ld	s2,48(sp)
    8000445c:	79a2                	ld	s3,40(sp)
    8000445e:	7a02                	ld	s4,32(sp)
    80004460:	6ae2                	ld	s5,24(sp)
    80004462:	6161                	add	sp,sp,80
    80004464:	8082                	ret

0000000080004466 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004466:	1141                	add	sp,sp,-16
    80004468:	e422                	sd	s0,8(sp)
    8000446a:	0800                	add	s0,sp,16
    8000446c:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000446e:	8905                	and	a0,a0,1
    80004470:	050e                	sll	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004472:	8b89                	and	a5,a5,2
    80004474:	c399                	beqz	a5,8000447a <flags2perm+0x14>
      perm |= PTE_W;
    80004476:	00456513          	or	a0,a0,4
    return perm;
}
    8000447a:	6422                	ld	s0,8(sp)
    8000447c:	0141                	add	sp,sp,16
    8000447e:	8082                	ret

0000000080004480 <exec>:

int
exec(char *path, char **argv)
{
    80004480:	df010113          	add	sp,sp,-528
    80004484:	20113423          	sd	ra,520(sp)
    80004488:	20813023          	sd	s0,512(sp)
    8000448c:	ffa6                	sd	s1,504(sp)
    8000448e:	fbca                	sd	s2,496(sp)
    80004490:	0c00                	add	s0,sp,528
    80004492:	892a                	mv	s2,a0
    80004494:	dea43c23          	sd	a0,-520(s0)
    80004498:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000449c:	c56fd0ef          	jal	800018f2 <myproc>
    800044a0:	84aa                	mv	s1,a0

  begin_op();
    800044a2:	dc6ff0ef          	jal	80003a68 <begin_op>

  if((ip = namei(path)) == 0){
    800044a6:	854a                	mv	a0,s2
    800044a8:	c04ff0ef          	jal	800038ac <namei>
    800044ac:	c931                	beqz	a0,80004500 <exec+0x80>
    800044ae:	f3d2                	sd	s4,480(sp)
    800044b0:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800044b2:	d21fe0ef          	jal	800031d2 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800044b6:	04000713          	li	a4,64
    800044ba:	4681                	li	a3,0
    800044bc:	e5040613          	add	a2,s0,-432
    800044c0:	4581                	li	a1,0
    800044c2:	8552                	mv	a0,s4
    800044c4:	f63fe0ef          	jal	80003426 <readi>
    800044c8:	04000793          	li	a5,64
    800044cc:	00f51a63          	bne	a0,a5,800044e0 <exec+0x60>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800044d0:	e5042703          	lw	a4,-432(s0)
    800044d4:	464c47b7          	lui	a5,0x464c4
    800044d8:	57f78793          	add	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800044dc:	02f70663          	beq	a4,a5,80004508 <exec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800044e0:	8552                	mv	a0,s4
    800044e2:	efbfe0ef          	jal	800033dc <iunlockput>
    end_op();
    800044e6:	decff0ef          	jal	80003ad2 <end_op>
  }
  return -1;
    800044ea:	557d                	li	a0,-1
    800044ec:	7a1e                	ld	s4,480(sp)
}
    800044ee:	20813083          	ld	ra,520(sp)
    800044f2:	20013403          	ld	s0,512(sp)
    800044f6:	74fe                	ld	s1,504(sp)
    800044f8:	795e                	ld	s2,496(sp)
    800044fa:	21010113          	add	sp,sp,528
    800044fe:	8082                	ret
    end_op();
    80004500:	dd2ff0ef          	jal	80003ad2 <end_op>
    return -1;
    80004504:	557d                	li	a0,-1
    80004506:	b7e5                	j	800044ee <exec+0x6e>
    80004508:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    8000450a:	8526                	mv	a0,s1
    8000450c:	c8efd0ef          	jal	8000199a <proc_pagetable>
    80004510:	8b2a                	mv	s6,a0
    80004512:	2c050b63          	beqz	a0,800047e8 <exec+0x368>
    80004516:	f7ce                	sd	s3,488(sp)
    80004518:	efd6                	sd	s5,472(sp)
    8000451a:	e7de                	sd	s7,456(sp)
    8000451c:	e3e2                	sd	s8,448(sp)
    8000451e:	ff66                	sd	s9,440(sp)
    80004520:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004522:	e7042d03          	lw	s10,-400(s0)
    80004526:	e8845783          	lhu	a5,-376(s0)
    8000452a:	12078963          	beqz	a5,8000465c <exec+0x1dc>
    8000452e:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004530:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004532:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004534:	6c85                	lui	s9,0x1
    80004536:	fffc8793          	add	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000453a:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    8000453e:	6a85                	lui	s5,0x1
    80004540:	a085                	j	800045a0 <exec+0x120>
      panic("loadseg: address should exist");
    80004542:	00003517          	auipc	a0,0x3
    80004546:	09e50513          	add	a0,a0,158 # 800075e0 <etext+0x5e0>
    8000454a:	a4afc0ef          	jal	80000794 <panic>
    if(sz - i < PGSIZE)
    8000454e:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004550:	8726                	mv	a4,s1
    80004552:	012c06bb          	addw	a3,s8,s2
    80004556:	4581                	li	a1,0
    80004558:	8552                	mv	a0,s4
    8000455a:	ecdfe0ef          	jal	80003426 <readi>
    8000455e:	2501                	sext.w	a0,a0
    80004560:	24a49a63          	bne	s1,a0,800047b4 <exec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80004564:	012a893b          	addw	s2,s5,s2
    80004568:	03397363          	bgeu	s2,s3,8000458e <exec+0x10e>
    pa = walkaddr(pagetable, va + i);
    8000456c:	02091593          	sll	a1,s2,0x20
    80004570:	9181                	srl	a1,a1,0x20
    80004572:	95de                	add	a1,a1,s7
    80004574:	855a                	mv	a0,s6
    80004576:	a61fc0ef          	jal	80000fd6 <walkaddr>
    8000457a:	862a                	mv	a2,a0
    if(pa == 0)
    8000457c:	d179                	beqz	a0,80004542 <exec+0xc2>
    if(sz - i < PGSIZE)
    8000457e:	412984bb          	subw	s1,s3,s2
    80004582:	0004879b          	sext.w	a5,s1
    80004586:	fcfcf4e3          	bgeu	s9,a5,8000454e <exec+0xce>
    8000458a:	84d6                	mv	s1,s5
    8000458c:	b7c9                	j	8000454e <exec+0xce>
    sz = sz1;
    8000458e:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004592:	2d85                	addw	s11,s11,1
    80004594:	038d0d1b          	addw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    80004598:	e8845783          	lhu	a5,-376(s0)
    8000459c:	08fdd063          	bge	s11,a5,8000461c <exec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800045a0:	2d01                	sext.w	s10,s10
    800045a2:	03800713          	li	a4,56
    800045a6:	86ea                	mv	a3,s10
    800045a8:	e1840613          	add	a2,s0,-488
    800045ac:	4581                	li	a1,0
    800045ae:	8552                	mv	a0,s4
    800045b0:	e77fe0ef          	jal	80003426 <readi>
    800045b4:	03800793          	li	a5,56
    800045b8:	1cf51663          	bne	a0,a5,80004784 <exec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    800045bc:	e1842783          	lw	a5,-488(s0)
    800045c0:	4705                	li	a4,1
    800045c2:	fce798e3          	bne	a5,a4,80004592 <exec+0x112>
    if(ph.memsz < ph.filesz)
    800045c6:	e4043483          	ld	s1,-448(s0)
    800045ca:	e3843783          	ld	a5,-456(s0)
    800045ce:	1af4ef63          	bltu	s1,a5,8000478c <exec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800045d2:	e2843783          	ld	a5,-472(s0)
    800045d6:	94be                	add	s1,s1,a5
    800045d8:	1af4ee63          	bltu	s1,a5,80004794 <exec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    800045dc:	df043703          	ld	a4,-528(s0)
    800045e0:	8ff9                	and	a5,a5,a4
    800045e2:	1a079d63          	bnez	a5,8000479c <exec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800045e6:	e1c42503          	lw	a0,-484(s0)
    800045ea:	e7dff0ef          	jal	80004466 <flags2perm>
    800045ee:	86aa                	mv	a3,a0
    800045f0:	8626                	mv	a2,s1
    800045f2:	85ca                	mv	a1,s2
    800045f4:	855a                	mv	a0,s6
    800045f6:	d5bfc0ef          	jal	80001350 <uvmalloc>
    800045fa:	e0a43423          	sd	a0,-504(s0)
    800045fe:	1a050363          	beqz	a0,800047a4 <exec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004602:	e2843b83          	ld	s7,-472(s0)
    80004606:	e2042c03          	lw	s8,-480(s0)
    8000460a:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000460e:	00098463          	beqz	s3,80004616 <exec+0x196>
    80004612:	4901                	li	s2,0
    80004614:	bfa1                	j	8000456c <exec+0xec>
    sz = sz1;
    80004616:	e0843903          	ld	s2,-504(s0)
    8000461a:	bfa5                	j	80004592 <exec+0x112>
    8000461c:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    8000461e:	8552                	mv	a0,s4
    80004620:	dbdfe0ef          	jal	800033dc <iunlockput>
  end_op();
    80004624:	caeff0ef          	jal	80003ad2 <end_op>
  p = myproc();
    80004628:	acafd0ef          	jal	800018f2 <myproc>
    8000462c:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    8000462e:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004632:	6985                	lui	s3,0x1
    80004634:	19fd                	add	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004636:	99ca                	add	s3,s3,s2
    80004638:	77fd                	lui	a5,0xfffff
    8000463a:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    8000463e:	4691                	li	a3,4
    80004640:	6609                	lui	a2,0x2
    80004642:	964e                	add	a2,a2,s3
    80004644:	85ce                	mv	a1,s3
    80004646:	855a                	mv	a0,s6
    80004648:	d09fc0ef          	jal	80001350 <uvmalloc>
    8000464c:	892a                	mv	s2,a0
    8000464e:	e0a43423          	sd	a0,-504(s0)
    80004652:	e519                	bnez	a0,80004660 <exec+0x1e0>
  if(pagetable)
    80004654:	e1343423          	sd	s3,-504(s0)
    80004658:	4a01                	li	s4,0
    8000465a:	aab1                	j	800047b6 <exec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000465c:	4901                	li	s2,0
    8000465e:	b7c1                	j	8000461e <exec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004660:	75f9                	lui	a1,0xffffe
    80004662:	95aa                	add	a1,a1,a0
    80004664:	855a                	mv	a0,s6
    80004666:	ed5fc0ef          	jal	8000153a <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    8000466a:	7bfd                	lui	s7,0xfffff
    8000466c:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    8000466e:	e0043783          	ld	a5,-512(s0)
    80004672:	6388                	ld	a0,0(a5)
    80004674:	cd39                	beqz	a0,800046d2 <exec+0x252>
    80004676:	e9040993          	add	s3,s0,-368
    8000467a:	f9040c13          	add	s8,s0,-112
    8000467e:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004680:	fb8fc0ef          	jal	80000e38 <strlen>
    80004684:	0015079b          	addw	a5,a0,1
    80004688:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000468c:	ff07f913          	and	s2,a5,-16
    if(sp < stackbase)
    80004690:	11796e63          	bltu	s2,s7,800047ac <exec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004694:	e0043d03          	ld	s10,-512(s0)
    80004698:	000d3a03          	ld	s4,0(s10)
    8000469c:	8552                	mv	a0,s4
    8000469e:	f9afc0ef          	jal	80000e38 <strlen>
    800046a2:	0015069b          	addw	a3,a0,1
    800046a6:	8652                	mv	a2,s4
    800046a8:	85ca                	mv	a1,s2
    800046aa:	855a                	mv	a0,s6
    800046ac:	eb9fc0ef          	jal	80001564 <copyout>
    800046b0:	10054063          	bltz	a0,800047b0 <exec+0x330>
    ustack[argc] = sp;
    800046b4:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800046b8:	0485                	add	s1,s1,1
    800046ba:	008d0793          	add	a5,s10,8
    800046be:	e0f43023          	sd	a5,-512(s0)
    800046c2:	008d3503          	ld	a0,8(s10)
    800046c6:	c909                	beqz	a0,800046d8 <exec+0x258>
    if(argc >= MAXARG)
    800046c8:	09a1                	add	s3,s3,8
    800046ca:	fb899be3          	bne	s3,s8,80004680 <exec+0x200>
  ip = 0;
    800046ce:	4a01                	li	s4,0
    800046d0:	a0dd                	j	800047b6 <exec+0x336>
  sp = sz;
    800046d2:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    800046d6:	4481                	li	s1,0
  ustack[argc] = 0;
    800046d8:	00349793          	sll	a5,s1,0x3
    800046dc:	f9078793          	add	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffde350>
    800046e0:	97a2                	add	a5,a5,s0
    800046e2:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800046e6:	00148693          	add	a3,s1,1
    800046ea:	068e                	sll	a3,a3,0x3
    800046ec:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800046f0:	ff097913          	and	s2,s2,-16
  sz = sz1;
    800046f4:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    800046f8:	f5796ee3          	bltu	s2,s7,80004654 <exec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800046fc:	e9040613          	add	a2,s0,-368
    80004700:	85ca                	mv	a1,s2
    80004702:	855a                	mv	a0,s6
    80004704:	e61fc0ef          	jal	80001564 <copyout>
    80004708:	0e054263          	bltz	a0,800047ec <exec+0x36c>
  p->trapframe->a1 = sp;
    8000470c:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004710:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004714:	df843783          	ld	a5,-520(s0)
    80004718:	0007c703          	lbu	a4,0(a5)
    8000471c:	cf11                	beqz	a4,80004738 <exec+0x2b8>
    8000471e:	0785                	add	a5,a5,1
    if(*s == '/')
    80004720:	02f00693          	li	a3,47
    80004724:	a039                	j	80004732 <exec+0x2b2>
      last = s+1;
    80004726:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    8000472a:	0785                	add	a5,a5,1
    8000472c:	fff7c703          	lbu	a4,-1(a5)
    80004730:	c701                	beqz	a4,80004738 <exec+0x2b8>
    if(*s == '/')
    80004732:	fed71ce3          	bne	a4,a3,8000472a <exec+0x2aa>
    80004736:	bfc5                	j	80004726 <exec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80004738:	4641                	li	a2,16
    8000473a:	df843583          	ld	a1,-520(s0)
    8000473e:	158a8513          	add	a0,s5,344
    80004742:	ec4fc0ef          	jal	80000e06 <safestrcpy>
  oldpagetable = p->pagetable;
    80004746:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    8000474a:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    8000474e:	e0843783          	ld	a5,-504(s0)
    80004752:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004756:	058ab783          	ld	a5,88(s5)
    8000475a:	e6843703          	ld	a4,-408(s0)
    8000475e:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004760:	058ab783          	ld	a5,88(s5)
    80004764:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004768:	85e6                	mv	a1,s9
    8000476a:	ab4fd0ef          	jal	80001a1e <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000476e:	0004851b          	sext.w	a0,s1
    80004772:	79be                	ld	s3,488(sp)
    80004774:	7a1e                	ld	s4,480(sp)
    80004776:	6afe                	ld	s5,472(sp)
    80004778:	6b5e                	ld	s6,464(sp)
    8000477a:	6bbe                	ld	s7,456(sp)
    8000477c:	6c1e                	ld	s8,448(sp)
    8000477e:	7cfa                	ld	s9,440(sp)
    80004780:	7d5a                	ld	s10,432(sp)
    80004782:	b3b5                	j	800044ee <exec+0x6e>
    80004784:	e1243423          	sd	s2,-504(s0)
    80004788:	7dba                	ld	s11,424(sp)
    8000478a:	a035                	j	800047b6 <exec+0x336>
    8000478c:	e1243423          	sd	s2,-504(s0)
    80004790:	7dba                	ld	s11,424(sp)
    80004792:	a015                	j	800047b6 <exec+0x336>
    80004794:	e1243423          	sd	s2,-504(s0)
    80004798:	7dba                	ld	s11,424(sp)
    8000479a:	a831                	j	800047b6 <exec+0x336>
    8000479c:	e1243423          	sd	s2,-504(s0)
    800047a0:	7dba                	ld	s11,424(sp)
    800047a2:	a811                	j	800047b6 <exec+0x336>
    800047a4:	e1243423          	sd	s2,-504(s0)
    800047a8:	7dba                	ld	s11,424(sp)
    800047aa:	a031                	j	800047b6 <exec+0x336>
  ip = 0;
    800047ac:	4a01                	li	s4,0
    800047ae:	a021                	j	800047b6 <exec+0x336>
    800047b0:	4a01                	li	s4,0
  if(pagetable)
    800047b2:	a011                	j	800047b6 <exec+0x336>
    800047b4:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    800047b6:	e0843583          	ld	a1,-504(s0)
    800047ba:	855a                	mv	a0,s6
    800047bc:	a62fd0ef          	jal	80001a1e <proc_freepagetable>
  return -1;
    800047c0:	557d                	li	a0,-1
  if(ip){
    800047c2:	000a1b63          	bnez	s4,800047d8 <exec+0x358>
    800047c6:	79be                	ld	s3,488(sp)
    800047c8:	7a1e                	ld	s4,480(sp)
    800047ca:	6afe                	ld	s5,472(sp)
    800047cc:	6b5e                	ld	s6,464(sp)
    800047ce:	6bbe                	ld	s7,456(sp)
    800047d0:	6c1e                	ld	s8,448(sp)
    800047d2:	7cfa                	ld	s9,440(sp)
    800047d4:	7d5a                	ld	s10,432(sp)
    800047d6:	bb21                	j	800044ee <exec+0x6e>
    800047d8:	79be                	ld	s3,488(sp)
    800047da:	6afe                	ld	s5,472(sp)
    800047dc:	6b5e                	ld	s6,464(sp)
    800047de:	6bbe                	ld	s7,456(sp)
    800047e0:	6c1e                	ld	s8,448(sp)
    800047e2:	7cfa                	ld	s9,440(sp)
    800047e4:	7d5a                	ld	s10,432(sp)
    800047e6:	b9ed                	j	800044e0 <exec+0x60>
    800047e8:	6b5e                	ld	s6,464(sp)
    800047ea:	b9dd                	j	800044e0 <exec+0x60>
  sz = sz1;
    800047ec:	e0843983          	ld	s3,-504(s0)
    800047f0:	b595                	j	80004654 <exec+0x1d4>

00000000800047f2 <argfd>:
uint64 sys_off(void);
// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800047f2:	7179                	add	sp,sp,-48
    800047f4:	f406                	sd	ra,40(sp)
    800047f6:	f022                	sd	s0,32(sp)
    800047f8:	ec26                	sd	s1,24(sp)
    800047fa:	e84a                	sd	s2,16(sp)
    800047fc:	1800                	add	s0,sp,48
    800047fe:	892e                	mv	s2,a1
    80004800:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004802:	fdc40593          	add	a1,s0,-36
    80004806:	fa1fd0ef          	jal	800027a6 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000480a:	fdc42703          	lw	a4,-36(s0)
    8000480e:	47bd                	li	a5,15
    80004810:	02e7e963          	bltu	a5,a4,80004842 <argfd+0x50>
    80004814:	8defd0ef          	jal	800018f2 <myproc>
    80004818:	fdc42703          	lw	a4,-36(s0)
    8000481c:	01a70793          	add	a5,a4,26
    80004820:	078e                	sll	a5,a5,0x3
    80004822:	953e                	add	a0,a0,a5
    80004824:	611c                	ld	a5,0(a0)
    80004826:	c385                	beqz	a5,80004846 <argfd+0x54>
    return -1;
  if(pfd)
    80004828:	00090463          	beqz	s2,80004830 <argfd+0x3e>
    *pfd = fd;
    8000482c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004830:	4501                	li	a0,0
  if(pf)
    80004832:	c091                	beqz	s1,80004836 <argfd+0x44>
    *pf = f;
    80004834:	e09c                	sd	a5,0(s1)
}
    80004836:	70a2                	ld	ra,40(sp)
    80004838:	7402                	ld	s0,32(sp)
    8000483a:	64e2                	ld	s1,24(sp)
    8000483c:	6942                	ld	s2,16(sp)
    8000483e:	6145                	add	sp,sp,48
    80004840:	8082                	ret
    return -1;
    80004842:	557d                	li	a0,-1
    80004844:	bfcd                	j	80004836 <argfd+0x44>
    80004846:	557d                	li	a0,-1
    80004848:	b7fd                	j	80004836 <argfd+0x44>

000000008000484a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000484a:	1101                	add	sp,sp,-32
    8000484c:	ec06                	sd	ra,24(sp)
    8000484e:	e822                	sd	s0,16(sp)
    80004850:	e426                	sd	s1,8(sp)
    80004852:	1000                	add	s0,sp,32
    80004854:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004856:	89cfd0ef          	jal	800018f2 <myproc>
    8000485a:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000485c:	0d050793          	add	a5,a0,208
    80004860:	4501                	li	a0,0
    80004862:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004864:	6398                	ld	a4,0(a5)
    80004866:	cb19                	beqz	a4,8000487c <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004868:	2505                	addw	a0,a0,1
    8000486a:	07a1                	add	a5,a5,8
    8000486c:	fed51ce3          	bne	a0,a3,80004864 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004870:	557d                	li	a0,-1
}
    80004872:	60e2                	ld	ra,24(sp)
    80004874:	6442                	ld	s0,16(sp)
    80004876:	64a2                	ld	s1,8(sp)
    80004878:	6105                	add	sp,sp,32
    8000487a:	8082                	ret
      p->ofile[fd] = f;
    8000487c:	01a50793          	add	a5,a0,26
    80004880:	078e                	sll	a5,a5,0x3
    80004882:	963e                	add	a2,a2,a5
    80004884:	e204                	sd	s1,0(a2)
      return fd;
    80004886:	b7f5                	j	80004872 <fdalloc+0x28>

0000000080004888 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004888:	715d                	add	sp,sp,-80
    8000488a:	e486                	sd	ra,72(sp)
    8000488c:	e0a2                	sd	s0,64(sp)
    8000488e:	fc26                	sd	s1,56(sp)
    80004890:	f84a                	sd	s2,48(sp)
    80004892:	f44e                	sd	s3,40(sp)
    80004894:	ec56                	sd	s5,24(sp)
    80004896:	e85a                	sd	s6,16(sp)
    80004898:	0880                	add	s0,sp,80
    8000489a:	8b2e                	mv	s6,a1
    8000489c:	89b2                	mv	s3,a2
    8000489e:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800048a0:	fb040593          	add	a1,s0,-80
    800048a4:	822ff0ef          	jal	800038c6 <nameiparent>
    800048a8:	84aa                	mv	s1,a0
    800048aa:	10050a63          	beqz	a0,800049be <create+0x136>
    return 0;

  ilock(dp);
    800048ae:	925fe0ef          	jal	800031d2 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800048b2:	4601                	li	a2,0
    800048b4:	fb040593          	add	a1,s0,-80
    800048b8:	8526                	mv	a0,s1
    800048ba:	d8dfe0ef          	jal	80003646 <dirlookup>
    800048be:	8aaa                	mv	s5,a0
    800048c0:	c129                	beqz	a0,80004902 <create+0x7a>
    iunlockput(dp);
    800048c2:	8526                	mv	a0,s1
    800048c4:	b19fe0ef          	jal	800033dc <iunlockput>
    ilock(ip);
    800048c8:	8556                	mv	a0,s5
    800048ca:	909fe0ef          	jal	800031d2 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800048ce:	4789                	li	a5,2
    800048d0:	02fb1463          	bne	s6,a5,800048f8 <create+0x70>
    800048d4:	044ad783          	lhu	a5,68(s5)
    800048d8:	37f9                	addw	a5,a5,-2
    800048da:	17c2                	sll	a5,a5,0x30
    800048dc:	93c1                	srl	a5,a5,0x30
    800048de:	4705                	li	a4,1
    800048e0:	00f76c63          	bltu	a4,a5,800048f8 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800048e4:	8556                	mv	a0,s5
    800048e6:	60a6                	ld	ra,72(sp)
    800048e8:	6406                	ld	s0,64(sp)
    800048ea:	74e2                	ld	s1,56(sp)
    800048ec:	7942                	ld	s2,48(sp)
    800048ee:	79a2                	ld	s3,40(sp)
    800048f0:	6ae2                	ld	s5,24(sp)
    800048f2:	6b42                	ld	s6,16(sp)
    800048f4:	6161                	add	sp,sp,80
    800048f6:	8082                	ret
    iunlockput(ip);
    800048f8:	8556                	mv	a0,s5
    800048fa:	ae3fe0ef          	jal	800033dc <iunlockput>
    return 0;
    800048fe:	4a81                	li	s5,0
    80004900:	b7d5                	j	800048e4 <create+0x5c>
    80004902:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004904:	85da                	mv	a1,s6
    80004906:	4088                	lw	a0,0(s1)
    80004908:	f5afe0ef          	jal	80003062 <ialloc>
    8000490c:	8a2a                	mv	s4,a0
    8000490e:	cd15                	beqz	a0,8000494a <create+0xc2>
  ilock(ip);
    80004910:	8c3fe0ef          	jal	800031d2 <ilock>
  ip->major = major;
    80004914:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004918:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000491c:	4905                	li	s2,1
    8000491e:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004922:	8552                	mv	a0,s4
    80004924:	ffafe0ef          	jal	8000311e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004928:	032b0763          	beq	s6,s2,80004956 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    8000492c:	004a2603          	lw	a2,4(s4)
    80004930:	fb040593          	add	a1,s0,-80
    80004934:	8526                	mv	a0,s1
    80004936:	eddfe0ef          	jal	80003812 <dirlink>
    8000493a:	06054563          	bltz	a0,800049a4 <create+0x11c>
  iunlockput(dp);
    8000493e:	8526                	mv	a0,s1
    80004940:	a9dfe0ef          	jal	800033dc <iunlockput>
  return ip;
    80004944:	8ad2                	mv	s5,s4
    80004946:	7a02                	ld	s4,32(sp)
    80004948:	bf71                	j	800048e4 <create+0x5c>
    iunlockput(dp);
    8000494a:	8526                	mv	a0,s1
    8000494c:	a91fe0ef          	jal	800033dc <iunlockput>
    return 0;
    80004950:	8ad2                	mv	s5,s4
    80004952:	7a02                	ld	s4,32(sp)
    80004954:	bf41                	j	800048e4 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004956:	004a2603          	lw	a2,4(s4)
    8000495a:	00003597          	auipc	a1,0x3
    8000495e:	ca658593          	add	a1,a1,-858 # 80007600 <etext+0x600>
    80004962:	8552                	mv	a0,s4
    80004964:	eaffe0ef          	jal	80003812 <dirlink>
    80004968:	02054e63          	bltz	a0,800049a4 <create+0x11c>
    8000496c:	40d0                	lw	a2,4(s1)
    8000496e:	00003597          	auipc	a1,0x3
    80004972:	c9a58593          	add	a1,a1,-870 # 80007608 <etext+0x608>
    80004976:	8552                	mv	a0,s4
    80004978:	e9bfe0ef          	jal	80003812 <dirlink>
    8000497c:	02054463          	bltz	a0,800049a4 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004980:	004a2603          	lw	a2,4(s4)
    80004984:	fb040593          	add	a1,s0,-80
    80004988:	8526                	mv	a0,s1
    8000498a:	e89fe0ef          	jal	80003812 <dirlink>
    8000498e:	00054b63          	bltz	a0,800049a4 <create+0x11c>
    dp->nlink++;  // for ".."
    80004992:	04a4d783          	lhu	a5,74(s1)
    80004996:	2785                	addw	a5,a5,1
    80004998:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000499c:	8526                	mv	a0,s1
    8000499e:	f80fe0ef          	jal	8000311e <iupdate>
    800049a2:	bf71                	j	8000493e <create+0xb6>
  ip->nlink = 0;
    800049a4:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800049a8:	8552                	mv	a0,s4
    800049aa:	f74fe0ef          	jal	8000311e <iupdate>
  iunlockput(ip);
    800049ae:	8552                	mv	a0,s4
    800049b0:	a2dfe0ef          	jal	800033dc <iunlockput>
  iunlockput(dp);
    800049b4:	8526                	mv	a0,s1
    800049b6:	a27fe0ef          	jal	800033dc <iunlockput>
  return 0;
    800049ba:	7a02                	ld	s4,32(sp)
    800049bc:	b725                	j	800048e4 <create+0x5c>
    return 0;
    800049be:	8aaa                	mv	s5,a0
    800049c0:	b715                	j	800048e4 <create+0x5c>

00000000800049c2 <sys_dup>:
{
    800049c2:	7179                	add	sp,sp,-48
    800049c4:	f406                	sd	ra,40(sp)
    800049c6:	f022                	sd	s0,32(sp)
    800049c8:	1800                	add	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800049ca:	fd840613          	add	a2,s0,-40
    800049ce:	4581                	li	a1,0
    800049d0:	4501                	li	a0,0
    800049d2:	e21ff0ef          	jal	800047f2 <argfd>
    return -1;
    800049d6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800049d8:	02054363          	bltz	a0,800049fe <sys_dup+0x3c>
    800049dc:	ec26                	sd	s1,24(sp)
    800049de:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    800049e0:	fd843903          	ld	s2,-40(s0)
    800049e4:	854a                	mv	a0,s2
    800049e6:	e65ff0ef          	jal	8000484a <fdalloc>
    800049ea:	84aa                	mv	s1,a0
    return -1;
    800049ec:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800049ee:	00054d63          	bltz	a0,80004a08 <sys_dup+0x46>
  filedup(f);
    800049f2:	854a                	mv	a0,s2
    800049f4:	c48ff0ef          	jal	80003e3c <filedup>
  return fd;
    800049f8:	87a6                	mv	a5,s1
    800049fa:	64e2                	ld	s1,24(sp)
    800049fc:	6942                	ld	s2,16(sp)
}
    800049fe:	853e                	mv	a0,a5
    80004a00:	70a2                	ld	ra,40(sp)
    80004a02:	7402                	ld	s0,32(sp)
    80004a04:	6145                	add	sp,sp,48
    80004a06:	8082                	ret
    80004a08:	64e2                	ld	s1,24(sp)
    80004a0a:	6942                	ld	s2,16(sp)
    80004a0c:	bfcd                	j	800049fe <sys_dup+0x3c>

0000000080004a0e <sys_read>:
{
    80004a0e:	7179                	add	sp,sp,-48
    80004a10:	f406                	sd	ra,40(sp)
    80004a12:	f022                	sd	s0,32(sp)
    80004a14:	1800                	add	s0,sp,48
  argaddr(1, &p);
    80004a16:	fd840593          	add	a1,s0,-40
    80004a1a:	4505                	li	a0,1
    80004a1c:	da7fd0ef          	jal	800027c2 <argaddr>
  argint(2, &n);
    80004a20:	fe440593          	add	a1,s0,-28
    80004a24:	4509                	li	a0,2
    80004a26:	d81fd0ef          	jal	800027a6 <argint>
  if(argfd(0, 0, &f) < 0)
    80004a2a:	fe840613          	add	a2,s0,-24
    80004a2e:	4581                	li	a1,0
    80004a30:	4501                	li	a0,0
    80004a32:	dc1ff0ef          	jal	800047f2 <argfd>
    80004a36:	87aa                	mv	a5,a0
    return -1;
    80004a38:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004a3a:	0007ca63          	bltz	a5,80004a4e <sys_read+0x40>
  return fileread(f, p, n);
    80004a3e:	fe442603          	lw	a2,-28(s0)
    80004a42:	fd843583          	ld	a1,-40(s0)
    80004a46:	fe843503          	ld	a0,-24(s0)
    80004a4a:	d58ff0ef          	jal	80003fa2 <fileread>
}
    80004a4e:	70a2                	ld	ra,40(sp)
    80004a50:	7402                	ld	s0,32(sp)
    80004a52:	6145                	add	sp,sp,48
    80004a54:	8082                	ret

0000000080004a56 <sys_write>:
{
    80004a56:	7179                	add	sp,sp,-48
    80004a58:	f406                	sd	ra,40(sp)
    80004a5a:	f022                	sd	s0,32(sp)
    80004a5c:	1800                	add	s0,sp,48
  argaddr(1, &p);
    80004a5e:	fd840593          	add	a1,s0,-40
    80004a62:	4505                	li	a0,1
    80004a64:	d5ffd0ef          	jal	800027c2 <argaddr>
  argint(2, &n);
    80004a68:	fe440593          	add	a1,s0,-28
    80004a6c:	4509                	li	a0,2
    80004a6e:	d39fd0ef          	jal	800027a6 <argint>
  if(argfd(0, 0, &f) < 0)
    80004a72:	fe840613          	add	a2,s0,-24
    80004a76:	4581                	li	a1,0
    80004a78:	4501                	li	a0,0
    80004a7a:	d79ff0ef          	jal	800047f2 <argfd>
    80004a7e:	87aa                	mv	a5,a0
    return -1;
    80004a80:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004a82:	0007ca63          	bltz	a5,80004a96 <sys_write+0x40>
  return filewrite(f, p, n);
    80004a86:	fe442603          	lw	a2,-28(s0)
    80004a8a:	fd843583          	ld	a1,-40(s0)
    80004a8e:	fe843503          	ld	a0,-24(s0)
    80004a92:	dceff0ef          	jal	80004060 <filewrite>
}
    80004a96:	70a2                	ld	ra,40(sp)
    80004a98:	7402                	ld	s0,32(sp)
    80004a9a:	6145                	add	sp,sp,48
    80004a9c:	8082                	ret

0000000080004a9e <sys_close>:
{
    80004a9e:	1101                	add	sp,sp,-32
    80004aa0:	ec06                	sd	ra,24(sp)
    80004aa2:	e822                	sd	s0,16(sp)
    80004aa4:	1000                	add	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004aa6:	fe040613          	add	a2,s0,-32
    80004aaa:	fec40593          	add	a1,s0,-20
    80004aae:	4501                	li	a0,0
    80004ab0:	d43ff0ef          	jal	800047f2 <argfd>
    return -1;
    80004ab4:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004ab6:	02054063          	bltz	a0,80004ad6 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004aba:	e39fc0ef          	jal	800018f2 <myproc>
    80004abe:	fec42783          	lw	a5,-20(s0)
    80004ac2:	07e9                	add	a5,a5,26
    80004ac4:	078e                	sll	a5,a5,0x3
    80004ac6:	953e                	add	a0,a0,a5
    80004ac8:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004acc:	fe043503          	ld	a0,-32(s0)
    80004ad0:	bb2ff0ef          	jal	80003e82 <fileclose>
  return 0;
    80004ad4:	4781                	li	a5,0
}
    80004ad6:	853e                	mv	a0,a5
    80004ad8:	60e2                	ld	ra,24(sp)
    80004ada:	6442                	ld	s0,16(sp)
    80004adc:	6105                	add	sp,sp,32
    80004ade:	8082                	ret

0000000080004ae0 <sys_fstat>:
{
    80004ae0:	1101                	add	sp,sp,-32
    80004ae2:	ec06                	sd	ra,24(sp)
    80004ae4:	e822                	sd	s0,16(sp)
    80004ae6:	1000                	add	s0,sp,32
  argaddr(1, &st);
    80004ae8:	fe040593          	add	a1,s0,-32
    80004aec:	4505                	li	a0,1
    80004aee:	cd5fd0ef          	jal	800027c2 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004af2:	fe840613          	add	a2,s0,-24
    80004af6:	4581                	li	a1,0
    80004af8:	4501                	li	a0,0
    80004afa:	cf9ff0ef          	jal	800047f2 <argfd>
    80004afe:	87aa                	mv	a5,a0
    return -1;
    80004b00:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004b02:	0007c863          	bltz	a5,80004b12 <sys_fstat+0x32>
  return filestat(f, st);
    80004b06:	fe043583          	ld	a1,-32(s0)
    80004b0a:	fe843503          	ld	a0,-24(s0)
    80004b0e:	c36ff0ef          	jal	80003f44 <filestat>
}
    80004b12:	60e2                	ld	ra,24(sp)
    80004b14:	6442                	ld	s0,16(sp)
    80004b16:	6105                	add	sp,sp,32
    80004b18:	8082                	ret

0000000080004b1a <sys_link>:
{
    80004b1a:	7169                	add	sp,sp,-304
    80004b1c:	f606                	sd	ra,296(sp)
    80004b1e:	f222                	sd	s0,288(sp)
    80004b20:	1a00                	add	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004b22:	08000613          	li	a2,128
    80004b26:	ed040593          	add	a1,s0,-304
    80004b2a:	4501                	li	a0,0
    80004b2c:	cb3fd0ef          	jal	800027de <argstr>
    return -1;
    80004b30:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004b32:	0c054e63          	bltz	a0,80004c0e <sys_link+0xf4>
    80004b36:	08000613          	li	a2,128
    80004b3a:	f5040593          	add	a1,s0,-176
    80004b3e:	4505                	li	a0,1
    80004b40:	c9ffd0ef          	jal	800027de <argstr>
    return -1;
    80004b44:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004b46:	0c054463          	bltz	a0,80004c0e <sys_link+0xf4>
    80004b4a:	ee26                	sd	s1,280(sp)
  begin_op();
    80004b4c:	f1dfe0ef          	jal	80003a68 <begin_op>
  if((ip = namei(old)) == 0){
    80004b50:	ed040513          	add	a0,s0,-304
    80004b54:	d59fe0ef          	jal	800038ac <namei>
    80004b58:	84aa                	mv	s1,a0
    80004b5a:	c53d                	beqz	a0,80004bc8 <sys_link+0xae>
  ilock(ip);
    80004b5c:	e76fe0ef          	jal	800031d2 <ilock>
  if(ip->type == T_DIR){
    80004b60:	04449703          	lh	a4,68(s1)
    80004b64:	4785                	li	a5,1
    80004b66:	06f70663          	beq	a4,a5,80004bd2 <sys_link+0xb8>
    80004b6a:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004b6c:	04a4d783          	lhu	a5,74(s1)
    80004b70:	2785                	addw	a5,a5,1
    80004b72:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004b76:	8526                	mv	a0,s1
    80004b78:	da6fe0ef          	jal	8000311e <iupdate>
  iunlock(ip);
    80004b7c:	8526                	mv	a0,s1
    80004b7e:	f02fe0ef          	jal	80003280 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004b82:	fd040593          	add	a1,s0,-48
    80004b86:	f5040513          	add	a0,s0,-176
    80004b8a:	d3dfe0ef          	jal	800038c6 <nameiparent>
    80004b8e:	892a                	mv	s2,a0
    80004b90:	cd21                	beqz	a0,80004be8 <sys_link+0xce>
  ilock(dp);
    80004b92:	e40fe0ef          	jal	800031d2 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004b96:	00092703          	lw	a4,0(s2)
    80004b9a:	409c                	lw	a5,0(s1)
    80004b9c:	04f71363          	bne	a4,a5,80004be2 <sys_link+0xc8>
    80004ba0:	40d0                	lw	a2,4(s1)
    80004ba2:	fd040593          	add	a1,s0,-48
    80004ba6:	854a                	mv	a0,s2
    80004ba8:	c6bfe0ef          	jal	80003812 <dirlink>
    80004bac:	02054b63          	bltz	a0,80004be2 <sys_link+0xc8>
  iunlockput(dp);
    80004bb0:	854a                	mv	a0,s2
    80004bb2:	82bfe0ef          	jal	800033dc <iunlockput>
  iput(ip);
    80004bb6:	8526                	mv	a0,s1
    80004bb8:	f9cfe0ef          	jal	80003354 <iput>
  end_op();
    80004bbc:	f17fe0ef          	jal	80003ad2 <end_op>
  return 0;
    80004bc0:	4781                	li	a5,0
    80004bc2:	64f2                	ld	s1,280(sp)
    80004bc4:	6952                	ld	s2,272(sp)
    80004bc6:	a0a1                	j	80004c0e <sys_link+0xf4>
    end_op();
    80004bc8:	f0bfe0ef          	jal	80003ad2 <end_op>
    return -1;
    80004bcc:	57fd                	li	a5,-1
    80004bce:	64f2                	ld	s1,280(sp)
    80004bd0:	a83d                	j	80004c0e <sys_link+0xf4>
    iunlockput(ip);
    80004bd2:	8526                	mv	a0,s1
    80004bd4:	809fe0ef          	jal	800033dc <iunlockput>
    end_op();
    80004bd8:	efbfe0ef          	jal	80003ad2 <end_op>
    return -1;
    80004bdc:	57fd                	li	a5,-1
    80004bde:	64f2                	ld	s1,280(sp)
    80004be0:	a03d                	j	80004c0e <sys_link+0xf4>
    iunlockput(dp);
    80004be2:	854a                	mv	a0,s2
    80004be4:	ff8fe0ef          	jal	800033dc <iunlockput>
  ilock(ip);
    80004be8:	8526                	mv	a0,s1
    80004bea:	de8fe0ef          	jal	800031d2 <ilock>
  ip->nlink--;
    80004bee:	04a4d783          	lhu	a5,74(s1)
    80004bf2:	37fd                	addw	a5,a5,-1
    80004bf4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004bf8:	8526                	mv	a0,s1
    80004bfa:	d24fe0ef          	jal	8000311e <iupdate>
  iunlockput(ip);
    80004bfe:	8526                	mv	a0,s1
    80004c00:	fdcfe0ef          	jal	800033dc <iunlockput>
  end_op();
    80004c04:	ecffe0ef          	jal	80003ad2 <end_op>
  return -1;
    80004c08:	57fd                	li	a5,-1
    80004c0a:	64f2                	ld	s1,280(sp)
    80004c0c:	6952                	ld	s2,272(sp)
}
    80004c0e:	853e                	mv	a0,a5
    80004c10:	70b2                	ld	ra,296(sp)
    80004c12:	7412                	ld	s0,288(sp)
    80004c14:	6155                	add	sp,sp,304
    80004c16:	8082                	ret

0000000080004c18 <sys_unlink>:
{
    80004c18:	7151                	add	sp,sp,-240
    80004c1a:	f586                	sd	ra,232(sp)
    80004c1c:	f1a2                	sd	s0,224(sp)
    80004c1e:	1980                	add	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004c20:	08000613          	li	a2,128
    80004c24:	f3040593          	add	a1,s0,-208
    80004c28:	4501                	li	a0,0
    80004c2a:	bb5fd0ef          	jal	800027de <argstr>
    80004c2e:	16054063          	bltz	a0,80004d8e <sys_unlink+0x176>
    80004c32:	eda6                	sd	s1,216(sp)
  begin_op();
    80004c34:	e35fe0ef          	jal	80003a68 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004c38:	fb040593          	add	a1,s0,-80
    80004c3c:	f3040513          	add	a0,s0,-208
    80004c40:	c87fe0ef          	jal	800038c6 <nameiparent>
    80004c44:	84aa                	mv	s1,a0
    80004c46:	c945                	beqz	a0,80004cf6 <sys_unlink+0xde>
  ilock(dp);
    80004c48:	d8afe0ef          	jal	800031d2 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004c4c:	00003597          	auipc	a1,0x3
    80004c50:	9b458593          	add	a1,a1,-1612 # 80007600 <etext+0x600>
    80004c54:	fb040513          	add	a0,s0,-80
    80004c58:	9d9fe0ef          	jal	80003630 <namecmp>
    80004c5c:	10050e63          	beqz	a0,80004d78 <sys_unlink+0x160>
    80004c60:	00003597          	auipc	a1,0x3
    80004c64:	9a858593          	add	a1,a1,-1624 # 80007608 <etext+0x608>
    80004c68:	fb040513          	add	a0,s0,-80
    80004c6c:	9c5fe0ef          	jal	80003630 <namecmp>
    80004c70:	10050463          	beqz	a0,80004d78 <sys_unlink+0x160>
    80004c74:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004c76:	f2c40613          	add	a2,s0,-212
    80004c7a:	fb040593          	add	a1,s0,-80
    80004c7e:	8526                	mv	a0,s1
    80004c80:	9c7fe0ef          	jal	80003646 <dirlookup>
    80004c84:	892a                	mv	s2,a0
    80004c86:	0e050863          	beqz	a0,80004d76 <sys_unlink+0x15e>
  ilock(ip);
    80004c8a:	d48fe0ef          	jal	800031d2 <ilock>
  if(ip->nlink < 1)
    80004c8e:	04a91783          	lh	a5,74(s2)
    80004c92:	06f05763          	blez	a5,80004d00 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004c96:	04491703          	lh	a4,68(s2)
    80004c9a:	4785                	li	a5,1
    80004c9c:	06f70963          	beq	a4,a5,80004d0e <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80004ca0:	4641                	li	a2,16
    80004ca2:	4581                	li	a1,0
    80004ca4:	fc040513          	add	a0,s0,-64
    80004ca8:	820fc0ef          	jal	80000cc8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004cac:	4741                	li	a4,16
    80004cae:	f2c42683          	lw	a3,-212(s0)
    80004cb2:	fc040613          	add	a2,s0,-64
    80004cb6:	4581                	li	a1,0
    80004cb8:	8526                	mv	a0,s1
    80004cba:	869fe0ef          	jal	80003522 <writei>
    80004cbe:	47c1                	li	a5,16
    80004cc0:	08f51b63          	bne	a0,a5,80004d56 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80004cc4:	04491703          	lh	a4,68(s2)
    80004cc8:	4785                	li	a5,1
    80004cca:	08f70d63          	beq	a4,a5,80004d64 <sys_unlink+0x14c>
  iunlockput(dp);
    80004cce:	8526                	mv	a0,s1
    80004cd0:	f0cfe0ef          	jal	800033dc <iunlockput>
  ip->nlink--;
    80004cd4:	04a95783          	lhu	a5,74(s2)
    80004cd8:	37fd                	addw	a5,a5,-1
    80004cda:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004cde:	854a                	mv	a0,s2
    80004ce0:	c3efe0ef          	jal	8000311e <iupdate>
  iunlockput(ip);
    80004ce4:	854a                	mv	a0,s2
    80004ce6:	ef6fe0ef          	jal	800033dc <iunlockput>
  end_op();
    80004cea:	de9fe0ef          	jal	80003ad2 <end_op>
  return 0;
    80004cee:	4501                	li	a0,0
    80004cf0:	64ee                	ld	s1,216(sp)
    80004cf2:	694e                	ld	s2,208(sp)
    80004cf4:	a849                	j	80004d86 <sys_unlink+0x16e>
    end_op();
    80004cf6:	dddfe0ef          	jal	80003ad2 <end_op>
    return -1;
    80004cfa:	557d                	li	a0,-1
    80004cfc:	64ee                	ld	s1,216(sp)
    80004cfe:	a061                	j	80004d86 <sys_unlink+0x16e>
    80004d00:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80004d02:	00003517          	auipc	a0,0x3
    80004d06:	90e50513          	add	a0,a0,-1778 # 80007610 <etext+0x610>
    80004d0a:	a8bfb0ef          	jal	80000794 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004d0e:	04c92703          	lw	a4,76(s2)
    80004d12:	02000793          	li	a5,32
    80004d16:	f8e7f5e3          	bgeu	a5,a4,80004ca0 <sys_unlink+0x88>
    80004d1a:	e5ce                	sd	s3,200(sp)
    80004d1c:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004d20:	4741                	li	a4,16
    80004d22:	86ce                	mv	a3,s3
    80004d24:	f1840613          	add	a2,s0,-232
    80004d28:	4581                	li	a1,0
    80004d2a:	854a                	mv	a0,s2
    80004d2c:	efafe0ef          	jal	80003426 <readi>
    80004d30:	47c1                	li	a5,16
    80004d32:	00f51c63          	bne	a0,a5,80004d4a <sys_unlink+0x132>
    if(de.inum != 0)
    80004d36:	f1845783          	lhu	a5,-232(s0)
    80004d3a:	efa1                	bnez	a5,80004d92 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004d3c:	29c1                	addw	s3,s3,16
    80004d3e:	04c92783          	lw	a5,76(s2)
    80004d42:	fcf9efe3          	bltu	s3,a5,80004d20 <sys_unlink+0x108>
    80004d46:	69ae                	ld	s3,200(sp)
    80004d48:	bfa1                	j	80004ca0 <sys_unlink+0x88>
      panic("isdirempty: readi");
    80004d4a:	00003517          	auipc	a0,0x3
    80004d4e:	8de50513          	add	a0,a0,-1826 # 80007628 <etext+0x628>
    80004d52:	a43fb0ef          	jal	80000794 <panic>
    80004d56:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80004d58:	00003517          	auipc	a0,0x3
    80004d5c:	8e850513          	add	a0,a0,-1816 # 80007640 <etext+0x640>
    80004d60:	a35fb0ef          	jal	80000794 <panic>
    dp->nlink--;
    80004d64:	04a4d783          	lhu	a5,74(s1)
    80004d68:	37fd                	addw	a5,a5,-1
    80004d6a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004d6e:	8526                	mv	a0,s1
    80004d70:	baefe0ef          	jal	8000311e <iupdate>
    80004d74:	bfa9                	j	80004cce <sys_unlink+0xb6>
    80004d76:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80004d78:	8526                	mv	a0,s1
    80004d7a:	e62fe0ef          	jal	800033dc <iunlockput>
  end_op();
    80004d7e:	d55fe0ef          	jal	80003ad2 <end_op>
  return -1;
    80004d82:	557d                	li	a0,-1
    80004d84:	64ee                	ld	s1,216(sp)
}
    80004d86:	70ae                	ld	ra,232(sp)
    80004d88:	740e                	ld	s0,224(sp)
    80004d8a:	616d                	add	sp,sp,240
    80004d8c:	8082                	ret
    return -1;
    80004d8e:	557d                	li	a0,-1
    80004d90:	bfdd                	j	80004d86 <sys_unlink+0x16e>
    iunlockput(ip);
    80004d92:	854a                	mv	a0,s2
    80004d94:	e48fe0ef          	jal	800033dc <iunlockput>
    goto bad;
    80004d98:	694e                	ld	s2,208(sp)
    80004d9a:	69ae                	ld	s3,200(sp)
    80004d9c:	bff1                	j	80004d78 <sys_unlink+0x160>

0000000080004d9e <sys_open>:

uint64
sys_open(void)
{
    80004d9e:	7131                	add	sp,sp,-192
    80004da0:	fd06                	sd	ra,184(sp)
    80004da2:	f922                	sd	s0,176(sp)
    80004da4:	0180                	add	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004da6:	f4c40593          	add	a1,s0,-180
    80004daa:	4505                	li	a0,1
    80004dac:	9fbfd0ef          	jal	800027a6 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004db0:	08000613          	li	a2,128
    80004db4:	f5040593          	add	a1,s0,-176
    80004db8:	4501                	li	a0,0
    80004dba:	a25fd0ef          	jal	800027de <argstr>
    80004dbe:	87aa                	mv	a5,a0
    return -1;
    80004dc0:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004dc2:	0a07c263          	bltz	a5,80004e66 <sys_open+0xc8>
    80004dc6:	f526                	sd	s1,168(sp)

  begin_op();
    80004dc8:	ca1fe0ef          	jal	80003a68 <begin_op>

  if(omode & O_CREATE){
    80004dcc:	f4c42783          	lw	a5,-180(s0)
    80004dd0:	2007f793          	and	a5,a5,512
    80004dd4:	c3d5                	beqz	a5,80004e78 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80004dd6:	4681                	li	a3,0
    80004dd8:	4601                	li	a2,0
    80004dda:	4589                	li	a1,2
    80004ddc:	f5040513          	add	a0,s0,-176
    80004de0:	aa9ff0ef          	jal	80004888 <create>
    80004de4:	84aa                	mv	s1,a0
    if(ip == 0){
    80004de6:	c541                	beqz	a0,80004e6e <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004de8:	04449703          	lh	a4,68(s1)
    80004dec:	478d                	li	a5,3
    80004dee:	00f71763          	bne	a4,a5,80004dfc <sys_open+0x5e>
    80004df2:	0464d703          	lhu	a4,70(s1)
    80004df6:	47a5                	li	a5,9
    80004df8:	0ae7ed63          	bltu	a5,a4,80004eb2 <sys_open+0x114>
    80004dfc:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004dfe:	fe1fe0ef          	jal	80003dde <filealloc>
    80004e02:	892a                	mv	s2,a0
    80004e04:	c179                	beqz	a0,80004eca <sys_open+0x12c>
    80004e06:	ed4e                	sd	s3,152(sp)
    80004e08:	a43ff0ef          	jal	8000484a <fdalloc>
    80004e0c:	89aa                	mv	s3,a0
    80004e0e:	0a054a63          	bltz	a0,80004ec2 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004e12:	04449703          	lh	a4,68(s1)
    80004e16:	478d                	li	a5,3
    80004e18:	0cf70263          	beq	a4,a5,80004edc <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004e1c:	4789                	li	a5,2
    80004e1e:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80004e22:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80004e26:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80004e2a:	f4c42783          	lw	a5,-180(s0)
    80004e2e:	0017c713          	xor	a4,a5,1
    80004e32:	8b05                	and	a4,a4,1
    80004e34:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004e38:	0037f713          	and	a4,a5,3
    80004e3c:	00e03733          	snez	a4,a4
    80004e40:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004e44:	4007f793          	and	a5,a5,1024
    80004e48:	c791                	beqz	a5,80004e54 <sys_open+0xb6>
    80004e4a:	04449703          	lh	a4,68(s1)
    80004e4e:	4789                	li	a5,2
    80004e50:	08f70d63          	beq	a4,a5,80004eea <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80004e54:	8526                	mv	a0,s1
    80004e56:	c2afe0ef          	jal	80003280 <iunlock>
  end_op();
    80004e5a:	c79fe0ef          	jal	80003ad2 <end_op>

  return fd;
    80004e5e:	854e                	mv	a0,s3
    80004e60:	74aa                	ld	s1,168(sp)
    80004e62:	790a                	ld	s2,160(sp)
    80004e64:	69ea                	ld	s3,152(sp)
}
    80004e66:	70ea                	ld	ra,184(sp)
    80004e68:	744a                	ld	s0,176(sp)
    80004e6a:	6129                	add	sp,sp,192
    80004e6c:	8082                	ret
      end_op();
    80004e6e:	c65fe0ef          	jal	80003ad2 <end_op>
      return -1;
    80004e72:	557d                	li	a0,-1
    80004e74:	74aa                	ld	s1,168(sp)
    80004e76:	bfc5                	j	80004e66 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    80004e78:	f5040513          	add	a0,s0,-176
    80004e7c:	a31fe0ef          	jal	800038ac <namei>
    80004e80:	84aa                	mv	s1,a0
    80004e82:	c11d                	beqz	a0,80004ea8 <sys_open+0x10a>
    ilock(ip);
    80004e84:	b4efe0ef          	jal	800031d2 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004e88:	04449703          	lh	a4,68(s1)
    80004e8c:	4785                	li	a5,1
    80004e8e:	f4f71de3          	bne	a4,a5,80004de8 <sys_open+0x4a>
    80004e92:	f4c42783          	lw	a5,-180(s0)
    80004e96:	d3bd                	beqz	a5,80004dfc <sys_open+0x5e>
      iunlockput(ip);
    80004e98:	8526                	mv	a0,s1
    80004e9a:	d42fe0ef          	jal	800033dc <iunlockput>
      end_op();
    80004e9e:	c35fe0ef          	jal	80003ad2 <end_op>
      return -1;
    80004ea2:	557d                	li	a0,-1
    80004ea4:	74aa                	ld	s1,168(sp)
    80004ea6:	b7c1                	j	80004e66 <sys_open+0xc8>
      end_op();
    80004ea8:	c2bfe0ef          	jal	80003ad2 <end_op>
      return -1;
    80004eac:	557d                	li	a0,-1
    80004eae:	74aa                	ld	s1,168(sp)
    80004eb0:	bf5d                	j	80004e66 <sys_open+0xc8>
    iunlockput(ip);
    80004eb2:	8526                	mv	a0,s1
    80004eb4:	d28fe0ef          	jal	800033dc <iunlockput>
    end_op();
    80004eb8:	c1bfe0ef          	jal	80003ad2 <end_op>
    return -1;
    80004ebc:	557d                	li	a0,-1
    80004ebe:	74aa                	ld	s1,168(sp)
    80004ec0:	b75d                	j	80004e66 <sys_open+0xc8>
      fileclose(f);
    80004ec2:	854a                	mv	a0,s2
    80004ec4:	fbffe0ef          	jal	80003e82 <fileclose>
    80004ec8:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80004eca:	8526                	mv	a0,s1
    80004ecc:	d10fe0ef          	jal	800033dc <iunlockput>
    end_op();
    80004ed0:	c03fe0ef          	jal	80003ad2 <end_op>
    return -1;
    80004ed4:	557d                	li	a0,-1
    80004ed6:	74aa                	ld	s1,168(sp)
    80004ed8:	790a                	ld	s2,160(sp)
    80004eda:	b771                	j	80004e66 <sys_open+0xc8>
    f->type = FD_DEVICE;
    80004edc:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80004ee0:	04649783          	lh	a5,70(s1)
    80004ee4:	02f91223          	sh	a5,36(s2)
    80004ee8:	bf3d                	j	80004e26 <sys_open+0x88>
    itrunc(ip);
    80004eea:	8526                	mv	a0,s1
    80004eec:	bd4fe0ef          	jal	800032c0 <itrunc>
    80004ef0:	b795                	j	80004e54 <sys_open+0xb6>

0000000080004ef2 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80004ef2:	7175                	add	sp,sp,-144
    80004ef4:	e506                	sd	ra,136(sp)
    80004ef6:	e122                	sd	s0,128(sp)
    80004ef8:	0900                	add	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004efa:	b6ffe0ef          	jal	80003a68 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004efe:	08000613          	li	a2,128
    80004f02:	f7040593          	add	a1,s0,-144
    80004f06:	4501                	li	a0,0
    80004f08:	8d7fd0ef          	jal	800027de <argstr>
    80004f0c:	02054363          	bltz	a0,80004f32 <sys_mkdir+0x40>
    80004f10:	4681                	li	a3,0
    80004f12:	4601                	li	a2,0
    80004f14:	4585                	li	a1,1
    80004f16:	f7040513          	add	a0,s0,-144
    80004f1a:	96fff0ef          	jal	80004888 <create>
    80004f1e:	c911                	beqz	a0,80004f32 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004f20:	cbcfe0ef          	jal	800033dc <iunlockput>
  end_op();
    80004f24:	baffe0ef          	jal	80003ad2 <end_op>
  return 0;
    80004f28:	4501                	li	a0,0
}
    80004f2a:	60aa                	ld	ra,136(sp)
    80004f2c:	640a                	ld	s0,128(sp)
    80004f2e:	6149                	add	sp,sp,144
    80004f30:	8082                	ret
    end_op();
    80004f32:	ba1fe0ef          	jal	80003ad2 <end_op>
    return -1;
    80004f36:	557d                	li	a0,-1
    80004f38:	bfcd                	j	80004f2a <sys_mkdir+0x38>

0000000080004f3a <sys_mknod>:

uint64
sys_mknod(void)
{
    80004f3a:	7135                	add	sp,sp,-160
    80004f3c:	ed06                	sd	ra,152(sp)
    80004f3e:	e922                	sd	s0,144(sp)
    80004f40:	1100                	add	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80004f42:	b27fe0ef          	jal	80003a68 <begin_op>
  argint(1, &major);
    80004f46:	f6c40593          	add	a1,s0,-148
    80004f4a:	4505                	li	a0,1
    80004f4c:	85bfd0ef          	jal	800027a6 <argint>
  argint(2, &minor);
    80004f50:	f6840593          	add	a1,s0,-152
    80004f54:	4509                	li	a0,2
    80004f56:	851fd0ef          	jal	800027a6 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004f5a:	08000613          	li	a2,128
    80004f5e:	f7040593          	add	a1,s0,-144
    80004f62:	4501                	li	a0,0
    80004f64:	87bfd0ef          	jal	800027de <argstr>
    80004f68:	02054563          	bltz	a0,80004f92 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80004f6c:	f6841683          	lh	a3,-152(s0)
    80004f70:	f6c41603          	lh	a2,-148(s0)
    80004f74:	458d                	li	a1,3
    80004f76:	f7040513          	add	a0,s0,-144
    80004f7a:	90fff0ef          	jal	80004888 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004f7e:	c911                	beqz	a0,80004f92 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004f80:	c5cfe0ef          	jal	800033dc <iunlockput>
  end_op();
    80004f84:	b4ffe0ef          	jal	80003ad2 <end_op>
  return 0;
    80004f88:	4501                	li	a0,0
}
    80004f8a:	60ea                	ld	ra,152(sp)
    80004f8c:	644a                	ld	s0,144(sp)
    80004f8e:	610d                	add	sp,sp,160
    80004f90:	8082                	ret
    end_op();
    80004f92:	b41fe0ef          	jal	80003ad2 <end_op>
    return -1;
    80004f96:	557d                	li	a0,-1
    80004f98:	bfcd                	j	80004f8a <sys_mknod+0x50>

0000000080004f9a <sys_chdir>:

uint64
sys_chdir(void)
{
    80004f9a:	7135                	add	sp,sp,-160
    80004f9c:	ed06                	sd	ra,152(sp)
    80004f9e:	e922                	sd	s0,144(sp)
    80004fa0:	e14a                	sd	s2,128(sp)
    80004fa2:	1100                	add	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80004fa4:	94ffc0ef          	jal	800018f2 <myproc>
    80004fa8:	892a                	mv	s2,a0
  
  begin_op();
    80004faa:	abffe0ef          	jal	80003a68 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80004fae:	08000613          	li	a2,128
    80004fb2:	f6040593          	add	a1,s0,-160
    80004fb6:	4501                	li	a0,0
    80004fb8:	827fd0ef          	jal	800027de <argstr>
    80004fbc:	04054363          	bltz	a0,80005002 <sys_chdir+0x68>
    80004fc0:	e526                	sd	s1,136(sp)
    80004fc2:	f6040513          	add	a0,s0,-160
    80004fc6:	8e7fe0ef          	jal	800038ac <namei>
    80004fca:	84aa                	mv	s1,a0
    80004fcc:	c915                	beqz	a0,80005000 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80004fce:	a04fe0ef          	jal	800031d2 <ilock>
  if(ip->type != T_DIR){
    80004fd2:	04449703          	lh	a4,68(s1)
    80004fd6:	4785                	li	a5,1
    80004fd8:	02f71963          	bne	a4,a5,8000500a <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80004fdc:	8526                	mv	a0,s1
    80004fde:	aa2fe0ef          	jal	80003280 <iunlock>
  iput(p->cwd);
    80004fe2:	15093503          	ld	a0,336(s2)
    80004fe6:	b6efe0ef          	jal	80003354 <iput>
  end_op();
    80004fea:	ae9fe0ef          	jal	80003ad2 <end_op>
  p->cwd = ip;
    80004fee:	14993823          	sd	s1,336(s2)
  return 0;
    80004ff2:	4501                	li	a0,0
    80004ff4:	64aa                	ld	s1,136(sp)
}
    80004ff6:	60ea                	ld	ra,152(sp)
    80004ff8:	644a                	ld	s0,144(sp)
    80004ffa:	690a                	ld	s2,128(sp)
    80004ffc:	610d                	add	sp,sp,160
    80004ffe:	8082                	ret
    80005000:	64aa                	ld	s1,136(sp)
    end_op();
    80005002:	ad1fe0ef          	jal	80003ad2 <end_op>
    return -1;
    80005006:	557d                	li	a0,-1
    80005008:	b7fd                	j	80004ff6 <sys_chdir+0x5c>
    iunlockput(ip);
    8000500a:	8526                	mv	a0,s1
    8000500c:	bd0fe0ef          	jal	800033dc <iunlockput>
    end_op();
    80005010:	ac3fe0ef          	jal	80003ad2 <end_op>
    return -1;
    80005014:	557d                	li	a0,-1
    80005016:	64aa                	ld	s1,136(sp)
    80005018:	bff9                	j	80004ff6 <sys_chdir+0x5c>

000000008000501a <sys_exec>:

uint64
sys_exec(void)
{
    8000501a:	7121                	add	sp,sp,-448
    8000501c:	ff06                	sd	ra,440(sp)
    8000501e:	fb22                	sd	s0,432(sp)
    80005020:	0380                	add	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005022:	e4840593          	add	a1,s0,-440
    80005026:	4505                	li	a0,1
    80005028:	f9afd0ef          	jal	800027c2 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000502c:	08000613          	li	a2,128
    80005030:	f5040593          	add	a1,s0,-176
    80005034:	4501                	li	a0,0
    80005036:	fa8fd0ef          	jal	800027de <argstr>
    8000503a:	87aa                	mv	a5,a0
    return -1;
    8000503c:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000503e:	0c07c463          	bltz	a5,80005106 <sys_exec+0xec>
    80005042:	f726                	sd	s1,424(sp)
    80005044:	f34a                	sd	s2,416(sp)
    80005046:	ef4e                	sd	s3,408(sp)
    80005048:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000504a:	10000613          	li	a2,256
    8000504e:	4581                	li	a1,0
    80005050:	e5040513          	add	a0,s0,-432
    80005054:	c75fb0ef          	jal	80000cc8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005058:	e5040493          	add	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    8000505c:	89a6                	mv	s3,s1
    8000505e:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005060:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005064:	00391513          	sll	a0,s2,0x3
    80005068:	e4040593          	add	a1,s0,-448
    8000506c:	e4843783          	ld	a5,-440(s0)
    80005070:	953e                	add	a0,a0,a5
    80005072:	eaafd0ef          	jal	8000271c <fetchaddr>
    80005076:	02054663          	bltz	a0,800050a2 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    8000507a:	e4043783          	ld	a5,-448(s0)
    8000507e:	c3a9                	beqz	a5,800050c0 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005080:	aa5fb0ef          	jal	80000b24 <kalloc>
    80005084:	85aa                	mv	a1,a0
    80005086:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000508a:	cd01                	beqz	a0,800050a2 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000508c:	6605                	lui	a2,0x1
    8000508e:	e4043503          	ld	a0,-448(s0)
    80005092:	ed4fd0ef          	jal	80002766 <fetchstr>
    80005096:	00054663          	bltz	a0,800050a2 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    8000509a:	0905                	add	s2,s2,1
    8000509c:	09a1                	add	s3,s3,8
    8000509e:	fd4913e3          	bne	s2,s4,80005064 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800050a2:	f5040913          	add	s2,s0,-176
    800050a6:	6088                	ld	a0,0(s1)
    800050a8:	c931                	beqz	a0,800050fc <sys_exec+0xe2>
    kfree(argv[i]);
    800050aa:	999fb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800050ae:	04a1                	add	s1,s1,8
    800050b0:	ff249be3          	bne	s1,s2,800050a6 <sys_exec+0x8c>
  return -1;
    800050b4:	557d                	li	a0,-1
    800050b6:	74ba                	ld	s1,424(sp)
    800050b8:	791a                	ld	s2,416(sp)
    800050ba:	69fa                	ld	s3,408(sp)
    800050bc:	6a5a                	ld	s4,400(sp)
    800050be:	a0a1                	j	80005106 <sys_exec+0xec>
      argv[i] = 0;
    800050c0:	0009079b          	sext.w	a5,s2
    800050c4:	078e                	sll	a5,a5,0x3
    800050c6:	fd078793          	add	a5,a5,-48
    800050ca:	97a2                	add	a5,a5,s0
    800050cc:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    800050d0:	e5040593          	add	a1,s0,-432
    800050d4:	f5040513          	add	a0,s0,-176
    800050d8:	ba8ff0ef          	jal	80004480 <exec>
    800050dc:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800050de:	f5040993          	add	s3,s0,-176
    800050e2:	6088                	ld	a0,0(s1)
    800050e4:	c511                	beqz	a0,800050f0 <sys_exec+0xd6>
    kfree(argv[i]);
    800050e6:	95dfb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800050ea:	04a1                	add	s1,s1,8
    800050ec:	ff349be3          	bne	s1,s3,800050e2 <sys_exec+0xc8>
  return ret;
    800050f0:	854a                	mv	a0,s2
    800050f2:	74ba                	ld	s1,424(sp)
    800050f4:	791a                	ld	s2,416(sp)
    800050f6:	69fa                	ld	s3,408(sp)
    800050f8:	6a5a                	ld	s4,400(sp)
    800050fa:	a031                	j	80005106 <sys_exec+0xec>
  return -1;
    800050fc:	557d                	li	a0,-1
    800050fe:	74ba                	ld	s1,424(sp)
    80005100:	791a                	ld	s2,416(sp)
    80005102:	69fa                	ld	s3,408(sp)
    80005104:	6a5a                	ld	s4,400(sp)
}
    80005106:	70fa                	ld	ra,440(sp)
    80005108:	745a                	ld	s0,432(sp)
    8000510a:	6139                	add	sp,sp,448
    8000510c:	8082                	ret

000000008000510e <sys_pipe>:

uint64
sys_pipe(void)
{
    8000510e:	7139                	add	sp,sp,-64
    80005110:	fc06                	sd	ra,56(sp)
    80005112:	f822                	sd	s0,48(sp)
    80005114:	f426                	sd	s1,40(sp)
    80005116:	0080                	add	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005118:	fdafc0ef          	jal	800018f2 <myproc>
    8000511c:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000511e:	fd840593          	add	a1,s0,-40
    80005122:	4501                	li	a0,0
    80005124:	e9efd0ef          	jal	800027c2 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005128:	fc840593          	add	a1,s0,-56
    8000512c:	fd040513          	add	a0,s0,-48
    80005130:	85cff0ef          	jal	8000418c <pipealloc>
    return -1;
    80005134:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005136:	0a054463          	bltz	a0,800051de <sys_pipe+0xd0>
  fd0 = -1;
    8000513a:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000513e:	fd043503          	ld	a0,-48(s0)
    80005142:	f08ff0ef          	jal	8000484a <fdalloc>
    80005146:	fca42223          	sw	a0,-60(s0)
    8000514a:	08054163          	bltz	a0,800051cc <sys_pipe+0xbe>
    8000514e:	fc843503          	ld	a0,-56(s0)
    80005152:	ef8ff0ef          	jal	8000484a <fdalloc>
    80005156:	fca42023          	sw	a0,-64(s0)
    8000515a:	06054063          	bltz	a0,800051ba <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000515e:	4691                	li	a3,4
    80005160:	fc440613          	add	a2,s0,-60
    80005164:	fd843583          	ld	a1,-40(s0)
    80005168:	68a8                	ld	a0,80(s1)
    8000516a:	bfafc0ef          	jal	80001564 <copyout>
    8000516e:	00054e63          	bltz	a0,8000518a <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005172:	4691                	li	a3,4
    80005174:	fc040613          	add	a2,s0,-64
    80005178:	fd843583          	ld	a1,-40(s0)
    8000517c:	0591                	add	a1,a1,4
    8000517e:	68a8                	ld	a0,80(s1)
    80005180:	be4fc0ef          	jal	80001564 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005184:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005186:	04055c63          	bgez	a0,800051de <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    8000518a:	fc442783          	lw	a5,-60(s0)
    8000518e:	07e9                	add	a5,a5,26
    80005190:	078e                	sll	a5,a5,0x3
    80005192:	97a6                	add	a5,a5,s1
    80005194:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005198:	fc042783          	lw	a5,-64(s0)
    8000519c:	07e9                	add	a5,a5,26
    8000519e:	078e                	sll	a5,a5,0x3
    800051a0:	94be                	add	s1,s1,a5
    800051a2:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800051a6:	fd043503          	ld	a0,-48(s0)
    800051aa:	cd9fe0ef          	jal	80003e82 <fileclose>
    fileclose(wf);
    800051ae:	fc843503          	ld	a0,-56(s0)
    800051b2:	cd1fe0ef          	jal	80003e82 <fileclose>
    return -1;
    800051b6:	57fd                	li	a5,-1
    800051b8:	a01d                	j	800051de <sys_pipe+0xd0>
    if(fd0 >= 0)
    800051ba:	fc442783          	lw	a5,-60(s0)
    800051be:	0007c763          	bltz	a5,800051cc <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800051c2:	07e9                	add	a5,a5,26
    800051c4:	078e                	sll	a5,a5,0x3
    800051c6:	97a6                	add	a5,a5,s1
    800051c8:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800051cc:	fd043503          	ld	a0,-48(s0)
    800051d0:	cb3fe0ef          	jal	80003e82 <fileclose>
    fileclose(wf);
    800051d4:	fc843503          	ld	a0,-56(s0)
    800051d8:	cabfe0ef          	jal	80003e82 <fileclose>
    return -1;
    800051dc:	57fd                	li	a5,-1
}
    800051de:	853e                	mv	a0,a5
    800051e0:	70e2                	ld	ra,56(sp)
    800051e2:	7442                	ld	s0,48(sp)
    800051e4:	74a2                	ld	s1,40(sp)
    800051e6:	6121                	add	sp,sp,64
    800051e8:	8082                	ret

00000000800051ea <sys_off>:

uint64 sys_off(void) {
    800051ea:	1141                	add	sp,sp,-16
    800051ec:	e422                	sd	s0,8(sp)
    800051ee:	0800                	add	s0,sp,16
    *(uint32 *)SYSCON_ADDR = 0x5555;
    800051f0:	6795                	lui	a5,0x5
    800051f2:	55578793          	add	a5,a5,1365 # 5555 <_entry-0x7fffaaab>
    800051f6:	00100737          	lui	a4,0x100
    800051fa:	c31c                	sw	a5,0(a4)
    while (1); // Hang if the reboot fails.
    800051fc:	a001                	j	800051fc <sys_off+0x12>
	...

0000000080005200 <kernelvec>:
    80005200:	7111                	add	sp,sp,-256
    80005202:	e006                	sd	ra,0(sp)
    80005204:	e40a                	sd	sp,8(sp)
    80005206:	e80e                	sd	gp,16(sp)
    80005208:	ec12                	sd	tp,24(sp)
    8000520a:	f016                	sd	t0,32(sp)
    8000520c:	f41a                	sd	t1,40(sp)
    8000520e:	f81e                	sd	t2,48(sp)
    80005210:	e4aa                	sd	a0,72(sp)
    80005212:	e8ae                	sd	a1,80(sp)
    80005214:	ecb2                	sd	a2,88(sp)
    80005216:	f0b6                	sd	a3,96(sp)
    80005218:	f4ba                	sd	a4,104(sp)
    8000521a:	f8be                	sd	a5,112(sp)
    8000521c:	fcc2                	sd	a6,120(sp)
    8000521e:	e146                	sd	a7,128(sp)
    80005220:	edf2                	sd	t3,216(sp)
    80005222:	f1f6                	sd	t4,224(sp)
    80005224:	f5fa                	sd	t5,232(sp)
    80005226:	f9fe                	sd	t6,240(sp)
    80005228:	c1afd0ef          	jal	80002642 <kerneltrap>
    8000522c:	6082                	ld	ra,0(sp)
    8000522e:	6122                	ld	sp,8(sp)
    80005230:	61c2                	ld	gp,16(sp)
    80005232:	7282                	ld	t0,32(sp)
    80005234:	7322                	ld	t1,40(sp)
    80005236:	73c2                	ld	t2,48(sp)
    80005238:	6526                	ld	a0,72(sp)
    8000523a:	65c6                	ld	a1,80(sp)
    8000523c:	6666                	ld	a2,88(sp)
    8000523e:	7686                	ld	a3,96(sp)
    80005240:	7726                	ld	a4,104(sp)
    80005242:	77c6                	ld	a5,112(sp)
    80005244:	7866                	ld	a6,120(sp)
    80005246:	688a                	ld	a7,128(sp)
    80005248:	6e6e                	ld	t3,216(sp)
    8000524a:	7e8e                	ld	t4,224(sp)
    8000524c:	7f2e                	ld	t5,232(sp)
    8000524e:	7fce                	ld	t6,240(sp)
    80005250:	6111                	add	sp,sp,256
    80005252:	10200073          	sret
	...

000000008000525e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000525e:	1141                	add	sp,sp,-16
    80005260:	e422                	sd	s0,8(sp)
    80005262:	0800                	add	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005264:	0c0007b7          	lui	a5,0xc000
    80005268:	4705                	li	a4,1
    8000526a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000526c:	0c0007b7          	lui	a5,0xc000
    80005270:	c3d8                	sw	a4,4(a5)
}
    80005272:	6422                	ld	s0,8(sp)
    80005274:	0141                	add	sp,sp,16
    80005276:	8082                	ret

0000000080005278 <plicinithart>:

void
plicinithart(void)
{
    80005278:	1141                	add	sp,sp,-16
    8000527a:	e406                	sd	ra,8(sp)
    8000527c:	e022                	sd	s0,0(sp)
    8000527e:	0800                	add	s0,sp,16
  int hart = cpuid();
    80005280:	e46fc0ef          	jal	800018c6 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005284:	0085171b          	sllw	a4,a0,0x8
    80005288:	0c0027b7          	lui	a5,0xc002
    8000528c:	97ba                	add	a5,a5,a4
    8000528e:	40200713          	li	a4,1026
    80005292:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005296:	00d5151b          	sllw	a0,a0,0xd
    8000529a:	0c2017b7          	lui	a5,0xc201
    8000529e:	97aa                	add	a5,a5,a0
    800052a0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800052a4:	60a2                	ld	ra,8(sp)
    800052a6:	6402                	ld	s0,0(sp)
    800052a8:	0141                	add	sp,sp,16
    800052aa:	8082                	ret

00000000800052ac <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800052ac:	1141                	add	sp,sp,-16
    800052ae:	e406                	sd	ra,8(sp)
    800052b0:	e022                	sd	s0,0(sp)
    800052b2:	0800                	add	s0,sp,16
  int hart = cpuid();
    800052b4:	e12fc0ef          	jal	800018c6 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800052b8:	00d5151b          	sllw	a0,a0,0xd
    800052bc:	0c2017b7          	lui	a5,0xc201
    800052c0:	97aa                	add	a5,a5,a0
  return irq;
}
    800052c2:	43c8                	lw	a0,4(a5)
    800052c4:	60a2                	ld	ra,8(sp)
    800052c6:	6402                	ld	s0,0(sp)
    800052c8:	0141                	add	sp,sp,16
    800052ca:	8082                	ret

00000000800052cc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800052cc:	1101                	add	sp,sp,-32
    800052ce:	ec06                	sd	ra,24(sp)
    800052d0:	e822                	sd	s0,16(sp)
    800052d2:	e426                	sd	s1,8(sp)
    800052d4:	1000                	add	s0,sp,32
    800052d6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800052d8:	deefc0ef          	jal	800018c6 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800052dc:	00d5151b          	sllw	a0,a0,0xd
    800052e0:	0c2017b7          	lui	a5,0xc201
    800052e4:	97aa                	add	a5,a5,a0
    800052e6:	c3c4                	sw	s1,4(a5)
}
    800052e8:	60e2                	ld	ra,24(sp)
    800052ea:	6442                	ld	s0,16(sp)
    800052ec:	64a2                	ld	s1,8(sp)
    800052ee:	6105                	add	sp,sp,32
    800052f0:	8082                	ret

00000000800052f2 <off>:


void
off(void)
{
    800052f2:	1141                	add	sp,sp,-16
    800052f4:	e406                	sd	ra,8(sp)
    800052f6:	e022                	sd	s0,0(sp)
    800052f8:	0800                	add	s0,sp,16
  printf("reoot called");
    800052fa:	00002517          	auipc	a0,0x2
    800052fe:	35650513          	add	a0,a0,854 # 80007650 <etext+0x650>
    80005302:	9c0fb0ef          	jal	800004c2 <printf>
  *(uint32 *)SYSCON_ADDR = 0x7777;
    80005306:	679d                	lui	a5,0x7
    80005308:	77778793          	add	a5,a5,1911 # 7777 <_entry-0x7fff8889>
    8000530c:	00100737          	lui	a4,0x100
    80005310:	c31c                	sw	a5,0(a4)
return;
}
    80005312:	60a2                	ld	ra,8(sp)
    80005314:	6402                	ld	s0,0(sp)
    80005316:	0141                	add	sp,sp,16
    80005318:	8082                	ret

000000008000531a <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    8000531a:	1141                	add	sp,sp,-16
    8000531c:	e406                	sd	ra,8(sp)
    8000531e:	e022                	sd	s0,0(sp)
    80005320:	0800                	add	s0,sp,16
  if(i >= NUM)
    80005322:	479d                	li	a5,7
    80005324:	04a7ca63          	blt	a5,a0,80005378 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005328:	0001b797          	auipc	a5,0x1b
    8000532c:	7d878793          	add	a5,a5,2008 # 80020b00 <disk>
    80005330:	97aa                	add	a5,a5,a0
    80005332:	0187c783          	lbu	a5,24(a5)
    80005336:	e7b9                	bnez	a5,80005384 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005338:	00451693          	sll	a3,a0,0x4
    8000533c:	0001b797          	auipc	a5,0x1b
    80005340:	7c478793          	add	a5,a5,1988 # 80020b00 <disk>
    80005344:	6398                	ld	a4,0(a5)
    80005346:	9736                	add	a4,a4,a3
    80005348:	00073023          	sd	zero,0(a4) # 100000 <_entry-0x7ff00000>
  disk.desc[i].len = 0;
    8000534c:	6398                	ld	a4,0(a5)
    8000534e:	9736                	add	a4,a4,a3
    80005350:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005354:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005358:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    8000535c:	97aa                	add	a5,a5,a0
    8000535e:	4705                	li	a4,1
    80005360:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005364:	0001b517          	auipc	a0,0x1b
    80005368:	7b450513          	add	a0,a0,1972 # 80020b18 <disk+0x18>
    8000536c:	ba1fc0ef          	jal	80001f0c <wakeup>
}
    80005370:	60a2                	ld	ra,8(sp)
    80005372:	6402                	ld	s0,0(sp)
    80005374:	0141                	add	sp,sp,16
    80005376:	8082                	ret
    panic("free_desc 1");
    80005378:	00002517          	auipc	a0,0x2
    8000537c:	2e850513          	add	a0,a0,744 # 80007660 <etext+0x660>
    80005380:	c14fb0ef          	jal	80000794 <panic>
    panic("free_desc 2");
    80005384:	00002517          	auipc	a0,0x2
    80005388:	2ec50513          	add	a0,a0,748 # 80007670 <etext+0x670>
    8000538c:	c08fb0ef          	jal	80000794 <panic>

0000000080005390 <virtio_disk_init>:
{
    80005390:	1101                	add	sp,sp,-32
    80005392:	ec06                	sd	ra,24(sp)
    80005394:	e822                	sd	s0,16(sp)
    80005396:	e426                	sd	s1,8(sp)
    80005398:	e04a                	sd	s2,0(sp)
    8000539a:	1000                	add	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000539c:	00002597          	auipc	a1,0x2
    800053a0:	2e458593          	add	a1,a1,740 # 80007680 <etext+0x680>
    800053a4:	0001c517          	auipc	a0,0x1c
    800053a8:	88450513          	add	a0,a0,-1916 # 80020c28 <disk+0x128>
    800053ac:	fc8fb0ef          	jal	80000b74 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800053b0:	100017b7          	lui	a5,0x10001
    800053b4:	4398                	lw	a4,0(a5)
    800053b6:	2701                	sext.w	a4,a4
    800053b8:	747277b7          	lui	a5,0x74727
    800053bc:	97678793          	add	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800053c0:	18f71063          	bne	a4,a5,80005540 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800053c4:	100017b7          	lui	a5,0x10001
    800053c8:	0791                	add	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800053ca:	439c                	lw	a5,0(a5)
    800053cc:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800053ce:	4709                	li	a4,2
    800053d0:	16e79863          	bne	a5,a4,80005540 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800053d4:	100017b7          	lui	a5,0x10001
    800053d8:	07a1                	add	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800053da:	439c                	lw	a5,0(a5)
    800053dc:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800053de:	16e79163          	bne	a5,a4,80005540 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800053e2:	100017b7          	lui	a5,0x10001
    800053e6:	47d8                	lw	a4,12(a5)
    800053e8:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800053ea:	554d47b7          	lui	a5,0x554d4
    800053ee:	55178793          	add	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800053f2:	14f71763          	bne	a4,a5,80005540 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    800053f6:	100017b7          	lui	a5,0x10001
    800053fa:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800053fe:	4705                	li	a4,1
    80005400:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005402:	470d                	li	a4,3
    80005404:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005406:	10001737          	lui	a4,0x10001
    8000540a:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    8000540c:	c7ffe737          	lui	a4,0xc7ffe
    80005410:	75f70713          	add	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fddb1f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005414:	8ef9                	and	a3,a3,a4
    80005416:	10001737          	lui	a4,0x10001
    8000541a:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000541c:	472d                	li	a4,11
    8000541e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005420:	07078793          	add	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005424:	439c                	lw	a5,0(a5)
    80005426:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000542a:	8ba1                	and	a5,a5,8
    8000542c:	12078063          	beqz	a5,8000554c <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005430:	100017b7          	lui	a5,0x10001
    80005434:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005438:	100017b7          	lui	a5,0x10001
    8000543c:	04478793          	add	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005440:	439c                	lw	a5,0(a5)
    80005442:	2781                	sext.w	a5,a5
    80005444:	10079a63          	bnez	a5,80005558 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005448:	100017b7          	lui	a5,0x10001
    8000544c:	03478793          	add	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005450:	439c                	lw	a5,0(a5)
    80005452:	2781                	sext.w	a5,a5
  if(max == 0)
    80005454:	10078863          	beqz	a5,80005564 <virtio_disk_init+0x1d4>
  if(max < NUM)
    80005458:	471d                	li	a4,7
    8000545a:	10f77b63          	bgeu	a4,a5,80005570 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    8000545e:	ec6fb0ef          	jal	80000b24 <kalloc>
    80005462:	0001b497          	auipc	s1,0x1b
    80005466:	69e48493          	add	s1,s1,1694 # 80020b00 <disk>
    8000546a:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    8000546c:	eb8fb0ef          	jal	80000b24 <kalloc>
    80005470:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005472:	eb2fb0ef          	jal	80000b24 <kalloc>
    80005476:	87aa                	mv	a5,a0
    80005478:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    8000547a:	6088                	ld	a0,0(s1)
    8000547c:	10050063          	beqz	a0,8000557c <virtio_disk_init+0x1ec>
    80005480:	0001b717          	auipc	a4,0x1b
    80005484:	68873703          	ld	a4,1672(a4) # 80020b08 <disk+0x8>
    80005488:	0e070a63          	beqz	a4,8000557c <virtio_disk_init+0x1ec>
    8000548c:	0e078863          	beqz	a5,8000557c <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005490:	6605                	lui	a2,0x1
    80005492:	4581                	li	a1,0
    80005494:	835fb0ef          	jal	80000cc8 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005498:	0001b497          	auipc	s1,0x1b
    8000549c:	66848493          	add	s1,s1,1640 # 80020b00 <disk>
    800054a0:	6605                	lui	a2,0x1
    800054a2:	4581                	li	a1,0
    800054a4:	6488                	ld	a0,8(s1)
    800054a6:	823fb0ef          	jal	80000cc8 <memset>
  memset(disk.used, 0, PGSIZE);
    800054aa:	6605                	lui	a2,0x1
    800054ac:	4581                	li	a1,0
    800054ae:	6888                	ld	a0,16(s1)
    800054b0:	819fb0ef          	jal	80000cc8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800054b4:	100017b7          	lui	a5,0x10001
    800054b8:	4721                	li	a4,8
    800054ba:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800054bc:	4098                	lw	a4,0(s1)
    800054be:	100017b7          	lui	a5,0x10001
    800054c2:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800054c6:	40d8                	lw	a4,4(s1)
    800054c8:	100017b7          	lui	a5,0x10001
    800054cc:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800054d0:	649c                	ld	a5,8(s1)
    800054d2:	0007869b          	sext.w	a3,a5
    800054d6:	10001737          	lui	a4,0x10001
    800054da:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800054de:	9781                	sra	a5,a5,0x20
    800054e0:	10001737          	lui	a4,0x10001
    800054e4:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800054e8:	689c                	ld	a5,16(s1)
    800054ea:	0007869b          	sext.w	a3,a5
    800054ee:	10001737          	lui	a4,0x10001
    800054f2:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800054f6:	9781                	sra	a5,a5,0x20
    800054f8:	10001737          	lui	a4,0x10001
    800054fc:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005500:	10001737          	lui	a4,0x10001
    80005504:	4785                	li	a5,1
    80005506:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005508:	00f48c23          	sb	a5,24(s1)
    8000550c:	00f48ca3          	sb	a5,25(s1)
    80005510:	00f48d23          	sb	a5,26(s1)
    80005514:	00f48da3          	sb	a5,27(s1)
    80005518:	00f48e23          	sb	a5,28(s1)
    8000551c:	00f48ea3          	sb	a5,29(s1)
    80005520:	00f48f23          	sb	a5,30(s1)
    80005524:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005528:	00496913          	or	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    8000552c:	100017b7          	lui	a5,0x10001
    80005530:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    80005534:	60e2                	ld	ra,24(sp)
    80005536:	6442                	ld	s0,16(sp)
    80005538:	64a2                	ld	s1,8(sp)
    8000553a:	6902                	ld	s2,0(sp)
    8000553c:	6105                	add	sp,sp,32
    8000553e:	8082                	ret
    panic("could not find virtio disk");
    80005540:	00002517          	auipc	a0,0x2
    80005544:	15050513          	add	a0,a0,336 # 80007690 <etext+0x690>
    80005548:	a4cfb0ef          	jal	80000794 <panic>
    panic("virtio disk FEATURES_OK unset");
    8000554c:	00002517          	auipc	a0,0x2
    80005550:	16450513          	add	a0,a0,356 # 800076b0 <etext+0x6b0>
    80005554:	a40fb0ef          	jal	80000794 <panic>
    panic("virtio disk should not be ready");
    80005558:	00002517          	auipc	a0,0x2
    8000555c:	17850513          	add	a0,a0,376 # 800076d0 <etext+0x6d0>
    80005560:	a34fb0ef          	jal	80000794 <panic>
    panic("virtio disk has no queue 0");
    80005564:	00002517          	auipc	a0,0x2
    80005568:	18c50513          	add	a0,a0,396 # 800076f0 <etext+0x6f0>
    8000556c:	a28fb0ef          	jal	80000794 <panic>
    panic("virtio disk max queue too short");
    80005570:	00002517          	auipc	a0,0x2
    80005574:	1a050513          	add	a0,a0,416 # 80007710 <etext+0x710>
    80005578:	a1cfb0ef          	jal	80000794 <panic>
    panic("virtio disk kalloc");
    8000557c:	00002517          	auipc	a0,0x2
    80005580:	1b450513          	add	a0,a0,436 # 80007730 <etext+0x730>
    80005584:	a10fb0ef          	jal	80000794 <panic>

0000000080005588 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005588:	7159                	add	sp,sp,-112
    8000558a:	f486                	sd	ra,104(sp)
    8000558c:	f0a2                	sd	s0,96(sp)
    8000558e:	eca6                	sd	s1,88(sp)
    80005590:	e8ca                	sd	s2,80(sp)
    80005592:	e4ce                	sd	s3,72(sp)
    80005594:	e0d2                	sd	s4,64(sp)
    80005596:	fc56                	sd	s5,56(sp)
    80005598:	f85a                	sd	s6,48(sp)
    8000559a:	f45e                	sd	s7,40(sp)
    8000559c:	f062                	sd	s8,32(sp)
    8000559e:	ec66                	sd	s9,24(sp)
    800055a0:	1880                	add	s0,sp,112
    800055a2:	8a2a                	mv	s4,a0
    800055a4:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800055a6:	00c52c83          	lw	s9,12(a0)
    800055aa:	001c9c9b          	sllw	s9,s9,0x1
    800055ae:	1c82                	sll	s9,s9,0x20
    800055b0:	020cdc93          	srl	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800055b4:	0001b517          	auipc	a0,0x1b
    800055b8:	67450513          	add	a0,a0,1652 # 80020c28 <disk+0x128>
    800055bc:	e38fb0ef          	jal	80000bf4 <acquire>
  for(int i = 0; i < 3; i++){
    800055c0:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800055c2:	44a1                	li	s1,8
      disk.free[i] = 0;
    800055c4:	0001bb17          	auipc	s6,0x1b
    800055c8:	53cb0b13          	add	s6,s6,1340 # 80020b00 <disk>
  for(int i = 0; i < 3; i++){
    800055cc:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800055ce:	0001bc17          	auipc	s8,0x1b
    800055d2:	65ac0c13          	add	s8,s8,1626 # 80020c28 <disk+0x128>
    800055d6:	a8b9                	j	80005634 <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    800055d8:	00fb0733          	add	a4,s6,a5
    800055dc:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    800055e0:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800055e2:	0207c563          	bltz	a5,8000560c <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    800055e6:	2905                	addw	s2,s2,1
    800055e8:	0611                	add	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800055ea:	05590963          	beq	s2,s5,8000563c <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    800055ee:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800055f0:	0001b717          	auipc	a4,0x1b
    800055f4:	51070713          	add	a4,a4,1296 # 80020b00 <disk>
    800055f8:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800055fa:	01874683          	lbu	a3,24(a4)
    800055fe:	fee9                	bnez	a3,800055d8 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80005600:	2785                	addw	a5,a5,1
    80005602:	0705                	add	a4,a4,1
    80005604:	fe979be3          	bne	a5,s1,800055fa <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80005608:	57fd                	li	a5,-1
    8000560a:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000560c:	01205d63          	blez	s2,80005626 <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005610:	f9042503          	lw	a0,-112(s0)
    80005614:	d07ff0ef          	jal	8000531a <free_desc>
      for(int j = 0; j < i; j++)
    80005618:	4785                	li	a5,1
    8000561a:	0127d663          	bge	a5,s2,80005626 <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    8000561e:	f9442503          	lw	a0,-108(s0)
    80005622:	cf9ff0ef          	jal	8000531a <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005626:	85e2                	mv	a1,s8
    80005628:	0001b517          	auipc	a0,0x1b
    8000562c:	4f050513          	add	a0,a0,1264 # 80020b18 <disk+0x18>
    80005630:	891fc0ef          	jal	80001ec0 <sleep>
  for(int i = 0; i < 3; i++){
    80005634:	f9040613          	add	a2,s0,-112
    80005638:	894e                	mv	s2,s3
    8000563a:	bf55                	j	800055ee <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000563c:	f9042503          	lw	a0,-112(s0)
    80005640:	00451693          	sll	a3,a0,0x4

  if(write)
    80005644:	0001b797          	auipc	a5,0x1b
    80005648:	4bc78793          	add	a5,a5,1212 # 80020b00 <disk>
    8000564c:	00a50713          	add	a4,a0,10
    80005650:	0712                	sll	a4,a4,0x4
    80005652:	973e                	add	a4,a4,a5
    80005654:	01703633          	snez	a2,s7
    80005658:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000565a:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    8000565e:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005662:	6398                	ld	a4,0(a5)
    80005664:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005666:	0a868613          	add	a2,a3,168
    8000566a:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000566c:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000566e:	6390                	ld	a2,0(a5)
    80005670:	00d605b3          	add	a1,a2,a3
    80005674:	4741                	li	a4,16
    80005676:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005678:	4805                	li	a6,1
    8000567a:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    8000567e:	f9442703          	lw	a4,-108(s0)
    80005682:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005686:	0712                	sll	a4,a4,0x4
    80005688:	963a                	add	a2,a2,a4
    8000568a:	058a0593          	add	a1,s4,88
    8000568e:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005690:	0007b883          	ld	a7,0(a5)
    80005694:	9746                	add	a4,a4,a7
    80005696:	40000613          	li	a2,1024
    8000569a:	c710                	sw	a2,8(a4)
  if(write)
    8000569c:	001bb613          	seqz	a2,s7
    800056a0:	0016161b          	sllw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800056a4:	00166613          	or	a2,a2,1
    800056a8:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800056ac:	f9842583          	lw	a1,-104(s0)
    800056b0:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800056b4:	00250613          	add	a2,a0,2
    800056b8:	0612                	sll	a2,a2,0x4
    800056ba:	963e                	add	a2,a2,a5
    800056bc:	577d                	li	a4,-1
    800056be:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800056c2:	0592                	sll	a1,a1,0x4
    800056c4:	98ae                	add	a7,a7,a1
    800056c6:	03068713          	add	a4,a3,48
    800056ca:	973e                	add	a4,a4,a5
    800056cc:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800056d0:	6398                	ld	a4,0(a5)
    800056d2:	972e                	add	a4,a4,a1
    800056d4:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800056d8:	4689                	li	a3,2
    800056da:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800056de:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800056e2:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    800056e6:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800056ea:	6794                	ld	a3,8(a5)
    800056ec:	0026d703          	lhu	a4,2(a3)
    800056f0:	8b1d                	and	a4,a4,7
    800056f2:	0706                	sll	a4,a4,0x1
    800056f4:	96ba                	add	a3,a3,a4
    800056f6:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800056fa:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800056fe:	6798                	ld	a4,8(a5)
    80005700:	00275783          	lhu	a5,2(a4)
    80005704:	2785                	addw	a5,a5,1
    80005706:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000570a:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000570e:	100017b7          	lui	a5,0x10001
    80005712:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005716:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    8000571a:	0001b917          	auipc	s2,0x1b
    8000571e:	50e90913          	add	s2,s2,1294 # 80020c28 <disk+0x128>
  while(b->disk == 1) {
    80005722:	4485                	li	s1,1
    80005724:	01079a63          	bne	a5,a6,80005738 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005728:	85ca                	mv	a1,s2
    8000572a:	8552                	mv	a0,s4
    8000572c:	f94fc0ef          	jal	80001ec0 <sleep>
  while(b->disk == 1) {
    80005730:	004a2783          	lw	a5,4(s4)
    80005734:	fe978ae3          	beq	a5,s1,80005728 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005738:	f9042903          	lw	s2,-112(s0)
    8000573c:	00290713          	add	a4,s2,2
    80005740:	0712                	sll	a4,a4,0x4
    80005742:	0001b797          	auipc	a5,0x1b
    80005746:	3be78793          	add	a5,a5,958 # 80020b00 <disk>
    8000574a:	97ba                	add	a5,a5,a4
    8000574c:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005750:	0001b997          	auipc	s3,0x1b
    80005754:	3b098993          	add	s3,s3,944 # 80020b00 <disk>
    80005758:	00491713          	sll	a4,s2,0x4
    8000575c:	0009b783          	ld	a5,0(s3)
    80005760:	97ba                	add	a5,a5,a4
    80005762:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005766:	854a                	mv	a0,s2
    80005768:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000576c:	bafff0ef          	jal	8000531a <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005770:	8885                	and	s1,s1,1
    80005772:	f0fd                	bnez	s1,80005758 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005774:	0001b517          	auipc	a0,0x1b
    80005778:	4b450513          	add	a0,a0,1204 # 80020c28 <disk+0x128>
    8000577c:	d10fb0ef          	jal	80000c8c <release>
}
    80005780:	70a6                	ld	ra,104(sp)
    80005782:	7406                	ld	s0,96(sp)
    80005784:	64e6                	ld	s1,88(sp)
    80005786:	6946                	ld	s2,80(sp)
    80005788:	69a6                	ld	s3,72(sp)
    8000578a:	6a06                	ld	s4,64(sp)
    8000578c:	7ae2                	ld	s5,56(sp)
    8000578e:	7b42                	ld	s6,48(sp)
    80005790:	7ba2                	ld	s7,40(sp)
    80005792:	7c02                	ld	s8,32(sp)
    80005794:	6ce2                	ld	s9,24(sp)
    80005796:	6165                	add	sp,sp,112
    80005798:	8082                	ret

000000008000579a <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000579a:	1101                	add	sp,sp,-32
    8000579c:	ec06                	sd	ra,24(sp)
    8000579e:	e822                	sd	s0,16(sp)
    800057a0:	e426                	sd	s1,8(sp)
    800057a2:	1000                	add	s0,sp,32
  acquire(&disk.vdisk_lock);
    800057a4:	0001b497          	auipc	s1,0x1b
    800057a8:	35c48493          	add	s1,s1,860 # 80020b00 <disk>
    800057ac:	0001b517          	auipc	a0,0x1b
    800057b0:	47c50513          	add	a0,a0,1148 # 80020c28 <disk+0x128>
    800057b4:	c40fb0ef          	jal	80000bf4 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800057b8:	100017b7          	lui	a5,0x10001
    800057bc:	53b8                	lw	a4,96(a5)
    800057be:	8b0d                	and	a4,a4,3
    800057c0:	100017b7          	lui	a5,0x10001
    800057c4:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    800057c6:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800057ca:	689c                	ld	a5,16(s1)
    800057cc:	0204d703          	lhu	a4,32(s1)
    800057d0:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    800057d4:	04f70663          	beq	a4,a5,80005820 <virtio_disk_intr+0x86>
    __sync_synchronize();
    800057d8:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800057dc:	6898                	ld	a4,16(s1)
    800057de:	0204d783          	lhu	a5,32(s1)
    800057e2:	8b9d                	and	a5,a5,7
    800057e4:	078e                	sll	a5,a5,0x3
    800057e6:	97ba                	add	a5,a5,a4
    800057e8:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800057ea:	00278713          	add	a4,a5,2
    800057ee:	0712                	sll	a4,a4,0x4
    800057f0:	9726                	add	a4,a4,s1
    800057f2:	01074703          	lbu	a4,16(a4)
    800057f6:	e321                	bnez	a4,80005836 <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800057f8:	0789                	add	a5,a5,2
    800057fa:	0792                	sll	a5,a5,0x4
    800057fc:	97a6                	add	a5,a5,s1
    800057fe:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005800:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005804:	f08fc0ef          	jal	80001f0c <wakeup>

    disk.used_idx += 1;
    80005808:	0204d783          	lhu	a5,32(s1)
    8000580c:	2785                	addw	a5,a5,1
    8000580e:	17c2                	sll	a5,a5,0x30
    80005810:	93c1                	srl	a5,a5,0x30
    80005812:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005816:	6898                	ld	a4,16(s1)
    80005818:	00275703          	lhu	a4,2(a4)
    8000581c:	faf71ee3          	bne	a4,a5,800057d8 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005820:	0001b517          	auipc	a0,0x1b
    80005824:	40850513          	add	a0,a0,1032 # 80020c28 <disk+0x128>
    80005828:	c64fb0ef          	jal	80000c8c <release>
}
    8000582c:	60e2                	ld	ra,24(sp)
    8000582e:	6442                	ld	s0,16(sp)
    80005830:	64a2                	ld	s1,8(sp)
    80005832:	6105                	add	sp,sp,32
    80005834:	8082                	ret
      panic("virtio_disk_intr status");
    80005836:	00002517          	auipc	a0,0x2
    8000583a:	f1250513          	add	a0,a0,-238 # 80007748 <etext+0x748>
    8000583e:	f57fa0ef          	jal	80000794 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	sll	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	8282                	jr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	sll	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
