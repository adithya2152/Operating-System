
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	2b013103          	ld	sp,688(sp) # 8000a2b0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	04e000ef          	jal	80000064 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e406                	sd	ra,8(sp)
    80000020:	e022                	sd	s0,0(sp)
    80000022:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000024:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000028:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002c:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80000030:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000034:	577d                	li	a4,-1
    80000036:	177e                	slli	a4,a4,0x3f
    80000038:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    8000003a:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003e:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000042:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000046:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    8000004a:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004e:	000f4737          	lui	a4,0xf4
    80000052:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000056:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000058:	14d79073          	csrw	stimecmp,a5
}
    8000005c:	60a2                	ld	ra,8(sp)
    8000005e:	6402                	ld	s0,0(sp)
    80000060:	0141                	addi	sp,sp,16
    80000062:	8082                	ret

0000000080000064 <start>:
{
    80000064:	1141                	addi	sp,sp,-16
    80000066:	e406                	sd	ra,8(sp)
    80000068:	e022                	sd	s0,0(sp)
    8000006a:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006c:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000070:	7779                	lui	a4,0xffffe
    80000072:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb1bf>
    80000076:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000078:	6705                	lui	a4,0x1
    8000007a:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000080:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000084:	00001797          	auipc	a5,0x1
    80000088:	e0078793          	addi	a5,a5,-512 # 80000e84 <main>
    8000008c:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80000090:	4781                	li	a5,0
    80000092:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000096:	67c1                	lui	a5,0x10
    80000098:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    8000009a:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009e:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000a2:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000a6:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000aa:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000ae:	57fd                	li	a5,-1
    800000b0:	83a9                	srli	a5,a5,0xa
    800000b2:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b6:	47bd                	li	a5,15
    800000b8:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000bc:	f61ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000c0:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c4:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c6:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c8:	30200073          	mret
}
    800000cc:	60a2                	ld	ra,8(sp)
    800000ce:	6402                	ld	s0,0(sp)
    800000d0:	0141                	addi	sp,sp,16
    800000d2:	8082                	ret

00000000800000d4 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d4:	711d                	addi	sp,sp,-96
    800000d6:	ec86                	sd	ra,88(sp)
    800000d8:	e8a2                	sd	s0,80(sp)
    800000da:	e0ca                	sd	s2,64(sp)
    800000dc:	1080                	addi	s0,sp,96
  int i;

  for(i = 0; i < n; i++){
    800000de:	04c05863          	blez	a2,8000012e <consolewrite+0x5a>
    800000e2:	e4a6                	sd	s1,72(sp)
    800000e4:	fc4e                	sd	s3,56(sp)
    800000e6:	f852                	sd	s4,48(sp)
    800000e8:	f456                	sd	s5,40(sp)
    800000ea:	f05a                	sd	s6,32(sp)
    800000ec:	ec5e                	sd	s7,24(sp)
    800000ee:	8a2a                	mv	s4,a0
    800000f0:	84ae                	mv	s1,a1
    800000f2:	89b2                	mv	s3,a2
    800000f4:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    800000f6:	faf40b93          	addi	s7,s0,-81
    800000fa:	4b05                	li	s6,1
    800000fc:	5afd                	li	s5,-1
    800000fe:	86da                	mv	a3,s6
    80000100:	8626                	mv	a2,s1
    80000102:	85d2                	mv	a1,s4
    80000104:	855e                	mv	a0,s7
    80000106:	144020ef          	jal	8000224a <either_copyin>
    8000010a:	03550463          	beq	a0,s5,80000132 <consolewrite+0x5e>
      break;
    uartputc(c);
    8000010e:	faf44503          	lbu	a0,-81(s0)
    80000112:	02d000ef          	jal	8000093e <uartputc>
  for(i = 0; i < n; i++){
    80000116:	2905                	addiw	s2,s2,1
    80000118:	0485                	addi	s1,s1,1
    8000011a:	ff2992e3          	bne	s3,s2,800000fe <consolewrite+0x2a>
    8000011e:	894e                	mv	s2,s3
    80000120:	64a6                	ld	s1,72(sp)
    80000122:	79e2                	ld	s3,56(sp)
    80000124:	7a42                	ld	s4,48(sp)
    80000126:	7aa2                	ld	s5,40(sp)
    80000128:	7b02                	ld	s6,32(sp)
    8000012a:	6be2                	ld	s7,24(sp)
    8000012c:	a809                	j	8000013e <consolewrite+0x6a>
    8000012e:	4901                	li	s2,0
    80000130:	a039                	j	8000013e <consolewrite+0x6a>
    80000132:	64a6                	ld	s1,72(sp)
    80000134:	79e2                	ld	s3,56(sp)
    80000136:	7a42                	ld	s4,48(sp)
    80000138:	7aa2                	ld	s5,40(sp)
    8000013a:	7b02                	ld	s6,32(sp)
    8000013c:	6be2                	ld	s7,24(sp)
  }

  return i;
}
    8000013e:	854a                	mv	a0,s2
    80000140:	60e6                	ld	ra,88(sp)
    80000142:	6446                	ld	s0,80(sp)
    80000144:	6906                	ld	s2,64(sp)
    80000146:	6125                	addi	sp,sp,96
    80000148:	8082                	ret

000000008000014a <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000014a:	711d                	addi	sp,sp,-96
    8000014c:	ec86                	sd	ra,88(sp)
    8000014e:	e8a2                	sd	s0,80(sp)
    80000150:	e4a6                	sd	s1,72(sp)
    80000152:	e0ca                	sd	s2,64(sp)
    80000154:	fc4e                	sd	s3,56(sp)
    80000156:	f852                	sd	s4,48(sp)
    80000158:	f456                	sd	s5,40(sp)
    8000015a:	f05a                	sd	s6,32(sp)
    8000015c:	1080                	addi	s0,sp,96
    8000015e:	8aaa                	mv	s5,a0
    80000160:	8a2e                	mv	s4,a1
    80000162:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000164:	8b32                	mv	s6,a2
  acquire(&cons.lock);
    80000166:	00012517          	auipc	a0,0x12
    8000016a:	1aa50513          	addi	a0,a0,426 # 80012310 <cons>
    8000016e:	291000ef          	jal	80000bfe <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000172:	00012497          	auipc	s1,0x12
    80000176:	19e48493          	addi	s1,s1,414 # 80012310 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000017a:	00012917          	auipc	s2,0x12
    8000017e:	22e90913          	addi	s2,s2,558 # 800123a8 <cons+0x98>
  while(n > 0){
    80000182:	0b305b63          	blez	s3,80000238 <consoleread+0xee>
    while(cons.r == cons.w){
    80000186:	0984a783          	lw	a5,152(s1)
    8000018a:	09c4a703          	lw	a4,156(s1)
    8000018e:	0af71063          	bne	a4,a5,8000022e <consoleread+0xe4>
      if(killed(myproc())){
    80000192:	74a010ef          	jal	800018dc <myproc>
    80000196:	74d010ef          	jal	800020e2 <killed>
    8000019a:	e12d                	bnez	a0,800001fc <consoleread+0xb2>
      sleep(&cons.r, &cons.lock);
    8000019c:	85a6                	mv	a1,s1
    8000019e:	854a                	mv	a0,s2
    800001a0:	50b010ef          	jal	80001eaa <sleep>
    while(cons.r == cons.w){
    800001a4:	0984a783          	lw	a5,152(s1)
    800001a8:	09c4a703          	lw	a4,156(s1)
    800001ac:	fef703e3          	beq	a4,a5,80000192 <consoleread+0x48>
    800001b0:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001b2:	00012717          	auipc	a4,0x12
    800001b6:	15e70713          	addi	a4,a4,350 # 80012310 <cons>
    800001ba:	0017869b          	addiw	a3,a5,1
    800001be:	08d72c23          	sw	a3,152(a4)
    800001c2:	07f7f693          	andi	a3,a5,127
    800001c6:	9736                	add	a4,a4,a3
    800001c8:	01874703          	lbu	a4,24(a4)
    800001cc:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001d0:	4691                	li	a3,4
    800001d2:	04db8663          	beq	s7,a3,8000021e <consoleread+0xd4>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800001d6:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001da:	4685                	li	a3,1
    800001dc:	faf40613          	addi	a2,s0,-81
    800001e0:	85d2                	mv	a1,s4
    800001e2:	8556                	mv	a0,s5
    800001e4:	01c020ef          	jal	80002200 <either_copyout>
    800001e8:	57fd                	li	a5,-1
    800001ea:	04f50663          	beq	a0,a5,80000236 <consoleread+0xec>
      break;

    dst++;
    800001ee:	0a05                	addi	s4,s4,1
    --n;
    800001f0:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    800001f2:	47a9                	li	a5,10
    800001f4:	04fb8b63          	beq	s7,a5,8000024a <consoleread+0x100>
    800001f8:	6be2                	ld	s7,24(sp)
    800001fa:	b761                	j	80000182 <consoleread+0x38>
        release(&cons.lock);
    800001fc:	00012517          	auipc	a0,0x12
    80000200:	11450513          	addi	a0,a0,276 # 80012310 <cons>
    80000204:	28f000ef          	jal	80000c92 <release>
        return -1;
    80000208:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    8000020a:	60e6                	ld	ra,88(sp)
    8000020c:	6446                	ld	s0,80(sp)
    8000020e:	64a6                	ld	s1,72(sp)
    80000210:	6906                	ld	s2,64(sp)
    80000212:	79e2                	ld	s3,56(sp)
    80000214:	7a42                	ld	s4,48(sp)
    80000216:	7aa2                	ld	s5,40(sp)
    80000218:	7b02                	ld	s6,32(sp)
    8000021a:	6125                	addi	sp,sp,96
    8000021c:	8082                	ret
      if(n < target){
    8000021e:	0169fa63          	bgeu	s3,s6,80000232 <consoleread+0xe8>
        cons.r--;
    80000222:	00012717          	auipc	a4,0x12
    80000226:	18f72323          	sw	a5,390(a4) # 800123a8 <cons+0x98>
    8000022a:	6be2                	ld	s7,24(sp)
    8000022c:	a031                	j	80000238 <consoleread+0xee>
    8000022e:	ec5e                	sd	s7,24(sp)
    80000230:	b749                	j	800001b2 <consoleread+0x68>
    80000232:	6be2                	ld	s7,24(sp)
    80000234:	a011                	j	80000238 <consoleread+0xee>
    80000236:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000238:	00012517          	auipc	a0,0x12
    8000023c:	0d850513          	addi	a0,a0,216 # 80012310 <cons>
    80000240:	253000ef          	jal	80000c92 <release>
  return target - n;
    80000244:	413b053b          	subw	a0,s6,s3
    80000248:	b7c9                	j	8000020a <consoleread+0xc0>
    8000024a:	6be2                	ld	s7,24(sp)
    8000024c:	b7f5                	j	80000238 <consoleread+0xee>

000000008000024e <consputc>:
{
    8000024e:	1141                	addi	sp,sp,-16
    80000250:	e406                	sd	ra,8(sp)
    80000252:	e022                	sd	s0,0(sp)
    80000254:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000256:	10000793          	li	a5,256
    8000025a:	00f50863          	beq	a0,a5,8000026a <consputc+0x1c>
    uartputc_sync(c);
    8000025e:	5fe000ef          	jal	8000085c <uartputc_sync>
}
    80000262:	60a2                	ld	ra,8(sp)
    80000264:	6402                	ld	s0,0(sp)
    80000266:	0141                	addi	sp,sp,16
    80000268:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000026a:	4521                	li	a0,8
    8000026c:	5f0000ef          	jal	8000085c <uartputc_sync>
    80000270:	02000513          	li	a0,32
    80000274:	5e8000ef          	jal	8000085c <uartputc_sync>
    80000278:	4521                	li	a0,8
    8000027a:	5e2000ef          	jal	8000085c <uartputc_sync>
    8000027e:	b7d5                	j	80000262 <consputc+0x14>

0000000080000280 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80000280:	7179                	addi	sp,sp,-48
    80000282:	f406                	sd	ra,40(sp)
    80000284:	f022                	sd	s0,32(sp)
    80000286:	ec26                	sd	s1,24(sp)
    80000288:	1800                	addi	s0,sp,48
    8000028a:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    8000028c:	00012517          	auipc	a0,0x12
    80000290:	08450513          	addi	a0,a0,132 # 80012310 <cons>
    80000294:	16b000ef          	jal	80000bfe <acquire>

  switch(c){
    80000298:	47d5                	li	a5,21
    8000029a:	08f48e63          	beq	s1,a5,80000336 <consoleintr+0xb6>
    8000029e:	0297c563          	blt	a5,s1,800002c8 <consoleintr+0x48>
    800002a2:	47a1                	li	a5,8
    800002a4:	0ef48863          	beq	s1,a5,80000394 <consoleintr+0x114>
    800002a8:	47c1                	li	a5,16
    800002aa:	10f49963          	bne	s1,a5,800003bc <consoleintr+0x13c>
  case C('P'):  // Print process list.
    procdump();
    800002ae:	7e7010ef          	jal	80002294 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002b2:	00012517          	auipc	a0,0x12
    800002b6:	05e50513          	addi	a0,a0,94 # 80012310 <cons>
    800002ba:	1d9000ef          	jal	80000c92 <release>
}
    800002be:	70a2                	ld	ra,40(sp)
    800002c0:	7402                	ld	s0,32(sp)
    800002c2:	64e2                	ld	s1,24(sp)
    800002c4:	6145                	addi	sp,sp,48
    800002c6:	8082                	ret
  switch(c){
    800002c8:	07f00793          	li	a5,127
    800002cc:	0cf48463          	beq	s1,a5,80000394 <consoleintr+0x114>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002d0:	00012717          	auipc	a4,0x12
    800002d4:	04070713          	addi	a4,a4,64 # 80012310 <cons>
    800002d8:	0a072783          	lw	a5,160(a4)
    800002dc:	09872703          	lw	a4,152(a4)
    800002e0:	9f99                	subw	a5,a5,a4
    800002e2:	07f00713          	li	a4,127
    800002e6:	fcf766e3          	bltu	a4,a5,800002b2 <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    800002ea:	47b5                	li	a5,13
    800002ec:	0cf48b63          	beq	s1,a5,800003c2 <consoleintr+0x142>
      consputc(c);
    800002f0:	8526                	mv	a0,s1
    800002f2:	f5dff0ef          	jal	8000024e <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800002f6:	00012797          	auipc	a5,0x12
    800002fa:	01a78793          	addi	a5,a5,26 # 80012310 <cons>
    800002fe:	0a07a683          	lw	a3,160(a5)
    80000302:	0016871b          	addiw	a4,a3,1
    80000306:	863a                	mv	a2,a4
    80000308:	0ae7a023          	sw	a4,160(a5)
    8000030c:	07f6f693          	andi	a3,a3,127
    80000310:	97b6                	add	a5,a5,a3
    80000312:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000316:	47a9                	li	a5,10
    80000318:	0cf48963          	beq	s1,a5,800003ea <consoleintr+0x16a>
    8000031c:	4791                	li	a5,4
    8000031e:	0cf48663          	beq	s1,a5,800003ea <consoleintr+0x16a>
    80000322:	00012797          	auipc	a5,0x12
    80000326:	0867a783          	lw	a5,134(a5) # 800123a8 <cons+0x98>
    8000032a:	9f1d                	subw	a4,a4,a5
    8000032c:	08000793          	li	a5,128
    80000330:	f8f711e3          	bne	a4,a5,800002b2 <consoleintr+0x32>
    80000334:	a85d                	j	800003ea <consoleintr+0x16a>
    80000336:	e84a                	sd	s2,16(sp)
    80000338:	e44e                	sd	s3,8(sp)
    while(cons.e != cons.w &&
    8000033a:	00012717          	auipc	a4,0x12
    8000033e:	fd670713          	addi	a4,a4,-42 # 80012310 <cons>
    80000342:	0a072783          	lw	a5,160(a4)
    80000346:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000034a:	00012497          	auipc	s1,0x12
    8000034e:	fc648493          	addi	s1,s1,-58 # 80012310 <cons>
    while(cons.e != cons.w &&
    80000352:	4929                	li	s2,10
      consputc(BACKSPACE);
    80000354:	10000993          	li	s3,256
    while(cons.e != cons.w &&
    80000358:	02f70863          	beq	a4,a5,80000388 <consoleintr+0x108>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000035c:	37fd                	addiw	a5,a5,-1
    8000035e:	07f7f713          	andi	a4,a5,127
    80000362:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80000364:	01874703          	lbu	a4,24(a4)
    80000368:	03270363          	beq	a4,s2,8000038e <consoleintr+0x10e>
      cons.e--;
    8000036c:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80000370:	854e                	mv	a0,s3
    80000372:	eddff0ef          	jal	8000024e <consputc>
    while(cons.e != cons.w &&
    80000376:	0a04a783          	lw	a5,160(s1)
    8000037a:	09c4a703          	lw	a4,156(s1)
    8000037e:	fcf71fe3          	bne	a4,a5,8000035c <consoleintr+0xdc>
    80000382:	6942                	ld	s2,16(sp)
    80000384:	69a2                	ld	s3,8(sp)
    80000386:	b735                	j	800002b2 <consoleintr+0x32>
    80000388:	6942                	ld	s2,16(sp)
    8000038a:	69a2                	ld	s3,8(sp)
    8000038c:	b71d                	j	800002b2 <consoleintr+0x32>
    8000038e:	6942                	ld	s2,16(sp)
    80000390:	69a2                	ld	s3,8(sp)
    80000392:	b705                	j	800002b2 <consoleintr+0x32>
    if(cons.e != cons.w){
    80000394:	00012717          	auipc	a4,0x12
    80000398:	f7c70713          	addi	a4,a4,-132 # 80012310 <cons>
    8000039c:	0a072783          	lw	a5,160(a4)
    800003a0:	09c72703          	lw	a4,156(a4)
    800003a4:	f0f707e3          	beq	a4,a5,800002b2 <consoleintr+0x32>
      cons.e--;
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	00012717          	auipc	a4,0x12
    800003ae:	00f72323          	sw	a5,6(a4) # 800123b0 <cons+0xa0>
      consputc(BACKSPACE);
    800003b2:	10000513          	li	a0,256
    800003b6:	e99ff0ef          	jal	8000024e <consputc>
    800003ba:	bde5                	j	800002b2 <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003bc:	ee048be3          	beqz	s1,800002b2 <consoleintr+0x32>
    800003c0:	bf01                	j	800002d0 <consoleintr+0x50>
      consputc(c);
    800003c2:	4529                	li	a0,10
    800003c4:	e8bff0ef          	jal	8000024e <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003c8:	00012797          	auipc	a5,0x12
    800003cc:	f4878793          	addi	a5,a5,-184 # 80012310 <cons>
    800003d0:	0a07a703          	lw	a4,160(a5)
    800003d4:	0017069b          	addiw	a3,a4,1
    800003d8:	8636                	mv	a2,a3
    800003da:	0ad7a023          	sw	a3,160(a5)
    800003de:	07f77713          	andi	a4,a4,127
    800003e2:	97ba                	add	a5,a5,a4
    800003e4:	4729                	li	a4,10
    800003e6:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800003ea:	00012797          	auipc	a5,0x12
    800003ee:	fcc7a123          	sw	a2,-62(a5) # 800123ac <cons+0x9c>
        wakeup(&cons.r);
    800003f2:	00012517          	auipc	a0,0x12
    800003f6:	fb650513          	addi	a0,a0,-74 # 800123a8 <cons+0x98>
    800003fa:	2fd010ef          	jal	80001ef6 <wakeup>
    800003fe:	bd55                	j	800002b2 <consoleintr+0x32>

0000000080000400 <consoleinit>:

void
consoleinit(void)
{
    80000400:	1141                	addi	sp,sp,-16
    80000402:	e406                	sd	ra,8(sp)
    80000404:	e022                	sd	s0,0(sp)
    80000406:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000408:	00007597          	auipc	a1,0x7
    8000040c:	bf858593          	addi	a1,a1,-1032 # 80007000 <etext>
    80000410:	00012517          	auipc	a0,0x12
    80000414:	f0050513          	addi	a0,a0,-256 # 80012310 <cons>
    80000418:	762000ef          	jal	80000b7a <initlock>

  uartinit();
    8000041c:	3ea000ef          	jal	80000806 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000420:	00022797          	auipc	a5,0x22
    80000424:	08878793          	addi	a5,a5,136 # 800224a8 <devsw>
    80000428:	00000717          	auipc	a4,0x0
    8000042c:	d2270713          	addi	a4,a4,-734 # 8000014a <consoleread>
    80000430:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000432:	00000717          	auipc	a4,0x0
    80000436:	ca270713          	addi	a4,a4,-862 # 800000d4 <consolewrite>
    8000043a:	ef98                	sd	a4,24(a5)
}
    8000043c:	60a2                	ld	ra,8(sp)
    8000043e:	6402                	ld	s0,0(sp)
    80000440:	0141                	addi	sp,sp,16
    80000442:	8082                	ret

0000000080000444 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000444:	7179                	addi	sp,sp,-48
    80000446:	f406                	sd	ra,40(sp)
    80000448:	f022                	sd	s0,32(sp)
    8000044a:	ec26                	sd	s1,24(sp)
    8000044c:	e84a                	sd	s2,16(sp)
    8000044e:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000450:	c219                	beqz	a2,80000456 <printint+0x12>
    80000452:	06054a63          	bltz	a0,800004c6 <printint+0x82>
    x = -xx;
  else
    x = xx;
    80000456:	4e01                	li	t3,0

  i = 0;
    80000458:	fd040313          	addi	t1,s0,-48
    x = xx;
    8000045c:	869a                	mv	a3,t1
  i = 0;
    8000045e:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80000460:	00007817          	auipc	a6,0x7
    80000464:	31080813          	addi	a6,a6,784 # 80007770 <digits>
    80000468:	88be                	mv	a7,a5
    8000046a:	0017861b          	addiw	a2,a5,1
    8000046e:	87b2                	mv	a5,a2
    80000470:	02b57733          	remu	a4,a0,a1
    80000474:	9742                	add	a4,a4,a6
    80000476:	00074703          	lbu	a4,0(a4)
    8000047a:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    8000047e:	872a                	mv	a4,a0
    80000480:	02b55533          	divu	a0,a0,a1
    80000484:	0685                	addi	a3,a3,1
    80000486:	feb771e3          	bgeu	a4,a1,80000468 <printint+0x24>

  if(sign)
    8000048a:	000e0c63          	beqz	t3,800004a2 <printint+0x5e>
    buf[i++] = '-';
    8000048e:	fe060793          	addi	a5,a2,-32
    80000492:	00878633          	add	a2,a5,s0
    80000496:	02d00793          	li	a5,45
    8000049a:	fef60823          	sb	a5,-16(a2)
    8000049e:	0028879b          	addiw	a5,a7,2

  while(--i >= 0)
    800004a2:	fff7891b          	addiw	s2,a5,-1
    800004a6:	006784b3          	add	s1,a5,t1
    consputc(buf[i]);
    800004aa:	fff4c503          	lbu	a0,-1(s1)
    800004ae:	da1ff0ef          	jal	8000024e <consputc>
  while(--i >= 0)
    800004b2:	397d                	addiw	s2,s2,-1
    800004b4:	14fd                	addi	s1,s1,-1
    800004b6:	fe095ae3          	bgez	s2,800004aa <printint+0x66>
}
    800004ba:	70a2                	ld	ra,40(sp)
    800004bc:	7402                	ld	s0,32(sp)
    800004be:	64e2                	ld	s1,24(sp)
    800004c0:	6942                	ld	s2,16(sp)
    800004c2:	6145                	addi	sp,sp,48
    800004c4:	8082                	ret
    x = -xx;
    800004c6:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004ca:	4e05                	li	t3,1
    x = -xx;
    800004cc:	b771                	j	80000458 <printint+0x14>

00000000800004ce <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004ce:	7155                	addi	sp,sp,-208
    800004d0:	e506                	sd	ra,136(sp)
    800004d2:	e122                	sd	s0,128(sp)
    800004d4:	f0d2                	sd	s4,96(sp)
    800004d6:	0900                	addi	s0,sp,144
    800004d8:	8a2a                	mv	s4,a0
    800004da:	e40c                	sd	a1,8(s0)
    800004dc:	e810                	sd	a2,16(s0)
    800004de:	ec14                	sd	a3,24(s0)
    800004e0:	f018                	sd	a4,32(s0)
    800004e2:	f41c                	sd	a5,40(s0)
    800004e4:	03043823          	sd	a6,48(s0)
    800004e8:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    800004ec:	00012797          	auipc	a5,0x12
    800004f0:	ee47a783          	lw	a5,-284(a5) # 800123d0 <pr+0x18>
    800004f4:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    800004f8:	e3a1                	bnez	a5,80000538 <printf+0x6a>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800004fa:	00840793          	addi	a5,s0,8
    800004fe:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000502:	00054503          	lbu	a0,0(a0)
    80000506:	26050663          	beqz	a0,80000772 <printf+0x2a4>
    8000050a:	fca6                	sd	s1,120(sp)
    8000050c:	f8ca                	sd	s2,112(sp)
    8000050e:	f4ce                	sd	s3,104(sp)
    80000510:	ecd6                	sd	s5,88(sp)
    80000512:	e8da                	sd	s6,80(sp)
    80000514:	e0e2                	sd	s8,64(sp)
    80000516:	fc66                	sd	s9,56(sp)
    80000518:	f86a                	sd	s10,48(sp)
    8000051a:	f46e                	sd	s11,40(sp)
    8000051c:	4981                	li	s3,0
    if(cx != '%'){
    8000051e:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80000522:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    80000526:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000052a:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    8000052e:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000532:	07000d93          	li	s11,112
    80000536:	a80d                	j	80000568 <printf+0x9a>
    acquire(&pr.lock);
    80000538:	00012517          	auipc	a0,0x12
    8000053c:	e8050513          	addi	a0,a0,-384 # 800123b8 <pr>
    80000540:	6be000ef          	jal	80000bfe <acquire>
  va_start(ap, fmt);
    80000544:	00840793          	addi	a5,s0,8
    80000548:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000054c:	000a4503          	lbu	a0,0(s4)
    80000550:	fd4d                	bnez	a0,8000050a <printf+0x3c>
    80000552:	ac3d                	j	80000790 <printf+0x2c2>
      consputc(cx);
    80000554:	cfbff0ef          	jal	8000024e <consputc>
      continue;
    80000558:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000055a:	2485                	addiw	s1,s1,1
    8000055c:	89a6                	mv	s3,s1
    8000055e:	94d2                	add	s1,s1,s4
    80000560:	0004c503          	lbu	a0,0(s1)
    80000564:	1e050b63          	beqz	a0,8000075a <printf+0x28c>
    if(cx != '%'){
    80000568:	ff5516e3          	bne	a0,s5,80000554 <printf+0x86>
    i++;
    8000056c:	0019879b          	addiw	a5,s3,1
    80000570:	84be                	mv	s1,a5
    c0 = fmt[i+0] & 0xff;
    80000572:	00fa0733          	add	a4,s4,a5
    80000576:	00074903          	lbu	s2,0(a4)
    if(c0) c1 = fmt[i+1] & 0xff;
    8000057a:	1e090063          	beqz	s2,8000075a <printf+0x28c>
    8000057e:	00174703          	lbu	a4,1(a4)
    c1 = c2 = 0;
    80000582:	86ba                	mv	a3,a4
    if(c1) c2 = fmt[i+2] & 0xff;
    80000584:	c701                	beqz	a4,8000058c <printf+0xbe>
    80000586:	97d2                	add	a5,a5,s4
    80000588:	0027c683          	lbu	a3,2(a5)
    if(c0 == 'd'){
    8000058c:	03690763          	beq	s2,s6,800005ba <printf+0xec>
    } else if(c0 == 'l' && c1 == 'd'){
    80000590:	05890163          	beq	s2,s8,800005d2 <printf+0x104>
    } else if(c0 == 'u'){
    80000594:	0d990b63          	beq	s2,s9,8000066a <printf+0x19c>
    } else if(c0 == 'x'){
    80000598:	13a90163          	beq	s2,s10,800006ba <printf+0x1ec>
    } else if(c0 == 'p'){
    8000059c:	13b90b63          	beq	s2,s11,800006d2 <printf+0x204>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 's'){
    800005a0:	07300793          	li	a5,115
    800005a4:	16f90a63          	beq	s2,a5,80000718 <printf+0x24a>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    800005a8:	1b590463          	beq	s2,s5,80000750 <printf+0x282>
      consputc('%');
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    800005ac:	8556                	mv	a0,s5
    800005ae:	ca1ff0ef          	jal	8000024e <consputc>
      consputc(c0);
    800005b2:	854a                	mv	a0,s2
    800005b4:	c9bff0ef          	jal	8000024e <consputc>
    800005b8:	b74d                	j	8000055a <printf+0x8c>
      printint(va_arg(ap, int), 10, 1);
    800005ba:	f8843783          	ld	a5,-120(s0)
    800005be:	00878713          	addi	a4,a5,8
    800005c2:	f8e43423          	sd	a4,-120(s0)
    800005c6:	4605                	li	a2,1
    800005c8:	45a9                	li	a1,10
    800005ca:	4388                	lw	a0,0(a5)
    800005cc:	e79ff0ef          	jal	80000444 <printint>
    800005d0:	b769                	j	8000055a <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'd'){
    800005d2:	03670663          	beq	a4,s6,800005fe <printf+0x130>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005d6:	05870263          	beq	a4,s8,8000061a <printf+0x14c>
    } else if(c0 == 'l' && c1 == 'u'){
    800005da:	0b970463          	beq	a4,s9,80000682 <printf+0x1b4>
    } else if(c0 == 'l' && c1 == 'x'){
    800005de:	fda717e3          	bne	a4,s10,800005ac <printf+0xde>
      printint(va_arg(ap, uint64), 16, 0);
    800005e2:	f8843783          	ld	a5,-120(s0)
    800005e6:	00878713          	addi	a4,a5,8
    800005ea:	f8e43423          	sd	a4,-120(s0)
    800005ee:	4601                	li	a2,0
    800005f0:	45c1                	li	a1,16
    800005f2:	6388                	ld	a0,0(a5)
    800005f4:	e51ff0ef          	jal	80000444 <printint>
      i += 1;
    800005f8:	0029849b          	addiw	s1,s3,2
    800005fc:	bfb9                	j	8000055a <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    800005fe:	f8843783          	ld	a5,-120(s0)
    80000602:	00878713          	addi	a4,a5,8
    80000606:	f8e43423          	sd	a4,-120(s0)
    8000060a:	4605                	li	a2,1
    8000060c:	45a9                	li	a1,10
    8000060e:	6388                	ld	a0,0(a5)
    80000610:	e35ff0ef          	jal	80000444 <printint>
      i += 1;
    80000614:	0029849b          	addiw	s1,s3,2
    80000618:	b789                	j	8000055a <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    8000061a:	06400793          	li	a5,100
    8000061e:	02f68863          	beq	a3,a5,8000064e <printf+0x180>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000622:	07500793          	li	a5,117
    80000626:	06f68c63          	beq	a3,a5,8000069e <printf+0x1d0>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000062a:	07800793          	li	a5,120
    8000062e:	f6f69fe3          	bne	a3,a5,800005ac <printf+0xde>
      printint(va_arg(ap, uint64), 16, 0);
    80000632:	f8843783          	ld	a5,-120(s0)
    80000636:	00878713          	addi	a4,a5,8
    8000063a:	f8e43423          	sd	a4,-120(s0)
    8000063e:	4601                	li	a2,0
    80000640:	45c1                	li	a1,16
    80000642:	6388                	ld	a0,0(a5)
    80000644:	e01ff0ef          	jal	80000444 <printint>
      i += 2;
    80000648:	0039849b          	addiw	s1,s3,3
    8000064c:	b739                	j	8000055a <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    8000064e:	f8843783          	ld	a5,-120(s0)
    80000652:	00878713          	addi	a4,a5,8
    80000656:	f8e43423          	sd	a4,-120(s0)
    8000065a:	4605                	li	a2,1
    8000065c:	45a9                	li	a1,10
    8000065e:	6388                	ld	a0,0(a5)
    80000660:	de5ff0ef          	jal	80000444 <printint>
      i += 2;
    80000664:	0039849b          	addiw	s1,s3,3
    80000668:	bdcd                	j	8000055a <printf+0x8c>
      printint(va_arg(ap, int), 10, 0);
    8000066a:	f8843783          	ld	a5,-120(s0)
    8000066e:	00878713          	addi	a4,a5,8
    80000672:	f8e43423          	sd	a4,-120(s0)
    80000676:	4601                	li	a2,0
    80000678:	45a9                	li	a1,10
    8000067a:	4388                	lw	a0,0(a5)
    8000067c:	dc9ff0ef          	jal	80000444 <printint>
    80000680:	bde9                	j	8000055a <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80000682:	f8843783          	ld	a5,-120(s0)
    80000686:	00878713          	addi	a4,a5,8
    8000068a:	f8e43423          	sd	a4,-120(s0)
    8000068e:	4601                	li	a2,0
    80000690:	45a9                	li	a1,10
    80000692:	6388                	ld	a0,0(a5)
    80000694:	db1ff0ef          	jal	80000444 <printint>
      i += 1;
    80000698:	0029849b          	addiw	s1,s3,2
    8000069c:	bd7d                	j	8000055a <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    8000069e:	f8843783          	ld	a5,-120(s0)
    800006a2:	00878713          	addi	a4,a5,8
    800006a6:	f8e43423          	sd	a4,-120(s0)
    800006aa:	4601                	li	a2,0
    800006ac:	45a9                	li	a1,10
    800006ae:	6388                	ld	a0,0(a5)
    800006b0:	d95ff0ef          	jal	80000444 <printint>
      i += 2;
    800006b4:	0039849b          	addiw	s1,s3,3
    800006b8:	b54d                	j	8000055a <printf+0x8c>
      printint(va_arg(ap, int), 16, 0);
    800006ba:	f8843783          	ld	a5,-120(s0)
    800006be:	00878713          	addi	a4,a5,8
    800006c2:	f8e43423          	sd	a4,-120(s0)
    800006c6:	4601                	li	a2,0
    800006c8:	45c1                	li	a1,16
    800006ca:	4388                	lw	a0,0(a5)
    800006cc:	d79ff0ef          	jal	80000444 <printint>
    800006d0:	b569                	j	8000055a <printf+0x8c>
    800006d2:	e4de                	sd	s7,72(sp)
      printptr(va_arg(ap, uint64));
    800006d4:	f8843783          	ld	a5,-120(s0)
    800006d8:	00878713          	addi	a4,a5,8
    800006dc:	f8e43423          	sd	a4,-120(s0)
    800006e0:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006e4:	03000513          	li	a0,48
    800006e8:	b67ff0ef          	jal	8000024e <consputc>
  consputc('x');
    800006ec:	07800513          	li	a0,120
    800006f0:	b5fff0ef          	jal	8000024e <consputc>
    800006f4:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006f6:	00007b97          	auipc	s7,0x7
    800006fa:	07ab8b93          	addi	s7,s7,122 # 80007770 <digits>
    800006fe:	03c9d793          	srli	a5,s3,0x3c
    80000702:	97de                	add	a5,a5,s7
    80000704:	0007c503          	lbu	a0,0(a5)
    80000708:	b47ff0ef          	jal	8000024e <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000070c:	0992                	slli	s3,s3,0x4
    8000070e:	397d                	addiw	s2,s2,-1
    80000710:	fe0917e3          	bnez	s2,800006fe <printf+0x230>
    80000714:	6ba6                	ld	s7,72(sp)
    80000716:	b591                	j	8000055a <printf+0x8c>
      if((s = va_arg(ap, char*)) == 0)
    80000718:	f8843783          	ld	a5,-120(s0)
    8000071c:	00878713          	addi	a4,a5,8
    80000720:	f8e43423          	sd	a4,-120(s0)
    80000724:	0007b903          	ld	s2,0(a5)
    80000728:	00090d63          	beqz	s2,80000742 <printf+0x274>
      for(; *s; s++)
    8000072c:	00094503          	lbu	a0,0(s2)
    80000730:	e20505e3          	beqz	a0,8000055a <printf+0x8c>
        consputc(*s);
    80000734:	b1bff0ef          	jal	8000024e <consputc>
      for(; *s; s++)
    80000738:	0905                	addi	s2,s2,1
    8000073a:	00094503          	lbu	a0,0(s2)
    8000073e:	f97d                	bnez	a0,80000734 <printf+0x266>
    80000740:	bd29                	j	8000055a <printf+0x8c>
        s = "(null)";
    80000742:	00007917          	auipc	s2,0x7
    80000746:	8c690913          	addi	s2,s2,-1850 # 80007008 <etext+0x8>
      for(; *s; s++)
    8000074a:	02800513          	li	a0,40
    8000074e:	b7dd                	j	80000734 <printf+0x266>
      consputc('%');
    80000750:	02500513          	li	a0,37
    80000754:	afbff0ef          	jal	8000024e <consputc>
    80000758:	b509                	j	8000055a <printf+0x8c>
    }
#endif
  }
  va_end(ap);

  if(locking)
    8000075a:	f7843783          	ld	a5,-136(s0)
    8000075e:	e385                	bnez	a5,8000077e <printf+0x2b0>
    80000760:	74e6                	ld	s1,120(sp)
    80000762:	7946                	ld	s2,112(sp)
    80000764:	79a6                	ld	s3,104(sp)
    80000766:	6ae6                	ld	s5,88(sp)
    80000768:	6b46                	ld	s6,80(sp)
    8000076a:	6c06                	ld	s8,64(sp)
    8000076c:	7ce2                	ld	s9,56(sp)
    8000076e:	7d42                	ld	s10,48(sp)
    80000770:	7da2                	ld	s11,40(sp)
    release(&pr.lock);

  return 0;
}
    80000772:	4501                	li	a0,0
    80000774:	60aa                	ld	ra,136(sp)
    80000776:	640a                	ld	s0,128(sp)
    80000778:	7a06                	ld	s4,96(sp)
    8000077a:	6169                	addi	sp,sp,208
    8000077c:	8082                	ret
    8000077e:	74e6                	ld	s1,120(sp)
    80000780:	7946                	ld	s2,112(sp)
    80000782:	79a6                	ld	s3,104(sp)
    80000784:	6ae6                	ld	s5,88(sp)
    80000786:	6b46                	ld	s6,80(sp)
    80000788:	6c06                	ld	s8,64(sp)
    8000078a:	7ce2                	ld	s9,56(sp)
    8000078c:	7d42                	ld	s10,48(sp)
    8000078e:	7da2                	ld	s11,40(sp)
    release(&pr.lock);
    80000790:	00012517          	auipc	a0,0x12
    80000794:	c2850513          	addi	a0,a0,-984 # 800123b8 <pr>
    80000798:	4fa000ef          	jal	80000c92 <release>
    8000079c:	bfd9                	j	80000772 <printf+0x2a4>

000000008000079e <panic>:

void
panic(char *s)
{
    8000079e:	1101                	addi	sp,sp,-32
    800007a0:	ec06                	sd	ra,24(sp)
    800007a2:	e822                	sd	s0,16(sp)
    800007a4:	e426                	sd	s1,8(sp)
    800007a6:	1000                	addi	s0,sp,32
    800007a8:	84aa                	mv	s1,a0
  pr.locking = 0;
    800007aa:	00012797          	auipc	a5,0x12
    800007ae:	c207a323          	sw	zero,-986(a5) # 800123d0 <pr+0x18>
  printf("panic: ");
    800007b2:	00007517          	auipc	a0,0x7
    800007b6:	86650513          	addi	a0,a0,-1946 # 80007018 <etext+0x18>
    800007ba:	d15ff0ef          	jal	800004ce <printf>
  printf("%s\n", s);
    800007be:	85a6                	mv	a1,s1
    800007c0:	00007517          	auipc	a0,0x7
    800007c4:	86050513          	addi	a0,a0,-1952 # 80007020 <etext+0x20>
    800007c8:	d07ff0ef          	jal	800004ce <printf>
  panicked = 1; // freeze uart output from other CPUs
    800007cc:	4785                	li	a5,1
    800007ce:	0000a717          	auipc	a4,0xa
    800007d2:	b0f72123          	sw	a5,-1278(a4) # 8000a2d0 <panicked>
  for(;;)
    800007d6:	a001                	j	800007d6 <panic+0x38>

00000000800007d8 <printfinit>:
    ;
}

void
printfinit(void)
{
    800007d8:	1101                	addi	sp,sp,-32
    800007da:	ec06                	sd	ra,24(sp)
    800007dc:	e822                	sd	s0,16(sp)
    800007de:	e426                	sd	s1,8(sp)
    800007e0:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800007e2:	00012497          	auipc	s1,0x12
    800007e6:	bd648493          	addi	s1,s1,-1066 # 800123b8 <pr>
    800007ea:	00007597          	auipc	a1,0x7
    800007ee:	83e58593          	addi	a1,a1,-1986 # 80007028 <etext+0x28>
    800007f2:	8526                	mv	a0,s1
    800007f4:	386000ef          	jal	80000b7a <initlock>
  pr.locking = 1;
    800007f8:	4785                	li	a5,1
    800007fa:	cc9c                	sw	a5,24(s1)
}
    800007fc:	60e2                	ld	ra,24(sp)
    800007fe:	6442                	ld	s0,16(sp)
    80000800:	64a2                	ld	s1,8(sp)
    80000802:	6105                	addi	sp,sp,32
    80000804:	8082                	ret

0000000080000806 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000806:	1141                	addi	sp,sp,-16
    80000808:	e406                	sd	ra,8(sp)
    8000080a:	e022                	sd	s0,0(sp)
    8000080c:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000080e:	100007b7          	lui	a5,0x10000
    80000812:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000816:	10000737          	lui	a4,0x10000
    8000081a:	f8000693          	li	a3,-128
    8000081e:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000822:	468d                	li	a3,3
    80000824:	10000637          	lui	a2,0x10000
    80000828:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    8000082c:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000830:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000834:	8732                	mv	a4,a2
    80000836:	461d                	li	a2,7
    80000838:	00c70123          	sb	a2,2(a4)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    8000083c:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000840:	00006597          	auipc	a1,0x6
    80000844:	7f058593          	addi	a1,a1,2032 # 80007030 <etext+0x30>
    80000848:	00012517          	auipc	a0,0x12
    8000084c:	b9050513          	addi	a0,a0,-1136 # 800123d8 <uart_tx_lock>
    80000850:	32a000ef          	jal	80000b7a <initlock>
}
    80000854:	60a2                	ld	ra,8(sp)
    80000856:	6402                	ld	s0,0(sp)
    80000858:	0141                	addi	sp,sp,16
    8000085a:	8082                	ret

000000008000085c <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000085c:	1101                	addi	sp,sp,-32
    8000085e:	ec06                	sd	ra,24(sp)
    80000860:	e822                	sd	s0,16(sp)
    80000862:	e426                	sd	s1,8(sp)
    80000864:	1000                	addi	s0,sp,32
    80000866:	84aa                	mv	s1,a0
  push_off();
    80000868:	356000ef          	jal	80000bbe <push_off>

  if(panicked){
    8000086c:	0000a797          	auipc	a5,0xa
    80000870:	a647a783          	lw	a5,-1436(a5) # 8000a2d0 <panicked>
    80000874:	e795                	bnez	a5,800008a0 <uartputc_sync+0x44>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000876:	10000737          	lui	a4,0x10000
    8000087a:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    8000087c:	00074783          	lbu	a5,0(a4)
    80000880:	0207f793          	andi	a5,a5,32
    80000884:	dfe5                	beqz	a5,8000087c <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    80000886:	0ff4f513          	zext.b	a0,s1
    8000088a:	100007b7          	lui	a5,0x10000
    8000088e:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000892:	3b0000ef          	jal	80000c42 <pop_off>
}
    80000896:	60e2                	ld	ra,24(sp)
    80000898:	6442                	ld	s0,16(sp)
    8000089a:	64a2                	ld	s1,8(sp)
    8000089c:	6105                	addi	sp,sp,32
    8000089e:	8082                	ret
    for(;;)
    800008a0:	a001                	j	800008a0 <uartputc_sync+0x44>

00000000800008a2 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    800008a2:	0000a797          	auipc	a5,0xa
    800008a6:	a367b783          	ld	a5,-1482(a5) # 8000a2d8 <uart_tx_r>
    800008aa:	0000a717          	auipc	a4,0xa
    800008ae:	a3673703          	ld	a4,-1482(a4) # 8000a2e0 <uart_tx_w>
    800008b2:	08f70163          	beq	a4,a5,80000934 <uartstart+0x92>
{
    800008b6:	7139                	addi	sp,sp,-64
    800008b8:	fc06                	sd	ra,56(sp)
    800008ba:	f822                	sd	s0,48(sp)
    800008bc:	f426                	sd	s1,40(sp)
    800008be:	f04a                	sd	s2,32(sp)
    800008c0:	ec4e                	sd	s3,24(sp)
    800008c2:	e852                	sd	s4,16(sp)
    800008c4:	e456                	sd	s5,8(sp)
    800008c6:	e05a                	sd	s6,0(sp)
    800008c8:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008ca:	10000937          	lui	s2,0x10000
    800008ce:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008d0:	00012a97          	auipc	s5,0x12
    800008d4:	b08a8a93          	addi	s5,s5,-1272 # 800123d8 <uart_tx_lock>
    uart_tx_r += 1;
    800008d8:	0000a497          	auipc	s1,0xa
    800008dc:	a0048493          	addi	s1,s1,-1536 # 8000a2d8 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008e0:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008e4:	0000a997          	auipc	s3,0xa
    800008e8:	9fc98993          	addi	s3,s3,-1540 # 8000a2e0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008ec:	00094703          	lbu	a4,0(s2)
    800008f0:	02077713          	andi	a4,a4,32
    800008f4:	c715                	beqz	a4,80000920 <uartstart+0x7e>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008f6:	01f7f713          	andi	a4,a5,31
    800008fa:	9756                	add	a4,a4,s5
    800008fc:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    80000900:	0785                	addi	a5,a5,1
    80000902:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    80000904:	8526                	mv	a0,s1
    80000906:	5f0010ef          	jal	80001ef6 <wakeup>
    WriteReg(THR, c);
    8000090a:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    8000090e:	609c                	ld	a5,0(s1)
    80000910:	0009b703          	ld	a4,0(s3)
    80000914:	fcf71ce3          	bne	a4,a5,800008ec <uartstart+0x4a>
      ReadReg(ISR);
    80000918:	100007b7          	lui	a5,0x10000
    8000091c:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>
  }
}
    80000920:	70e2                	ld	ra,56(sp)
    80000922:	7442                	ld	s0,48(sp)
    80000924:	74a2                	ld	s1,40(sp)
    80000926:	7902                	ld	s2,32(sp)
    80000928:	69e2                	ld	s3,24(sp)
    8000092a:	6a42                	ld	s4,16(sp)
    8000092c:	6aa2                	ld	s5,8(sp)
    8000092e:	6b02                	ld	s6,0(sp)
    80000930:	6121                	addi	sp,sp,64
    80000932:	8082                	ret
      ReadReg(ISR);
    80000934:	100007b7          	lui	a5,0x10000
    80000938:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>
      return;
    8000093c:	8082                	ret

000000008000093e <uartputc>:
{
    8000093e:	7179                	addi	sp,sp,-48
    80000940:	f406                	sd	ra,40(sp)
    80000942:	f022                	sd	s0,32(sp)
    80000944:	ec26                	sd	s1,24(sp)
    80000946:	e84a                	sd	s2,16(sp)
    80000948:	e44e                	sd	s3,8(sp)
    8000094a:	e052                	sd	s4,0(sp)
    8000094c:	1800                	addi	s0,sp,48
    8000094e:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    80000950:	00012517          	auipc	a0,0x12
    80000954:	a8850513          	addi	a0,a0,-1400 # 800123d8 <uart_tx_lock>
    80000958:	2a6000ef          	jal	80000bfe <acquire>
  if(panicked){
    8000095c:	0000a797          	auipc	a5,0xa
    80000960:	9747a783          	lw	a5,-1676(a5) # 8000a2d0 <panicked>
    80000964:	efbd                	bnez	a5,800009e2 <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000966:	0000a717          	auipc	a4,0xa
    8000096a:	97a73703          	ld	a4,-1670(a4) # 8000a2e0 <uart_tx_w>
    8000096e:	0000a797          	auipc	a5,0xa
    80000972:	96a7b783          	ld	a5,-1686(a5) # 8000a2d8 <uart_tx_r>
    80000976:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    8000097a:	00012997          	auipc	s3,0x12
    8000097e:	a5e98993          	addi	s3,s3,-1442 # 800123d8 <uart_tx_lock>
    80000982:	0000a497          	auipc	s1,0xa
    80000986:	95648493          	addi	s1,s1,-1706 # 8000a2d8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000098a:	0000a917          	auipc	s2,0xa
    8000098e:	95690913          	addi	s2,s2,-1706 # 8000a2e0 <uart_tx_w>
    80000992:	00e79d63          	bne	a5,a4,800009ac <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000996:	85ce                	mv	a1,s3
    80000998:	8526                	mv	a0,s1
    8000099a:	510010ef          	jal	80001eaa <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000099e:	00093703          	ld	a4,0(s2)
    800009a2:	609c                	ld	a5,0(s1)
    800009a4:	02078793          	addi	a5,a5,32
    800009a8:	fee787e3          	beq	a5,a4,80000996 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009ac:	00012497          	auipc	s1,0x12
    800009b0:	a2c48493          	addi	s1,s1,-1492 # 800123d8 <uart_tx_lock>
    800009b4:	01f77793          	andi	a5,a4,31
    800009b8:	97a6                	add	a5,a5,s1
    800009ba:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009be:	0705                	addi	a4,a4,1
    800009c0:	0000a797          	auipc	a5,0xa
    800009c4:	92e7b023          	sd	a4,-1760(a5) # 8000a2e0 <uart_tx_w>
  uartstart();
    800009c8:	edbff0ef          	jal	800008a2 <uartstart>
  release(&uart_tx_lock);
    800009cc:	8526                	mv	a0,s1
    800009ce:	2c4000ef          	jal	80000c92 <release>
}
    800009d2:	70a2                	ld	ra,40(sp)
    800009d4:	7402                	ld	s0,32(sp)
    800009d6:	64e2                	ld	s1,24(sp)
    800009d8:	6942                	ld	s2,16(sp)
    800009da:	69a2                	ld	s3,8(sp)
    800009dc:	6a02                	ld	s4,0(sp)
    800009de:	6145                	addi	sp,sp,48
    800009e0:	8082                	ret
    for(;;)
    800009e2:	a001                	j	800009e2 <uartputc+0xa4>

00000000800009e4 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009e4:	1141                	addi	sp,sp,-16
    800009e6:	e406                	sd	ra,8(sp)
    800009e8:	e022                	sd	s0,0(sp)
    800009ea:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009ec:	100007b7          	lui	a5,0x10000
    800009f0:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009f4:	8b85                	andi	a5,a5,1
    800009f6:	cb89                	beqz	a5,80000a08 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009f8:	100007b7          	lui	a5,0x10000
    800009fc:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    80000a00:	60a2                	ld	ra,8(sp)
    80000a02:	6402                	ld	s0,0(sp)
    80000a04:	0141                	addi	sp,sp,16
    80000a06:	8082                	ret
    return -1;
    80000a08:	557d                	li	a0,-1
    80000a0a:	bfdd                	j	80000a00 <uartgetc+0x1c>

0000000080000a0c <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000a0c:	1101                	addi	sp,sp,-32
    80000a0e:	ec06                	sd	ra,24(sp)
    80000a10:	e822                	sd	s0,16(sp)
    80000a12:	e426                	sd	s1,8(sp)
    80000a14:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a16:	54fd                	li	s1,-1
    int c = uartgetc();
    80000a18:	fcdff0ef          	jal	800009e4 <uartgetc>
    if(c == -1)
    80000a1c:	00950563          	beq	a0,s1,80000a26 <uartintr+0x1a>
      break;
    consoleintr(c);
    80000a20:	861ff0ef          	jal	80000280 <consoleintr>
  while(1){
    80000a24:	bfd5                	j	80000a18 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a26:	00012497          	auipc	s1,0x12
    80000a2a:	9b248493          	addi	s1,s1,-1614 # 800123d8 <uart_tx_lock>
    80000a2e:	8526                	mv	a0,s1
    80000a30:	1ce000ef          	jal	80000bfe <acquire>
  uartstart();
    80000a34:	e6fff0ef          	jal	800008a2 <uartstart>
  release(&uart_tx_lock);
    80000a38:	8526                	mv	a0,s1
    80000a3a:	258000ef          	jal	80000c92 <release>
}
    80000a3e:	60e2                	ld	ra,24(sp)
    80000a40:	6442                	ld	s0,16(sp)
    80000a42:	64a2                	ld	s1,8(sp)
    80000a44:	6105                	addi	sp,sp,32
    80000a46:	8082                	ret

0000000080000a48 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a48:	1101                	addi	sp,sp,-32
    80000a4a:	ec06                	sd	ra,24(sp)
    80000a4c:	e822                	sd	s0,16(sp)
    80000a4e:	e426                	sd	s1,8(sp)
    80000a50:	e04a                	sd	s2,0(sp)
    80000a52:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a54:	03451793          	slli	a5,a0,0x34
    80000a58:	e7a9                	bnez	a5,80000aa2 <kfree+0x5a>
    80000a5a:	84aa                	mv	s1,a0
    80000a5c:	00023797          	auipc	a5,0x23
    80000a60:	be478793          	addi	a5,a5,-1052 # 80023640 <end>
    80000a64:	02f56f63          	bltu	a0,a5,80000aa2 <kfree+0x5a>
    80000a68:	47c5                	li	a5,17
    80000a6a:	07ee                	slli	a5,a5,0x1b
    80000a6c:	02f57b63          	bgeu	a0,a5,80000aa2 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a70:	6605                	lui	a2,0x1
    80000a72:	4585                	li	a1,1
    80000a74:	25a000ef          	jal	80000cce <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a78:	00012917          	auipc	s2,0x12
    80000a7c:	99890913          	addi	s2,s2,-1640 # 80012410 <kmem>
    80000a80:	854a                	mv	a0,s2
    80000a82:	17c000ef          	jal	80000bfe <acquire>
  r->next = kmem.freelist;
    80000a86:	01893783          	ld	a5,24(s2)
    80000a8a:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a8c:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a90:	854a                	mv	a0,s2
    80000a92:	200000ef          	jal	80000c92 <release>
}
    80000a96:	60e2                	ld	ra,24(sp)
    80000a98:	6442                	ld	s0,16(sp)
    80000a9a:	64a2                	ld	s1,8(sp)
    80000a9c:	6902                	ld	s2,0(sp)
    80000a9e:	6105                	addi	sp,sp,32
    80000aa0:	8082                	ret
    panic("kfree");
    80000aa2:	00006517          	auipc	a0,0x6
    80000aa6:	59650513          	addi	a0,a0,1430 # 80007038 <etext+0x38>
    80000aaa:	cf5ff0ef          	jal	8000079e <panic>

0000000080000aae <freerange>:
{
    80000aae:	7179                	addi	sp,sp,-48
    80000ab0:	f406                	sd	ra,40(sp)
    80000ab2:	f022                	sd	s0,32(sp)
    80000ab4:	ec26                	sd	s1,24(sp)
    80000ab6:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ab8:	6785                	lui	a5,0x1
    80000aba:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000abe:	00e504b3          	add	s1,a0,a4
    80000ac2:	777d                	lui	a4,0xfffff
    80000ac4:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ac6:	94be                	add	s1,s1,a5
    80000ac8:	0295e263          	bltu	a1,s1,80000aec <freerange+0x3e>
    80000acc:	e84a                	sd	s2,16(sp)
    80000ace:	e44e                	sd	s3,8(sp)
    80000ad0:	e052                	sd	s4,0(sp)
    80000ad2:	892e                	mv	s2,a1
    kfree(p);
    80000ad4:	8a3a                	mv	s4,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ad6:	89be                	mv	s3,a5
    kfree(p);
    80000ad8:	01448533          	add	a0,s1,s4
    80000adc:	f6dff0ef          	jal	80000a48 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ae0:	94ce                	add	s1,s1,s3
    80000ae2:	fe997be3          	bgeu	s2,s1,80000ad8 <freerange+0x2a>
    80000ae6:	6942                	ld	s2,16(sp)
    80000ae8:	69a2                	ld	s3,8(sp)
    80000aea:	6a02                	ld	s4,0(sp)
}
    80000aec:	70a2                	ld	ra,40(sp)
    80000aee:	7402                	ld	s0,32(sp)
    80000af0:	64e2                	ld	s1,24(sp)
    80000af2:	6145                	addi	sp,sp,48
    80000af4:	8082                	ret

0000000080000af6 <kinit>:
{
    80000af6:	1141                	addi	sp,sp,-16
    80000af8:	e406                	sd	ra,8(sp)
    80000afa:	e022                	sd	s0,0(sp)
    80000afc:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000afe:	00006597          	auipc	a1,0x6
    80000b02:	54258593          	addi	a1,a1,1346 # 80007040 <etext+0x40>
    80000b06:	00012517          	auipc	a0,0x12
    80000b0a:	90a50513          	addi	a0,a0,-1782 # 80012410 <kmem>
    80000b0e:	06c000ef          	jal	80000b7a <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b12:	45c5                	li	a1,17
    80000b14:	05ee                	slli	a1,a1,0x1b
    80000b16:	00023517          	auipc	a0,0x23
    80000b1a:	b2a50513          	addi	a0,a0,-1238 # 80023640 <end>
    80000b1e:	f91ff0ef          	jal	80000aae <freerange>
}
    80000b22:	60a2                	ld	ra,8(sp)
    80000b24:	6402                	ld	s0,0(sp)
    80000b26:	0141                	addi	sp,sp,16
    80000b28:	8082                	ret

0000000080000b2a <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b2a:	1101                	addi	sp,sp,-32
    80000b2c:	ec06                	sd	ra,24(sp)
    80000b2e:	e822                	sd	s0,16(sp)
    80000b30:	e426                	sd	s1,8(sp)
    80000b32:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b34:	00012497          	auipc	s1,0x12
    80000b38:	8dc48493          	addi	s1,s1,-1828 # 80012410 <kmem>
    80000b3c:	8526                	mv	a0,s1
    80000b3e:	0c0000ef          	jal	80000bfe <acquire>
  r = kmem.freelist;
    80000b42:	6c84                	ld	s1,24(s1)
  if(r)
    80000b44:	c485                	beqz	s1,80000b6c <kalloc+0x42>
    kmem.freelist = r->next;
    80000b46:	609c                	ld	a5,0(s1)
    80000b48:	00012517          	auipc	a0,0x12
    80000b4c:	8c850513          	addi	a0,a0,-1848 # 80012410 <kmem>
    80000b50:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b52:	140000ef          	jal	80000c92 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b56:	6605                	lui	a2,0x1
    80000b58:	4595                	li	a1,5
    80000b5a:	8526                	mv	a0,s1
    80000b5c:	172000ef          	jal	80000cce <memset>
  return (void*)r;
}
    80000b60:	8526                	mv	a0,s1
    80000b62:	60e2                	ld	ra,24(sp)
    80000b64:	6442                	ld	s0,16(sp)
    80000b66:	64a2                	ld	s1,8(sp)
    80000b68:	6105                	addi	sp,sp,32
    80000b6a:	8082                	ret
  release(&kmem.lock);
    80000b6c:	00012517          	auipc	a0,0x12
    80000b70:	8a450513          	addi	a0,a0,-1884 # 80012410 <kmem>
    80000b74:	11e000ef          	jal	80000c92 <release>
  if(r)
    80000b78:	b7e5                	j	80000b60 <kalloc+0x36>

0000000080000b7a <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b7a:	1141                	addi	sp,sp,-16
    80000b7c:	e406                	sd	ra,8(sp)
    80000b7e:	e022                	sd	s0,0(sp)
    80000b80:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b82:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b84:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b88:	00053823          	sd	zero,16(a0)
}
    80000b8c:	60a2                	ld	ra,8(sp)
    80000b8e:	6402                	ld	s0,0(sp)
    80000b90:	0141                	addi	sp,sp,16
    80000b92:	8082                	ret

0000000080000b94 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b94:	411c                	lw	a5,0(a0)
    80000b96:	e399                	bnez	a5,80000b9c <holding+0x8>
    80000b98:	4501                	li	a0,0
  return r;
}
    80000b9a:	8082                	ret
{
    80000b9c:	1101                	addi	sp,sp,-32
    80000b9e:	ec06                	sd	ra,24(sp)
    80000ba0:	e822                	sd	s0,16(sp)
    80000ba2:	e426                	sd	s1,8(sp)
    80000ba4:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000ba6:	6904                	ld	s1,16(a0)
    80000ba8:	515000ef          	jal	800018bc <mycpu>
    80000bac:	40a48533          	sub	a0,s1,a0
    80000bb0:	00153513          	seqz	a0,a0
}
    80000bb4:	60e2                	ld	ra,24(sp)
    80000bb6:	6442                	ld	s0,16(sp)
    80000bb8:	64a2                	ld	s1,8(sp)
    80000bba:	6105                	addi	sp,sp,32
    80000bbc:	8082                	ret

0000000080000bbe <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bbe:	1101                	addi	sp,sp,-32
    80000bc0:	ec06                	sd	ra,24(sp)
    80000bc2:	e822                	sd	s0,16(sp)
    80000bc4:	e426                	sd	s1,8(sp)
    80000bc6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bc8:	100024f3          	csrr	s1,sstatus
    80000bcc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bd0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bd2:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bd6:	4e7000ef          	jal	800018bc <mycpu>
    80000bda:	5d3c                	lw	a5,120(a0)
    80000bdc:	cb99                	beqz	a5,80000bf2 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bde:	4df000ef          	jal	800018bc <mycpu>
    80000be2:	5d3c                	lw	a5,120(a0)
    80000be4:	2785                	addiw	a5,a5,1
    80000be6:	dd3c                	sw	a5,120(a0)
}
    80000be8:	60e2                	ld	ra,24(sp)
    80000bea:	6442                	ld	s0,16(sp)
    80000bec:	64a2                	ld	s1,8(sp)
    80000bee:	6105                	addi	sp,sp,32
    80000bf0:	8082                	ret
    mycpu()->intena = old;
    80000bf2:	4cb000ef          	jal	800018bc <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bf6:	8085                	srli	s1,s1,0x1
    80000bf8:	8885                	andi	s1,s1,1
    80000bfa:	dd64                	sw	s1,124(a0)
    80000bfc:	b7cd                	j	80000bde <push_off+0x20>

0000000080000bfe <acquire>:
{
    80000bfe:	1101                	addi	sp,sp,-32
    80000c00:	ec06                	sd	ra,24(sp)
    80000c02:	e822                	sd	s0,16(sp)
    80000c04:	e426                	sd	s1,8(sp)
    80000c06:	1000                	addi	s0,sp,32
    80000c08:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c0a:	fb5ff0ef          	jal	80000bbe <push_off>
  if(holding(lk))
    80000c0e:	8526                	mv	a0,s1
    80000c10:	f85ff0ef          	jal	80000b94 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c14:	4705                	li	a4,1
  if(holding(lk))
    80000c16:	e105                	bnez	a0,80000c36 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c18:	87ba                	mv	a5,a4
    80000c1a:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c1e:	2781                	sext.w	a5,a5
    80000c20:	ffe5                	bnez	a5,80000c18 <acquire+0x1a>
  __sync_synchronize();
    80000c22:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000c26:	497000ef          	jal	800018bc <mycpu>
    80000c2a:	e888                	sd	a0,16(s1)
}
    80000c2c:	60e2                	ld	ra,24(sp)
    80000c2e:	6442                	ld	s0,16(sp)
    80000c30:	64a2                	ld	s1,8(sp)
    80000c32:	6105                	addi	sp,sp,32
    80000c34:	8082                	ret
    panic("acquire");
    80000c36:	00006517          	auipc	a0,0x6
    80000c3a:	41250513          	addi	a0,a0,1042 # 80007048 <etext+0x48>
    80000c3e:	b61ff0ef          	jal	8000079e <panic>

0000000080000c42 <pop_off>:

void
pop_off(void)
{
    80000c42:	1141                	addi	sp,sp,-16
    80000c44:	e406                	sd	ra,8(sp)
    80000c46:	e022                	sd	s0,0(sp)
    80000c48:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c4a:	473000ef          	jal	800018bc <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c4e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c52:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c54:	e39d                	bnez	a5,80000c7a <pop_off+0x38>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c56:	5d3c                	lw	a5,120(a0)
    80000c58:	02f05763          	blez	a5,80000c86 <pop_off+0x44>
    panic("pop_off");
  c->noff -= 1;
    80000c5c:	37fd                	addiw	a5,a5,-1
    80000c5e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c60:	eb89                	bnez	a5,80000c72 <pop_off+0x30>
    80000c62:	5d7c                	lw	a5,124(a0)
    80000c64:	c799                	beqz	a5,80000c72 <pop_off+0x30>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c66:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c6a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c6e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c72:	60a2                	ld	ra,8(sp)
    80000c74:	6402                	ld	s0,0(sp)
    80000c76:	0141                	addi	sp,sp,16
    80000c78:	8082                	ret
    panic("pop_off - interruptible");
    80000c7a:	00006517          	auipc	a0,0x6
    80000c7e:	3d650513          	addi	a0,a0,982 # 80007050 <etext+0x50>
    80000c82:	b1dff0ef          	jal	8000079e <panic>
    panic("pop_off");
    80000c86:	00006517          	auipc	a0,0x6
    80000c8a:	3e250513          	addi	a0,a0,994 # 80007068 <etext+0x68>
    80000c8e:	b11ff0ef          	jal	8000079e <panic>

0000000080000c92 <release>:
{
    80000c92:	1101                	addi	sp,sp,-32
    80000c94:	ec06                	sd	ra,24(sp)
    80000c96:	e822                	sd	s0,16(sp)
    80000c98:	e426                	sd	s1,8(sp)
    80000c9a:	1000                	addi	s0,sp,32
    80000c9c:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c9e:	ef7ff0ef          	jal	80000b94 <holding>
    80000ca2:	c105                	beqz	a0,80000cc2 <release+0x30>
  lk->cpu = 0;
    80000ca4:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca8:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000cac:	0310000f          	fence	rw,w
    80000cb0:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000cb4:	f8fff0ef          	jal	80000c42 <pop_off>
}
    80000cb8:	60e2                	ld	ra,24(sp)
    80000cba:	6442                	ld	s0,16(sp)
    80000cbc:	64a2                	ld	s1,8(sp)
    80000cbe:	6105                	addi	sp,sp,32
    80000cc0:	8082                	ret
    panic("release");
    80000cc2:	00006517          	auipc	a0,0x6
    80000cc6:	3ae50513          	addi	a0,a0,942 # 80007070 <etext+0x70>
    80000cca:	ad5ff0ef          	jal	8000079e <panic>

0000000080000cce <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cce:	1141                	addi	sp,sp,-16
    80000cd0:	e406                	sd	ra,8(sp)
    80000cd2:	e022                	sd	s0,0(sp)
    80000cd4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd6:	ca19                	beqz	a2,80000cec <memset+0x1e>
    80000cd8:	87aa                	mv	a5,a0
    80000cda:	1602                	slli	a2,a2,0x20
    80000cdc:	9201                	srli	a2,a2,0x20
    80000cde:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce6:	0785                	addi	a5,a5,1
    80000ce8:	fee79de3          	bne	a5,a4,80000ce2 <memset+0x14>
  }
  return dst;
}
    80000cec:	60a2                	ld	ra,8(sp)
    80000cee:	6402                	ld	s0,0(sp)
    80000cf0:	0141                	addi	sp,sp,16
    80000cf2:	8082                	ret

0000000080000cf4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf4:	1141                	addi	sp,sp,-16
    80000cf6:	e406                	sd	ra,8(sp)
    80000cf8:	e022                	sd	s0,0(sp)
    80000cfa:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cfc:	ca0d                	beqz	a2,80000d2e <memcmp+0x3a>
    80000cfe:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d02:	1682                	slli	a3,a3,0x20
    80000d04:	9281                	srli	a3,a3,0x20
    80000d06:	0685                	addi	a3,a3,1
    80000d08:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d0a:	00054783          	lbu	a5,0(a0)
    80000d0e:	0005c703          	lbu	a4,0(a1)
    80000d12:	00e79863          	bne	a5,a4,80000d22 <memcmp+0x2e>
      return *s1 - *s2;
    s1++, s2++;
    80000d16:	0505                	addi	a0,a0,1
    80000d18:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d1a:	fed518e3          	bne	a0,a3,80000d0a <memcmp+0x16>
  }

  return 0;
    80000d1e:	4501                	li	a0,0
    80000d20:	a019                	j	80000d26 <memcmp+0x32>
      return *s1 - *s2;
    80000d22:	40e7853b          	subw	a0,a5,a4
}
    80000d26:	60a2                	ld	ra,8(sp)
    80000d28:	6402                	ld	s0,0(sp)
    80000d2a:	0141                	addi	sp,sp,16
    80000d2c:	8082                	ret
  return 0;
    80000d2e:	4501                	li	a0,0
    80000d30:	bfdd                	j	80000d26 <memcmp+0x32>

0000000080000d32 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d32:	1141                	addi	sp,sp,-16
    80000d34:	e406                	sd	ra,8(sp)
    80000d36:	e022                	sd	s0,0(sp)
    80000d38:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d3a:	c205                	beqz	a2,80000d5a <memmove+0x28>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d3c:	02a5e363          	bltu	a1,a0,80000d62 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d40:	1602                	slli	a2,a2,0x20
    80000d42:	9201                	srli	a2,a2,0x20
    80000d44:	00c587b3          	add	a5,a1,a2
{
    80000d48:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d4a:	0585                	addi	a1,a1,1
    80000d4c:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdb9c1>
    80000d4e:	fff5c683          	lbu	a3,-1(a1)
    80000d52:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d56:	feb79ae3          	bne	a5,a1,80000d4a <memmove+0x18>

  return dst;
}
    80000d5a:	60a2                	ld	ra,8(sp)
    80000d5c:	6402                	ld	s0,0(sp)
    80000d5e:	0141                	addi	sp,sp,16
    80000d60:	8082                	ret
  if(s < d && s + n > d){
    80000d62:	02061693          	slli	a3,a2,0x20
    80000d66:	9281                	srli	a3,a3,0x20
    80000d68:	00d58733          	add	a4,a1,a3
    80000d6c:	fce57ae3          	bgeu	a0,a4,80000d40 <memmove+0xe>
    d += n;
    80000d70:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d72:	fff6079b          	addiw	a5,a2,-1
    80000d76:	1782                	slli	a5,a5,0x20
    80000d78:	9381                	srli	a5,a5,0x20
    80000d7a:	fff7c793          	not	a5,a5
    80000d7e:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d80:	177d                	addi	a4,a4,-1
    80000d82:	16fd                	addi	a3,a3,-1
    80000d84:	00074603          	lbu	a2,0(a4)
    80000d88:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d8c:	fee79ae3          	bne	a5,a4,80000d80 <memmove+0x4e>
    80000d90:	b7e9                	j	80000d5a <memmove+0x28>

0000000080000d92 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d92:	1141                	addi	sp,sp,-16
    80000d94:	e406                	sd	ra,8(sp)
    80000d96:	e022                	sd	s0,0(sp)
    80000d98:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d9a:	f99ff0ef          	jal	80000d32 <memmove>
}
    80000d9e:	60a2                	ld	ra,8(sp)
    80000da0:	6402                	ld	s0,0(sp)
    80000da2:	0141                	addi	sp,sp,16
    80000da4:	8082                	ret

0000000080000da6 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000da6:	1141                	addi	sp,sp,-16
    80000da8:	e406                	sd	ra,8(sp)
    80000daa:	e022                	sd	s0,0(sp)
    80000dac:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dae:	ce11                	beqz	a2,80000dca <strncmp+0x24>
    80000db0:	00054783          	lbu	a5,0(a0)
    80000db4:	cf89                	beqz	a5,80000dce <strncmp+0x28>
    80000db6:	0005c703          	lbu	a4,0(a1)
    80000dba:	00f71a63          	bne	a4,a5,80000dce <strncmp+0x28>
    n--, p++, q++;
    80000dbe:	367d                	addiw	a2,a2,-1
    80000dc0:	0505                	addi	a0,a0,1
    80000dc2:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dc4:	f675                	bnez	a2,80000db0 <strncmp+0xa>
  if(n == 0)
    return 0;
    80000dc6:	4501                	li	a0,0
    80000dc8:	a801                	j	80000dd8 <strncmp+0x32>
    80000dca:	4501                	li	a0,0
    80000dcc:	a031                	j	80000dd8 <strncmp+0x32>
  return (uchar)*p - (uchar)*q;
    80000dce:	00054503          	lbu	a0,0(a0)
    80000dd2:	0005c783          	lbu	a5,0(a1)
    80000dd6:	9d1d                	subw	a0,a0,a5
}
    80000dd8:	60a2                	ld	ra,8(sp)
    80000dda:	6402                	ld	s0,0(sp)
    80000ddc:	0141                	addi	sp,sp,16
    80000dde:	8082                	ret

0000000080000de0 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000de0:	1141                	addi	sp,sp,-16
    80000de2:	e406                	sd	ra,8(sp)
    80000de4:	e022                	sd	s0,0(sp)
    80000de6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de8:	87aa                	mv	a5,a0
    80000dea:	86b2                	mv	a3,a2
    80000dec:	367d                	addiw	a2,a2,-1
    80000dee:	02d05563          	blez	a3,80000e18 <strncpy+0x38>
    80000df2:	0785                	addi	a5,a5,1
    80000df4:	0005c703          	lbu	a4,0(a1)
    80000df8:	fee78fa3          	sb	a4,-1(a5)
    80000dfc:	0585                	addi	a1,a1,1
    80000dfe:	f775                	bnez	a4,80000dea <strncpy+0xa>
    ;
  while(n-- > 0)
    80000e00:	873e                	mv	a4,a5
    80000e02:	00c05b63          	blez	a2,80000e18 <strncpy+0x38>
    80000e06:	9fb5                	addw	a5,a5,a3
    80000e08:	37fd                	addiw	a5,a5,-1
    *s++ = 0;
    80000e0a:	0705                	addi	a4,a4,1
    80000e0c:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e10:	40e786bb          	subw	a3,a5,a4
    80000e14:	fed04be3          	bgtz	a3,80000e0a <strncpy+0x2a>
  return os;
}
    80000e18:	60a2                	ld	ra,8(sp)
    80000e1a:	6402                	ld	s0,0(sp)
    80000e1c:	0141                	addi	sp,sp,16
    80000e1e:	8082                	ret

0000000080000e20 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e20:	1141                	addi	sp,sp,-16
    80000e22:	e406                	sd	ra,8(sp)
    80000e24:	e022                	sd	s0,0(sp)
    80000e26:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e28:	02c05363          	blez	a2,80000e4e <safestrcpy+0x2e>
    80000e2c:	fff6069b          	addiw	a3,a2,-1
    80000e30:	1682                	slli	a3,a3,0x20
    80000e32:	9281                	srli	a3,a3,0x20
    80000e34:	96ae                	add	a3,a3,a1
    80000e36:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e38:	00d58963          	beq	a1,a3,80000e4a <safestrcpy+0x2a>
    80000e3c:	0585                	addi	a1,a1,1
    80000e3e:	0785                	addi	a5,a5,1
    80000e40:	fff5c703          	lbu	a4,-1(a1)
    80000e44:	fee78fa3          	sb	a4,-1(a5)
    80000e48:	fb65                	bnez	a4,80000e38 <safestrcpy+0x18>
    ;
  *s = 0;
    80000e4a:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e4e:	60a2                	ld	ra,8(sp)
    80000e50:	6402                	ld	s0,0(sp)
    80000e52:	0141                	addi	sp,sp,16
    80000e54:	8082                	ret

0000000080000e56 <strlen>:

int
strlen(const char *s)
{
    80000e56:	1141                	addi	sp,sp,-16
    80000e58:	e406                	sd	ra,8(sp)
    80000e5a:	e022                	sd	s0,0(sp)
    80000e5c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e5e:	00054783          	lbu	a5,0(a0)
    80000e62:	cf99                	beqz	a5,80000e80 <strlen+0x2a>
    80000e64:	0505                	addi	a0,a0,1
    80000e66:	87aa                	mv	a5,a0
    80000e68:	86be                	mv	a3,a5
    80000e6a:	0785                	addi	a5,a5,1
    80000e6c:	fff7c703          	lbu	a4,-1(a5)
    80000e70:	ff65                	bnez	a4,80000e68 <strlen+0x12>
    80000e72:	40a6853b          	subw	a0,a3,a0
    80000e76:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e78:	60a2                	ld	ra,8(sp)
    80000e7a:	6402                	ld	s0,0(sp)
    80000e7c:	0141                	addi	sp,sp,16
    80000e7e:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e80:	4501                	li	a0,0
    80000e82:	bfdd                	j	80000e78 <strlen+0x22>

0000000080000e84 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e84:	1141                	addi	sp,sp,-16
    80000e86:	e406                	sd	ra,8(sp)
    80000e88:	e022                	sd	s0,0(sp)
    80000e8a:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e8c:	21d000ef          	jal	800018a8 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e90:	00009717          	auipc	a4,0x9
    80000e94:	45870713          	addi	a4,a4,1112 # 8000a2e8 <started>
  if(cpuid() == 0){
    80000e98:	c51d                	beqz	a0,80000ec6 <main+0x42>
    while(started == 0)
    80000e9a:	431c                	lw	a5,0(a4)
    80000e9c:	2781                	sext.w	a5,a5
    80000e9e:	dff5                	beqz	a5,80000e9a <main+0x16>
      ;
    __sync_synchronize();
    80000ea0:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000ea4:	205000ef          	jal	800018a8 <cpuid>
    80000ea8:	85aa                	mv	a1,a0
    80000eaa:	00006517          	auipc	a0,0x6
    80000eae:	1ee50513          	addi	a0,a0,494 # 80007098 <etext+0x98>
    80000eb2:	e1cff0ef          	jal	800004ce <printf>
    kvminithart();    // turn on paging
    80000eb6:	080000ef          	jal	80000f36 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eba:	50c010ef          	jal	800023c6 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ebe:	47a040ef          	jal	80005338 <plicinithart>
  }

  scheduler();        
    80000ec2:	64f000ef          	jal	80001d10 <scheduler>
    consoleinit();
    80000ec6:	d3aff0ef          	jal	80000400 <consoleinit>
    printfinit();
    80000eca:	90fff0ef          	jal	800007d8 <printfinit>
    printf("\n");
    80000ece:	00006517          	auipc	a0,0x6
    80000ed2:	1aa50513          	addi	a0,a0,426 # 80007078 <etext+0x78>
    80000ed6:	df8ff0ef          	jal	800004ce <printf>
    printf("xv6 kernel is booting\n");
    80000eda:	00006517          	auipc	a0,0x6
    80000ede:	1a650513          	addi	a0,a0,422 # 80007080 <etext+0x80>
    80000ee2:	decff0ef          	jal	800004ce <printf>
    printf("\n");
    80000ee6:	00006517          	auipc	a0,0x6
    80000eea:	19250513          	addi	a0,a0,402 # 80007078 <etext+0x78>
    80000eee:	de0ff0ef          	jal	800004ce <printf>
    kinit();         // physical page allocator
    80000ef2:	c05ff0ef          	jal	80000af6 <kinit>
    kvminit();       // create kernel page table
    80000ef6:	2ce000ef          	jal	800011c4 <kvminit>
    kvminithart();   // turn on paging
    80000efa:	03c000ef          	jal	80000f36 <kvminithart>
    procinit();      // process table
    80000efe:	0fb000ef          	jal	800017f8 <procinit>
    trapinit();      // trap vectors
    80000f02:	4a0010ef          	jal	800023a2 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f06:	4c0010ef          	jal	800023c6 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f0a:	414040ef          	jal	8000531e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f0e:	42a040ef          	jal	80005338 <plicinithart>
    binit();         // buffer cache
    80000f12:	397010ef          	jal	80002aa8 <binit>
    iinit();         // inode table
    80000f16:	162020ef          	jal	80003078 <iinit>
    fileinit();      // file table
    80000f1a:	731020ef          	jal	80003e4a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f1e:	50a040ef          	jal	80005428 <virtio_disk_init>
    userinit();      // first user process
    80000f22:	423000ef          	jal	80001b44 <userinit>
    __sync_synchronize();
    80000f26:	0330000f          	fence	rw,rw
    started = 1;
    80000f2a:	4785                	li	a5,1
    80000f2c:	00009717          	auipc	a4,0x9
    80000f30:	3af72e23          	sw	a5,956(a4) # 8000a2e8 <started>
    80000f34:	b779                	j	80000ec2 <main+0x3e>

0000000080000f36 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f36:	1141                	addi	sp,sp,-16
    80000f38:	e406                	sd	ra,8(sp)
    80000f3a:	e022                	sd	s0,0(sp)
    80000f3c:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f3e:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f42:	00009797          	auipc	a5,0x9
    80000f46:	3ae7b783          	ld	a5,942(a5) # 8000a2f0 <kernel_pagetable>
    80000f4a:	83b1                	srli	a5,a5,0xc
    80000f4c:	577d                	li	a4,-1
    80000f4e:	177e                	slli	a4,a4,0x3f
    80000f50:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f52:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f56:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f5a:	60a2                	ld	ra,8(sp)
    80000f5c:	6402                	ld	s0,0(sp)
    80000f5e:	0141                	addi	sp,sp,16
    80000f60:	8082                	ret

0000000080000f62 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f62:	7139                	addi	sp,sp,-64
    80000f64:	fc06                	sd	ra,56(sp)
    80000f66:	f822                	sd	s0,48(sp)
    80000f68:	f426                	sd	s1,40(sp)
    80000f6a:	f04a                	sd	s2,32(sp)
    80000f6c:	ec4e                	sd	s3,24(sp)
    80000f6e:	e852                	sd	s4,16(sp)
    80000f70:	e456                	sd	s5,8(sp)
    80000f72:	e05a                	sd	s6,0(sp)
    80000f74:	0080                	addi	s0,sp,64
    80000f76:	84aa                	mv	s1,a0
    80000f78:	89ae                	mv	s3,a1
    80000f7a:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000f7c:	57fd                	li	a5,-1
    80000f7e:	83e9                	srli	a5,a5,0x1a
    80000f80:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000f82:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000f84:	04b7e263          	bltu	a5,a1,80000fc8 <walk+0x66>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f88:	0149d933          	srl	s2,s3,s4
    80000f8c:	1ff97913          	andi	s2,s2,511
    80000f90:	090e                	slli	s2,s2,0x3
    80000f92:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000f94:	00093483          	ld	s1,0(s2)
    80000f98:	0014f793          	andi	a5,s1,1
    80000f9c:	cf85                	beqz	a5,80000fd4 <walk+0x72>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000f9e:	80a9                	srli	s1,s1,0xa
    80000fa0:	04b2                	slli	s1,s1,0xc
  for(int level = 2; level > 0; level--) {
    80000fa2:	3a5d                	addiw	s4,s4,-9
    80000fa4:	ff6a12e3          	bne	s4,s6,80000f88 <walk+0x26>
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
    80000fa8:	00c9d513          	srli	a0,s3,0xc
    80000fac:	1ff57513          	andi	a0,a0,511
    80000fb0:	050e                	slli	a0,a0,0x3
    80000fb2:	9526                	add	a0,a0,s1
}
    80000fb4:	70e2                	ld	ra,56(sp)
    80000fb6:	7442                	ld	s0,48(sp)
    80000fb8:	74a2                	ld	s1,40(sp)
    80000fba:	7902                	ld	s2,32(sp)
    80000fbc:	69e2                	ld	s3,24(sp)
    80000fbe:	6a42                	ld	s4,16(sp)
    80000fc0:	6aa2                	ld	s5,8(sp)
    80000fc2:	6b02                	ld	s6,0(sp)
    80000fc4:	6121                	addi	sp,sp,64
    80000fc6:	8082                	ret
    panic("walk");
    80000fc8:	00006517          	auipc	a0,0x6
    80000fcc:	0e850513          	addi	a0,a0,232 # 800070b0 <etext+0xb0>
    80000fd0:	fceff0ef          	jal	8000079e <panic>
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fd4:	020a8263          	beqz	s5,80000ff8 <walk+0x96>
    80000fd8:	b53ff0ef          	jal	80000b2a <kalloc>
    80000fdc:	84aa                	mv	s1,a0
    80000fde:	d979                	beqz	a0,80000fb4 <walk+0x52>
      memset(pagetable, 0, PGSIZE);
    80000fe0:	6605                	lui	a2,0x1
    80000fe2:	4581                	li	a1,0
    80000fe4:	cebff0ef          	jal	80000cce <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000fe8:	00c4d793          	srli	a5,s1,0xc
    80000fec:	07aa                	slli	a5,a5,0xa
    80000fee:	0017e793          	ori	a5,a5,1
    80000ff2:	00f93023          	sd	a5,0(s2)
    80000ff6:	b775                	j	80000fa2 <walk+0x40>
        return 0;
    80000ff8:	4501                	li	a0,0
    80000ffa:	bf6d                	j	80000fb4 <walk+0x52>

0000000080000ffc <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000ffc:	57fd                	li	a5,-1
    80000ffe:	83e9                	srli	a5,a5,0x1a
    80001000:	00b7f463          	bgeu	a5,a1,80001008 <walkaddr+0xc>
    return 0;
    80001004:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001006:	8082                	ret
{
    80001008:	1141                	addi	sp,sp,-16
    8000100a:	e406                	sd	ra,8(sp)
    8000100c:	e022                	sd	s0,0(sp)
    8000100e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001010:	4601                	li	a2,0
    80001012:	f51ff0ef          	jal	80000f62 <walk>
  if(pte == 0)
    80001016:	c105                	beqz	a0,80001036 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80001018:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000101a:	0117f693          	andi	a3,a5,17
    8000101e:	4745                	li	a4,17
    return 0;
    80001020:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001022:	00e68663          	beq	a3,a4,8000102e <walkaddr+0x32>
}
    80001026:	60a2                	ld	ra,8(sp)
    80001028:	6402                	ld	s0,0(sp)
    8000102a:	0141                	addi	sp,sp,16
    8000102c:	8082                	ret
  pa = PTE2PA(*pte);
    8000102e:	83a9                	srli	a5,a5,0xa
    80001030:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001034:	bfcd                	j	80001026 <walkaddr+0x2a>
    return 0;
    80001036:	4501                	li	a0,0
    80001038:	b7fd                	j	80001026 <walkaddr+0x2a>

000000008000103a <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000103a:	715d                	addi	sp,sp,-80
    8000103c:	e486                	sd	ra,72(sp)
    8000103e:	e0a2                	sd	s0,64(sp)
    80001040:	fc26                	sd	s1,56(sp)
    80001042:	f84a                	sd	s2,48(sp)
    80001044:	f44e                	sd	s3,40(sp)
    80001046:	f052                	sd	s4,32(sp)
    80001048:	ec56                	sd	s5,24(sp)
    8000104a:	e85a                	sd	s6,16(sp)
    8000104c:	e45e                	sd	s7,8(sp)
    8000104e:	e062                	sd	s8,0(sp)
    80001050:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001052:	03459793          	slli	a5,a1,0x34
    80001056:	e7b1                	bnez	a5,800010a2 <mappages+0x68>
    80001058:	8aaa                	mv	s5,a0
    8000105a:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    8000105c:	03461793          	slli	a5,a2,0x34
    80001060:	e7b9                	bnez	a5,800010ae <mappages+0x74>
    panic("mappages: size not aligned");

  if(size == 0)
    80001062:	ce21                	beqz	a2,800010ba <mappages+0x80>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80001064:	77fd                	lui	a5,0xfffff
    80001066:	963e                	add	a2,a2,a5
    80001068:	00b609b3          	add	s3,a2,a1
  a = va;
    8000106c:	892e                	mv	s2,a1
    8000106e:	40b68a33          	sub	s4,a3,a1
  for(;;){
    if((pte = walk(pagetable, a, 1)) == 0)
    80001072:	4b85                	li	s7,1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001074:	6c05                	lui	s8,0x1
    80001076:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    8000107a:	865e                	mv	a2,s7
    8000107c:	85ca                	mv	a1,s2
    8000107e:	8556                	mv	a0,s5
    80001080:	ee3ff0ef          	jal	80000f62 <walk>
    80001084:	c539                	beqz	a0,800010d2 <mappages+0x98>
    if(*pte & PTE_V)
    80001086:	611c                	ld	a5,0(a0)
    80001088:	8b85                	andi	a5,a5,1
    8000108a:	ef95                	bnez	a5,800010c6 <mappages+0x8c>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000108c:	80b1                	srli	s1,s1,0xc
    8000108e:	04aa                	slli	s1,s1,0xa
    80001090:	0164e4b3          	or	s1,s1,s6
    80001094:	0014e493          	ori	s1,s1,1
    80001098:	e104                	sd	s1,0(a0)
    if(a == last)
    8000109a:	05390963          	beq	s2,s3,800010ec <mappages+0xb2>
    a += PGSIZE;
    8000109e:	9962                	add	s2,s2,s8
    if((pte = walk(pagetable, a, 1)) == 0)
    800010a0:	bfd9                	j	80001076 <mappages+0x3c>
    panic("mappages: va not aligned");
    800010a2:	00006517          	auipc	a0,0x6
    800010a6:	01650513          	addi	a0,a0,22 # 800070b8 <etext+0xb8>
    800010aa:	ef4ff0ef          	jal	8000079e <panic>
    panic("mappages: size not aligned");
    800010ae:	00006517          	auipc	a0,0x6
    800010b2:	02a50513          	addi	a0,a0,42 # 800070d8 <etext+0xd8>
    800010b6:	ee8ff0ef          	jal	8000079e <panic>
    panic("mappages: size");
    800010ba:	00006517          	auipc	a0,0x6
    800010be:	03e50513          	addi	a0,a0,62 # 800070f8 <etext+0xf8>
    800010c2:	edcff0ef          	jal	8000079e <panic>
      panic("mappages: remap");
    800010c6:	00006517          	auipc	a0,0x6
    800010ca:	04250513          	addi	a0,a0,66 # 80007108 <etext+0x108>
    800010ce:	ed0ff0ef          	jal	8000079e <panic>
      return -1;
    800010d2:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010d4:	60a6                	ld	ra,72(sp)
    800010d6:	6406                	ld	s0,64(sp)
    800010d8:	74e2                	ld	s1,56(sp)
    800010da:	7942                	ld	s2,48(sp)
    800010dc:	79a2                	ld	s3,40(sp)
    800010de:	7a02                	ld	s4,32(sp)
    800010e0:	6ae2                	ld	s5,24(sp)
    800010e2:	6b42                	ld	s6,16(sp)
    800010e4:	6ba2                	ld	s7,8(sp)
    800010e6:	6c02                	ld	s8,0(sp)
    800010e8:	6161                	addi	sp,sp,80
    800010ea:	8082                	ret
  return 0;
    800010ec:	4501                	li	a0,0
    800010ee:	b7dd                	j	800010d4 <mappages+0x9a>

00000000800010f0 <kvmmap>:
{
    800010f0:	1141                	addi	sp,sp,-16
    800010f2:	e406                	sd	ra,8(sp)
    800010f4:	e022                	sd	s0,0(sp)
    800010f6:	0800                	addi	s0,sp,16
    800010f8:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800010fa:	86b2                	mv	a3,a2
    800010fc:	863e                	mv	a2,a5
    800010fe:	f3dff0ef          	jal	8000103a <mappages>
    80001102:	e509                	bnez	a0,8000110c <kvmmap+0x1c>
}
    80001104:	60a2                	ld	ra,8(sp)
    80001106:	6402                	ld	s0,0(sp)
    80001108:	0141                	addi	sp,sp,16
    8000110a:	8082                	ret
    panic("kvmmap");
    8000110c:	00006517          	auipc	a0,0x6
    80001110:	00c50513          	addi	a0,a0,12 # 80007118 <etext+0x118>
    80001114:	e8aff0ef          	jal	8000079e <panic>

0000000080001118 <kvmmake>:
{
    80001118:	1101                	addi	sp,sp,-32
    8000111a:	ec06                	sd	ra,24(sp)
    8000111c:	e822                	sd	s0,16(sp)
    8000111e:	e426                	sd	s1,8(sp)
    80001120:	e04a                	sd	s2,0(sp)
    80001122:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001124:	a07ff0ef          	jal	80000b2a <kalloc>
    80001128:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000112a:	6605                	lui	a2,0x1
    8000112c:	4581                	li	a1,0
    8000112e:	ba1ff0ef          	jal	80000cce <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001132:	4719                	li	a4,6
    80001134:	6685                	lui	a3,0x1
    80001136:	10000637          	lui	a2,0x10000
    8000113a:	85b2                	mv	a1,a2
    8000113c:	8526                	mv	a0,s1
    8000113e:	fb3ff0ef          	jal	800010f0 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001142:	4719                	li	a4,6
    80001144:	6685                	lui	a3,0x1
    80001146:	10001637          	lui	a2,0x10001
    8000114a:	85b2                	mv	a1,a2
    8000114c:	8526                	mv	a0,s1
    8000114e:	fa3ff0ef          	jal	800010f0 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80001152:	4719                	li	a4,6
    80001154:	040006b7          	lui	a3,0x4000
    80001158:	0c000637          	lui	a2,0xc000
    8000115c:	85b2                	mv	a1,a2
    8000115e:	8526                	mv	a0,s1
    80001160:	f91ff0ef          	jal	800010f0 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001164:	00006917          	auipc	s2,0x6
    80001168:	e9c90913          	addi	s2,s2,-356 # 80007000 <etext>
    8000116c:	4729                	li	a4,10
    8000116e:	80006697          	auipc	a3,0x80006
    80001172:	e9268693          	addi	a3,a3,-366 # 7000 <_entry-0x7fff9000>
    80001176:	4605                	li	a2,1
    80001178:	067e                	slli	a2,a2,0x1f
    8000117a:	85b2                	mv	a1,a2
    8000117c:	8526                	mv	a0,s1
    8000117e:	f73ff0ef          	jal	800010f0 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001182:	4719                	li	a4,6
    80001184:	46c5                	li	a3,17
    80001186:	06ee                	slli	a3,a3,0x1b
    80001188:	412686b3          	sub	a3,a3,s2
    8000118c:	864a                	mv	a2,s2
    8000118e:	85ca                	mv	a1,s2
    80001190:	8526                	mv	a0,s1
    80001192:	f5fff0ef          	jal	800010f0 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001196:	4729                	li	a4,10
    80001198:	6685                	lui	a3,0x1
    8000119a:	00005617          	auipc	a2,0x5
    8000119e:	e6660613          	addi	a2,a2,-410 # 80006000 <_trampoline>
    800011a2:	040005b7          	lui	a1,0x4000
    800011a6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800011a8:	05b2                	slli	a1,a1,0xc
    800011aa:	8526                	mv	a0,s1
    800011ac:	f45ff0ef          	jal	800010f0 <kvmmap>
  proc_mapstacks(kpgtbl);
    800011b0:	8526                	mv	a0,s1
    800011b2:	5a8000ef          	jal	8000175a <proc_mapstacks>
}
    800011b6:	8526                	mv	a0,s1
    800011b8:	60e2                	ld	ra,24(sp)
    800011ba:	6442                	ld	s0,16(sp)
    800011bc:	64a2                	ld	s1,8(sp)
    800011be:	6902                	ld	s2,0(sp)
    800011c0:	6105                	addi	sp,sp,32
    800011c2:	8082                	ret

00000000800011c4 <kvminit>:
{
    800011c4:	1141                	addi	sp,sp,-16
    800011c6:	e406                	sd	ra,8(sp)
    800011c8:	e022                	sd	s0,0(sp)
    800011ca:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011cc:	f4dff0ef          	jal	80001118 <kvmmake>
    800011d0:	00009797          	auipc	a5,0x9
    800011d4:	12a7b023          	sd	a0,288(a5) # 8000a2f0 <kernel_pagetable>
}
    800011d8:	60a2                	ld	ra,8(sp)
    800011da:	6402                	ld	s0,0(sp)
    800011dc:	0141                	addi	sp,sp,16
    800011de:	8082                	ret

00000000800011e0 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011e0:	715d                	addi	sp,sp,-80
    800011e2:	e486                	sd	ra,72(sp)
    800011e4:	e0a2                	sd	s0,64(sp)
    800011e6:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800011e8:	03459793          	slli	a5,a1,0x34
    800011ec:	e39d                	bnez	a5,80001212 <uvmunmap+0x32>
    800011ee:	f84a                	sd	s2,48(sp)
    800011f0:	f44e                	sd	s3,40(sp)
    800011f2:	f052                	sd	s4,32(sp)
    800011f4:	ec56                	sd	s5,24(sp)
    800011f6:	e85a                	sd	s6,16(sp)
    800011f8:	e45e                	sd	s7,8(sp)
    800011fa:	8a2a                	mv	s4,a0
    800011fc:	892e                	mv	s2,a1
    800011fe:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001200:	0632                	slli	a2,a2,0xc
    80001202:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001206:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001208:	6b05                	lui	s6,0x1
    8000120a:	0735ff63          	bgeu	a1,s3,80001288 <uvmunmap+0xa8>
    8000120e:	fc26                	sd	s1,56(sp)
    80001210:	a0a9                	j	8000125a <uvmunmap+0x7a>
    80001212:	fc26                	sd	s1,56(sp)
    80001214:	f84a                	sd	s2,48(sp)
    80001216:	f44e                	sd	s3,40(sp)
    80001218:	f052                	sd	s4,32(sp)
    8000121a:	ec56                	sd	s5,24(sp)
    8000121c:	e85a                	sd	s6,16(sp)
    8000121e:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    80001220:	00006517          	auipc	a0,0x6
    80001224:	f0050513          	addi	a0,a0,-256 # 80007120 <etext+0x120>
    80001228:	d76ff0ef          	jal	8000079e <panic>
      panic("uvmunmap: walk");
    8000122c:	00006517          	auipc	a0,0x6
    80001230:	f0c50513          	addi	a0,a0,-244 # 80007138 <etext+0x138>
    80001234:	d6aff0ef          	jal	8000079e <panic>
      panic("uvmunmap: not mapped");
    80001238:	00006517          	auipc	a0,0x6
    8000123c:	f1050513          	addi	a0,a0,-240 # 80007148 <etext+0x148>
    80001240:	d5eff0ef          	jal	8000079e <panic>
      panic("uvmunmap: not a leaf");
    80001244:	00006517          	auipc	a0,0x6
    80001248:	f1c50513          	addi	a0,a0,-228 # 80007160 <etext+0x160>
    8000124c:	d52ff0ef          	jal	8000079e <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    80001250:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001254:	995a                	add	s2,s2,s6
    80001256:	03397863          	bgeu	s2,s3,80001286 <uvmunmap+0xa6>
    if((pte = walk(pagetable, a, 0)) == 0)
    8000125a:	4601                	li	a2,0
    8000125c:	85ca                	mv	a1,s2
    8000125e:	8552                	mv	a0,s4
    80001260:	d03ff0ef          	jal	80000f62 <walk>
    80001264:	84aa                	mv	s1,a0
    80001266:	d179                	beqz	a0,8000122c <uvmunmap+0x4c>
    if((*pte & PTE_V) == 0)
    80001268:	6108                	ld	a0,0(a0)
    8000126a:	00157793          	andi	a5,a0,1
    8000126e:	d7e9                	beqz	a5,80001238 <uvmunmap+0x58>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001270:	3ff57793          	andi	a5,a0,1023
    80001274:	fd7788e3          	beq	a5,s7,80001244 <uvmunmap+0x64>
    if(do_free){
    80001278:	fc0a8ce3          	beqz	s5,80001250 <uvmunmap+0x70>
      uint64 pa = PTE2PA(*pte);
    8000127c:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000127e:	0532                	slli	a0,a0,0xc
    80001280:	fc8ff0ef          	jal	80000a48 <kfree>
    80001284:	b7f1                	j	80001250 <uvmunmap+0x70>
    80001286:	74e2                	ld	s1,56(sp)
    80001288:	7942                	ld	s2,48(sp)
    8000128a:	79a2                	ld	s3,40(sp)
    8000128c:	7a02                	ld	s4,32(sp)
    8000128e:	6ae2                	ld	s5,24(sp)
    80001290:	6b42                	ld	s6,16(sp)
    80001292:	6ba2                	ld	s7,8(sp)
  }
}
    80001294:	60a6                	ld	ra,72(sp)
    80001296:	6406                	ld	s0,64(sp)
    80001298:	6161                	addi	sp,sp,80
    8000129a:	8082                	ret

000000008000129c <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000129c:	1101                	addi	sp,sp,-32
    8000129e:	ec06                	sd	ra,24(sp)
    800012a0:	e822                	sd	s0,16(sp)
    800012a2:	e426                	sd	s1,8(sp)
    800012a4:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800012a6:	885ff0ef          	jal	80000b2a <kalloc>
    800012aa:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800012ac:	c509                	beqz	a0,800012b6 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800012ae:	6605                	lui	a2,0x1
    800012b0:	4581                	li	a1,0
    800012b2:	a1dff0ef          	jal	80000cce <memset>
  return pagetable;
}
    800012b6:	8526                	mv	a0,s1
    800012b8:	60e2                	ld	ra,24(sp)
    800012ba:	6442                	ld	s0,16(sp)
    800012bc:	64a2                	ld	s1,8(sp)
    800012be:	6105                	addi	sp,sp,32
    800012c0:	8082                	ret

00000000800012c2 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    800012c2:	7179                	addi	sp,sp,-48
    800012c4:	f406                	sd	ra,40(sp)
    800012c6:	f022                	sd	s0,32(sp)
    800012c8:	ec26                	sd	s1,24(sp)
    800012ca:	e84a                	sd	s2,16(sp)
    800012cc:	e44e                	sd	s3,8(sp)
    800012ce:	e052                	sd	s4,0(sp)
    800012d0:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800012d2:	6785                	lui	a5,0x1
    800012d4:	04f67063          	bgeu	a2,a5,80001314 <uvmfirst+0x52>
    800012d8:	8a2a                	mv	s4,a0
    800012da:	89ae                	mv	s3,a1
    800012dc:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800012de:	84dff0ef          	jal	80000b2a <kalloc>
    800012e2:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800012e4:	6605                	lui	a2,0x1
    800012e6:	4581                	li	a1,0
    800012e8:	9e7ff0ef          	jal	80000cce <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800012ec:	4779                	li	a4,30
    800012ee:	86ca                	mv	a3,s2
    800012f0:	6605                	lui	a2,0x1
    800012f2:	4581                	li	a1,0
    800012f4:	8552                	mv	a0,s4
    800012f6:	d45ff0ef          	jal	8000103a <mappages>
  memmove(mem, src, sz);
    800012fa:	8626                	mv	a2,s1
    800012fc:	85ce                	mv	a1,s3
    800012fe:	854a                	mv	a0,s2
    80001300:	a33ff0ef          	jal	80000d32 <memmove>
}
    80001304:	70a2                	ld	ra,40(sp)
    80001306:	7402                	ld	s0,32(sp)
    80001308:	64e2                	ld	s1,24(sp)
    8000130a:	6942                	ld	s2,16(sp)
    8000130c:	69a2                	ld	s3,8(sp)
    8000130e:	6a02                	ld	s4,0(sp)
    80001310:	6145                	addi	sp,sp,48
    80001312:	8082                	ret
    panic("uvmfirst: more than a page");
    80001314:	00006517          	auipc	a0,0x6
    80001318:	e6450513          	addi	a0,a0,-412 # 80007178 <etext+0x178>
    8000131c:	c82ff0ef          	jal	8000079e <panic>

0000000080001320 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001320:	1101                	addi	sp,sp,-32
    80001322:	ec06                	sd	ra,24(sp)
    80001324:	e822                	sd	s0,16(sp)
    80001326:	e426                	sd	s1,8(sp)
    80001328:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000132a:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000132c:	00b67d63          	bgeu	a2,a1,80001346 <uvmdealloc+0x26>
    80001330:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001332:	6785                	lui	a5,0x1
    80001334:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001336:	00f60733          	add	a4,a2,a5
    8000133a:	76fd                	lui	a3,0xfffff
    8000133c:	8f75                	and	a4,a4,a3
    8000133e:	97ae                	add	a5,a5,a1
    80001340:	8ff5                	and	a5,a5,a3
    80001342:	00f76863          	bltu	a4,a5,80001352 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001346:	8526                	mv	a0,s1
    80001348:	60e2                	ld	ra,24(sp)
    8000134a:	6442                	ld	s0,16(sp)
    8000134c:	64a2                	ld	s1,8(sp)
    8000134e:	6105                	addi	sp,sp,32
    80001350:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001352:	8f99                	sub	a5,a5,a4
    80001354:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001356:	4685                	li	a3,1
    80001358:	0007861b          	sext.w	a2,a5
    8000135c:	85ba                	mv	a1,a4
    8000135e:	e83ff0ef          	jal	800011e0 <uvmunmap>
    80001362:	b7d5                	j	80001346 <uvmdealloc+0x26>

0000000080001364 <uvmalloc>:
  if(newsz < oldsz)
    80001364:	0ab66363          	bltu	a2,a1,8000140a <uvmalloc+0xa6>
{
    80001368:	715d                	addi	sp,sp,-80
    8000136a:	e486                	sd	ra,72(sp)
    8000136c:	e0a2                	sd	s0,64(sp)
    8000136e:	f052                	sd	s4,32(sp)
    80001370:	ec56                	sd	s5,24(sp)
    80001372:	e85a                	sd	s6,16(sp)
    80001374:	0880                	addi	s0,sp,80
    80001376:	8b2a                	mv	s6,a0
    80001378:	8ab2                	mv	s5,a2
  oldsz = PGROUNDUP(oldsz);
    8000137a:	6785                	lui	a5,0x1
    8000137c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000137e:	95be                	add	a1,a1,a5
    80001380:	77fd                	lui	a5,0xfffff
    80001382:	00f5fa33          	and	s4,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001386:	08ca7463          	bgeu	s4,a2,8000140e <uvmalloc+0xaa>
    8000138a:	fc26                	sd	s1,56(sp)
    8000138c:	f84a                	sd	s2,48(sp)
    8000138e:	f44e                	sd	s3,40(sp)
    80001390:	e45e                	sd	s7,8(sp)
    80001392:	8952                	mv	s2,s4
    memset(mem, 0, PGSIZE);
    80001394:	6985                	lui	s3,0x1
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001396:	0126eb93          	ori	s7,a3,18
    mem = kalloc();
    8000139a:	f90ff0ef          	jal	80000b2a <kalloc>
    8000139e:	84aa                	mv	s1,a0
    if(mem == 0){
    800013a0:	c515                	beqz	a0,800013cc <uvmalloc+0x68>
    memset(mem, 0, PGSIZE);
    800013a2:	864e                	mv	a2,s3
    800013a4:	4581                	li	a1,0
    800013a6:	929ff0ef          	jal	80000cce <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800013aa:	875e                	mv	a4,s7
    800013ac:	86a6                	mv	a3,s1
    800013ae:	864e                	mv	a2,s3
    800013b0:	85ca                	mv	a1,s2
    800013b2:	855a                	mv	a0,s6
    800013b4:	c87ff0ef          	jal	8000103a <mappages>
    800013b8:	e91d                	bnez	a0,800013ee <uvmalloc+0x8a>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800013ba:	994e                	add	s2,s2,s3
    800013bc:	fd596fe3          	bltu	s2,s5,8000139a <uvmalloc+0x36>
  return newsz;
    800013c0:	8556                	mv	a0,s5
    800013c2:	74e2                	ld	s1,56(sp)
    800013c4:	7942                	ld	s2,48(sp)
    800013c6:	79a2                	ld	s3,40(sp)
    800013c8:	6ba2                	ld	s7,8(sp)
    800013ca:	a819                	j	800013e0 <uvmalloc+0x7c>
      uvmdealloc(pagetable, a, oldsz);
    800013cc:	8652                	mv	a2,s4
    800013ce:	85ca                	mv	a1,s2
    800013d0:	855a                	mv	a0,s6
    800013d2:	f4fff0ef          	jal	80001320 <uvmdealloc>
      return 0;
    800013d6:	4501                	li	a0,0
    800013d8:	74e2                	ld	s1,56(sp)
    800013da:	7942                	ld	s2,48(sp)
    800013dc:	79a2                	ld	s3,40(sp)
    800013de:	6ba2                	ld	s7,8(sp)
}
    800013e0:	60a6                	ld	ra,72(sp)
    800013e2:	6406                	ld	s0,64(sp)
    800013e4:	7a02                	ld	s4,32(sp)
    800013e6:	6ae2                	ld	s5,24(sp)
    800013e8:	6b42                	ld	s6,16(sp)
    800013ea:	6161                	addi	sp,sp,80
    800013ec:	8082                	ret
      kfree(mem);
    800013ee:	8526                	mv	a0,s1
    800013f0:	e58ff0ef          	jal	80000a48 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800013f4:	8652                	mv	a2,s4
    800013f6:	85ca                	mv	a1,s2
    800013f8:	855a                	mv	a0,s6
    800013fa:	f27ff0ef          	jal	80001320 <uvmdealloc>
      return 0;
    800013fe:	4501                	li	a0,0
    80001400:	74e2                	ld	s1,56(sp)
    80001402:	7942                	ld	s2,48(sp)
    80001404:	79a2                	ld	s3,40(sp)
    80001406:	6ba2                	ld	s7,8(sp)
    80001408:	bfe1                	j	800013e0 <uvmalloc+0x7c>
    return oldsz;
    8000140a:	852e                	mv	a0,a1
}
    8000140c:	8082                	ret
  return newsz;
    8000140e:	8532                	mv	a0,a2
    80001410:	bfc1                	j	800013e0 <uvmalloc+0x7c>

0000000080001412 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001412:	7179                	addi	sp,sp,-48
    80001414:	f406                	sd	ra,40(sp)
    80001416:	f022                	sd	s0,32(sp)
    80001418:	ec26                	sd	s1,24(sp)
    8000141a:	e84a                	sd	s2,16(sp)
    8000141c:	e44e                	sd	s3,8(sp)
    8000141e:	e052                	sd	s4,0(sp)
    80001420:	1800                	addi	s0,sp,48
    80001422:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001424:	84aa                	mv	s1,a0
    80001426:	6905                	lui	s2,0x1
    80001428:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000142a:	4985                	li	s3,1
    8000142c:	a819                	j	80001442 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000142e:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001430:	00c79513          	slli	a0,a5,0xc
    80001434:	fdfff0ef          	jal	80001412 <freewalk>
      pagetable[i] = 0;
    80001438:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000143c:	04a1                	addi	s1,s1,8
    8000143e:	01248f63          	beq	s1,s2,8000145c <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80001442:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001444:	00f7f713          	andi	a4,a5,15
    80001448:	ff3703e3          	beq	a4,s3,8000142e <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000144c:	8b85                	andi	a5,a5,1
    8000144e:	d7fd                	beqz	a5,8000143c <freewalk+0x2a>
      panic("freewalk: leaf");
    80001450:	00006517          	auipc	a0,0x6
    80001454:	d4850513          	addi	a0,a0,-696 # 80007198 <etext+0x198>
    80001458:	b46ff0ef          	jal	8000079e <panic>
    }
  }
  kfree((void*)pagetable);
    8000145c:	8552                	mv	a0,s4
    8000145e:	deaff0ef          	jal	80000a48 <kfree>
}
    80001462:	70a2                	ld	ra,40(sp)
    80001464:	7402                	ld	s0,32(sp)
    80001466:	64e2                	ld	s1,24(sp)
    80001468:	6942                	ld	s2,16(sp)
    8000146a:	69a2                	ld	s3,8(sp)
    8000146c:	6a02                	ld	s4,0(sp)
    8000146e:	6145                	addi	sp,sp,48
    80001470:	8082                	ret

0000000080001472 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001472:	1101                	addi	sp,sp,-32
    80001474:	ec06                	sd	ra,24(sp)
    80001476:	e822                	sd	s0,16(sp)
    80001478:	e426                	sd	s1,8(sp)
    8000147a:	1000                	addi	s0,sp,32
    8000147c:	84aa                	mv	s1,a0
  if(sz > 0)
    8000147e:	e989                	bnez	a1,80001490 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001480:	8526                	mv	a0,s1
    80001482:	f91ff0ef          	jal	80001412 <freewalk>
}
    80001486:	60e2                	ld	ra,24(sp)
    80001488:	6442                	ld	s0,16(sp)
    8000148a:	64a2                	ld	s1,8(sp)
    8000148c:	6105                	addi	sp,sp,32
    8000148e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001490:	6785                	lui	a5,0x1
    80001492:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001494:	95be                	add	a1,a1,a5
    80001496:	4685                	li	a3,1
    80001498:	00c5d613          	srli	a2,a1,0xc
    8000149c:	4581                	li	a1,0
    8000149e:	d43ff0ef          	jal	800011e0 <uvmunmap>
    800014a2:	bff9                	j	80001480 <uvmfree+0xe>

00000000800014a4 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800014a4:	ca4d                	beqz	a2,80001556 <uvmcopy+0xb2>
{
    800014a6:	715d                	addi	sp,sp,-80
    800014a8:	e486                	sd	ra,72(sp)
    800014aa:	e0a2                	sd	s0,64(sp)
    800014ac:	fc26                	sd	s1,56(sp)
    800014ae:	f84a                	sd	s2,48(sp)
    800014b0:	f44e                	sd	s3,40(sp)
    800014b2:	f052                	sd	s4,32(sp)
    800014b4:	ec56                	sd	s5,24(sp)
    800014b6:	e85a                	sd	s6,16(sp)
    800014b8:	e45e                	sd	s7,8(sp)
    800014ba:	e062                	sd	s8,0(sp)
    800014bc:	0880                	addi	s0,sp,80
    800014be:	8baa                	mv	s7,a0
    800014c0:	8b2e                	mv	s6,a1
    800014c2:	8ab2                	mv	s5,a2
  for(i = 0; i < sz; i += PGSIZE){
    800014c4:	4981                	li	s3,0
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800014c6:	6a05                	lui	s4,0x1
    if((pte = walk(old, i, 0)) == 0)
    800014c8:	4601                	li	a2,0
    800014ca:	85ce                	mv	a1,s3
    800014cc:	855e                	mv	a0,s7
    800014ce:	a95ff0ef          	jal	80000f62 <walk>
    800014d2:	cd1d                	beqz	a0,80001510 <uvmcopy+0x6c>
    if((*pte & PTE_V) == 0)
    800014d4:	6118                	ld	a4,0(a0)
    800014d6:	00177793          	andi	a5,a4,1
    800014da:	c3a9                	beqz	a5,8000151c <uvmcopy+0x78>
    pa = PTE2PA(*pte);
    800014dc:	00a75593          	srli	a1,a4,0xa
    800014e0:	00c59c13          	slli	s8,a1,0xc
    flags = PTE_FLAGS(*pte);
    800014e4:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800014e8:	e42ff0ef          	jal	80000b2a <kalloc>
    800014ec:	892a                	mv	s2,a0
    800014ee:	c121                	beqz	a0,8000152e <uvmcopy+0x8a>
    memmove(mem, (char*)pa, PGSIZE);
    800014f0:	8652                	mv	a2,s4
    800014f2:	85e2                	mv	a1,s8
    800014f4:	83fff0ef          	jal	80000d32 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800014f8:	8726                	mv	a4,s1
    800014fa:	86ca                	mv	a3,s2
    800014fc:	8652                	mv	a2,s4
    800014fe:	85ce                	mv	a1,s3
    80001500:	855a                	mv	a0,s6
    80001502:	b39ff0ef          	jal	8000103a <mappages>
    80001506:	e10d                	bnez	a0,80001528 <uvmcopy+0x84>
  for(i = 0; i < sz; i += PGSIZE){
    80001508:	99d2                	add	s3,s3,s4
    8000150a:	fb59efe3          	bltu	s3,s5,800014c8 <uvmcopy+0x24>
    8000150e:	a805                	j	8000153e <uvmcopy+0x9a>
      panic("uvmcopy: pte should exist");
    80001510:	00006517          	auipc	a0,0x6
    80001514:	c9850513          	addi	a0,a0,-872 # 800071a8 <etext+0x1a8>
    80001518:	a86ff0ef          	jal	8000079e <panic>
      panic("uvmcopy: page not present");
    8000151c:	00006517          	auipc	a0,0x6
    80001520:	cac50513          	addi	a0,a0,-852 # 800071c8 <etext+0x1c8>
    80001524:	a7aff0ef          	jal	8000079e <panic>
      kfree(mem);
    80001528:	854a                	mv	a0,s2
    8000152a:	d1eff0ef          	jal	80000a48 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000152e:	4685                	li	a3,1
    80001530:	00c9d613          	srli	a2,s3,0xc
    80001534:	4581                	li	a1,0
    80001536:	855a                	mv	a0,s6
    80001538:	ca9ff0ef          	jal	800011e0 <uvmunmap>
  return -1;
    8000153c:	557d                	li	a0,-1
}
    8000153e:	60a6                	ld	ra,72(sp)
    80001540:	6406                	ld	s0,64(sp)
    80001542:	74e2                	ld	s1,56(sp)
    80001544:	7942                	ld	s2,48(sp)
    80001546:	79a2                	ld	s3,40(sp)
    80001548:	7a02                	ld	s4,32(sp)
    8000154a:	6ae2                	ld	s5,24(sp)
    8000154c:	6b42                	ld	s6,16(sp)
    8000154e:	6ba2                	ld	s7,8(sp)
    80001550:	6c02                	ld	s8,0(sp)
    80001552:	6161                	addi	sp,sp,80
    80001554:	8082                	ret
  return 0;
    80001556:	4501                	li	a0,0
}
    80001558:	8082                	ret

000000008000155a <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000155a:	1141                	addi	sp,sp,-16
    8000155c:	e406                	sd	ra,8(sp)
    8000155e:	e022                	sd	s0,0(sp)
    80001560:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001562:	4601                	li	a2,0
    80001564:	9ffff0ef          	jal	80000f62 <walk>
  if(pte == 0)
    80001568:	c901                	beqz	a0,80001578 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000156a:	611c                	ld	a5,0(a0)
    8000156c:	9bbd                	andi	a5,a5,-17
    8000156e:	e11c                	sd	a5,0(a0)
}
    80001570:	60a2                	ld	ra,8(sp)
    80001572:	6402                	ld	s0,0(sp)
    80001574:	0141                	addi	sp,sp,16
    80001576:	8082                	ret
    panic("uvmclear");
    80001578:	00006517          	auipc	a0,0x6
    8000157c:	c7050513          	addi	a0,a0,-912 # 800071e8 <etext+0x1e8>
    80001580:	a1eff0ef          	jal	8000079e <panic>

0000000080001584 <copyout>:
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    80001584:	c2d9                	beqz	a3,8000160a <copyout+0x86>
{
    80001586:	711d                	addi	sp,sp,-96
    80001588:	ec86                	sd	ra,88(sp)
    8000158a:	e8a2                	sd	s0,80(sp)
    8000158c:	e4a6                	sd	s1,72(sp)
    8000158e:	e0ca                	sd	s2,64(sp)
    80001590:	fc4e                	sd	s3,56(sp)
    80001592:	f852                	sd	s4,48(sp)
    80001594:	f456                	sd	s5,40(sp)
    80001596:	f05a                	sd	s6,32(sp)
    80001598:	ec5e                	sd	s7,24(sp)
    8000159a:	e862                	sd	s8,16(sp)
    8000159c:	e466                	sd	s9,8(sp)
    8000159e:	e06a                	sd	s10,0(sp)
    800015a0:	1080                	addi	s0,sp,96
    800015a2:	8c2a                	mv	s8,a0
    800015a4:	892e                	mv	s2,a1
    800015a6:	8ab2                	mv	s5,a2
    800015a8:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    800015aa:	7cfd                	lui	s9,0xfffff
    if(va0 >= MAXVA)
    800015ac:	5bfd                	li	s7,-1
    800015ae:	01abdb93          	srli	s7,s7,0x1a
      return -1;
    pte = walk(pagetable, va0, 0);
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    800015b2:	4d55                	li	s10,21
       (*pte & PTE_W) == 0)
      return -1;
    pa0 = PTE2PA(*pte);
    n = PGSIZE - (dstva - va0);
    800015b4:	6b05                	lui	s6,0x1
    800015b6:	a015                	j	800015da <copyout+0x56>
    pa0 = PTE2PA(*pte);
    800015b8:	83a9                	srli	a5,a5,0xa
    800015ba:	07b2                	slli	a5,a5,0xc
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800015bc:	41390533          	sub	a0,s2,s3
    800015c0:	0004861b          	sext.w	a2,s1
    800015c4:	85d6                	mv	a1,s5
    800015c6:	953e                	add	a0,a0,a5
    800015c8:	f6aff0ef          	jal	80000d32 <memmove>

    len -= n;
    800015cc:	409a0a33          	sub	s4,s4,s1
    src += n;
    800015d0:	9aa6                	add	s5,s5,s1
    dstva = va0 + PGSIZE;
    800015d2:	01698933          	add	s2,s3,s6
  while(len > 0){
    800015d6:	020a0863          	beqz	s4,80001606 <copyout+0x82>
    va0 = PGROUNDDOWN(dstva);
    800015da:	019979b3          	and	s3,s2,s9
    if(va0 >= MAXVA)
    800015de:	033be863          	bltu	s7,s3,8000160e <copyout+0x8a>
    pte = walk(pagetable, va0, 0);
    800015e2:	4601                	li	a2,0
    800015e4:	85ce                	mv	a1,s3
    800015e6:	8562                	mv	a0,s8
    800015e8:	97bff0ef          	jal	80000f62 <walk>
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    800015ec:	c121                	beqz	a0,8000162c <copyout+0xa8>
    800015ee:	611c                	ld	a5,0(a0)
    800015f0:	0157f713          	andi	a4,a5,21
    800015f4:	03a71e63          	bne	a4,s10,80001630 <copyout+0xac>
    n = PGSIZE - (dstva - va0);
    800015f8:	412984b3          	sub	s1,s3,s2
    800015fc:	94da                	add	s1,s1,s6
    if(n > len)
    800015fe:	fa9a7de3          	bgeu	s4,s1,800015b8 <copyout+0x34>
    80001602:	84d2                	mv	s1,s4
    80001604:	bf55                	j	800015b8 <copyout+0x34>
  }
  return 0;
    80001606:	4501                	li	a0,0
    80001608:	a021                	j	80001610 <copyout+0x8c>
    8000160a:	4501                	li	a0,0
}
    8000160c:	8082                	ret
      return -1;
    8000160e:	557d                	li	a0,-1
}
    80001610:	60e6                	ld	ra,88(sp)
    80001612:	6446                	ld	s0,80(sp)
    80001614:	64a6                	ld	s1,72(sp)
    80001616:	6906                	ld	s2,64(sp)
    80001618:	79e2                	ld	s3,56(sp)
    8000161a:	7a42                	ld	s4,48(sp)
    8000161c:	7aa2                	ld	s5,40(sp)
    8000161e:	7b02                	ld	s6,32(sp)
    80001620:	6be2                	ld	s7,24(sp)
    80001622:	6c42                	ld	s8,16(sp)
    80001624:	6ca2                	ld	s9,8(sp)
    80001626:	6d02                	ld	s10,0(sp)
    80001628:	6125                	addi	sp,sp,96
    8000162a:	8082                	ret
      return -1;
    8000162c:	557d                	li	a0,-1
    8000162e:	b7cd                	j	80001610 <copyout+0x8c>
    80001630:	557d                	li	a0,-1
    80001632:	bff9                	j	80001610 <copyout+0x8c>

0000000080001634 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001634:	c6a5                	beqz	a3,8000169c <copyin+0x68>
{
    80001636:	715d                	addi	sp,sp,-80
    80001638:	e486                	sd	ra,72(sp)
    8000163a:	e0a2                	sd	s0,64(sp)
    8000163c:	fc26                	sd	s1,56(sp)
    8000163e:	f84a                	sd	s2,48(sp)
    80001640:	f44e                	sd	s3,40(sp)
    80001642:	f052                	sd	s4,32(sp)
    80001644:	ec56                	sd	s5,24(sp)
    80001646:	e85a                	sd	s6,16(sp)
    80001648:	e45e                	sd	s7,8(sp)
    8000164a:	e062                	sd	s8,0(sp)
    8000164c:	0880                	addi	s0,sp,80
    8000164e:	8b2a                	mv	s6,a0
    80001650:	8a2e                	mv	s4,a1
    80001652:	8c32                	mv	s8,a2
    80001654:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001656:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001658:	6a85                	lui	s5,0x1
    8000165a:	a00d                	j	8000167c <copyin+0x48>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000165c:	018505b3          	add	a1,a0,s8
    80001660:	0004861b          	sext.w	a2,s1
    80001664:	412585b3          	sub	a1,a1,s2
    80001668:	8552                	mv	a0,s4
    8000166a:	ec8ff0ef          	jal	80000d32 <memmove>

    len -= n;
    8000166e:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001672:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001674:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001678:	02098063          	beqz	s3,80001698 <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    8000167c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001680:	85ca                	mv	a1,s2
    80001682:	855a                	mv	a0,s6
    80001684:	979ff0ef          	jal	80000ffc <walkaddr>
    if(pa0 == 0)
    80001688:	cd01                	beqz	a0,800016a0 <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    8000168a:	418904b3          	sub	s1,s2,s8
    8000168e:	94d6                	add	s1,s1,s5
    if(n > len)
    80001690:	fc99f6e3          	bgeu	s3,s1,8000165c <copyin+0x28>
    80001694:	84ce                	mv	s1,s3
    80001696:	b7d9                	j	8000165c <copyin+0x28>
  }
  return 0;
    80001698:	4501                	li	a0,0
    8000169a:	a021                	j	800016a2 <copyin+0x6e>
    8000169c:	4501                	li	a0,0
}
    8000169e:	8082                	ret
      return -1;
    800016a0:	557d                	li	a0,-1
}
    800016a2:	60a6                	ld	ra,72(sp)
    800016a4:	6406                	ld	s0,64(sp)
    800016a6:	74e2                	ld	s1,56(sp)
    800016a8:	7942                	ld	s2,48(sp)
    800016aa:	79a2                	ld	s3,40(sp)
    800016ac:	7a02                	ld	s4,32(sp)
    800016ae:	6ae2                	ld	s5,24(sp)
    800016b0:	6b42                	ld	s6,16(sp)
    800016b2:	6ba2                	ld	s7,8(sp)
    800016b4:	6c02                	ld	s8,0(sp)
    800016b6:	6161                	addi	sp,sp,80
    800016b8:	8082                	ret

00000000800016ba <copyinstr>:
// Copy bytes to dst from virtual address srcva in a given page table,
// until a '\0', or max.
// Return 0 on success, -1 on error.
int
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
    800016ba:	715d                	addi	sp,sp,-80
    800016bc:	e486                	sd	ra,72(sp)
    800016be:	e0a2                	sd	s0,64(sp)
    800016c0:	fc26                	sd	s1,56(sp)
    800016c2:	f84a                	sd	s2,48(sp)
    800016c4:	f44e                	sd	s3,40(sp)
    800016c6:	f052                	sd	s4,32(sp)
    800016c8:	ec56                	sd	s5,24(sp)
    800016ca:	e85a                	sd	s6,16(sp)
    800016cc:	e45e                	sd	s7,8(sp)
    800016ce:	0880                	addi	s0,sp,80
    800016d0:	8aaa                	mv	s5,a0
    800016d2:	89ae                	mv	s3,a1
    800016d4:	8bb2                	mv	s7,a2
    800016d6:	84b6                	mv	s1,a3
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    va0 = PGROUNDDOWN(srcva);
    800016d8:	7b7d                	lui	s6,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800016da:	6a05                	lui	s4,0x1
    800016dc:	a02d                	j	80001706 <copyinstr+0x4c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800016de:	00078023          	sb	zero,0(a5)
    800016e2:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800016e4:	0017c793          	xori	a5,a5,1
    800016e8:	40f0053b          	negw	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800016ec:	60a6                	ld	ra,72(sp)
    800016ee:	6406                	ld	s0,64(sp)
    800016f0:	74e2                	ld	s1,56(sp)
    800016f2:	7942                	ld	s2,48(sp)
    800016f4:	79a2                	ld	s3,40(sp)
    800016f6:	7a02                	ld	s4,32(sp)
    800016f8:	6ae2                	ld	s5,24(sp)
    800016fa:	6b42                	ld	s6,16(sp)
    800016fc:	6ba2                	ld	s7,8(sp)
    800016fe:	6161                	addi	sp,sp,80
    80001700:	8082                	ret
    srcva = va0 + PGSIZE;
    80001702:	01490bb3          	add	s7,s2,s4
  while(got_null == 0 && max > 0){
    80001706:	c4b1                	beqz	s1,80001752 <copyinstr+0x98>
    va0 = PGROUNDDOWN(srcva);
    80001708:	016bf933          	and	s2,s7,s6
    pa0 = walkaddr(pagetable, va0);
    8000170c:	85ca                	mv	a1,s2
    8000170e:	8556                	mv	a0,s5
    80001710:	8edff0ef          	jal	80000ffc <walkaddr>
    if(pa0 == 0)
    80001714:	c129                	beqz	a0,80001756 <copyinstr+0x9c>
    n = PGSIZE - (srcva - va0);
    80001716:	41790633          	sub	a2,s2,s7
    8000171a:	9652                	add	a2,a2,s4
    if(n > max)
    8000171c:	00c4f363          	bgeu	s1,a2,80001722 <copyinstr+0x68>
    80001720:	8626                	mv	a2,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001722:	412b8bb3          	sub	s7,s7,s2
    80001726:	9baa                	add	s7,s7,a0
    while(n > 0){
    80001728:	de69                	beqz	a2,80001702 <copyinstr+0x48>
    8000172a:	87ce                	mv	a5,s3
      if(*p == '\0'){
    8000172c:	413b86b3          	sub	a3,s7,s3
    while(n > 0){
    80001730:	964e                	add	a2,a2,s3
    80001732:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001734:	00f68733          	add	a4,a3,a5
    80001738:	00074703          	lbu	a4,0(a4)
    8000173c:	d34d                	beqz	a4,800016de <copyinstr+0x24>
        *dst = *p;
    8000173e:	00e78023          	sb	a4,0(a5)
      dst++;
    80001742:	0785                	addi	a5,a5,1
    while(n > 0){
    80001744:	fec797e3          	bne	a5,a2,80001732 <copyinstr+0x78>
    80001748:	14fd                	addi	s1,s1,-1
    8000174a:	94ce                	add	s1,s1,s3
      --max;
    8000174c:	8c8d                	sub	s1,s1,a1
    8000174e:	89be                	mv	s3,a5
    80001750:	bf4d                	j	80001702 <copyinstr+0x48>
    80001752:	4781                	li	a5,0
    80001754:	bf41                	j	800016e4 <copyinstr+0x2a>
      return -1;
    80001756:	557d                	li	a0,-1
    80001758:	bf51                	j	800016ec <copyinstr+0x32>

000000008000175a <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    8000175a:	715d                	addi	sp,sp,-80
    8000175c:	e486                	sd	ra,72(sp)
    8000175e:	e0a2                	sd	s0,64(sp)
    80001760:	fc26                	sd	s1,56(sp)
    80001762:	f84a                	sd	s2,48(sp)
    80001764:	f44e                	sd	s3,40(sp)
    80001766:	f052                	sd	s4,32(sp)
    80001768:	ec56                	sd	s5,24(sp)
    8000176a:	e85a                	sd	s6,16(sp)
    8000176c:	e45e                	sd	s7,8(sp)
    8000176e:	e062                	sd	s8,0(sp)
    80001770:	0880                	addi	s0,sp,80
    80001772:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001774:	00011497          	auipc	s1,0x11
    80001778:	0ec48493          	addi	s1,s1,236 # 80012860 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000177c:	8c26                	mv	s8,s1
    8000177e:	a4fa57b7          	lui	a5,0xa4fa5
    80001782:	fa578793          	addi	a5,a5,-91 # ffffffffa4fa4fa5 <end+0xffffffff24f81965>
    80001786:	4fa50937          	lui	s2,0x4fa50
    8000178a:	a5090913          	addi	s2,s2,-1456 # 4fa4fa50 <_entry-0x305b05b0>
    8000178e:	1902                	slli	s2,s2,0x20
    80001790:	993e                	add	s2,s2,a5
    80001792:	040009b7          	lui	s3,0x4000
    80001796:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001798:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000179a:	4b99                	li	s7,6
    8000179c:	6b05                	lui	s6,0x1
  for(p = proc; p < &proc[NPROC]; p++) {
    8000179e:	00017a97          	auipc	s5,0x17
    800017a2:	ac2a8a93          	addi	s5,s5,-1342 # 80018260 <tickslock>
    char *pa = kalloc();
    800017a6:	b84ff0ef          	jal	80000b2a <kalloc>
    800017aa:	862a                	mv	a2,a0
    if(pa == 0)
    800017ac:	c121                	beqz	a0,800017ec <proc_mapstacks+0x92>
    uint64 va = KSTACK((int) (p - proc));
    800017ae:	418485b3          	sub	a1,s1,s8
    800017b2:	858d                	srai	a1,a1,0x3
    800017b4:	032585b3          	mul	a1,a1,s2
    800017b8:	2585                	addiw	a1,a1,1
    800017ba:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017be:	875e                	mv	a4,s7
    800017c0:	86da                	mv	a3,s6
    800017c2:	40b985b3          	sub	a1,s3,a1
    800017c6:	8552                	mv	a0,s4
    800017c8:	929ff0ef          	jal	800010f0 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800017cc:	16848493          	addi	s1,s1,360
    800017d0:	fd549be3          	bne	s1,s5,800017a6 <proc_mapstacks+0x4c>
  }
}
    800017d4:	60a6                	ld	ra,72(sp)
    800017d6:	6406                	ld	s0,64(sp)
    800017d8:	74e2                	ld	s1,56(sp)
    800017da:	7942                	ld	s2,48(sp)
    800017dc:	79a2                	ld	s3,40(sp)
    800017de:	7a02                	ld	s4,32(sp)
    800017e0:	6ae2                	ld	s5,24(sp)
    800017e2:	6b42                	ld	s6,16(sp)
    800017e4:	6ba2                	ld	s7,8(sp)
    800017e6:	6c02                	ld	s8,0(sp)
    800017e8:	6161                	addi	sp,sp,80
    800017ea:	8082                	ret
      panic("kalloc");
    800017ec:	00006517          	auipc	a0,0x6
    800017f0:	a0c50513          	addi	a0,a0,-1524 # 800071f8 <etext+0x1f8>
    800017f4:	fabfe0ef          	jal	8000079e <panic>

00000000800017f8 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800017f8:	7139                	addi	sp,sp,-64
    800017fa:	fc06                	sd	ra,56(sp)
    800017fc:	f822                	sd	s0,48(sp)
    800017fe:	f426                	sd	s1,40(sp)
    80001800:	f04a                	sd	s2,32(sp)
    80001802:	ec4e                	sd	s3,24(sp)
    80001804:	e852                	sd	s4,16(sp)
    80001806:	e456                	sd	s5,8(sp)
    80001808:	e05a                	sd	s6,0(sp)
    8000180a:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    8000180c:	00006597          	auipc	a1,0x6
    80001810:	9f458593          	addi	a1,a1,-1548 # 80007200 <etext+0x200>
    80001814:	00011517          	auipc	a0,0x11
    80001818:	c1c50513          	addi	a0,a0,-996 # 80012430 <pid_lock>
    8000181c:	b5eff0ef          	jal	80000b7a <initlock>
  initlock(&wait_lock, "wait_lock");
    80001820:	00006597          	auipc	a1,0x6
    80001824:	9e858593          	addi	a1,a1,-1560 # 80007208 <etext+0x208>
    80001828:	00011517          	auipc	a0,0x11
    8000182c:	c2050513          	addi	a0,a0,-992 # 80012448 <wait_lock>
    80001830:	b4aff0ef          	jal	80000b7a <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001834:	00011497          	auipc	s1,0x11
    80001838:	02c48493          	addi	s1,s1,44 # 80012860 <proc>
      initlock(&p->lock, "proc");
    8000183c:	00006b17          	auipc	s6,0x6
    80001840:	9dcb0b13          	addi	s6,s6,-1572 # 80007218 <etext+0x218>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001844:	8aa6                	mv	s5,s1
    80001846:	a4fa57b7          	lui	a5,0xa4fa5
    8000184a:	fa578793          	addi	a5,a5,-91 # ffffffffa4fa4fa5 <end+0xffffffff24f81965>
    8000184e:	4fa50937          	lui	s2,0x4fa50
    80001852:	a5090913          	addi	s2,s2,-1456 # 4fa4fa50 <_entry-0x305b05b0>
    80001856:	1902                	slli	s2,s2,0x20
    80001858:	993e                	add	s2,s2,a5
    8000185a:	040009b7          	lui	s3,0x4000
    8000185e:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001860:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001862:	00017a17          	auipc	s4,0x17
    80001866:	9fea0a13          	addi	s4,s4,-1538 # 80018260 <tickslock>
      initlock(&p->lock, "proc");
    8000186a:	85da                	mv	a1,s6
    8000186c:	8526                	mv	a0,s1
    8000186e:	b0cff0ef          	jal	80000b7a <initlock>
      p->state = UNUSED;
    80001872:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001876:	415487b3          	sub	a5,s1,s5
    8000187a:	878d                	srai	a5,a5,0x3
    8000187c:	032787b3          	mul	a5,a5,s2
    80001880:	2785                	addiw	a5,a5,1
    80001882:	00d7979b          	slliw	a5,a5,0xd
    80001886:	40f987b3          	sub	a5,s3,a5
    8000188a:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000188c:	16848493          	addi	s1,s1,360
    80001890:	fd449de3          	bne	s1,s4,8000186a <procinit+0x72>
  }
}
    80001894:	70e2                	ld	ra,56(sp)
    80001896:	7442                	ld	s0,48(sp)
    80001898:	74a2                	ld	s1,40(sp)
    8000189a:	7902                	ld	s2,32(sp)
    8000189c:	69e2                	ld	s3,24(sp)
    8000189e:	6a42                	ld	s4,16(sp)
    800018a0:	6aa2                	ld	s5,8(sp)
    800018a2:	6b02                	ld	s6,0(sp)
    800018a4:	6121                	addi	sp,sp,64
    800018a6:	8082                	ret

00000000800018a8 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018a8:	1141                	addi	sp,sp,-16
    800018aa:	e406                	sd	ra,8(sp)
    800018ac:	e022                	sd	s0,0(sp)
    800018ae:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800018b0:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018b2:	2501                	sext.w	a0,a0
    800018b4:	60a2                	ld	ra,8(sp)
    800018b6:	6402                	ld	s0,0(sp)
    800018b8:	0141                	addi	sp,sp,16
    800018ba:	8082                	ret

00000000800018bc <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800018bc:	1141                	addi	sp,sp,-16
    800018be:	e406                	sd	ra,8(sp)
    800018c0:	e022                	sd	s0,0(sp)
    800018c2:	0800                	addi	s0,sp,16
    800018c4:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800018c6:	2781                	sext.w	a5,a5
    800018c8:	079e                	slli	a5,a5,0x7
  return c;
}
    800018ca:	00011517          	auipc	a0,0x11
    800018ce:	b9650513          	addi	a0,a0,-1130 # 80012460 <cpus>
    800018d2:	953e                	add	a0,a0,a5
    800018d4:	60a2                	ld	ra,8(sp)
    800018d6:	6402                	ld	s0,0(sp)
    800018d8:	0141                	addi	sp,sp,16
    800018da:	8082                	ret

00000000800018dc <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800018dc:	1101                	addi	sp,sp,-32
    800018de:	ec06                	sd	ra,24(sp)
    800018e0:	e822                	sd	s0,16(sp)
    800018e2:	e426                	sd	s1,8(sp)
    800018e4:	1000                	addi	s0,sp,32
  push_off();
    800018e6:	ad8ff0ef          	jal	80000bbe <push_off>
    800018ea:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800018ec:	2781                	sext.w	a5,a5
    800018ee:	079e                	slli	a5,a5,0x7
    800018f0:	00011717          	auipc	a4,0x11
    800018f4:	b4070713          	addi	a4,a4,-1216 # 80012430 <pid_lock>
    800018f8:	97ba                	add	a5,a5,a4
    800018fa:	7b84                	ld	s1,48(a5)
  pop_off();
    800018fc:	b46ff0ef          	jal	80000c42 <pop_off>
  return p;
}
    80001900:	8526                	mv	a0,s1
    80001902:	60e2                	ld	ra,24(sp)
    80001904:	6442                	ld	s0,16(sp)
    80001906:	64a2                	ld	s1,8(sp)
    80001908:	6105                	addi	sp,sp,32
    8000190a:	8082                	ret

000000008000190c <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    8000190c:	1141                	addi	sp,sp,-16
    8000190e:	e406                	sd	ra,8(sp)
    80001910:	e022                	sd	s0,0(sp)
    80001912:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001914:	fc9ff0ef          	jal	800018dc <myproc>
    80001918:	b7aff0ef          	jal	80000c92 <release>

  if (first) {
    8000191c:	00009797          	auipc	a5,0x9
    80001920:	9447a783          	lw	a5,-1724(a5) # 8000a260 <first.1>
    80001924:	e799                	bnez	a5,80001932 <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    80001926:	2bd000ef          	jal	800023e2 <usertrapret>
}
    8000192a:	60a2                	ld	ra,8(sp)
    8000192c:	6402                	ld	s0,0(sp)
    8000192e:	0141                	addi	sp,sp,16
    80001930:	8082                	ret
    fsinit(ROOTDEV);
    80001932:	4505                	li	a0,1
    80001934:	6d8010ef          	jal	8000300c <fsinit>
    first = 0;
    80001938:	00009797          	auipc	a5,0x9
    8000193c:	9207a423          	sw	zero,-1752(a5) # 8000a260 <first.1>
    __sync_synchronize();
    80001940:	0330000f          	fence	rw,rw
    80001944:	b7cd                	j	80001926 <forkret+0x1a>

0000000080001946 <allocpid>:
{
    80001946:	1101                	addi	sp,sp,-32
    80001948:	ec06                	sd	ra,24(sp)
    8000194a:	e822                	sd	s0,16(sp)
    8000194c:	e426                	sd	s1,8(sp)
    8000194e:	e04a                	sd	s2,0(sp)
    80001950:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001952:	00011917          	auipc	s2,0x11
    80001956:	ade90913          	addi	s2,s2,-1314 # 80012430 <pid_lock>
    8000195a:	854a                	mv	a0,s2
    8000195c:	aa2ff0ef          	jal	80000bfe <acquire>
  pid = nextpid;
    80001960:	00009797          	auipc	a5,0x9
    80001964:	90478793          	addi	a5,a5,-1788 # 8000a264 <nextpid>
    80001968:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    8000196a:	0014871b          	addiw	a4,s1,1
    8000196e:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001970:	854a                	mv	a0,s2
    80001972:	b20ff0ef          	jal	80000c92 <release>
}
    80001976:	8526                	mv	a0,s1
    80001978:	60e2                	ld	ra,24(sp)
    8000197a:	6442                	ld	s0,16(sp)
    8000197c:	64a2                	ld	s1,8(sp)
    8000197e:	6902                	ld	s2,0(sp)
    80001980:	6105                	addi	sp,sp,32
    80001982:	8082                	ret

0000000080001984 <proc_pagetable>:
{
    80001984:	1101                	addi	sp,sp,-32
    80001986:	ec06                	sd	ra,24(sp)
    80001988:	e822                	sd	s0,16(sp)
    8000198a:	e426                	sd	s1,8(sp)
    8000198c:	e04a                	sd	s2,0(sp)
    8000198e:	1000                	addi	s0,sp,32
    80001990:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001992:	90bff0ef          	jal	8000129c <uvmcreate>
    80001996:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001998:	cd05                	beqz	a0,800019d0 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    8000199a:	4729                	li	a4,10
    8000199c:	00004697          	auipc	a3,0x4
    800019a0:	66468693          	addi	a3,a3,1636 # 80006000 <_trampoline>
    800019a4:	6605                	lui	a2,0x1
    800019a6:	040005b7          	lui	a1,0x4000
    800019aa:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019ac:	05b2                	slli	a1,a1,0xc
    800019ae:	e8cff0ef          	jal	8000103a <mappages>
    800019b2:	02054663          	bltz	a0,800019de <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    800019b6:	4719                	li	a4,6
    800019b8:	05893683          	ld	a3,88(s2)
    800019bc:	6605                	lui	a2,0x1
    800019be:	020005b7          	lui	a1,0x2000
    800019c2:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800019c4:	05b6                	slli	a1,a1,0xd
    800019c6:	8526                	mv	a0,s1
    800019c8:	e72ff0ef          	jal	8000103a <mappages>
    800019cc:	00054f63          	bltz	a0,800019ea <proc_pagetable+0x66>
}
    800019d0:	8526                	mv	a0,s1
    800019d2:	60e2                	ld	ra,24(sp)
    800019d4:	6442                	ld	s0,16(sp)
    800019d6:	64a2                	ld	s1,8(sp)
    800019d8:	6902                	ld	s2,0(sp)
    800019da:	6105                	addi	sp,sp,32
    800019dc:	8082                	ret
    uvmfree(pagetable, 0);
    800019de:	4581                	li	a1,0
    800019e0:	8526                	mv	a0,s1
    800019e2:	a91ff0ef          	jal	80001472 <uvmfree>
    return 0;
    800019e6:	4481                	li	s1,0
    800019e8:	b7e5                	j	800019d0 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    800019ea:	4681                	li	a3,0
    800019ec:	4605                	li	a2,1
    800019ee:	040005b7          	lui	a1,0x4000
    800019f2:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019f4:	05b2                	slli	a1,a1,0xc
    800019f6:	8526                	mv	a0,s1
    800019f8:	fe8ff0ef          	jal	800011e0 <uvmunmap>
    uvmfree(pagetable, 0);
    800019fc:	4581                	li	a1,0
    800019fe:	8526                	mv	a0,s1
    80001a00:	a73ff0ef          	jal	80001472 <uvmfree>
    return 0;
    80001a04:	4481                	li	s1,0
    80001a06:	b7e9                	j	800019d0 <proc_pagetable+0x4c>

0000000080001a08 <proc_freepagetable>:
{
    80001a08:	1101                	addi	sp,sp,-32
    80001a0a:	ec06                	sd	ra,24(sp)
    80001a0c:	e822                	sd	s0,16(sp)
    80001a0e:	e426                	sd	s1,8(sp)
    80001a10:	e04a                	sd	s2,0(sp)
    80001a12:	1000                	addi	s0,sp,32
    80001a14:	84aa                	mv	s1,a0
    80001a16:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a18:	4681                	li	a3,0
    80001a1a:	4605                	li	a2,1
    80001a1c:	040005b7          	lui	a1,0x4000
    80001a20:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a22:	05b2                	slli	a1,a1,0xc
    80001a24:	fbcff0ef          	jal	800011e0 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001a28:	4681                	li	a3,0
    80001a2a:	4605                	li	a2,1
    80001a2c:	020005b7          	lui	a1,0x2000
    80001a30:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a32:	05b6                	slli	a1,a1,0xd
    80001a34:	8526                	mv	a0,s1
    80001a36:	faaff0ef          	jal	800011e0 <uvmunmap>
  uvmfree(pagetable, sz);
    80001a3a:	85ca                	mv	a1,s2
    80001a3c:	8526                	mv	a0,s1
    80001a3e:	a35ff0ef          	jal	80001472 <uvmfree>
}
    80001a42:	60e2                	ld	ra,24(sp)
    80001a44:	6442                	ld	s0,16(sp)
    80001a46:	64a2                	ld	s1,8(sp)
    80001a48:	6902                	ld	s2,0(sp)
    80001a4a:	6105                	addi	sp,sp,32
    80001a4c:	8082                	ret

0000000080001a4e <freeproc>:
{
    80001a4e:	1101                	addi	sp,sp,-32
    80001a50:	ec06                	sd	ra,24(sp)
    80001a52:	e822                	sd	s0,16(sp)
    80001a54:	e426                	sd	s1,8(sp)
    80001a56:	1000                	addi	s0,sp,32
    80001a58:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001a5a:	6d28                	ld	a0,88(a0)
    80001a5c:	c119                	beqz	a0,80001a62 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001a5e:	febfe0ef          	jal	80000a48 <kfree>
  p->trapframe = 0;
    80001a62:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001a66:	68a8                	ld	a0,80(s1)
    80001a68:	c501                	beqz	a0,80001a70 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001a6a:	64ac                	ld	a1,72(s1)
    80001a6c:	f9dff0ef          	jal	80001a08 <proc_freepagetable>
  p->pagetable = 0;
    80001a70:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001a74:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001a78:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001a7c:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001a80:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001a84:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001a88:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001a8c:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001a90:	0004ac23          	sw	zero,24(s1)
}
    80001a94:	60e2                	ld	ra,24(sp)
    80001a96:	6442                	ld	s0,16(sp)
    80001a98:	64a2                	ld	s1,8(sp)
    80001a9a:	6105                	addi	sp,sp,32
    80001a9c:	8082                	ret

0000000080001a9e <allocproc>:
{
    80001a9e:	1101                	addi	sp,sp,-32
    80001aa0:	ec06                	sd	ra,24(sp)
    80001aa2:	e822                	sd	s0,16(sp)
    80001aa4:	e426                	sd	s1,8(sp)
    80001aa6:	e04a                	sd	s2,0(sp)
    80001aa8:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001aaa:	00011497          	auipc	s1,0x11
    80001aae:	db648493          	addi	s1,s1,-586 # 80012860 <proc>
    80001ab2:	00016917          	auipc	s2,0x16
    80001ab6:	7ae90913          	addi	s2,s2,1966 # 80018260 <tickslock>
    acquire(&p->lock);
    80001aba:	8526                	mv	a0,s1
    80001abc:	942ff0ef          	jal	80000bfe <acquire>
    if(p->state == UNUSED) {
    80001ac0:	4c9c                	lw	a5,24(s1)
    80001ac2:	cb91                	beqz	a5,80001ad6 <allocproc+0x38>
      release(&p->lock);
    80001ac4:	8526                	mv	a0,s1
    80001ac6:	9ccff0ef          	jal	80000c92 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001aca:	16848493          	addi	s1,s1,360
    80001ace:	ff2496e3          	bne	s1,s2,80001aba <allocproc+0x1c>
  return 0;
    80001ad2:	4481                	li	s1,0
    80001ad4:	a089                	j	80001b16 <allocproc+0x78>
  p->pid = allocpid();
    80001ad6:	e71ff0ef          	jal	80001946 <allocpid>
    80001ada:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001adc:	4785                	li	a5,1
    80001ade:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001ae0:	84aff0ef          	jal	80000b2a <kalloc>
    80001ae4:	892a                	mv	s2,a0
    80001ae6:	eca8                	sd	a0,88(s1)
    80001ae8:	cd15                	beqz	a0,80001b24 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001aea:	8526                	mv	a0,s1
    80001aec:	e99ff0ef          	jal	80001984 <proc_pagetable>
    80001af0:	892a                	mv	s2,a0
    80001af2:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001af4:	c121                	beqz	a0,80001b34 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001af6:	07000613          	li	a2,112
    80001afa:	4581                	li	a1,0
    80001afc:	06048513          	addi	a0,s1,96
    80001b00:	9ceff0ef          	jal	80000cce <memset>
  p->context.ra = (uint64)forkret;
    80001b04:	00000797          	auipc	a5,0x0
    80001b08:	e0878793          	addi	a5,a5,-504 # 8000190c <forkret>
    80001b0c:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b0e:	60bc                	ld	a5,64(s1)
    80001b10:	6705                	lui	a4,0x1
    80001b12:	97ba                	add	a5,a5,a4
    80001b14:	f4bc                	sd	a5,104(s1)
}
    80001b16:	8526                	mv	a0,s1
    80001b18:	60e2                	ld	ra,24(sp)
    80001b1a:	6442                	ld	s0,16(sp)
    80001b1c:	64a2                	ld	s1,8(sp)
    80001b1e:	6902                	ld	s2,0(sp)
    80001b20:	6105                	addi	sp,sp,32
    80001b22:	8082                	ret
    freeproc(p);
    80001b24:	8526                	mv	a0,s1
    80001b26:	f29ff0ef          	jal	80001a4e <freeproc>
    release(&p->lock);
    80001b2a:	8526                	mv	a0,s1
    80001b2c:	966ff0ef          	jal	80000c92 <release>
    return 0;
    80001b30:	84ca                	mv	s1,s2
    80001b32:	b7d5                	j	80001b16 <allocproc+0x78>
    freeproc(p);
    80001b34:	8526                	mv	a0,s1
    80001b36:	f19ff0ef          	jal	80001a4e <freeproc>
    release(&p->lock);
    80001b3a:	8526                	mv	a0,s1
    80001b3c:	956ff0ef          	jal	80000c92 <release>
    return 0;
    80001b40:	84ca                	mv	s1,s2
    80001b42:	bfd1                	j	80001b16 <allocproc+0x78>

0000000080001b44 <userinit>:
{
    80001b44:	1101                	addi	sp,sp,-32
    80001b46:	ec06                	sd	ra,24(sp)
    80001b48:	e822                	sd	s0,16(sp)
    80001b4a:	e426                	sd	s1,8(sp)
    80001b4c:	1000                	addi	s0,sp,32
  p = allocproc();
    80001b4e:	f51ff0ef          	jal	80001a9e <allocproc>
    80001b52:	84aa                	mv	s1,a0
  initproc = p;
    80001b54:	00008797          	auipc	a5,0x8
    80001b58:	7aa7b223          	sd	a0,1956(a5) # 8000a2f8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001b5c:	03400613          	li	a2,52
    80001b60:	00008597          	auipc	a1,0x8
    80001b64:	71058593          	addi	a1,a1,1808 # 8000a270 <initcode>
    80001b68:	6928                	ld	a0,80(a0)
    80001b6a:	f58ff0ef          	jal	800012c2 <uvmfirst>
  p->sz = PGSIZE;
    80001b6e:	6785                	lui	a5,0x1
    80001b70:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001b72:	6cb8                	ld	a4,88(s1)
    80001b74:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001b78:	6cb8                	ld	a4,88(s1)
    80001b7a:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001b7c:	4641                	li	a2,16
    80001b7e:	00005597          	auipc	a1,0x5
    80001b82:	6a258593          	addi	a1,a1,1698 # 80007220 <etext+0x220>
    80001b86:	15848513          	addi	a0,s1,344
    80001b8a:	a96ff0ef          	jal	80000e20 <safestrcpy>
  p->cwd = namei("/");
    80001b8e:	00005517          	auipc	a0,0x5
    80001b92:	6a250513          	addi	a0,a0,1698 # 80007230 <etext+0x230>
    80001b96:	59b010ef          	jal	80003930 <namei>
    80001b9a:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001b9e:	478d                	li	a5,3
    80001ba0:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001ba2:	8526                	mv	a0,s1
    80001ba4:	8eeff0ef          	jal	80000c92 <release>
}
    80001ba8:	60e2                	ld	ra,24(sp)
    80001baa:	6442                	ld	s0,16(sp)
    80001bac:	64a2                	ld	s1,8(sp)
    80001bae:	6105                	addi	sp,sp,32
    80001bb0:	8082                	ret

0000000080001bb2 <growproc>:
{
    80001bb2:	1101                	addi	sp,sp,-32
    80001bb4:	ec06                	sd	ra,24(sp)
    80001bb6:	e822                	sd	s0,16(sp)
    80001bb8:	e426                	sd	s1,8(sp)
    80001bba:	e04a                	sd	s2,0(sp)
    80001bbc:	1000                	addi	s0,sp,32
    80001bbe:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001bc0:	d1dff0ef          	jal	800018dc <myproc>
    80001bc4:	84aa                	mv	s1,a0
  sz = p->sz;
    80001bc6:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001bc8:	01204c63          	bgtz	s2,80001be0 <growproc+0x2e>
  } else if(n < 0){
    80001bcc:	02094463          	bltz	s2,80001bf4 <growproc+0x42>
  p->sz = sz;
    80001bd0:	e4ac                	sd	a1,72(s1)
  return 0;
    80001bd2:	4501                	li	a0,0
}
    80001bd4:	60e2                	ld	ra,24(sp)
    80001bd6:	6442                	ld	s0,16(sp)
    80001bd8:	64a2                	ld	s1,8(sp)
    80001bda:	6902                	ld	s2,0(sp)
    80001bdc:	6105                	addi	sp,sp,32
    80001bde:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001be0:	4691                	li	a3,4
    80001be2:	00b90633          	add	a2,s2,a1
    80001be6:	6928                	ld	a0,80(a0)
    80001be8:	f7cff0ef          	jal	80001364 <uvmalloc>
    80001bec:	85aa                	mv	a1,a0
    80001bee:	f16d                	bnez	a0,80001bd0 <growproc+0x1e>
      return -1;
    80001bf0:	557d                	li	a0,-1
    80001bf2:	b7cd                	j	80001bd4 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001bf4:	00b90633          	add	a2,s2,a1
    80001bf8:	6928                	ld	a0,80(a0)
    80001bfa:	f26ff0ef          	jal	80001320 <uvmdealloc>
    80001bfe:	85aa                	mv	a1,a0
    80001c00:	bfc1                	j	80001bd0 <growproc+0x1e>

0000000080001c02 <fork>:
{
    80001c02:	7139                	addi	sp,sp,-64
    80001c04:	fc06                	sd	ra,56(sp)
    80001c06:	f822                	sd	s0,48(sp)
    80001c08:	f04a                	sd	s2,32(sp)
    80001c0a:	e456                	sd	s5,8(sp)
    80001c0c:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c0e:	ccfff0ef          	jal	800018dc <myproc>
    80001c12:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001c14:	e8bff0ef          	jal	80001a9e <allocproc>
    80001c18:	0e050a63          	beqz	a0,80001d0c <fork+0x10a>
    80001c1c:	e852                	sd	s4,16(sp)
    80001c1e:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001c20:	048ab603          	ld	a2,72(s5)
    80001c24:	692c                	ld	a1,80(a0)
    80001c26:	050ab503          	ld	a0,80(s5)
    80001c2a:	87bff0ef          	jal	800014a4 <uvmcopy>
    80001c2e:	04054a63          	bltz	a0,80001c82 <fork+0x80>
    80001c32:	f426                	sd	s1,40(sp)
    80001c34:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001c36:	048ab783          	ld	a5,72(s5)
    80001c3a:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001c3e:	058ab683          	ld	a3,88(s5)
    80001c42:	87b6                	mv	a5,a3
    80001c44:	058a3703          	ld	a4,88(s4)
    80001c48:	12068693          	addi	a3,a3,288
    80001c4c:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001c50:	6788                	ld	a0,8(a5)
    80001c52:	6b8c                	ld	a1,16(a5)
    80001c54:	6f90                	ld	a2,24(a5)
    80001c56:	01073023          	sd	a6,0(a4)
    80001c5a:	e708                	sd	a0,8(a4)
    80001c5c:	eb0c                	sd	a1,16(a4)
    80001c5e:	ef10                	sd	a2,24(a4)
    80001c60:	02078793          	addi	a5,a5,32
    80001c64:	02070713          	addi	a4,a4,32
    80001c68:	fed792e3          	bne	a5,a3,80001c4c <fork+0x4a>
  np->trapframe->a0 = 0;
    80001c6c:	058a3783          	ld	a5,88(s4)
    80001c70:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001c74:	0d0a8493          	addi	s1,s5,208
    80001c78:	0d0a0913          	addi	s2,s4,208
    80001c7c:	150a8993          	addi	s3,s5,336
    80001c80:	a831                	j	80001c9c <fork+0x9a>
    freeproc(np);
    80001c82:	8552                	mv	a0,s4
    80001c84:	dcbff0ef          	jal	80001a4e <freeproc>
    release(&np->lock);
    80001c88:	8552                	mv	a0,s4
    80001c8a:	808ff0ef          	jal	80000c92 <release>
    return -1;
    80001c8e:	597d                	li	s2,-1
    80001c90:	6a42                	ld	s4,16(sp)
    80001c92:	a0b5                	j	80001cfe <fork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001c94:	04a1                	addi	s1,s1,8
    80001c96:	0921                	addi	s2,s2,8
    80001c98:	01348963          	beq	s1,s3,80001caa <fork+0xa8>
    if(p->ofile[i])
    80001c9c:	6088                	ld	a0,0(s1)
    80001c9e:	d97d                	beqz	a0,80001c94 <fork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ca0:	22c020ef          	jal	80003ecc <filedup>
    80001ca4:	00a93023          	sd	a0,0(s2)
    80001ca8:	b7f5                	j	80001c94 <fork+0x92>
  np->cwd = idup(p->cwd);
    80001caa:	150ab503          	ld	a0,336(s5)
    80001cae:	55c010ef          	jal	8000320a <idup>
    80001cb2:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001cb6:	4641                	li	a2,16
    80001cb8:	158a8593          	addi	a1,s5,344
    80001cbc:	158a0513          	addi	a0,s4,344
    80001cc0:	960ff0ef          	jal	80000e20 <safestrcpy>
  pid = np->pid;
    80001cc4:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001cc8:	8552                	mv	a0,s4
    80001cca:	fc9fe0ef          	jal	80000c92 <release>
  acquire(&wait_lock);
    80001cce:	00010497          	auipc	s1,0x10
    80001cd2:	77a48493          	addi	s1,s1,1914 # 80012448 <wait_lock>
    80001cd6:	8526                	mv	a0,s1
    80001cd8:	f27fe0ef          	jal	80000bfe <acquire>
  np->parent = p;
    80001cdc:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001ce0:	8526                	mv	a0,s1
    80001ce2:	fb1fe0ef          	jal	80000c92 <release>
  acquire(&np->lock);
    80001ce6:	8552                	mv	a0,s4
    80001ce8:	f17fe0ef          	jal	80000bfe <acquire>
  np->state = RUNNABLE;
    80001cec:	478d                	li	a5,3
    80001cee:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001cf2:	8552                	mv	a0,s4
    80001cf4:	f9ffe0ef          	jal	80000c92 <release>
  return pid;
    80001cf8:	74a2                	ld	s1,40(sp)
    80001cfa:	69e2                	ld	s3,24(sp)
    80001cfc:	6a42                	ld	s4,16(sp)
}
    80001cfe:	854a                	mv	a0,s2
    80001d00:	70e2                	ld	ra,56(sp)
    80001d02:	7442                	ld	s0,48(sp)
    80001d04:	7902                	ld	s2,32(sp)
    80001d06:	6aa2                	ld	s5,8(sp)
    80001d08:	6121                	addi	sp,sp,64
    80001d0a:	8082                	ret
    return -1;
    80001d0c:	597d                	li	s2,-1
    80001d0e:	bfc5                	j	80001cfe <fork+0xfc>

0000000080001d10 <scheduler>:
{
    80001d10:	715d                	addi	sp,sp,-80
    80001d12:	e486                	sd	ra,72(sp)
    80001d14:	e0a2                	sd	s0,64(sp)
    80001d16:	fc26                	sd	s1,56(sp)
    80001d18:	f84a                	sd	s2,48(sp)
    80001d1a:	f44e                	sd	s3,40(sp)
    80001d1c:	f052                	sd	s4,32(sp)
    80001d1e:	ec56                	sd	s5,24(sp)
    80001d20:	e85a                	sd	s6,16(sp)
    80001d22:	e45e                	sd	s7,8(sp)
    80001d24:	e062                	sd	s8,0(sp)
    80001d26:	0880                	addi	s0,sp,80
    80001d28:	8792                	mv	a5,tp
  int id = r_tp();
    80001d2a:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d2c:	00779b13          	slli	s6,a5,0x7
    80001d30:	00010717          	auipc	a4,0x10
    80001d34:	70070713          	addi	a4,a4,1792 # 80012430 <pid_lock>
    80001d38:	975a                	add	a4,a4,s6
    80001d3a:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001d3e:	00010717          	auipc	a4,0x10
    80001d42:	72a70713          	addi	a4,a4,1834 # 80012468 <cpus+0x8>
    80001d46:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001d48:	4c11                	li	s8,4
        c->proc = p;
    80001d4a:	079e                	slli	a5,a5,0x7
    80001d4c:	00010a17          	auipc	s4,0x10
    80001d50:	6e4a0a13          	addi	s4,s4,1764 # 80012430 <pid_lock>
    80001d54:	9a3e                	add	s4,s4,a5
        found = 1;
    80001d56:	4b85                	li	s7,1
    80001d58:	a0a9                	j	80001da2 <scheduler+0x92>
      release(&p->lock);
    80001d5a:	8526                	mv	a0,s1
    80001d5c:	f37fe0ef          	jal	80000c92 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d60:	16848493          	addi	s1,s1,360
    80001d64:	03248563          	beq	s1,s2,80001d8e <scheduler+0x7e>
      acquire(&p->lock);
    80001d68:	8526                	mv	a0,s1
    80001d6a:	e95fe0ef          	jal	80000bfe <acquire>
      if(p->state == RUNNABLE) {
    80001d6e:	4c9c                	lw	a5,24(s1)
    80001d70:	ff3795e3          	bne	a5,s3,80001d5a <scheduler+0x4a>
        p->state = RUNNING;
    80001d74:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001d78:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001d7c:	06048593          	addi	a1,s1,96
    80001d80:	855a                	mv	a0,s6
    80001d82:	5b6000ef          	jal	80002338 <swtch>
        c->proc = 0;
    80001d86:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001d8a:	8ade                	mv	s5,s7
    80001d8c:	b7f9                	j	80001d5a <scheduler+0x4a>
    if(found == 0) {
    80001d8e:	000a9a63          	bnez	s5,80001da2 <scheduler+0x92>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d92:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001d96:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001d9a:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001d9e:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001da2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001da6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001daa:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001dae:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001db0:	00011497          	auipc	s1,0x11
    80001db4:	ab048493          	addi	s1,s1,-1360 # 80012860 <proc>
      if(p->state == RUNNABLE) {
    80001db8:	498d                	li	s3,3
    for(p = proc; p < &proc[NPROC]; p++) {
    80001dba:	00016917          	auipc	s2,0x16
    80001dbe:	4a690913          	addi	s2,s2,1190 # 80018260 <tickslock>
    80001dc2:	b75d                	j	80001d68 <scheduler+0x58>

0000000080001dc4 <sched>:
{
    80001dc4:	7179                	addi	sp,sp,-48
    80001dc6:	f406                	sd	ra,40(sp)
    80001dc8:	f022                	sd	s0,32(sp)
    80001dca:	ec26                	sd	s1,24(sp)
    80001dcc:	e84a                	sd	s2,16(sp)
    80001dce:	e44e                	sd	s3,8(sp)
    80001dd0:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001dd2:	b0bff0ef          	jal	800018dc <myproc>
    80001dd6:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001dd8:	dbdfe0ef          	jal	80000b94 <holding>
    80001ddc:	c92d                	beqz	a0,80001e4e <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001dde:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001de0:	2781                	sext.w	a5,a5
    80001de2:	079e                	slli	a5,a5,0x7
    80001de4:	00010717          	auipc	a4,0x10
    80001de8:	64c70713          	addi	a4,a4,1612 # 80012430 <pid_lock>
    80001dec:	97ba                	add	a5,a5,a4
    80001dee:	0a87a703          	lw	a4,168(a5)
    80001df2:	4785                	li	a5,1
    80001df4:	06f71363          	bne	a4,a5,80001e5a <sched+0x96>
  if(p->state == RUNNING)
    80001df8:	4c98                	lw	a4,24(s1)
    80001dfa:	4791                	li	a5,4
    80001dfc:	06f70563          	beq	a4,a5,80001e66 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e00:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e04:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e06:	e7b5                	bnez	a5,80001e72 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e08:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e0a:	00010917          	auipc	s2,0x10
    80001e0e:	62690913          	addi	s2,s2,1574 # 80012430 <pid_lock>
    80001e12:	2781                	sext.w	a5,a5
    80001e14:	079e                	slli	a5,a5,0x7
    80001e16:	97ca                	add	a5,a5,s2
    80001e18:	0ac7a983          	lw	s3,172(a5)
    80001e1c:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e1e:	2781                	sext.w	a5,a5
    80001e20:	079e                	slli	a5,a5,0x7
    80001e22:	00010597          	auipc	a1,0x10
    80001e26:	64658593          	addi	a1,a1,1606 # 80012468 <cpus+0x8>
    80001e2a:	95be                	add	a1,a1,a5
    80001e2c:	06048513          	addi	a0,s1,96
    80001e30:	508000ef          	jal	80002338 <swtch>
    80001e34:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001e36:	2781                	sext.w	a5,a5
    80001e38:	079e                	slli	a5,a5,0x7
    80001e3a:	993e                	add	s2,s2,a5
    80001e3c:	0b392623          	sw	s3,172(s2)
}
    80001e40:	70a2                	ld	ra,40(sp)
    80001e42:	7402                	ld	s0,32(sp)
    80001e44:	64e2                	ld	s1,24(sp)
    80001e46:	6942                	ld	s2,16(sp)
    80001e48:	69a2                	ld	s3,8(sp)
    80001e4a:	6145                	addi	sp,sp,48
    80001e4c:	8082                	ret
    panic("sched p->lock");
    80001e4e:	00005517          	auipc	a0,0x5
    80001e52:	3ea50513          	addi	a0,a0,1002 # 80007238 <etext+0x238>
    80001e56:	949fe0ef          	jal	8000079e <panic>
    panic("sched locks");
    80001e5a:	00005517          	auipc	a0,0x5
    80001e5e:	3ee50513          	addi	a0,a0,1006 # 80007248 <etext+0x248>
    80001e62:	93dfe0ef          	jal	8000079e <panic>
    panic("sched running");
    80001e66:	00005517          	auipc	a0,0x5
    80001e6a:	3f250513          	addi	a0,a0,1010 # 80007258 <etext+0x258>
    80001e6e:	931fe0ef          	jal	8000079e <panic>
    panic("sched interruptible");
    80001e72:	00005517          	auipc	a0,0x5
    80001e76:	3f650513          	addi	a0,a0,1014 # 80007268 <etext+0x268>
    80001e7a:	925fe0ef          	jal	8000079e <panic>

0000000080001e7e <yield>:
{
    80001e7e:	1101                	addi	sp,sp,-32
    80001e80:	ec06                	sd	ra,24(sp)
    80001e82:	e822                	sd	s0,16(sp)
    80001e84:	e426                	sd	s1,8(sp)
    80001e86:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001e88:	a55ff0ef          	jal	800018dc <myproc>
    80001e8c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001e8e:	d71fe0ef          	jal	80000bfe <acquire>
  p->state = RUNNABLE;
    80001e92:	478d                	li	a5,3
    80001e94:	cc9c                	sw	a5,24(s1)
  sched();
    80001e96:	f2fff0ef          	jal	80001dc4 <sched>
  release(&p->lock);
    80001e9a:	8526                	mv	a0,s1
    80001e9c:	df7fe0ef          	jal	80000c92 <release>
}
    80001ea0:	60e2                	ld	ra,24(sp)
    80001ea2:	6442                	ld	s0,16(sp)
    80001ea4:	64a2                	ld	s1,8(sp)
    80001ea6:	6105                	addi	sp,sp,32
    80001ea8:	8082                	ret

0000000080001eaa <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001eaa:	7179                	addi	sp,sp,-48
    80001eac:	f406                	sd	ra,40(sp)
    80001eae:	f022                	sd	s0,32(sp)
    80001eb0:	ec26                	sd	s1,24(sp)
    80001eb2:	e84a                	sd	s2,16(sp)
    80001eb4:	e44e                	sd	s3,8(sp)
    80001eb6:	1800                	addi	s0,sp,48
    80001eb8:	89aa                	mv	s3,a0
    80001eba:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001ebc:	a21ff0ef          	jal	800018dc <myproc>
    80001ec0:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001ec2:	d3dfe0ef          	jal	80000bfe <acquire>
  release(lk);
    80001ec6:	854a                	mv	a0,s2
    80001ec8:	dcbfe0ef          	jal	80000c92 <release>

  // Go to sleep.
  p->chan = chan;
    80001ecc:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001ed0:	4789                	li	a5,2
    80001ed2:	cc9c                	sw	a5,24(s1)

  sched();
    80001ed4:	ef1ff0ef          	jal	80001dc4 <sched>

  // Tidy up.
  p->chan = 0;
    80001ed8:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001edc:	8526                	mv	a0,s1
    80001ede:	db5fe0ef          	jal	80000c92 <release>
  acquire(lk);
    80001ee2:	854a                	mv	a0,s2
    80001ee4:	d1bfe0ef          	jal	80000bfe <acquire>
}
    80001ee8:	70a2                	ld	ra,40(sp)
    80001eea:	7402                	ld	s0,32(sp)
    80001eec:	64e2                	ld	s1,24(sp)
    80001eee:	6942                	ld	s2,16(sp)
    80001ef0:	69a2                	ld	s3,8(sp)
    80001ef2:	6145                	addi	sp,sp,48
    80001ef4:	8082                	ret

0000000080001ef6 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80001ef6:	7139                	addi	sp,sp,-64
    80001ef8:	fc06                	sd	ra,56(sp)
    80001efa:	f822                	sd	s0,48(sp)
    80001efc:	f426                	sd	s1,40(sp)
    80001efe:	f04a                	sd	s2,32(sp)
    80001f00:	ec4e                	sd	s3,24(sp)
    80001f02:	e852                	sd	s4,16(sp)
    80001f04:	e456                	sd	s5,8(sp)
    80001f06:	0080                	addi	s0,sp,64
    80001f08:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001f0a:	00011497          	auipc	s1,0x11
    80001f0e:	95648493          	addi	s1,s1,-1706 # 80012860 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001f12:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f14:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f16:	00016917          	auipc	s2,0x16
    80001f1a:	34a90913          	addi	s2,s2,842 # 80018260 <tickslock>
    80001f1e:	a801                	j	80001f2e <wakeup+0x38>
      }
      release(&p->lock);
    80001f20:	8526                	mv	a0,s1
    80001f22:	d71fe0ef          	jal	80000c92 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f26:	16848493          	addi	s1,s1,360
    80001f2a:	03248263          	beq	s1,s2,80001f4e <wakeup+0x58>
    if(p != myproc()){
    80001f2e:	9afff0ef          	jal	800018dc <myproc>
    80001f32:	fea48ae3          	beq	s1,a0,80001f26 <wakeup+0x30>
      acquire(&p->lock);
    80001f36:	8526                	mv	a0,s1
    80001f38:	cc7fe0ef          	jal	80000bfe <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001f3c:	4c9c                	lw	a5,24(s1)
    80001f3e:	ff3791e3          	bne	a5,s3,80001f20 <wakeup+0x2a>
    80001f42:	709c                	ld	a5,32(s1)
    80001f44:	fd479ee3          	bne	a5,s4,80001f20 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001f48:	0154ac23          	sw	s5,24(s1)
    80001f4c:	bfd1                	j	80001f20 <wakeup+0x2a>
    }
  }
}
    80001f4e:	70e2                	ld	ra,56(sp)
    80001f50:	7442                	ld	s0,48(sp)
    80001f52:	74a2                	ld	s1,40(sp)
    80001f54:	7902                	ld	s2,32(sp)
    80001f56:	69e2                	ld	s3,24(sp)
    80001f58:	6a42                	ld	s4,16(sp)
    80001f5a:	6aa2                	ld	s5,8(sp)
    80001f5c:	6121                	addi	sp,sp,64
    80001f5e:	8082                	ret

0000000080001f60 <reparent>:
{
    80001f60:	7179                	addi	sp,sp,-48
    80001f62:	f406                	sd	ra,40(sp)
    80001f64:	f022                	sd	s0,32(sp)
    80001f66:	ec26                	sd	s1,24(sp)
    80001f68:	e84a                	sd	s2,16(sp)
    80001f6a:	e44e                	sd	s3,8(sp)
    80001f6c:	e052                	sd	s4,0(sp)
    80001f6e:	1800                	addi	s0,sp,48
    80001f70:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f72:	00011497          	auipc	s1,0x11
    80001f76:	8ee48493          	addi	s1,s1,-1810 # 80012860 <proc>
      pp->parent = initproc;
    80001f7a:	00008a17          	auipc	s4,0x8
    80001f7e:	37ea0a13          	addi	s4,s4,894 # 8000a2f8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f82:	00016997          	auipc	s3,0x16
    80001f86:	2de98993          	addi	s3,s3,734 # 80018260 <tickslock>
    80001f8a:	a029                	j	80001f94 <reparent+0x34>
    80001f8c:	16848493          	addi	s1,s1,360
    80001f90:	01348b63          	beq	s1,s3,80001fa6 <reparent+0x46>
    if(pp->parent == p){
    80001f94:	7c9c                	ld	a5,56(s1)
    80001f96:	ff279be3          	bne	a5,s2,80001f8c <reparent+0x2c>
      pp->parent = initproc;
    80001f9a:	000a3503          	ld	a0,0(s4)
    80001f9e:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001fa0:	f57ff0ef          	jal	80001ef6 <wakeup>
    80001fa4:	b7e5                	j	80001f8c <reparent+0x2c>
}
    80001fa6:	70a2                	ld	ra,40(sp)
    80001fa8:	7402                	ld	s0,32(sp)
    80001faa:	64e2                	ld	s1,24(sp)
    80001fac:	6942                	ld	s2,16(sp)
    80001fae:	69a2                	ld	s3,8(sp)
    80001fb0:	6a02                	ld	s4,0(sp)
    80001fb2:	6145                	addi	sp,sp,48
    80001fb4:	8082                	ret

0000000080001fb6 <exit>:
{
    80001fb6:	7179                	addi	sp,sp,-48
    80001fb8:	f406                	sd	ra,40(sp)
    80001fba:	f022                	sd	s0,32(sp)
    80001fbc:	ec26                	sd	s1,24(sp)
    80001fbe:	e84a                	sd	s2,16(sp)
    80001fc0:	e44e                	sd	s3,8(sp)
    80001fc2:	e052                	sd	s4,0(sp)
    80001fc4:	1800                	addi	s0,sp,48
    80001fc6:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001fc8:	915ff0ef          	jal	800018dc <myproc>
    80001fcc:	89aa                	mv	s3,a0
  if(p == initproc)
    80001fce:	00008797          	auipc	a5,0x8
    80001fd2:	32a7b783          	ld	a5,810(a5) # 8000a2f8 <initproc>
    80001fd6:	0d050493          	addi	s1,a0,208
    80001fda:	15050913          	addi	s2,a0,336
    80001fde:	00a79b63          	bne	a5,a0,80001ff4 <exit+0x3e>
    panic("init exiting");
    80001fe2:	00005517          	auipc	a0,0x5
    80001fe6:	29e50513          	addi	a0,a0,670 # 80007280 <etext+0x280>
    80001fea:	fb4fe0ef          	jal	8000079e <panic>
  for(int fd = 0; fd < NOFILE; fd++){
    80001fee:	04a1                	addi	s1,s1,8
    80001ff0:	01248963          	beq	s1,s2,80002002 <exit+0x4c>
    if(p->ofile[fd]){
    80001ff4:	6088                	ld	a0,0(s1)
    80001ff6:	dd65                	beqz	a0,80001fee <exit+0x38>
      fileclose(f);
    80001ff8:	71b010ef          	jal	80003f12 <fileclose>
      p->ofile[fd] = 0;
    80001ffc:	0004b023          	sd	zero,0(s1)
    80002000:	b7fd                	j	80001fee <exit+0x38>
  begin_op();
    80002002:	2f1010ef          	jal	80003af2 <begin_op>
  iput(p->cwd);
    80002006:	1509b503          	ld	a0,336(s3)
    8000200a:	3b8010ef          	jal	800033c2 <iput>
  end_op();
    8000200e:	34f010ef          	jal	80003b5c <end_op>
  p->cwd = 0;
    80002012:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002016:	00010497          	auipc	s1,0x10
    8000201a:	43248493          	addi	s1,s1,1074 # 80012448 <wait_lock>
    8000201e:	8526                	mv	a0,s1
    80002020:	bdffe0ef          	jal	80000bfe <acquire>
  reparent(p);
    80002024:	854e                	mv	a0,s3
    80002026:	f3bff0ef          	jal	80001f60 <reparent>
  wakeup(p->parent);
    8000202a:	0389b503          	ld	a0,56(s3)
    8000202e:	ec9ff0ef          	jal	80001ef6 <wakeup>
  acquire(&p->lock);
    80002032:	854e                	mv	a0,s3
    80002034:	bcbfe0ef          	jal	80000bfe <acquire>
  p->xstate = status;
    80002038:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000203c:	4795                	li	a5,5
    8000203e:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002042:	8526                	mv	a0,s1
    80002044:	c4ffe0ef          	jal	80000c92 <release>
  sched();
    80002048:	d7dff0ef          	jal	80001dc4 <sched>
  panic("zombie exit");
    8000204c:	00005517          	auipc	a0,0x5
    80002050:	24450513          	addi	a0,a0,580 # 80007290 <etext+0x290>
    80002054:	f4afe0ef          	jal	8000079e <panic>

0000000080002058 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002058:	7179                	addi	sp,sp,-48
    8000205a:	f406                	sd	ra,40(sp)
    8000205c:	f022                	sd	s0,32(sp)
    8000205e:	ec26                	sd	s1,24(sp)
    80002060:	e84a                	sd	s2,16(sp)
    80002062:	e44e                	sd	s3,8(sp)
    80002064:	1800                	addi	s0,sp,48
    80002066:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002068:	00010497          	auipc	s1,0x10
    8000206c:	7f848493          	addi	s1,s1,2040 # 80012860 <proc>
    80002070:	00016997          	auipc	s3,0x16
    80002074:	1f098993          	addi	s3,s3,496 # 80018260 <tickslock>
    acquire(&p->lock);
    80002078:	8526                	mv	a0,s1
    8000207a:	b85fe0ef          	jal	80000bfe <acquire>
    if(p->pid == pid){
    8000207e:	589c                	lw	a5,48(s1)
    80002080:	01278b63          	beq	a5,s2,80002096 <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002084:	8526                	mv	a0,s1
    80002086:	c0dfe0ef          	jal	80000c92 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000208a:	16848493          	addi	s1,s1,360
    8000208e:	ff3495e3          	bne	s1,s3,80002078 <kill+0x20>
  }
  return -1;
    80002092:	557d                	li	a0,-1
    80002094:	a819                	j	800020aa <kill+0x52>
      p->killed = 1;
    80002096:	4785                	li	a5,1
    80002098:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000209a:	4c98                	lw	a4,24(s1)
    8000209c:	4789                	li	a5,2
    8000209e:	00f70d63          	beq	a4,a5,800020b8 <kill+0x60>
      release(&p->lock);
    800020a2:	8526                	mv	a0,s1
    800020a4:	beffe0ef          	jal	80000c92 <release>
      return 0;
    800020a8:	4501                	li	a0,0
}
    800020aa:	70a2                	ld	ra,40(sp)
    800020ac:	7402                	ld	s0,32(sp)
    800020ae:	64e2                	ld	s1,24(sp)
    800020b0:	6942                	ld	s2,16(sp)
    800020b2:	69a2                	ld	s3,8(sp)
    800020b4:	6145                	addi	sp,sp,48
    800020b6:	8082                	ret
        p->state = RUNNABLE;
    800020b8:	478d                	li	a5,3
    800020ba:	cc9c                	sw	a5,24(s1)
    800020bc:	b7dd                	j	800020a2 <kill+0x4a>

00000000800020be <setkilled>:

void
setkilled(struct proc *p)
{
    800020be:	1101                	addi	sp,sp,-32
    800020c0:	ec06                	sd	ra,24(sp)
    800020c2:	e822                	sd	s0,16(sp)
    800020c4:	e426                	sd	s1,8(sp)
    800020c6:	1000                	addi	s0,sp,32
    800020c8:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020ca:	b35fe0ef          	jal	80000bfe <acquire>
  p->killed = 1;
    800020ce:	4785                	li	a5,1
    800020d0:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800020d2:	8526                	mv	a0,s1
    800020d4:	bbffe0ef          	jal	80000c92 <release>
}
    800020d8:	60e2                	ld	ra,24(sp)
    800020da:	6442                	ld	s0,16(sp)
    800020dc:	64a2                	ld	s1,8(sp)
    800020de:	6105                	addi	sp,sp,32
    800020e0:	8082                	ret

00000000800020e2 <killed>:

int
killed(struct proc *p)
{
    800020e2:	1101                	addi	sp,sp,-32
    800020e4:	ec06                	sd	ra,24(sp)
    800020e6:	e822                	sd	s0,16(sp)
    800020e8:	e426                	sd	s1,8(sp)
    800020ea:	e04a                	sd	s2,0(sp)
    800020ec:	1000                	addi	s0,sp,32
    800020ee:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800020f0:	b0ffe0ef          	jal	80000bfe <acquire>
  k = p->killed;
    800020f4:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800020f8:	8526                	mv	a0,s1
    800020fa:	b99fe0ef          	jal	80000c92 <release>
  return k;
}
    800020fe:	854a                	mv	a0,s2
    80002100:	60e2                	ld	ra,24(sp)
    80002102:	6442                	ld	s0,16(sp)
    80002104:	64a2                	ld	s1,8(sp)
    80002106:	6902                	ld	s2,0(sp)
    80002108:	6105                	addi	sp,sp,32
    8000210a:	8082                	ret

000000008000210c <wait>:
{
    8000210c:	715d                	addi	sp,sp,-80
    8000210e:	e486                	sd	ra,72(sp)
    80002110:	e0a2                	sd	s0,64(sp)
    80002112:	fc26                	sd	s1,56(sp)
    80002114:	f84a                	sd	s2,48(sp)
    80002116:	f44e                	sd	s3,40(sp)
    80002118:	f052                	sd	s4,32(sp)
    8000211a:	ec56                	sd	s5,24(sp)
    8000211c:	e85a                	sd	s6,16(sp)
    8000211e:	e45e                	sd	s7,8(sp)
    80002120:	0880                	addi	s0,sp,80
    80002122:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002124:	fb8ff0ef          	jal	800018dc <myproc>
    80002128:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000212a:	00010517          	auipc	a0,0x10
    8000212e:	31e50513          	addi	a0,a0,798 # 80012448 <wait_lock>
    80002132:	acdfe0ef          	jal	80000bfe <acquire>
        if(pp->state == ZOMBIE){
    80002136:	4a15                	li	s4,5
        havekids = 1;
    80002138:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000213a:	00016997          	auipc	s3,0x16
    8000213e:	12698993          	addi	s3,s3,294 # 80018260 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002142:	00010b97          	auipc	s7,0x10
    80002146:	306b8b93          	addi	s7,s7,774 # 80012448 <wait_lock>
    8000214a:	a869                	j	800021e4 <wait+0xd8>
          pid = pp->pid;
    8000214c:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002150:	000b0c63          	beqz	s6,80002168 <wait+0x5c>
    80002154:	4691                	li	a3,4
    80002156:	02c48613          	addi	a2,s1,44
    8000215a:	85da                	mv	a1,s6
    8000215c:	05093503          	ld	a0,80(s2)
    80002160:	c24ff0ef          	jal	80001584 <copyout>
    80002164:	02054a63          	bltz	a0,80002198 <wait+0x8c>
          freeproc(pp);
    80002168:	8526                	mv	a0,s1
    8000216a:	8e5ff0ef          	jal	80001a4e <freeproc>
          release(&pp->lock);
    8000216e:	8526                	mv	a0,s1
    80002170:	b23fe0ef          	jal	80000c92 <release>
          release(&wait_lock);
    80002174:	00010517          	auipc	a0,0x10
    80002178:	2d450513          	addi	a0,a0,724 # 80012448 <wait_lock>
    8000217c:	b17fe0ef          	jal	80000c92 <release>
}
    80002180:	854e                	mv	a0,s3
    80002182:	60a6                	ld	ra,72(sp)
    80002184:	6406                	ld	s0,64(sp)
    80002186:	74e2                	ld	s1,56(sp)
    80002188:	7942                	ld	s2,48(sp)
    8000218a:	79a2                	ld	s3,40(sp)
    8000218c:	7a02                	ld	s4,32(sp)
    8000218e:	6ae2                	ld	s5,24(sp)
    80002190:	6b42                	ld	s6,16(sp)
    80002192:	6ba2                	ld	s7,8(sp)
    80002194:	6161                	addi	sp,sp,80
    80002196:	8082                	ret
            release(&pp->lock);
    80002198:	8526                	mv	a0,s1
    8000219a:	af9fe0ef          	jal	80000c92 <release>
            release(&wait_lock);
    8000219e:	00010517          	auipc	a0,0x10
    800021a2:	2aa50513          	addi	a0,a0,682 # 80012448 <wait_lock>
    800021a6:	aedfe0ef          	jal	80000c92 <release>
            return -1;
    800021aa:	59fd                	li	s3,-1
    800021ac:	bfd1                	j	80002180 <wait+0x74>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021ae:	16848493          	addi	s1,s1,360
    800021b2:	03348063          	beq	s1,s3,800021d2 <wait+0xc6>
      if(pp->parent == p){
    800021b6:	7c9c                	ld	a5,56(s1)
    800021b8:	ff279be3          	bne	a5,s2,800021ae <wait+0xa2>
        acquire(&pp->lock);
    800021bc:	8526                	mv	a0,s1
    800021be:	a41fe0ef          	jal	80000bfe <acquire>
        if(pp->state == ZOMBIE){
    800021c2:	4c9c                	lw	a5,24(s1)
    800021c4:	f94784e3          	beq	a5,s4,8000214c <wait+0x40>
        release(&pp->lock);
    800021c8:	8526                	mv	a0,s1
    800021ca:	ac9fe0ef          	jal	80000c92 <release>
        havekids = 1;
    800021ce:	8756                	mv	a4,s5
    800021d0:	bff9                	j	800021ae <wait+0xa2>
    if(!havekids || killed(p)){
    800021d2:	cf19                	beqz	a4,800021f0 <wait+0xe4>
    800021d4:	854a                	mv	a0,s2
    800021d6:	f0dff0ef          	jal	800020e2 <killed>
    800021da:	e919                	bnez	a0,800021f0 <wait+0xe4>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800021dc:	85de                	mv	a1,s7
    800021de:	854a                	mv	a0,s2
    800021e0:	ccbff0ef          	jal	80001eaa <sleep>
    havekids = 0;
    800021e4:	4701                	li	a4,0
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021e6:	00010497          	auipc	s1,0x10
    800021ea:	67a48493          	addi	s1,s1,1658 # 80012860 <proc>
    800021ee:	b7e1                	j	800021b6 <wait+0xaa>
      release(&wait_lock);
    800021f0:	00010517          	auipc	a0,0x10
    800021f4:	25850513          	addi	a0,a0,600 # 80012448 <wait_lock>
    800021f8:	a9bfe0ef          	jal	80000c92 <release>
      return -1;
    800021fc:	59fd                	li	s3,-1
    800021fe:	b749                	j	80002180 <wait+0x74>

0000000080002200 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002200:	7179                	addi	sp,sp,-48
    80002202:	f406                	sd	ra,40(sp)
    80002204:	f022                	sd	s0,32(sp)
    80002206:	ec26                	sd	s1,24(sp)
    80002208:	e84a                	sd	s2,16(sp)
    8000220a:	e44e                	sd	s3,8(sp)
    8000220c:	e052                	sd	s4,0(sp)
    8000220e:	1800                	addi	s0,sp,48
    80002210:	84aa                	mv	s1,a0
    80002212:	892e                	mv	s2,a1
    80002214:	89b2                	mv	s3,a2
    80002216:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002218:	ec4ff0ef          	jal	800018dc <myproc>
  if(user_dst){
    8000221c:	cc99                	beqz	s1,8000223a <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    8000221e:	86d2                	mv	a3,s4
    80002220:	864e                	mv	a2,s3
    80002222:	85ca                	mv	a1,s2
    80002224:	6928                	ld	a0,80(a0)
    80002226:	b5eff0ef          	jal	80001584 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000222a:	70a2                	ld	ra,40(sp)
    8000222c:	7402                	ld	s0,32(sp)
    8000222e:	64e2                	ld	s1,24(sp)
    80002230:	6942                	ld	s2,16(sp)
    80002232:	69a2                	ld	s3,8(sp)
    80002234:	6a02                	ld	s4,0(sp)
    80002236:	6145                	addi	sp,sp,48
    80002238:	8082                	ret
    memmove((char *)dst, src, len);
    8000223a:	000a061b          	sext.w	a2,s4
    8000223e:	85ce                	mv	a1,s3
    80002240:	854a                	mv	a0,s2
    80002242:	af1fe0ef          	jal	80000d32 <memmove>
    return 0;
    80002246:	8526                	mv	a0,s1
    80002248:	b7cd                	j	8000222a <either_copyout+0x2a>

000000008000224a <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000224a:	7179                	addi	sp,sp,-48
    8000224c:	f406                	sd	ra,40(sp)
    8000224e:	f022                	sd	s0,32(sp)
    80002250:	ec26                	sd	s1,24(sp)
    80002252:	e84a                	sd	s2,16(sp)
    80002254:	e44e                	sd	s3,8(sp)
    80002256:	e052                	sd	s4,0(sp)
    80002258:	1800                	addi	s0,sp,48
    8000225a:	892a                	mv	s2,a0
    8000225c:	84ae                	mv	s1,a1
    8000225e:	89b2                	mv	s3,a2
    80002260:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002262:	e7aff0ef          	jal	800018dc <myproc>
  if(user_src){
    80002266:	cc99                	beqz	s1,80002284 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002268:	86d2                	mv	a3,s4
    8000226a:	864e                	mv	a2,s3
    8000226c:	85ca                	mv	a1,s2
    8000226e:	6928                	ld	a0,80(a0)
    80002270:	bc4ff0ef          	jal	80001634 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002274:	70a2                	ld	ra,40(sp)
    80002276:	7402                	ld	s0,32(sp)
    80002278:	64e2                	ld	s1,24(sp)
    8000227a:	6942                	ld	s2,16(sp)
    8000227c:	69a2                	ld	s3,8(sp)
    8000227e:	6a02                	ld	s4,0(sp)
    80002280:	6145                	addi	sp,sp,48
    80002282:	8082                	ret
    memmove(dst, (char*)src, len);
    80002284:	000a061b          	sext.w	a2,s4
    80002288:	85ce                	mv	a1,s3
    8000228a:	854a                	mv	a0,s2
    8000228c:	aa7fe0ef          	jal	80000d32 <memmove>
    return 0;
    80002290:	8526                	mv	a0,s1
    80002292:	b7cd                	j	80002274 <either_copyin+0x2a>

0000000080002294 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002294:	715d                	addi	sp,sp,-80
    80002296:	e486                	sd	ra,72(sp)
    80002298:	e0a2                	sd	s0,64(sp)
    8000229a:	fc26                	sd	s1,56(sp)
    8000229c:	f84a                	sd	s2,48(sp)
    8000229e:	f44e                	sd	s3,40(sp)
    800022a0:	f052                	sd	s4,32(sp)
    800022a2:	ec56                	sd	s5,24(sp)
    800022a4:	e85a                	sd	s6,16(sp)
    800022a6:	e45e                	sd	s7,8(sp)
    800022a8:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800022aa:	00005517          	auipc	a0,0x5
    800022ae:	dce50513          	addi	a0,a0,-562 # 80007078 <etext+0x78>
    800022b2:	a1cfe0ef          	jal	800004ce <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800022b6:	00010497          	auipc	s1,0x10
    800022ba:	70248493          	addi	s1,s1,1794 # 800129b8 <proc+0x158>
    800022be:	00016917          	auipc	s2,0x16
    800022c2:	0fa90913          	addi	s2,s2,250 # 800183b8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022c6:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800022c8:	00005997          	auipc	s3,0x5
    800022cc:	fd898993          	addi	s3,s3,-40 # 800072a0 <etext+0x2a0>
    printf("%d %s %s", p->pid, state, p->name);
    800022d0:	00005a97          	auipc	s5,0x5
    800022d4:	fd8a8a93          	addi	s5,s5,-40 # 800072a8 <etext+0x2a8>
    printf("\n");
    800022d8:	00005a17          	auipc	s4,0x5
    800022dc:	da0a0a13          	addi	s4,s4,-608 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022e0:	00005b97          	auipc	s7,0x5
    800022e4:	4a8b8b93          	addi	s7,s7,1192 # 80007788 <states.0>
    800022e8:	a829                	j	80002302 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    800022ea:	ed86a583          	lw	a1,-296(a3)
    800022ee:	8556                	mv	a0,s5
    800022f0:	9defe0ef          	jal	800004ce <printf>
    printf("\n");
    800022f4:	8552                	mv	a0,s4
    800022f6:	9d8fe0ef          	jal	800004ce <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800022fa:	16848493          	addi	s1,s1,360
    800022fe:	03248263          	beq	s1,s2,80002322 <procdump+0x8e>
    if(p->state == UNUSED)
    80002302:	86a6                	mv	a3,s1
    80002304:	ec04a783          	lw	a5,-320(s1)
    80002308:	dbed                	beqz	a5,800022fa <procdump+0x66>
      state = "???";
    8000230a:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000230c:	fcfb6fe3          	bltu	s6,a5,800022ea <procdump+0x56>
    80002310:	02079713          	slli	a4,a5,0x20
    80002314:	01d75793          	srli	a5,a4,0x1d
    80002318:	97de                	add	a5,a5,s7
    8000231a:	6390                	ld	a2,0(a5)
    8000231c:	f679                	bnez	a2,800022ea <procdump+0x56>
      state = "???";
    8000231e:	864e                	mv	a2,s3
    80002320:	b7e9                	j	800022ea <procdump+0x56>
  }
}
    80002322:	60a6                	ld	ra,72(sp)
    80002324:	6406                	ld	s0,64(sp)
    80002326:	74e2                	ld	s1,56(sp)
    80002328:	7942                	ld	s2,48(sp)
    8000232a:	79a2                	ld	s3,40(sp)
    8000232c:	7a02                	ld	s4,32(sp)
    8000232e:	6ae2                	ld	s5,24(sp)
    80002330:	6b42                	ld	s6,16(sp)
    80002332:	6ba2                	ld	s7,8(sp)
    80002334:	6161                	addi	sp,sp,80
    80002336:	8082                	ret

0000000080002338 <swtch>:
    80002338:	00153023          	sd	ra,0(a0)
    8000233c:	00253423          	sd	sp,8(a0)
    80002340:	e900                	sd	s0,16(a0)
    80002342:	ed04                	sd	s1,24(a0)
    80002344:	03253023          	sd	s2,32(a0)
    80002348:	03353423          	sd	s3,40(a0)
    8000234c:	03453823          	sd	s4,48(a0)
    80002350:	03553c23          	sd	s5,56(a0)
    80002354:	05653023          	sd	s6,64(a0)
    80002358:	05753423          	sd	s7,72(a0)
    8000235c:	05853823          	sd	s8,80(a0)
    80002360:	05953c23          	sd	s9,88(a0)
    80002364:	07a53023          	sd	s10,96(a0)
    80002368:	07b53423          	sd	s11,104(a0)
    8000236c:	0005b083          	ld	ra,0(a1)
    80002370:	0085b103          	ld	sp,8(a1)
    80002374:	6980                	ld	s0,16(a1)
    80002376:	6d84                	ld	s1,24(a1)
    80002378:	0205b903          	ld	s2,32(a1)
    8000237c:	0285b983          	ld	s3,40(a1)
    80002380:	0305ba03          	ld	s4,48(a1)
    80002384:	0385ba83          	ld	s5,56(a1)
    80002388:	0405bb03          	ld	s6,64(a1)
    8000238c:	0485bb83          	ld	s7,72(a1)
    80002390:	0505bc03          	ld	s8,80(a1)
    80002394:	0585bc83          	ld	s9,88(a1)
    80002398:	0605bd03          	ld	s10,96(a1)
    8000239c:	0685bd83          	ld	s11,104(a1)
    800023a0:	8082                	ret

00000000800023a2 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800023a2:	1141                	addi	sp,sp,-16
    800023a4:	e406                	sd	ra,8(sp)
    800023a6:	e022                	sd	s0,0(sp)
    800023a8:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800023aa:	00005597          	auipc	a1,0x5
    800023ae:	f3e58593          	addi	a1,a1,-194 # 800072e8 <etext+0x2e8>
    800023b2:	00016517          	auipc	a0,0x16
    800023b6:	eae50513          	addi	a0,a0,-338 # 80018260 <tickslock>
    800023ba:	fc0fe0ef          	jal	80000b7a <initlock>
}
    800023be:	60a2                	ld	ra,8(sp)
    800023c0:	6402                	ld	s0,0(sp)
    800023c2:	0141                	addi	sp,sp,16
    800023c4:	8082                	ret

00000000800023c6 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800023c6:	1141                	addi	sp,sp,-16
    800023c8:	e406                	sd	ra,8(sp)
    800023ca:	e022                	sd	s0,0(sp)
    800023cc:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800023ce:	00003797          	auipc	a5,0x3
    800023d2:	ef278793          	addi	a5,a5,-270 # 800052c0 <kernelvec>
    800023d6:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800023da:	60a2                	ld	ra,8(sp)
    800023dc:	6402                	ld	s0,0(sp)
    800023de:	0141                	addi	sp,sp,16
    800023e0:	8082                	ret

00000000800023e2 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800023e2:	1141                	addi	sp,sp,-16
    800023e4:	e406                	sd	ra,8(sp)
    800023e6:	e022                	sd	s0,0(sp)
    800023e8:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800023ea:	cf2ff0ef          	jal	800018dc <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800023ee:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800023f2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800023f4:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800023f8:	00004697          	auipc	a3,0x4
    800023fc:	c0868693          	addi	a3,a3,-1016 # 80006000 <_trampoline>
    80002400:	00004717          	auipc	a4,0x4
    80002404:	c0070713          	addi	a4,a4,-1024 # 80006000 <_trampoline>
    80002408:	8f15                	sub	a4,a4,a3
    8000240a:	040007b7          	lui	a5,0x4000
    8000240e:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002410:	07b2                	slli	a5,a5,0xc
    80002412:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002414:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002418:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000241a:	18002673          	csrr	a2,satp
    8000241e:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002420:	6d30                	ld	a2,88(a0)
    80002422:	6138                	ld	a4,64(a0)
    80002424:	6585                	lui	a1,0x1
    80002426:	972e                	add	a4,a4,a1
    80002428:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000242a:	6d38                	ld	a4,88(a0)
    8000242c:	00000617          	auipc	a2,0x0
    80002430:	11060613          	addi	a2,a2,272 # 8000253c <usertrap>
    80002434:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002436:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002438:	8612                	mv	a2,tp
    8000243a:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000243c:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002440:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002444:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002448:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000244c:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000244e:	6f18                	ld	a4,24(a4)
    80002450:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002454:	6928                	ld	a0,80(a0)
    80002456:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002458:	00004717          	auipc	a4,0x4
    8000245c:	c4470713          	addi	a4,a4,-956 # 8000609c <userret>
    80002460:	8f15                	sub	a4,a4,a3
    80002462:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002464:	577d                	li	a4,-1
    80002466:	177e                	slli	a4,a4,0x3f
    80002468:	8d59                	or	a0,a0,a4
    8000246a:	9782                	jalr	a5
}
    8000246c:	60a2                	ld	ra,8(sp)
    8000246e:	6402                	ld	s0,0(sp)
    80002470:	0141                	addi	sp,sp,16
    80002472:	8082                	ret

0000000080002474 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002474:	1101                	addi	sp,sp,-32
    80002476:	ec06                	sd	ra,24(sp)
    80002478:	e822                	sd	s0,16(sp)
    8000247a:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    8000247c:	c2cff0ef          	jal	800018a8 <cpuid>
    80002480:	cd11                	beqz	a0,8000249c <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002482:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002486:	000f4737          	lui	a4,0xf4
    8000248a:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000248e:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002490:	14d79073          	csrw	stimecmp,a5
}
    80002494:	60e2                	ld	ra,24(sp)
    80002496:	6442                	ld	s0,16(sp)
    80002498:	6105                	addi	sp,sp,32
    8000249a:	8082                	ret
    8000249c:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    8000249e:	00016497          	auipc	s1,0x16
    800024a2:	dc248493          	addi	s1,s1,-574 # 80018260 <tickslock>
    800024a6:	8526                	mv	a0,s1
    800024a8:	f56fe0ef          	jal	80000bfe <acquire>
    ticks++;
    800024ac:	00008517          	auipc	a0,0x8
    800024b0:	e5450513          	addi	a0,a0,-428 # 8000a300 <ticks>
    800024b4:	411c                	lw	a5,0(a0)
    800024b6:	2785                	addiw	a5,a5,1
    800024b8:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800024ba:	a3dff0ef          	jal	80001ef6 <wakeup>
    release(&tickslock);
    800024be:	8526                	mv	a0,s1
    800024c0:	fd2fe0ef          	jal	80000c92 <release>
    800024c4:	64a2                	ld	s1,8(sp)
    800024c6:	bf75                	j	80002482 <clockintr+0xe>

00000000800024c8 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800024c8:	1101                	addi	sp,sp,-32
    800024ca:	ec06                	sd	ra,24(sp)
    800024cc:	e822                	sd	s0,16(sp)
    800024ce:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800024d0:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    800024d4:	57fd                	li	a5,-1
    800024d6:	17fe                	slli	a5,a5,0x3f
    800024d8:	07a5                	addi	a5,a5,9
    800024da:	00f70c63          	beq	a4,a5,800024f2 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    800024de:	57fd                	li	a5,-1
    800024e0:	17fe                	slli	a5,a5,0x3f
    800024e2:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800024e4:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    800024e6:	04f70763          	beq	a4,a5,80002534 <devintr+0x6c>
  }
}
    800024ea:	60e2                	ld	ra,24(sp)
    800024ec:	6442                	ld	s0,16(sp)
    800024ee:	6105                	addi	sp,sp,32
    800024f0:	8082                	ret
    800024f2:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800024f4:	679020ef          	jal	8000536c <plic_claim>
    800024f8:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800024fa:	47a9                	li	a5,10
    800024fc:	00f50963          	beq	a0,a5,8000250e <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002500:	4785                	li	a5,1
    80002502:	00f50963          	beq	a0,a5,80002514 <devintr+0x4c>
    return 1;
    80002506:	4505                	li	a0,1
    } else if(irq){
    80002508:	e889                	bnez	s1,8000251a <devintr+0x52>
    8000250a:	64a2                	ld	s1,8(sp)
    8000250c:	bff9                	j	800024ea <devintr+0x22>
      uartintr();
    8000250e:	cfefe0ef          	jal	80000a0c <uartintr>
    if(irq)
    80002512:	a819                	j	80002528 <devintr+0x60>
      virtio_disk_intr();
    80002514:	2e8030ef          	jal	800057fc <virtio_disk_intr>
    if(irq)
    80002518:	a801                	j	80002528 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    8000251a:	85a6                	mv	a1,s1
    8000251c:	00005517          	auipc	a0,0x5
    80002520:	dd450513          	addi	a0,a0,-556 # 800072f0 <etext+0x2f0>
    80002524:	fabfd0ef          	jal	800004ce <printf>
      plic_complete(irq);
    80002528:	8526                	mv	a0,s1
    8000252a:	663020ef          	jal	8000538c <plic_complete>
    return 1;
    8000252e:	4505                	li	a0,1
    80002530:	64a2                	ld	s1,8(sp)
    80002532:	bf65                	j	800024ea <devintr+0x22>
    clockintr();
    80002534:	f41ff0ef          	jal	80002474 <clockintr>
    return 2;
    80002538:	4509                	li	a0,2
    8000253a:	bf45                	j	800024ea <devintr+0x22>

000000008000253c <usertrap>:
{
    8000253c:	1101                	addi	sp,sp,-32
    8000253e:	ec06                	sd	ra,24(sp)
    80002540:	e822                	sd	s0,16(sp)
    80002542:	e426                	sd	s1,8(sp)
    80002544:	e04a                	sd	s2,0(sp)
    80002546:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002548:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000254c:	1007f793          	andi	a5,a5,256
    80002550:	ef85                	bnez	a5,80002588 <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002552:	00003797          	auipc	a5,0x3
    80002556:	d6e78793          	addi	a5,a5,-658 # 800052c0 <kernelvec>
    8000255a:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000255e:	b7eff0ef          	jal	800018dc <myproc>
    80002562:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002564:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002566:	14102773          	csrr	a4,sepc
    8000256a:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000256c:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002570:	47a1                	li	a5,8
    80002572:	02f70163          	beq	a4,a5,80002594 <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    80002576:	f53ff0ef          	jal	800024c8 <devintr>
    8000257a:	892a                	mv	s2,a0
    8000257c:	c135                	beqz	a0,800025e0 <usertrap+0xa4>
  if(killed(p))
    8000257e:	8526                	mv	a0,s1
    80002580:	b63ff0ef          	jal	800020e2 <killed>
    80002584:	cd1d                	beqz	a0,800025c2 <usertrap+0x86>
    80002586:	a81d                	j	800025bc <usertrap+0x80>
    panic("usertrap: not from user mode");
    80002588:	00005517          	auipc	a0,0x5
    8000258c:	d8850513          	addi	a0,a0,-632 # 80007310 <etext+0x310>
    80002590:	a0efe0ef          	jal	8000079e <panic>
    if(killed(p))
    80002594:	b4fff0ef          	jal	800020e2 <killed>
    80002598:	e121                	bnez	a0,800025d8 <usertrap+0x9c>
    p->trapframe->epc += 4;
    8000259a:	6cb8                	ld	a4,88(s1)
    8000259c:	6f1c                	ld	a5,24(a4)
    8000259e:	0791                	addi	a5,a5,4
    800025a0:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025a2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800025a6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800025aa:	10079073          	csrw	sstatus,a5
    syscall();
    800025ae:	240000ef          	jal	800027ee <syscall>
  if(killed(p))
    800025b2:	8526                	mv	a0,s1
    800025b4:	b2fff0ef          	jal	800020e2 <killed>
    800025b8:	c901                	beqz	a0,800025c8 <usertrap+0x8c>
    800025ba:	4901                	li	s2,0
    exit(-1);
    800025bc:	557d                	li	a0,-1
    800025be:	9f9ff0ef          	jal	80001fb6 <exit>
  if(which_dev == 2)
    800025c2:	4789                	li	a5,2
    800025c4:	04f90563          	beq	s2,a5,8000260e <usertrap+0xd2>
  usertrapret();
    800025c8:	e1bff0ef          	jal	800023e2 <usertrapret>
}
    800025cc:	60e2                	ld	ra,24(sp)
    800025ce:	6442                	ld	s0,16(sp)
    800025d0:	64a2                	ld	s1,8(sp)
    800025d2:	6902                	ld	s2,0(sp)
    800025d4:	6105                	addi	sp,sp,32
    800025d6:	8082                	ret
      exit(-1);
    800025d8:	557d                	li	a0,-1
    800025da:	9ddff0ef          	jal	80001fb6 <exit>
    800025de:	bf75                	j	8000259a <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800025e0:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800025e4:	5890                	lw	a2,48(s1)
    800025e6:	00005517          	auipc	a0,0x5
    800025ea:	d4a50513          	addi	a0,a0,-694 # 80007330 <etext+0x330>
    800025ee:	ee1fd0ef          	jal	800004ce <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800025f2:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800025f6:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800025fa:	00005517          	auipc	a0,0x5
    800025fe:	d6650513          	addi	a0,a0,-666 # 80007360 <etext+0x360>
    80002602:	ecdfd0ef          	jal	800004ce <printf>
    setkilled(p);
    80002606:	8526                	mv	a0,s1
    80002608:	ab7ff0ef          	jal	800020be <setkilled>
    8000260c:	b75d                	j	800025b2 <usertrap+0x76>
    yield();
    8000260e:	871ff0ef          	jal	80001e7e <yield>
    80002612:	bf5d                	j	800025c8 <usertrap+0x8c>

0000000080002614 <kerneltrap>:
{
    80002614:	7179                	addi	sp,sp,-48
    80002616:	f406                	sd	ra,40(sp)
    80002618:	f022                	sd	s0,32(sp)
    8000261a:	ec26                	sd	s1,24(sp)
    8000261c:	e84a                	sd	s2,16(sp)
    8000261e:	e44e                	sd	s3,8(sp)
    80002620:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002622:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002626:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000262a:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000262e:	1004f793          	andi	a5,s1,256
    80002632:	c795                	beqz	a5,8000265e <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002634:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002638:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000263a:	eb85                	bnez	a5,8000266a <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    8000263c:	e8dff0ef          	jal	800024c8 <devintr>
    80002640:	c91d                	beqz	a0,80002676 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002642:	4789                	li	a5,2
    80002644:	04f50a63          	beq	a0,a5,80002698 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002648:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000264c:	10049073          	csrw	sstatus,s1
}
    80002650:	70a2                	ld	ra,40(sp)
    80002652:	7402                	ld	s0,32(sp)
    80002654:	64e2                	ld	s1,24(sp)
    80002656:	6942                	ld	s2,16(sp)
    80002658:	69a2                	ld	s3,8(sp)
    8000265a:	6145                	addi	sp,sp,48
    8000265c:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000265e:	00005517          	auipc	a0,0x5
    80002662:	d2a50513          	addi	a0,a0,-726 # 80007388 <etext+0x388>
    80002666:	938fe0ef          	jal	8000079e <panic>
    panic("kerneltrap: interrupts enabled");
    8000266a:	00005517          	auipc	a0,0x5
    8000266e:	d4650513          	addi	a0,a0,-698 # 800073b0 <etext+0x3b0>
    80002672:	92cfe0ef          	jal	8000079e <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002676:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000267a:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    8000267e:	85ce                	mv	a1,s3
    80002680:	00005517          	auipc	a0,0x5
    80002684:	d5050513          	addi	a0,a0,-688 # 800073d0 <etext+0x3d0>
    80002688:	e47fd0ef          	jal	800004ce <printf>
    panic("kerneltrap");
    8000268c:	00005517          	auipc	a0,0x5
    80002690:	d6c50513          	addi	a0,a0,-660 # 800073f8 <etext+0x3f8>
    80002694:	90afe0ef          	jal	8000079e <panic>
  if(which_dev == 2 && myproc() != 0)
    80002698:	a44ff0ef          	jal	800018dc <myproc>
    8000269c:	d555                	beqz	a0,80002648 <kerneltrap+0x34>
    yield();
    8000269e:	fe0ff0ef          	jal	80001e7e <yield>
    800026a2:	b75d                	j	80002648 <kerneltrap+0x34>

00000000800026a4 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800026a4:	1101                	addi	sp,sp,-32
    800026a6:	ec06                	sd	ra,24(sp)
    800026a8:	e822                	sd	s0,16(sp)
    800026aa:	e426                	sd	s1,8(sp)
    800026ac:	1000                	addi	s0,sp,32
    800026ae:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800026b0:	a2cff0ef          	jal	800018dc <myproc>
  switch (n) {
    800026b4:	4795                	li	a5,5
    800026b6:	0497e163          	bltu	a5,s1,800026f8 <argraw+0x54>
    800026ba:	048a                	slli	s1,s1,0x2
    800026bc:	00005717          	auipc	a4,0x5
    800026c0:	0fc70713          	addi	a4,a4,252 # 800077b8 <states.0+0x30>
    800026c4:	94ba                	add	s1,s1,a4
    800026c6:	409c                	lw	a5,0(s1)
    800026c8:	97ba                	add	a5,a5,a4
    800026ca:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800026cc:	6d3c                	ld	a5,88(a0)
    800026ce:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800026d0:	60e2                	ld	ra,24(sp)
    800026d2:	6442                	ld	s0,16(sp)
    800026d4:	64a2                	ld	s1,8(sp)
    800026d6:	6105                	addi	sp,sp,32
    800026d8:	8082                	ret
    return p->trapframe->a1;
    800026da:	6d3c                	ld	a5,88(a0)
    800026dc:	7fa8                	ld	a0,120(a5)
    800026de:	bfcd                	j	800026d0 <argraw+0x2c>
    return p->trapframe->a2;
    800026e0:	6d3c                	ld	a5,88(a0)
    800026e2:	63c8                	ld	a0,128(a5)
    800026e4:	b7f5                	j	800026d0 <argraw+0x2c>
    return p->trapframe->a3;
    800026e6:	6d3c                	ld	a5,88(a0)
    800026e8:	67c8                	ld	a0,136(a5)
    800026ea:	b7dd                	j	800026d0 <argraw+0x2c>
    return p->trapframe->a4;
    800026ec:	6d3c                	ld	a5,88(a0)
    800026ee:	6bc8                	ld	a0,144(a5)
    800026f0:	b7c5                	j	800026d0 <argraw+0x2c>
    return p->trapframe->a5;
    800026f2:	6d3c                	ld	a5,88(a0)
    800026f4:	6fc8                	ld	a0,152(a5)
    800026f6:	bfe9                	j	800026d0 <argraw+0x2c>
  panic("argraw");
    800026f8:	00005517          	auipc	a0,0x5
    800026fc:	d1050513          	addi	a0,a0,-752 # 80007408 <etext+0x408>
    80002700:	89efe0ef          	jal	8000079e <panic>

0000000080002704 <fetchaddr>:
{
    80002704:	1101                	addi	sp,sp,-32
    80002706:	ec06                	sd	ra,24(sp)
    80002708:	e822                	sd	s0,16(sp)
    8000270a:	e426                	sd	s1,8(sp)
    8000270c:	e04a                	sd	s2,0(sp)
    8000270e:	1000                	addi	s0,sp,32
    80002710:	84aa                	mv	s1,a0
    80002712:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002714:	9c8ff0ef          	jal	800018dc <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002718:	653c                	ld	a5,72(a0)
    8000271a:	02f4f663          	bgeu	s1,a5,80002746 <fetchaddr+0x42>
    8000271e:	00848713          	addi	a4,s1,8
    80002722:	02e7e463          	bltu	a5,a4,8000274a <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002726:	46a1                	li	a3,8
    80002728:	8626                	mv	a2,s1
    8000272a:	85ca                	mv	a1,s2
    8000272c:	6928                	ld	a0,80(a0)
    8000272e:	f07fe0ef          	jal	80001634 <copyin>
    80002732:	00a03533          	snez	a0,a0
    80002736:	40a0053b          	negw	a0,a0
}
    8000273a:	60e2                	ld	ra,24(sp)
    8000273c:	6442                	ld	s0,16(sp)
    8000273e:	64a2                	ld	s1,8(sp)
    80002740:	6902                	ld	s2,0(sp)
    80002742:	6105                	addi	sp,sp,32
    80002744:	8082                	ret
    return -1;
    80002746:	557d                	li	a0,-1
    80002748:	bfcd                	j	8000273a <fetchaddr+0x36>
    8000274a:	557d                	li	a0,-1
    8000274c:	b7fd                	j	8000273a <fetchaddr+0x36>

000000008000274e <fetchstr>:
{
    8000274e:	7179                	addi	sp,sp,-48
    80002750:	f406                	sd	ra,40(sp)
    80002752:	f022                	sd	s0,32(sp)
    80002754:	ec26                	sd	s1,24(sp)
    80002756:	e84a                	sd	s2,16(sp)
    80002758:	e44e                	sd	s3,8(sp)
    8000275a:	1800                	addi	s0,sp,48
    8000275c:	892a                	mv	s2,a0
    8000275e:	84ae                	mv	s1,a1
    80002760:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002762:	97aff0ef          	jal	800018dc <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002766:	86ce                	mv	a3,s3
    80002768:	864a                	mv	a2,s2
    8000276a:	85a6                	mv	a1,s1
    8000276c:	6928                	ld	a0,80(a0)
    8000276e:	f4dfe0ef          	jal	800016ba <copyinstr>
    80002772:	00054c63          	bltz	a0,8000278a <fetchstr+0x3c>
  return strlen(buf);
    80002776:	8526                	mv	a0,s1
    80002778:	edefe0ef          	jal	80000e56 <strlen>
}
    8000277c:	70a2                	ld	ra,40(sp)
    8000277e:	7402                	ld	s0,32(sp)
    80002780:	64e2                	ld	s1,24(sp)
    80002782:	6942                	ld	s2,16(sp)
    80002784:	69a2                	ld	s3,8(sp)
    80002786:	6145                	addi	sp,sp,48
    80002788:	8082                	ret
    return -1;
    8000278a:	557d                	li	a0,-1
    8000278c:	bfc5                	j	8000277c <fetchstr+0x2e>

000000008000278e <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    8000278e:	1101                	addi	sp,sp,-32
    80002790:	ec06                	sd	ra,24(sp)
    80002792:	e822                	sd	s0,16(sp)
    80002794:	e426                	sd	s1,8(sp)
    80002796:	1000                	addi	s0,sp,32
    80002798:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000279a:	f0bff0ef          	jal	800026a4 <argraw>
    8000279e:	c088                	sw	a0,0(s1)
}
    800027a0:	60e2                	ld	ra,24(sp)
    800027a2:	6442                	ld	s0,16(sp)
    800027a4:	64a2                	ld	s1,8(sp)
    800027a6:	6105                	addi	sp,sp,32
    800027a8:	8082                	ret

00000000800027aa <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800027aa:	1101                	addi	sp,sp,-32
    800027ac:	ec06                	sd	ra,24(sp)
    800027ae:	e822                	sd	s0,16(sp)
    800027b0:	e426                	sd	s1,8(sp)
    800027b2:	1000                	addi	s0,sp,32
    800027b4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800027b6:	eefff0ef          	jal	800026a4 <argraw>
    800027ba:	e088                	sd	a0,0(s1)
}
    800027bc:	60e2                	ld	ra,24(sp)
    800027be:	6442                	ld	s0,16(sp)
    800027c0:	64a2                	ld	s1,8(sp)
    800027c2:	6105                	addi	sp,sp,32
    800027c4:	8082                	ret

00000000800027c6 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800027c6:	1101                	addi	sp,sp,-32
    800027c8:	ec06                	sd	ra,24(sp)
    800027ca:	e822                	sd	s0,16(sp)
    800027cc:	e426                	sd	s1,8(sp)
    800027ce:	e04a                	sd	s2,0(sp)
    800027d0:	1000                	addi	s0,sp,32
    800027d2:	84ae                	mv	s1,a1
    800027d4:	8932                	mv	s2,a2
  *ip = argraw(n);
    800027d6:	ecfff0ef          	jal	800026a4 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    800027da:	864a                	mv	a2,s2
    800027dc:	85a6                	mv	a1,s1
    800027de:	f71ff0ef          	jal	8000274e <fetchstr>
}
    800027e2:	60e2                	ld	ra,24(sp)
    800027e4:	6442                	ld	s0,16(sp)
    800027e6:	64a2                	ld	s1,8(sp)
    800027e8:	6902                	ld	s2,0(sp)
    800027ea:	6105                	addi	sp,sp,32
    800027ec:	8082                	ret

00000000800027ee <syscall>:
    // Existing system calls...
  //  [SYS_toggle_case] toggle_case,
//};
void
syscall(void)
{
    800027ee:	1101                	addi	sp,sp,-32
    800027f0:	ec06                	sd	ra,24(sp)
    800027f2:	e822                	sd	s0,16(sp)
    800027f4:	e426                	sd	s1,8(sp)
    800027f6:	e04a                	sd	s2,0(sp)
    800027f8:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800027fa:	8e2ff0ef          	jal	800018dc <myproc>
    800027fe:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002800:	05853903          	ld	s2,88(a0)
    80002804:	0a893783          	ld	a5,168(s2)
    80002808:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000280c:	37fd                	addiw	a5,a5,-1
    8000280e:	4755                	li	a4,21
    80002810:	00f76f63          	bltu	a4,a5,8000282e <syscall+0x40>
    80002814:	00369713          	slli	a4,a3,0x3
    80002818:	00005797          	auipc	a5,0x5
    8000281c:	fb878793          	addi	a5,a5,-72 # 800077d0 <syscalls>
    80002820:	97ba                	add	a5,a5,a4
    80002822:	639c                	ld	a5,0(a5)
    80002824:	c789                	beqz	a5,8000282e <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002826:	9782                	jalr	a5
    80002828:	06a93823          	sd	a0,112(s2)
    8000282c:	a829                	j	80002846 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    8000282e:	15848613          	addi	a2,s1,344
    80002832:	588c                	lw	a1,48(s1)
    80002834:	00005517          	auipc	a0,0x5
    80002838:	bdc50513          	addi	a0,a0,-1060 # 80007410 <etext+0x410>
    8000283c:	c93fd0ef          	jal	800004ce <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002840:	6cbc                	ld	a5,88(s1)
    80002842:	577d                	li	a4,-1
    80002844:	fbb8                	sd	a4,112(a5)
  }
}
    80002846:	60e2                	ld	ra,24(sp)
    80002848:	6442                	ld	s0,16(sp)
    8000284a:	64a2                	ld	s1,8(sp)
    8000284c:	6902                	ld	s2,0(sp)
    8000284e:	6105                	addi	sp,sp,32
    80002850:	8082                	ret

0000000080002852 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002852:	1101                	addi	sp,sp,-32
    80002854:	ec06                	sd	ra,24(sp)
    80002856:	e822                	sd	s0,16(sp)
    80002858:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    8000285a:	fec40593          	addi	a1,s0,-20
    8000285e:	4501                	li	a0,0
    80002860:	f2fff0ef          	jal	8000278e <argint>
  exit(n);
    80002864:	fec42503          	lw	a0,-20(s0)
    80002868:	f4eff0ef          	jal	80001fb6 <exit>
  return 0;  // not reached
}
    8000286c:	4501                	li	a0,0
    8000286e:	60e2                	ld	ra,24(sp)
    80002870:	6442                	ld	s0,16(sp)
    80002872:	6105                	addi	sp,sp,32
    80002874:	8082                	ret

0000000080002876 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002876:	1141                	addi	sp,sp,-16
    80002878:	e406                	sd	ra,8(sp)
    8000287a:	e022                	sd	s0,0(sp)
    8000287c:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000287e:	85eff0ef          	jal	800018dc <myproc>
}
    80002882:	5908                	lw	a0,48(a0)
    80002884:	60a2                	ld	ra,8(sp)
    80002886:	6402                	ld	s0,0(sp)
    80002888:	0141                	addi	sp,sp,16
    8000288a:	8082                	ret

000000008000288c <sys_fork>:

uint64
sys_fork(void)
{
    8000288c:	1141                	addi	sp,sp,-16
    8000288e:	e406                	sd	ra,8(sp)
    80002890:	e022                	sd	s0,0(sp)
    80002892:	0800                	addi	s0,sp,16
  return fork();
    80002894:	b6eff0ef          	jal	80001c02 <fork>
}
    80002898:	60a2                	ld	ra,8(sp)
    8000289a:	6402                	ld	s0,0(sp)
    8000289c:	0141                	addi	sp,sp,16
    8000289e:	8082                	ret

00000000800028a0 <sys_wait>:

uint64
sys_wait(void)
{
    800028a0:	1101                	addi	sp,sp,-32
    800028a2:	ec06                	sd	ra,24(sp)
    800028a4:	e822                	sd	s0,16(sp)
    800028a6:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800028a8:	fe840593          	addi	a1,s0,-24
    800028ac:	4501                	li	a0,0
    800028ae:	efdff0ef          	jal	800027aa <argaddr>
  return wait(p);
    800028b2:	fe843503          	ld	a0,-24(s0)
    800028b6:	857ff0ef          	jal	8000210c <wait>
}
    800028ba:	60e2                	ld	ra,24(sp)
    800028bc:	6442                	ld	s0,16(sp)
    800028be:	6105                	addi	sp,sp,32
    800028c0:	8082                	ret

00000000800028c2 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800028c2:	7179                	addi	sp,sp,-48
    800028c4:	f406                	sd	ra,40(sp)
    800028c6:	f022                	sd	s0,32(sp)
    800028c8:	ec26                	sd	s1,24(sp)
    800028ca:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    800028cc:	fdc40593          	addi	a1,s0,-36
    800028d0:	4501                	li	a0,0
    800028d2:	ebdff0ef          	jal	8000278e <argint>
  addr = myproc()->sz;
    800028d6:	806ff0ef          	jal	800018dc <myproc>
    800028da:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    800028dc:	fdc42503          	lw	a0,-36(s0)
    800028e0:	ad2ff0ef          	jal	80001bb2 <growproc>
    800028e4:	00054863          	bltz	a0,800028f4 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    800028e8:	8526                	mv	a0,s1
    800028ea:	70a2                	ld	ra,40(sp)
    800028ec:	7402                	ld	s0,32(sp)
    800028ee:	64e2                	ld	s1,24(sp)
    800028f0:	6145                	addi	sp,sp,48
    800028f2:	8082                	ret
    return -1;
    800028f4:	54fd                	li	s1,-1
    800028f6:	bfcd                	j	800028e8 <sys_sbrk+0x26>

00000000800028f8 <sys_sleep>:

uint64
sys_sleep(void)
{
    800028f8:	7139                	addi	sp,sp,-64
    800028fa:	fc06                	sd	ra,56(sp)
    800028fc:	f822                	sd	s0,48(sp)
    800028fe:	f04a                	sd	s2,32(sp)
    80002900:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002902:	fcc40593          	addi	a1,s0,-52
    80002906:	4501                	li	a0,0
    80002908:	e87ff0ef          	jal	8000278e <argint>
  if(n < 0)
    8000290c:	fcc42783          	lw	a5,-52(s0)
    80002910:	0607c763          	bltz	a5,8000297e <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80002914:	00016517          	auipc	a0,0x16
    80002918:	94c50513          	addi	a0,a0,-1716 # 80018260 <tickslock>
    8000291c:	ae2fe0ef          	jal	80000bfe <acquire>
  ticks0 = ticks;
    80002920:	00008917          	auipc	s2,0x8
    80002924:	9e092903          	lw	s2,-1568(s2) # 8000a300 <ticks>
  while(ticks - ticks0 < n){
    80002928:	fcc42783          	lw	a5,-52(s0)
    8000292c:	cf8d                	beqz	a5,80002966 <sys_sleep+0x6e>
    8000292e:	f426                	sd	s1,40(sp)
    80002930:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002932:	00016997          	auipc	s3,0x16
    80002936:	92e98993          	addi	s3,s3,-1746 # 80018260 <tickslock>
    8000293a:	00008497          	auipc	s1,0x8
    8000293e:	9c648493          	addi	s1,s1,-1594 # 8000a300 <ticks>
    if(killed(myproc())){
    80002942:	f9bfe0ef          	jal	800018dc <myproc>
    80002946:	f9cff0ef          	jal	800020e2 <killed>
    8000294a:	ed0d                	bnez	a0,80002984 <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    8000294c:	85ce                	mv	a1,s3
    8000294e:	8526                	mv	a0,s1
    80002950:	d5aff0ef          	jal	80001eaa <sleep>
  while(ticks - ticks0 < n){
    80002954:	409c                	lw	a5,0(s1)
    80002956:	412787bb          	subw	a5,a5,s2
    8000295a:	fcc42703          	lw	a4,-52(s0)
    8000295e:	fee7e2e3          	bltu	a5,a4,80002942 <sys_sleep+0x4a>
    80002962:	74a2                	ld	s1,40(sp)
    80002964:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002966:	00016517          	auipc	a0,0x16
    8000296a:	8fa50513          	addi	a0,a0,-1798 # 80018260 <tickslock>
    8000296e:	b24fe0ef          	jal	80000c92 <release>
  return 0;
    80002972:	4501                	li	a0,0
}
    80002974:	70e2                	ld	ra,56(sp)
    80002976:	7442                	ld	s0,48(sp)
    80002978:	7902                	ld	s2,32(sp)
    8000297a:	6121                	addi	sp,sp,64
    8000297c:	8082                	ret
    n = 0;
    8000297e:	fc042623          	sw	zero,-52(s0)
    80002982:	bf49                	j	80002914 <sys_sleep+0x1c>
      release(&tickslock);
    80002984:	00016517          	auipc	a0,0x16
    80002988:	8dc50513          	addi	a0,a0,-1828 # 80018260 <tickslock>
    8000298c:	b06fe0ef          	jal	80000c92 <release>
      return -1;
    80002990:	557d                	li	a0,-1
    80002992:	74a2                	ld	s1,40(sp)
    80002994:	69e2                	ld	s3,24(sp)
    80002996:	bff9                	j	80002974 <sys_sleep+0x7c>

0000000080002998 <sys_kill>:

uint64
sys_kill(void)
{
    80002998:	1101                	addi	sp,sp,-32
    8000299a:	ec06                	sd	ra,24(sp)
    8000299c:	e822                	sd	s0,16(sp)
    8000299e:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800029a0:	fec40593          	addi	a1,s0,-20
    800029a4:	4501                	li	a0,0
    800029a6:	de9ff0ef          	jal	8000278e <argint>
  return kill(pid);
    800029aa:	fec42503          	lw	a0,-20(s0)
    800029ae:	eaaff0ef          	jal	80002058 <kill>
}
    800029b2:	60e2                	ld	ra,24(sp)
    800029b4:	6442                	ld	s0,16(sp)
    800029b6:	6105                	addi	sp,sp,32
    800029b8:	8082                	ret

00000000800029ba <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800029ba:	1101                	addi	sp,sp,-32
    800029bc:	ec06                	sd	ra,24(sp)
    800029be:	e822                	sd	s0,16(sp)
    800029c0:	e426                	sd	s1,8(sp)
    800029c2:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800029c4:	00016517          	auipc	a0,0x16
    800029c8:	89c50513          	addi	a0,a0,-1892 # 80018260 <tickslock>
    800029cc:	a32fe0ef          	jal	80000bfe <acquire>
  xticks = ticks;
    800029d0:	00008497          	auipc	s1,0x8
    800029d4:	9304a483          	lw	s1,-1744(s1) # 8000a300 <ticks>
  release(&tickslock);
    800029d8:	00016517          	auipc	a0,0x16
    800029dc:	88850513          	addi	a0,a0,-1912 # 80018260 <tickslock>
    800029e0:	ab2fe0ef          	jal	80000c92 <release>
  return xticks;
}
    800029e4:	02049513          	slli	a0,s1,0x20
    800029e8:	9101                	srli	a0,a0,0x20
    800029ea:	60e2                	ld	ra,24(sp)
    800029ec:	6442                	ld	s0,16(sp)
    800029ee:	64a2                	ld	s1,8(sp)
    800029f0:	6105                	addi	sp,sp,32
    800029f2:	8082                	ret

00000000800029f4 <toggle_case>:

 
int toggle_case(void)
{
    800029f4:	7135                	addi	sp,sp,-160
    800029f6:	ed06                	sd	ra,152(sp)
    800029f8:	e922                	sd	s0,144(sp)
    800029fa:	1100                	addi	s0,sp,160
  	 char str[100];          // Buffer for the string
    uint64 user_addr;       // Address of the string in user space

    // Get the user-space address of the string
    argaddr(0, &user_addr);  // Simply call argaddr; don't use it in an if condition.
    800029fc:	f6040593          	addi	a1,s0,-160
    80002a00:	4501                	li	a0,0
    80002a02:	da9ff0ef          	jal	800027aa <argaddr>

    // Check if the user address is valid (basic sanity check)
    if (user_addr == 0)
    80002a06:	f6043783          	ld	a5,-160(s0)
    80002a0a:	cbd9                	beqz	a5,80002aa0 <toggle_case+0xac>
        return -1;

    // Copy the string from user space to kernel space
    if (copyin(myproc()->pagetable, str, user_addr, sizeof(str)) < 0)
    80002a0c:	ed1fe0ef          	jal	800018dc <myproc>
    80002a10:	06400693          	li	a3,100
    80002a14:	f6043603          	ld	a2,-160(s0)
    80002a18:	f6840593          	addi	a1,s0,-152
    80002a1c:	6928                	ld	a0,80(a0)
    80002a1e:	c17fe0ef          	jal	80001634 <copyin>
    80002a22:	08054163          	bltz	a0,80002aa4 <toggle_case+0xb0>
    80002a26:	e526                	sd	s1,136(sp)
    80002a28:	e14a                	sd	s2,128(sp)
    80002a2a:	fcce                	sd	s3,120(sp)
        return -1;

    // Toggle the case of each character in the string
    for (int i = 0; str[i] != '\0'; i++) {
    80002a2c:	f6844783          	lbu	a5,-152(s0)
    80002a30:	cf8d                	beqz	a5,80002a6a <toggle_case+0x76>
    80002a32:	f6840693          	addi	a3,s0,-152
        if (str[i] >= 'a' && str[i] <= 'z') {
    80002a36:	4665                	li	a2,25
    80002a38:	a839                	j	80002a56 <toggle_case+0x62>
            str[i] -= 32;  // Convert lowercase to uppercase
        } else if (str[i] >= 'A' && str[i] <= 'Z') {
    80002a3a:	fbf7871b          	addiw	a4,a5,-65
    80002a3e:	0ff77713          	zext.b	a4,a4
    80002a42:	00e66663          	bltu	a2,a4,80002a4e <toggle_case+0x5a>
            str[i] += 32;  // Convert uppercase to lowercase
    80002a46:	0207879b          	addiw	a5,a5,32
    80002a4a:	00f68023          	sb	a5,0(a3)
    for (int i = 0; str[i] != '\0'; i++) {
    80002a4e:	0685                	addi	a3,a3,1
    80002a50:	0006c783          	lbu	a5,0(a3)
    80002a54:	cb99                	beqz	a5,80002a6a <toggle_case+0x76>
        if (str[i] >= 'a' && str[i] <= 'z') {
    80002a56:	f9f7871b          	addiw	a4,a5,-97
    80002a5a:	0ff77713          	zext.b	a4,a4
    80002a5e:	fce66ee3          	bltu	a2,a4,80002a3a <toggle_case+0x46>
            str[i] -= 32;  // Convert lowercase to uppercase
    80002a62:	3781                	addiw	a5,a5,-32
    80002a64:	00f68023          	sb	a5,0(a3)
    80002a68:	b7dd                	j	80002a4e <toggle_case+0x5a>
        }
    }

    // Copy the modified string back to user space
    if (copyout(myproc()->pagetable, user_addr, str, strlen(str) + 1) < 0)
    80002a6a:	e73fe0ef          	jal	800018dc <myproc>
    80002a6e:	05053903          	ld	s2,80(a0)
    80002a72:	f6043983          	ld	s3,-160(s0)
    80002a76:	f6840493          	addi	s1,s0,-152
    80002a7a:	8526                	mv	a0,s1
    80002a7c:	bdafe0ef          	jal	80000e56 <strlen>
    80002a80:	0015069b          	addiw	a3,a0,1
    80002a84:	8626                	mv	a2,s1
    80002a86:	85ce                	mv	a1,s3
    80002a88:	854a                	mv	a0,s2
    80002a8a:	afbfe0ef          	jal	80001584 <copyout>
    80002a8e:	41f5551b          	sraiw	a0,a0,0x1f
    80002a92:	64aa                	ld	s1,136(sp)
    80002a94:	690a                	ld	s2,128(sp)
    80002a96:	79e6                	ld	s3,120(sp)
        return -1;

    return 0;
}
    80002a98:	60ea                	ld	ra,152(sp)
    80002a9a:	644a                	ld	s0,144(sp)
    80002a9c:	610d                	addi	sp,sp,160
    80002a9e:	8082                	ret
        return -1;
    80002aa0:	557d                	li	a0,-1
    80002aa2:	bfdd                	j	80002a98 <toggle_case+0xa4>
        return -1;
    80002aa4:	557d                	li	a0,-1
    80002aa6:	bfcd                	j	80002a98 <toggle_case+0xa4>

0000000080002aa8 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002aa8:	7179                	addi	sp,sp,-48
    80002aaa:	f406                	sd	ra,40(sp)
    80002aac:	f022                	sd	s0,32(sp)
    80002aae:	ec26                	sd	s1,24(sp)
    80002ab0:	e84a                	sd	s2,16(sp)
    80002ab2:	e44e                	sd	s3,8(sp)
    80002ab4:	e052                	sd	s4,0(sp)
    80002ab6:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002ab8:	00005597          	auipc	a1,0x5
    80002abc:	97858593          	addi	a1,a1,-1672 # 80007430 <etext+0x430>
    80002ac0:	00015517          	auipc	a0,0x15
    80002ac4:	7b850513          	addi	a0,a0,1976 # 80018278 <bcache>
    80002ac8:	8b2fe0ef          	jal	80000b7a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002acc:	0001d797          	auipc	a5,0x1d
    80002ad0:	7ac78793          	addi	a5,a5,1964 # 80020278 <bcache+0x8000>
    80002ad4:	0001e717          	auipc	a4,0x1e
    80002ad8:	a0c70713          	addi	a4,a4,-1524 # 800204e0 <bcache+0x8268>
    80002adc:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002ae0:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002ae4:	00015497          	auipc	s1,0x15
    80002ae8:	7ac48493          	addi	s1,s1,1964 # 80018290 <bcache+0x18>
    b->next = bcache.head.next;
    80002aec:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002aee:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002af0:	00005a17          	auipc	s4,0x5
    80002af4:	948a0a13          	addi	s4,s4,-1720 # 80007438 <etext+0x438>
    b->next = bcache.head.next;
    80002af8:	2b893783          	ld	a5,696(s2)
    80002afc:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002afe:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002b02:	85d2                	mv	a1,s4
    80002b04:	01048513          	addi	a0,s1,16
    80002b08:	244010ef          	jal	80003d4c <initsleeplock>
    bcache.head.next->prev = b;
    80002b0c:	2b893783          	ld	a5,696(s2)
    80002b10:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002b12:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002b16:	45848493          	addi	s1,s1,1112
    80002b1a:	fd349fe3          	bne	s1,s3,80002af8 <binit+0x50>
  }
}
    80002b1e:	70a2                	ld	ra,40(sp)
    80002b20:	7402                	ld	s0,32(sp)
    80002b22:	64e2                	ld	s1,24(sp)
    80002b24:	6942                	ld	s2,16(sp)
    80002b26:	69a2                	ld	s3,8(sp)
    80002b28:	6a02                	ld	s4,0(sp)
    80002b2a:	6145                	addi	sp,sp,48
    80002b2c:	8082                	ret

0000000080002b2e <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002b2e:	7179                	addi	sp,sp,-48
    80002b30:	f406                	sd	ra,40(sp)
    80002b32:	f022                	sd	s0,32(sp)
    80002b34:	ec26                	sd	s1,24(sp)
    80002b36:	e84a                	sd	s2,16(sp)
    80002b38:	e44e                	sd	s3,8(sp)
    80002b3a:	1800                	addi	s0,sp,48
    80002b3c:	892a                	mv	s2,a0
    80002b3e:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002b40:	00015517          	auipc	a0,0x15
    80002b44:	73850513          	addi	a0,a0,1848 # 80018278 <bcache>
    80002b48:	8b6fe0ef          	jal	80000bfe <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002b4c:	0001e497          	auipc	s1,0x1e
    80002b50:	9e44b483          	ld	s1,-1564(s1) # 80020530 <bcache+0x82b8>
    80002b54:	0001e797          	auipc	a5,0x1e
    80002b58:	98c78793          	addi	a5,a5,-1652 # 800204e0 <bcache+0x8268>
    80002b5c:	02f48b63          	beq	s1,a5,80002b92 <bread+0x64>
    80002b60:	873e                	mv	a4,a5
    80002b62:	a021                	j	80002b6a <bread+0x3c>
    80002b64:	68a4                	ld	s1,80(s1)
    80002b66:	02e48663          	beq	s1,a4,80002b92 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002b6a:	449c                	lw	a5,8(s1)
    80002b6c:	ff279ce3          	bne	a5,s2,80002b64 <bread+0x36>
    80002b70:	44dc                	lw	a5,12(s1)
    80002b72:	ff3799e3          	bne	a5,s3,80002b64 <bread+0x36>
      b->refcnt++;
    80002b76:	40bc                	lw	a5,64(s1)
    80002b78:	2785                	addiw	a5,a5,1
    80002b7a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002b7c:	00015517          	auipc	a0,0x15
    80002b80:	6fc50513          	addi	a0,a0,1788 # 80018278 <bcache>
    80002b84:	90efe0ef          	jal	80000c92 <release>
      acquiresleep(&b->lock);
    80002b88:	01048513          	addi	a0,s1,16
    80002b8c:	1f6010ef          	jal	80003d82 <acquiresleep>
      return b;
    80002b90:	a889                	j	80002be2 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002b92:	0001e497          	auipc	s1,0x1e
    80002b96:	9964b483          	ld	s1,-1642(s1) # 80020528 <bcache+0x82b0>
    80002b9a:	0001e797          	auipc	a5,0x1e
    80002b9e:	94678793          	addi	a5,a5,-1722 # 800204e0 <bcache+0x8268>
    80002ba2:	00f48863          	beq	s1,a5,80002bb2 <bread+0x84>
    80002ba6:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002ba8:	40bc                	lw	a5,64(s1)
    80002baa:	cb91                	beqz	a5,80002bbe <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002bac:	64a4                	ld	s1,72(s1)
    80002bae:	fee49de3          	bne	s1,a4,80002ba8 <bread+0x7a>
  panic("bget: no buffers");
    80002bb2:	00005517          	auipc	a0,0x5
    80002bb6:	88e50513          	addi	a0,a0,-1906 # 80007440 <etext+0x440>
    80002bba:	be5fd0ef          	jal	8000079e <panic>
      b->dev = dev;
    80002bbe:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002bc2:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002bc6:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002bca:	4785                	li	a5,1
    80002bcc:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002bce:	00015517          	auipc	a0,0x15
    80002bd2:	6aa50513          	addi	a0,a0,1706 # 80018278 <bcache>
    80002bd6:	8bcfe0ef          	jal	80000c92 <release>
      acquiresleep(&b->lock);
    80002bda:	01048513          	addi	a0,s1,16
    80002bde:	1a4010ef          	jal	80003d82 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002be2:	409c                	lw	a5,0(s1)
    80002be4:	cb89                	beqz	a5,80002bf6 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002be6:	8526                	mv	a0,s1
    80002be8:	70a2                	ld	ra,40(sp)
    80002bea:	7402                	ld	s0,32(sp)
    80002bec:	64e2                	ld	s1,24(sp)
    80002bee:	6942                	ld	s2,16(sp)
    80002bf0:	69a2                	ld	s3,8(sp)
    80002bf2:	6145                	addi	sp,sp,48
    80002bf4:	8082                	ret
    virtio_disk_rw(b, 0);
    80002bf6:	4581                	li	a1,0
    80002bf8:	8526                	mv	a0,s1
    80002bfa:	1f7020ef          	jal	800055f0 <virtio_disk_rw>
    b->valid = 1;
    80002bfe:	4785                	li	a5,1
    80002c00:	c09c                	sw	a5,0(s1)
  return b;
    80002c02:	b7d5                	j	80002be6 <bread+0xb8>

0000000080002c04 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002c04:	1101                	addi	sp,sp,-32
    80002c06:	ec06                	sd	ra,24(sp)
    80002c08:	e822                	sd	s0,16(sp)
    80002c0a:	e426                	sd	s1,8(sp)
    80002c0c:	1000                	addi	s0,sp,32
    80002c0e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002c10:	0541                	addi	a0,a0,16
    80002c12:	1ee010ef          	jal	80003e00 <holdingsleep>
    80002c16:	c911                	beqz	a0,80002c2a <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002c18:	4585                	li	a1,1
    80002c1a:	8526                	mv	a0,s1
    80002c1c:	1d5020ef          	jal	800055f0 <virtio_disk_rw>
}
    80002c20:	60e2                	ld	ra,24(sp)
    80002c22:	6442                	ld	s0,16(sp)
    80002c24:	64a2                	ld	s1,8(sp)
    80002c26:	6105                	addi	sp,sp,32
    80002c28:	8082                	ret
    panic("bwrite");
    80002c2a:	00005517          	auipc	a0,0x5
    80002c2e:	82e50513          	addi	a0,a0,-2002 # 80007458 <etext+0x458>
    80002c32:	b6dfd0ef          	jal	8000079e <panic>

0000000080002c36 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002c36:	1101                	addi	sp,sp,-32
    80002c38:	ec06                	sd	ra,24(sp)
    80002c3a:	e822                	sd	s0,16(sp)
    80002c3c:	e426                	sd	s1,8(sp)
    80002c3e:	e04a                	sd	s2,0(sp)
    80002c40:	1000                	addi	s0,sp,32
    80002c42:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002c44:	01050913          	addi	s2,a0,16
    80002c48:	854a                	mv	a0,s2
    80002c4a:	1b6010ef          	jal	80003e00 <holdingsleep>
    80002c4e:	c125                	beqz	a0,80002cae <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002c50:	854a                	mv	a0,s2
    80002c52:	176010ef          	jal	80003dc8 <releasesleep>

  acquire(&bcache.lock);
    80002c56:	00015517          	auipc	a0,0x15
    80002c5a:	62250513          	addi	a0,a0,1570 # 80018278 <bcache>
    80002c5e:	fa1fd0ef          	jal	80000bfe <acquire>
  b->refcnt--;
    80002c62:	40bc                	lw	a5,64(s1)
    80002c64:	37fd                	addiw	a5,a5,-1
    80002c66:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002c68:	e79d                	bnez	a5,80002c96 <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002c6a:	68b8                	ld	a4,80(s1)
    80002c6c:	64bc                	ld	a5,72(s1)
    80002c6e:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002c70:	68b8                	ld	a4,80(s1)
    80002c72:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002c74:	0001d797          	auipc	a5,0x1d
    80002c78:	60478793          	addi	a5,a5,1540 # 80020278 <bcache+0x8000>
    80002c7c:	2b87b703          	ld	a4,696(a5)
    80002c80:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002c82:	0001e717          	auipc	a4,0x1e
    80002c86:	85e70713          	addi	a4,a4,-1954 # 800204e0 <bcache+0x8268>
    80002c8a:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002c8c:	2b87b703          	ld	a4,696(a5)
    80002c90:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002c92:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002c96:	00015517          	auipc	a0,0x15
    80002c9a:	5e250513          	addi	a0,a0,1506 # 80018278 <bcache>
    80002c9e:	ff5fd0ef          	jal	80000c92 <release>
}
    80002ca2:	60e2                	ld	ra,24(sp)
    80002ca4:	6442                	ld	s0,16(sp)
    80002ca6:	64a2                	ld	s1,8(sp)
    80002ca8:	6902                	ld	s2,0(sp)
    80002caa:	6105                	addi	sp,sp,32
    80002cac:	8082                	ret
    panic("brelse");
    80002cae:	00004517          	auipc	a0,0x4
    80002cb2:	7b250513          	addi	a0,a0,1970 # 80007460 <etext+0x460>
    80002cb6:	ae9fd0ef          	jal	8000079e <panic>

0000000080002cba <bpin>:

void
bpin(struct buf *b) {
    80002cba:	1101                	addi	sp,sp,-32
    80002cbc:	ec06                	sd	ra,24(sp)
    80002cbe:	e822                	sd	s0,16(sp)
    80002cc0:	e426                	sd	s1,8(sp)
    80002cc2:	1000                	addi	s0,sp,32
    80002cc4:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002cc6:	00015517          	auipc	a0,0x15
    80002cca:	5b250513          	addi	a0,a0,1458 # 80018278 <bcache>
    80002cce:	f31fd0ef          	jal	80000bfe <acquire>
  b->refcnt++;
    80002cd2:	40bc                	lw	a5,64(s1)
    80002cd4:	2785                	addiw	a5,a5,1
    80002cd6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002cd8:	00015517          	auipc	a0,0x15
    80002cdc:	5a050513          	addi	a0,a0,1440 # 80018278 <bcache>
    80002ce0:	fb3fd0ef          	jal	80000c92 <release>
}
    80002ce4:	60e2                	ld	ra,24(sp)
    80002ce6:	6442                	ld	s0,16(sp)
    80002ce8:	64a2                	ld	s1,8(sp)
    80002cea:	6105                	addi	sp,sp,32
    80002cec:	8082                	ret

0000000080002cee <bunpin>:

void
bunpin(struct buf *b) {
    80002cee:	1101                	addi	sp,sp,-32
    80002cf0:	ec06                	sd	ra,24(sp)
    80002cf2:	e822                	sd	s0,16(sp)
    80002cf4:	e426                	sd	s1,8(sp)
    80002cf6:	1000                	addi	s0,sp,32
    80002cf8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002cfa:	00015517          	auipc	a0,0x15
    80002cfe:	57e50513          	addi	a0,a0,1406 # 80018278 <bcache>
    80002d02:	efdfd0ef          	jal	80000bfe <acquire>
  b->refcnt--;
    80002d06:	40bc                	lw	a5,64(s1)
    80002d08:	37fd                	addiw	a5,a5,-1
    80002d0a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d0c:	00015517          	auipc	a0,0x15
    80002d10:	56c50513          	addi	a0,a0,1388 # 80018278 <bcache>
    80002d14:	f7ffd0ef          	jal	80000c92 <release>
}
    80002d18:	60e2                	ld	ra,24(sp)
    80002d1a:	6442                	ld	s0,16(sp)
    80002d1c:	64a2                	ld	s1,8(sp)
    80002d1e:	6105                	addi	sp,sp,32
    80002d20:	8082                	ret

0000000080002d22 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002d22:	1101                	addi	sp,sp,-32
    80002d24:	ec06                	sd	ra,24(sp)
    80002d26:	e822                	sd	s0,16(sp)
    80002d28:	e426                	sd	s1,8(sp)
    80002d2a:	e04a                	sd	s2,0(sp)
    80002d2c:	1000                	addi	s0,sp,32
    80002d2e:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002d30:	00d5d79b          	srliw	a5,a1,0xd
    80002d34:	0001e597          	auipc	a1,0x1e
    80002d38:	c205a583          	lw	a1,-992(a1) # 80020954 <sb+0x1c>
    80002d3c:	9dbd                	addw	a1,a1,a5
    80002d3e:	df1ff0ef          	jal	80002b2e <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002d42:	0074f713          	andi	a4,s1,7
    80002d46:	4785                	li	a5,1
    80002d48:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002d4c:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    80002d4e:	90d9                	srli	s1,s1,0x36
    80002d50:	00950733          	add	a4,a0,s1
    80002d54:	05874703          	lbu	a4,88(a4)
    80002d58:	00e7f6b3          	and	a3,a5,a4
    80002d5c:	c29d                	beqz	a3,80002d82 <bfree+0x60>
    80002d5e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002d60:	94aa                	add	s1,s1,a0
    80002d62:	fff7c793          	not	a5,a5
    80002d66:	8f7d                	and	a4,a4,a5
    80002d68:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002d6c:	711000ef          	jal	80003c7c <log_write>
  brelse(bp);
    80002d70:	854a                	mv	a0,s2
    80002d72:	ec5ff0ef          	jal	80002c36 <brelse>
}
    80002d76:	60e2                	ld	ra,24(sp)
    80002d78:	6442                	ld	s0,16(sp)
    80002d7a:	64a2                	ld	s1,8(sp)
    80002d7c:	6902                	ld	s2,0(sp)
    80002d7e:	6105                	addi	sp,sp,32
    80002d80:	8082                	ret
    panic("freeing free block");
    80002d82:	00004517          	auipc	a0,0x4
    80002d86:	6e650513          	addi	a0,a0,1766 # 80007468 <etext+0x468>
    80002d8a:	a15fd0ef          	jal	8000079e <panic>

0000000080002d8e <balloc>:
{
    80002d8e:	715d                	addi	sp,sp,-80
    80002d90:	e486                	sd	ra,72(sp)
    80002d92:	e0a2                	sd	s0,64(sp)
    80002d94:	fc26                	sd	s1,56(sp)
    80002d96:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    80002d98:	0001e797          	auipc	a5,0x1e
    80002d9c:	ba47a783          	lw	a5,-1116(a5) # 8002093c <sb+0x4>
    80002da0:	0e078863          	beqz	a5,80002e90 <balloc+0x102>
    80002da4:	f84a                	sd	s2,48(sp)
    80002da6:	f44e                	sd	s3,40(sp)
    80002da8:	f052                	sd	s4,32(sp)
    80002daa:	ec56                	sd	s5,24(sp)
    80002dac:	e85a                	sd	s6,16(sp)
    80002dae:	e45e                	sd	s7,8(sp)
    80002db0:	e062                	sd	s8,0(sp)
    80002db2:	8baa                	mv	s7,a0
    80002db4:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002db6:	0001eb17          	auipc	s6,0x1e
    80002dba:	b82b0b13          	addi	s6,s6,-1150 # 80020938 <sb>
      m = 1 << (bi % 8);
    80002dbe:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002dc0:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002dc2:	6c09                	lui	s8,0x2
    80002dc4:	a09d                	j	80002e2a <balloc+0x9c>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002dc6:	97ca                	add	a5,a5,s2
    80002dc8:	8e55                	or	a2,a2,a3
    80002dca:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002dce:	854a                	mv	a0,s2
    80002dd0:	6ad000ef          	jal	80003c7c <log_write>
        brelse(bp);
    80002dd4:	854a                	mv	a0,s2
    80002dd6:	e61ff0ef          	jal	80002c36 <brelse>
  bp = bread(dev, bno);
    80002dda:	85a6                	mv	a1,s1
    80002ddc:	855e                	mv	a0,s7
    80002dde:	d51ff0ef          	jal	80002b2e <bread>
    80002de2:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002de4:	40000613          	li	a2,1024
    80002de8:	4581                	li	a1,0
    80002dea:	05850513          	addi	a0,a0,88
    80002dee:	ee1fd0ef          	jal	80000cce <memset>
  log_write(bp);
    80002df2:	854a                	mv	a0,s2
    80002df4:	689000ef          	jal	80003c7c <log_write>
  brelse(bp);
    80002df8:	854a                	mv	a0,s2
    80002dfa:	e3dff0ef          	jal	80002c36 <brelse>
}
    80002dfe:	7942                	ld	s2,48(sp)
    80002e00:	79a2                	ld	s3,40(sp)
    80002e02:	7a02                	ld	s4,32(sp)
    80002e04:	6ae2                	ld	s5,24(sp)
    80002e06:	6b42                	ld	s6,16(sp)
    80002e08:	6ba2                	ld	s7,8(sp)
    80002e0a:	6c02                	ld	s8,0(sp)
}
    80002e0c:	8526                	mv	a0,s1
    80002e0e:	60a6                	ld	ra,72(sp)
    80002e10:	6406                	ld	s0,64(sp)
    80002e12:	74e2                	ld	s1,56(sp)
    80002e14:	6161                	addi	sp,sp,80
    80002e16:	8082                	ret
    brelse(bp);
    80002e18:	854a                	mv	a0,s2
    80002e1a:	e1dff0ef          	jal	80002c36 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002e1e:	015c0abb          	addw	s5,s8,s5
    80002e22:	004b2783          	lw	a5,4(s6)
    80002e26:	04fafe63          	bgeu	s5,a5,80002e82 <balloc+0xf4>
    bp = bread(dev, BBLOCK(b, sb));
    80002e2a:	41fad79b          	sraiw	a5,s5,0x1f
    80002e2e:	0137d79b          	srliw	a5,a5,0x13
    80002e32:	015787bb          	addw	a5,a5,s5
    80002e36:	40d7d79b          	sraiw	a5,a5,0xd
    80002e3a:	01cb2583          	lw	a1,28(s6)
    80002e3e:	9dbd                	addw	a1,a1,a5
    80002e40:	855e                	mv	a0,s7
    80002e42:	cedff0ef          	jal	80002b2e <bread>
    80002e46:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e48:	004b2503          	lw	a0,4(s6)
    80002e4c:	84d6                	mv	s1,s5
    80002e4e:	4701                	li	a4,0
    80002e50:	fca4f4e3          	bgeu	s1,a0,80002e18 <balloc+0x8a>
      m = 1 << (bi % 8);
    80002e54:	00777693          	andi	a3,a4,7
    80002e58:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002e5c:	41f7579b          	sraiw	a5,a4,0x1f
    80002e60:	01d7d79b          	srliw	a5,a5,0x1d
    80002e64:	9fb9                	addw	a5,a5,a4
    80002e66:	4037d79b          	sraiw	a5,a5,0x3
    80002e6a:	00f90633          	add	a2,s2,a5
    80002e6e:	05864603          	lbu	a2,88(a2)
    80002e72:	00c6f5b3          	and	a1,a3,a2
    80002e76:	d9a1                	beqz	a1,80002dc6 <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e78:	2705                	addiw	a4,a4,1
    80002e7a:	2485                	addiw	s1,s1,1
    80002e7c:	fd471ae3          	bne	a4,s4,80002e50 <balloc+0xc2>
    80002e80:	bf61                	j	80002e18 <balloc+0x8a>
    80002e82:	7942                	ld	s2,48(sp)
    80002e84:	79a2                	ld	s3,40(sp)
    80002e86:	7a02                	ld	s4,32(sp)
    80002e88:	6ae2                	ld	s5,24(sp)
    80002e8a:	6b42                	ld	s6,16(sp)
    80002e8c:	6ba2                	ld	s7,8(sp)
    80002e8e:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    80002e90:	00004517          	auipc	a0,0x4
    80002e94:	5f050513          	addi	a0,a0,1520 # 80007480 <etext+0x480>
    80002e98:	e36fd0ef          	jal	800004ce <printf>
  return 0;
    80002e9c:	4481                	li	s1,0
    80002e9e:	b7bd                	j	80002e0c <balloc+0x7e>

0000000080002ea0 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002ea0:	7179                	addi	sp,sp,-48
    80002ea2:	f406                	sd	ra,40(sp)
    80002ea4:	f022                	sd	s0,32(sp)
    80002ea6:	ec26                	sd	s1,24(sp)
    80002ea8:	e84a                	sd	s2,16(sp)
    80002eaa:	e44e                	sd	s3,8(sp)
    80002eac:	1800                	addi	s0,sp,48
    80002eae:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002eb0:	47ad                	li	a5,11
    80002eb2:	02b7e363          	bltu	a5,a1,80002ed8 <bmap+0x38>
    if((addr = ip->addrs[bn]) == 0){
    80002eb6:	02059793          	slli	a5,a1,0x20
    80002eba:	01e7d593          	srli	a1,a5,0x1e
    80002ebe:	00b504b3          	add	s1,a0,a1
    80002ec2:	0504a903          	lw	s2,80(s1)
    80002ec6:	06091363          	bnez	s2,80002f2c <bmap+0x8c>
      addr = balloc(ip->dev);
    80002eca:	4108                	lw	a0,0(a0)
    80002ecc:	ec3ff0ef          	jal	80002d8e <balloc>
    80002ed0:	892a                	mv	s2,a0
      if(addr == 0)
    80002ed2:	cd29                	beqz	a0,80002f2c <bmap+0x8c>
        return 0;
      ip->addrs[bn] = addr;
    80002ed4:	c8a8                	sw	a0,80(s1)
    80002ed6:	a899                	j	80002f2c <bmap+0x8c>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002ed8:	ff45849b          	addiw	s1,a1,-12

  if(bn < NINDIRECT){
    80002edc:	0ff00793          	li	a5,255
    80002ee0:	0697e963          	bltu	a5,s1,80002f52 <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002ee4:	08052903          	lw	s2,128(a0)
    80002ee8:	00091b63          	bnez	s2,80002efe <bmap+0x5e>
      addr = balloc(ip->dev);
    80002eec:	4108                	lw	a0,0(a0)
    80002eee:	ea1ff0ef          	jal	80002d8e <balloc>
    80002ef2:	892a                	mv	s2,a0
      if(addr == 0)
    80002ef4:	cd05                	beqz	a0,80002f2c <bmap+0x8c>
    80002ef6:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002ef8:	08a9a023          	sw	a0,128(s3)
    80002efc:	a011                	j	80002f00 <bmap+0x60>
    80002efe:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002f00:	85ca                	mv	a1,s2
    80002f02:	0009a503          	lw	a0,0(s3)
    80002f06:	c29ff0ef          	jal	80002b2e <bread>
    80002f0a:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002f0c:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002f10:	02049713          	slli	a4,s1,0x20
    80002f14:	01e75593          	srli	a1,a4,0x1e
    80002f18:	00b784b3          	add	s1,a5,a1
    80002f1c:	0004a903          	lw	s2,0(s1)
    80002f20:	00090e63          	beqz	s2,80002f3c <bmap+0x9c>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002f24:	8552                	mv	a0,s4
    80002f26:	d11ff0ef          	jal	80002c36 <brelse>
    return addr;
    80002f2a:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002f2c:	854a                	mv	a0,s2
    80002f2e:	70a2                	ld	ra,40(sp)
    80002f30:	7402                	ld	s0,32(sp)
    80002f32:	64e2                	ld	s1,24(sp)
    80002f34:	6942                	ld	s2,16(sp)
    80002f36:	69a2                	ld	s3,8(sp)
    80002f38:	6145                	addi	sp,sp,48
    80002f3a:	8082                	ret
      addr = balloc(ip->dev);
    80002f3c:	0009a503          	lw	a0,0(s3)
    80002f40:	e4fff0ef          	jal	80002d8e <balloc>
    80002f44:	892a                	mv	s2,a0
      if(addr){
    80002f46:	dd79                	beqz	a0,80002f24 <bmap+0x84>
        a[bn] = addr;
    80002f48:	c088                	sw	a0,0(s1)
        log_write(bp);
    80002f4a:	8552                	mv	a0,s4
    80002f4c:	531000ef          	jal	80003c7c <log_write>
    80002f50:	bfd1                	j	80002f24 <bmap+0x84>
    80002f52:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80002f54:	00004517          	auipc	a0,0x4
    80002f58:	54450513          	addi	a0,a0,1348 # 80007498 <etext+0x498>
    80002f5c:	843fd0ef          	jal	8000079e <panic>

0000000080002f60 <iget>:
{
    80002f60:	7179                	addi	sp,sp,-48
    80002f62:	f406                	sd	ra,40(sp)
    80002f64:	f022                	sd	s0,32(sp)
    80002f66:	ec26                	sd	s1,24(sp)
    80002f68:	e84a                	sd	s2,16(sp)
    80002f6a:	e44e                	sd	s3,8(sp)
    80002f6c:	e052                	sd	s4,0(sp)
    80002f6e:	1800                	addi	s0,sp,48
    80002f70:	89aa                	mv	s3,a0
    80002f72:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002f74:	0001e517          	auipc	a0,0x1e
    80002f78:	9e450513          	addi	a0,a0,-1564 # 80020958 <itable>
    80002f7c:	c83fd0ef          	jal	80000bfe <acquire>
  empty = 0;
    80002f80:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002f82:	0001e497          	auipc	s1,0x1e
    80002f86:	9ee48493          	addi	s1,s1,-1554 # 80020970 <itable+0x18>
    80002f8a:	0001f697          	auipc	a3,0x1f
    80002f8e:	47668693          	addi	a3,a3,1142 # 80022400 <log>
    80002f92:	a039                	j	80002fa0 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002f94:	02090963          	beqz	s2,80002fc6 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002f98:	08848493          	addi	s1,s1,136
    80002f9c:	02d48863          	beq	s1,a3,80002fcc <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80002fa0:	449c                	lw	a5,8(s1)
    80002fa2:	fef059e3          	blez	a5,80002f94 <iget+0x34>
    80002fa6:	4098                	lw	a4,0(s1)
    80002fa8:	ff3716e3          	bne	a4,s3,80002f94 <iget+0x34>
    80002fac:	40d8                	lw	a4,4(s1)
    80002fae:	ff4713e3          	bne	a4,s4,80002f94 <iget+0x34>
      ip->ref++;
    80002fb2:	2785                	addiw	a5,a5,1
    80002fb4:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002fb6:	0001e517          	auipc	a0,0x1e
    80002fba:	9a250513          	addi	a0,a0,-1630 # 80020958 <itable>
    80002fbe:	cd5fd0ef          	jal	80000c92 <release>
      return ip;
    80002fc2:	8926                	mv	s2,s1
    80002fc4:	a02d                	j	80002fee <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002fc6:	fbe9                	bnez	a5,80002f98 <iget+0x38>
      empty = ip;
    80002fc8:	8926                	mv	s2,s1
    80002fca:	b7f9                	j	80002f98 <iget+0x38>
  if(empty == 0)
    80002fcc:	02090a63          	beqz	s2,80003000 <iget+0xa0>
  ip->dev = dev;
    80002fd0:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80002fd4:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80002fd8:	4785                	li	a5,1
    80002fda:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80002fde:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80002fe2:	0001e517          	auipc	a0,0x1e
    80002fe6:	97650513          	addi	a0,a0,-1674 # 80020958 <itable>
    80002fea:	ca9fd0ef          	jal	80000c92 <release>
}
    80002fee:	854a                	mv	a0,s2
    80002ff0:	70a2                	ld	ra,40(sp)
    80002ff2:	7402                	ld	s0,32(sp)
    80002ff4:	64e2                	ld	s1,24(sp)
    80002ff6:	6942                	ld	s2,16(sp)
    80002ff8:	69a2                	ld	s3,8(sp)
    80002ffa:	6a02                	ld	s4,0(sp)
    80002ffc:	6145                	addi	sp,sp,48
    80002ffe:	8082                	ret
    panic("iget: no inodes");
    80003000:	00004517          	auipc	a0,0x4
    80003004:	4b050513          	addi	a0,a0,1200 # 800074b0 <etext+0x4b0>
    80003008:	f96fd0ef          	jal	8000079e <panic>

000000008000300c <fsinit>:
fsinit(int dev) {
    8000300c:	7179                	addi	sp,sp,-48
    8000300e:	f406                	sd	ra,40(sp)
    80003010:	f022                	sd	s0,32(sp)
    80003012:	ec26                	sd	s1,24(sp)
    80003014:	e84a                	sd	s2,16(sp)
    80003016:	e44e                	sd	s3,8(sp)
    80003018:	1800                	addi	s0,sp,48
    8000301a:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000301c:	4585                	li	a1,1
    8000301e:	b11ff0ef          	jal	80002b2e <bread>
    80003022:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003024:	0001e997          	auipc	s3,0x1e
    80003028:	91498993          	addi	s3,s3,-1772 # 80020938 <sb>
    8000302c:	02000613          	li	a2,32
    80003030:	05850593          	addi	a1,a0,88
    80003034:	854e                	mv	a0,s3
    80003036:	cfdfd0ef          	jal	80000d32 <memmove>
  brelse(bp);
    8000303a:	8526                	mv	a0,s1
    8000303c:	bfbff0ef          	jal	80002c36 <brelse>
  if(sb.magic != FSMAGIC)
    80003040:	0009a703          	lw	a4,0(s3)
    80003044:	102037b7          	lui	a5,0x10203
    80003048:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000304c:	02f71063          	bne	a4,a5,8000306c <fsinit+0x60>
  initlog(dev, &sb);
    80003050:	0001e597          	auipc	a1,0x1e
    80003054:	8e858593          	addi	a1,a1,-1816 # 80020938 <sb>
    80003058:	854a                	mv	a0,s2
    8000305a:	215000ef          	jal	80003a6e <initlog>
}
    8000305e:	70a2                	ld	ra,40(sp)
    80003060:	7402                	ld	s0,32(sp)
    80003062:	64e2                	ld	s1,24(sp)
    80003064:	6942                	ld	s2,16(sp)
    80003066:	69a2                	ld	s3,8(sp)
    80003068:	6145                	addi	sp,sp,48
    8000306a:	8082                	ret
    panic("invalid file system");
    8000306c:	00004517          	auipc	a0,0x4
    80003070:	45450513          	addi	a0,a0,1108 # 800074c0 <etext+0x4c0>
    80003074:	f2afd0ef          	jal	8000079e <panic>

0000000080003078 <iinit>:
{
    80003078:	7179                	addi	sp,sp,-48
    8000307a:	f406                	sd	ra,40(sp)
    8000307c:	f022                	sd	s0,32(sp)
    8000307e:	ec26                	sd	s1,24(sp)
    80003080:	e84a                	sd	s2,16(sp)
    80003082:	e44e                	sd	s3,8(sp)
    80003084:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003086:	00004597          	auipc	a1,0x4
    8000308a:	45258593          	addi	a1,a1,1106 # 800074d8 <etext+0x4d8>
    8000308e:	0001e517          	auipc	a0,0x1e
    80003092:	8ca50513          	addi	a0,a0,-1846 # 80020958 <itable>
    80003096:	ae5fd0ef          	jal	80000b7a <initlock>
  for(i = 0; i < NINODE; i++) {
    8000309a:	0001e497          	auipc	s1,0x1e
    8000309e:	8e648493          	addi	s1,s1,-1818 # 80020980 <itable+0x28>
    800030a2:	0001f997          	auipc	s3,0x1f
    800030a6:	36e98993          	addi	s3,s3,878 # 80022410 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800030aa:	00004917          	auipc	s2,0x4
    800030ae:	43690913          	addi	s2,s2,1078 # 800074e0 <etext+0x4e0>
    800030b2:	85ca                	mv	a1,s2
    800030b4:	8526                	mv	a0,s1
    800030b6:	497000ef          	jal	80003d4c <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800030ba:	08848493          	addi	s1,s1,136
    800030be:	ff349ae3          	bne	s1,s3,800030b2 <iinit+0x3a>
}
    800030c2:	70a2                	ld	ra,40(sp)
    800030c4:	7402                	ld	s0,32(sp)
    800030c6:	64e2                	ld	s1,24(sp)
    800030c8:	6942                	ld	s2,16(sp)
    800030ca:	69a2                	ld	s3,8(sp)
    800030cc:	6145                	addi	sp,sp,48
    800030ce:	8082                	ret

00000000800030d0 <ialloc>:
{
    800030d0:	7139                	addi	sp,sp,-64
    800030d2:	fc06                	sd	ra,56(sp)
    800030d4:	f822                	sd	s0,48(sp)
    800030d6:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800030d8:	0001e717          	auipc	a4,0x1e
    800030dc:	86c72703          	lw	a4,-1940(a4) # 80020944 <sb+0xc>
    800030e0:	4785                	li	a5,1
    800030e2:	06e7f063          	bgeu	a5,a4,80003142 <ialloc+0x72>
    800030e6:	f426                	sd	s1,40(sp)
    800030e8:	f04a                	sd	s2,32(sp)
    800030ea:	ec4e                	sd	s3,24(sp)
    800030ec:	e852                	sd	s4,16(sp)
    800030ee:	e456                	sd	s5,8(sp)
    800030f0:	e05a                	sd	s6,0(sp)
    800030f2:	8aaa                	mv	s5,a0
    800030f4:	8b2e                	mv	s6,a1
    800030f6:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    800030f8:	0001ea17          	auipc	s4,0x1e
    800030fc:	840a0a13          	addi	s4,s4,-1984 # 80020938 <sb>
    80003100:	00495593          	srli	a1,s2,0x4
    80003104:	018a2783          	lw	a5,24(s4)
    80003108:	9dbd                	addw	a1,a1,a5
    8000310a:	8556                	mv	a0,s5
    8000310c:	a23ff0ef          	jal	80002b2e <bread>
    80003110:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003112:	05850993          	addi	s3,a0,88
    80003116:	00f97793          	andi	a5,s2,15
    8000311a:	079a                	slli	a5,a5,0x6
    8000311c:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000311e:	00099783          	lh	a5,0(s3)
    80003122:	cb9d                	beqz	a5,80003158 <ialloc+0x88>
    brelse(bp);
    80003124:	b13ff0ef          	jal	80002c36 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003128:	0905                	addi	s2,s2,1
    8000312a:	00ca2703          	lw	a4,12(s4)
    8000312e:	0009079b          	sext.w	a5,s2
    80003132:	fce7e7e3          	bltu	a5,a4,80003100 <ialloc+0x30>
    80003136:	74a2                	ld	s1,40(sp)
    80003138:	7902                	ld	s2,32(sp)
    8000313a:	69e2                	ld	s3,24(sp)
    8000313c:	6a42                	ld	s4,16(sp)
    8000313e:	6aa2                	ld	s5,8(sp)
    80003140:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003142:	00004517          	auipc	a0,0x4
    80003146:	3a650513          	addi	a0,a0,934 # 800074e8 <etext+0x4e8>
    8000314a:	b84fd0ef          	jal	800004ce <printf>
  return 0;
    8000314e:	4501                	li	a0,0
}
    80003150:	70e2                	ld	ra,56(sp)
    80003152:	7442                	ld	s0,48(sp)
    80003154:	6121                	addi	sp,sp,64
    80003156:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003158:	04000613          	li	a2,64
    8000315c:	4581                	li	a1,0
    8000315e:	854e                	mv	a0,s3
    80003160:	b6ffd0ef          	jal	80000cce <memset>
      dip->type = type;
    80003164:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003168:	8526                	mv	a0,s1
    8000316a:	313000ef          	jal	80003c7c <log_write>
      brelse(bp);
    8000316e:	8526                	mv	a0,s1
    80003170:	ac7ff0ef          	jal	80002c36 <brelse>
      return iget(dev, inum);
    80003174:	0009059b          	sext.w	a1,s2
    80003178:	8556                	mv	a0,s5
    8000317a:	de7ff0ef          	jal	80002f60 <iget>
    8000317e:	74a2                	ld	s1,40(sp)
    80003180:	7902                	ld	s2,32(sp)
    80003182:	69e2                	ld	s3,24(sp)
    80003184:	6a42                	ld	s4,16(sp)
    80003186:	6aa2                	ld	s5,8(sp)
    80003188:	6b02                	ld	s6,0(sp)
    8000318a:	b7d9                	j	80003150 <ialloc+0x80>

000000008000318c <iupdate>:
{
    8000318c:	1101                	addi	sp,sp,-32
    8000318e:	ec06                	sd	ra,24(sp)
    80003190:	e822                	sd	s0,16(sp)
    80003192:	e426                	sd	s1,8(sp)
    80003194:	e04a                	sd	s2,0(sp)
    80003196:	1000                	addi	s0,sp,32
    80003198:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000319a:	415c                	lw	a5,4(a0)
    8000319c:	0047d79b          	srliw	a5,a5,0x4
    800031a0:	0001d597          	auipc	a1,0x1d
    800031a4:	7b05a583          	lw	a1,1968(a1) # 80020950 <sb+0x18>
    800031a8:	9dbd                	addw	a1,a1,a5
    800031aa:	4108                	lw	a0,0(a0)
    800031ac:	983ff0ef          	jal	80002b2e <bread>
    800031b0:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800031b2:	05850793          	addi	a5,a0,88
    800031b6:	40d8                	lw	a4,4(s1)
    800031b8:	8b3d                	andi	a4,a4,15
    800031ba:	071a                	slli	a4,a4,0x6
    800031bc:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800031be:	04449703          	lh	a4,68(s1)
    800031c2:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800031c6:	04649703          	lh	a4,70(s1)
    800031ca:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800031ce:	04849703          	lh	a4,72(s1)
    800031d2:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800031d6:	04a49703          	lh	a4,74(s1)
    800031da:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800031de:	44f8                	lw	a4,76(s1)
    800031e0:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800031e2:	03400613          	li	a2,52
    800031e6:	05048593          	addi	a1,s1,80
    800031ea:	00c78513          	addi	a0,a5,12
    800031ee:	b45fd0ef          	jal	80000d32 <memmove>
  log_write(bp);
    800031f2:	854a                	mv	a0,s2
    800031f4:	289000ef          	jal	80003c7c <log_write>
  brelse(bp);
    800031f8:	854a                	mv	a0,s2
    800031fa:	a3dff0ef          	jal	80002c36 <brelse>
}
    800031fe:	60e2                	ld	ra,24(sp)
    80003200:	6442                	ld	s0,16(sp)
    80003202:	64a2                	ld	s1,8(sp)
    80003204:	6902                	ld	s2,0(sp)
    80003206:	6105                	addi	sp,sp,32
    80003208:	8082                	ret

000000008000320a <idup>:
{
    8000320a:	1101                	addi	sp,sp,-32
    8000320c:	ec06                	sd	ra,24(sp)
    8000320e:	e822                	sd	s0,16(sp)
    80003210:	e426                	sd	s1,8(sp)
    80003212:	1000                	addi	s0,sp,32
    80003214:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003216:	0001d517          	auipc	a0,0x1d
    8000321a:	74250513          	addi	a0,a0,1858 # 80020958 <itable>
    8000321e:	9e1fd0ef          	jal	80000bfe <acquire>
  ip->ref++;
    80003222:	449c                	lw	a5,8(s1)
    80003224:	2785                	addiw	a5,a5,1
    80003226:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003228:	0001d517          	auipc	a0,0x1d
    8000322c:	73050513          	addi	a0,a0,1840 # 80020958 <itable>
    80003230:	a63fd0ef          	jal	80000c92 <release>
}
    80003234:	8526                	mv	a0,s1
    80003236:	60e2                	ld	ra,24(sp)
    80003238:	6442                	ld	s0,16(sp)
    8000323a:	64a2                	ld	s1,8(sp)
    8000323c:	6105                	addi	sp,sp,32
    8000323e:	8082                	ret

0000000080003240 <ilock>:
{
    80003240:	1101                	addi	sp,sp,-32
    80003242:	ec06                	sd	ra,24(sp)
    80003244:	e822                	sd	s0,16(sp)
    80003246:	e426                	sd	s1,8(sp)
    80003248:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000324a:	cd19                	beqz	a0,80003268 <ilock+0x28>
    8000324c:	84aa                	mv	s1,a0
    8000324e:	451c                	lw	a5,8(a0)
    80003250:	00f05c63          	blez	a5,80003268 <ilock+0x28>
  acquiresleep(&ip->lock);
    80003254:	0541                	addi	a0,a0,16
    80003256:	32d000ef          	jal	80003d82 <acquiresleep>
  if(ip->valid == 0){
    8000325a:	40bc                	lw	a5,64(s1)
    8000325c:	cf89                	beqz	a5,80003276 <ilock+0x36>
}
    8000325e:	60e2                	ld	ra,24(sp)
    80003260:	6442                	ld	s0,16(sp)
    80003262:	64a2                	ld	s1,8(sp)
    80003264:	6105                	addi	sp,sp,32
    80003266:	8082                	ret
    80003268:	e04a                	sd	s2,0(sp)
    panic("ilock");
    8000326a:	00004517          	auipc	a0,0x4
    8000326e:	29650513          	addi	a0,a0,662 # 80007500 <etext+0x500>
    80003272:	d2cfd0ef          	jal	8000079e <panic>
    80003276:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003278:	40dc                	lw	a5,4(s1)
    8000327a:	0047d79b          	srliw	a5,a5,0x4
    8000327e:	0001d597          	auipc	a1,0x1d
    80003282:	6d25a583          	lw	a1,1746(a1) # 80020950 <sb+0x18>
    80003286:	9dbd                	addw	a1,a1,a5
    80003288:	4088                	lw	a0,0(s1)
    8000328a:	8a5ff0ef          	jal	80002b2e <bread>
    8000328e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003290:	05850593          	addi	a1,a0,88
    80003294:	40dc                	lw	a5,4(s1)
    80003296:	8bbd                	andi	a5,a5,15
    80003298:	079a                	slli	a5,a5,0x6
    8000329a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000329c:	00059783          	lh	a5,0(a1)
    800032a0:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800032a4:	00259783          	lh	a5,2(a1)
    800032a8:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800032ac:	00459783          	lh	a5,4(a1)
    800032b0:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800032b4:	00659783          	lh	a5,6(a1)
    800032b8:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800032bc:	459c                	lw	a5,8(a1)
    800032be:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800032c0:	03400613          	li	a2,52
    800032c4:	05b1                	addi	a1,a1,12
    800032c6:	05048513          	addi	a0,s1,80
    800032ca:	a69fd0ef          	jal	80000d32 <memmove>
    brelse(bp);
    800032ce:	854a                	mv	a0,s2
    800032d0:	967ff0ef          	jal	80002c36 <brelse>
    ip->valid = 1;
    800032d4:	4785                	li	a5,1
    800032d6:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800032d8:	04449783          	lh	a5,68(s1)
    800032dc:	c399                	beqz	a5,800032e2 <ilock+0xa2>
    800032de:	6902                	ld	s2,0(sp)
    800032e0:	bfbd                	j	8000325e <ilock+0x1e>
      panic("ilock: no type");
    800032e2:	00004517          	auipc	a0,0x4
    800032e6:	22650513          	addi	a0,a0,550 # 80007508 <etext+0x508>
    800032ea:	cb4fd0ef          	jal	8000079e <panic>

00000000800032ee <iunlock>:
{
    800032ee:	1101                	addi	sp,sp,-32
    800032f0:	ec06                	sd	ra,24(sp)
    800032f2:	e822                	sd	s0,16(sp)
    800032f4:	e426                	sd	s1,8(sp)
    800032f6:	e04a                	sd	s2,0(sp)
    800032f8:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800032fa:	c505                	beqz	a0,80003322 <iunlock+0x34>
    800032fc:	84aa                	mv	s1,a0
    800032fe:	01050913          	addi	s2,a0,16
    80003302:	854a                	mv	a0,s2
    80003304:	2fd000ef          	jal	80003e00 <holdingsleep>
    80003308:	cd09                	beqz	a0,80003322 <iunlock+0x34>
    8000330a:	449c                	lw	a5,8(s1)
    8000330c:	00f05b63          	blez	a5,80003322 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003310:	854a                	mv	a0,s2
    80003312:	2b7000ef          	jal	80003dc8 <releasesleep>
}
    80003316:	60e2                	ld	ra,24(sp)
    80003318:	6442                	ld	s0,16(sp)
    8000331a:	64a2                	ld	s1,8(sp)
    8000331c:	6902                	ld	s2,0(sp)
    8000331e:	6105                	addi	sp,sp,32
    80003320:	8082                	ret
    panic("iunlock");
    80003322:	00004517          	auipc	a0,0x4
    80003326:	1f650513          	addi	a0,a0,502 # 80007518 <etext+0x518>
    8000332a:	c74fd0ef          	jal	8000079e <panic>

000000008000332e <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000332e:	7179                	addi	sp,sp,-48
    80003330:	f406                	sd	ra,40(sp)
    80003332:	f022                	sd	s0,32(sp)
    80003334:	ec26                	sd	s1,24(sp)
    80003336:	e84a                	sd	s2,16(sp)
    80003338:	e44e                	sd	s3,8(sp)
    8000333a:	1800                	addi	s0,sp,48
    8000333c:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000333e:	05050493          	addi	s1,a0,80
    80003342:	08050913          	addi	s2,a0,128
    80003346:	a021                	j	8000334e <itrunc+0x20>
    80003348:	0491                	addi	s1,s1,4
    8000334a:	01248b63          	beq	s1,s2,80003360 <itrunc+0x32>
    if(ip->addrs[i]){
    8000334e:	408c                	lw	a1,0(s1)
    80003350:	dde5                	beqz	a1,80003348 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003352:	0009a503          	lw	a0,0(s3)
    80003356:	9cdff0ef          	jal	80002d22 <bfree>
      ip->addrs[i] = 0;
    8000335a:	0004a023          	sw	zero,0(s1)
    8000335e:	b7ed                	j	80003348 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003360:	0809a583          	lw	a1,128(s3)
    80003364:	ed89                	bnez	a1,8000337e <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003366:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000336a:	854e                	mv	a0,s3
    8000336c:	e21ff0ef          	jal	8000318c <iupdate>
}
    80003370:	70a2                	ld	ra,40(sp)
    80003372:	7402                	ld	s0,32(sp)
    80003374:	64e2                	ld	s1,24(sp)
    80003376:	6942                	ld	s2,16(sp)
    80003378:	69a2                	ld	s3,8(sp)
    8000337a:	6145                	addi	sp,sp,48
    8000337c:	8082                	ret
    8000337e:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003380:	0009a503          	lw	a0,0(s3)
    80003384:	faaff0ef          	jal	80002b2e <bread>
    80003388:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000338a:	05850493          	addi	s1,a0,88
    8000338e:	45850913          	addi	s2,a0,1112
    80003392:	a021                	j	8000339a <itrunc+0x6c>
    80003394:	0491                	addi	s1,s1,4
    80003396:	01248963          	beq	s1,s2,800033a8 <itrunc+0x7a>
      if(a[j])
    8000339a:	408c                	lw	a1,0(s1)
    8000339c:	dde5                	beqz	a1,80003394 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    8000339e:	0009a503          	lw	a0,0(s3)
    800033a2:	981ff0ef          	jal	80002d22 <bfree>
    800033a6:	b7fd                	j	80003394 <itrunc+0x66>
    brelse(bp);
    800033a8:	8552                	mv	a0,s4
    800033aa:	88dff0ef          	jal	80002c36 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800033ae:	0809a583          	lw	a1,128(s3)
    800033b2:	0009a503          	lw	a0,0(s3)
    800033b6:	96dff0ef          	jal	80002d22 <bfree>
    ip->addrs[NDIRECT] = 0;
    800033ba:	0809a023          	sw	zero,128(s3)
    800033be:	6a02                	ld	s4,0(sp)
    800033c0:	b75d                	j	80003366 <itrunc+0x38>

00000000800033c2 <iput>:
{
    800033c2:	1101                	addi	sp,sp,-32
    800033c4:	ec06                	sd	ra,24(sp)
    800033c6:	e822                	sd	s0,16(sp)
    800033c8:	e426                	sd	s1,8(sp)
    800033ca:	1000                	addi	s0,sp,32
    800033cc:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800033ce:	0001d517          	auipc	a0,0x1d
    800033d2:	58a50513          	addi	a0,a0,1418 # 80020958 <itable>
    800033d6:	829fd0ef          	jal	80000bfe <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800033da:	4498                	lw	a4,8(s1)
    800033dc:	4785                	li	a5,1
    800033de:	02f70063          	beq	a4,a5,800033fe <iput+0x3c>
  ip->ref--;
    800033e2:	449c                	lw	a5,8(s1)
    800033e4:	37fd                	addiw	a5,a5,-1
    800033e6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800033e8:	0001d517          	auipc	a0,0x1d
    800033ec:	57050513          	addi	a0,a0,1392 # 80020958 <itable>
    800033f0:	8a3fd0ef          	jal	80000c92 <release>
}
    800033f4:	60e2                	ld	ra,24(sp)
    800033f6:	6442                	ld	s0,16(sp)
    800033f8:	64a2                	ld	s1,8(sp)
    800033fa:	6105                	addi	sp,sp,32
    800033fc:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800033fe:	40bc                	lw	a5,64(s1)
    80003400:	d3ed                	beqz	a5,800033e2 <iput+0x20>
    80003402:	04a49783          	lh	a5,74(s1)
    80003406:	fff1                	bnez	a5,800033e2 <iput+0x20>
    80003408:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    8000340a:	01048913          	addi	s2,s1,16
    8000340e:	854a                	mv	a0,s2
    80003410:	173000ef          	jal	80003d82 <acquiresleep>
    release(&itable.lock);
    80003414:	0001d517          	auipc	a0,0x1d
    80003418:	54450513          	addi	a0,a0,1348 # 80020958 <itable>
    8000341c:	877fd0ef          	jal	80000c92 <release>
    itrunc(ip);
    80003420:	8526                	mv	a0,s1
    80003422:	f0dff0ef          	jal	8000332e <itrunc>
    ip->type = 0;
    80003426:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000342a:	8526                	mv	a0,s1
    8000342c:	d61ff0ef          	jal	8000318c <iupdate>
    ip->valid = 0;
    80003430:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003434:	854a                	mv	a0,s2
    80003436:	193000ef          	jal	80003dc8 <releasesleep>
    acquire(&itable.lock);
    8000343a:	0001d517          	auipc	a0,0x1d
    8000343e:	51e50513          	addi	a0,a0,1310 # 80020958 <itable>
    80003442:	fbcfd0ef          	jal	80000bfe <acquire>
    80003446:	6902                	ld	s2,0(sp)
    80003448:	bf69                	j	800033e2 <iput+0x20>

000000008000344a <iunlockput>:
{
    8000344a:	1101                	addi	sp,sp,-32
    8000344c:	ec06                	sd	ra,24(sp)
    8000344e:	e822                	sd	s0,16(sp)
    80003450:	e426                	sd	s1,8(sp)
    80003452:	1000                	addi	s0,sp,32
    80003454:	84aa                	mv	s1,a0
  iunlock(ip);
    80003456:	e99ff0ef          	jal	800032ee <iunlock>
  iput(ip);
    8000345a:	8526                	mv	a0,s1
    8000345c:	f67ff0ef          	jal	800033c2 <iput>
}
    80003460:	60e2                	ld	ra,24(sp)
    80003462:	6442                	ld	s0,16(sp)
    80003464:	64a2                	ld	s1,8(sp)
    80003466:	6105                	addi	sp,sp,32
    80003468:	8082                	ret

000000008000346a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000346a:	1141                	addi	sp,sp,-16
    8000346c:	e406                	sd	ra,8(sp)
    8000346e:	e022                	sd	s0,0(sp)
    80003470:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003472:	411c                	lw	a5,0(a0)
    80003474:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003476:	415c                	lw	a5,4(a0)
    80003478:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000347a:	04451783          	lh	a5,68(a0)
    8000347e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003482:	04a51783          	lh	a5,74(a0)
    80003486:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000348a:	04c56783          	lwu	a5,76(a0)
    8000348e:	e99c                	sd	a5,16(a1)
}
    80003490:	60a2                	ld	ra,8(sp)
    80003492:	6402                	ld	s0,0(sp)
    80003494:	0141                	addi	sp,sp,16
    80003496:	8082                	ret

0000000080003498 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003498:	457c                	lw	a5,76(a0)
    8000349a:	0ed7e663          	bltu	a5,a3,80003586 <readi+0xee>
{
    8000349e:	7159                	addi	sp,sp,-112
    800034a0:	f486                	sd	ra,104(sp)
    800034a2:	f0a2                	sd	s0,96(sp)
    800034a4:	eca6                	sd	s1,88(sp)
    800034a6:	e0d2                	sd	s4,64(sp)
    800034a8:	fc56                	sd	s5,56(sp)
    800034aa:	f85a                	sd	s6,48(sp)
    800034ac:	f45e                	sd	s7,40(sp)
    800034ae:	1880                	addi	s0,sp,112
    800034b0:	8b2a                	mv	s6,a0
    800034b2:	8bae                	mv	s7,a1
    800034b4:	8a32                	mv	s4,a2
    800034b6:	84b6                	mv	s1,a3
    800034b8:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800034ba:	9f35                	addw	a4,a4,a3
    return 0;
    800034bc:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800034be:	0ad76b63          	bltu	a4,a3,80003574 <readi+0xdc>
    800034c2:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    800034c4:	00e7f463          	bgeu	a5,a4,800034cc <readi+0x34>
    n = ip->size - off;
    800034c8:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800034cc:	080a8b63          	beqz	s5,80003562 <readi+0xca>
    800034d0:	e8ca                	sd	s2,80(sp)
    800034d2:	f062                	sd	s8,32(sp)
    800034d4:	ec66                	sd	s9,24(sp)
    800034d6:	e86a                	sd	s10,16(sp)
    800034d8:	e46e                	sd	s11,8(sp)
    800034da:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800034dc:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800034e0:	5c7d                	li	s8,-1
    800034e2:	a80d                	j	80003514 <readi+0x7c>
    800034e4:	020d1d93          	slli	s11,s10,0x20
    800034e8:	020ddd93          	srli	s11,s11,0x20
    800034ec:	05890613          	addi	a2,s2,88
    800034f0:	86ee                	mv	a3,s11
    800034f2:	963e                	add	a2,a2,a5
    800034f4:	85d2                	mv	a1,s4
    800034f6:	855e                	mv	a0,s7
    800034f8:	d09fe0ef          	jal	80002200 <either_copyout>
    800034fc:	05850363          	beq	a0,s8,80003542 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003500:	854a                	mv	a0,s2
    80003502:	f34ff0ef          	jal	80002c36 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003506:	013d09bb          	addw	s3,s10,s3
    8000350a:	009d04bb          	addw	s1,s10,s1
    8000350e:	9a6e                	add	s4,s4,s11
    80003510:	0559f363          	bgeu	s3,s5,80003556 <readi+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003514:	00a4d59b          	srliw	a1,s1,0xa
    80003518:	855a                	mv	a0,s6
    8000351a:	987ff0ef          	jal	80002ea0 <bmap>
    8000351e:	85aa                	mv	a1,a0
    if(addr == 0)
    80003520:	c139                	beqz	a0,80003566 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003522:	000b2503          	lw	a0,0(s6)
    80003526:	e08ff0ef          	jal	80002b2e <bread>
    8000352a:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000352c:	3ff4f793          	andi	a5,s1,1023
    80003530:	40fc873b          	subw	a4,s9,a5
    80003534:	413a86bb          	subw	a3,s5,s3
    80003538:	8d3a                	mv	s10,a4
    8000353a:	fae6f5e3          	bgeu	a3,a4,800034e4 <readi+0x4c>
    8000353e:	8d36                	mv	s10,a3
    80003540:	b755                	j	800034e4 <readi+0x4c>
      brelse(bp);
    80003542:	854a                	mv	a0,s2
    80003544:	ef2ff0ef          	jal	80002c36 <brelse>
      tot = -1;
    80003548:	59fd                	li	s3,-1
      break;
    8000354a:	6946                	ld	s2,80(sp)
    8000354c:	7c02                	ld	s8,32(sp)
    8000354e:	6ce2                	ld	s9,24(sp)
    80003550:	6d42                	ld	s10,16(sp)
    80003552:	6da2                	ld	s11,8(sp)
    80003554:	a831                	j	80003570 <readi+0xd8>
    80003556:	6946                	ld	s2,80(sp)
    80003558:	7c02                	ld	s8,32(sp)
    8000355a:	6ce2                	ld	s9,24(sp)
    8000355c:	6d42                	ld	s10,16(sp)
    8000355e:	6da2                	ld	s11,8(sp)
    80003560:	a801                	j	80003570 <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003562:	89d6                	mv	s3,s5
    80003564:	a031                	j	80003570 <readi+0xd8>
    80003566:	6946                	ld	s2,80(sp)
    80003568:	7c02                	ld	s8,32(sp)
    8000356a:	6ce2                	ld	s9,24(sp)
    8000356c:	6d42                	ld	s10,16(sp)
    8000356e:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003570:	854e                	mv	a0,s3
    80003572:	69a6                	ld	s3,72(sp)
}
    80003574:	70a6                	ld	ra,104(sp)
    80003576:	7406                	ld	s0,96(sp)
    80003578:	64e6                	ld	s1,88(sp)
    8000357a:	6a06                	ld	s4,64(sp)
    8000357c:	7ae2                	ld	s5,56(sp)
    8000357e:	7b42                	ld	s6,48(sp)
    80003580:	7ba2                	ld	s7,40(sp)
    80003582:	6165                	addi	sp,sp,112
    80003584:	8082                	ret
    return 0;
    80003586:	4501                	li	a0,0
}
    80003588:	8082                	ret

000000008000358a <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000358a:	457c                	lw	a5,76(a0)
    8000358c:	0ed7eb63          	bltu	a5,a3,80003682 <writei+0xf8>
{
    80003590:	7159                	addi	sp,sp,-112
    80003592:	f486                	sd	ra,104(sp)
    80003594:	f0a2                	sd	s0,96(sp)
    80003596:	e8ca                	sd	s2,80(sp)
    80003598:	e0d2                	sd	s4,64(sp)
    8000359a:	fc56                	sd	s5,56(sp)
    8000359c:	f85a                	sd	s6,48(sp)
    8000359e:	f45e                	sd	s7,40(sp)
    800035a0:	1880                	addi	s0,sp,112
    800035a2:	8aaa                	mv	s5,a0
    800035a4:	8bae                	mv	s7,a1
    800035a6:	8a32                	mv	s4,a2
    800035a8:	8936                	mv	s2,a3
    800035aa:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800035ac:	00e687bb          	addw	a5,a3,a4
    800035b0:	0cd7eb63          	bltu	a5,a3,80003686 <writei+0xfc>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800035b4:	00043737          	lui	a4,0x43
    800035b8:	0cf76963          	bltu	a4,a5,8000368a <writei+0x100>
    800035bc:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800035be:	0a0b0a63          	beqz	s6,80003672 <writei+0xe8>
    800035c2:	eca6                	sd	s1,88(sp)
    800035c4:	f062                	sd	s8,32(sp)
    800035c6:	ec66                	sd	s9,24(sp)
    800035c8:	e86a                	sd	s10,16(sp)
    800035ca:	e46e                	sd	s11,8(sp)
    800035cc:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800035ce:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800035d2:	5c7d                	li	s8,-1
    800035d4:	a825                	j	8000360c <writei+0x82>
    800035d6:	020d1d93          	slli	s11,s10,0x20
    800035da:	020ddd93          	srli	s11,s11,0x20
    800035de:	05848513          	addi	a0,s1,88
    800035e2:	86ee                	mv	a3,s11
    800035e4:	8652                	mv	a2,s4
    800035e6:	85de                	mv	a1,s7
    800035e8:	953e                	add	a0,a0,a5
    800035ea:	c61fe0ef          	jal	8000224a <either_copyin>
    800035ee:	05850663          	beq	a0,s8,8000363a <writei+0xb0>
      brelse(bp);
      break;
    }
    log_write(bp);
    800035f2:	8526                	mv	a0,s1
    800035f4:	688000ef          	jal	80003c7c <log_write>
    brelse(bp);
    800035f8:	8526                	mv	a0,s1
    800035fa:	e3cff0ef          	jal	80002c36 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800035fe:	013d09bb          	addw	s3,s10,s3
    80003602:	012d093b          	addw	s2,s10,s2
    80003606:	9a6e                	add	s4,s4,s11
    80003608:	0369fc63          	bgeu	s3,s6,80003640 <writei+0xb6>
    uint addr = bmap(ip, off/BSIZE);
    8000360c:	00a9559b          	srliw	a1,s2,0xa
    80003610:	8556                	mv	a0,s5
    80003612:	88fff0ef          	jal	80002ea0 <bmap>
    80003616:	85aa                	mv	a1,a0
    if(addr == 0)
    80003618:	c505                	beqz	a0,80003640 <writei+0xb6>
    bp = bread(ip->dev, addr);
    8000361a:	000aa503          	lw	a0,0(s5)
    8000361e:	d10ff0ef          	jal	80002b2e <bread>
    80003622:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003624:	3ff97793          	andi	a5,s2,1023
    80003628:	40fc873b          	subw	a4,s9,a5
    8000362c:	413b06bb          	subw	a3,s6,s3
    80003630:	8d3a                	mv	s10,a4
    80003632:	fae6f2e3          	bgeu	a3,a4,800035d6 <writei+0x4c>
    80003636:	8d36                	mv	s10,a3
    80003638:	bf79                	j	800035d6 <writei+0x4c>
      brelse(bp);
    8000363a:	8526                	mv	a0,s1
    8000363c:	dfaff0ef          	jal	80002c36 <brelse>
  }

  if(off > ip->size)
    80003640:	04caa783          	lw	a5,76(s5)
    80003644:	0327f963          	bgeu	a5,s2,80003676 <writei+0xec>
    ip->size = off;
    80003648:	052aa623          	sw	s2,76(s5)
    8000364c:	64e6                	ld	s1,88(sp)
    8000364e:	7c02                	ld	s8,32(sp)
    80003650:	6ce2                	ld	s9,24(sp)
    80003652:	6d42                	ld	s10,16(sp)
    80003654:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003656:	8556                	mv	a0,s5
    80003658:	b35ff0ef          	jal	8000318c <iupdate>

  return tot;
    8000365c:	854e                	mv	a0,s3
    8000365e:	69a6                	ld	s3,72(sp)
}
    80003660:	70a6                	ld	ra,104(sp)
    80003662:	7406                	ld	s0,96(sp)
    80003664:	6946                	ld	s2,80(sp)
    80003666:	6a06                	ld	s4,64(sp)
    80003668:	7ae2                	ld	s5,56(sp)
    8000366a:	7b42                	ld	s6,48(sp)
    8000366c:	7ba2                	ld	s7,40(sp)
    8000366e:	6165                	addi	sp,sp,112
    80003670:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003672:	89da                	mv	s3,s6
    80003674:	b7cd                	j	80003656 <writei+0xcc>
    80003676:	64e6                	ld	s1,88(sp)
    80003678:	7c02                	ld	s8,32(sp)
    8000367a:	6ce2                	ld	s9,24(sp)
    8000367c:	6d42                	ld	s10,16(sp)
    8000367e:	6da2                	ld	s11,8(sp)
    80003680:	bfd9                	j	80003656 <writei+0xcc>
    return -1;
    80003682:	557d                	li	a0,-1
}
    80003684:	8082                	ret
    return -1;
    80003686:	557d                	li	a0,-1
    80003688:	bfe1                	j	80003660 <writei+0xd6>
    return -1;
    8000368a:	557d                	li	a0,-1
    8000368c:	bfd1                	j	80003660 <writei+0xd6>

000000008000368e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000368e:	1141                	addi	sp,sp,-16
    80003690:	e406                	sd	ra,8(sp)
    80003692:	e022                	sd	s0,0(sp)
    80003694:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003696:	4639                	li	a2,14
    80003698:	f0efd0ef          	jal	80000da6 <strncmp>
}
    8000369c:	60a2                	ld	ra,8(sp)
    8000369e:	6402                	ld	s0,0(sp)
    800036a0:	0141                	addi	sp,sp,16
    800036a2:	8082                	ret

00000000800036a4 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800036a4:	711d                	addi	sp,sp,-96
    800036a6:	ec86                	sd	ra,88(sp)
    800036a8:	e8a2                	sd	s0,80(sp)
    800036aa:	e4a6                	sd	s1,72(sp)
    800036ac:	e0ca                	sd	s2,64(sp)
    800036ae:	fc4e                	sd	s3,56(sp)
    800036b0:	f852                	sd	s4,48(sp)
    800036b2:	f456                	sd	s5,40(sp)
    800036b4:	f05a                	sd	s6,32(sp)
    800036b6:	ec5e                	sd	s7,24(sp)
    800036b8:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800036ba:	04451703          	lh	a4,68(a0)
    800036be:	4785                	li	a5,1
    800036c0:	00f71f63          	bne	a4,a5,800036de <dirlookup+0x3a>
    800036c4:	892a                	mv	s2,a0
    800036c6:	8aae                	mv	s5,a1
    800036c8:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800036ca:	457c                	lw	a5,76(a0)
    800036cc:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800036ce:	fa040a13          	addi	s4,s0,-96
    800036d2:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    800036d4:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800036d8:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800036da:	e39d                	bnez	a5,80003700 <dirlookup+0x5c>
    800036dc:	a8b9                	j	8000373a <dirlookup+0x96>
    panic("dirlookup not DIR");
    800036de:	00004517          	auipc	a0,0x4
    800036e2:	e4250513          	addi	a0,a0,-446 # 80007520 <etext+0x520>
    800036e6:	8b8fd0ef          	jal	8000079e <panic>
      panic("dirlookup read");
    800036ea:	00004517          	auipc	a0,0x4
    800036ee:	e4e50513          	addi	a0,a0,-434 # 80007538 <etext+0x538>
    800036f2:	8acfd0ef          	jal	8000079e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800036f6:	24c1                	addiw	s1,s1,16
    800036f8:	04c92783          	lw	a5,76(s2)
    800036fc:	02f4fe63          	bgeu	s1,a5,80003738 <dirlookup+0x94>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003700:	874e                	mv	a4,s3
    80003702:	86a6                	mv	a3,s1
    80003704:	8652                	mv	a2,s4
    80003706:	4581                	li	a1,0
    80003708:	854a                	mv	a0,s2
    8000370a:	d8fff0ef          	jal	80003498 <readi>
    8000370e:	fd351ee3          	bne	a0,s3,800036ea <dirlookup+0x46>
    if(de.inum == 0)
    80003712:	fa045783          	lhu	a5,-96(s0)
    80003716:	d3e5                	beqz	a5,800036f6 <dirlookup+0x52>
    if(namecmp(name, de.name) == 0){
    80003718:	85da                	mv	a1,s6
    8000371a:	8556                	mv	a0,s5
    8000371c:	f73ff0ef          	jal	8000368e <namecmp>
    80003720:	f979                	bnez	a0,800036f6 <dirlookup+0x52>
      if(poff)
    80003722:	000b8463          	beqz	s7,8000372a <dirlookup+0x86>
        *poff = off;
    80003726:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    8000372a:	fa045583          	lhu	a1,-96(s0)
    8000372e:	00092503          	lw	a0,0(s2)
    80003732:	82fff0ef          	jal	80002f60 <iget>
    80003736:	a011                	j	8000373a <dirlookup+0x96>
  return 0;
    80003738:	4501                	li	a0,0
}
    8000373a:	60e6                	ld	ra,88(sp)
    8000373c:	6446                	ld	s0,80(sp)
    8000373e:	64a6                	ld	s1,72(sp)
    80003740:	6906                	ld	s2,64(sp)
    80003742:	79e2                	ld	s3,56(sp)
    80003744:	7a42                	ld	s4,48(sp)
    80003746:	7aa2                	ld	s5,40(sp)
    80003748:	7b02                	ld	s6,32(sp)
    8000374a:	6be2                	ld	s7,24(sp)
    8000374c:	6125                	addi	sp,sp,96
    8000374e:	8082                	ret

0000000080003750 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003750:	711d                	addi	sp,sp,-96
    80003752:	ec86                	sd	ra,88(sp)
    80003754:	e8a2                	sd	s0,80(sp)
    80003756:	e4a6                	sd	s1,72(sp)
    80003758:	e0ca                	sd	s2,64(sp)
    8000375a:	fc4e                	sd	s3,56(sp)
    8000375c:	f852                	sd	s4,48(sp)
    8000375e:	f456                	sd	s5,40(sp)
    80003760:	f05a                	sd	s6,32(sp)
    80003762:	ec5e                	sd	s7,24(sp)
    80003764:	e862                	sd	s8,16(sp)
    80003766:	e466                	sd	s9,8(sp)
    80003768:	e06a                	sd	s10,0(sp)
    8000376a:	1080                	addi	s0,sp,96
    8000376c:	84aa                	mv	s1,a0
    8000376e:	8b2e                	mv	s6,a1
    80003770:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003772:	00054703          	lbu	a4,0(a0)
    80003776:	02f00793          	li	a5,47
    8000377a:	00f70f63          	beq	a4,a5,80003798 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000377e:	95efe0ef          	jal	800018dc <myproc>
    80003782:	15053503          	ld	a0,336(a0)
    80003786:	a85ff0ef          	jal	8000320a <idup>
    8000378a:	8a2a                	mv	s4,a0
  while(*path == '/')
    8000378c:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003790:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003792:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003794:	4b85                	li	s7,1
    80003796:	a879                	j	80003834 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80003798:	4585                	li	a1,1
    8000379a:	852e                	mv	a0,a1
    8000379c:	fc4ff0ef          	jal	80002f60 <iget>
    800037a0:	8a2a                	mv	s4,a0
    800037a2:	b7ed                	j	8000378c <namex+0x3c>
      iunlockput(ip);
    800037a4:	8552                	mv	a0,s4
    800037a6:	ca5ff0ef          	jal	8000344a <iunlockput>
      return 0;
    800037aa:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800037ac:	8552                	mv	a0,s4
    800037ae:	60e6                	ld	ra,88(sp)
    800037b0:	6446                	ld	s0,80(sp)
    800037b2:	64a6                	ld	s1,72(sp)
    800037b4:	6906                	ld	s2,64(sp)
    800037b6:	79e2                	ld	s3,56(sp)
    800037b8:	7a42                	ld	s4,48(sp)
    800037ba:	7aa2                	ld	s5,40(sp)
    800037bc:	7b02                	ld	s6,32(sp)
    800037be:	6be2                	ld	s7,24(sp)
    800037c0:	6c42                	ld	s8,16(sp)
    800037c2:	6ca2                	ld	s9,8(sp)
    800037c4:	6d02                	ld	s10,0(sp)
    800037c6:	6125                	addi	sp,sp,96
    800037c8:	8082                	ret
      iunlock(ip);
    800037ca:	8552                	mv	a0,s4
    800037cc:	b23ff0ef          	jal	800032ee <iunlock>
      return ip;
    800037d0:	bff1                	j	800037ac <namex+0x5c>
      iunlockput(ip);
    800037d2:	8552                	mv	a0,s4
    800037d4:	c77ff0ef          	jal	8000344a <iunlockput>
      return 0;
    800037d8:	8a4e                	mv	s4,s3
    800037da:	bfc9                	j	800037ac <namex+0x5c>
  len = path - s;
    800037dc:	40998633          	sub	a2,s3,s1
    800037e0:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    800037e4:	09ac5063          	bge	s8,s10,80003864 <namex+0x114>
    memmove(name, s, DIRSIZ);
    800037e8:	8666                	mv	a2,s9
    800037ea:	85a6                	mv	a1,s1
    800037ec:	8556                	mv	a0,s5
    800037ee:	d44fd0ef          	jal	80000d32 <memmove>
    800037f2:	84ce                	mv	s1,s3
  while(*path == '/')
    800037f4:	0004c783          	lbu	a5,0(s1)
    800037f8:	01279763          	bne	a5,s2,80003806 <namex+0xb6>
    path++;
    800037fc:	0485                	addi	s1,s1,1
  while(*path == '/')
    800037fe:	0004c783          	lbu	a5,0(s1)
    80003802:	ff278de3          	beq	a5,s2,800037fc <namex+0xac>
    ilock(ip);
    80003806:	8552                	mv	a0,s4
    80003808:	a39ff0ef          	jal	80003240 <ilock>
    if(ip->type != T_DIR){
    8000380c:	044a1783          	lh	a5,68(s4)
    80003810:	f9779ae3          	bne	a5,s7,800037a4 <namex+0x54>
    if(nameiparent && *path == '\0'){
    80003814:	000b0563          	beqz	s6,8000381e <namex+0xce>
    80003818:	0004c783          	lbu	a5,0(s1)
    8000381c:	d7dd                	beqz	a5,800037ca <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000381e:	4601                	li	a2,0
    80003820:	85d6                	mv	a1,s5
    80003822:	8552                	mv	a0,s4
    80003824:	e81ff0ef          	jal	800036a4 <dirlookup>
    80003828:	89aa                	mv	s3,a0
    8000382a:	d545                	beqz	a0,800037d2 <namex+0x82>
    iunlockput(ip);
    8000382c:	8552                	mv	a0,s4
    8000382e:	c1dff0ef          	jal	8000344a <iunlockput>
    ip = next;
    80003832:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003834:	0004c783          	lbu	a5,0(s1)
    80003838:	01279763          	bne	a5,s2,80003846 <namex+0xf6>
    path++;
    8000383c:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000383e:	0004c783          	lbu	a5,0(s1)
    80003842:	ff278de3          	beq	a5,s2,8000383c <namex+0xec>
  if(*path == 0)
    80003846:	cb8d                	beqz	a5,80003878 <namex+0x128>
  while(*path != '/' && *path != 0)
    80003848:	0004c783          	lbu	a5,0(s1)
    8000384c:	89a6                	mv	s3,s1
  len = path - s;
    8000384e:	4d01                	li	s10,0
    80003850:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003852:	01278963          	beq	a5,s2,80003864 <namex+0x114>
    80003856:	d3d9                	beqz	a5,800037dc <namex+0x8c>
    path++;
    80003858:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    8000385a:	0009c783          	lbu	a5,0(s3)
    8000385e:	ff279ce3          	bne	a5,s2,80003856 <namex+0x106>
    80003862:	bfad                	j	800037dc <namex+0x8c>
    memmove(name, s, len);
    80003864:	2601                	sext.w	a2,a2
    80003866:	85a6                	mv	a1,s1
    80003868:	8556                	mv	a0,s5
    8000386a:	cc8fd0ef          	jal	80000d32 <memmove>
    name[len] = 0;
    8000386e:	9d56                	add	s10,s10,s5
    80003870:	000d0023          	sb	zero,0(s10)
    80003874:	84ce                	mv	s1,s3
    80003876:	bfbd                	j	800037f4 <namex+0xa4>
  if(nameiparent){
    80003878:	f20b0ae3          	beqz	s6,800037ac <namex+0x5c>
    iput(ip);
    8000387c:	8552                	mv	a0,s4
    8000387e:	b45ff0ef          	jal	800033c2 <iput>
    return 0;
    80003882:	4a01                	li	s4,0
    80003884:	b725                	j	800037ac <namex+0x5c>

0000000080003886 <dirlink>:
{
    80003886:	715d                	addi	sp,sp,-80
    80003888:	e486                	sd	ra,72(sp)
    8000388a:	e0a2                	sd	s0,64(sp)
    8000388c:	f84a                	sd	s2,48(sp)
    8000388e:	ec56                	sd	s5,24(sp)
    80003890:	e85a                	sd	s6,16(sp)
    80003892:	0880                	addi	s0,sp,80
    80003894:	892a                	mv	s2,a0
    80003896:	8aae                	mv	s5,a1
    80003898:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000389a:	4601                	li	a2,0
    8000389c:	e09ff0ef          	jal	800036a4 <dirlookup>
    800038a0:	ed1d                	bnez	a0,800038de <dirlink+0x58>
    800038a2:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    800038a4:	04c92483          	lw	s1,76(s2)
    800038a8:	c4b9                	beqz	s1,800038f6 <dirlink+0x70>
    800038aa:	f44e                	sd	s3,40(sp)
    800038ac:	f052                	sd	s4,32(sp)
    800038ae:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800038b0:	fb040a13          	addi	s4,s0,-80
    800038b4:	49c1                	li	s3,16
    800038b6:	874e                	mv	a4,s3
    800038b8:	86a6                	mv	a3,s1
    800038ba:	8652                	mv	a2,s4
    800038bc:	4581                	li	a1,0
    800038be:	854a                	mv	a0,s2
    800038c0:	bd9ff0ef          	jal	80003498 <readi>
    800038c4:	03351163          	bne	a0,s3,800038e6 <dirlink+0x60>
    if(de.inum == 0)
    800038c8:	fb045783          	lhu	a5,-80(s0)
    800038cc:	c39d                	beqz	a5,800038f2 <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800038ce:	24c1                	addiw	s1,s1,16
    800038d0:	04c92783          	lw	a5,76(s2)
    800038d4:	fef4e1e3          	bltu	s1,a5,800038b6 <dirlink+0x30>
    800038d8:	79a2                	ld	s3,40(sp)
    800038da:	7a02                	ld	s4,32(sp)
    800038dc:	a829                	j	800038f6 <dirlink+0x70>
    iput(ip);
    800038de:	ae5ff0ef          	jal	800033c2 <iput>
    return -1;
    800038e2:	557d                	li	a0,-1
    800038e4:	a83d                	j	80003922 <dirlink+0x9c>
      panic("dirlink read");
    800038e6:	00004517          	auipc	a0,0x4
    800038ea:	c6250513          	addi	a0,a0,-926 # 80007548 <etext+0x548>
    800038ee:	eb1fc0ef          	jal	8000079e <panic>
    800038f2:	79a2                	ld	s3,40(sp)
    800038f4:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    800038f6:	4639                	li	a2,14
    800038f8:	85d6                	mv	a1,s5
    800038fa:	fb240513          	addi	a0,s0,-78
    800038fe:	ce2fd0ef          	jal	80000de0 <strncpy>
  de.inum = inum;
    80003902:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003906:	4741                	li	a4,16
    80003908:	86a6                	mv	a3,s1
    8000390a:	fb040613          	addi	a2,s0,-80
    8000390e:	4581                	li	a1,0
    80003910:	854a                	mv	a0,s2
    80003912:	c79ff0ef          	jal	8000358a <writei>
    80003916:	1541                	addi	a0,a0,-16
    80003918:	00a03533          	snez	a0,a0
    8000391c:	40a0053b          	negw	a0,a0
    80003920:	74e2                	ld	s1,56(sp)
}
    80003922:	60a6                	ld	ra,72(sp)
    80003924:	6406                	ld	s0,64(sp)
    80003926:	7942                	ld	s2,48(sp)
    80003928:	6ae2                	ld	s5,24(sp)
    8000392a:	6b42                	ld	s6,16(sp)
    8000392c:	6161                	addi	sp,sp,80
    8000392e:	8082                	ret

0000000080003930 <namei>:

struct inode*
namei(char *path)
{
    80003930:	1101                	addi	sp,sp,-32
    80003932:	ec06                	sd	ra,24(sp)
    80003934:	e822                	sd	s0,16(sp)
    80003936:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003938:	fe040613          	addi	a2,s0,-32
    8000393c:	4581                	li	a1,0
    8000393e:	e13ff0ef          	jal	80003750 <namex>
}
    80003942:	60e2                	ld	ra,24(sp)
    80003944:	6442                	ld	s0,16(sp)
    80003946:	6105                	addi	sp,sp,32
    80003948:	8082                	ret

000000008000394a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000394a:	1141                	addi	sp,sp,-16
    8000394c:	e406                	sd	ra,8(sp)
    8000394e:	e022                	sd	s0,0(sp)
    80003950:	0800                	addi	s0,sp,16
    80003952:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003954:	4585                	li	a1,1
    80003956:	dfbff0ef          	jal	80003750 <namex>
}
    8000395a:	60a2                	ld	ra,8(sp)
    8000395c:	6402                	ld	s0,0(sp)
    8000395e:	0141                	addi	sp,sp,16
    80003960:	8082                	ret

0000000080003962 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003962:	1101                	addi	sp,sp,-32
    80003964:	ec06                	sd	ra,24(sp)
    80003966:	e822                	sd	s0,16(sp)
    80003968:	e426                	sd	s1,8(sp)
    8000396a:	e04a                	sd	s2,0(sp)
    8000396c:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000396e:	0001f917          	auipc	s2,0x1f
    80003972:	a9290913          	addi	s2,s2,-1390 # 80022400 <log>
    80003976:	01892583          	lw	a1,24(s2)
    8000397a:	02892503          	lw	a0,40(s2)
    8000397e:	9b0ff0ef          	jal	80002b2e <bread>
    80003982:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003984:	02c92603          	lw	a2,44(s2)
    80003988:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000398a:	00c05f63          	blez	a2,800039a8 <write_head+0x46>
    8000398e:	0001f717          	auipc	a4,0x1f
    80003992:	aa270713          	addi	a4,a4,-1374 # 80022430 <log+0x30>
    80003996:	87aa                	mv	a5,a0
    80003998:	060a                	slli	a2,a2,0x2
    8000399a:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    8000399c:	4314                	lw	a3,0(a4)
    8000399e:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    800039a0:	0711                	addi	a4,a4,4
    800039a2:	0791                	addi	a5,a5,4
    800039a4:	fec79ce3          	bne	a5,a2,8000399c <write_head+0x3a>
  }
  bwrite(buf);
    800039a8:	8526                	mv	a0,s1
    800039aa:	a5aff0ef          	jal	80002c04 <bwrite>
  brelse(buf);
    800039ae:	8526                	mv	a0,s1
    800039b0:	a86ff0ef          	jal	80002c36 <brelse>
}
    800039b4:	60e2                	ld	ra,24(sp)
    800039b6:	6442                	ld	s0,16(sp)
    800039b8:	64a2                	ld	s1,8(sp)
    800039ba:	6902                	ld	s2,0(sp)
    800039bc:	6105                	addi	sp,sp,32
    800039be:	8082                	ret

00000000800039c0 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800039c0:	0001f797          	auipc	a5,0x1f
    800039c4:	a6c7a783          	lw	a5,-1428(a5) # 8002242c <log+0x2c>
    800039c8:	0af05263          	blez	a5,80003a6c <install_trans+0xac>
{
    800039cc:	715d                	addi	sp,sp,-80
    800039ce:	e486                	sd	ra,72(sp)
    800039d0:	e0a2                	sd	s0,64(sp)
    800039d2:	fc26                	sd	s1,56(sp)
    800039d4:	f84a                	sd	s2,48(sp)
    800039d6:	f44e                	sd	s3,40(sp)
    800039d8:	f052                	sd	s4,32(sp)
    800039da:	ec56                	sd	s5,24(sp)
    800039dc:	e85a                	sd	s6,16(sp)
    800039de:	e45e                	sd	s7,8(sp)
    800039e0:	0880                	addi	s0,sp,80
    800039e2:	8b2a                	mv	s6,a0
    800039e4:	0001fa97          	auipc	s5,0x1f
    800039e8:	a4ca8a93          	addi	s5,s5,-1460 # 80022430 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800039ec:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800039ee:	0001f997          	auipc	s3,0x1f
    800039f2:	a1298993          	addi	s3,s3,-1518 # 80022400 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800039f6:	40000b93          	li	s7,1024
    800039fa:	a829                	j	80003a14 <install_trans+0x54>
    brelse(lbuf);
    800039fc:	854a                	mv	a0,s2
    800039fe:	a38ff0ef          	jal	80002c36 <brelse>
    brelse(dbuf);
    80003a02:	8526                	mv	a0,s1
    80003a04:	a32ff0ef          	jal	80002c36 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003a08:	2a05                	addiw	s4,s4,1
    80003a0a:	0a91                	addi	s5,s5,4
    80003a0c:	02c9a783          	lw	a5,44(s3)
    80003a10:	04fa5363          	bge	s4,a5,80003a56 <install_trans+0x96>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003a14:	0189a583          	lw	a1,24(s3)
    80003a18:	014585bb          	addw	a1,a1,s4
    80003a1c:	2585                	addiw	a1,a1,1
    80003a1e:	0289a503          	lw	a0,40(s3)
    80003a22:	90cff0ef          	jal	80002b2e <bread>
    80003a26:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003a28:	000aa583          	lw	a1,0(s5)
    80003a2c:	0289a503          	lw	a0,40(s3)
    80003a30:	8feff0ef          	jal	80002b2e <bread>
    80003a34:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003a36:	865e                	mv	a2,s7
    80003a38:	05890593          	addi	a1,s2,88
    80003a3c:	05850513          	addi	a0,a0,88
    80003a40:	af2fd0ef          	jal	80000d32 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003a44:	8526                	mv	a0,s1
    80003a46:	9beff0ef          	jal	80002c04 <bwrite>
    if(recovering == 0)
    80003a4a:	fa0b19e3          	bnez	s6,800039fc <install_trans+0x3c>
      bunpin(dbuf);
    80003a4e:	8526                	mv	a0,s1
    80003a50:	a9eff0ef          	jal	80002cee <bunpin>
    80003a54:	b765                	j	800039fc <install_trans+0x3c>
}
    80003a56:	60a6                	ld	ra,72(sp)
    80003a58:	6406                	ld	s0,64(sp)
    80003a5a:	74e2                	ld	s1,56(sp)
    80003a5c:	7942                	ld	s2,48(sp)
    80003a5e:	79a2                	ld	s3,40(sp)
    80003a60:	7a02                	ld	s4,32(sp)
    80003a62:	6ae2                	ld	s5,24(sp)
    80003a64:	6b42                	ld	s6,16(sp)
    80003a66:	6ba2                	ld	s7,8(sp)
    80003a68:	6161                	addi	sp,sp,80
    80003a6a:	8082                	ret
    80003a6c:	8082                	ret

0000000080003a6e <initlog>:
{
    80003a6e:	7179                	addi	sp,sp,-48
    80003a70:	f406                	sd	ra,40(sp)
    80003a72:	f022                	sd	s0,32(sp)
    80003a74:	ec26                	sd	s1,24(sp)
    80003a76:	e84a                	sd	s2,16(sp)
    80003a78:	e44e                	sd	s3,8(sp)
    80003a7a:	1800                	addi	s0,sp,48
    80003a7c:	892a                	mv	s2,a0
    80003a7e:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003a80:	0001f497          	auipc	s1,0x1f
    80003a84:	98048493          	addi	s1,s1,-1664 # 80022400 <log>
    80003a88:	00004597          	auipc	a1,0x4
    80003a8c:	ad058593          	addi	a1,a1,-1328 # 80007558 <etext+0x558>
    80003a90:	8526                	mv	a0,s1
    80003a92:	8e8fd0ef          	jal	80000b7a <initlock>
  log.start = sb->logstart;
    80003a96:	0149a583          	lw	a1,20(s3)
    80003a9a:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003a9c:	0109a783          	lw	a5,16(s3)
    80003aa0:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003aa2:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003aa6:	854a                	mv	a0,s2
    80003aa8:	886ff0ef          	jal	80002b2e <bread>
  log.lh.n = lh->n;
    80003aac:	4d30                	lw	a2,88(a0)
    80003aae:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003ab0:	00c05f63          	blez	a2,80003ace <initlog+0x60>
    80003ab4:	87aa                	mv	a5,a0
    80003ab6:	0001f717          	auipc	a4,0x1f
    80003aba:	97a70713          	addi	a4,a4,-1670 # 80022430 <log+0x30>
    80003abe:	060a                	slli	a2,a2,0x2
    80003ac0:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003ac2:	4ff4                	lw	a3,92(a5)
    80003ac4:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003ac6:	0791                	addi	a5,a5,4
    80003ac8:	0711                	addi	a4,a4,4
    80003aca:	fec79ce3          	bne	a5,a2,80003ac2 <initlog+0x54>
  brelse(buf);
    80003ace:	968ff0ef          	jal	80002c36 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003ad2:	4505                	li	a0,1
    80003ad4:	eedff0ef          	jal	800039c0 <install_trans>
  log.lh.n = 0;
    80003ad8:	0001f797          	auipc	a5,0x1f
    80003adc:	9407aa23          	sw	zero,-1708(a5) # 8002242c <log+0x2c>
  write_head(); // clear the log
    80003ae0:	e83ff0ef          	jal	80003962 <write_head>
}
    80003ae4:	70a2                	ld	ra,40(sp)
    80003ae6:	7402                	ld	s0,32(sp)
    80003ae8:	64e2                	ld	s1,24(sp)
    80003aea:	6942                	ld	s2,16(sp)
    80003aec:	69a2                	ld	s3,8(sp)
    80003aee:	6145                	addi	sp,sp,48
    80003af0:	8082                	ret

0000000080003af2 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003af2:	1101                	addi	sp,sp,-32
    80003af4:	ec06                	sd	ra,24(sp)
    80003af6:	e822                	sd	s0,16(sp)
    80003af8:	e426                	sd	s1,8(sp)
    80003afa:	e04a                	sd	s2,0(sp)
    80003afc:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003afe:	0001f517          	auipc	a0,0x1f
    80003b02:	90250513          	addi	a0,a0,-1790 # 80022400 <log>
    80003b06:	8f8fd0ef          	jal	80000bfe <acquire>
  while(1){
    if(log.committing){
    80003b0a:	0001f497          	auipc	s1,0x1f
    80003b0e:	8f648493          	addi	s1,s1,-1802 # 80022400 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003b12:	4979                	li	s2,30
    80003b14:	a029                	j	80003b1e <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003b16:	85a6                	mv	a1,s1
    80003b18:	8526                	mv	a0,s1
    80003b1a:	b90fe0ef          	jal	80001eaa <sleep>
    if(log.committing){
    80003b1e:	50dc                	lw	a5,36(s1)
    80003b20:	fbfd                	bnez	a5,80003b16 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003b22:	5098                	lw	a4,32(s1)
    80003b24:	2705                	addiw	a4,a4,1
    80003b26:	0027179b          	slliw	a5,a4,0x2
    80003b2a:	9fb9                	addw	a5,a5,a4
    80003b2c:	0017979b          	slliw	a5,a5,0x1
    80003b30:	54d4                	lw	a3,44(s1)
    80003b32:	9fb5                	addw	a5,a5,a3
    80003b34:	00f95763          	bge	s2,a5,80003b42 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003b38:	85a6                	mv	a1,s1
    80003b3a:	8526                	mv	a0,s1
    80003b3c:	b6efe0ef          	jal	80001eaa <sleep>
    80003b40:	bff9                	j	80003b1e <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003b42:	0001f517          	auipc	a0,0x1f
    80003b46:	8be50513          	addi	a0,a0,-1858 # 80022400 <log>
    80003b4a:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80003b4c:	946fd0ef          	jal	80000c92 <release>
      break;
    }
  }
}
    80003b50:	60e2                	ld	ra,24(sp)
    80003b52:	6442                	ld	s0,16(sp)
    80003b54:	64a2                	ld	s1,8(sp)
    80003b56:	6902                	ld	s2,0(sp)
    80003b58:	6105                	addi	sp,sp,32
    80003b5a:	8082                	ret

0000000080003b5c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003b5c:	7139                	addi	sp,sp,-64
    80003b5e:	fc06                	sd	ra,56(sp)
    80003b60:	f822                	sd	s0,48(sp)
    80003b62:	f426                	sd	s1,40(sp)
    80003b64:	f04a                	sd	s2,32(sp)
    80003b66:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003b68:	0001f497          	auipc	s1,0x1f
    80003b6c:	89848493          	addi	s1,s1,-1896 # 80022400 <log>
    80003b70:	8526                	mv	a0,s1
    80003b72:	88cfd0ef          	jal	80000bfe <acquire>
  log.outstanding -= 1;
    80003b76:	509c                	lw	a5,32(s1)
    80003b78:	37fd                	addiw	a5,a5,-1
    80003b7a:	893e                	mv	s2,a5
    80003b7c:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003b7e:	50dc                	lw	a5,36(s1)
    80003b80:	ef9d                	bnez	a5,80003bbe <end_op+0x62>
    panic("log.committing");
  if(log.outstanding == 0){
    80003b82:	04091863          	bnez	s2,80003bd2 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003b86:	0001f497          	auipc	s1,0x1f
    80003b8a:	87a48493          	addi	s1,s1,-1926 # 80022400 <log>
    80003b8e:	4785                	li	a5,1
    80003b90:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003b92:	8526                	mv	a0,s1
    80003b94:	8fefd0ef          	jal	80000c92 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003b98:	54dc                	lw	a5,44(s1)
    80003b9a:	04f04c63          	bgtz	a5,80003bf2 <end_op+0x96>
    acquire(&log.lock);
    80003b9e:	0001f497          	auipc	s1,0x1f
    80003ba2:	86248493          	addi	s1,s1,-1950 # 80022400 <log>
    80003ba6:	8526                	mv	a0,s1
    80003ba8:	856fd0ef          	jal	80000bfe <acquire>
    log.committing = 0;
    80003bac:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003bb0:	8526                	mv	a0,s1
    80003bb2:	b44fe0ef          	jal	80001ef6 <wakeup>
    release(&log.lock);
    80003bb6:	8526                	mv	a0,s1
    80003bb8:	8dafd0ef          	jal	80000c92 <release>
}
    80003bbc:	a02d                	j	80003be6 <end_op+0x8a>
    80003bbe:	ec4e                	sd	s3,24(sp)
    80003bc0:	e852                	sd	s4,16(sp)
    80003bc2:	e456                	sd	s5,8(sp)
    80003bc4:	e05a                	sd	s6,0(sp)
    panic("log.committing");
    80003bc6:	00004517          	auipc	a0,0x4
    80003bca:	99a50513          	addi	a0,a0,-1638 # 80007560 <etext+0x560>
    80003bce:	bd1fc0ef          	jal	8000079e <panic>
    wakeup(&log);
    80003bd2:	0001f497          	auipc	s1,0x1f
    80003bd6:	82e48493          	addi	s1,s1,-2002 # 80022400 <log>
    80003bda:	8526                	mv	a0,s1
    80003bdc:	b1afe0ef          	jal	80001ef6 <wakeup>
  release(&log.lock);
    80003be0:	8526                	mv	a0,s1
    80003be2:	8b0fd0ef          	jal	80000c92 <release>
}
    80003be6:	70e2                	ld	ra,56(sp)
    80003be8:	7442                	ld	s0,48(sp)
    80003bea:	74a2                	ld	s1,40(sp)
    80003bec:	7902                	ld	s2,32(sp)
    80003bee:	6121                	addi	sp,sp,64
    80003bf0:	8082                	ret
    80003bf2:	ec4e                	sd	s3,24(sp)
    80003bf4:	e852                	sd	s4,16(sp)
    80003bf6:	e456                	sd	s5,8(sp)
    80003bf8:	e05a                	sd	s6,0(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003bfa:	0001fa97          	auipc	s5,0x1f
    80003bfe:	836a8a93          	addi	s5,s5,-1994 # 80022430 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003c02:	0001ea17          	auipc	s4,0x1e
    80003c06:	7fea0a13          	addi	s4,s4,2046 # 80022400 <log>
    memmove(to->data, from->data, BSIZE);
    80003c0a:	40000b13          	li	s6,1024
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003c0e:	018a2583          	lw	a1,24(s4)
    80003c12:	012585bb          	addw	a1,a1,s2
    80003c16:	2585                	addiw	a1,a1,1
    80003c18:	028a2503          	lw	a0,40(s4)
    80003c1c:	f13fe0ef          	jal	80002b2e <bread>
    80003c20:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003c22:	000aa583          	lw	a1,0(s5)
    80003c26:	028a2503          	lw	a0,40(s4)
    80003c2a:	f05fe0ef          	jal	80002b2e <bread>
    80003c2e:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003c30:	865a                	mv	a2,s6
    80003c32:	05850593          	addi	a1,a0,88
    80003c36:	05848513          	addi	a0,s1,88
    80003c3a:	8f8fd0ef          	jal	80000d32 <memmove>
    bwrite(to);  // write the log
    80003c3e:	8526                	mv	a0,s1
    80003c40:	fc5fe0ef          	jal	80002c04 <bwrite>
    brelse(from);
    80003c44:	854e                	mv	a0,s3
    80003c46:	ff1fe0ef          	jal	80002c36 <brelse>
    brelse(to);
    80003c4a:	8526                	mv	a0,s1
    80003c4c:	febfe0ef          	jal	80002c36 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c50:	2905                	addiw	s2,s2,1
    80003c52:	0a91                	addi	s5,s5,4
    80003c54:	02ca2783          	lw	a5,44(s4)
    80003c58:	faf94be3          	blt	s2,a5,80003c0e <end_op+0xb2>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003c5c:	d07ff0ef          	jal	80003962 <write_head>
    install_trans(0); // Now install writes to home locations
    80003c60:	4501                	li	a0,0
    80003c62:	d5fff0ef          	jal	800039c0 <install_trans>
    log.lh.n = 0;
    80003c66:	0001e797          	auipc	a5,0x1e
    80003c6a:	7c07a323          	sw	zero,1990(a5) # 8002242c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003c6e:	cf5ff0ef          	jal	80003962 <write_head>
    80003c72:	69e2                	ld	s3,24(sp)
    80003c74:	6a42                	ld	s4,16(sp)
    80003c76:	6aa2                	ld	s5,8(sp)
    80003c78:	6b02                	ld	s6,0(sp)
    80003c7a:	b715                	j	80003b9e <end_op+0x42>

0000000080003c7c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003c7c:	1101                	addi	sp,sp,-32
    80003c7e:	ec06                	sd	ra,24(sp)
    80003c80:	e822                	sd	s0,16(sp)
    80003c82:	e426                	sd	s1,8(sp)
    80003c84:	e04a                	sd	s2,0(sp)
    80003c86:	1000                	addi	s0,sp,32
    80003c88:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003c8a:	0001e917          	auipc	s2,0x1e
    80003c8e:	77690913          	addi	s2,s2,1910 # 80022400 <log>
    80003c92:	854a                	mv	a0,s2
    80003c94:	f6bfc0ef          	jal	80000bfe <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003c98:	02c92603          	lw	a2,44(s2)
    80003c9c:	47f5                	li	a5,29
    80003c9e:	06c7c363          	blt	a5,a2,80003d04 <log_write+0x88>
    80003ca2:	0001e797          	auipc	a5,0x1e
    80003ca6:	77a7a783          	lw	a5,1914(a5) # 8002241c <log+0x1c>
    80003caa:	37fd                	addiw	a5,a5,-1
    80003cac:	04f65c63          	bge	a2,a5,80003d04 <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003cb0:	0001e797          	auipc	a5,0x1e
    80003cb4:	7707a783          	lw	a5,1904(a5) # 80022420 <log+0x20>
    80003cb8:	04f05c63          	blez	a5,80003d10 <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003cbc:	4781                	li	a5,0
    80003cbe:	04c05f63          	blez	a2,80003d1c <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003cc2:	44cc                	lw	a1,12(s1)
    80003cc4:	0001e717          	auipc	a4,0x1e
    80003cc8:	76c70713          	addi	a4,a4,1900 # 80022430 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003ccc:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003cce:	4314                	lw	a3,0(a4)
    80003cd0:	04b68663          	beq	a3,a1,80003d1c <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    80003cd4:	2785                	addiw	a5,a5,1
    80003cd6:	0711                	addi	a4,a4,4
    80003cd8:	fef61be3          	bne	a2,a5,80003cce <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003cdc:	0621                	addi	a2,a2,8
    80003cde:	060a                	slli	a2,a2,0x2
    80003ce0:	0001e797          	auipc	a5,0x1e
    80003ce4:	72078793          	addi	a5,a5,1824 # 80022400 <log>
    80003ce8:	97b2                	add	a5,a5,a2
    80003cea:	44d8                	lw	a4,12(s1)
    80003cec:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003cee:	8526                	mv	a0,s1
    80003cf0:	fcbfe0ef          	jal	80002cba <bpin>
    log.lh.n++;
    80003cf4:	0001e717          	auipc	a4,0x1e
    80003cf8:	70c70713          	addi	a4,a4,1804 # 80022400 <log>
    80003cfc:	575c                	lw	a5,44(a4)
    80003cfe:	2785                	addiw	a5,a5,1
    80003d00:	d75c                	sw	a5,44(a4)
    80003d02:	a80d                	j	80003d34 <log_write+0xb8>
    panic("too big a transaction");
    80003d04:	00004517          	auipc	a0,0x4
    80003d08:	86c50513          	addi	a0,a0,-1940 # 80007570 <etext+0x570>
    80003d0c:	a93fc0ef          	jal	8000079e <panic>
    panic("log_write outside of trans");
    80003d10:	00004517          	auipc	a0,0x4
    80003d14:	87850513          	addi	a0,a0,-1928 # 80007588 <etext+0x588>
    80003d18:	a87fc0ef          	jal	8000079e <panic>
  log.lh.block[i] = b->blockno;
    80003d1c:	00878693          	addi	a3,a5,8
    80003d20:	068a                	slli	a3,a3,0x2
    80003d22:	0001e717          	auipc	a4,0x1e
    80003d26:	6de70713          	addi	a4,a4,1758 # 80022400 <log>
    80003d2a:	9736                	add	a4,a4,a3
    80003d2c:	44d4                	lw	a3,12(s1)
    80003d2e:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003d30:	faf60fe3          	beq	a2,a5,80003cee <log_write+0x72>
  }
  release(&log.lock);
    80003d34:	0001e517          	auipc	a0,0x1e
    80003d38:	6cc50513          	addi	a0,a0,1740 # 80022400 <log>
    80003d3c:	f57fc0ef          	jal	80000c92 <release>
}
    80003d40:	60e2                	ld	ra,24(sp)
    80003d42:	6442                	ld	s0,16(sp)
    80003d44:	64a2                	ld	s1,8(sp)
    80003d46:	6902                	ld	s2,0(sp)
    80003d48:	6105                	addi	sp,sp,32
    80003d4a:	8082                	ret

0000000080003d4c <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003d4c:	1101                	addi	sp,sp,-32
    80003d4e:	ec06                	sd	ra,24(sp)
    80003d50:	e822                	sd	s0,16(sp)
    80003d52:	e426                	sd	s1,8(sp)
    80003d54:	e04a                	sd	s2,0(sp)
    80003d56:	1000                	addi	s0,sp,32
    80003d58:	84aa                	mv	s1,a0
    80003d5a:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003d5c:	00004597          	auipc	a1,0x4
    80003d60:	84c58593          	addi	a1,a1,-1972 # 800075a8 <etext+0x5a8>
    80003d64:	0521                	addi	a0,a0,8
    80003d66:	e15fc0ef          	jal	80000b7a <initlock>
  lk->name = name;
    80003d6a:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003d6e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003d72:	0204a423          	sw	zero,40(s1)
}
    80003d76:	60e2                	ld	ra,24(sp)
    80003d78:	6442                	ld	s0,16(sp)
    80003d7a:	64a2                	ld	s1,8(sp)
    80003d7c:	6902                	ld	s2,0(sp)
    80003d7e:	6105                	addi	sp,sp,32
    80003d80:	8082                	ret

0000000080003d82 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003d82:	1101                	addi	sp,sp,-32
    80003d84:	ec06                	sd	ra,24(sp)
    80003d86:	e822                	sd	s0,16(sp)
    80003d88:	e426                	sd	s1,8(sp)
    80003d8a:	e04a                	sd	s2,0(sp)
    80003d8c:	1000                	addi	s0,sp,32
    80003d8e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003d90:	00850913          	addi	s2,a0,8
    80003d94:	854a                	mv	a0,s2
    80003d96:	e69fc0ef          	jal	80000bfe <acquire>
  while (lk->locked) {
    80003d9a:	409c                	lw	a5,0(s1)
    80003d9c:	c799                	beqz	a5,80003daa <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003d9e:	85ca                	mv	a1,s2
    80003da0:	8526                	mv	a0,s1
    80003da2:	908fe0ef          	jal	80001eaa <sleep>
  while (lk->locked) {
    80003da6:	409c                	lw	a5,0(s1)
    80003da8:	fbfd                	bnez	a5,80003d9e <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003daa:	4785                	li	a5,1
    80003dac:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003dae:	b2ffd0ef          	jal	800018dc <myproc>
    80003db2:	591c                	lw	a5,48(a0)
    80003db4:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003db6:	854a                	mv	a0,s2
    80003db8:	edbfc0ef          	jal	80000c92 <release>
}
    80003dbc:	60e2                	ld	ra,24(sp)
    80003dbe:	6442                	ld	s0,16(sp)
    80003dc0:	64a2                	ld	s1,8(sp)
    80003dc2:	6902                	ld	s2,0(sp)
    80003dc4:	6105                	addi	sp,sp,32
    80003dc6:	8082                	ret

0000000080003dc8 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003dc8:	1101                	addi	sp,sp,-32
    80003dca:	ec06                	sd	ra,24(sp)
    80003dcc:	e822                	sd	s0,16(sp)
    80003dce:	e426                	sd	s1,8(sp)
    80003dd0:	e04a                	sd	s2,0(sp)
    80003dd2:	1000                	addi	s0,sp,32
    80003dd4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003dd6:	00850913          	addi	s2,a0,8
    80003dda:	854a                	mv	a0,s2
    80003ddc:	e23fc0ef          	jal	80000bfe <acquire>
  lk->locked = 0;
    80003de0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003de4:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003de8:	8526                	mv	a0,s1
    80003dea:	90cfe0ef          	jal	80001ef6 <wakeup>
  release(&lk->lk);
    80003dee:	854a                	mv	a0,s2
    80003df0:	ea3fc0ef          	jal	80000c92 <release>
}
    80003df4:	60e2                	ld	ra,24(sp)
    80003df6:	6442                	ld	s0,16(sp)
    80003df8:	64a2                	ld	s1,8(sp)
    80003dfa:	6902                	ld	s2,0(sp)
    80003dfc:	6105                	addi	sp,sp,32
    80003dfe:	8082                	ret

0000000080003e00 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003e00:	7179                	addi	sp,sp,-48
    80003e02:	f406                	sd	ra,40(sp)
    80003e04:	f022                	sd	s0,32(sp)
    80003e06:	ec26                	sd	s1,24(sp)
    80003e08:	e84a                	sd	s2,16(sp)
    80003e0a:	1800                	addi	s0,sp,48
    80003e0c:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003e0e:	00850913          	addi	s2,a0,8
    80003e12:	854a                	mv	a0,s2
    80003e14:	debfc0ef          	jal	80000bfe <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003e18:	409c                	lw	a5,0(s1)
    80003e1a:	ef81                	bnez	a5,80003e32 <holdingsleep+0x32>
    80003e1c:	4481                	li	s1,0
  release(&lk->lk);
    80003e1e:	854a                	mv	a0,s2
    80003e20:	e73fc0ef          	jal	80000c92 <release>
  return r;
}
    80003e24:	8526                	mv	a0,s1
    80003e26:	70a2                	ld	ra,40(sp)
    80003e28:	7402                	ld	s0,32(sp)
    80003e2a:	64e2                	ld	s1,24(sp)
    80003e2c:	6942                	ld	s2,16(sp)
    80003e2e:	6145                	addi	sp,sp,48
    80003e30:	8082                	ret
    80003e32:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80003e34:	0284a983          	lw	s3,40(s1)
    80003e38:	aa5fd0ef          	jal	800018dc <myproc>
    80003e3c:	5904                	lw	s1,48(a0)
    80003e3e:	413484b3          	sub	s1,s1,s3
    80003e42:	0014b493          	seqz	s1,s1
    80003e46:	69a2                	ld	s3,8(sp)
    80003e48:	bfd9                	j	80003e1e <holdingsleep+0x1e>

0000000080003e4a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003e4a:	1141                	addi	sp,sp,-16
    80003e4c:	e406                	sd	ra,8(sp)
    80003e4e:	e022                	sd	s0,0(sp)
    80003e50:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003e52:	00003597          	auipc	a1,0x3
    80003e56:	76658593          	addi	a1,a1,1894 # 800075b8 <etext+0x5b8>
    80003e5a:	0001e517          	auipc	a0,0x1e
    80003e5e:	6ee50513          	addi	a0,a0,1774 # 80022548 <ftable>
    80003e62:	d19fc0ef          	jal	80000b7a <initlock>
}
    80003e66:	60a2                	ld	ra,8(sp)
    80003e68:	6402                	ld	s0,0(sp)
    80003e6a:	0141                	addi	sp,sp,16
    80003e6c:	8082                	ret

0000000080003e6e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003e6e:	1101                	addi	sp,sp,-32
    80003e70:	ec06                	sd	ra,24(sp)
    80003e72:	e822                	sd	s0,16(sp)
    80003e74:	e426                	sd	s1,8(sp)
    80003e76:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003e78:	0001e517          	auipc	a0,0x1e
    80003e7c:	6d050513          	addi	a0,a0,1744 # 80022548 <ftable>
    80003e80:	d7ffc0ef          	jal	80000bfe <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003e84:	0001e497          	auipc	s1,0x1e
    80003e88:	6dc48493          	addi	s1,s1,1756 # 80022560 <ftable+0x18>
    80003e8c:	0001f717          	auipc	a4,0x1f
    80003e90:	67470713          	addi	a4,a4,1652 # 80023500 <disk>
    if(f->ref == 0){
    80003e94:	40dc                	lw	a5,4(s1)
    80003e96:	cf89                	beqz	a5,80003eb0 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003e98:	02848493          	addi	s1,s1,40
    80003e9c:	fee49ce3          	bne	s1,a4,80003e94 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003ea0:	0001e517          	auipc	a0,0x1e
    80003ea4:	6a850513          	addi	a0,a0,1704 # 80022548 <ftable>
    80003ea8:	debfc0ef          	jal	80000c92 <release>
  return 0;
    80003eac:	4481                	li	s1,0
    80003eae:	a809                	j	80003ec0 <filealloc+0x52>
      f->ref = 1;
    80003eb0:	4785                	li	a5,1
    80003eb2:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003eb4:	0001e517          	auipc	a0,0x1e
    80003eb8:	69450513          	addi	a0,a0,1684 # 80022548 <ftable>
    80003ebc:	dd7fc0ef          	jal	80000c92 <release>
}
    80003ec0:	8526                	mv	a0,s1
    80003ec2:	60e2                	ld	ra,24(sp)
    80003ec4:	6442                	ld	s0,16(sp)
    80003ec6:	64a2                	ld	s1,8(sp)
    80003ec8:	6105                	addi	sp,sp,32
    80003eca:	8082                	ret

0000000080003ecc <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003ecc:	1101                	addi	sp,sp,-32
    80003ece:	ec06                	sd	ra,24(sp)
    80003ed0:	e822                	sd	s0,16(sp)
    80003ed2:	e426                	sd	s1,8(sp)
    80003ed4:	1000                	addi	s0,sp,32
    80003ed6:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003ed8:	0001e517          	auipc	a0,0x1e
    80003edc:	67050513          	addi	a0,a0,1648 # 80022548 <ftable>
    80003ee0:	d1ffc0ef          	jal	80000bfe <acquire>
  if(f->ref < 1)
    80003ee4:	40dc                	lw	a5,4(s1)
    80003ee6:	02f05063          	blez	a5,80003f06 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80003eea:	2785                	addiw	a5,a5,1
    80003eec:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003eee:	0001e517          	auipc	a0,0x1e
    80003ef2:	65a50513          	addi	a0,a0,1626 # 80022548 <ftable>
    80003ef6:	d9dfc0ef          	jal	80000c92 <release>
  return f;
}
    80003efa:	8526                	mv	a0,s1
    80003efc:	60e2                	ld	ra,24(sp)
    80003efe:	6442                	ld	s0,16(sp)
    80003f00:	64a2                	ld	s1,8(sp)
    80003f02:	6105                	addi	sp,sp,32
    80003f04:	8082                	ret
    panic("filedup");
    80003f06:	00003517          	auipc	a0,0x3
    80003f0a:	6ba50513          	addi	a0,a0,1722 # 800075c0 <etext+0x5c0>
    80003f0e:	891fc0ef          	jal	8000079e <panic>

0000000080003f12 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003f12:	7139                	addi	sp,sp,-64
    80003f14:	fc06                	sd	ra,56(sp)
    80003f16:	f822                	sd	s0,48(sp)
    80003f18:	f426                	sd	s1,40(sp)
    80003f1a:	0080                	addi	s0,sp,64
    80003f1c:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003f1e:	0001e517          	auipc	a0,0x1e
    80003f22:	62a50513          	addi	a0,a0,1578 # 80022548 <ftable>
    80003f26:	cd9fc0ef          	jal	80000bfe <acquire>
  if(f->ref < 1)
    80003f2a:	40dc                	lw	a5,4(s1)
    80003f2c:	04f05863          	blez	a5,80003f7c <fileclose+0x6a>
    panic("fileclose");
  if(--f->ref > 0){
    80003f30:	37fd                	addiw	a5,a5,-1
    80003f32:	c0dc                	sw	a5,4(s1)
    80003f34:	04f04e63          	bgtz	a5,80003f90 <fileclose+0x7e>
    80003f38:	f04a                	sd	s2,32(sp)
    80003f3a:	ec4e                	sd	s3,24(sp)
    80003f3c:	e852                	sd	s4,16(sp)
    80003f3e:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80003f40:	0004a903          	lw	s2,0(s1)
    80003f44:	0094ca83          	lbu	s5,9(s1)
    80003f48:	0104ba03          	ld	s4,16(s1)
    80003f4c:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80003f50:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003f54:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80003f58:	0001e517          	auipc	a0,0x1e
    80003f5c:	5f050513          	addi	a0,a0,1520 # 80022548 <ftable>
    80003f60:	d33fc0ef          	jal	80000c92 <release>

  if(ff.type == FD_PIPE){
    80003f64:	4785                	li	a5,1
    80003f66:	04f90063          	beq	s2,a5,80003fa6 <fileclose+0x94>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003f6a:	3979                	addiw	s2,s2,-2
    80003f6c:	4785                	li	a5,1
    80003f6e:	0527f563          	bgeu	a5,s2,80003fb8 <fileclose+0xa6>
    80003f72:	7902                	ld	s2,32(sp)
    80003f74:	69e2                	ld	s3,24(sp)
    80003f76:	6a42                	ld	s4,16(sp)
    80003f78:	6aa2                	ld	s5,8(sp)
    80003f7a:	a00d                	j	80003f9c <fileclose+0x8a>
    80003f7c:	f04a                	sd	s2,32(sp)
    80003f7e:	ec4e                	sd	s3,24(sp)
    80003f80:	e852                	sd	s4,16(sp)
    80003f82:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80003f84:	00003517          	auipc	a0,0x3
    80003f88:	64450513          	addi	a0,a0,1604 # 800075c8 <etext+0x5c8>
    80003f8c:	813fc0ef          	jal	8000079e <panic>
    release(&ftable.lock);
    80003f90:	0001e517          	auipc	a0,0x1e
    80003f94:	5b850513          	addi	a0,a0,1464 # 80022548 <ftable>
    80003f98:	cfbfc0ef          	jal	80000c92 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80003f9c:	70e2                	ld	ra,56(sp)
    80003f9e:	7442                	ld	s0,48(sp)
    80003fa0:	74a2                	ld	s1,40(sp)
    80003fa2:	6121                	addi	sp,sp,64
    80003fa4:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003fa6:	85d6                	mv	a1,s5
    80003fa8:	8552                	mv	a0,s4
    80003faa:	340000ef          	jal	800042ea <pipeclose>
    80003fae:	7902                	ld	s2,32(sp)
    80003fb0:	69e2                	ld	s3,24(sp)
    80003fb2:	6a42                	ld	s4,16(sp)
    80003fb4:	6aa2                	ld	s5,8(sp)
    80003fb6:	b7dd                	j	80003f9c <fileclose+0x8a>
    begin_op();
    80003fb8:	b3bff0ef          	jal	80003af2 <begin_op>
    iput(ff.ip);
    80003fbc:	854e                	mv	a0,s3
    80003fbe:	c04ff0ef          	jal	800033c2 <iput>
    end_op();
    80003fc2:	b9bff0ef          	jal	80003b5c <end_op>
    80003fc6:	7902                	ld	s2,32(sp)
    80003fc8:	69e2                	ld	s3,24(sp)
    80003fca:	6a42                	ld	s4,16(sp)
    80003fcc:	6aa2                	ld	s5,8(sp)
    80003fce:	b7f9                	j	80003f9c <fileclose+0x8a>

0000000080003fd0 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80003fd0:	715d                	addi	sp,sp,-80
    80003fd2:	e486                	sd	ra,72(sp)
    80003fd4:	e0a2                	sd	s0,64(sp)
    80003fd6:	fc26                	sd	s1,56(sp)
    80003fd8:	f44e                	sd	s3,40(sp)
    80003fda:	0880                	addi	s0,sp,80
    80003fdc:	84aa                	mv	s1,a0
    80003fde:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80003fe0:	8fdfd0ef          	jal	800018dc <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003fe4:	409c                	lw	a5,0(s1)
    80003fe6:	37f9                	addiw	a5,a5,-2
    80003fe8:	4705                	li	a4,1
    80003fea:	04f76263          	bltu	a4,a5,8000402e <filestat+0x5e>
    80003fee:	f84a                	sd	s2,48(sp)
    80003ff0:	f052                	sd	s4,32(sp)
    80003ff2:	892a                	mv	s2,a0
    ilock(f->ip);
    80003ff4:	6c88                	ld	a0,24(s1)
    80003ff6:	a4aff0ef          	jal	80003240 <ilock>
    stati(f->ip, &st);
    80003ffa:	fb840a13          	addi	s4,s0,-72
    80003ffe:	85d2                	mv	a1,s4
    80004000:	6c88                	ld	a0,24(s1)
    80004002:	c68ff0ef          	jal	8000346a <stati>
    iunlock(f->ip);
    80004006:	6c88                	ld	a0,24(s1)
    80004008:	ae6ff0ef          	jal	800032ee <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000400c:	46e1                	li	a3,24
    8000400e:	8652                	mv	a2,s4
    80004010:	85ce                	mv	a1,s3
    80004012:	05093503          	ld	a0,80(s2)
    80004016:	d6efd0ef          	jal	80001584 <copyout>
    8000401a:	41f5551b          	sraiw	a0,a0,0x1f
    8000401e:	7942                	ld	s2,48(sp)
    80004020:	7a02                	ld	s4,32(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004022:	60a6                	ld	ra,72(sp)
    80004024:	6406                	ld	s0,64(sp)
    80004026:	74e2                	ld	s1,56(sp)
    80004028:	79a2                	ld	s3,40(sp)
    8000402a:	6161                	addi	sp,sp,80
    8000402c:	8082                	ret
  return -1;
    8000402e:	557d                	li	a0,-1
    80004030:	bfcd                	j	80004022 <filestat+0x52>

0000000080004032 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004032:	7179                	addi	sp,sp,-48
    80004034:	f406                	sd	ra,40(sp)
    80004036:	f022                	sd	s0,32(sp)
    80004038:	e84a                	sd	s2,16(sp)
    8000403a:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000403c:	00854783          	lbu	a5,8(a0)
    80004040:	cfd1                	beqz	a5,800040dc <fileread+0xaa>
    80004042:	ec26                	sd	s1,24(sp)
    80004044:	e44e                	sd	s3,8(sp)
    80004046:	84aa                	mv	s1,a0
    80004048:	89ae                	mv	s3,a1
    8000404a:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000404c:	411c                	lw	a5,0(a0)
    8000404e:	4705                	li	a4,1
    80004050:	04e78363          	beq	a5,a4,80004096 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004054:	470d                	li	a4,3
    80004056:	04e78763          	beq	a5,a4,800040a4 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000405a:	4709                	li	a4,2
    8000405c:	06e79a63          	bne	a5,a4,800040d0 <fileread+0x9e>
    ilock(f->ip);
    80004060:	6d08                	ld	a0,24(a0)
    80004062:	9deff0ef          	jal	80003240 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004066:	874a                	mv	a4,s2
    80004068:	5094                	lw	a3,32(s1)
    8000406a:	864e                	mv	a2,s3
    8000406c:	4585                	li	a1,1
    8000406e:	6c88                	ld	a0,24(s1)
    80004070:	c28ff0ef          	jal	80003498 <readi>
    80004074:	892a                	mv	s2,a0
    80004076:	00a05563          	blez	a0,80004080 <fileread+0x4e>
      f->off += r;
    8000407a:	509c                	lw	a5,32(s1)
    8000407c:	9fa9                	addw	a5,a5,a0
    8000407e:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004080:	6c88                	ld	a0,24(s1)
    80004082:	a6cff0ef          	jal	800032ee <iunlock>
    80004086:	64e2                	ld	s1,24(sp)
    80004088:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    8000408a:	854a                	mv	a0,s2
    8000408c:	70a2                	ld	ra,40(sp)
    8000408e:	7402                	ld	s0,32(sp)
    80004090:	6942                	ld	s2,16(sp)
    80004092:	6145                	addi	sp,sp,48
    80004094:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004096:	6908                	ld	a0,16(a0)
    80004098:	3a2000ef          	jal	8000443a <piperead>
    8000409c:	892a                	mv	s2,a0
    8000409e:	64e2                	ld	s1,24(sp)
    800040a0:	69a2                	ld	s3,8(sp)
    800040a2:	b7e5                	j	8000408a <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800040a4:	02451783          	lh	a5,36(a0)
    800040a8:	03079693          	slli	a3,a5,0x30
    800040ac:	92c1                	srli	a3,a3,0x30
    800040ae:	4725                	li	a4,9
    800040b0:	02d76863          	bltu	a4,a3,800040e0 <fileread+0xae>
    800040b4:	0792                	slli	a5,a5,0x4
    800040b6:	0001e717          	auipc	a4,0x1e
    800040ba:	3f270713          	addi	a4,a4,1010 # 800224a8 <devsw>
    800040be:	97ba                	add	a5,a5,a4
    800040c0:	639c                	ld	a5,0(a5)
    800040c2:	c39d                	beqz	a5,800040e8 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    800040c4:	4505                	li	a0,1
    800040c6:	9782                	jalr	a5
    800040c8:	892a                	mv	s2,a0
    800040ca:	64e2                	ld	s1,24(sp)
    800040cc:	69a2                	ld	s3,8(sp)
    800040ce:	bf75                	j	8000408a <fileread+0x58>
    panic("fileread");
    800040d0:	00003517          	auipc	a0,0x3
    800040d4:	50850513          	addi	a0,a0,1288 # 800075d8 <etext+0x5d8>
    800040d8:	ec6fc0ef          	jal	8000079e <panic>
    return -1;
    800040dc:	597d                	li	s2,-1
    800040de:	b775                	j	8000408a <fileread+0x58>
      return -1;
    800040e0:	597d                	li	s2,-1
    800040e2:	64e2                	ld	s1,24(sp)
    800040e4:	69a2                	ld	s3,8(sp)
    800040e6:	b755                	j	8000408a <fileread+0x58>
    800040e8:	597d                	li	s2,-1
    800040ea:	64e2                	ld	s1,24(sp)
    800040ec:	69a2                	ld	s3,8(sp)
    800040ee:	bf71                	j	8000408a <fileread+0x58>

00000000800040f0 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800040f0:	00954783          	lbu	a5,9(a0)
    800040f4:	10078e63          	beqz	a5,80004210 <filewrite+0x120>
{
    800040f8:	711d                	addi	sp,sp,-96
    800040fa:	ec86                	sd	ra,88(sp)
    800040fc:	e8a2                	sd	s0,80(sp)
    800040fe:	e0ca                	sd	s2,64(sp)
    80004100:	f456                	sd	s5,40(sp)
    80004102:	f05a                	sd	s6,32(sp)
    80004104:	1080                	addi	s0,sp,96
    80004106:	892a                	mv	s2,a0
    80004108:	8b2e                	mv	s6,a1
    8000410a:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    8000410c:	411c                	lw	a5,0(a0)
    8000410e:	4705                	li	a4,1
    80004110:	02e78963          	beq	a5,a4,80004142 <filewrite+0x52>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004114:	470d                	li	a4,3
    80004116:	02e78a63          	beq	a5,a4,8000414a <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000411a:	4709                	li	a4,2
    8000411c:	0ce79e63          	bne	a5,a4,800041f8 <filewrite+0x108>
    80004120:	f852                	sd	s4,48(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004122:	0ac05963          	blez	a2,800041d4 <filewrite+0xe4>
    80004126:	e4a6                	sd	s1,72(sp)
    80004128:	fc4e                	sd	s3,56(sp)
    8000412a:	ec5e                	sd	s7,24(sp)
    8000412c:	e862                	sd	s8,16(sp)
    8000412e:	e466                	sd	s9,8(sp)
    int i = 0;
    80004130:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    80004132:	6b85                	lui	s7,0x1
    80004134:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004138:	6c85                	lui	s9,0x1
    8000413a:	c00c8c9b          	addiw	s9,s9,-1024 # c00 <_entry-0x7ffff400>
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000413e:	4c05                	li	s8,1
    80004140:	a8ad                	j	800041ba <filewrite+0xca>
    ret = pipewrite(f->pipe, addr, n);
    80004142:	6908                	ld	a0,16(a0)
    80004144:	1fe000ef          	jal	80004342 <pipewrite>
    80004148:	a04d                	j	800041ea <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000414a:	02451783          	lh	a5,36(a0)
    8000414e:	03079693          	slli	a3,a5,0x30
    80004152:	92c1                	srli	a3,a3,0x30
    80004154:	4725                	li	a4,9
    80004156:	0ad76f63          	bltu	a4,a3,80004214 <filewrite+0x124>
    8000415a:	0792                	slli	a5,a5,0x4
    8000415c:	0001e717          	auipc	a4,0x1e
    80004160:	34c70713          	addi	a4,a4,844 # 800224a8 <devsw>
    80004164:	97ba                	add	a5,a5,a4
    80004166:	679c                	ld	a5,8(a5)
    80004168:	cbc5                	beqz	a5,80004218 <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    8000416a:	4505                	li	a0,1
    8000416c:	9782                	jalr	a5
    8000416e:	a8b5                	j	800041ea <filewrite+0xfa>
      if(n1 > max)
    80004170:	2981                	sext.w	s3,s3
      begin_op();
    80004172:	981ff0ef          	jal	80003af2 <begin_op>
      ilock(f->ip);
    80004176:	01893503          	ld	a0,24(s2)
    8000417a:	8c6ff0ef          	jal	80003240 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000417e:	874e                	mv	a4,s3
    80004180:	02092683          	lw	a3,32(s2)
    80004184:	016a0633          	add	a2,s4,s6
    80004188:	85e2                	mv	a1,s8
    8000418a:	01893503          	ld	a0,24(s2)
    8000418e:	bfcff0ef          	jal	8000358a <writei>
    80004192:	84aa                	mv	s1,a0
    80004194:	00a05763          	blez	a0,800041a2 <filewrite+0xb2>
        f->off += r;
    80004198:	02092783          	lw	a5,32(s2)
    8000419c:	9fa9                	addw	a5,a5,a0
    8000419e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800041a2:	01893503          	ld	a0,24(s2)
    800041a6:	948ff0ef          	jal	800032ee <iunlock>
      end_op();
    800041aa:	9b3ff0ef          	jal	80003b5c <end_op>

      if(r != n1){
    800041ae:	02999563          	bne	s3,s1,800041d8 <filewrite+0xe8>
        // error from writei
        break;
      }
      i += r;
    800041b2:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    800041b6:	015a5963          	bge	s4,s5,800041c8 <filewrite+0xd8>
      int n1 = n - i;
    800041ba:	414a87bb          	subw	a5,s5,s4
    800041be:	89be                	mv	s3,a5
      if(n1 > max)
    800041c0:	fafbd8e3          	bge	s7,a5,80004170 <filewrite+0x80>
    800041c4:	89e6                	mv	s3,s9
    800041c6:	b76d                	j	80004170 <filewrite+0x80>
    800041c8:	64a6                	ld	s1,72(sp)
    800041ca:	79e2                	ld	s3,56(sp)
    800041cc:	6be2                	ld	s7,24(sp)
    800041ce:	6c42                	ld	s8,16(sp)
    800041d0:	6ca2                	ld	s9,8(sp)
    800041d2:	a801                	j	800041e2 <filewrite+0xf2>
    int i = 0;
    800041d4:	4a01                	li	s4,0
    800041d6:	a031                	j	800041e2 <filewrite+0xf2>
    800041d8:	64a6                	ld	s1,72(sp)
    800041da:	79e2                	ld	s3,56(sp)
    800041dc:	6be2                	ld	s7,24(sp)
    800041de:	6c42                	ld	s8,16(sp)
    800041e0:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    800041e2:	034a9d63          	bne	s5,s4,8000421c <filewrite+0x12c>
    800041e6:	8556                	mv	a0,s5
    800041e8:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800041ea:	60e6                	ld	ra,88(sp)
    800041ec:	6446                	ld	s0,80(sp)
    800041ee:	6906                	ld	s2,64(sp)
    800041f0:	7aa2                	ld	s5,40(sp)
    800041f2:	7b02                	ld	s6,32(sp)
    800041f4:	6125                	addi	sp,sp,96
    800041f6:	8082                	ret
    800041f8:	e4a6                	sd	s1,72(sp)
    800041fa:	fc4e                	sd	s3,56(sp)
    800041fc:	f852                	sd	s4,48(sp)
    800041fe:	ec5e                	sd	s7,24(sp)
    80004200:	e862                	sd	s8,16(sp)
    80004202:	e466                	sd	s9,8(sp)
    panic("filewrite");
    80004204:	00003517          	auipc	a0,0x3
    80004208:	3e450513          	addi	a0,a0,996 # 800075e8 <etext+0x5e8>
    8000420c:	d92fc0ef          	jal	8000079e <panic>
    return -1;
    80004210:	557d                	li	a0,-1
}
    80004212:	8082                	ret
      return -1;
    80004214:	557d                	li	a0,-1
    80004216:	bfd1                	j	800041ea <filewrite+0xfa>
    80004218:	557d                	li	a0,-1
    8000421a:	bfc1                	j	800041ea <filewrite+0xfa>
    ret = (i == n ? n : -1);
    8000421c:	557d                	li	a0,-1
    8000421e:	7a42                	ld	s4,48(sp)
    80004220:	b7e9                	j	800041ea <filewrite+0xfa>

0000000080004222 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004222:	7179                	addi	sp,sp,-48
    80004224:	f406                	sd	ra,40(sp)
    80004226:	f022                	sd	s0,32(sp)
    80004228:	ec26                	sd	s1,24(sp)
    8000422a:	e052                	sd	s4,0(sp)
    8000422c:	1800                	addi	s0,sp,48
    8000422e:	84aa                	mv	s1,a0
    80004230:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004232:	0005b023          	sd	zero,0(a1)
    80004236:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000423a:	c35ff0ef          	jal	80003e6e <filealloc>
    8000423e:	e088                	sd	a0,0(s1)
    80004240:	c549                	beqz	a0,800042ca <pipealloc+0xa8>
    80004242:	c2dff0ef          	jal	80003e6e <filealloc>
    80004246:	00aa3023          	sd	a0,0(s4)
    8000424a:	cd25                	beqz	a0,800042c2 <pipealloc+0xa0>
    8000424c:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000424e:	8ddfc0ef          	jal	80000b2a <kalloc>
    80004252:	892a                	mv	s2,a0
    80004254:	c12d                	beqz	a0,800042b6 <pipealloc+0x94>
    80004256:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004258:	4985                	li	s3,1
    8000425a:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000425e:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004262:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004266:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000426a:	00003597          	auipc	a1,0x3
    8000426e:	38e58593          	addi	a1,a1,910 # 800075f8 <etext+0x5f8>
    80004272:	909fc0ef          	jal	80000b7a <initlock>
  (*f0)->type = FD_PIPE;
    80004276:	609c                	ld	a5,0(s1)
    80004278:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000427c:	609c                	ld	a5,0(s1)
    8000427e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004282:	609c                	ld	a5,0(s1)
    80004284:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004288:	609c                	ld	a5,0(s1)
    8000428a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000428e:	000a3783          	ld	a5,0(s4)
    80004292:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004296:	000a3783          	ld	a5,0(s4)
    8000429a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000429e:	000a3783          	ld	a5,0(s4)
    800042a2:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800042a6:	000a3783          	ld	a5,0(s4)
    800042aa:	0127b823          	sd	s2,16(a5)
  return 0;
    800042ae:	4501                	li	a0,0
    800042b0:	6942                	ld	s2,16(sp)
    800042b2:	69a2                	ld	s3,8(sp)
    800042b4:	a01d                	j	800042da <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800042b6:	6088                	ld	a0,0(s1)
    800042b8:	c119                	beqz	a0,800042be <pipealloc+0x9c>
    800042ba:	6942                	ld	s2,16(sp)
    800042bc:	a029                	j	800042c6 <pipealloc+0xa4>
    800042be:	6942                	ld	s2,16(sp)
    800042c0:	a029                	j	800042ca <pipealloc+0xa8>
    800042c2:	6088                	ld	a0,0(s1)
    800042c4:	c10d                	beqz	a0,800042e6 <pipealloc+0xc4>
    fileclose(*f0);
    800042c6:	c4dff0ef          	jal	80003f12 <fileclose>
  if(*f1)
    800042ca:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800042ce:	557d                	li	a0,-1
  if(*f1)
    800042d0:	c789                	beqz	a5,800042da <pipealloc+0xb8>
    fileclose(*f1);
    800042d2:	853e                	mv	a0,a5
    800042d4:	c3fff0ef          	jal	80003f12 <fileclose>
  return -1;
    800042d8:	557d                	li	a0,-1
}
    800042da:	70a2                	ld	ra,40(sp)
    800042dc:	7402                	ld	s0,32(sp)
    800042de:	64e2                	ld	s1,24(sp)
    800042e0:	6a02                	ld	s4,0(sp)
    800042e2:	6145                	addi	sp,sp,48
    800042e4:	8082                	ret
  return -1;
    800042e6:	557d                	li	a0,-1
    800042e8:	bfcd                	j	800042da <pipealloc+0xb8>

00000000800042ea <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800042ea:	1101                	addi	sp,sp,-32
    800042ec:	ec06                	sd	ra,24(sp)
    800042ee:	e822                	sd	s0,16(sp)
    800042f0:	e426                	sd	s1,8(sp)
    800042f2:	e04a                	sd	s2,0(sp)
    800042f4:	1000                	addi	s0,sp,32
    800042f6:	84aa                	mv	s1,a0
    800042f8:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800042fa:	905fc0ef          	jal	80000bfe <acquire>
  if(writable){
    800042fe:	02090763          	beqz	s2,8000432c <pipeclose+0x42>
    pi->writeopen = 0;
    80004302:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004306:	21848513          	addi	a0,s1,536
    8000430a:	bedfd0ef          	jal	80001ef6 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000430e:	2204b783          	ld	a5,544(s1)
    80004312:	e785                	bnez	a5,8000433a <pipeclose+0x50>
    release(&pi->lock);
    80004314:	8526                	mv	a0,s1
    80004316:	97dfc0ef          	jal	80000c92 <release>
    kfree((char*)pi);
    8000431a:	8526                	mv	a0,s1
    8000431c:	f2cfc0ef          	jal	80000a48 <kfree>
  } else
    release(&pi->lock);
}
    80004320:	60e2                	ld	ra,24(sp)
    80004322:	6442                	ld	s0,16(sp)
    80004324:	64a2                	ld	s1,8(sp)
    80004326:	6902                	ld	s2,0(sp)
    80004328:	6105                	addi	sp,sp,32
    8000432a:	8082                	ret
    pi->readopen = 0;
    8000432c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004330:	21c48513          	addi	a0,s1,540
    80004334:	bc3fd0ef          	jal	80001ef6 <wakeup>
    80004338:	bfd9                	j	8000430e <pipeclose+0x24>
    release(&pi->lock);
    8000433a:	8526                	mv	a0,s1
    8000433c:	957fc0ef          	jal	80000c92 <release>
}
    80004340:	b7c5                	j	80004320 <pipeclose+0x36>

0000000080004342 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004342:	7159                	addi	sp,sp,-112
    80004344:	f486                	sd	ra,104(sp)
    80004346:	f0a2                	sd	s0,96(sp)
    80004348:	eca6                	sd	s1,88(sp)
    8000434a:	e8ca                	sd	s2,80(sp)
    8000434c:	e4ce                	sd	s3,72(sp)
    8000434e:	e0d2                	sd	s4,64(sp)
    80004350:	fc56                	sd	s5,56(sp)
    80004352:	1880                	addi	s0,sp,112
    80004354:	84aa                	mv	s1,a0
    80004356:	8aae                	mv	s5,a1
    80004358:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000435a:	d82fd0ef          	jal	800018dc <myproc>
    8000435e:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004360:	8526                	mv	a0,s1
    80004362:	89dfc0ef          	jal	80000bfe <acquire>
  while(i < n){
    80004366:	0d405263          	blez	s4,8000442a <pipewrite+0xe8>
    8000436a:	f85a                	sd	s6,48(sp)
    8000436c:	f45e                	sd	s7,40(sp)
    8000436e:	f062                	sd	s8,32(sp)
    80004370:	ec66                	sd	s9,24(sp)
    80004372:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004374:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004376:	f9f40c13          	addi	s8,s0,-97
    8000437a:	4b85                	li	s7,1
    8000437c:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000437e:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004382:	21c48c93          	addi	s9,s1,540
    80004386:	a82d                	j	800043c0 <pipewrite+0x7e>
      release(&pi->lock);
    80004388:	8526                	mv	a0,s1
    8000438a:	909fc0ef          	jal	80000c92 <release>
      return -1;
    8000438e:	597d                	li	s2,-1
    80004390:	7b42                	ld	s6,48(sp)
    80004392:	7ba2                	ld	s7,40(sp)
    80004394:	7c02                	ld	s8,32(sp)
    80004396:	6ce2                	ld	s9,24(sp)
    80004398:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000439a:	854a                	mv	a0,s2
    8000439c:	70a6                	ld	ra,104(sp)
    8000439e:	7406                	ld	s0,96(sp)
    800043a0:	64e6                	ld	s1,88(sp)
    800043a2:	6946                	ld	s2,80(sp)
    800043a4:	69a6                	ld	s3,72(sp)
    800043a6:	6a06                	ld	s4,64(sp)
    800043a8:	7ae2                	ld	s5,56(sp)
    800043aa:	6165                	addi	sp,sp,112
    800043ac:	8082                	ret
      wakeup(&pi->nread);
    800043ae:	856a                	mv	a0,s10
    800043b0:	b47fd0ef          	jal	80001ef6 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800043b4:	85a6                	mv	a1,s1
    800043b6:	8566                	mv	a0,s9
    800043b8:	af3fd0ef          	jal	80001eaa <sleep>
  while(i < n){
    800043bc:	05495a63          	bge	s2,s4,80004410 <pipewrite+0xce>
    if(pi->readopen == 0 || killed(pr)){
    800043c0:	2204a783          	lw	a5,544(s1)
    800043c4:	d3f1                	beqz	a5,80004388 <pipewrite+0x46>
    800043c6:	854e                	mv	a0,s3
    800043c8:	d1bfd0ef          	jal	800020e2 <killed>
    800043cc:	fd55                	bnez	a0,80004388 <pipewrite+0x46>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800043ce:	2184a783          	lw	a5,536(s1)
    800043d2:	21c4a703          	lw	a4,540(s1)
    800043d6:	2007879b          	addiw	a5,a5,512
    800043da:	fcf70ae3          	beq	a4,a5,800043ae <pipewrite+0x6c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800043de:	86de                	mv	a3,s7
    800043e0:	01590633          	add	a2,s2,s5
    800043e4:	85e2                	mv	a1,s8
    800043e6:	0509b503          	ld	a0,80(s3)
    800043ea:	a4afd0ef          	jal	80001634 <copyin>
    800043ee:	05650063          	beq	a0,s6,8000442e <pipewrite+0xec>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800043f2:	21c4a783          	lw	a5,540(s1)
    800043f6:	0017871b          	addiw	a4,a5,1
    800043fa:	20e4ae23          	sw	a4,540(s1)
    800043fe:	1ff7f793          	andi	a5,a5,511
    80004402:	97a6                	add	a5,a5,s1
    80004404:	f9f44703          	lbu	a4,-97(s0)
    80004408:	00e78c23          	sb	a4,24(a5)
      i++;
    8000440c:	2905                	addiw	s2,s2,1
    8000440e:	b77d                	j	800043bc <pipewrite+0x7a>
    80004410:	7b42                	ld	s6,48(sp)
    80004412:	7ba2                	ld	s7,40(sp)
    80004414:	7c02                	ld	s8,32(sp)
    80004416:	6ce2                	ld	s9,24(sp)
    80004418:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    8000441a:	21848513          	addi	a0,s1,536
    8000441e:	ad9fd0ef          	jal	80001ef6 <wakeup>
  release(&pi->lock);
    80004422:	8526                	mv	a0,s1
    80004424:	86ffc0ef          	jal	80000c92 <release>
  return i;
    80004428:	bf8d                	j	8000439a <pipewrite+0x58>
  int i = 0;
    8000442a:	4901                	li	s2,0
    8000442c:	b7fd                	j	8000441a <pipewrite+0xd8>
    8000442e:	7b42                	ld	s6,48(sp)
    80004430:	7ba2                	ld	s7,40(sp)
    80004432:	7c02                	ld	s8,32(sp)
    80004434:	6ce2                	ld	s9,24(sp)
    80004436:	6d42                	ld	s10,16(sp)
    80004438:	b7cd                	j	8000441a <pipewrite+0xd8>

000000008000443a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000443a:	711d                	addi	sp,sp,-96
    8000443c:	ec86                	sd	ra,88(sp)
    8000443e:	e8a2                	sd	s0,80(sp)
    80004440:	e4a6                	sd	s1,72(sp)
    80004442:	e0ca                	sd	s2,64(sp)
    80004444:	fc4e                	sd	s3,56(sp)
    80004446:	f852                	sd	s4,48(sp)
    80004448:	f456                	sd	s5,40(sp)
    8000444a:	1080                	addi	s0,sp,96
    8000444c:	84aa                	mv	s1,a0
    8000444e:	892e                	mv	s2,a1
    80004450:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004452:	c8afd0ef          	jal	800018dc <myproc>
    80004456:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004458:	8526                	mv	a0,s1
    8000445a:	fa4fc0ef          	jal	80000bfe <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000445e:	2184a703          	lw	a4,536(s1)
    80004462:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004466:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000446a:	02f71763          	bne	a4,a5,80004498 <piperead+0x5e>
    8000446e:	2244a783          	lw	a5,548(s1)
    80004472:	cf85                	beqz	a5,800044aa <piperead+0x70>
    if(killed(pr)){
    80004474:	8552                	mv	a0,s4
    80004476:	c6dfd0ef          	jal	800020e2 <killed>
    8000447a:	e11d                	bnez	a0,800044a0 <piperead+0x66>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000447c:	85a6                	mv	a1,s1
    8000447e:	854e                	mv	a0,s3
    80004480:	a2bfd0ef          	jal	80001eaa <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004484:	2184a703          	lw	a4,536(s1)
    80004488:	21c4a783          	lw	a5,540(s1)
    8000448c:	fef701e3          	beq	a4,a5,8000446e <piperead+0x34>
    80004490:	f05a                	sd	s6,32(sp)
    80004492:	ec5e                	sd	s7,24(sp)
    80004494:	e862                	sd	s8,16(sp)
    80004496:	a829                	j	800044b0 <piperead+0x76>
    80004498:	f05a                	sd	s6,32(sp)
    8000449a:	ec5e                	sd	s7,24(sp)
    8000449c:	e862                	sd	s8,16(sp)
    8000449e:	a809                	j	800044b0 <piperead+0x76>
      release(&pi->lock);
    800044a0:	8526                	mv	a0,s1
    800044a2:	ff0fc0ef          	jal	80000c92 <release>
      return -1;
    800044a6:	59fd                	li	s3,-1
    800044a8:	a0a5                	j	80004510 <piperead+0xd6>
    800044aa:	f05a                	sd	s6,32(sp)
    800044ac:	ec5e                	sd	s7,24(sp)
    800044ae:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800044b0:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800044b2:	faf40c13          	addi	s8,s0,-81
    800044b6:	4b85                	li	s7,1
    800044b8:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800044ba:	05505163          	blez	s5,800044fc <piperead+0xc2>
    if(pi->nread == pi->nwrite)
    800044be:	2184a783          	lw	a5,536(s1)
    800044c2:	21c4a703          	lw	a4,540(s1)
    800044c6:	02f70b63          	beq	a4,a5,800044fc <piperead+0xc2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800044ca:	0017871b          	addiw	a4,a5,1
    800044ce:	20e4ac23          	sw	a4,536(s1)
    800044d2:	1ff7f793          	andi	a5,a5,511
    800044d6:	97a6                	add	a5,a5,s1
    800044d8:	0187c783          	lbu	a5,24(a5)
    800044dc:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800044e0:	86de                	mv	a3,s7
    800044e2:	8662                	mv	a2,s8
    800044e4:	85ca                	mv	a1,s2
    800044e6:	050a3503          	ld	a0,80(s4)
    800044ea:	89afd0ef          	jal	80001584 <copyout>
    800044ee:	01650763          	beq	a0,s6,800044fc <piperead+0xc2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800044f2:	2985                	addiw	s3,s3,1
    800044f4:	0905                	addi	s2,s2,1
    800044f6:	fd3a94e3          	bne	s5,s3,800044be <piperead+0x84>
    800044fa:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800044fc:	21c48513          	addi	a0,s1,540
    80004500:	9f7fd0ef          	jal	80001ef6 <wakeup>
  release(&pi->lock);
    80004504:	8526                	mv	a0,s1
    80004506:	f8cfc0ef          	jal	80000c92 <release>
    8000450a:	7b02                	ld	s6,32(sp)
    8000450c:	6be2                	ld	s7,24(sp)
    8000450e:	6c42                	ld	s8,16(sp)
  return i;
}
    80004510:	854e                	mv	a0,s3
    80004512:	60e6                	ld	ra,88(sp)
    80004514:	6446                	ld	s0,80(sp)
    80004516:	64a6                	ld	s1,72(sp)
    80004518:	6906                	ld	s2,64(sp)
    8000451a:	79e2                	ld	s3,56(sp)
    8000451c:	7a42                	ld	s4,48(sp)
    8000451e:	7aa2                	ld	s5,40(sp)
    80004520:	6125                	addi	sp,sp,96
    80004522:	8082                	ret

0000000080004524 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004524:	1141                	addi	sp,sp,-16
    80004526:	e406                	sd	ra,8(sp)
    80004528:	e022                	sd	s0,0(sp)
    8000452a:	0800                	addi	s0,sp,16
    8000452c:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000452e:	0035151b          	slliw	a0,a0,0x3
    80004532:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    80004534:	8b89                	andi	a5,a5,2
    80004536:	c399                	beqz	a5,8000453c <flags2perm+0x18>
      perm |= PTE_W;
    80004538:	00456513          	ori	a0,a0,4
    return perm;
}
    8000453c:	60a2                	ld	ra,8(sp)
    8000453e:	6402                	ld	s0,0(sp)
    80004540:	0141                	addi	sp,sp,16
    80004542:	8082                	ret

0000000080004544 <exec>:

int
exec(char *path, char **argv)
{
    80004544:	de010113          	addi	sp,sp,-544
    80004548:	20113c23          	sd	ra,536(sp)
    8000454c:	20813823          	sd	s0,528(sp)
    80004550:	20913423          	sd	s1,520(sp)
    80004554:	21213023          	sd	s2,512(sp)
    80004558:	1400                	addi	s0,sp,544
    8000455a:	892a                	mv	s2,a0
    8000455c:	dea43823          	sd	a0,-528(s0)
    80004560:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004564:	b78fd0ef          	jal	800018dc <myproc>
    80004568:	84aa                	mv	s1,a0

  begin_op();
    8000456a:	d88ff0ef          	jal	80003af2 <begin_op>

  if((ip = namei(path)) == 0){
    8000456e:	854a                	mv	a0,s2
    80004570:	bc0ff0ef          	jal	80003930 <namei>
    80004574:	cd21                	beqz	a0,800045cc <exec+0x88>
    80004576:	fbd2                	sd	s4,496(sp)
    80004578:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000457a:	cc7fe0ef          	jal	80003240 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000457e:	04000713          	li	a4,64
    80004582:	4681                	li	a3,0
    80004584:	e5040613          	addi	a2,s0,-432
    80004588:	4581                	li	a1,0
    8000458a:	8552                	mv	a0,s4
    8000458c:	f0dfe0ef          	jal	80003498 <readi>
    80004590:	04000793          	li	a5,64
    80004594:	00f51a63          	bne	a0,a5,800045a8 <exec+0x64>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004598:	e5042703          	lw	a4,-432(s0)
    8000459c:	464c47b7          	lui	a5,0x464c4
    800045a0:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800045a4:	02f70863          	beq	a4,a5,800045d4 <exec+0x90>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800045a8:	8552                	mv	a0,s4
    800045aa:	ea1fe0ef          	jal	8000344a <iunlockput>
    end_op();
    800045ae:	daeff0ef          	jal	80003b5c <end_op>
  }
  return -1;
    800045b2:	557d                	li	a0,-1
    800045b4:	7a5e                	ld	s4,496(sp)
}
    800045b6:	21813083          	ld	ra,536(sp)
    800045ba:	21013403          	ld	s0,528(sp)
    800045be:	20813483          	ld	s1,520(sp)
    800045c2:	20013903          	ld	s2,512(sp)
    800045c6:	22010113          	addi	sp,sp,544
    800045ca:	8082                	ret
    end_op();
    800045cc:	d90ff0ef          	jal	80003b5c <end_op>
    return -1;
    800045d0:	557d                	li	a0,-1
    800045d2:	b7d5                	j	800045b6 <exec+0x72>
    800045d4:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    800045d6:	8526                	mv	a0,s1
    800045d8:	bacfd0ef          	jal	80001984 <proc_pagetable>
    800045dc:	8b2a                	mv	s6,a0
    800045de:	26050d63          	beqz	a0,80004858 <exec+0x314>
    800045e2:	ffce                	sd	s3,504(sp)
    800045e4:	f7d6                	sd	s5,488(sp)
    800045e6:	efde                	sd	s7,472(sp)
    800045e8:	ebe2                	sd	s8,464(sp)
    800045ea:	e7e6                	sd	s9,456(sp)
    800045ec:	e3ea                	sd	s10,448(sp)
    800045ee:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800045f0:	e7042683          	lw	a3,-400(s0)
    800045f4:	e8845783          	lhu	a5,-376(s0)
    800045f8:	0e078763          	beqz	a5,800046e6 <exec+0x1a2>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800045fc:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800045fe:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004600:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    80004604:	6c85                	lui	s9,0x1
    80004606:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000460a:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    8000460e:	6a85                	lui	s5,0x1
    80004610:	a085                	j	80004670 <exec+0x12c>
      panic("loadseg: address should exist");
    80004612:	00003517          	auipc	a0,0x3
    80004616:	fee50513          	addi	a0,a0,-18 # 80007600 <etext+0x600>
    8000461a:	984fc0ef          	jal	8000079e <panic>
    if(sz - i < PGSIZE)
    8000461e:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004620:	874a                	mv	a4,s2
    80004622:	009c06bb          	addw	a3,s8,s1
    80004626:	4581                	li	a1,0
    80004628:	8552                	mv	a0,s4
    8000462a:	e6ffe0ef          	jal	80003498 <readi>
    8000462e:	22a91963          	bne	s2,a0,80004860 <exec+0x31c>
  for(i = 0; i < sz; i += PGSIZE){
    80004632:	009a84bb          	addw	s1,s5,s1
    80004636:	0334f263          	bgeu	s1,s3,8000465a <exec+0x116>
    pa = walkaddr(pagetable, va + i);
    8000463a:	02049593          	slli	a1,s1,0x20
    8000463e:	9181                	srli	a1,a1,0x20
    80004640:	95de                	add	a1,a1,s7
    80004642:	855a                	mv	a0,s6
    80004644:	9b9fc0ef          	jal	80000ffc <walkaddr>
    80004648:	862a                	mv	a2,a0
    if(pa == 0)
    8000464a:	d561                	beqz	a0,80004612 <exec+0xce>
    if(sz - i < PGSIZE)
    8000464c:	409987bb          	subw	a5,s3,s1
    80004650:	893e                	mv	s2,a5
    80004652:	fcfcf6e3          	bgeu	s9,a5,8000461e <exec+0xda>
    80004656:	8956                	mv	s2,s5
    80004658:	b7d9                	j	8000461e <exec+0xda>
    sz = sz1;
    8000465a:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000465e:	2d05                	addiw	s10,s10,1
    80004660:	e0843783          	ld	a5,-504(s0)
    80004664:	0387869b          	addiw	a3,a5,56
    80004668:	e8845783          	lhu	a5,-376(s0)
    8000466c:	06fd5e63          	bge	s10,a5,800046e8 <exec+0x1a4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004670:	e0d43423          	sd	a3,-504(s0)
    80004674:	876e                	mv	a4,s11
    80004676:	e1840613          	addi	a2,s0,-488
    8000467a:	4581                	li	a1,0
    8000467c:	8552                	mv	a0,s4
    8000467e:	e1bfe0ef          	jal	80003498 <readi>
    80004682:	1db51d63          	bne	a0,s11,8000485c <exec+0x318>
    if(ph.type != ELF_PROG_LOAD)
    80004686:	e1842783          	lw	a5,-488(s0)
    8000468a:	4705                	li	a4,1
    8000468c:	fce799e3          	bne	a5,a4,8000465e <exec+0x11a>
    if(ph.memsz < ph.filesz)
    80004690:	e4043483          	ld	s1,-448(s0)
    80004694:	e3843783          	ld	a5,-456(s0)
    80004698:	1ef4e263          	bltu	s1,a5,8000487c <exec+0x338>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000469c:	e2843783          	ld	a5,-472(s0)
    800046a0:	94be                	add	s1,s1,a5
    800046a2:	1ef4e063          	bltu	s1,a5,80004882 <exec+0x33e>
    if(ph.vaddr % PGSIZE != 0)
    800046a6:	de843703          	ld	a4,-536(s0)
    800046aa:	8ff9                	and	a5,a5,a4
    800046ac:	1c079e63          	bnez	a5,80004888 <exec+0x344>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800046b0:	e1c42503          	lw	a0,-484(s0)
    800046b4:	e71ff0ef          	jal	80004524 <flags2perm>
    800046b8:	86aa                	mv	a3,a0
    800046ba:	8626                	mv	a2,s1
    800046bc:	85ca                	mv	a1,s2
    800046be:	855a                	mv	a0,s6
    800046c0:	ca5fc0ef          	jal	80001364 <uvmalloc>
    800046c4:	dea43c23          	sd	a0,-520(s0)
    800046c8:	1c050363          	beqz	a0,8000488e <exec+0x34a>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800046cc:	e2843b83          	ld	s7,-472(s0)
    800046d0:	e2042c03          	lw	s8,-480(s0)
    800046d4:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800046d8:	00098463          	beqz	s3,800046e0 <exec+0x19c>
    800046dc:	4481                	li	s1,0
    800046de:	bfb1                	j	8000463a <exec+0xf6>
    sz = sz1;
    800046e0:	df843903          	ld	s2,-520(s0)
    800046e4:	bfad                	j	8000465e <exec+0x11a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800046e6:	4901                	li	s2,0
  iunlockput(ip);
    800046e8:	8552                	mv	a0,s4
    800046ea:	d61fe0ef          	jal	8000344a <iunlockput>
  end_op();
    800046ee:	c6eff0ef          	jal	80003b5c <end_op>
  p = myproc();
    800046f2:	9eafd0ef          	jal	800018dc <myproc>
    800046f6:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800046f8:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    800046fc:	6985                	lui	s3,0x1
    800046fe:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004700:	99ca                	add	s3,s3,s2
    80004702:	77fd                	lui	a5,0xfffff
    80004704:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004708:	4691                	li	a3,4
    8000470a:	6609                	lui	a2,0x2
    8000470c:	964e                	add	a2,a2,s3
    8000470e:	85ce                	mv	a1,s3
    80004710:	855a                	mv	a0,s6
    80004712:	c53fc0ef          	jal	80001364 <uvmalloc>
    80004716:	8a2a                	mv	s4,a0
    80004718:	e105                	bnez	a0,80004738 <exec+0x1f4>
    proc_freepagetable(pagetable, sz);
    8000471a:	85ce                	mv	a1,s3
    8000471c:	855a                	mv	a0,s6
    8000471e:	aeafd0ef          	jal	80001a08 <proc_freepagetable>
  return -1;
    80004722:	557d                	li	a0,-1
    80004724:	79fe                	ld	s3,504(sp)
    80004726:	7a5e                	ld	s4,496(sp)
    80004728:	7abe                	ld	s5,488(sp)
    8000472a:	7b1e                	ld	s6,480(sp)
    8000472c:	6bfe                	ld	s7,472(sp)
    8000472e:	6c5e                	ld	s8,464(sp)
    80004730:	6cbe                	ld	s9,456(sp)
    80004732:	6d1e                	ld	s10,448(sp)
    80004734:	7dfa                	ld	s11,440(sp)
    80004736:	b541                	j	800045b6 <exec+0x72>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004738:	75f9                	lui	a1,0xffffe
    8000473a:	95aa                	add	a1,a1,a0
    8000473c:	855a                	mv	a0,s6
    8000473e:	e1dfc0ef          	jal	8000155a <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004742:	7bfd                	lui	s7,0xfffff
    80004744:	9bd2                	add	s7,s7,s4
  for(argc = 0; argv[argc]; argc++) {
    80004746:	e0043783          	ld	a5,-512(s0)
    8000474a:	6388                	ld	a0,0(a5)
  sp = sz;
    8000474c:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    8000474e:	4481                	li	s1,0
    ustack[argc] = sp;
    80004750:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    80004754:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    80004758:	cd21                	beqz	a0,800047b0 <exec+0x26c>
    sp -= strlen(argv[argc]) + 1;
    8000475a:	efcfc0ef          	jal	80000e56 <strlen>
    8000475e:	0015079b          	addiw	a5,a0,1
    80004762:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004766:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    8000476a:	13796563          	bltu	s2,s7,80004894 <exec+0x350>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000476e:	e0043d83          	ld	s11,-512(s0)
    80004772:	000db983          	ld	s3,0(s11)
    80004776:	854e                	mv	a0,s3
    80004778:	edefc0ef          	jal	80000e56 <strlen>
    8000477c:	0015069b          	addiw	a3,a0,1
    80004780:	864e                	mv	a2,s3
    80004782:	85ca                	mv	a1,s2
    80004784:	855a                	mv	a0,s6
    80004786:	dfffc0ef          	jal	80001584 <copyout>
    8000478a:	10054763          	bltz	a0,80004898 <exec+0x354>
    ustack[argc] = sp;
    8000478e:	00349793          	slli	a5,s1,0x3
    80004792:	97e6                	add	a5,a5,s9
    80004794:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb9c0>
  for(argc = 0; argv[argc]; argc++) {
    80004798:	0485                	addi	s1,s1,1
    8000479a:	008d8793          	addi	a5,s11,8
    8000479e:	e0f43023          	sd	a5,-512(s0)
    800047a2:	008db503          	ld	a0,8(s11)
    800047a6:	c509                	beqz	a0,800047b0 <exec+0x26c>
    if(argc >= MAXARG)
    800047a8:	fb8499e3          	bne	s1,s8,8000475a <exec+0x216>
  sz = sz1;
    800047ac:	89d2                	mv	s3,s4
    800047ae:	b7b5                	j	8000471a <exec+0x1d6>
  ustack[argc] = 0;
    800047b0:	00349793          	slli	a5,s1,0x3
    800047b4:	f9078793          	addi	a5,a5,-112
    800047b8:	97a2                	add	a5,a5,s0
    800047ba:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800047be:	00148693          	addi	a3,s1,1
    800047c2:	068e                	slli	a3,a3,0x3
    800047c4:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800047c8:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    800047cc:	89d2                	mv	s3,s4
  if(sp < stackbase)
    800047ce:	f57966e3          	bltu	s2,s7,8000471a <exec+0x1d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800047d2:	e9040613          	addi	a2,s0,-368
    800047d6:	85ca                	mv	a1,s2
    800047d8:	855a                	mv	a0,s6
    800047da:	dabfc0ef          	jal	80001584 <copyout>
    800047de:	f2054ee3          	bltz	a0,8000471a <exec+0x1d6>
  p->trapframe->a1 = sp;
    800047e2:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    800047e6:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800047ea:	df043783          	ld	a5,-528(s0)
    800047ee:	0007c703          	lbu	a4,0(a5)
    800047f2:	cf11                	beqz	a4,8000480e <exec+0x2ca>
    800047f4:	0785                	addi	a5,a5,1
    if(*s == '/')
    800047f6:	02f00693          	li	a3,47
    800047fa:	a029                	j	80004804 <exec+0x2c0>
  for(last=s=path; *s; s++)
    800047fc:	0785                	addi	a5,a5,1
    800047fe:	fff7c703          	lbu	a4,-1(a5)
    80004802:	c711                	beqz	a4,8000480e <exec+0x2ca>
    if(*s == '/')
    80004804:	fed71ce3          	bne	a4,a3,800047fc <exec+0x2b8>
      last = s+1;
    80004808:	def43823          	sd	a5,-528(s0)
    8000480c:	bfc5                	j	800047fc <exec+0x2b8>
  safestrcpy(p->name, last, sizeof(p->name));
    8000480e:	4641                	li	a2,16
    80004810:	df043583          	ld	a1,-528(s0)
    80004814:	158a8513          	addi	a0,s5,344
    80004818:	e08fc0ef          	jal	80000e20 <safestrcpy>
  oldpagetable = p->pagetable;
    8000481c:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004820:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004824:	054ab423          	sd	s4,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004828:	058ab783          	ld	a5,88(s5)
    8000482c:	e6843703          	ld	a4,-408(s0)
    80004830:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004832:	058ab783          	ld	a5,88(s5)
    80004836:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000483a:	85ea                	mv	a1,s10
    8000483c:	9ccfd0ef          	jal	80001a08 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004840:	0004851b          	sext.w	a0,s1
    80004844:	79fe                	ld	s3,504(sp)
    80004846:	7a5e                	ld	s4,496(sp)
    80004848:	7abe                	ld	s5,488(sp)
    8000484a:	7b1e                	ld	s6,480(sp)
    8000484c:	6bfe                	ld	s7,472(sp)
    8000484e:	6c5e                	ld	s8,464(sp)
    80004850:	6cbe                	ld	s9,456(sp)
    80004852:	6d1e                	ld	s10,448(sp)
    80004854:	7dfa                	ld	s11,440(sp)
    80004856:	b385                	j	800045b6 <exec+0x72>
    80004858:	7b1e                	ld	s6,480(sp)
    8000485a:	b3b9                	j	800045a8 <exec+0x64>
    8000485c:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004860:	df843583          	ld	a1,-520(s0)
    80004864:	855a                	mv	a0,s6
    80004866:	9a2fd0ef          	jal	80001a08 <proc_freepagetable>
  if(ip){
    8000486a:	79fe                	ld	s3,504(sp)
    8000486c:	7abe                	ld	s5,488(sp)
    8000486e:	7b1e                	ld	s6,480(sp)
    80004870:	6bfe                	ld	s7,472(sp)
    80004872:	6c5e                	ld	s8,464(sp)
    80004874:	6cbe                	ld	s9,456(sp)
    80004876:	6d1e                	ld	s10,448(sp)
    80004878:	7dfa                	ld	s11,440(sp)
    8000487a:	b33d                	j	800045a8 <exec+0x64>
    8000487c:	df243c23          	sd	s2,-520(s0)
    80004880:	b7c5                	j	80004860 <exec+0x31c>
    80004882:	df243c23          	sd	s2,-520(s0)
    80004886:	bfe9                	j	80004860 <exec+0x31c>
    80004888:	df243c23          	sd	s2,-520(s0)
    8000488c:	bfd1                	j	80004860 <exec+0x31c>
    8000488e:	df243c23          	sd	s2,-520(s0)
    80004892:	b7f9                	j	80004860 <exec+0x31c>
  sz = sz1;
    80004894:	89d2                	mv	s3,s4
    80004896:	b551                	j	8000471a <exec+0x1d6>
    80004898:	89d2                	mv	s3,s4
    8000489a:	b541                	j	8000471a <exec+0x1d6>

000000008000489c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000489c:	7179                	addi	sp,sp,-48
    8000489e:	f406                	sd	ra,40(sp)
    800048a0:	f022                	sd	s0,32(sp)
    800048a2:	ec26                	sd	s1,24(sp)
    800048a4:	e84a                	sd	s2,16(sp)
    800048a6:	1800                	addi	s0,sp,48
    800048a8:	892e                	mv	s2,a1
    800048aa:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800048ac:	fdc40593          	addi	a1,s0,-36
    800048b0:	edffd0ef          	jal	8000278e <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800048b4:	fdc42703          	lw	a4,-36(s0)
    800048b8:	47bd                	li	a5,15
    800048ba:	02e7e963          	bltu	a5,a4,800048ec <argfd+0x50>
    800048be:	81efd0ef          	jal	800018dc <myproc>
    800048c2:	fdc42703          	lw	a4,-36(s0)
    800048c6:	01a70793          	addi	a5,a4,26
    800048ca:	078e                	slli	a5,a5,0x3
    800048cc:	953e                	add	a0,a0,a5
    800048ce:	611c                	ld	a5,0(a0)
    800048d0:	c385                	beqz	a5,800048f0 <argfd+0x54>
    return -1;
  if(pfd)
    800048d2:	00090463          	beqz	s2,800048da <argfd+0x3e>
    *pfd = fd;
    800048d6:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800048da:	4501                	li	a0,0
  if(pf)
    800048dc:	c091                	beqz	s1,800048e0 <argfd+0x44>
    *pf = f;
    800048de:	e09c                	sd	a5,0(s1)
}
    800048e0:	70a2                	ld	ra,40(sp)
    800048e2:	7402                	ld	s0,32(sp)
    800048e4:	64e2                	ld	s1,24(sp)
    800048e6:	6942                	ld	s2,16(sp)
    800048e8:	6145                	addi	sp,sp,48
    800048ea:	8082                	ret
    return -1;
    800048ec:	557d                	li	a0,-1
    800048ee:	bfcd                	j	800048e0 <argfd+0x44>
    800048f0:	557d                	li	a0,-1
    800048f2:	b7fd                	j	800048e0 <argfd+0x44>

00000000800048f4 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800048f4:	1101                	addi	sp,sp,-32
    800048f6:	ec06                	sd	ra,24(sp)
    800048f8:	e822                	sd	s0,16(sp)
    800048fa:	e426                	sd	s1,8(sp)
    800048fc:	1000                	addi	s0,sp,32
    800048fe:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004900:	fddfc0ef          	jal	800018dc <myproc>
    80004904:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004906:	0d050793          	addi	a5,a0,208
    8000490a:	4501                	li	a0,0
    8000490c:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000490e:	6398                	ld	a4,0(a5)
    80004910:	cb19                	beqz	a4,80004926 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004912:	2505                	addiw	a0,a0,1
    80004914:	07a1                	addi	a5,a5,8
    80004916:	fed51ce3          	bne	a0,a3,8000490e <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000491a:	557d                	li	a0,-1
}
    8000491c:	60e2                	ld	ra,24(sp)
    8000491e:	6442                	ld	s0,16(sp)
    80004920:	64a2                	ld	s1,8(sp)
    80004922:	6105                	addi	sp,sp,32
    80004924:	8082                	ret
      p->ofile[fd] = f;
    80004926:	01a50793          	addi	a5,a0,26
    8000492a:	078e                	slli	a5,a5,0x3
    8000492c:	963e                	add	a2,a2,a5
    8000492e:	e204                	sd	s1,0(a2)
      return fd;
    80004930:	b7f5                	j	8000491c <fdalloc+0x28>

0000000080004932 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004932:	715d                	addi	sp,sp,-80
    80004934:	e486                	sd	ra,72(sp)
    80004936:	e0a2                	sd	s0,64(sp)
    80004938:	fc26                	sd	s1,56(sp)
    8000493a:	f84a                	sd	s2,48(sp)
    8000493c:	f44e                	sd	s3,40(sp)
    8000493e:	ec56                	sd	s5,24(sp)
    80004940:	e85a                	sd	s6,16(sp)
    80004942:	0880                	addi	s0,sp,80
    80004944:	8b2e                	mv	s6,a1
    80004946:	89b2                	mv	s3,a2
    80004948:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000494a:	fb040593          	addi	a1,s0,-80
    8000494e:	ffdfe0ef          	jal	8000394a <nameiparent>
    80004952:	84aa                	mv	s1,a0
    80004954:	10050a63          	beqz	a0,80004a68 <create+0x136>
    return 0;

  ilock(dp);
    80004958:	8e9fe0ef          	jal	80003240 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000495c:	4601                	li	a2,0
    8000495e:	fb040593          	addi	a1,s0,-80
    80004962:	8526                	mv	a0,s1
    80004964:	d41fe0ef          	jal	800036a4 <dirlookup>
    80004968:	8aaa                	mv	s5,a0
    8000496a:	c129                	beqz	a0,800049ac <create+0x7a>
    iunlockput(dp);
    8000496c:	8526                	mv	a0,s1
    8000496e:	addfe0ef          	jal	8000344a <iunlockput>
    ilock(ip);
    80004972:	8556                	mv	a0,s5
    80004974:	8cdfe0ef          	jal	80003240 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004978:	4789                	li	a5,2
    8000497a:	02fb1463          	bne	s6,a5,800049a2 <create+0x70>
    8000497e:	044ad783          	lhu	a5,68(s5)
    80004982:	37f9                	addiw	a5,a5,-2
    80004984:	17c2                	slli	a5,a5,0x30
    80004986:	93c1                	srli	a5,a5,0x30
    80004988:	4705                	li	a4,1
    8000498a:	00f76c63          	bltu	a4,a5,800049a2 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000498e:	8556                	mv	a0,s5
    80004990:	60a6                	ld	ra,72(sp)
    80004992:	6406                	ld	s0,64(sp)
    80004994:	74e2                	ld	s1,56(sp)
    80004996:	7942                	ld	s2,48(sp)
    80004998:	79a2                	ld	s3,40(sp)
    8000499a:	6ae2                	ld	s5,24(sp)
    8000499c:	6b42                	ld	s6,16(sp)
    8000499e:	6161                	addi	sp,sp,80
    800049a0:	8082                	ret
    iunlockput(ip);
    800049a2:	8556                	mv	a0,s5
    800049a4:	aa7fe0ef          	jal	8000344a <iunlockput>
    return 0;
    800049a8:	4a81                	li	s5,0
    800049aa:	b7d5                	j	8000498e <create+0x5c>
    800049ac:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    800049ae:	85da                	mv	a1,s6
    800049b0:	4088                	lw	a0,0(s1)
    800049b2:	f1efe0ef          	jal	800030d0 <ialloc>
    800049b6:	8a2a                	mv	s4,a0
    800049b8:	cd15                	beqz	a0,800049f4 <create+0xc2>
  ilock(ip);
    800049ba:	887fe0ef          	jal	80003240 <ilock>
  ip->major = major;
    800049be:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800049c2:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800049c6:	4905                	li	s2,1
    800049c8:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800049cc:	8552                	mv	a0,s4
    800049ce:	fbefe0ef          	jal	8000318c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800049d2:	032b0763          	beq	s6,s2,80004a00 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    800049d6:	004a2603          	lw	a2,4(s4)
    800049da:	fb040593          	addi	a1,s0,-80
    800049de:	8526                	mv	a0,s1
    800049e0:	ea7fe0ef          	jal	80003886 <dirlink>
    800049e4:	06054563          	bltz	a0,80004a4e <create+0x11c>
  iunlockput(dp);
    800049e8:	8526                	mv	a0,s1
    800049ea:	a61fe0ef          	jal	8000344a <iunlockput>
  return ip;
    800049ee:	8ad2                	mv	s5,s4
    800049f0:	7a02                	ld	s4,32(sp)
    800049f2:	bf71                	j	8000498e <create+0x5c>
    iunlockput(dp);
    800049f4:	8526                	mv	a0,s1
    800049f6:	a55fe0ef          	jal	8000344a <iunlockput>
    return 0;
    800049fa:	8ad2                	mv	s5,s4
    800049fc:	7a02                	ld	s4,32(sp)
    800049fe:	bf41                	j	8000498e <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004a00:	004a2603          	lw	a2,4(s4)
    80004a04:	00003597          	auipc	a1,0x3
    80004a08:	c1c58593          	addi	a1,a1,-996 # 80007620 <etext+0x620>
    80004a0c:	8552                	mv	a0,s4
    80004a0e:	e79fe0ef          	jal	80003886 <dirlink>
    80004a12:	02054e63          	bltz	a0,80004a4e <create+0x11c>
    80004a16:	40d0                	lw	a2,4(s1)
    80004a18:	00003597          	auipc	a1,0x3
    80004a1c:	c1058593          	addi	a1,a1,-1008 # 80007628 <etext+0x628>
    80004a20:	8552                	mv	a0,s4
    80004a22:	e65fe0ef          	jal	80003886 <dirlink>
    80004a26:	02054463          	bltz	a0,80004a4e <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004a2a:	004a2603          	lw	a2,4(s4)
    80004a2e:	fb040593          	addi	a1,s0,-80
    80004a32:	8526                	mv	a0,s1
    80004a34:	e53fe0ef          	jal	80003886 <dirlink>
    80004a38:	00054b63          	bltz	a0,80004a4e <create+0x11c>
    dp->nlink++;  // for ".."
    80004a3c:	04a4d783          	lhu	a5,74(s1)
    80004a40:	2785                	addiw	a5,a5,1
    80004a42:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004a46:	8526                	mv	a0,s1
    80004a48:	f44fe0ef          	jal	8000318c <iupdate>
    80004a4c:	bf71                	j	800049e8 <create+0xb6>
  ip->nlink = 0;
    80004a4e:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004a52:	8552                	mv	a0,s4
    80004a54:	f38fe0ef          	jal	8000318c <iupdate>
  iunlockput(ip);
    80004a58:	8552                	mv	a0,s4
    80004a5a:	9f1fe0ef          	jal	8000344a <iunlockput>
  iunlockput(dp);
    80004a5e:	8526                	mv	a0,s1
    80004a60:	9ebfe0ef          	jal	8000344a <iunlockput>
  return 0;
    80004a64:	7a02                	ld	s4,32(sp)
    80004a66:	b725                	j	8000498e <create+0x5c>
    return 0;
    80004a68:	8aaa                	mv	s5,a0
    80004a6a:	b715                	j	8000498e <create+0x5c>

0000000080004a6c <sys_dup>:
{
    80004a6c:	7179                	addi	sp,sp,-48
    80004a6e:	f406                	sd	ra,40(sp)
    80004a70:	f022                	sd	s0,32(sp)
    80004a72:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004a74:	fd840613          	addi	a2,s0,-40
    80004a78:	4581                	li	a1,0
    80004a7a:	4501                	li	a0,0
    80004a7c:	e21ff0ef          	jal	8000489c <argfd>
    return -1;
    80004a80:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004a82:	02054363          	bltz	a0,80004aa8 <sys_dup+0x3c>
    80004a86:	ec26                	sd	s1,24(sp)
    80004a88:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004a8a:	fd843903          	ld	s2,-40(s0)
    80004a8e:	854a                	mv	a0,s2
    80004a90:	e65ff0ef          	jal	800048f4 <fdalloc>
    80004a94:	84aa                	mv	s1,a0
    return -1;
    80004a96:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004a98:	00054d63          	bltz	a0,80004ab2 <sys_dup+0x46>
  filedup(f);
    80004a9c:	854a                	mv	a0,s2
    80004a9e:	c2eff0ef          	jal	80003ecc <filedup>
  return fd;
    80004aa2:	87a6                	mv	a5,s1
    80004aa4:	64e2                	ld	s1,24(sp)
    80004aa6:	6942                	ld	s2,16(sp)
}
    80004aa8:	853e                	mv	a0,a5
    80004aaa:	70a2                	ld	ra,40(sp)
    80004aac:	7402                	ld	s0,32(sp)
    80004aae:	6145                	addi	sp,sp,48
    80004ab0:	8082                	ret
    80004ab2:	64e2                	ld	s1,24(sp)
    80004ab4:	6942                	ld	s2,16(sp)
    80004ab6:	bfcd                	j	80004aa8 <sys_dup+0x3c>

0000000080004ab8 <sys_read>:
{
    80004ab8:	7179                	addi	sp,sp,-48
    80004aba:	f406                	sd	ra,40(sp)
    80004abc:	f022                	sd	s0,32(sp)
    80004abe:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004ac0:	fd840593          	addi	a1,s0,-40
    80004ac4:	4505                	li	a0,1
    80004ac6:	ce5fd0ef          	jal	800027aa <argaddr>
  argint(2, &n);
    80004aca:	fe440593          	addi	a1,s0,-28
    80004ace:	4509                	li	a0,2
    80004ad0:	cbffd0ef          	jal	8000278e <argint>
  if(argfd(0, 0, &f) < 0)
    80004ad4:	fe840613          	addi	a2,s0,-24
    80004ad8:	4581                	li	a1,0
    80004ada:	4501                	li	a0,0
    80004adc:	dc1ff0ef          	jal	8000489c <argfd>
    80004ae0:	87aa                	mv	a5,a0
    return -1;
    80004ae2:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004ae4:	0007ca63          	bltz	a5,80004af8 <sys_read+0x40>
  return fileread(f, p, n);
    80004ae8:	fe442603          	lw	a2,-28(s0)
    80004aec:	fd843583          	ld	a1,-40(s0)
    80004af0:	fe843503          	ld	a0,-24(s0)
    80004af4:	d3eff0ef          	jal	80004032 <fileread>
}
    80004af8:	70a2                	ld	ra,40(sp)
    80004afa:	7402                	ld	s0,32(sp)
    80004afc:	6145                	addi	sp,sp,48
    80004afe:	8082                	ret

0000000080004b00 <sys_write>:
{
    80004b00:	7179                	addi	sp,sp,-48
    80004b02:	f406                	sd	ra,40(sp)
    80004b04:	f022                	sd	s0,32(sp)
    80004b06:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004b08:	fd840593          	addi	a1,s0,-40
    80004b0c:	4505                	li	a0,1
    80004b0e:	c9dfd0ef          	jal	800027aa <argaddr>
  argint(2, &n);
    80004b12:	fe440593          	addi	a1,s0,-28
    80004b16:	4509                	li	a0,2
    80004b18:	c77fd0ef          	jal	8000278e <argint>
  if(argfd(0, 0, &f) < 0)
    80004b1c:	fe840613          	addi	a2,s0,-24
    80004b20:	4581                	li	a1,0
    80004b22:	4501                	li	a0,0
    80004b24:	d79ff0ef          	jal	8000489c <argfd>
    80004b28:	87aa                	mv	a5,a0
    return -1;
    80004b2a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004b2c:	0007ca63          	bltz	a5,80004b40 <sys_write+0x40>
  return filewrite(f, p, n);
    80004b30:	fe442603          	lw	a2,-28(s0)
    80004b34:	fd843583          	ld	a1,-40(s0)
    80004b38:	fe843503          	ld	a0,-24(s0)
    80004b3c:	db4ff0ef          	jal	800040f0 <filewrite>
}
    80004b40:	70a2                	ld	ra,40(sp)
    80004b42:	7402                	ld	s0,32(sp)
    80004b44:	6145                	addi	sp,sp,48
    80004b46:	8082                	ret

0000000080004b48 <sys_close>:
{
    80004b48:	1101                	addi	sp,sp,-32
    80004b4a:	ec06                	sd	ra,24(sp)
    80004b4c:	e822                	sd	s0,16(sp)
    80004b4e:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004b50:	fe040613          	addi	a2,s0,-32
    80004b54:	fec40593          	addi	a1,s0,-20
    80004b58:	4501                	li	a0,0
    80004b5a:	d43ff0ef          	jal	8000489c <argfd>
    return -1;
    80004b5e:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004b60:	02054063          	bltz	a0,80004b80 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004b64:	d79fc0ef          	jal	800018dc <myproc>
    80004b68:	fec42783          	lw	a5,-20(s0)
    80004b6c:	07e9                	addi	a5,a5,26
    80004b6e:	078e                	slli	a5,a5,0x3
    80004b70:	953e                	add	a0,a0,a5
    80004b72:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004b76:	fe043503          	ld	a0,-32(s0)
    80004b7a:	b98ff0ef          	jal	80003f12 <fileclose>
  return 0;
    80004b7e:	4781                	li	a5,0
}
    80004b80:	853e                	mv	a0,a5
    80004b82:	60e2                	ld	ra,24(sp)
    80004b84:	6442                	ld	s0,16(sp)
    80004b86:	6105                	addi	sp,sp,32
    80004b88:	8082                	ret

0000000080004b8a <sys_fstat>:
{
    80004b8a:	1101                	addi	sp,sp,-32
    80004b8c:	ec06                	sd	ra,24(sp)
    80004b8e:	e822                	sd	s0,16(sp)
    80004b90:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004b92:	fe040593          	addi	a1,s0,-32
    80004b96:	4505                	li	a0,1
    80004b98:	c13fd0ef          	jal	800027aa <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004b9c:	fe840613          	addi	a2,s0,-24
    80004ba0:	4581                	li	a1,0
    80004ba2:	4501                	li	a0,0
    80004ba4:	cf9ff0ef          	jal	8000489c <argfd>
    80004ba8:	87aa                	mv	a5,a0
    return -1;
    80004baa:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004bac:	0007c863          	bltz	a5,80004bbc <sys_fstat+0x32>
  return filestat(f, st);
    80004bb0:	fe043583          	ld	a1,-32(s0)
    80004bb4:	fe843503          	ld	a0,-24(s0)
    80004bb8:	c18ff0ef          	jal	80003fd0 <filestat>
}
    80004bbc:	60e2                	ld	ra,24(sp)
    80004bbe:	6442                	ld	s0,16(sp)
    80004bc0:	6105                	addi	sp,sp,32
    80004bc2:	8082                	ret

0000000080004bc4 <sys_link>:
{
    80004bc4:	7169                	addi	sp,sp,-304
    80004bc6:	f606                	sd	ra,296(sp)
    80004bc8:	f222                	sd	s0,288(sp)
    80004bca:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004bcc:	08000613          	li	a2,128
    80004bd0:	ed040593          	addi	a1,s0,-304
    80004bd4:	4501                	li	a0,0
    80004bd6:	bf1fd0ef          	jal	800027c6 <argstr>
    return -1;
    80004bda:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004bdc:	0c054e63          	bltz	a0,80004cb8 <sys_link+0xf4>
    80004be0:	08000613          	li	a2,128
    80004be4:	f5040593          	addi	a1,s0,-176
    80004be8:	4505                	li	a0,1
    80004bea:	bddfd0ef          	jal	800027c6 <argstr>
    return -1;
    80004bee:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004bf0:	0c054463          	bltz	a0,80004cb8 <sys_link+0xf4>
    80004bf4:	ee26                	sd	s1,280(sp)
  begin_op();
    80004bf6:	efdfe0ef          	jal	80003af2 <begin_op>
  if((ip = namei(old)) == 0){
    80004bfa:	ed040513          	addi	a0,s0,-304
    80004bfe:	d33fe0ef          	jal	80003930 <namei>
    80004c02:	84aa                	mv	s1,a0
    80004c04:	c53d                	beqz	a0,80004c72 <sys_link+0xae>
  ilock(ip);
    80004c06:	e3afe0ef          	jal	80003240 <ilock>
  if(ip->type == T_DIR){
    80004c0a:	04449703          	lh	a4,68(s1)
    80004c0e:	4785                	li	a5,1
    80004c10:	06f70663          	beq	a4,a5,80004c7c <sys_link+0xb8>
    80004c14:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004c16:	04a4d783          	lhu	a5,74(s1)
    80004c1a:	2785                	addiw	a5,a5,1
    80004c1c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004c20:	8526                	mv	a0,s1
    80004c22:	d6afe0ef          	jal	8000318c <iupdate>
  iunlock(ip);
    80004c26:	8526                	mv	a0,s1
    80004c28:	ec6fe0ef          	jal	800032ee <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004c2c:	fd040593          	addi	a1,s0,-48
    80004c30:	f5040513          	addi	a0,s0,-176
    80004c34:	d17fe0ef          	jal	8000394a <nameiparent>
    80004c38:	892a                	mv	s2,a0
    80004c3a:	cd21                	beqz	a0,80004c92 <sys_link+0xce>
  ilock(dp);
    80004c3c:	e04fe0ef          	jal	80003240 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004c40:	00092703          	lw	a4,0(s2)
    80004c44:	409c                	lw	a5,0(s1)
    80004c46:	04f71363          	bne	a4,a5,80004c8c <sys_link+0xc8>
    80004c4a:	40d0                	lw	a2,4(s1)
    80004c4c:	fd040593          	addi	a1,s0,-48
    80004c50:	854a                	mv	a0,s2
    80004c52:	c35fe0ef          	jal	80003886 <dirlink>
    80004c56:	02054b63          	bltz	a0,80004c8c <sys_link+0xc8>
  iunlockput(dp);
    80004c5a:	854a                	mv	a0,s2
    80004c5c:	feefe0ef          	jal	8000344a <iunlockput>
  iput(ip);
    80004c60:	8526                	mv	a0,s1
    80004c62:	f60fe0ef          	jal	800033c2 <iput>
  end_op();
    80004c66:	ef7fe0ef          	jal	80003b5c <end_op>
  return 0;
    80004c6a:	4781                	li	a5,0
    80004c6c:	64f2                	ld	s1,280(sp)
    80004c6e:	6952                	ld	s2,272(sp)
    80004c70:	a0a1                	j	80004cb8 <sys_link+0xf4>
    end_op();
    80004c72:	eebfe0ef          	jal	80003b5c <end_op>
    return -1;
    80004c76:	57fd                	li	a5,-1
    80004c78:	64f2                	ld	s1,280(sp)
    80004c7a:	a83d                	j	80004cb8 <sys_link+0xf4>
    iunlockput(ip);
    80004c7c:	8526                	mv	a0,s1
    80004c7e:	fccfe0ef          	jal	8000344a <iunlockput>
    end_op();
    80004c82:	edbfe0ef          	jal	80003b5c <end_op>
    return -1;
    80004c86:	57fd                	li	a5,-1
    80004c88:	64f2                	ld	s1,280(sp)
    80004c8a:	a03d                	j	80004cb8 <sys_link+0xf4>
    iunlockput(dp);
    80004c8c:	854a                	mv	a0,s2
    80004c8e:	fbcfe0ef          	jal	8000344a <iunlockput>
  ilock(ip);
    80004c92:	8526                	mv	a0,s1
    80004c94:	dacfe0ef          	jal	80003240 <ilock>
  ip->nlink--;
    80004c98:	04a4d783          	lhu	a5,74(s1)
    80004c9c:	37fd                	addiw	a5,a5,-1
    80004c9e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004ca2:	8526                	mv	a0,s1
    80004ca4:	ce8fe0ef          	jal	8000318c <iupdate>
  iunlockput(ip);
    80004ca8:	8526                	mv	a0,s1
    80004caa:	fa0fe0ef          	jal	8000344a <iunlockput>
  end_op();
    80004cae:	eaffe0ef          	jal	80003b5c <end_op>
  return -1;
    80004cb2:	57fd                	li	a5,-1
    80004cb4:	64f2                	ld	s1,280(sp)
    80004cb6:	6952                	ld	s2,272(sp)
}
    80004cb8:	853e                	mv	a0,a5
    80004cba:	70b2                	ld	ra,296(sp)
    80004cbc:	7412                	ld	s0,288(sp)
    80004cbe:	6155                	addi	sp,sp,304
    80004cc0:	8082                	ret

0000000080004cc2 <sys_unlink>:
{
    80004cc2:	7111                	addi	sp,sp,-256
    80004cc4:	fd86                	sd	ra,248(sp)
    80004cc6:	f9a2                	sd	s0,240(sp)
    80004cc8:	0200                	addi	s0,sp,256
  if(argstr(0, path, MAXPATH) < 0)
    80004cca:	08000613          	li	a2,128
    80004cce:	f2040593          	addi	a1,s0,-224
    80004cd2:	4501                	li	a0,0
    80004cd4:	af3fd0ef          	jal	800027c6 <argstr>
    80004cd8:	16054663          	bltz	a0,80004e44 <sys_unlink+0x182>
    80004cdc:	f5a6                	sd	s1,232(sp)
  begin_op();
    80004cde:	e15fe0ef          	jal	80003af2 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004ce2:	fa040593          	addi	a1,s0,-96
    80004ce6:	f2040513          	addi	a0,s0,-224
    80004cea:	c61fe0ef          	jal	8000394a <nameiparent>
    80004cee:	84aa                	mv	s1,a0
    80004cf0:	c955                	beqz	a0,80004da4 <sys_unlink+0xe2>
  ilock(dp);
    80004cf2:	d4efe0ef          	jal	80003240 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004cf6:	00003597          	auipc	a1,0x3
    80004cfa:	92a58593          	addi	a1,a1,-1750 # 80007620 <etext+0x620>
    80004cfe:	fa040513          	addi	a0,s0,-96
    80004d02:	98dfe0ef          	jal	8000368e <namecmp>
    80004d06:	12050463          	beqz	a0,80004e2e <sys_unlink+0x16c>
    80004d0a:	00003597          	auipc	a1,0x3
    80004d0e:	91e58593          	addi	a1,a1,-1762 # 80007628 <etext+0x628>
    80004d12:	fa040513          	addi	a0,s0,-96
    80004d16:	979fe0ef          	jal	8000368e <namecmp>
    80004d1a:	10050a63          	beqz	a0,80004e2e <sys_unlink+0x16c>
    80004d1e:	f1ca                	sd	s2,224(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004d20:	f1c40613          	addi	a2,s0,-228
    80004d24:	fa040593          	addi	a1,s0,-96
    80004d28:	8526                	mv	a0,s1
    80004d2a:	97bfe0ef          	jal	800036a4 <dirlookup>
    80004d2e:	892a                	mv	s2,a0
    80004d30:	0e050e63          	beqz	a0,80004e2c <sys_unlink+0x16a>
    80004d34:	edce                	sd	s3,216(sp)
  ilock(ip);
    80004d36:	d0afe0ef          	jal	80003240 <ilock>
  if(ip->nlink < 1)
    80004d3a:	04a91783          	lh	a5,74(s2)
    80004d3e:	06f05863          	blez	a5,80004dae <sys_unlink+0xec>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004d42:	04491703          	lh	a4,68(s2)
    80004d46:	4785                	li	a5,1
    80004d48:	06f70b63          	beq	a4,a5,80004dbe <sys_unlink+0xfc>
  memset(&de, 0, sizeof(de));
    80004d4c:	fb040993          	addi	s3,s0,-80
    80004d50:	4641                	li	a2,16
    80004d52:	4581                	li	a1,0
    80004d54:	854e                	mv	a0,s3
    80004d56:	f79fb0ef          	jal	80000cce <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004d5a:	4741                	li	a4,16
    80004d5c:	f1c42683          	lw	a3,-228(s0)
    80004d60:	864e                	mv	a2,s3
    80004d62:	4581                	li	a1,0
    80004d64:	8526                	mv	a0,s1
    80004d66:	825fe0ef          	jal	8000358a <writei>
    80004d6a:	47c1                	li	a5,16
    80004d6c:	08f51f63          	bne	a0,a5,80004e0a <sys_unlink+0x148>
  if(ip->type == T_DIR){
    80004d70:	04491703          	lh	a4,68(s2)
    80004d74:	4785                	li	a5,1
    80004d76:	0af70263          	beq	a4,a5,80004e1a <sys_unlink+0x158>
  iunlockput(dp);
    80004d7a:	8526                	mv	a0,s1
    80004d7c:	ecefe0ef          	jal	8000344a <iunlockput>
  ip->nlink--;
    80004d80:	04a95783          	lhu	a5,74(s2)
    80004d84:	37fd                	addiw	a5,a5,-1
    80004d86:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004d8a:	854a                	mv	a0,s2
    80004d8c:	c00fe0ef          	jal	8000318c <iupdate>
  iunlockput(ip);
    80004d90:	854a                	mv	a0,s2
    80004d92:	eb8fe0ef          	jal	8000344a <iunlockput>
  end_op();
    80004d96:	dc7fe0ef          	jal	80003b5c <end_op>
  return 0;
    80004d9a:	4501                	li	a0,0
    80004d9c:	74ae                	ld	s1,232(sp)
    80004d9e:	790e                	ld	s2,224(sp)
    80004da0:	69ee                	ld	s3,216(sp)
    80004da2:	a869                	j	80004e3c <sys_unlink+0x17a>
    end_op();
    80004da4:	db9fe0ef          	jal	80003b5c <end_op>
    return -1;
    80004da8:	557d                	li	a0,-1
    80004daa:	74ae                	ld	s1,232(sp)
    80004dac:	a841                	j	80004e3c <sys_unlink+0x17a>
    80004dae:	e9d2                	sd	s4,208(sp)
    80004db0:	e5d6                	sd	s5,200(sp)
    panic("unlink: nlink < 1");
    80004db2:	00003517          	auipc	a0,0x3
    80004db6:	87e50513          	addi	a0,a0,-1922 # 80007630 <etext+0x630>
    80004dba:	9e5fb0ef          	jal	8000079e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004dbe:	04c92703          	lw	a4,76(s2)
    80004dc2:	02000793          	li	a5,32
    80004dc6:	f8e7f3e3          	bgeu	a5,a4,80004d4c <sys_unlink+0x8a>
    80004dca:	e9d2                	sd	s4,208(sp)
    80004dcc:	e5d6                	sd	s5,200(sp)
    80004dce:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004dd0:	f0840a93          	addi	s5,s0,-248
    80004dd4:	4a41                	li	s4,16
    80004dd6:	8752                	mv	a4,s4
    80004dd8:	86ce                	mv	a3,s3
    80004dda:	8656                	mv	a2,s5
    80004ddc:	4581                	li	a1,0
    80004dde:	854a                	mv	a0,s2
    80004de0:	eb8fe0ef          	jal	80003498 <readi>
    80004de4:	01451d63          	bne	a0,s4,80004dfe <sys_unlink+0x13c>
    if(de.inum != 0)
    80004de8:	f0845783          	lhu	a5,-248(s0)
    80004dec:	efb1                	bnez	a5,80004e48 <sys_unlink+0x186>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004dee:	29c1                	addiw	s3,s3,16
    80004df0:	04c92783          	lw	a5,76(s2)
    80004df4:	fef9e1e3          	bltu	s3,a5,80004dd6 <sys_unlink+0x114>
    80004df8:	6a4e                	ld	s4,208(sp)
    80004dfa:	6aae                	ld	s5,200(sp)
    80004dfc:	bf81                	j	80004d4c <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80004dfe:	00003517          	auipc	a0,0x3
    80004e02:	84a50513          	addi	a0,a0,-1974 # 80007648 <etext+0x648>
    80004e06:	999fb0ef          	jal	8000079e <panic>
    80004e0a:	e9d2                	sd	s4,208(sp)
    80004e0c:	e5d6                	sd	s5,200(sp)
    panic("unlink: writei");
    80004e0e:	00003517          	auipc	a0,0x3
    80004e12:	85250513          	addi	a0,a0,-1966 # 80007660 <etext+0x660>
    80004e16:	989fb0ef          	jal	8000079e <panic>
    dp->nlink--;
    80004e1a:	04a4d783          	lhu	a5,74(s1)
    80004e1e:	37fd                	addiw	a5,a5,-1
    80004e20:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004e24:	8526                	mv	a0,s1
    80004e26:	b66fe0ef          	jal	8000318c <iupdate>
    80004e2a:	bf81                	j	80004d7a <sys_unlink+0xb8>
    80004e2c:	790e                	ld	s2,224(sp)
  iunlockput(dp);
    80004e2e:	8526                	mv	a0,s1
    80004e30:	e1afe0ef          	jal	8000344a <iunlockput>
  end_op();
    80004e34:	d29fe0ef          	jal	80003b5c <end_op>
  return -1;
    80004e38:	557d                	li	a0,-1
    80004e3a:	74ae                	ld	s1,232(sp)
}
    80004e3c:	70ee                	ld	ra,248(sp)
    80004e3e:	744e                	ld	s0,240(sp)
    80004e40:	6111                	addi	sp,sp,256
    80004e42:	8082                	ret
    return -1;
    80004e44:	557d                	li	a0,-1
    80004e46:	bfdd                	j	80004e3c <sys_unlink+0x17a>
    iunlockput(ip);
    80004e48:	854a                	mv	a0,s2
    80004e4a:	e00fe0ef          	jal	8000344a <iunlockput>
    goto bad;
    80004e4e:	790e                	ld	s2,224(sp)
    80004e50:	69ee                	ld	s3,216(sp)
    80004e52:	6a4e                	ld	s4,208(sp)
    80004e54:	6aae                	ld	s5,200(sp)
    80004e56:	bfe1                	j	80004e2e <sys_unlink+0x16c>

0000000080004e58 <sys_open>:

uint64
sys_open(void)
{
    80004e58:	7131                	addi	sp,sp,-192
    80004e5a:	fd06                	sd	ra,184(sp)
    80004e5c:	f922                	sd	s0,176(sp)
    80004e5e:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004e60:	f4c40593          	addi	a1,s0,-180
    80004e64:	4505                	li	a0,1
    80004e66:	929fd0ef          	jal	8000278e <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004e6a:	08000613          	li	a2,128
    80004e6e:	f5040593          	addi	a1,s0,-176
    80004e72:	4501                	li	a0,0
    80004e74:	953fd0ef          	jal	800027c6 <argstr>
    80004e78:	87aa                	mv	a5,a0
    return -1;
    80004e7a:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004e7c:	0a07c363          	bltz	a5,80004f22 <sys_open+0xca>
    80004e80:	f526                	sd	s1,168(sp)

  begin_op();
    80004e82:	c71fe0ef          	jal	80003af2 <begin_op>

  if(omode & O_CREATE){
    80004e86:	f4c42783          	lw	a5,-180(s0)
    80004e8a:	2007f793          	andi	a5,a5,512
    80004e8e:	c3dd                	beqz	a5,80004f34 <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    80004e90:	4681                	li	a3,0
    80004e92:	4601                	li	a2,0
    80004e94:	4589                	li	a1,2
    80004e96:	f5040513          	addi	a0,s0,-176
    80004e9a:	a99ff0ef          	jal	80004932 <create>
    80004e9e:	84aa                	mv	s1,a0
    if(ip == 0){
    80004ea0:	c549                	beqz	a0,80004f2a <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004ea2:	04449703          	lh	a4,68(s1)
    80004ea6:	478d                	li	a5,3
    80004ea8:	00f71763          	bne	a4,a5,80004eb6 <sys_open+0x5e>
    80004eac:	0464d703          	lhu	a4,70(s1)
    80004eb0:	47a5                	li	a5,9
    80004eb2:	0ae7ee63          	bltu	a5,a4,80004f6e <sys_open+0x116>
    80004eb6:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004eb8:	fb7fe0ef          	jal	80003e6e <filealloc>
    80004ebc:	892a                	mv	s2,a0
    80004ebe:	c561                	beqz	a0,80004f86 <sys_open+0x12e>
    80004ec0:	ed4e                	sd	s3,152(sp)
    80004ec2:	a33ff0ef          	jal	800048f4 <fdalloc>
    80004ec6:	89aa                	mv	s3,a0
    80004ec8:	0a054b63          	bltz	a0,80004f7e <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004ecc:	04449703          	lh	a4,68(s1)
    80004ed0:	478d                	li	a5,3
    80004ed2:	0cf70363          	beq	a4,a5,80004f98 <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004ed6:	4789                	li	a5,2
    80004ed8:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80004edc:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80004ee0:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80004ee4:	f4c42783          	lw	a5,-180(s0)
    80004ee8:	0017f713          	andi	a4,a5,1
    80004eec:	00174713          	xori	a4,a4,1
    80004ef0:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004ef4:	0037f713          	andi	a4,a5,3
    80004ef8:	00e03733          	snez	a4,a4
    80004efc:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004f00:	4007f793          	andi	a5,a5,1024
    80004f04:	c791                	beqz	a5,80004f10 <sys_open+0xb8>
    80004f06:	04449703          	lh	a4,68(s1)
    80004f0a:	4789                	li	a5,2
    80004f0c:	08f70d63          	beq	a4,a5,80004fa6 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    80004f10:	8526                	mv	a0,s1
    80004f12:	bdcfe0ef          	jal	800032ee <iunlock>
  end_op();
    80004f16:	c47fe0ef          	jal	80003b5c <end_op>

  return fd;
    80004f1a:	854e                	mv	a0,s3
    80004f1c:	74aa                	ld	s1,168(sp)
    80004f1e:	790a                	ld	s2,160(sp)
    80004f20:	69ea                	ld	s3,152(sp)
}
    80004f22:	70ea                	ld	ra,184(sp)
    80004f24:	744a                	ld	s0,176(sp)
    80004f26:	6129                	addi	sp,sp,192
    80004f28:	8082                	ret
      end_op();
    80004f2a:	c33fe0ef          	jal	80003b5c <end_op>
      return -1;
    80004f2e:	557d                	li	a0,-1
    80004f30:	74aa                	ld	s1,168(sp)
    80004f32:	bfc5                	j	80004f22 <sys_open+0xca>
    if((ip = namei(path)) == 0){
    80004f34:	f5040513          	addi	a0,s0,-176
    80004f38:	9f9fe0ef          	jal	80003930 <namei>
    80004f3c:	84aa                	mv	s1,a0
    80004f3e:	c11d                	beqz	a0,80004f64 <sys_open+0x10c>
    ilock(ip);
    80004f40:	b00fe0ef          	jal	80003240 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004f44:	04449703          	lh	a4,68(s1)
    80004f48:	4785                	li	a5,1
    80004f4a:	f4f71ce3          	bne	a4,a5,80004ea2 <sys_open+0x4a>
    80004f4e:	f4c42783          	lw	a5,-180(s0)
    80004f52:	d3b5                	beqz	a5,80004eb6 <sys_open+0x5e>
      iunlockput(ip);
    80004f54:	8526                	mv	a0,s1
    80004f56:	cf4fe0ef          	jal	8000344a <iunlockput>
      end_op();
    80004f5a:	c03fe0ef          	jal	80003b5c <end_op>
      return -1;
    80004f5e:	557d                	li	a0,-1
    80004f60:	74aa                	ld	s1,168(sp)
    80004f62:	b7c1                	j	80004f22 <sys_open+0xca>
      end_op();
    80004f64:	bf9fe0ef          	jal	80003b5c <end_op>
      return -1;
    80004f68:	557d                	li	a0,-1
    80004f6a:	74aa                	ld	s1,168(sp)
    80004f6c:	bf5d                	j	80004f22 <sys_open+0xca>
    iunlockput(ip);
    80004f6e:	8526                	mv	a0,s1
    80004f70:	cdafe0ef          	jal	8000344a <iunlockput>
    end_op();
    80004f74:	be9fe0ef          	jal	80003b5c <end_op>
    return -1;
    80004f78:	557d                	li	a0,-1
    80004f7a:	74aa                	ld	s1,168(sp)
    80004f7c:	b75d                	j	80004f22 <sys_open+0xca>
      fileclose(f);
    80004f7e:	854a                	mv	a0,s2
    80004f80:	f93fe0ef          	jal	80003f12 <fileclose>
    80004f84:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80004f86:	8526                	mv	a0,s1
    80004f88:	cc2fe0ef          	jal	8000344a <iunlockput>
    end_op();
    80004f8c:	bd1fe0ef          	jal	80003b5c <end_op>
    return -1;
    80004f90:	557d                	li	a0,-1
    80004f92:	74aa                	ld	s1,168(sp)
    80004f94:	790a                	ld	s2,160(sp)
    80004f96:	b771                	j	80004f22 <sys_open+0xca>
    f->type = FD_DEVICE;
    80004f98:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80004f9c:	04649783          	lh	a5,70(s1)
    80004fa0:	02f91223          	sh	a5,36(s2)
    80004fa4:	bf35                	j	80004ee0 <sys_open+0x88>
    itrunc(ip);
    80004fa6:	8526                	mv	a0,s1
    80004fa8:	b86fe0ef          	jal	8000332e <itrunc>
    80004fac:	b795                	j	80004f10 <sys_open+0xb8>

0000000080004fae <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80004fae:	7175                	addi	sp,sp,-144
    80004fb0:	e506                	sd	ra,136(sp)
    80004fb2:	e122                	sd	s0,128(sp)
    80004fb4:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004fb6:	b3dfe0ef          	jal	80003af2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004fba:	08000613          	li	a2,128
    80004fbe:	f7040593          	addi	a1,s0,-144
    80004fc2:	4501                	li	a0,0
    80004fc4:	803fd0ef          	jal	800027c6 <argstr>
    80004fc8:	02054363          	bltz	a0,80004fee <sys_mkdir+0x40>
    80004fcc:	4681                	li	a3,0
    80004fce:	4601                	li	a2,0
    80004fd0:	4585                	li	a1,1
    80004fd2:	f7040513          	addi	a0,s0,-144
    80004fd6:	95dff0ef          	jal	80004932 <create>
    80004fda:	c911                	beqz	a0,80004fee <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004fdc:	c6efe0ef          	jal	8000344a <iunlockput>
  end_op();
    80004fe0:	b7dfe0ef          	jal	80003b5c <end_op>
  return 0;
    80004fe4:	4501                	li	a0,0
}
    80004fe6:	60aa                	ld	ra,136(sp)
    80004fe8:	640a                	ld	s0,128(sp)
    80004fea:	6149                	addi	sp,sp,144
    80004fec:	8082                	ret
    end_op();
    80004fee:	b6ffe0ef          	jal	80003b5c <end_op>
    return -1;
    80004ff2:	557d                	li	a0,-1
    80004ff4:	bfcd                	j	80004fe6 <sys_mkdir+0x38>

0000000080004ff6 <sys_mknod>:

uint64
sys_mknod(void)
{
    80004ff6:	7135                	addi	sp,sp,-160
    80004ff8:	ed06                	sd	ra,152(sp)
    80004ffa:	e922                	sd	s0,144(sp)
    80004ffc:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80004ffe:	af5fe0ef          	jal	80003af2 <begin_op>
  argint(1, &major);
    80005002:	f6c40593          	addi	a1,s0,-148
    80005006:	4505                	li	a0,1
    80005008:	f86fd0ef          	jal	8000278e <argint>
  argint(2, &minor);
    8000500c:	f6840593          	addi	a1,s0,-152
    80005010:	4509                	li	a0,2
    80005012:	f7cfd0ef          	jal	8000278e <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005016:	08000613          	li	a2,128
    8000501a:	f7040593          	addi	a1,s0,-144
    8000501e:	4501                	li	a0,0
    80005020:	fa6fd0ef          	jal	800027c6 <argstr>
    80005024:	02054563          	bltz	a0,8000504e <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005028:	f6841683          	lh	a3,-152(s0)
    8000502c:	f6c41603          	lh	a2,-148(s0)
    80005030:	458d                	li	a1,3
    80005032:	f7040513          	addi	a0,s0,-144
    80005036:	8fdff0ef          	jal	80004932 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000503a:	c911                	beqz	a0,8000504e <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000503c:	c0efe0ef          	jal	8000344a <iunlockput>
  end_op();
    80005040:	b1dfe0ef          	jal	80003b5c <end_op>
  return 0;
    80005044:	4501                	li	a0,0
}
    80005046:	60ea                	ld	ra,152(sp)
    80005048:	644a                	ld	s0,144(sp)
    8000504a:	610d                	addi	sp,sp,160
    8000504c:	8082                	ret
    end_op();
    8000504e:	b0ffe0ef          	jal	80003b5c <end_op>
    return -1;
    80005052:	557d                	li	a0,-1
    80005054:	bfcd                	j	80005046 <sys_mknod+0x50>

0000000080005056 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005056:	7135                	addi	sp,sp,-160
    80005058:	ed06                	sd	ra,152(sp)
    8000505a:	e922                	sd	s0,144(sp)
    8000505c:	e14a                	sd	s2,128(sp)
    8000505e:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005060:	87dfc0ef          	jal	800018dc <myproc>
    80005064:	892a                	mv	s2,a0
  
  begin_op();
    80005066:	a8dfe0ef          	jal	80003af2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000506a:	08000613          	li	a2,128
    8000506e:	f6040593          	addi	a1,s0,-160
    80005072:	4501                	li	a0,0
    80005074:	f52fd0ef          	jal	800027c6 <argstr>
    80005078:	04054363          	bltz	a0,800050be <sys_chdir+0x68>
    8000507c:	e526                	sd	s1,136(sp)
    8000507e:	f6040513          	addi	a0,s0,-160
    80005082:	8affe0ef          	jal	80003930 <namei>
    80005086:	84aa                	mv	s1,a0
    80005088:	c915                	beqz	a0,800050bc <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    8000508a:	9b6fe0ef          	jal	80003240 <ilock>
  if(ip->type != T_DIR){
    8000508e:	04449703          	lh	a4,68(s1)
    80005092:	4785                	li	a5,1
    80005094:	02f71963          	bne	a4,a5,800050c6 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005098:	8526                	mv	a0,s1
    8000509a:	a54fe0ef          	jal	800032ee <iunlock>
  iput(p->cwd);
    8000509e:	15093503          	ld	a0,336(s2)
    800050a2:	b20fe0ef          	jal	800033c2 <iput>
  end_op();
    800050a6:	ab7fe0ef          	jal	80003b5c <end_op>
  p->cwd = ip;
    800050aa:	14993823          	sd	s1,336(s2)
  return 0;
    800050ae:	4501                	li	a0,0
    800050b0:	64aa                	ld	s1,136(sp)
}
    800050b2:	60ea                	ld	ra,152(sp)
    800050b4:	644a                	ld	s0,144(sp)
    800050b6:	690a                	ld	s2,128(sp)
    800050b8:	610d                	addi	sp,sp,160
    800050ba:	8082                	ret
    800050bc:	64aa                	ld	s1,136(sp)
    end_op();
    800050be:	a9ffe0ef          	jal	80003b5c <end_op>
    return -1;
    800050c2:	557d                	li	a0,-1
    800050c4:	b7fd                	j	800050b2 <sys_chdir+0x5c>
    iunlockput(ip);
    800050c6:	8526                	mv	a0,s1
    800050c8:	b82fe0ef          	jal	8000344a <iunlockput>
    end_op();
    800050cc:	a91fe0ef          	jal	80003b5c <end_op>
    return -1;
    800050d0:	557d                	li	a0,-1
    800050d2:	64aa                	ld	s1,136(sp)
    800050d4:	bff9                	j	800050b2 <sys_chdir+0x5c>

00000000800050d6 <sys_exec>:

uint64
sys_exec(void)
{
    800050d6:	7105                	addi	sp,sp,-480
    800050d8:	ef86                	sd	ra,472(sp)
    800050da:	eba2                	sd	s0,464(sp)
    800050dc:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800050de:	e2840593          	addi	a1,s0,-472
    800050e2:	4505                	li	a0,1
    800050e4:	ec6fd0ef          	jal	800027aa <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800050e8:	08000613          	li	a2,128
    800050ec:	f3040593          	addi	a1,s0,-208
    800050f0:	4501                	li	a0,0
    800050f2:	ed4fd0ef          	jal	800027c6 <argstr>
    800050f6:	87aa                	mv	a5,a0
    return -1;
    800050f8:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800050fa:	0e07c063          	bltz	a5,800051da <sys_exec+0x104>
    800050fe:	e7a6                	sd	s1,456(sp)
    80005100:	e3ca                	sd	s2,448(sp)
    80005102:	ff4e                	sd	s3,440(sp)
    80005104:	fb52                	sd	s4,432(sp)
    80005106:	f756                	sd	s5,424(sp)
    80005108:	f35a                	sd	s6,416(sp)
    8000510a:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000510c:	e3040a13          	addi	s4,s0,-464
    80005110:	10000613          	li	a2,256
    80005114:	4581                	li	a1,0
    80005116:	8552                	mv	a0,s4
    80005118:	bb7fb0ef          	jal	80000cce <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000511c:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    8000511e:	89d2                	mv	s3,s4
    80005120:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005122:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005126:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    80005128:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000512c:	00391513          	slli	a0,s2,0x3
    80005130:	85d6                	mv	a1,s5
    80005132:	e2843783          	ld	a5,-472(s0)
    80005136:	953e                	add	a0,a0,a5
    80005138:	dccfd0ef          	jal	80002704 <fetchaddr>
    8000513c:	02054663          	bltz	a0,80005168 <sys_exec+0x92>
    if(uarg == 0){
    80005140:	e2043783          	ld	a5,-480(s0)
    80005144:	c7a1                	beqz	a5,8000518c <sys_exec+0xb6>
    argv[i] = kalloc();
    80005146:	9e5fb0ef          	jal	80000b2a <kalloc>
    8000514a:	85aa                	mv	a1,a0
    8000514c:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005150:	cd01                	beqz	a0,80005168 <sys_exec+0x92>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005152:	865a                	mv	a2,s6
    80005154:	e2043503          	ld	a0,-480(s0)
    80005158:	df6fd0ef          	jal	8000274e <fetchstr>
    8000515c:	00054663          	bltz	a0,80005168 <sys_exec+0x92>
    if(i >= NELEM(argv)){
    80005160:	0905                	addi	s2,s2,1
    80005162:	09a1                	addi	s3,s3,8
    80005164:	fd7914e3          	bne	s2,s7,8000512c <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005168:	100a0a13          	addi	s4,s4,256
    8000516c:	6088                	ld	a0,0(s1)
    8000516e:	cd31                	beqz	a0,800051ca <sys_exec+0xf4>
    kfree(argv[i]);
    80005170:	8d9fb0ef          	jal	80000a48 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005174:	04a1                	addi	s1,s1,8
    80005176:	ff449be3          	bne	s1,s4,8000516c <sys_exec+0x96>
  return -1;
    8000517a:	557d                	li	a0,-1
    8000517c:	64be                	ld	s1,456(sp)
    8000517e:	691e                	ld	s2,448(sp)
    80005180:	79fa                	ld	s3,440(sp)
    80005182:	7a5a                	ld	s4,432(sp)
    80005184:	7aba                	ld	s5,424(sp)
    80005186:	7b1a                	ld	s6,416(sp)
    80005188:	6bfa                	ld	s7,408(sp)
    8000518a:	a881                	j	800051da <sys_exec+0x104>
      argv[i] = 0;
    8000518c:	0009079b          	sext.w	a5,s2
    80005190:	e3040593          	addi	a1,s0,-464
    80005194:	078e                	slli	a5,a5,0x3
    80005196:	97ae                	add	a5,a5,a1
    80005198:	0007b023          	sd	zero,0(a5)
  int ret = exec(path, argv);
    8000519c:	f3040513          	addi	a0,s0,-208
    800051a0:	ba4ff0ef          	jal	80004544 <exec>
    800051a4:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800051a6:	100a0a13          	addi	s4,s4,256
    800051aa:	6088                	ld	a0,0(s1)
    800051ac:	c511                	beqz	a0,800051b8 <sys_exec+0xe2>
    kfree(argv[i]);
    800051ae:	89bfb0ef          	jal	80000a48 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800051b2:	04a1                	addi	s1,s1,8
    800051b4:	ff449be3          	bne	s1,s4,800051aa <sys_exec+0xd4>
  return ret;
    800051b8:	854a                	mv	a0,s2
    800051ba:	64be                	ld	s1,456(sp)
    800051bc:	691e                	ld	s2,448(sp)
    800051be:	79fa                	ld	s3,440(sp)
    800051c0:	7a5a                	ld	s4,432(sp)
    800051c2:	7aba                	ld	s5,424(sp)
    800051c4:	7b1a                	ld	s6,416(sp)
    800051c6:	6bfa                	ld	s7,408(sp)
    800051c8:	a809                	j	800051da <sys_exec+0x104>
  return -1;
    800051ca:	557d                	li	a0,-1
    800051cc:	64be                	ld	s1,456(sp)
    800051ce:	691e                	ld	s2,448(sp)
    800051d0:	79fa                	ld	s3,440(sp)
    800051d2:	7a5a                	ld	s4,432(sp)
    800051d4:	7aba                	ld	s5,424(sp)
    800051d6:	7b1a                	ld	s6,416(sp)
    800051d8:	6bfa                	ld	s7,408(sp)
}
    800051da:	60fe                	ld	ra,472(sp)
    800051dc:	645e                	ld	s0,464(sp)
    800051de:	613d                	addi	sp,sp,480
    800051e0:	8082                	ret

00000000800051e2 <sys_pipe>:

uint64
sys_pipe(void)
{
    800051e2:	7139                	addi	sp,sp,-64
    800051e4:	fc06                	sd	ra,56(sp)
    800051e6:	f822                	sd	s0,48(sp)
    800051e8:	f426                	sd	s1,40(sp)
    800051ea:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800051ec:	ef0fc0ef          	jal	800018dc <myproc>
    800051f0:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800051f2:	fd840593          	addi	a1,s0,-40
    800051f6:	4501                	li	a0,0
    800051f8:	db2fd0ef          	jal	800027aa <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800051fc:	fc840593          	addi	a1,s0,-56
    80005200:	fd040513          	addi	a0,s0,-48
    80005204:	81eff0ef          	jal	80004222 <pipealloc>
    return -1;
    80005208:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000520a:	0a054463          	bltz	a0,800052b2 <sys_pipe+0xd0>
  fd0 = -1;
    8000520e:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005212:	fd043503          	ld	a0,-48(s0)
    80005216:	edeff0ef          	jal	800048f4 <fdalloc>
    8000521a:	fca42223          	sw	a0,-60(s0)
    8000521e:	08054163          	bltz	a0,800052a0 <sys_pipe+0xbe>
    80005222:	fc843503          	ld	a0,-56(s0)
    80005226:	eceff0ef          	jal	800048f4 <fdalloc>
    8000522a:	fca42023          	sw	a0,-64(s0)
    8000522e:	06054063          	bltz	a0,8000528e <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005232:	4691                	li	a3,4
    80005234:	fc440613          	addi	a2,s0,-60
    80005238:	fd843583          	ld	a1,-40(s0)
    8000523c:	68a8                	ld	a0,80(s1)
    8000523e:	b46fc0ef          	jal	80001584 <copyout>
    80005242:	00054e63          	bltz	a0,8000525e <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005246:	4691                	li	a3,4
    80005248:	fc040613          	addi	a2,s0,-64
    8000524c:	fd843583          	ld	a1,-40(s0)
    80005250:	95b6                	add	a1,a1,a3
    80005252:	68a8                	ld	a0,80(s1)
    80005254:	b30fc0ef          	jal	80001584 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005258:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000525a:	04055c63          	bgez	a0,800052b2 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    8000525e:	fc442783          	lw	a5,-60(s0)
    80005262:	07e9                	addi	a5,a5,26
    80005264:	078e                	slli	a5,a5,0x3
    80005266:	97a6                	add	a5,a5,s1
    80005268:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000526c:	fc042783          	lw	a5,-64(s0)
    80005270:	07e9                	addi	a5,a5,26
    80005272:	078e                	slli	a5,a5,0x3
    80005274:	94be                	add	s1,s1,a5
    80005276:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000527a:	fd043503          	ld	a0,-48(s0)
    8000527e:	c95fe0ef          	jal	80003f12 <fileclose>
    fileclose(wf);
    80005282:	fc843503          	ld	a0,-56(s0)
    80005286:	c8dfe0ef          	jal	80003f12 <fileclose>
    return -1;
    8000528a:	57fd                	li	a5,-1
    8000528c:	a01d                	j	800052b2 <sys_pipe+0xd0>
    if(fd0 >= 0)
    8000528e:	fc442783          	lw	a5,-60(s0)
    80005292:	0007c763          	bltz	a5,800052a0 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005296:	07e9                	addi	a5,a5,26
    80005298:	078e                	slli	a5,a5,0x3
    8000529a:	97a6                	add	a5,a5,s1
    8000529c:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800052a0:	fd043503          	ld	a0,-48(s0)
    800052a4:	c6ffe0ef          	jal	80003f12 <fileclose>
    fileclose(wf);
    800052a8:	fc843503          	ld	a0,-56(s0)
    800052ac:	c67fe0ef          	jal	80003f12 <fileclose>
    return -1;
    800052b0:	57fd                	li	a5,-1
}
    800052b2:	853e                	mv	a0,a5
    800052b4:	70e2                	ld	ra,56(sp)
    800052b6:	7442                	ld	s0,48(sp)
    800052b8:	74a2                	ld	s1,40(sp)
    800052ba:	6121                	addi	sp,sp,64
    800052bc:	8082                	ret
	...

00000000800052c0 <kernelvec>:
    800052c0:	7111                	addi	sp,sp,-256
    800052c2:	e006                	sd	ra,0(sp)
    800052c4:	e40a                	sd	sp,8(sp)
    800052c6:	e80e                	sd	gp,16(sp)
    800052c8:	ec12                	sd	tp,24(sp)
    800052ca:	f016                	sd	t0,32(sp)
    800052cc:	f41a                	sd	t1,40(sp)
    800052ce:	f81e                	sd	t2,48(sp)
    800052d0:	e4aa                	sd	a0,72(sp)
    800052d2:	e8ae                	sd	a1,80(sp)
    800052d4:	ecb2                	sd	a2,88(sp)
    800052d6:	f0b6                	sd	a3,96(sp)
    800052d8:	f4ba                	sd	a4,104(sp)
    800052da:	f8be                	sd	a5,112(sp)
    800052dc:	fcc2                	sd	a6,120(sp)
    800052de:	e146                	sd	a7,128(sp)
    800052e0:	edf2                	sd	t3,216(sp)
    800052e2:	f1f6                	sd	t4,224(sp)
    800052e4:	f5fa                	sd	t5,232(sp)
    800052e6:	f9fe                	sd	t6,240(sp)
    800052e8:	b2cfd0ef          	jal	80002614 <kerneltrap>
    800052ec:	6082                	ld	ra,0(sp)
    800052ee:	6122                	ld	sp,8(sp)
    800052f0:	61c2                	ld	gp,16(sp)
    800052f2:	7282                	ld	t0,32(sp)
    800052f4:	7322                	ld	t1,40(sp)
    800052f6:	73c2                	ld	t2,48(sp)
    800052f8:	6526                	ld	a0,72(sp)
    800052fa:	65c6                	ld	a1,80(sp)
    800052fc:	6666                	ld	a2,88(sp)
    800052fe:	7686                	ld	a3,96(sp)
    80005300:	7726                	ld	a4,104(sp)
    80005302:	77c6                	ld	a5,112(sp)
    80005304:	7866                	ld	a6,120(sp)
    80005306:	688a                	ld	a7,128(sp)
    80005308:	6e6e                	ld	t3,216(sp)
    8000530a:	7e8e                	ld	t4,224(sp)
    8000530c:	7f2e                	ld	t5,232(sp)
    8000530e:	7fce                	ld	t6,240(sp)
    80005310:	6111                	addi	sp,sp,256
    80005312:	10200073          	sret
	...

000000008000531e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000531e:	1141                	addi	sp,sp,-16
    80005320:	e406                	sd	ra,8(sp)
    80005322:	e022                	sd	s0,0(sp)
    80005324:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005326:	0c000737          	lui	a4,0xc000
    8000532a:	4785                	li	a5,1
    8000532c:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000532e:	c35c                	sw	a5,4(a4)
}
    80005330:	60a2                	ld	ra,8(sp)
    80005332:	6402                	ld	s0,0(sp)
    80005334:	0141                	addi	sp,sp,16
    80005336:	8082                	ret

0000000080005338 <plicinithart>:

void
plicinithart(void)
{
    80005338:	1141                	addi	sp,sp,-16
    8000533a:	e406                	sd	ra,8(sp)
    8000533c:	e022                	sd	s0,0(sp)
    8000533e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005340:	d68fc0ef          	jal	800018a8 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005344:	0085171b          	slliw	a4,a0,0x8
    80005348:	0c0027b7          	lui	a5,0xc002
    8000534c:	97ba                	add	a5,a5,a4
    8000534e:	40200713          	li	a4,1026
    80005352:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005356:	00d5151b          	slliw	a0,a0,0xd
    8000535a:	0c2017b7          	lui	a5,0xc201
    8000535e:	97aa                	add	a5,a5,a0
    80005360:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005364:	60a2                	ld	ra,8(sp)
    80005366:	6402                	ld	s0,0(sp)
    80005368:	0141                	addi	sp,sp,16
    8000536a:	8082                	ret

000000008000536c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000536c:	1141                	addi	sp,sp,-16
    8000536e:	e406                	sd	ra,8(sp)
    80005370:	e022                	sd	s0,0(sp)
    80005372:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005374:	d34fc0ef          	jal	800018a8 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005378:	00d5151b          	slliw	a0,a0,0xd
    8000537c:	0c2017b7          	lui	a5,0xc201
    80005380:	97aa                	add	a5,a5,a0
  return irq;
}
    80005382:	43c8                	lw	a0,4(a5)
    80005384:	60a2                	ld	ra,8(sp)
    80005386:	6402                	ld	s0,0(sp)
    80005388:	0141                	addi	sp,sp,16
    8000538a:	8082                	ret

000000008000538c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000538c:	1101                	addi	sp,sp,-32
    8000538e:	ec06                	sd	ra,24(sp)
    80005390:	e822                	sd	s0,16(sp)
    80005392:	e426                	sd	s1,8(sp)
    80005394:	1000                	addi	s0,sp,32
    80005396:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005398:	d10fc0ef          	jal	800018a8 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000539c:	00d5179b          	slliw	a5,a0,0xd
    800053a0:	0c201737          	lui	a4,0xc201
    800053a4:	97ba                	add	a5,a5,a4
    800053a6:	c3c4                	sw	s1,4(a5)
}
    800053a8:	60e2                	ld	ra,24(sp)
    800053aa:	6442                	ld	s0,16(sp)
    800053ac:	64a2                	ld	s1,8(sp)
    800053ae:	6105                	addi	sp,sp,32
    800053b0:	8082                	ret

00000000800053b2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800053b2:	1141                	addi	sp,sp,-16
    800053b4:	e406                	sd	ra,8(sp)
    800053b6:	e022                	sd	s0,0(sp)
    800053b8:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800053ba:	479d                	li	a5,7
    800053bc:	04a7ca63          	blt	a5,a0,80005410 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    800053c0:	0001e797          	auipc	a5,0x1e
    800053c4:	14078793          	addi	a5,a5,320 # 80023500 <disk>
    800053c8:	97aa                	add	a5,a5,a0
    800053ca:	0187c783          	lbu	a5,24(a5)
    800053ce:	e7b9                	bnez	a5,8000541c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800053d0:	00451693          	slli	a3,a0,0x4
    800053d4:	0001e797          	auipc	a5,0x1e
    800053d8:	12c78793          	addi	a5,a5,300 # 80023500 <disk>
    800053dc:	6398                	ld	a4,0(a5)
    800053de:	9736                	add	a4,a4,a3
    800053e0:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    800053e4:	6398                	ld	a4,0(a5)
    800053e6:	9736                	add	a4,a4,a3
    800053e8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800053ec:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800053f0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800053f4:	97aa                	add	a5,a5,a0
    800053f6:	4705                	li	a4,1
    800053f8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800053fc:	0001e517          	auipc	a0,0x1e
    80005400:	11c50513          	addi	a0,a0,284 # 80023518 <disk+0x18>
    80005404:	af3fc0ef          	jal	80001ef6 <wakeup>
}
    80005408:	60a2                	ld	ra,8(sp)
    8000540a:	6402                	ld	s0,0(sp)
    8000540c:	0141                	addi	sp,sp,16
    8000540e:	8082                	ret
    panic("free_desc 1");
    80005410:	00002517          	auipc	a0,0x2
    80005414:	26050513          	addi	a0,a0,608 # 80007670 <etext+0x670>
    80005418:	b86fb0ef          	jal	8000079e <panic>
    panic("free_desc 2");
    8000541c:	00002517          	auipc	a0,0x2
    80005420:	26450513          	addi	a0,a0,612 # 80007680 <etext+0x680>
    80005424:	b7afb0ef          	jal	8000079e <panic>

0000000080005428 <virtio_disk_init>:
{
    80005428:	1101                	addi	sp,sp,-32
    8000542a:	ec06                	sd	ra,24(sp)
    8000542c:	e822                	sd	s0,16(sp)
    8000542e:	e426                	sd	s1,8(sp)
    80005430:	e04a                	sd	s2,0(sp)
    80005432:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005434:	00002597          	auipc	a1,0x2
    80005438:	25c58593          	addi	a1,a1,604 # 80007690 <etext+0x690>
    8000543c:	0001e517          	auipc	a0,0x1e
    80005440:	1ec50513          	addi	a0,a0,492 # 80023628 <disk+0x128>
    80005444:	f36fb0ef          	jal	80000b7a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005448:	100017b7          	lui	a5,0x10001
    8000544c:	4398                	lw	a4,0(a5)
    8000544e:	2701                	sext.w	a4,a4
    80005450:	747277b7          	lui	a5,0x74727
    80005454:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005458:	14f71863          	bne	a4,a5,800055a8 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000545c:	100017b7          	lui	a5,0x10001
    80005460:	43dc                	lw	a5,4(a5)
    80005462:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005464:	4709                	li	a4,2
    80005466:	14e79163          	bne	a5,a4,800055a8 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000546a:	100017b7          	lui	a5,0x10001
    8000546e:	479c                	lw	a5,8(a5)
    80005470:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005472:	12e79b63          	bne	a5,a4,800055a8 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005476:	100017b7          	lui	a5,0x10001
    8000547a:	47d8                	lw	a4,12(a5)
    8000547c:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000547e:	554d47b7          	lui	a5,0x554d4
    80005482:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005486:	12f71163          	bne	a4,a5,800055a8 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000548a:	100017b7          	lui	a5,0x10001
    8000548e:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005492:	4705                	li	a4,1
    80005494:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005496:	470d                	li	a4,3
    80005498:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000549a:	10001737          	lui	a4,0x10001
    8000549e:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800054a0:	c7ffe6b7          	lui	a3,0xc7ffe
    800054a4:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdb11f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800054a8:	8f75                	and	a4,a4,a3
    800054aa:	100016b7          	lui	a3,0x10001
    800054ae:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    800054b0:	472d                	li	a4,11
    800054b2:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800054b4:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800054b8:	439c                	lw	a5,0(a5)
    800054ba:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800054be:	8ba1                	andi	a5,a5,8
    800054c0:	0e078a63          	beqz	a5,800055b4 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800054c4:	100017b7          	lui	a5,0x10001
    800054c8:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800054cc:	43fc                	lw	a5,68(a5)
    800054ce:	2781                	sext.w	a5,a5
    800054d0:	0e079863          	bnez	a5,800055c0 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800054d4:	100017b7          	lui	a5,0x10001
    800054d8:	5bdc                	lw	a5,52(a5)
    800054da:	2781                	sext.w	a5,a5
  if(max == 0)
    800054dc:	0e078863          	beqz	a5,800055cc <virtio_disk_init+0x1a4>
  if(max < NUM)
    800054e0:	471d                	li	a4,7
    800054e2:	0ef77b63          	bgeu	a4,a5,800055d8 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    800054e6:	e44fb0ef          	jal	80000b2a <kalloc>
    800054ea:	0001e497          	auipc	s1,0x1e
    800054ee:	01648493          	addi	s1,s1,22 # 80023500 <disk>
    800054f2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800054f4:	e36fb0ef          	jal	80000b2a <kalloc>
    800054f8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800054fa:	e30fb0ef          	jal	80000b2a <kalloc>
    800054fe:	87aa                	mv	a5,a0
    80005500:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005502:	6088                	ld	a0,0(s1)
    80005504:	0e050063          	beqz	a0,800055e4 <virtio_disk_init+0x1bc>
    80005508:	0001e717          	auipc	a4,0x1e
    8000550c:	00073703          	ld	a4,0(a4) # 80023508 <disk+0x8>
    80005510:	cb71                	beqz	a4,800055e4 <virtio_disk_init+0x1bc>
    80005512:	cbe9                	beqz	a5,800055e4 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    80005514:	6605                	lui	a2,0x1
    80005516:	4581                	li	a1,0
    80005518:	fb6fb0ef          	jal	80000cce <memset>
  memset(disk.avail, 0, PGSIZE);
    8000551c:	0001e497          	auipc	s1,0x1e
    80005520:	fe448493          	addi	s1,s1,-28 # 80023500 <disk>
    80005524:	6605                	lui	a2,0x1
    80005526:	4581                	li	a1,0
    80005528:	6488                	ld	a0,8(s1)
    8000552a:	fa4fb0ef          	jal	80000cce <memset>
  memset(disk.used, 0, PGSIZE);
    8000552e:	6605                	lui	a2,0x1
    80005530:	4581                	li	a1,0
    80005532:	6888                	ld	a0,16(s1)
    80005534:	f9afb0ef          	jal	80000cce <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005538:	100017b7          	lui	a5,0x10001
    8000553c:	4721                	li	a4,8
    8000553e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005540:	4098                	lw	a4,0(s1)
    80005542:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005546:	40d8                	lw	a4,4(s1)
    80005548:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000554c:	649c                	ld	a5,8(s1)
    8000554e:	0007869b          	sext.w	a3,a5
    80005552:	10001737          	lui	a4,0x10001
    80005556:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    8000555a:	9781                	srai	a5,a5,0x20
    8000555c:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005560:	689c                	ld	a5,16(s1)
    80005562:	0007869b          	sext.w	a3,a5
    80005566:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000556a:	9781                	srai	a5,a5,0x20
    8000556c:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005570:	4785                	li	a5,1
    80005572:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005574:	00f48c23          	sb	a5,24(s1)
    80005578:	00f48ca3          	sb	a5,25(s1)
    8000557c:	00f48d23          	sb	a5,26(s1)
    80005580:	00f48da3          	sb	a5,27(s1)
    80005584:	00f48e23          	sb	a5,28(s1)
    80005588:	00f48ea3          	sb	a5,29(s1)
    8000558c:	00f48f23          	sb	a5,30(s1)
    80005590:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005594:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005598:	07272823          	sw	s2,112(a4)
}
    8000559c:	60e2                	ld	ra,24(sp)
    8000559e:	6442                	ld	s0,16(sp)
    800055a0:	64a2                	ld	s1,8(sp)
    800055a2:	6902                	ld	s2,0(sp)
    800055a4:	6105                	addi	sp,sp,32
    800055a6:	8082                	ret
    panic("could not find virtio disk");
    800055a8:	00002517          	auipc	a0,0x2
    800055ac:	0f850513          	addi	a0,a0,248 # 800076a0 <etext+0x6a0>
    800055b0:	9eefb0ef          	jal	8000079e <panic>
    panic("virtio disk FEATURES_OK unset");
    800055b4:	00002517          	auipc	a0,0x2
    800055b8:	10c50513          	addi	a0,a0,268 # 800076c0 <etext+0x6c0>
    800055bc:	9e2fb0ef          	jal	8000079e <panic>
    panic("virtio disk should not be ready");
    800055c0:	00002517          	auipc	a0,0x2
    800055c4:	12050513          	addi	a0,a0,288 # 800076e0 <etext+0x6e0>
    800055c8:	9d6fb0ef          	jal	8000079e <panic>
    panic("virtio disk has no queue 0");
    800055cc:	00002517          	auipc	a0,0x2
    800055d0:	13450513          	addi	a0,a0,308 # 80007700 <etext+0x700>
    800055d4:	9cafb0ef          	jal	8000079e <panic>
    panic("virtio disk max queue too short");
    800055d8:	00002517          	auipc	a0,0x2
    800055dc:	14850513          	addi	a0,a0,328 # 80007720 <etext+0x720>
    800055e0:	9befb0ef          	jal	8000079e <panic>
    panic("virtio disk kalloc");
    800055e4:	00002517          	auipc	a0,0x2
    800055e8:	15c50513          	addi	a0,a0,348 # 80007740 <etext+0x740>
    800055ec:	9b2fb0ef          	jal	8000079e <panic>

00000000800055f0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800055f0:	711d                	addi	sp,sp,-96
    800055f2:	ec86                	sd	ra,88(sp)
    800055f4:	e8a2                	sd	s0,80(sp)
    800055f6:	e4a6                	sd	s1,72(sp)
    800055f8:	e0ca                	sd	s2,64(sp)
    800055fa:	fc4e                	sd	s3,56(sp)
    800055fc:	f852                	sd	s4,48(sp)
    800055fe:	f456                	sd	s5,40(sp)
    80005600:	f05a                	sd	s6,32(sp)
    80005602:	ec5e                	sd	s7,24(sp)
    80005604:	e862                	sd	s8,16(sp)
    80005606:	1080                	addi	s0,sp,96
    80005608:	89aa                	mv	s3,a0
    8000560a:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000560c:	00c52b83          	lw	s7,12(a0)
    80005610:	001b9b9b          	slliw	s7,s7,0x1
    80005614:	1b82                	slli	s7,s7,0x20
    80005616:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    8000561a:	0001e517          	auipc	a0,0x1e
    8000561e:	00e50513          	addi	a0,a0,14 # 80023628 <disk+0x128>
    80005622:	ddcfb0ef          	jal	80000bfe <acquire>
  for(int i = 0; i < NUM; i++){
    80005626:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005628:	0001ea97          	auipc	s5,0x1e
    8000562c:	ed8a8a93          	addi	s5,s5,-296 # 80023500 <disk>
  for(int i = 0; i < 3; i++){
    80005630:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005632:	5c7d                	li	s8,-1
    80005634:	a095                	j	80005698 <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    80005636:	00fa8733          	add	a4,s5,a5
    8000563a:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    8000563e:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005640:	0207c563          	bltz	a5,8000566a <virtio_disk_rw+0x7a>
  for(int i = 0; i < 3; i++){
    80005644:	2905                	addiw	s2,s2,1
    80005646:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005648:	05490c63          	beq	s2,s4,800056a0 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    8000564c:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    8000564e:	0001e717          	auipc	a4,0x1e
    80005652:	eb270713          	addi	a4,a4,-334 # 80023500 <disk>
    80005656:	4781                	li	a5,0
    if(disk.free[i]){
    80005658:	01874683          	lbu	a3,24(a4)
    8000565c:	fee9                	bnez	a3,80005636 <virtio_disk_rw+0x46>
  for(int i = 0; i < NUM; i++){
    8000565e:	2785                	addiw	a5,a5,1
    80005660:	0705                	addi	a4,a4,1
    80005662:	fe979be3          	bne	a5,s1,80005658 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005666:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    8000566a:	01205d63          	blez	s2,80005684 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000566e:	fa042503          	lw	a0,-96(s0)
    80005672:	d41ff0ef          	jal	800053b2 <free_desc>
      for(int j = 0; j < i; j++)
    80005676:	4785                	li	a5,1
    80005678:	0127d663          	bge	a5,s2,80005684 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000567c:	fa442503          	lw	a0,-92(s0)
    80005680:	d33ff0ef          	jal	800053b2 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005684:	0001e597          	auipc	a1,0x1e
    80005688:	fa458593          	addi	a1,a1,-92 # 80023628 <disk+0x128>
    8000568c:	0001e517          	auipc	a0,0x1e
    80005690:	e8c50513          	addi	a0,a0,-372 # 80023518 <disk+0x18>
    80005694:	817fc0ef          	jal	80001eaa <sleep>
  for(int i = 0; i < 3; i++){
    80005698:	fa040613          	addi	a2,s0,-96
    8000569c:	4901                	li	s2,0
    8000569e:	b77d                	j	8000564c <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800056a0:	fa042503          	lw	a0,-96(s0)
    800056a4:	00451693          	slli	a3,a0,0x4

  if(write)
    800056a8:	0001e797          	auipc	a5,0x1e
    800056ac:	e5878793          	addi	a5,a5,-424 # 80023500 <disk>
    800056b0:	00a50713          	addi	a4,a0,10
    800056b4:	0712                	slli	a4,a4,0x4
    800056b6:	973e                	add	a4,a4,a5
    800056b8:	01603633          	snez	a2,s6
    800056bc:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800056be:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800056c2:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800056c6:	6398                	ld	a4,0(a5)
    800056c8:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800056ca:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    800056ce:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800056d0:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800056d2:	6390                	ld	a2,0(a5)
    800056d4:	00d605b3          	add	a1,a2,a3
    800056d8:	4741                	li	a4,16
    800056da:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800056dc:	4805                	li	a6,1
    800056de:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    800056e2:	fa442703          	lw	a4,-92(s0)
    800056e6:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800056ea:	0712                	slli	a4,a4,0x4
    800056ec:	963a                	add	a2,a2,a4
    800056ee:	05898593          	addi	a1,s3,88
    800056f2:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800056f4:	0007b883          	ld	a7,0(a5)
    800056f8:	9746                	add	a4,a4,a7
    800056fa:	40000613          	li	a2,1024
    800056fe:	c710                	sw	a2,8(a4)
  if(write)
    80005700:	001b3613          	seqz	a2,s6
    80005704:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005708:	01066633          	or	a2,a2,a6
    8000570c:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005710:	fa842583          	lw	a1,-88(s0)
    80005714:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005718:	00250613          	addi	a2,a0,2
    8000571c:	0612                	slli	a2,a2,0x4
    8000571e:	963e                	add	a2,a2,a5
    80005720:	577d                	li	a4,-1
    80005722:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005726:	0592                	slli	a1,a1,0x4
    80005728:	98ae                	add	a7,a7,a1
    8000572a:	03068713          	addi	a4,a3,48
    8000572e:	973e                	add	a4,a4,a5
    80005730:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005734:	6398                	ld	a4,0(a5)
    80005736:	972e                	add	a4,a4,a1
    80005738:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000573c:	4689                	li	a3,2
    8000573e:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005742:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005746:	0109a223          	sw	a6,4(s3)
  disk.info[idx[0]].b = b;
    8000574a:	01363423          	sd	s3,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000574e:	6794                	ld	a3,8(a5)
    80005750:	0026d703          	lhu	a4,2(a3)
    80005754:	8b1d                	andi	a4,a4,7
    80005756:	0706                	slli	a4,a4,0x1
    80005758:	96ba                	add	a3,a3,a4
    8000575a:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    8000575e:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005762:	6798                	ld	a4,8(a5)
    80005764:	00275783          	lhu	a5,2(a4)
    80005768:	2785                	addiw	a5,a5,1
    8000576a:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000576e:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005772:	100017b7          	lui	a5,0x10001
    80005776:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000577a:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    8000577e:	0001e917          	auipc	s2,0x1e
    80005782:	eaa90913          	addi	s2,s2,-342 # 80023628 <disk+0x128>
  while(b->disk == 1) {
    80005786:	84c2                	mv	s1,a6
    80005788:	01079a63          	bne	a5,a6,8000579c <virtio_disk_rw+0x1ac>
    sleep(b, &disk.vdisk_lock);
    8000578c:	85ca                	mv	a1,s2
    8000578e:	854e                	mv	a0,s3
    80005790:	f1afc0ef          	jal	80001eaa <sleep>
  while(b->disk == 1) {
    80005794:	0049a783          	lw	a5,4(s3)
    80005798:	fe978ae3          	beq	a5,s1,8000578c <virtio_disk_rw+0x19c>
  }

  disk.info[idx[0]].b = 0;
    8000579c:	fa042903          	lw	s2,-96(s0)
    800057a0:	00290713          	addi	a4,s2,2
    800057a4:	0712                	slli	a4,a4,0x4
    800057a6:	0001e797          	auipc	a5,0x1e
    800057aa:	d5a78793          	addi	a5,a5,-678 # 80023500 <disk>
    800057ae:	97ba                	add	a5,a5,a4
    800057b0:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800057b4:	0001e997          	auipc	s3,0x1e
    800057b8:	d4c98993          	addi	s3,s3,-692 # 80023500 <disk>
    800057bc:	00491713          	slli	a4,s2,0x4
    800057c0:	0009b783          	ld	a5,0(s3)
    800057c4:	97ba                	add	a5,a5,a4
    800057c6:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800057ca:	854a                	mv	a0,s2
    800057cc:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800057d0:	be3ff0ef          	jal	800053b2 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800057d4:	8885                	andi	s1,s1,1
    800057d6:	f0fd                	bnez	s1,800057bc <virtio_disk_rw+0x1cc>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800057d8:	0001e517          	auipc	a0,0x1e
    800057dc:	e5050513          	addi	a0,a0,-432 # 80023628 <disk+0x128>
    800057e0:	cb2fb0ef          	jal	80000c92 <release>
}
    800057e4:	60e6                	ld	ra,88(sp)
    800057e6:	6446                	ld	s0,80(sp)
    800057e8:	64a6                	ld	s1,72(sp)
    800057ea:	6906                	ld	s2,64(sp)
    800057ec:	79e2                	ld	s3,56(sp)
    800057ee:	7a42                	ld	s4,48(sp)
    800057f0:	7aa2                	ld	s5,40(sp)
    800057f2:	7b02                	ld	s6,32(sp)
    800057f4:	6be2                	ld	s7,24(sp)
    800057f6:	6c42                	ld	s8,16(sp)
    800057f8:	6125                	addi	sp,sp,96
    800057fa:	8082                	ret

00000000800057fc <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800057fc:	1101                	addi	sp,sp,-32
    800057fe:	ec06                	sd	ra,24(sp)
    80005800:	e822                	sd	s0,16(sp)
    80005802:	e426                	sd	s1,8(sp)
    80005804:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005806:	0001e497          	auipc	s1,0x1e
    8000580a:	cfa48493          	addi	s1,s1,-774 # 80023500 <disk>
    8000580e:	0001e517          	auipc	a0,0x1e
    80005812:	e1a50513          	addi	a0,a0,-486 # 80023628 <disk+0x128>
    80005816:	be8fb0ef          	jal	80000bfe <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000581a:	100017b7          	lui	a5,0x10001
    8000581e:	53bc                	lw	a5,96(a5)
    80005820:	8b8d                	andi	a5,a5,3
    80005822:	10001737          	lui	a4,0x10001
    80005826:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005828:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    8000582c:	689c                	ld	a5,16(s1)
    8000582e:	0204d703          	lhu	a4,32(s1)
    80005832:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005836:	04f70663          	beq	a4,a5,80005882 <virtio_disk_intr+0x86>
    __sync_synchronize();
    8000583a:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000583e:	6898                	ld	a4,16(s1)
    80005840:	0204d783          	lhu	a5,32(s1)
    80005844:	8b9d                	andi	a5,a5,7
    80005846:	078e                	slli	a5,a5,0x3
    80005848:	97ba                	add	a5,a5,a4
    8000584a:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    8000584c:	00278713          	addi	a4,a5,2
    80005850:	0712                	slli	a4,a4,0x4
    80005852:	9726                	add	a4,a4,s1
    80005854:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80005858:	e321                	bnez	a4,80005898 <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000585a:	0789                	addi	a5,a5,2
    8000585c:	0792                	slli	a5,a5,0x4
    8000585e:	97a6                	add	a5,a5,s1
    80005860:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005862:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005866:	e90fc0ef          	jal	80001ef6 <wakeup>

    disk.used_idx += 1;
    8000586a:	0204d783          	lhu	a5,32(s1)
    8000586e:	2785                	addiw	a5,a5,1
    80005870:	17c2                	slli	a5,a5,0x30
    80005872:	93c1                	srli	a5,a5,0x30
    80005874:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005878:	6898                	ld	a4,16(s1)
    8000587a:	00275703          	lhu	a4,2(a4)
    8000587e:	faf71ee3          	bne	a4,a5,8000583a <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005882:	0001e517          	auipc	a0,0x1e
    80005886:	da650513          	addi	a0,a0,-602 # 80023628 <disk+0x128>
    8000588a:	c08fb0ef          	jal	80000c92 <release>
}
    8000588e:	60e2                	ld	ra,24(sp)
    80005890:	6442                	ld	s0,16(sp)
    80005892:	64a2                	ld	s1,8(sp)
    80005894:	6105                	addi	sp,sp,32
    80005896:	8082                	ret
      panic("virtio_disk_intr status");
    80005898:	00002517          	auipc	a0,0x2
    8000589c:	ec050513          	addi	a0,a0,-320 # 80007758 <etext+0x758>
    800058a0:	efffa0ef          	jal	8000079e <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
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
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
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
