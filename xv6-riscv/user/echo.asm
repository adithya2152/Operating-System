
user/_echo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	e852                	sd	s4,16(sp)
   e:	e456                	sd	s5,8(sp)
  10:	e05a                	sd	s6,0(sp)
  12:	0080                	addi	s0,sp,64
  int i;

  for(i = 1; i < argc; i++){
  14:	4785                	li	a5,1
  16:	06a7d063          	bge	a5,a0,76 <main+0x76>
  1a:	00858493          	addi	s1,a1,8
  1e:	3579                	addiw	a0,a0,-2
  20:	02051793          	slli	a5,a0,0x20
  24:	01d7d513          	srli	a0,a5,0x1d
  28:	00a48ab3          	add	s5,s1,a0
  2c:	05c1                	addi	a1,a1,16
  2e:	00a58a33          	add	s4,a1,a0
    write(1, argv[i], strlen(argv[i]));
  32:	4985                	li	s3,1
    if(i + 1 < argc){
      write(1, " ", 1);
  34:	00001b17          	auipc	s6,0x1
  38:	89cb0b13          	addi	s6,s6,-1892 # 8d0 <malloc+0xf4>
  3c:	a809                	j	4e <main+0x4e>
  3e:	864e                	mv	a2,s3
  40:	85da                	mv	a1,s6
  42:	854e                	mv	a0,s3
  44:	2f6000ef          	jal	33a <write>
  for(i = 1; i < argc; i++){
  48:	04a1                	addi	s1,s1,8
  4a:	03448663          	beq	s1,s4,76 <main+0x76>
    write(1, argv[i], strlen(argv[i]));
  4e:	0004b903          	ld	s2,0(s1)
  52:	854a                	mv	a0,s2
  54:	08a000ef          	jal	de <strlen>
  58:	862a                	mv	a2,a0
  5a:	85ca                	mv	a1,s2
  5c:	854e                	mv	a0,s3
  5e:	2dc000ef          	jal	33a <write>
    if(i + 1 < argc){
  62:	fd549ee3          	bne	s1,s5,3e <main+0x3e>
    } else {
      write(1, "\n", 1);
  66:	4605                	li	a2,1
  68:	00001597          	auipc	a1,0x1
  6c:	87058593          	addi	a1,a1,-1936 # 8d8 <malloc+0xfc>
  70:	8532                	mv	a0,a2
  72:	2c8000ef          	jal	33a <write>
    }
  }
  exit(0);
  76:	4501                	li	a0,0
  78:	2a2000ef          	jal	31a <exit>

000000000000007c <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
  7c:	1141                	addi	sp,sp,-16
  7e:	e406                	sd	ra,8(sp)
  80:	e022                	sd	s0,0(sp)
  82:	0800                	addi	s0,sp,16
  extern int main();
  main();
  84:	f7dff0ef          	jal	0 <main>
  exit(0);
  88:	4501                	li	a0,0
  8a:	290000ef          	jal	31a <exit>

000000000000008e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  8e:	1141                	addi	sp,sp,-16
  90:	e406                	sd	ra,8(sp)
  92:	e022                	sd	s0,0(sp)
  94:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  96:	87aa                	mv	a5,a0
  98:	0585                	addi	a1,a1,1
  9a:	0785                	addi	a5,a5,1
  9c:	fff5c703          	lbu	a4,-1(a1)
  a0:	fee78fa3          	sb	a4,-1(a5)
  a4:	fb75                	bnez	a4,98 <strcpy+0xa>
    ;
  return os;
}
  a6:	60a2                	ld	ra,8(sp)
  a8:	6402                	ld	s0,0(sp)
  aa:	0141                	addi	sp,sp,16
  ac:	8082                	ret

00000000000000ae <strcmp>:

int
strcmp(const char *p, const char *q)
{
  ae:	1141                	addi	sp,sp,-16
  b0:	e406                	sd	ra,8(sp)
  b2:	e022                	sd	s0,0(sp)
  b4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  b6:	00054783          	lbu	a5,0(a0)
  ba:	cb91                	beqz	a5,ce <strcmp+0x20>
  bc:	0005c703          	lbu	a4,0(a1)
  c0:	00f71763          	bne	a4,a5,ce <strcmp+0x20>
    p++, q++;
  c4:	0505                	addi	a0,a0,1
  c6:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  c8:	00054783          	lbu	a5,0(a0)
  cc:	fbe5                	bnez	a5,bc <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
  ce:	0005c503          	lbu	a0,0(a1)
}
  d2:	40a7853b          	subw	a0,a5,a0
  d6:	60a2                	ld	ra,8(sp)
  d8:	6402                	ld	s0,0(sp)
  da:	0141                	addi	sp,sp,16
  dc:	8082                	ret

00000000000000de <strlen>:

uint
strlen(const char *s)
{
  de:	1141                	addi	sp,sp,-16
  e0:	e406                	sd	ra,8(sp)
  e2:	e022                	sd	s0,0(sp)
  e4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  e6:	00054783          	lbu	a5,0(a0)
  ea:	cf99                	beqz	a5,108 <strlen+0x2a>
  ec:	0505                	addi	a0,a0,1
  ee:	87aa                	mv	a5,a0
  f0:	86be                	mv	a3,a5
  f2:	0785                	addi	a5,a5,1
  f4:	fff7c703          	lbu	a4,-1(a5)
  f8:	ff65                	bnez	a4,f0 <strlen+0x12>
  fa:	40a6853b          	subw	a0,a3,a0
  fe:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 100:	60a2                	ld	ra,8(sp)
 102:	6402                	ld	s0,0(sp)
 104:	0141                	addi	sp,sp,16
 106:	8082                	ret
  for(n = 0; s[n]; n++)
 108:	4501                	li	a0,0
 10a:	bfdd                	j	100 <strlen+0x22>

000000000000010c <memset>:

void*
memset(void *dst, int c, uint n)
{
 10c:	1141                	addi	sp,sp,-16
 10e:	e406                	sd	ra,8(sp)
 110:	e022                	sd	s0,0(sp)
 112:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 114:	ca19                	beqz	a2,12a <memset+0x1e>
 116:	87aa                	mv	a5,a0
 118:	1602                	slli	a2,a2,0x20
 11a:	9201                	srli	a2,a2,0x20
 11c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 120:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 124:	0785                	addi	a5,a5,1
 126:	fee79de3          	bne	a5,a4,120 <memset+0x14>
  }
  return dst;
}
 12a:	60a2                	ld	ra,8(sp)
 12c:	6402                	ld	s0,0(sp)
 12e:	0141                	addi	sp,sp,16
 130:	8082                	ret

0000000000000132 <strchr>:

char*
strchr(const char *s, char c)
{
 132:	1141                	addi	sp,sp,-16
 134:	e406                	sd	ra,8(sp)
 136:	e022                	sd	s0,0(sp)
 138:	0800                	addi	s0,sp,16
  for(; *s; s++)
 13a:	00054783          	lbu	a5,0(a0)
 13e:	cf81                	beqz	a5,156 <strchr+0x24>
    if(*s == c)
 140:	00f58763          	beq	a1,a5,14e <strchr+0x1c>
  for(; *s; s++)
 144:	0505                	addi	a0,a0,1
 146:	00054783          	lbu	a5,0(a0)
 14a:	fbfd                	bnez	a5,140 <strchr+0xe>
      return (char*)s;
  return 0;
 14c:	4501                	li	a0,0
}
 14e:	60a2                	ld	ra,8(sp)
 150:	6402                	ld	s0,0(sp)
 152:	0141                	addi	sp,sp,16
 154:	8082                	ret
  return 0;
 156:	4501                	li	a0,0
 158:	bfdd                	j	14e <strchr+0x1c>

000000000000015a <gets>:

char*
gets(char *buf, int max)
{
 15a:	7159                	addi	sp,sp,-112
 15c:	f486                	sd	ra,104(sp)
 15e:	f0a2                	sd	s0,96(sp)
 160:	eca6                	sd	s1,88(sp)
 162:	e8ca                	sd	s2,80(sp)
 164:	e4ce                	sd	s3,72(sp)
 166:	e0d2                	sd	s4,64(sp)
 168:	fc56                	sd	s5,56(sp)
 16a:	f85a                	sd	s6,48(sp)
 16c:	f45e                	sd	s7,40(sp)
 16e:	f062                	sd	s8,32(sp)
 170:	ec66                	sd	s9,24(sp)
 172:	e86a                	sd	s10,16(sp)
 174:	1880                	addi	s0,sp,112
 176:	8caa                	mv	s9,a0
 178:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 17a:	892a                	mv	s2,a0
 17c:	4481                	li	s1,0
    cc = read(0, &c, 1);
 17e:	f9f40b13          	addi	s6,s0,-97
 182:	4a85                	li	s5,1
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 184:	4ba9                	li	s7,10
 186:	4c35                	li	s8,13
  for(i=0; i+1 < max; ){
 188:	8d26                	mv	s10,s1
 18a:	0014899b          	addiw	s3,s1,1
 18e:	84ce                	mv	s1,s3
 190:	0349d563          	bge	s3,s4,1ba <gets+0x60>
    cc = read(0, &c, 1);
 194:	8656                	mv	a2,s5
 196:	85da                	mv	a1,s6
 198:	4501                	li	a0,0
 19a:	198000ef          	jal	332 <read>
    if(cc < 1)
 19e:	00a05e63          	blez	a0,1ba <gets+0x60>
    buf[i++] = c;
 1a2:	f9f44783          	lbu	a5,-97(s0)
 1a6:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1aa:	01778763          	beq	a5,s7,1b8 <gets+0x5e>
 1ae:	0905                	addi	s2,s2,1
 1b0:	fd879ce3          	bne	a5,s8,188 <gets+0x2e>
    buf[i++] = c;
 1b4:	8d4e                	mv	s10,s3
 1b6:	a011                	j	1ba <gets+0x60>
 1b8:	8d4e                	mv	s10,s3
      break;
  }
  buf[i] = '\0';
 1ba:	9d66                	add	s10,s10,s9
 1bc:	000d0023          	sb	zero,0(s10)
  return buf;
}
 1c0:	8566                	mv	a0,s9
 1c2:	70a6                	ld	ra,104(sp)
 1c4:	7406                	ld	s0,96(sp)
 1c6:	64e6                	ld	s1,88(sp)
 1c8:	6946                	ld	s2,80(sp)
 1ca:	69a6                	ld	s3,72(sp)
 1cc:	6a06                	ld	s4,64(sp)
 1ce:	7ae2                	ld	s5,56(sp)
 1d0:	7b42                	ld	s6,48(sp)
 1d2:	7ba2                	ld	s7,40(sp)
 1d4:	7c02                	ld	s8,32(sp)
 1d6:	6ce2                	ld	s9,24(sp)
 1d8:	6d42                	ld	s10,16(sp)
 1da:	6165                	addi	sp,sp,112
 1dc:	8082                	ret

00000000000001de <stat>:

int
stat(const char *n, struct stat *st)
{
 1de:	1101                	addi	sp,sp,-32
 1e0:	ec06                	sd	ra,24(sp)
 1e2:	e822                	sd	s0,16(sp)
 1e4:	e04a                	sd	s2,0(sp)
 1e6:	1000                	addi	s0,sp,32
 1e8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1ea:	4581                	li	a1,0
 1ec:	16e000ef          	jal	35a <open>
  if(fd < 0)
 1f0:	02054263          	bltz	a0,214 <stat+0x36>
 1f4:	e426                	sd	s1,8(sp)
 1f6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1f8:	85ca                	mv	a1,s2
 1fa:	178000ef          	jal	372 <fstat>
 1fe:	892a                	mv	s2,a0
  close(fd);
 200:	8526                	mv	a0,s1
 202:	140000ef          	jal	342 <close>
  return r;
 206:	64a2                	ld	s1,8(sp)
}
 208:	854a                	mv	a0,s2
 20a:	60e2                	ld	ra,24(sp)
 20c:	6442                	ld	s0,16(sp)
 20e:	6902                	ld	s2,0(sp)
 210:	6105                	addi	sp,sp,32
 212:	8082                	ret
    return -1;
 214:	597d                	li	s2,-1
 216:	bfcd                	j	208 <stat+0x2a>

0000000000000218 <atoi>:

int
atoi(const char *s)
{
 218:	1141                	addi	sp,sp,-16
 21a:	e406                	sd	ra,8(sp)
 21c:	e022                	sd	s0,0(sp)
 21e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 220:	00054683          	lbu	a3,0(a0)
 224:	fd06879b          	addiw	a5,a3,-48
 228:	0ff7f793          	zext.b	a5,a5
 22c:	4625                	li	a2,9
 22e:	02f66963          	bltu	a2,a5,260 <atoi+0x48>
 232:	872a                	mv	a4,a0
  n = 0;
 234:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 236:	0705                	addi	a4,a4,1
 238:	0025179b          	slliw	a5,a0,0x2
 23c:	9fa9                	addw	a5,a5,a0
 23e:	0017979b          	slliw	a5,a5,0x1
 242:	9fb5                	addw	a5,a5,a3
 244:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 248:	00074683          	lbu	a3,0(a4)
 24c:	fd06879b          	addiw	a5,a3,-48
 250:	0ff7f793          	zext.b	a5,a5
 254:	fef671e3          	bgeu	a2,a5,236 <atoi+0x1e>
  return n;
}
 258:	60a2                	ld	ra,8(sp)
 25a:	6402                	ld	s0,0(sp)
 25c:	0141                	addi	sp,sp,16
 25e:	8082                	ret
  n = 0;
 260:	4501                	li	a0,0
 262:	bfdd                	j	258 <atoi+0x40>

0000000000000264 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 264:	1141                	addi	sp,sp,-16
 266:	e406                	sd	ra,8(sp)
 268:	e022                	sd	s0,0(sp)
 26a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 26c:	02b57563          	bgeu	a0,a1,296 <memmove+0x32>
    while(n-- > 0)
 270:	00c05f63          	blez	a2,28e <memmove+0x2a>
 274:	1602                	slli	a2,a2,0x20
 276:	9201                	srli	a2,a2,0x20
 278:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 27c:	872a                	mv	a4,a0
      *dst++ = *src++;
 27e:	0585                	addi	a1,a1,1
 280:	0705                	addi	a4,a4,1
 282:	fff5c683          	lbu	a3,-1(a1)
 286:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 28a:	fee79ae3          	bne	a5,a4,27e <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 28e:	60a2                	ld	ra,8(sp)
 290:	6402                	ld	s0,0(sp)
 292:	0141                	addi	sp,sp,16
 294:	8082                	ret
    dst += n;
 296:	00c50733          	add	a4,a0,a2
    src += n;
 29a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 29c:	fec059e3          	blez	a2,28e <memmove+0x2a>
 2a0:	fff6079b          	addiw	a5,a2,-1
 2a4:	1782                	slli	a5,a5,0x20
 2a6:	9381                	srli	a5,a5,0x20
 2a8:	fff7c793          	not	a5,a5
 2ac:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2ae:	15fd                	addi	a1,a1,-1
 2b0:	177d                	addi	a4,a4,-1
 2b2:	0005c683          	lbu	a3,0(a1)
 2b6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2ba:	fef71ae3          	bne	a4,a5,2ae <memmove+0x4a>
 2be:	bfc1                	j	28e <memmove+0x2a>

00000000000002c0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2c0:	1141                	addi	sp,sp,-16
 2c2:	e406                	sd	ra,8(sp)
 2c4:	e022                	sd	s0,0(sp)
 2c6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2c8:	ca0d                	beqz	a2,2fa <memcmp+0x3a>
 2ca:	fff6069b          	addiw	a3,a2,-1
 2ce:	1682                	slli	a3,a3,0x20
 2d0:	9281                	srli	a3,a3,0x20
 2d2:	0685                	addi	a3,a3,1
 2d4:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2d6:	00054783          	lbu	a5,0(a0)
 2da:	0005c703          	lbu	a4,0(a1)
 2de:	00e79863          	bne	a5,a4,2ee <memcmp+0x2e>
      return *p1 - *p2;
    }
    p1++;
 2e2:	0505                	addi	a0,a0,1
    p2++;
 2e4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2e6:	fed518e3          	bne	a0,a3,2d6 <memcmp+0x16>
  }
  return 0;
 2ea:	4501                	li	a0,0
 2ec:	a019                	j	2f2 <memcmp+0x32>
      return *p1 - *p2;
 2ee:	40e7853b          	subw	a0,a5,a4
}
 2f2:	60a2                	ld	ra,8(sp)
 2f4:	6402                	ld	s0,0(sp)
 2f6:	0141                	addi	sp,sp,16
 2f8:	8082                	ret
  return 0;
 2fa:	4501                	li	a0,0
 2fc:	bfdd                	j	2f2 <memcmp+0x32>

