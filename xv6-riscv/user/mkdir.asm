
user/_mkdir:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
   8:	4785                	li	a5,1
   a:	02a7d963          	bge	a5,a0,3c <main+0x3c>
   e:	e426                	sd	s1,8(sp)
  10:	e04a                	sd	s2,0(sp)
  12:	00858493          	addi	s1,a1,8
  16:	ffe5091b          	addiw	s2,a0,-2
  1a:	02091793          	slli	a5,s2,0x20
  1e:	01d7d913          	srli	s2,a5,0x1d
  22:	05c1                	addi	a1,a1,16
  24:	992e                	add	s2,s2,a1
    fprintf(2, "Usage: mkdir files...\n");
    exit(1);
  }

  for(i = 1; i < argc; i++){
    if(mkdir(argv[i]) < 0){
  26:	6088                	ld	a0,0(s1)
  28:	344000ef          	jal	36c <mkdir>
  2c:	02054463          	bltz	a0,54 <main+0x54>
  for(i = 1; i < argc; i++){
  30:	04a1                	addi	s1,s1,8
  32:	ff249ae3          	bne	s1,s2,26 <main+0x26>
      fprintf(2, "mkdir: %s failed to create\n", argv[i]);
      break;
    }
  }

  exit(0);
  36:	4501                	li	a0,0
  38:	2cc000ef          	jal	304 <exit>
  3c:	e426                	sd	s1,8(sp)
  3e:	e04a                	sd	s2,0(sp)
    fprintf(2, "Usage: mkdir files...\n");
  40:	00001597          	auipc	a1,0x1
  44:	88058593          	addi	a1,a1,-1920 # 8c0 <malloc+0xfa>
  48:	4509                	li	a0,2
  4a:	69a000ef          	jal	6e4 <fprintf>
    exit(1);
  4e:	4505                	li	a0,1
  50:	2b4000ef          	jal	304 <exit>
      fprintf(2, "mkdir: %s failed to create\n", argv[i]);
  54:	6090                	ld	a2,0(s1)
  56:	00001597          	auipc	a1,0x1
  5a:	88258593          	addi	a1,a1,-1918 # 8d8 <malloc+0x112>
  5e:	4509                	li	a0,2
  60:	684000ef          	jal	6e4 <fprintf>
      break;
  64:	bfc9                	j	36 <main+0x36>

0000000000000066 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
  66:	1141                	addi	sp,sp,-16
  68:	e406                	sd	ra,8(sp)
  6a:	e022                	sd	s0,0(sp)
  6c:	0800                	addi	s0,sp,16
  extern int main();
  main();
  6e:	f93ff0ef          	jal	0 <main>
  exit(0);
  72:	4501                	li	a0,0
  74:	290000ef          	jal	304 <exit>

0000000000000078 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  78:	1141                	addi	sp,sp,-16
  7a:	e406                	sd	ra,8(sp)
  7c:	e022                	sd	s0,0(sp)
  7e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  80:	87aa                	mv	a5,a0
  82:	0585                	addi	a1,a1,1
  84:	0785                	addi	a5,a5,1
  86:	fff5c703          	lbu	a4,-1(a1)
  8a:	fee78fa3          	sb	a4,-1(a5)
  8e:	fb75                	bnez	a4,82 <strcpy+0xa>
    ;
  return os;
}
  90:	60a2                	ld	ra,8(sp)
  92:	6402                	ld	s0,0(sp)
  94:	0141                	addi	sp,sp,16
  96:	8082                	ret

0000000000000098 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  98:	1141                	addi	sp,sp,-16
  9a:	e406                	sd	ra,8(sp)
  9c:	e022                	sd	s0,0(sp)
  9e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  a0:	00054783          	lbu	a5,0(a0)
  a4:	cb91                	beqz	a5,b8 <strcmp+0x20>
  a6:	0005c703          	lbu	a4,0(a1)
  aa:	00f71763          	bne	a4,a5,b8 <strcmp+0x20>
    p++, q++;
  ae:	0505                	addi	a0,a0,1
  b0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  b2:	00054783          	lbu	a5,0(a0)
  b6:	fbe5                	bnez	a5,a6 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
  b8:	0005c503          	lbu	a0,0(a1)
}
  bc:	40a7853b          	subw	a0,a5,a0
  c0:	60a2                	ld	ra,8(sp)
  c2:	6402                	ld	s0,0(sp)
  c4:	0141                	addi	sp,sp,16
  c6:	8082                	ret

00000000000000c8 <strlen>:

uint
strlen(const char *s)
{
  c8:	1141                	addi	sp,sp,-16
  ca:	e406                	sd	ra,8(sp)
  cc:	e022                	sd	s0,0(sp)
  ce:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  d0:	00054783          	lbu	a5,0(a0)
  d4:	cf99                	beqz	a5,f2 <strlen+0x2a>
  d6:	0505                	addi	a0,a0,1
  d8:	87aa                	mv	a5,a0
  da:	86be                	mv	a3,a5
  dc:	0785                	addi	a5,a5,1
  de:	fff7c703          	lbu	a4,-1(a5)
  e2:	ff65                	bnez	a4,da <strlen+0x12>
  e4:	40a6853b          	subw	a0,a3,a0
  e8:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  ea:	60a2                	ld	ra,8(sp)
  ec:	6402                	ld	s0,0(sp)
  ee:	0141                	addi	sp,sp,16
  f0:	8082                	ret
  for(n = 0; s[n]; n++)
  f2:	4501                	li	a0,0
  f4:	bfdd                	j	ea <strlen+0x22>

00000000000000f6 <memset>:

void*
memset(void *dst, int c, uint n)
{
  f6:	1141                	addi	sp,sp,-16
  f8:	e406                	sd	ra,8(sp)
  fa:	e022                	sd	s0,0(sp)
  fc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  fe:	ca19                	beqz	a2,114 <memset+0x1e>
 100:	87aa                	mv	a5,a0
 102:	1602                	slli	a2,a2,0x20
 104:	9201                	srli	a2,a2,0x20
 106:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 10a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 10e:	0785                	addi	a5,a5,1
 110:	fee79de3          	bne	a5,a4,10a <memset+0x14>
  }
  return dst;
}
 114:	60a2                	ld	ra,8(sp)
 116:	6402                	ld	s0,0(sp)
 118:	0141                	addi	sp,sp,16
 11a:	8082                	ret