00000000000002fe <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2fe:	1141                	addi	sp,sp,-16
 300:	e406                	sd	ra,8(sp)
 302:	e022                	sd	s0,0(sp)
 304:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 306:	f5fff0ef          	jal	264 <memmove>
}
 30a:	60a2                	ld	ra,8(sp)
 30c:	6402                	ld	s0,0(sp)
 30e:	0141                	addi	sp,sp,16
 310:	8082                	ret

0000000000000312 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 312:	4885                	li	a7,1
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <exit>:
.global exit
exit:
 li a7, SYS_exit
 31a:	4889                	li	a7,2
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <wait>:
.global wait
wait:
 li a7, SYS_wait
 322:	488d                	li	a7,3
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 32a:	4891                	li	a7,4
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <read>:
.global read
read:
 li a7, SYS_read
 332:	4895                	li	a7,5
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <write>:
.global write
write:
 li a7, SYS_write
 33a:	48c1                	li	a7,16
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <close>:
.global close
close:
 li a7, SYS_close
 342:	48d5                	li	a7,21
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <kill>:
.global kill
kill:
 li a7, SYS_kill
 34a:	4899                	li	a7,6
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <exec>:
.global exec
exec:
 li a7, SYS_exec
 352:	489d                	li	a7,7
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <open>:
.global open
open:
 li a7, SYS_open
 35a:	48bd                	li	a7,15
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 362:	48c5                	li	a7,17
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 36a:	48c9                	li	a7,18
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 372:	48a1                	li	a7,8
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <link>:
.global link
link:
 li a7, SYS_link
 37a:	48cd                	li	a7,19
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 382:	48d1                	li	a7,20
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 38a:	48a5                	li	a7,9
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <dup>:
.global dup
dup:
 li a7, SYS_dup
 392:	48a9                	li	a7,10
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 39a:	48ad                	li	a7,11
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3a2:	48b1                	li	a7,12
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3aa:	48b5                	li	a7,13
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3b2:	48b9                	li	a7,14
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <toggle_case>:
.global toggle_case
toggle_case:
 li a7, SYS_toggle_case
 3ba:	48d9                	li	a7,22
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3c2:	1101                	addi	sp,sp,-32
 3c4:	ec06                	sd	ra,24(sp)
 3c6:	e822                	sd	s0,16(sp)
 3c8:	1000                	addi	s0,sp,32
 3ca:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3ce:	4605                	li	a2,1
 3d0:	fef40593          	addi	a1,s0,-17
 3d4:	f67ff0ef          	jal	33a <write>
}
 3d8:	60e2                	ld	ra,24(sp)
 3da:	6442                	ld	s0,16(sp)
 3dc:	6105                	addi	sp,sp,32
 3de:	8082                	ret