000000000000011c <strchr>:

char*
strchr(const char *s, char c)
{
 11c:	1141                	addi	sp,sp,-16
 11e:	e406                	sd	ra,8(sp)
 120:	e022                	sd	s0,0(sp)
 122:	0800                	addi	s0,sp,16
  for(; *s; s++)
 124:	00054783          	lbu	a5,0(a0)
 128:	cf81                	beqz	a5,140 <strchr+0x24>
    if(*s == c)
 12a:	00f58763          	beq	a1,a5,138 <strchr+0x1c>
  for(; *s; s++)
 12e:	0505                	addi	a0,a0,1
 130:	00054783          	lbu	a5,0(a0)
 134:	fbfd                	bnez	a5,12a <strchr+0xe>
      return (char*)s;
  return 0;
 136:	4501                	li	a0,0
}
 138:	60a2                	ld	ra,8(sp)
 13a:	6402                	ld	s0,0(sp)
 13c:	0141                	addi	sp,sp,16
 13e:	8082                	ret
  return 0;
 140:	4501                	li	a0,0
 142:	bfdd                	j	138 <strchr+0x1c>

0000000000000144 <gets>:

char*
gets(char *buf, int max)
{
 144:	7159                	addi	sp,sp,-112
 146:	f486                	sd	ra,104(sp)
 148:	f0a2                	sd	s0,96(sp)
 14a:	eca6                	sd	s1,88(sp)
 14c:	e8ca                	sd	s2,80(sp)
 14e:	e4ce                	sd	s3,72(sp)
 150:	e0d2                	sd	s4,64(sp)
 152:	fc56                	sd	s5,56(sp)
 154:	f85a                	sd	s6,48(sp)
 156:	f45e                	sd	s7,40(sp)
 158:	f062                	sd	s8,32(sp)
 15a:	ec66                	sd	s9,24(sp)
 15c:	e86a                	sd	s10,16(sp)
 15e:	1880                	addi	s0,sp,112
 160:	8caa                	mv	s9,a0
 162:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 164:	892a                	mv	s2,a0
 166:	4481                	li	s1,0
    cc = read(0, &c, 1);
 168:	f9f40b13          	addi	s6,s0,-97
 16c:	4a85                	li	s5,1
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 16e:	4ba9                	li	s7,10
 170:	4c35                	li	s8,13
  for(i=0; i+1 < max; ){
 172:	8d26                	mv	s10,s1
 174:	0014899b          	addiw	s3,s1,1
 178:	84ce                	mv	s1,s3
 17a:	0349d563          	bge	s3,s4,1a4 <gets+0x60>
    cc = read(0, &c, 1);
 17e:	8656                	mv	a2,s5
 180:	85da                	mv	a1,s6
 182:	4501                	li	a0,0
 184:	198000ef          	jal	31c <read>
    if(cc < 1)
 188:	00a05e63          	blez	a0,1a4 <gets+0x60>
    buf[i++] = c;
 18c:	f9f44783          	lbu	a5,-97(s0)
 190:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 194:	01778763          	beq	a5,s7,1a2 <gets+0x5e>
 198:	0905                	addi	s2,s2,1
 19a:	fd879ce3          	bne	a5,s8,172 <gets+0x2e>
    buf[i++] = c;
 19e:	8d4e                	mv	s10,s3
 1a0:	a011                	j	1a4 <gets+0x60>
 1a2:	8d4e                	mv	s10,s3
      break;
  }
  buf[i] = '\0';
 1a4:	9d66                	add	s10,s10,s9
 1a6:	000d0023          	sb	zero,0(s10)
  return buf;
}
 1aa:	8566                	mv	a0,s9
 1ac:	70a6                	ld	ra,104(sp)
 1ae:	7406                	ld	s0,96(sp)
 1b0:	64e6                	ld	s1,88(sp)
 1b2:	6946                	ld	s2,80(sp)
 1b4:	69a6                	ld	s3,72(sp)
 1b6:	6a06                	ld	s4,64(sp)
 1b8:	7ae2                	ld	s5,56(sp)
 1ba:	7b42                	ld	s6,48(sp)
 1bc:	7ba2                	ld	s7,40(sp)
 1be:	7c02                	ld	s8,32(sp)
 1c0:	6ce2                	ld	s9,24(sp)
 1c2:	6d42                	ld	s10,16(sp)
 1c4:	6165                	addi	sp,sp,112
 1c6:	8082                	ret

00000000000001c8 <stat>:

int
stat(const char *n, struct stat *st)
{
 1c8:	1101                	addi	sp,sp,-32
 1ca:	ec06                	sd	ra,24(sp)
 1cc:	e822                	sd	s0,16(sp)
 1ce:	e04a                	sd	s2,0(sp)
 1d0:	1000                	addi	s0,sp,32
 1d2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1d4:	4581                	li	a1,0
 1d6:	16e000ef          	jal	344 <open>
  if(fd < 0)
 1da:	02054263          	bltz	a0,1fe <stat+0x36>
 1de:	e426                	sd	s1,8(sp)
 1e0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1e2:	85ca                	mv	a1,s2
 1e4:	178000ef          	jal	35c <fstat>
 1e8:	892a                	mv	s2,a0
  close(fd);
 1ea:	8526                	mv	a0,s1
 1ec:	140000ef          	jal	32c <close>
  return r;
 1f0:	64a2                	ld	s1,8(sp)
}
 1f2:	854a                	mv	a0,s2
 1f4:	60e2                	ld	ra,24(sp)
 1f6:	6442                	ld	s0,16(sp)
 1f8:	6902                	ld	s2,0(sp)
 1fa:	6105                	addi	sp,sp,32
 1fc:	8082                	ret
    return -1;
 1fe:	597d                	li	s2,-1
 200:	bfcd                	j	1f2 <stat+0x2a>

0000000000000202 <atoi>:

int
atoi(const char *s)
{
 202:	1141                	addi	sp,sp,-16
 204:	e406                	sd	ra,8(sp)
 206:	e022                	sd	s0,0(sp)
 208:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 20a:	00054683          	lbu	a3,0(a0)
 20e:	fd06879b          	addiw	a5,a3,-48
 212:	0ff7f793          	zext.b	a5,a5
 216:	4625                	li	a2,9
 218:	02f66963          	bltu	a2,a5,24a <atoi+0x48>
 21c:	872a                	mv	a4,a0
  n = 0;
 21e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 220:	0705                	addi	a4,a4,1
 222:	0025179b          	slliw	a5,a0,0x2
 226:	9fa9                	addw	a5,a5,a0
 228:	0017979b          	slliw	a5,a5,0x1
 22c:	9fb5                	addw	a5,a5,a3
 22e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 232:	00074683          	lbu	a3,0(a4)
 236:	fd06879b          	addiw	a5,a3,-48
 23a:	0ff7f793          	zext.b	a5,a5
 23e:	fef671e3          	bgeu	a2,a5,220 <atoi+0x1e>
  return n;
}
 242:	60a2                	ld	ra,8(sp)
 244:	6402                	ld	s0,0(sp)
 246:	0141                	addi	sp,sp,16
 248:	8082                	ret
  n = 0;
 24a:	4501                	li	a0,0
 24c:	bfdd                	j	242 <atoi+0x40>

000000000000024e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 24e:	1141                	addi	sp,sp,-16
 250:	e406                	sd	ra,8(sp)
 252:	e022                	sd	s0,0(sp)
 254:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 256:	02b57563          	bgeu	a0,a1,280 <memmove+0x32>
    while(n-- > 0)
 25a:	00c05f63          	blez	a2,278 <memmove+0x2a>
 25e:	1602                	slli	a2,a2,0x20
 260:	9201                	srli	a2,a2,0x20
 262:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 266:	872a                	mv	a4,a0
      *dst++ = *src++;
 268:	0585                	addi	a1,a1,1
 26a:	0705                	addi	a4,a4,1
 26c:	fff5c683          	lbu	a3,-1(a1)
 270:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 274:	fee79ae3          	bne	a5,a4,268 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 278:	60a2                	ld	ra,8(sp)
 27a:	6402                	ld	s0,0(sp)
 27c:	0141                	addi	sp,sp,16
 27e:	8082                	ret
    dst += n;
 280:	00c50733          	add	a4,a0,a2
    src += n;
 284:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 286:	fec059e3          	blez	a2,278 <memmove+0x2a>
 28a:	fff6079b          	addiw	a5,a2,-1
 28e:	1782                	slli	a5,a5,0x20
 290:	9381                	srli	a5,a5,0x20
 292:	fff7c793          	not	a5,a5
 296:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 298:	15fd                	addi	a1,a1,-1
 29a:	177d                	addi	a4,a4,-1
 29c:	0005c683          	lbu	a3,0(a1)
 2a0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2a4:	fef71ae3          	bne	a4,a5,298 <memmove+0x4a>
 2a8:	bfc1                	j	278 <memmove+0x2a>

00000000000002aa <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2aa:	1141                	addi	sp,sp,-16
 2ac:	e406                	sd	ra,8(sp)
 2ae:	e022                	sd	s0,0(sp)
 2b0:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2b2:	ca0d                	beqz	a2,2e4 <memcmp+0x3a>
 2b4:	fff6069b          	addiw	a3,a2,-1
 2b8:	1682                	slli	a3,a3,0x20
 2ba:	9281                	srli	a3,a3,0x20
 2bc:	0685                	addi	a3,a3,1
 2be:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2c0:	00054783          	lbu	a5,0(a0)
 2c4:	0005c703          	lbu	a4,0(a1)
 2c8:	00e79863          	bne	a5,a4,2d8 <memcmp+0x2e>
      return *p1 - *p2;
    }
    p1++;
 2cc:	0505                	addi	a0,a0,1
    p2++;
 2ce:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2d0:	fed518e3          	bne	a0,a3,2c0 <memcmp+0x16>
  }
  return 0;
 2d4:	4501                	li	a0,0
 2d6:	a019                	j	2dc <memcmp+0x32>
      return *p1 - *p2;
 2d8:	40e7853b          	subw	a0,a5,a4
}
 2dc:	60a2                	ld	ra,8(sp)
 2de:	6402                	ld	s0,0(sp)
 2e0:	0141                	addi	sp,sp,16
 2e2:	8082                	ret
  return 0;
 2e4:	4501                	li	a0,0
 2e6:	bfdd                	j	2dc <memcmp+0x32>