00000000000003e0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3e0:	7139                	addi	sp,sp,-64
 3e2:	fc06                	sd	ra,56(sp)
 3e4:	f822                	sd	s0,48(sp)
 3e6:	f426                	sd	s1,40(sp)
 3e8:	f04a                	sd	s2,32(sp)
 3ea:	ec4e                	sd	s3,24(sp)
 3ec:	0080                	addi	s0,sp,64
 3ee:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3f0:	c299                	beqz	a3,3f6 <printint+0x16>
 3f2:	0605ce63          	bltz	a1,46e <printint+0x8e>
  neg = 0;
 3f6:	4e01                	li	t3,0
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 3f8:	fc040313          	addi	t1,s0,-64
  neg = 0;
 3fc:	869a                	mv	a3,t1
  i = 0;
 3fe:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 400:	00000817          	auipc	a6,0x0
 404:	4e880813          	addi	a6,a6,1256 # 8e8 <digits>
 408:	88be                	mv	a7,a5
 40a:	0017851b          	addiw	a0,a5,1
 40e:	87aa                	mv	a5,a0
 410:	02c5f73b          	remuw	a4,a1,a2
 414:	1702                	slli	a4,a4,0x20
 416:	9301                	srli	a4,a4,0x20
 418:	9742                	add	a4,a4,a6
 41a:	00074703          	lbu	a4,0(a4)
 41e:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 422:	872e                	mv	a4,a1
 424:	02c5d5bb          	divuw	a1,a1,a2
 428:	0685                	addi	a3,a3,1
 42a:	fcc77fe3          	bgeu	a4,a2,408 <printint+0x28>
  if(neg)
 42e:	000e0c63          	beqz	t3,446 <printint+0x66>
    buf[i++] = '-';
 432:	fd050793          	addi	a5,a0,-48
 436:	00878533          	add	a0,a5,s0
 43a:	02d00793          	li	a5,45
 43e:	fef50823          	sb	a5,-16(a0)
 442:	0028879b          	addiw	a5,a7,2

  while(--i >= 0)
 446:	fff7899b          	addiw	s3,a5,-1
 44a:	006784b3          	add	s1,a5,t1
    putc(fd, buf[i]);
 44e:	fff4c583          	lbu	a1,-1(s1)
 452:	854a                	mv	a0,s2
 454:	f6fff0ef          	jal	3c2 <putc>
  while(--i >= 0)
 458:	39fd                	addiw	s3,s3,-1
 45a:	14fd                	addi	s1,s1,-1
 45c:	fe09d9e3          	bgez	s3,44e <printint+0x6e>
}
 460:	70e2                	ld	ra,56(sp)
 462:	7442                	ld	s0,48(sp)
 464:	74a2                	ld	s1,40(sp)
 466:	7902                	ld	s2,32(sp)
 468:	69e2                	ld	s3,24(sp)
 46a:	6121                	addi	sp,sp,64
 46c:	8082                	ret
    x = -xx;
 46e:	40b005bb          	negw	a1,a1
    neg = 1;
 472:	4e05                	li	t3,1
    x = -xx;
 474:	b751                	j	3f8 <printint+0x18>