00000000000002e8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2e8:	1141                	addi	sp,sp,-16
 2ea:	e406                	sd	ra,8(sp)
 2ec:	e022                	sd	s0,0(sp)
 2ee:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2f0:	f5fff0ef          	jal	24e <memmove>
}
 2f4:	60a2                	ld	ra,8(sp)
 2f6:	6402                	ld	s0,0(sp)
 2f8:	0141                	addi	sp,sp,16
 2fa:	8082                	ret

00000000000002fc <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2fc:	4885                	li	a7,1
 ecall
 2fe:	00000073          	ecall
 ret
 302:	8082                	ret

0000000000000304 <exit>:
.global exit
exit:
 li a7, SYS_exit
 304:	4889                	li	a7,2
 ecall
 306:	00000073          	ecall
 ret
 30a:	8082                	ret

000000000000030c <wait>:
.global wait
wait:
 li a7, SYS_wait
 30c:	488d                	li	a7,3
 ecall
 30e:	00000073          	ecall
 ret
 312:	8082                	ret

0000000000000314 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 314:	4891                	li	a7,4
 ecall
 316:	00000073          	ecall
 ret
 31a:	8082                	ret

000000000000031c <read>:
.global read
read:
 li a7, SYS_read
 31c:	4895                	li	a7,5
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <write>:
.global write
write:
 li a7, SYS_write
 324:	48c1                	li	a7,16
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <close>:
.global close
close:
 li a7, SYS_close
 32c:	48d5                	li	a7,21
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <kill>:
.global kill
kill:
 li a7, SYS_kill
 334:	4899                	li	a7,6
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <exec>:
.global exec
exec:
 li a7, SYS_exec
 33c:	489d                	li	a7,7
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <open>:
.global open
open:
 li a7, SYS_open
 344:	48bd                	li	a7,15
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 34c:	48c5                	li	a7,17
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 354:	48c9                	li	a7,18
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 35c:	48a1                	li	a7,8
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <link>:
.global link
link:
 li a7, SYS_link
 364:	48cd                	li	a7,19
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 36c:	48d1                	li	a7,20
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 374:	48a5                	li	a7,9
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <dup>:
.global dup
dup:
 li a7, SYS_dup
 37c:	48a9                	li	a7,10
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 384:	48ad                	li	a7,11
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 38c:	48b1                	li	a7,12
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 394:	48b5                	li	a7,13
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 39c:	48b9                	li	a7,14
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <toggle_case>:
.global toggle_case
toggle_case:
 li a7, SYS_toggle_case
 3a4:	48d9                	li	a7,22
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3ac:	1101                	addi	sp,sp,-32
 3ae:	ec06                	sd	ra,24(sp)
 3b0:	e822                	sd	s0,16(sp)
 3b2:	1000                	addi	s0,sp,32
 3b4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3b8:	4605                	li	a2,1
 3ba:	fef40593          	addi	a1,s0,-17
 3be:	f67ff0ef          	jal	324 <write>
}
 3c2:	60e2                	ld	ra,24(sp)
 3c4:	6442                	ld	s0,16(sp)
 3c6:	6105                	addi	sp,sp,32
 3c8:	8082                	ret

00000000000003ca <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3ca:	7139                	addi	sp,sp,-64
 3cc:	fc06                	sd	ra,56(sp)
 3ce:	f822                	sd	s0,48(sp)
 3d0:	f426                	sd	s1,40(sp)
 3d2:	f04a                	sd	s2,32(sp)
 3d4:	ec4e                	sd	s3,24(sp)
 3d6:	0080                	addi	s0,sp,64
 3d8:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3da:	c299                	beqz	a3,3e0 <printint+0x16>
 3dc:	0605ce63          	bltz	a1,458 <printint+0x8e>
  neg = 0;
 3e0:	4e01                	li	t3,0
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 3e2:	fc040313          	addi	t1,s0,-64
  neg = 0;
 3e6:	869a                	mv	a3,t1
  i = 0;
 3e8:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 3ea:	00000817          	auipc	a6,0x0
 3ee:	51680813          	addi	a6,a6,1302 # 900 <digits>
 3f2:	88be                	mv	a7,a5
 3f4:	0017851b          	addiw	a0,a5,1
 3f8:	87aa                	mv	a5,a0
 3fa:	02c5f73b          	remuw	a4,a1,a2
 3fe:	1702                	slli	a4,a4,0x20
 400:	9301                	srli	a4,a4,0x20
 402:	9742                	add	a4,a4,a6
 404:	00074703          	lbu	a4,0(a4)
 408:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 40c:	872e                	mv	a4,a1
 40e:	02c5d5bb          	divuw	a1,a1,a2
 412:	0685                	addi	a3,a3,1
 414:	fcc77fe3          	bgeu	a4,a2,3f2 <printint+0x28>
  if(neg)
 418:	000e0c63          	beqz	t3,430 <printint+0x66>
    buf[i++] = '-';
 41c:	fd050793          	addi	a5,a0,-48
 420:	00878533          	add	a0,a5,s0
 424:	02d00793          	li	a5,45
 428:	fef50823          	sb	a5,-16(a0)
 42c:	0028879b          	addiw	a5,a7,2

  while(--i >= 0)
 430:	fff7899b          	addiw	s3,a5,-1
 434:	006784b3          	add	s1,a5,t1
    putc(fd, buf[i]);
 438:	fff4c583          	lbu	a1,-1(s1)
 43c:	854a                	mv	a0,s2
 43e:	f6fff0ef          	jal	3ac <putc>
  while(--i >= 0)
 442:	39fd                	addiw	s3,s3,-1
 444:	14fd                	addi	s1,s1,-1
 446:	fe09d9e3          	bgez	s3,438 <printint+0x6e>
}
 44a:	70e2                	ld	ra,56(sp)
 44c:	7442                	ld	s0,48(sp)
 44e:	74a2                	ld	s1,40(sp)
 450:	7902                	ld	s2,32(sp)
 452:	69e2                	ld	s3,24(sp)
 454:	6121                	addi	sp,sp,64
 456:	8082                	ret
    x = -xx;
 458:	40b005bb          	negw	a1,a1
    neg = 1;
 45c:	4e05                	li	t3,1
    x = -xx;
 45e:	b751                	j	3e2 <printint+0x18>