0000000000000476 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 476:	711d                	addi	sp,sp,-96
 478:	ec86                	sd	ra,88(sp)
 47a:	e8a2                	sd	s0,80(sp)
 47c:	e4a6                	sd	s1,72(sp)
 47e:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 480:	0005c483          	lbu	s1,0(a1)
 484:	26048663          	beqz	s1,6f0 <vprintf+0x27a>
 488:	e0ca                	sd	s2,64(sp)
 48a:	fc4e                	sd	s3,56(sp)
 48c:	f852                	sd	s4,48(sp)
 48e:	f456                	sd	s5,40(sp)
 490:	f05a                	sd	s6,32(sp)
 492:	ec5e                	sd	s7,24(sp)
 494:	e862                	sd	s8,16(sp)
 496:	e466                	sd	s9,8(sp)
 498:	8b2a                	mv	s6,a0
 49a:	8a2e                	mv	s4,a1
 49c:	8bb2                	mv	s7,a2
  state = 0;
 49e:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4a0:	4901                	li	s2,0
 4a2:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4a4:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4a8:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4ac:	06c00c93          	li	s9,108
 4b0:	a00d                	j	4d2 <vprintf+0x5c>
        putc(fd, c0);
 4b2:	85a6                	mv	a1,s1
 4b4:	855a                	mv	a0,s6
 4b6:	f0dff0ef          	jal	3c2 <putc>
 4ba:	a019                	j	4c0 <vprintf+0x4a>
    } else if(state == '%'){
 4bc:	03598363          	beq	s3,s5,4e2 <vprintf+0x6c>
  for(i = 0; fmt[i]; i++){
 4c0:	0019079b          	addiw	a5,s2,1
 4c4:	893e                	mv	s2,a5
 4c6:	873e                	mv	a4,a5
 4c8:	97d2                	add	a5,a5,s4
 4ca:	0007c483          	lbu	s1,0(a5)
 4ce:	20048963          	beqz	s1,6e0 <vprintf+0x26a>
    c0 = fmt[i] & 0xff;
 4d2:	0004879b          	sext.w	a5,s1
    if(state == 0){
 4d6:	fe0993e3          	bnez	s3,4bc <vprintf+0x46>
      if(c0 == '%'){
 4da:	fd579ce3          	bne	a5,s5,4b2 <vprintf+0x3c>
        state = '%';
 4de:	89be                	mv	s3,a5
 4e0:	b7c5                	j	4c0 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 4e2:	00ea06b3          	add	a3,s4,a4
 4e6:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 4ea:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 4ec:	c681                	beqz	a3,4f4 <vprintf+0x7e>
 4ee:	9752                	add	a4,a4,s4
 4f0:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 4f4:	03878e63          	beq	a5,s8,530 <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 4f8:	05978863          	beq	a5,s9,548 <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 4fc:	07500713          	li	a4,117
 500:	0ee78263          	beq	a5,a4,5e4 <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 504:	07800713          	li	a4,120
 508:	12e78463          	beq	a5,a4,630 <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 50c:	07000713          	li	a4,112
 510:	14e78963          	beq	a5,a4,662 <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 514:	07300713          	li	a4,115
 518:	18e78863          	beq	a5,a4,6a8 <vprintf+0x232>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 51c:	02500713          	li	a4,37
 520:	04e79463          	bne	a5,a4,568 <vprintf+0xf2>
        putc(fd, '%');
 524:	85ba                	mv	a1,a4
 526:	855a                	mv	a0,s6
 528:	e9bff0ef          	jal	3c2 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 52c:	4981                	li	s3,0
 52e:	bf49                	j	4c0 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 530:	008b8493          	addi	s1,s7,8
 534:	4685                	li	a3,1
 536:	4629                	li	a2,10
 538:	000ba583          	lw	a1,0(s7)
 53c:	855a                	mv	a0,s6
 53e:	ea3ff0ef          	jal	3e0 <printint>
 542:	8ba6                	mv	s7,s1
      state = 0;
 544:	4981                	li	s3,0
 546:	bfad                	j	4c0 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 548:	06400793          	li	a5,100
 54c:	02f68963          	beq	a3,a5,57e <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 550:	06c00793          	li	a5,108
 554:	04f68263          	beq	a3,a5,598 <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 558:	07500793          	li	a5,117
 55c:	0af68063          	beq	a3,a5,5fc <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 560:	07800793          	li	a5,120
 564:	0ef68263          	beq	a3,a5,648 <vprintf+0x1d2>
        putc(fd, '%');
 568:	02500593          	li	a1,37
 56c:	855a                	mv	a0,s6
 56e:	e55ff0ef          	jal	3c2 <putc>
        putc(fd, c0);
 572:	85a6                	mv	a1,s1
 574:	855a                	mv	a0,s6
 576:	e4dff0ef          	jal	3c2 <putc>
      state = 0;
 57a:	4981                	li	s3,0
 57c:	b791                	j	4c0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 57e:	008b8493          	addi	s1,s7,8
 582:	4685                	li	a3,1
 584:	4629                	li	a2,10
 586:	000ba583          	lw	a1,0(s7)
 58a:	855a                	mv	a0,s6
 58c:	e55ff0ef          	jal	3e0 <printint>
        i += 1;
 590:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 592:	8ba6                	mv	s7,s1
      state = 0;
 594:	4981                	li	s3,0
        i += 1;
 596:	b72d                	j	4c0 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 598:	06400793          	li	a5,100
 59c:	02f60763          	beq	a2,a5,5ca <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5a0:	07500793          	li	a5,117
 5a4:	06f60963          	beq	a2,a5,616 <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5a8:	07800793          	li	a5,120
 5ac:	faf61ee3          	bne	a2,a5,568 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5b0:	008b8493          	addi	s1,s7,8
 5b4:	4681                	li	a3,0
 5b6:	4641                	li	a2,16
 5b8:	000ba583          	lw	a1,0(s7)
 5bc:	855a                	mv	a0,s6
 5be:	e23ff0ef          	jal	3e0 <printint>
        i += 2;
 5c2:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5c4:	8ba6                	mv	s7,s1
      state = 0;
 5c6:	4981                	li	s3,0
        i += 2;
 5c8:	bde5                	j	4c0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ca:	008b8493          	addi	s1,s7,8
 5ce:	4685                	li	a3,1
 5d0:	4629                	li	a2,10
 5d2:	000ba583          	lw	a1,0(s7)
 5d6:	855a                	mv	a0,s6
 5d8:	e09ff0ef          	jal	3e0 <printint>
        i += 2;
 5dc:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5de:	8ba6                	mv	s7,s1
      state = 0;
 5e0:	4981                	li	s3,0
        i += 2;
 5e2:	bdf9                	j	4c0 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 5e4:	008b8493          	addi	s1,s7,8
 5e8:	4681                	li	a3,0
 5ea:	4629                	li	a2,10
 5ec:	000ba583          	lw	a1,0(s7)
 5f0:	855a                	mv	a0,s6
 5f2:	defff0ef          	jal	3e0 <printint>
 5f6:	8ba6                	mv	s7,s1
      state = 0;
 5f8:	4981                	li	s3,0
 5fa:	b5d9                	j	4c0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5fc:	008b8493          	addi	s1,s7,8
 600:	4681                	li	a3,0
 602:	4629                	li	a2,10
 604:	000ba583          	lw	a1,0(s7)
 608:	855a                	mv	a0,s6
 60a:	dd7ff0ef          	jal	3e0 <printint>
        i += 1;
 60e:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 610:	8ba6                	mv	s7,s1
      state = 0;
 612:	4981                	li	s3,0
        i += 1;
 614:	b575                	j	4c0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 616:	008b8493          	addi	s1,s7,8
 61a:	4681                	li	a3,0
 61c:	4629                	li	a2,10
 61e:	000ba583          	lw	a1,0(s7)
 622:	855a                	mv	a0,s6
 624:	dbdff0ef          	jal	3e0 <printint>
        i += 2;
 628:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 62a:	8ba6                	mv	s7,s1
      state = 0;
 62c:	4981                	li	s3,0
        i += 2;
 62e:	bd49                	j	4c0 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 630:	008b8493          	addi	s1,s7,8
 634:	4681                	li	a3,0
 636:	4641                	li	a2,16
 638:	000ba583          	lw	a1,0(s7)
 63c:	855a                	mv	a0,s6
 63e:	da3ff0ef          	jal	3e0 <printint>
 642:	8ba6                	mv	s7,s1
      state = 0;
 644:	4981                	li	s3,0
 646:	bdad                	j	4c0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 648:	008b8493          	addi	s1,s7,8
 64c:	4681                	li	a3,0
 64e:	4641                	li	a2,16
 650:	000ba583          	lw	a1,0(s7)
 654:	855a                	mv	a0,s6
 656:	d8bff0ef          	jal	3e0 <printint>
        i += 1;
 65a:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 65c:	8ba6                	mv	s7,s1
      state = 0;
 65e:	4981                	li	s3,0
        i += 1;
 660:	b585                	j	4c0 <vprintf+0x4a>
 662:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 664:	008b8d13          	addi	s10,s7,8
 668:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 66c:	03000593          	li	a1,48
 670:	855a                	mv	a0,s6
 672:	d51ff0ef          	jal	3c2 <putc>
  putc(fd, 'x');
 676:	07800593          	li	a1,120
 67a:	855a                	mv	a0,s6
 67c:	d47ff0ef          	jal	3c2 <putc>
 680:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 682:	00000b97          	auipc	s7,0x0
 686:	266b8b93          	addi	s7,s7,614 # 8e8 <digits>
 68a:	03c9d793          	srli	a5,s3,0x3c
 68e:	97de                	add	a5,a5,s7
 690:	0007c583          	lbu	a1,0(a5)
 694:	855a                	mv	a0,s6
 696:	d2dff0ef          	jal	3c2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 69a:	0992                	slli	s3,s3,0x4
 69c:	34fd                	addiw	s1,s1,-1
 69e:	f4f5                	bnez	s1,68a <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 6a0:	8bea                	mv	s7,s10
      state = 0;
 6a2:	4981                	li	s3,0
 6a4:	6d02                	ld	s10,0(sp)
 6a6:	bd29                	j	4c0 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 6a8:	008b8993          	addi	s3,s7,8
 6ac:	000bb483          	ld	s1,0(s7)
 6b0:	cc91                	beqz	s1,6cc <vprintf+0x256>
        for(; *s; s++)
 6b2:	0004c583          	lbu	a1,0(s1)
 6b6:	c195                	beqz	a1,6da <vprintf+0x264>
          putc(fd, *s);
 6b8:	855a                	mv	a0,s6
 6ba:	d09ff0ef          	jal	3c2 <putc>
        for(; *s; s++)
 6be:	0485                	addi	s1,s1,1
 6c0:	0004c583          	lbu	a1,0(s1)
 6c4:	f9f5                	bnez	a1,6b8 <vprintf+0x242>
        if((s = va_arg(ap, char*)) == 0)
 6c6:	8bce                	mv	s7,s3
      state = 0;
 6c8:	4981                	li	s3,0
 6ca:	bbdd                	j	4c0 <vprintf+0x4a>
          s = "(null)";
 6cc:	00000497          	auipc	s1,0x0
 6d0:	21448493          	addi	s1,s1,532 # 8e0 <malloc+0x104>
        for(; *s; s++)
 6d4:	02800593          	li	a1,40
 6d8:	b7c5                	j	6b8 <vprintf+0x242>
        if((s = va_arg(ap, char*)) == 0)
 6da:	8bce                	mv	s7,s3
      state = 0;
 6dc:	4981                	li	s3,0
 6de:	b3cd                	j	4c0 <vprintf+0x4a>
 6e0:	6906                	ld	s2,64(sp)
 6e2:	79e2                	ld	s3,56(sp)
 6e4:	7a42                	ld	s4,48(sp)
 6e6:	7aa2                	ld	s5,40(sp)
 6e8:	7b02                	ld	s6,32(sp)
 6ea:	6be2                	ld	s7,24(sp)
 6ec:	6c42                	ld	s8,16(sp)
 6ee:	6ca2                	ld	s9,8(sp)
    }
  }
}
 6f0:	60e6                	ld	ra,88(sp)
 6f2:	6446                	ld	s0,80(sp)
 6f4:	64a6                	ld	s1,72(sp)
 6f6:	6125                	addi	sp,sp,96
 6f8:	8082                	ret

00000000000006fa <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6fa:	715d                	addi	sp,sp,-80
 6fc:	ec06                	sd	ra,24(sp)
 6fe:	e822                	sd	s0,16(sp)
 700:	1000                	addi	s0,sp,32
 702:	e010                	sd	a2,0(s0)
 704:	e414                	sd	a3,8(s0)
 706:	e818                	sd	a4,16(s0)
 708:	ec1c                	sd	a5,24(s0)
 70a:	03043023          	sd	a6,32(s0)
 70e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 712:	8622                	mv	a2,s0
 714:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 718:	d5fff0ef          	jal	476 <vprintf>
}
 71c:	60e2                	ld	ra,24(sp)
 71e:	6442                	ld	s0,16(sp)
 720:	6161                	addi	sp,sp,80
 722:	8082                	ret

0000000000000724 <printf>:

void
printf(const char *fmt, ...)
{
 724:	711d                	addi	sp,sp,-96
 726:	ec06                	sd	ra,24(sp)
 728:	e822                	sd	s0,16(sp)
 72a:	1000                	addi	s0,sp,32
 72c:	e40c                	sd	a1,8(s0)
 72e:	e810                	sd	a2,16(s0)
 730:	ec14                	sd	a3,24(s0)
 732:	f018                	sd	a4,32(s0)
 734:	f41c                	sd	a5,40(s0)
 736:	03043823          	sd	a6,48(s0)
 73a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 73e:	00840613          	addi	a2,s0,8
 742:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 746:	85aa                	mv	a1,a0
 748:	4505                	li	a0,1
 74a:	d2dff0ef          	jal	476 <vprintf>
}
 74e:	60e2                	ld	ra,24(sp)
 750:	6442                	ld	s0,16(sp)
 752:	6125                	addi	sp,sp,96
 754:	8082                	ret

0000000000000756 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 756:	1141                	addi	sp,sp,-16
 758:	e406                	sd	ra,8(sp)
 75a:	e022                	sd	s0,0(sp)
 75c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 75e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 762:	00001797          	auipc	a5,0x1
 766:	89e7b783          	ld	a5,-1890(a5) # 1000 <freep>
 76a:	a02d                	j	794 <free+0x3e>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 76c:	4618                	lw	a4,8(a2)
 76e:	9f2d                	addw	a4,a4,a1
 770:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 774:	6398                	ld	a4,0(a5)
 776:	6310                	ld	a2,0(a4)
 778:	a83d                	j	7b6 <free+0x60>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 77a:	ff852703          	lw	a4,-8(a0)
 77e:	9f31                	addw	a4,a4,a2
 780:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 782:	ff053683          	ld	a3,-16(a0)
 786:	a091                	j	7ca <free+0x74>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 788:	6398                	ld	a4,0(a5)
 78a:	00e7e463          	bltu	a5,a4,792 <free+0x3c>
 78e:	00e6ea63          	bltu	a3,a4,7a2 <free+0x4c>
{
 792:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 794:	fed7fae3          	bgeu	a5,a3,788 <free+0x32>
 798:	6398                	ld	a4,0(a5)
 79a:	00e6e463          	bltu	a3,a4,7a2 <free+0x4c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 79e:	fee7eae3          	bltu	a5,a4,792 <free+0x3c>
  if(bp + bp->s.size == p->s.ptr){
 7a2:	ff852583          	lw	a1,-8(a0)
 7a6:	6390                	ld	a2,0(a5)
 7a8:	02059813          	slli	a6,a1,0x20
 7ac:	01c85713          	srli	a4,a6,0x1c
 7b0:	9736                	add	a4,a4,a3
 7b2:	fae60de3          	beq	a2,a4,76c <free+0x16>
    bp->s.ptr = p->s.ptr->s.ptr;
 7b6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7ba:	4790                	lw	a2,8(a5)
 7bc:	02061593          	slli	a1,a2,0x20
 7c0:	01c5d713          	srli	a4,a1,0x1c
 7c4:	973e                	add	a4,a4,a5
 7c6:	fae68ae3          	beq	a3,a4,77a <free+0x24>
    p->s.ptr = bp->s.ptr;
 7ca:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7cc:	00001717          	auipc	a4,0x1
 7d0:	82f73a23          	sd	a5,-1996(a4) # 1000 <freep>
}
 7d4:	60a2                	ld	ra,8(sp)
 7d6:	6402                	ld	s0,0(sp)
 7d8:	0141                	addi	sp,sp,16
 7da:	8082                	ret

00000000000007dc <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7dc:	7139                	addi	sp,sp,-64
 7de:	fc06                	sd	ra,56(sp)
 7e0:	f822                	sd	s0,48(sp)
 7e2:	f04a                	sd	s2,32(sp)
 7e4:	ec4e                	sd	s3,24(sp)
 7e6:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7e8:	02051993          	slli	s3,a0,0x20
 7ec:	0209d993          	srli	s3,s3,0x20
 7f0:	09bd                	addi	s3,s3,15
 7f2:	0049d993          	srli	s3,s3,0x4
 7f6:	2985                	addiw	s3,s3,1
 7f8:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 7fa:	00001517          	auipc	a0,0x1
 7fe:	80653503          	ld	a0,-2042(a0) # 1000 <freep>
 802:	c905                	beqz	a0,832 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 804:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 806:	4798                	lw	a4,8(a5)
 808:	09377663          	bgeu	a4,s3,894 <malloc+0xb8>
 80c:	f426                	sd	s1,40(sp)
 80e:	e852                	sd	s4,16(sp)
 810:	e456                	sd	s5,8(sp)
 812:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 814:	8a4e                	mv	s4,s3
 816:	6705                	lui	a4,0x1
 818:	00e9f363          	bgeu	s3,a4,81e <malloc+0x42>
 81c:	6a05                	lui	s4,0x1
 81e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 822:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 826:	00000497          	auipc	s1,0x0
 82a:	7da48493          	addi	s1,s1,2010 # 1000 <freep>
  if(p == (char*)-1)
 82e:	5afd                	li	s5,-1
 830:	a83d                	j	86e <malloc+0x92>
 832:	f426                	sd	s1,40(sp)
 834:	e852                	sd	s4,16(sp)
 836:	e456                	sd	s5,8(sp)
 838:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 83a:	00000797          	auipc	a5,0x0
 83e:	7d678793          	addi	a5,a5,2006 # 1010 <base>
 842:	00000717          	auipc	a4,0x0
 846:	7af73f23          	sd	a5,1982(a4) # 1000 <freep>
 84a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 84c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 850:	b7d1                	j	814 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 852:	6398                	ld	a4,0(a5)
 854:	e118                	sd	a4,0(a0)
 856:	a899                	j	8ac <malloc+0xd0>
  hp->s.size = nu;
 858:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 85c:	0541                	addi	a0,a0,16
 85e:	ef9ff0ef          	jal	756 <free>
  return freep;
 862:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 864:	c125                	beqz	a0,8c4 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 866:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 868:	4798                	lw	a4,8(a5)
 86a:	03277163          	bgeu	a4,s2,88c <malloc+0xb0>
    if(p == freep)
 86e:	6098                	ld	a4,0(s1)
 870:	853e                	mv	a0,a5
 872:	fef71ae3          	bne	a4,a5,866 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 876:	8552                	mv	a0,s4
 878:	b2bff0ef          	jal	3a2 <sbrk>
  if(p == (char*)-1)
 87c:	fd551ee3          	bne	a0,s5,858 <malloc+0x7c>
        return 0;
 880:	4501                	li	a0,0
 882:	74a2                	ld	s1,40(sp)
 884:	6a42                	ld	s4,16(sp)
 886:	6aa2                	ld	s5,8(sp)
 888:	6b02                	ld	s6,0(sp)
 88a:	a03d                	j	8b8 <malloc+0xdc>
 88c:	74a2                	ld	s1,40(sp)
 88e:	6a42                	ld	s4,16(sp)
 890:	6aa2                	ld	s5,8(sp)
 892:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 894:	fae90fe3          	beq	s2,a4,852 <malloc+0x76>
        p->s.size -= nunits;
 898:	4137073b          	subw	a4,a4,s3
 89c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 89e:	02071693          	slli	a3,a4,0x20
 8a2:	01c6d713          	srli	a4,a3,0x1c
 8a6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8a8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8ac:	00000717          	auipc	a4,0x0
 8b0:	74a73a23          	sd	a0,1876(a4) # 1000 <freep>
      return (void*)(p + 1);
 8b4:	01078513          	addi	a0,a5,16
  }
}
 8b8:	70e2                	ld	ra,56(sp)
 8ba:	7442                	ld	s0,48(sp)
 8bc:	7902                	ld	s2,32(sp)
 8be:	69e2                	ld	s3,24(sp)
 8c0:	6121                	addi	sp,sp,64
 8c2:	8082                	ret
 8c4:	74a2                	ld	s1,40(sp)
 8c6:	6a42                	ld	s4,16(sp)
 8c8:	6aa2                	ld	s5,8(sp)
 8ca:	6b02                	ld	s6,0(sp)
 8cc:	b7f5                	j	8b8 <malloc+0xdc>