0000000000000460 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 460:	711d                	addi	sp,sp,-96
 462:	ec86                	sd	ra,88(sp)
 464:	e8a2                	sd	s0,80(sp)
 466:	e4a6                	sd	s1,72(sp)
 468:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 46a:	0005c483          	lbu	s1,0(a1)
 46e:	26048663          	beqz	s1,6da <vprintf+0x27a>
 472:	e0ca                	sd	s2,64(sp)
 474:	fc4e                	sd	s3,56(sp)
 476:	f852                	sd	s4,48(sp)
 478:	f456                	sd	s5,40(sp)
 47a:	f05a                	sd	s6,32(sp)
 47c:	ec5e                	sd	s7,24(sp)
 47e:	e862                	sd	s8,16(sp)
 480:	e466                	sd	s9,8(sp)
 482:	8b2a                	mv	s6,a0
 484:	8a2e                	mv	s4,a1
 486:	8bb2                	mv	s7,a2
  state = 0;
 488:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 48a:	4901                	li	s2,0
 48c:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 48e:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 492:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 496:	06c00c93          	li	s9,108
 49a:	a00d                	j	4bc <vprintf+0x5c>
        putc(fd, c0);
 49c:	85a6                	mv	a1,s1
 49e:	855a                	mv	a0,s6
 4a0:	f0dff0ef          	jal	3ac <putc>
 4a4:	a019                	j	4aa <vprintf+0x4a>
    } else if(state == '%'){
 4a6:	03598363          	beq	s3,s5,4cc <vprintf+0x6c>
  for(i = 0; fmt[i]; i++){
 4aa:	0019079b          	addiw	a5,s2,1
 4ae:	893e                	mv	s2,a5
 4b0:	873e                	mv	a4,a5
 4b2:	97d2                	add	a5,a5,s4
 4b4:	0007c483          	lbu	s1,0(a5)
 4b8:	20048963          	beqz	s1,6ca <vprintf+0x26a>
    c0 = fmt[i] & 0xff;
 4bc:	0004879b          	sext.w	a5,s1
    if(state == 0){
 4c0:	fe0993e3          	bnez	s3,4a6 <vprintf+0x46>
      if(c0 == '%'){
 4c4:	fd579ce3          	bne	a5,s5,49c <vprintf+0x3c>
        state = '%';
 4c8:	89be                	mv	s3,a5
 4ca:	b7c5                	j	4aa <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 4cc:	00ea06b3          	add	a3,s4,a4
 4d0:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 4d4:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 4d6:	c681                	beqz	a3,4de <vprintf+0x7e>
 4d8:	9752                	add	a4,a4,s4
 4da:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 4de:	03878e63          	beq	a5,s8,51a <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 4e2:	05978863          	beq	a5,s9,532 <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 4e6:	07500713          	li	a4,117
 4ea:	0ee78263          	beq	a5,a4,5ce <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 4ee:	07800713          	li	a4,120
 4f2:	12e78463          	beq	a5,a4,61a <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 4f6:	07000713          	li	a4,112
 4fa:	14e78963          	beq	a5,a4,64c <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 4fe:	07300713          	li	a4,115
 502:	18e78863          	beq	a5,a4,692 <vprintf+0x232>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 506:	02500713          	li	a4,37
 50a:	04e79463          	bne	a5,a4,552 <vprintf+0xf2>
        putc(fd, '%');
 50e:	85ba                	mv	a1,a4
 510:	855a                	mv	a0,s6
 512:	e9bff0ef          	jal	3ac <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 516:	4981                	li	s3,0
 518:	bf49                	j	4aa <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 51a:	008b8493          	addi	s1,s7,8
 51e:	4685                	li	a3,1
 520:	4629                	li	a2,10
 522:	000ba583          	lw	a1,0(s7)
 526:	855a                	mv	a0,s6
 528:	ea3ff0ef          	jal	3ca <printint>
 52c:	8ba6                	mv	s7,s1
      state = 0;
 52e:	4981                	li	s3,0
 530:	bfad                	j	4aa <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 532:	06400793          	li	a5,100
 536:	02f68963          	beq	a3,a5,568 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 53a:	06c00793          	li	a5,108
 53e:	04f68263          	beq	a3,a5,582 <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 542:	07500793          	li	a5,117
 546:	0af68063          	beq	a3,a5,5e6 <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 54a:	07800793          	li	a5,120
 54e:	0ef68263          	beq	a3,a5,632 <vprintf+0x1d2>
        putc(fd, '%');
 552:	02500593          	li	a1,37
 556:	855a                	mv	a0,s6
 558:	e55ff0ef          	jal	3ac <putc>
        putc(fd, c0);
 55c:	85a6                	mv	a1,s1
 55e:	855a                	mv	a0,s6
 560:	e4dff0ef          	jal	3ac <putc>
      state = 0;
 564:	4981                	li	s3,0
 566:	b791                	j	4aa <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 568:	008b8493          	addi	s1,s7,8
 56c:	4685                	li	a3,1
 56e:	4629                	li	a2,10
 570:	000ba583          	lw	a1,0(s7)
 574:	855a                	mv	a0,s6
 576:	e55ff0ef          	jal	3ca <printint>
        i += 1;
 57a:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 57c:	8ba6                	mv	s7,s1
      state = 0;
 57e:	4981                	li	s3,0
        i += 1;
 580:	b72d                	j	4aa <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 582:	06400793          	li	a5,100
 586:	02f60763          	beq	a2,a5,5b4 <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 58a:	07500793          	li	a5,117
 58e:	06f60963          	beq	a2,a5,600 <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 592:	07800793          	li	a5,120
 596:	faf61ee3          	bne	a2,a5,552 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 59a:	008b8493          	addi	s1,s7,8
 59e:	4681                	li	a3,0
 5a0:	4641                	li	a2,16
 5a2:	000ba583          	lw	a1,0(s7)
 5a6:	855a                	mv	a0,s6
 5a8:	e23ff0ef          	jal	3ca <printint>
        i += 2;
 5ac:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5ae:	8ba6                	mv	s7,s1
      state = 0;
 5b0:	4981                	li	s3,0
        i += 2;
 5b2:	bde5                	j	4aa <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5b4:	008b8493          	addi	s1,s7,8
 5b8:	4685                	li	a3,1
 5ba:	4629                	li	a2,10
 5bc:	000ba583          	lw	a1,0(s7)
 5c0:	855a                	mv	a0,s6
 5c2:	e09ff0ef          	jal	3ca <printint>
        i += 2;
 5c6:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5c8:	8ba6                	mv	s7,s1
      state = 0;
 5ca:	4981                	li	s3,0
        i += 2;
 5cc:	bdf9                	j	4aa <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 5ce:	008b8493          	addi	s1,s7,8
 5d2:	4681                	li	a3,0
 5d4:	4629                	li	a2,10
 5d6:	000ba583          	lw	a1,0(s7)
 5da:	855a                	mv	a0,s6
 5dc:	defff0ef          	jal	3ca <printint>
 5e0:	8ba6                	mv	s7,s1
      state = 0;
 5e2:	4981                	li	s3,0
 5e4:	b5d9                	j	4aa <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5e6:	008b8493          	addi	s1,s7,8
 5ea:	4681                	li	a3,0
 5ec:	4629                	li	a2,10
 5ee:	000ba583          	lw	a1,0(s7)
 5f2:	855a                	mv	a0,s6
 5f4:	dd7ff0ef          	jal	3ca <printint>
        i += 1;
 5f8:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5fa:	8ba6                	mv	s7,s1
      state = 0;
 5fc:	4981                	li	s3,0
        i += 1;
 5fe:	b575                	j	4aa <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 600:	008b8493          	addi	s1,s7,8
 604:	4681                	li	a3,0
 606:	4629                	li	a2,10
 608:	000ba583          	lw	a1,0(s7)
 60c:	855a                	mv	a0,s6
 60e:	dbdff0ef          	jal	3ca <printint>
        i += 2;
 612:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 614:	8ba6                	mv	s7,s1
      state = 0;
 616:	4981                	li	s3,0
        i += 2;
 618:	bd49                	j	4aa <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 61a:	008b8493          	addi	s1,s7,8
 61e:	4681                	li	a3,0
 620:	4641                	li	a2,16
 622:	000ba583          	lw	a1,0(s7)
 626:	855a                	mv	a0,s6
 628:	da3ff0ef          	jal	3ca <printint>
 62c:	8ba6                	mv	s7,s1
      state = 0;
 62e:	4981                	li	s3,0
 630:	bdad                	j	4aa <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 632:	008b8493          	addi	s1,s7,8
 636:	4681                	li	a3,0
 638:	4641                	li	a2,16
 63a:	000ba583          	lw	a1,0(s7)
 63e:	855a                	mv	a0,s6
 640:	d8bff0ef          	jal	3ca <printint>
        i += 1;
 644:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 646:	8ba6                	mv	s7,s1
      state = 0;
 648:	4981                	li	s3,0
        i += 1;
 64a:	b585                	j	4aa <vprintf+0x4a>
 64c:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 64e:	008b8d13          	addi	s10,s7,8
 652:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 656:	03000593          	li	a1,48
 65a:	855a                	mv	a0,s6
 65c:	d51ff0ef          	jal	3ac <putc>
  putc(fd, 'x');
 660:	07800593          	li	a1,120
 664:	855a                	mv	a0,s6
 666:	d47ff0ef          	jal	3ac <putc>
 66a:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 66c:	00000b97          	auipc	s7,0x0
 670:	294b8b93          	addi	s7,s7,660 # 900 <digits>
 674:	03c9d793          	srli	a5,s3,0x3c
 678:	97de                	add	a5,a5,s7
 67a:	0007c583          	lbu	a1,0(a5)
 67e:	855a                	mv	a0,s6
 680:	d2dff0ef          	jal	3ac <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 684:	0992                	slli	s3,s3,0x4
 686:	34fd                	addiw	s1,s1,-1
 688:	f4f5                	bnez	s1,674 <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 68a:	8bea                	mv	s7,s10
      state = 0;
 68c:	4981                	li	s3,0
 68e:	6d02                	ld	s10,0(sp)
 690:	bd29                	j	4aa <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 692:	008b8993          	addi	s3,s7,8
 696:	000bb483          	ld	s1,0(s7)
 69a:	cc91                	beqz	s1,6b6 <vprintf+0x256>
        for(; *s; s++)
 69c:	0004c583          	lbu	a1,0(s1)
 6a0:	c195                	beqz	a1,6c4 <vprintf+0x264>
          putc(fd, *s);
 6a2:	855a                	mv	a0,s6
 6a4:	d09ff0ef          	jal	3ac <putc>
        for(; *s; s++)
 6a8:	0485                	addi	s1,s1,1
 6aa:	0004c583          	lbu	a1,0(s1)
 6ae:	f9f5                	bnez	a1,6a2 <vprintf+0x242>
        if((s = va_arg(ap, char*)) == 0)
 6b0:	8bce                	mv	s7,s3
      state = 0;
 6b2:	4981                	li	s3,0
 6b4:	bbdd                	j	4aa <vprintf+0x4a>
          s = "(null)";
 6b6:	00000497          	auipc	s1,0x0
 6ba:	24248493          	addi	s1,s1,578 # 8f8 <malloc+0x132>
        for(; *s; s++)
 6be:	02800593          	li	a1,40
 6c2:	b7c5                	j	6a2 <vprintf+0x242>
        if((s = va_arg(ap, char*)) == 0)
 6c4:	8bce                	mv	s7,s3
      state = 0;
 6c6:	4981                	li	s3,0
 6c8:	b3cd                	j	4aa <vprintf+0x4a>
 6ca:	6906                	ld	s2,64(sp)
 6cc:	79e2                	ld	s3,56(sp)
 6ce:	7a42                	ld	s4,48(sp)
 6d0:	7aa2                	ld	s5,40(sp)
 6d2:	7b02                	ld	s6,32(sp)
 6d4:	6be2                	ld	s7,24(sp)
 6d6:	6c42                	ld	s8,16(sp)
 6d8:	6ca2                	ld	s9,8(sp)
    }
  }
}
 6da:	60e6                	ld	ra,88(sp)
 6dc:	6446                	ld	s0,80(sp)
 6de:	64a6                	ld	s1,72(sp)
 6e0:	6125                	addi	sp,sp,96
 6e2:	8082                	ret

00000000000006e4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6e4:	715d                	addi	sp,sp,-80
 6e6:	ec06                	sd	ra,24(sp)
 6e8:	e822                	sd	s0,16(sp)
 6ea:	1000                	addi	s0,sp,32
 6ec:	e010                	sd	a2,0(s0)
 6ee:	e414                	sd	a3,8(s0)
 6f0:	e818                	sd	a4,16(s0)
 6f2:	ec1c                	sd	a5,24(s0)
 6f4:	03043023          	sd	a6,32(s0)
 6f8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6fc:	8622                	mv	a2,s0
 6fe:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 702:	d5fff0ef          	jal	460 <vprintf>
}
 706:	60e2                	ld	ra,24(sp)
 708:	6442                	ld	s0,16(sp)
 70a:	6161                	addi	sp,sp,80
 70c:	8082                	ret

000000000000070e <printf>:

void
printf(const char *fmt, ...)
{
 70e:	711d                	addi	sp,sp,-96
 710:	ec06                	sd	ra,24(sp)
 712:	e822                	sd	s0,16(sp)
 714:	1000                	addi	s0,sp,32
 716:	e40c                	sd	a1,8(s0)
 718:	e810                	sd	a2,16(s0)
 71a:	ec14                	sd	a3,24(s0)
 71c:	f018                	sd	a4,32(s0)
 71e:	f41c                	sd	a5,40(s0)
 720:	03043823          	sd	a6,48(s0)
 724:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 728:	00840613          	addi	a2,s0,8
 72c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 730:	85aa                	mv	a1,a0
 732:	4505                	li	a0,1
 734:	d2dff0ef          	jal	460 <vprintf>
}
 738:	60e2                	ld	ra,24(sp)
 73a:	6442                	ld	s0,16(sp)
 73c:	6125                	addi	sp,sp,96
 73e:	8082                	ret

0000000000000740 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 740:	1141                	addi	sp,sp,-16
 742:	e406                	sd	ra,8(sp)
 744:	e022                	sd	s0,0(sp)
 746:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 748:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 74c:	00001797          	auipc	a5,0x1
 750:	8b47b783          	ld	a5,-1868(a5) # 1000 <freep>
 754:	a02d                	j	77e <free+0x3e>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 756:	4618                	lw	a4,8(a2)
 758:	9f2d                	addw	a4,a4,a1
 75a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 75e:	6398                	ld	a4,0(a5)
 760:	6310                	ld	a2,0(a4)
 762:	a83d                	j	7a0 <free+0x60>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 764:	ff852703          	lw	a4,-8(a0)
 768:	9f31                	addw	a4,a4,a2
 76a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 76c:	ff053683          	ld	a3,-16(a0)
 770:	a091                	j	7b4 <free+0x74>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 772:	6398                	ld	a4,0(a5)
 774:	00e7e463          	bltu	a5,a4,77c <free+0x3c>
 778:	00e6ea63          	bltu	a3,a4,78c <free+0x4c>
{
 77c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 77e:	fed7fae3          	bgeu	a5,a3,772 <free+0x32>
 782:	6398                	ld	a4,0(a5)
 784:	00e6e463          	bltu	a3,a4,78c <free+0x4c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 788:	fee7eae3          	bltu	a5,a4,77c <free+0x3c>
  if(bp + bp->s.size == p->s.ptr){
 78c:	ff852583          	lw	a1,-8(a0)
 790:	6390                	ld	a2,0(a5)
 792:	02059813          	slli	a6,a1,0x20
 796:	01c85713          	srli	a4,a6,0x1c
 79a:	9736                	add	a4,a4,a3
 79c:	fae60de3          	beq	a2,a4,756 <free+0x16>
    bp->s.ptr = p->s.ptr->s.ptr;
 7a0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7a4:	4790                	lw	a2,8(a5)
 7a6:	02061593          	slli	a1,a2,0x20
 7aa:	01c5d713          	srli	a4,a1,0x1c
 7ae:	973e                	add	a4,a4,a5
 7b0:	fae68ae3          	beq	a3,a4,764 <free+0x24>
    p->s.ptr = bp->s.ptr;
 7b4:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7b6:	00001717          	auipc	a4,0x1
 7ba:	84f73523          	sd	a5,-1974(a4) # 1000 <freep>
}
 7be:	60a2                	ld	ra,8(sp)
 7c0:	6402                	ld	s0,0(sp)
 7c2:	0141                	addi	sp,sp,16
 7c4:	8082                	ret

00000000000007c6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7c6:	7139                	addi	sp,sp,-64
 7c8:	fc06                	sd	ra,56(sp)
 7ca:	f822                	sd	s0,48(sp)
 7cc:	f04a                	sd	s2,32(sp)
 7ce:	ec4e                	sd	s3,24(sp)
 7d0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7d2:	02051993          	slli	s3,a0,0x20
 7d6:	0209d993          	srli	s3,s3,0x20
 7da:	09bd                	addi	s3,s3,15
 7dc:	0049d993          	srli	s3,s3,0x4
 7e0:	2985                	addiw	s3,s3,1
 7e2:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 7e4:	00001517          	auipc	a0,0x1
 7e8:	81c53503          	ld	a0,-2020(a0) # 1000 <freep>
 7ec:	c905                	beqz	a0,81c <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7ee:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7f0:	4798                	lw	a4,8(a5)
 7f2:	09377663          	bgeu	a4,s3,87e <malloc+0xb8>
 7f6:	f426                	sd	s1,40(sp)
 7f8:	e852                	sd	s4,16(sp)
 7fa:	e456                	sd	s5,8(sp)
 7fc:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 7fe:	8a4e                	mv	s4,s3
 800:	6705                	lui	a4,0x1
 802:	00e9f363          	bgeu	s3,a4,808 <malloc+0x42>
 806:	6a05                	lui	s4,0x1
 808:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 80c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 810:	00000497          	auipc	s1,0x0
 814:	7f048493          	addi	s1,s1,2032 # 1000 <freep>
  if(p == (char*)-1)
 818:	5afd                	li	s5,-1
 81a:	a83d                	j	858 <malloc+0x92>
 81c:	f426                	sd	s1,40(sp)
 81e:	e852                	sd	s4,16(sp)
 820:	e456                	sd	s5,8(sp)
 822:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 824:	00000797          	auipc	a5,0x0
 828:	7ec78793          	addi	a5,a5,2028 # 1010 <base>
 82c:	00000717          	auipc	a4,0x0
 830:	7cf73a23          	sd	a5,2004(a4) # 1000 <freep>
 834:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 836:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 83a:	b7d1                	j	7fe <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 83c:	6398                	ld	a4,0(a5)
 83e:	e118                	sd	a4,0(a0)
 840:	a899                	j	896 <malloc+0xd0>
  hp->s.size = nu;
 842:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 846:	0541                	addi	a0,a0,16
 848:	ef9ff0ef          	jal	740 <free>
  return freep;
 84c:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 84e:	c125                	beqz	a0,8ae <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 850:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 852:	4798                	lw	a4,8(a5)
 854:	03277163          	bgeu	a4,s2,876 <malloc+0xb0>
    if(p == freep)
 858:	6098                	ld	a4,0(s1)
 85a:	853e                	mv	a0,a5
 85c:	fef71ae3          	bne	a4,a5,850 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 860:	8552                	mv	a0,s4
 862:	b2bff0ef          	jal	38c <sbrk>
  if(p == (char*)-1)
 866:	fd551ee3          	bne	a0,s5,842 <malloc+0x7c>
        return 0;
 86a:	4501                	li	a0,0
 86c:	74a2                	ld	s1,40(sp)
 86e:	6a42                	ld	s4,16(sp)
 870:	6aa2                	ld	s5,8(sp)
 872:	6b02                	ld	s6,0(sp)
 874:	a03d                	j	8a2 <malloc+0xdc>
 876:	74a2                	ld	s1,40(sp)
 878:	6a42                	ld	s4,16(sp)
 87a:	6aa2                	ld	s5,8(sp)
 87c:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 87e:	fae90fe3          	beq	s2,a4,83c <malloc+0x76>
        p->s.size -= nunits;
 882:	4137073b          	subw	a4,a4,s3
 886:	c798                	sw	a4,8(a5)
        p += p->s.size;
 888:	02071693          	slli	a3,a4,0x20
 88c:	01c6d713          	srli	a4,a3,0x1c
 890:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 892:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 896:	00000717          	auipc	a4,0x0
 89a:	76a73523          	sd	a0,1898(a4) # 1000 <freep>
      return (void*)(p + 1);
 89e:	01078513          	addi	a0,a5,16
  }
}
 8a2:	70e2                	ld	ra,56(sp)
 8a4:	7442                	ld	s0,48(sp)
 8a6:	7902                	ld	s2,32(sp)
 8a8:	69e2                	ld	s3,24(sp)
 8aa:	6121                	addi	sp,sp,64
 8ac:	8082                	ret
 8ae:	74a2                	ld	s1,40(sp)
 8b0:	6a42                	ld	s4,16(sp)
 8b2:	6aa2                	ld	s5,8(sp)
 8b4:	6b02                	ld	s6,0(sp)
 8b6:	b7f5                	j	8a2 <malloc+0xdc>
