
user/_toggle_case:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <strcat_custom>:
#include "kernel/types.h"
#include "user.h"

void
strcat_custom(char *dest, const char *src)
{
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
    // Find the end of the destination string
    while (*dest != '\0') {
   6:	00054783          	lbu	a5,0(a0)
   a:	c789                	beqz	a5,14 <strcat_custom+0x14>
        dest++;
   c:	0505                	addi	a0,a0,1
    while (*dest != '\0') {
   e:	00054783          	lbu	a5,0(a0)
  12:	ffed                	bnez	a5,c <strcat_custom+0xc>
    }

    // Copy the source string to the destination
    while (*src != '\0') {
  14:	0005c783          	lbu	a5,0(a1)
  18:	cb81                	beqz	a5,28 <strcat_custom+0x28>
        *dest = *src;
  1a:	00f50023          	sb	a5,0(a0)
        dest++;
  1e:	0505                	addi	a0,a0,1
        src++;
  20:	0585                	addi	a1,a1,1
    while (*src != '\0') {
  22:	0005c783          	lbu	a5,0(a1)
  26:	fbf5                	bnez	a5,1a <strcat_custom+0x1a>
    }

    // Null-terminate the result
    *dest = '\0';
  28:	00050023          	sb	zero,0(a0)
}
  2c:	6422                	ld	s0,8(sp)
  2e:	0141                	addi	sp,sp,16
  30:	8082                	ret

0000000000000032 <main>:

int
main(int argc, char *argv[])
{
  32:	7171                	addi	sp,sp,-176
  34:	f506                	sd	ra,168(sp)
  36:	f122                	sd	s0,160(sp)
  38:	1900                	addi	s0,sp,176
    if (argc < 2) {
  3a:	4785                	li	a5,1
  3c:	04a7dc63          	bge	a5,a0,94 <main+0x62>
  40:	ed26                	sd	s1,152(sp)
  42:	e94a                	sd	s2,144(sp)
  44:	e54e                	sd	s3,136(sp)
  46:	e152                	sd	s4,128(sp)
  48:	fcd6                	sd	s5,120(sp)
  4a:	89aa                	mv	s3,a0
        printf("Usage: toggle_case <string>\n");
        exit(0);
    }

    char str[100] = {0};  // Buffer to hold the concatenated string
  4c:	f4043c23          	sd	zero,-168(s0)
  50:	f6043023          	sd	zero,-160(s0)
  54:	f6043423          	sd	zero,-152(s0)
  58:	f6043823          	sd	zero,-144(s0)
  5c:	f6043c23          	sd	zero,-136(s0)
  60:	f8043023          	sd	zero,-128(s0)
  64:	f8043423          	sd	zero,-120(s0)
  68:	f8043823          	sd	zero,-112(s0)
  6c:	f8043c23          	sd	zero,-104(s0)
  70:	fa043023          	sd	zero,-96(s0)
  74:	fa043423          	sd	zero,-88(s0)
  78:	fa043823          	sd	zero,-80(s0)
  7c:	fa042c23          	sw	zero,-72(s0)

    // Concatenate all arguments into one string with spaces
    for (int i = 1; i < argc; i++) {
  80:	00858913          	addi	s2,a1,8
  84:	4485                	li	s1,1
        strcat_custom(str, argv[i]);
        if (i < argc - 1) {
  86:	fff50a1b          	addiw	s4,a0,-1
            strcat_custom(str, " ");
  8a:	00001a97          	auipc	s5,0x1
  8e:	8d6a8a93          	addi	s5,s5,-1834 # 960 <malloc+0x118>
  92:	a01d                	j	b8 <main+0x86>
  94:	ed26                	sd	s1,152(sp)
  96:	e94a                	sd	s2,144(sp)
  98:	e54e                	sd	s3,136(sp)
  9a:	e152                	sd	s4,128(sp)
  9c:	fcd6                	sd	s5,120(sp)
        printf("Usage: toggle_case <string>\n");
  9e:	00001517          	auipc	a0,0x1
  a2:	8a250513          	addi	a0,a0,-1886 # 940 <malloc+0xf8>
  a6:	6ee000ef          	jal	794 <printf>
        exit(0);
  aa:	4501                	li	a0,0
  ac:	2c0000ef          	jal	36c <exit>
    for (int i = 1; i < argc; i++) {
  b0:	2485                	addiw	s1,s1,1
  b2:	0921                	addi	s2,s2,8
  b4:	02998063          	beq	s3,s1,d4 <main+0xa2>
        strcat_custom(str, argv[i]);
  b8:	00093583          	ld	a1,0(s2)
  bc:	f5840513          	addi	a0,s0,-168
  c0:	f41ff0ef          	jal	0 <strcat_custom>
        if (i < argc - 1) {
  c4:	ff44d6e3          	bge	s1,s4,b0 <main+0x7e>
            strcat_custom(str, " ");
  c8:	85d6                	mv	a1,s5
  ca:	f5840513          	addi	a0,s0,-168
  ce:	f33ff0ef          	jal	0 <strcat_custom>
  d2:	bff9                	j	b0 <main+0x7e>
        }
    }

    printf("Original String: %s\n", str);
  d4:	f5840593          	addi	a1,s0,-168
  d8:	00001517          	auipc	a0,0x1
  dc:	89050513          	addi	a0,a0,-1904 # 968 <malloc+0x120>
  e0:	6b4000ef          	jal	794 <printf>

    // Call the toggle_case system call
    toggle_case(str);
  e4:	f5840513          	addi	a0,s0,-168
  e8:	32c000ef          	jal	414 <toggle_case>

    printf("Modified String: %s\n", str);
  ec:	f5840593          	addi	a1,s0,-168
  f0:	00001517          	auipc	a0,0x1
  f4:	89050513          	addi	a0,a0,-1904 # 980 <malloc+0x138>
  f8:	69c000ef          	jal	794 <printf>
    exit(0);
  fc:	4501                	li	a0,0
  fe:	26e000ef          	jal	36c <exit>

0000000000000102 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
 102:	1141                	addi	sp,sp,-16
 104:	e406                	sd	ra,8(sp)
 106:	e022                	sd	s0,0(sp)
 108:	0800                	addi	s0,sp,16
  extern int main();
  main();
 10a:	f29ff0ef          	jal	32 <main>
  exit(0);
 10e:	4501                	li	a0,0
 110:	25c000ef          	jal	36c <exit>

0000000000000114 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 114:	1141                	addi	sp,sp,-16
 116:	e422                	sd	s0,8(sp)
 118:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 11a:	87aa                	mv	a5,a0
 11c:	0585                	addi	a1,a1,1
 11e:	0785                	addi	a5,a5,1
 120:	fff5c703          	lbu	a4,-1(a1)
 124:	fee78fa3          	sb	a4,-1(a5)
 128:	fb75                	bnez	a4,11c <strcpy+0x8>
    ;
  return os;
}
 12a:	6422                	ld	s0,8(sp)
 12c:	0141                	addi	sp,sp,16
 12e:	8082                	ret

0000000000000130 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 130:	1141                	addi	sp,sp,-16
 132:	e422                	sd	s0,8(sp)
 134:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 136:	00054783          	lbu	a5,0(a0)
 13a:	cb91                	beqz	a5,14e <strcmp+0x1e>
 13c:	0005c703          	lbu	a4,0(a1)
 140:	00f71763          	bne	a4,a5,14e <strcmp+0x1e>
    p++, q++;
 144:	0505                	addi	a0,a0,1
 146:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 148:	00054783          	lbu	a5,0(a0)
 14c:	fbe5                	bnez	a5,13c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 14e:	0005c503          	lbu	a0,0(a1)
}
 152:	40a7853b          	subw	a0,a5,a0
 156:	6422                	ld	s0,8(sp)
 158:	0141                	addi	sp,sp,16
 15a:	8082                	ret

000000000000015c <strlen>:

uint
strlen(const char *s)
{
 15c:	1141                	addi	sp,sp,-16
 15e:	e422                	sd	s0,8(sp)
 160:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 162:	00054783          	lbu	a5,0(a0)
 166:	cf91                	beqz	a5,182 <strlen+0x26>
 168:	0505                	addi	a0,a0,1
 16a:	87aa                	mv	a5,a0
 16c:	86be                	mv	a3,a5
 16e:	0785                	addi	a5,a5,1
 170:	fff7c703          	lbu	a4,-1(a5)
 174:	ff65                	bnez	a4,16c <strlen+0x10>
 176:	40a6853b          	subw	a0,a3,a0
 17a:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 17c:	6422                	ld	s0,8(sp)
 17e:	0141                	addi	sp,sp,16
 180:	8082                	ret
  for(n = 0; s[n]; n++)
 182:	4501                	li	a0,0
 184:	bfe5                	j	17c <strlen+0x20>

0000000000000186 <memset>:

void*
memset(void *dst, int c, uint n)
{
 186:	1141                	addi	sp,sp,-16
 188:	e422                	sd	s0,8(sp)
 18a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 18c:	ca19                	beqz	a2,1a2 <memset+0x1c>
 18e:	87aa                	mv	a5,a0
 190:	1602                	slli	a2,a2,0x20
 192:	9201                	srli	a2,a2,0x20
 194:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 198:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 19c:	0785                	addi	a5,a5,1
 19e:	fee79de3          	bne	a5,a4,198 <memset+0x12>
  }
  return dst;
}
 1a2:	6422                	ld	s0,8(sp)
 1a4:	0141                	addi	sp,sp,16
 1a6:	8082                	ret

00000000000001a8 <strchr>:

char*
strchr(const char *s, char c)
{
 1a8:	1141                	addi	sp,sp,-16
 1aa:	e422                	sd	s0,8(sp)
 1ac:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1ae:	00054783          	lbu	a5,0(a0)
 1b2:	cb99                	beqz	a5,1c8 <strchr+0x20>
    if(*s == c)
 1b4:	00f58763          	beq	a1,a5,1c2 <strchr+0x1a>
  for(; *s; s++)
 1b8:	0505                	addi	a0,a0,1
 1ba:	00054783          	lbu	a5,0(a0)
 1be:	fbfd                	bnez	a5,1b4 <strchr+0xc>
      return (char*)s;
  return 0;
 1c0:	4501                	li	a0,0
}
 1c2:	6422                	ld	s0,8(sp)
 1c4:	0141                	addi	sp,sp,16
 1c6:	8082                	ret
  return 0;
 1c8:	4501                	li	a0,0
 1ca:	bfe5                	j	1c2 <strchr+0x1a>

00000000000001cc <gets>:

char*
gets(char *buf, int max)
{
 1cc:	711d                	addi	sp,sp,-96
 1ce:	ec86                	sd	ra,88(sp)
 1d0:	e8a2                	sd	s0,80(sp)
 1d2:	e4a6                	sd	s1,72(sp)
 1d4:	e0ca                	sd	s2,64(sp)
 1d6:	fc4e                	sd	s3,56(sp)
 1d8:	f852                	sd	s4,48(sp)
 1da:	f456                	sd	s5,40(sp)
 1dc:	f05a                	sd	s6,32(sp)
 1de:	ec5e                	sd	s7,24(sp)
 1e0:	1080                	addi	s0,sp,96
 1e2:	8baa                	mv	s7,a0
 1e4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1e6:	892a                	mv	s2,a0
 1e8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1ea:	4aa9                	li	s5,10
 1ec:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1ee:	89a6                	mv	s3,s1
 1f0:	2485                	addiw	s1,s1,1
 1f2:	0344d663          	bge	s1,s4,21e <gets+0x52>
    cc = read(0, &c, 1);
 1f6:	4605                	li	a2,1
 1f8:	faf40593          	addi	a1,s0,-81
 1fc:	4501                	li	a0,0
 1fe:	186000ef          	jal	384 <read>
    if(cc < 1)
 202:	00a05e63          	blez	a0,21e <gets+0x52>
    buf[i++] = c;
 206:	faf44783          	lbu	a5,-81(s0)
 20a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 20e:	01578763          	beq	a5,s5,21c <gets+0x50>
 212:	0905                	addi	s2,s2,1
 214:	fd679de3          	bne	a5,s6,1ee <gets+0x22>
    buf[i++] = c;
 218:	89a6                	mv	s3,s1
 21a:	a011                	j	21e <gets+0x52>
 21c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 21e:	99de                	add	s3,s3,s7
 220:	00098023          	sb	zero,0(s3)
  return buf;
}
 224:	855e                	mv	a0,s7
 226:	60e6                	ld	ra,88(sp)
 228:	6446                	ld	s0,80(sp)
 22a:	64a6                	ld	s1,72(sp)
 22c:	6906                	ld	s2,64(sp)
 22e:	79e2                	ld	s3,56(sp)
 230:	7a42                	ld	s4,48(sp)
 232:	7aa2                	ld	s5,40(sp)
 234:	7b02                	ld	s6,32(sp)
 236:	6be2                	ld	s7,24(sp)
 238:	6125                	addi	sp,sp,96
 23a:	8082                	ret

000000000000023c <stat>:

int
stat(const char *n, struct stat *st)
{
 23c:	1101                	addi	sp,sp,-32
 23e:	ec06                	sd	ra,24(sp)
 240:	e822                	sd	s0,16(sp)
 242:	e04a                	sd	s2,0(sp)
 244:	1000                	addi	s0,sp,32
 246:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 248:	4581                	li	a1,0
 24a:	162000ef          	jal	3ac <open>
  if(fd < 0)
 24e:	02054263          	bltz	a0,272 <stat+0x36>
 252:	e426                	sd	s1,8(sp)
 254:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 256:	85ca                	mv	a1,s2
 258:	16c000ef          	jal	3c4 <fstat>
 25c:	892a                	mv	s2,a0
  close(fd);
 25e:	8526                	mv	a0,s1
 260:	134000ef          	jal	394 <close>
  return r;
 264:	64a2                	ld	s1,8(sp)
}
 266:	854a                	mv	a0,s2
 268:	60e2                	ld	ra,24(sp)
 26a:	6442                	ld	s0,16(sp)
 26c:	6902                	ld	s2,0(sp)
 26e:	6105                	addi	sp,sp,32
 270:	8082                	ret
    return -1;
 272:	597d                	li	s2,-1
 274:	bfcd                	j	266 <stat+0x2a>

0000000000000276 <atoi>:

int
atoi(const char *s)
{
 276:	1141                	addi	sp,sp,-16
 278:	e422                	sd	s0,8(sp)
 27a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 27c:	00054683          	lbu	a3,0(a0)
 280:	fd06879b          	addiw	a5,a3,-48
 284:	0ff7f793          	zext.b	a5,a5
 288:	4625                	li	a2,9
 28a:	02f66863          	bltu	a2,a5,2ba <atoi+0x44>
 28e:	872a                	mv	a4,a0
  n = 0;
 290:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 292:	0705                	addi	a4,a4,1
 294:	0025179b          	slliw	a5,a0,0x2
 298:	9fa9                	addw	a5,a5,a0
 29a:	0017979b          	slliw	a5,a5,0x1
 29e:	9fb5                	addw	a5,a5,a3
 2a0:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2a4:	00074683          	lbu	a3,0(a4)
 2a8:	fd06879b          	addiw	a5,a3,-48
 2ac:	0ff7f793          	zext.b	a5,a5
 2b0:	fef671e3          	bgeu	a2,a5,292 <atoi+0x1c>
  return n;
}
 2b4:	6422                	ld	s0,8(sp)
 2b6:	0141                	addi	sp,sp,16
 2b8:	8082                	ret
  n = 0;
 2ba:	4501                	li	a0,0
 2bc:	bfe5                	j	2b4 <atoi+0x3e>

00000000000002be <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2be:	1141                	addi	sp,sp,-16
 2c0:	e422                	sd	s0,8(sp)
 2c2:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2c4:	02b57463          	bgeu	a0,a1,2ec <memmove+0x2e>
    while(n-- > 0)
 2c8:	00c05f63          	blez	a2,2e6 <memmove+0x28>
 2cc:	1602                	slli	a2,a2,0x20
 2ce:	9201                	srli	a2,a2,0x20
 2d0:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2d4:	872a                	mv	a4,a0
      *dst++ = *src++;
 2d6:	0585                	addi	a1,a1,1
 2d8:	0705                	addi	a4,a4,1
 2da:	fff5c683          	lbu	a3,-1(a1)
 2de:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2e2:	fef71ae3          	bne	a4,a5,2d6 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2e6:	6422                	ld	s0,8(sp)
 2e8:	0141                	addi	sp,sp,16
 2ea:	8082                	ret
    dst += n;
 2ec:	00c50733          	add	a4,a0,a2
    src += n;
 2f0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2f2:	fec05ae3          	blez	a2,2e6 <memmove+0x28>
 2f6:	fff6079b          	addiw	a5,a2,-1
 2fa:	1782                	slli	a5,a5,0x20
 2fc:	9381                	srli	a5,a5,0x20
 2fe:	fff7c793          	not	a5,a5
 302:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 304:	15fd                	addi	a1,a1,-1
 306:	177d                	addi	a4,a4,-1
 308:	0005c683          	lbu	a3,0(a1)
 30c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 310:	fee79ae3          	bne	a5,a4,304 <memmove+0x46>
 314:	bfc9                	j	2e6 <memmove+0x28>

0000000000000316 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 316:	1141                	addi	sp,sp,-16
 318:	e422                	sd	s0,8(sp)
 31a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 31c:	ca05                	beqz	a2,34c <memcmp+0x36>
 31e:	fff6069b          	addiw	a3,a2,-1
 322:	1682                	slli	a3,a3,0x20
 324:	9281                	srli	a3,a3,0x20
 326:	0685                	addi	a3,a3,1
 328:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 32a:	00054783          	lbu	a5,0(a0)
 32e:	0005c703          	lbu	a4,0(a1)
 332:	00e79863          	bne	a5,a4,342 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 336:	0505                	addi	a0,a0,1
    p2++;
 338:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 33a:	fed518e3          	bne	a0,a3,32a <memcmp+0x14>
  }
  return 0;
 33e:	4501                	li	a0,0
 340:	a019                	j	346 <memcmp+0x30>
      return *p1 - *p2;
 342:	40e7853b          	subw	a0,a5,a4
}
 346:	6422                	ld	s0,8(sp)
 348:	0141                	addi	sp,sp,16
 34a:	8082                	ret
  return 0;
 34c:	4501                	li	a0,0
 34e:	bfe5                	j	346 <memcmp+0x30>

0000000000000350 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 350:	1141                	addi	sp,sp,-16
 352:	e406                	sd	ra,8(sp)
 354:	e022                	sd	s0,0(sp)
 356:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 358:	f67ff0ef          	jal	2be <memmove>
}
 35c:	60a2                	ld	ra,8(sp)
 35e:	6402                	ld	s0,0(sp)
 360:	0141                	addi	sp,sp,16
 362:	8082                	ret

0000000000000364 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 364:	4885                	li	a7,1
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <exit>:
.global exit
exit:
 li a7, SYS_exit
 36c:	4889                	li	a7,2
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <wait>:
.global wait
wait:
 li a7, SYS_wait
 374:	488d                	li	a7,3
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 37c:	4891                	li	a7,4
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <read>:
.global read
read:
 li a7, SYS_read
 384:	4895                	li	a7,5
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <write>:
.global write
write:
 li a7, SYS_write
 38c:	48c1                	li	a7,16
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <close>:
.global close
close:
 li a7, SYS_close
 394:	48d5                	li	a7,21
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <kill>:
.global kill
kill:
 li a7, SYS_kill
 39c:	4899                	li	a7,6
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3a4:	489d                	li	a7,7
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <open>:
.global open
open:
 li a7, SYS_open
 3ac:	48bd                	li	a7,15
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3b4:	48c5                	li	a7,17
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3bc:	48c9                	li	a7,18
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3c4:	48a1                	li	a7,8
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <link>:
.global link
link:
 li a7, SYS_link
 3cc:	48cd                	li	a7,19
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3d4:	48d1                	li	a7,20
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3dc:	48a5                	li	a7,9
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3e4:	48a9                	li	a7,10
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3ec:	48ad                	li	a7,11
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3f4:	48b1                	li	a7,12
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3fc:	48b5                	li	a7,13
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 404:	48b9                	li	a7,14
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <reverse>:
.global reverse
reverse:
 li a7, SYS_reverse
 40c:	48d9                	li	a7,22
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <toggle_case>:
.global toggle_case
toggle_case:
 li a7, SYS_toggle_case
 414:	48dd                	li	a7,23
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 41c:	1101                	addi	sp,sp,-32
 41e:	ec06                	sd	ra,24(sp)
 420:	e822                	sd	s0,16(sp)
 422:	1000                	addi	s0,sp,32
 424:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 428:	4605                	li	a2,1
 42a:	fef40593          	addi	a1,s0,-17
 42e:	f5fff0ef          	jal	38c <write>
}
 432:	60e2                	ld	ra,24(sp)
 434:	6442                	ld	s0,16(sp)
 436:	6105                	addi	sp,sp,32
 438:	8082                	ret

000000000000043a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 43a:	7139                	addi	sp,sp,-64
 43c:	fc06                	sd	ra,56(sp)
 43e:	f822                	sd	s0,48(sp)
 440:	f426                	sd	s1,40(sp)
 442:	0080                	addi	s0,sp,64
 444:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 446:	c299                	beqz	a3,44c <printint+0x12>
 448:	0805c963          	bltz	a1,4da <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 44c:	2581                	sext.w	a1,a1
  neg = 0;
 44e:	4881                	li	a7,0
 450:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 454:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 456:	2601                	sext.w	a2,a2
 458:	00000517          	auipc	a0,0x0
 45c:	54850513          	addi	a0,a0,1352 # 9a0 <digits>
 460:	883a                	mv	a6,a4
 462:	2705                	addiw	a4,a4,1
 464:	02c5f7bb          	remuw	a5,a1,a2
 468:	1782                	slli	a5,a5,0x20
 46a:	9381                	srli	a5,a5,0x20
 46c:	97aa                	add	a5,a5,a0
 46e:	0007c783          	lbu	a5,0(a5)
 472:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 476:	0005879b          	sext.w	a5,a1
 47a:	02c5d5bb          	divuw	a1,a1,a2
 47e:	0685                	addi	a3,a3,1
 480:	fec7f0e3          	bgeu	a5,a2,460 <printint+0x26>
  if(neg)
 484:	00088c63          	beqz	a7,49c <printint+0x62>
    buf[i++] = '-';
 488:	fd070793          	addi	a5,a4,-48
 48c:	00878733          	add	a4,a5,s0
 490:	02d00793          	li	a5,45
 494:	fef70823          	sb	a5,-16(a4)
 498:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 49c:	02e05a63          	blez	a4,4d0 <printint+0x96>
 4a0:	f04a                	sd	s2,32(sp)
 4a2:	ec4e                	sd	s3,24(sp)
 4a4:	fc040793          	addi	a5,s0,-64
 4a8:	00e78933          	add	s2,a5,a4
 4ac:	fff78993          	addi	s3,a5,-1
 4b0:	99ba                	add	s3,s3,a4
 4b2:	377d                	addiw	a4,a4,-1
 4b4:	1702                	slli	a4,a4,0x20
 4b6:	9301                	srli	a4,a4,0x20
 4b8:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4bc:	fff94583          	lbu	a1,-1(s2)
 4c0:	8526                	mv	a0,s1
 4c2:	f5bff0ef          	jal	41c <putc>
  while(--i >= 0)
 4c6:	197d                	addi	s2,s2,-1
 4c8:	ff391ae3          	bne	s2,s3,4bc <printint+0x82>
 4cc:	7902                	ld	s2,32(sp)
 4ce:	69e2                	ld	s3,24(sp)
}
 4d0:	70e2                	ld	ra,56(sp)
 4d2:	7442                	ld	s0,48(sp)
 4d4:	74a2                	ld	s1,40(sp)
 4d6:	6121                	addi	sp,sp,64
 4d8:	8082                	ret
    x = -xx;
 4da:	40b005bb          	negw	a1,a1
    neg = 1;
 4de:	4885                	li	a7,1
    x = -xx;
 4e0:	bf85                	j	450 <printint+0x16>

00000000000004e2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4e2:	711d                	addi	sp,sp,-96
 4e4:	ec86                	sd	ra,88(sp)
 4e6:	e8a2                	sd	s0,80(sp)
 4e8:	e0ca                	sd	s2,64(sp)
 4ea:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4ec:	0005c903          	lbu	s2,0(a1)
 4f0:	26090863          	beqz	s2,760 <vprintf+0x27e>
 4f4:	e4a6                	sd	s1,72(sp)
 4f6:	fc4e                	sd	s3,56(sp)
 4f8:	f852                	sd	s4,48(sp)
 4fa:	f456                	sd	s5,40(sp)
 4fc:	f05a                	sd	s6,32(sp)
 4fe:	ec5e                	sd	s7,24(sp)
 500:	e862                	sd	s8,16(sp)
 502:	e466                	sd	s9,8(sp)
 504:	8b2a                	mv	s6,a0
 506:	8a2e                	mv	s4,a1
 508:	8bb2                	mv	s7,a2
  state = 0;
 50a:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 50c:	4481                	li	s1,0
 50e:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 510:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 514:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 518:	06c00c93          	li	s9,108
 51c:	a005                	j	53c <vprintf+0x5a>
        putc(fd, c0);
 51e:	85ca                	mv	a1,s2
 520:	855a                	mv	a0,s6
 522:	efbff0ef          	jal	41c <putc>
 526:	a019                	j	52c <vprintf+0x4a>
    } else if(state == '%'){
 528:	03598263          	beq	s3,s5,54c <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 52c:	2485                	addiw	s1,s1,1
 52e:	8726                	mv	a4,s1
 530:	009a07b3          	add	a5,s4,s1
 534:	0007c903          	lbu	s2,0(a5)
 538:	20090c63          	beqz	s2,750 <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
 53c:	0009079b          	sext.w	a5,s2
    if(state == 0){
 540:	fe0994e3          	bnez	s3,528 <vprintf+0x46>
      if(c0 == '%'){
 544:	fd579de3          	bne	a5,s5,51e <vprintf+0x3c>
        state = '%';
 548:	89be                	mv	s3,a5
 54a:	b7cd                	j	52c <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 54c:	00ea06b3          	add	a3,s4,a4
 550:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 554:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 556:	c681                	beqz	a3,55e <vprintf+0x7c>
 558:	9752                	add	a4,a4,s4
 55a:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 55e:	03878f63          	beq	a5,s8,59c <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 562:	05978963          	beq	a5,s9,5b4 <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 566:	07500713          	li	a4,117
 56a:	0ee78363          	beq	a5,a4,650 <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 56e:	07800713          	li	a4,120
 572:	12e78563          	beq	a5,a4,69c <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 576:	07000713          	li	a4,112
 57a:	14e78a63          	beq	a5,a4,6ce <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 57e:	07300713          	li	a4,115
 582:	18e78a63          	beq	a5,a4,716 <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 586:	02500713          	li	a4,37
 58a:	04e79563          	bne	a5,a4,5d4 <vprintf+0xf2>
        putc(fd, '%');
 58e:	02500593          	li	a1,37
 592:	855a                	mv	a0,s6
 594:	e89ff0ef          	jal	41c <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 598:	4981                	li	s3,0
 59a:	bf49                	j	52c <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 59c:	008b8913          	addi	s2,s7,8
 5a0:	4685                	li	a3,1
 5a2:	4629                	li	a2,10
 5a4:	000ba583          	lw	a1,0(s7)
 5a8:	855a                	mv	a0,s6
 5aa:	e91ff0ef          	jal	43a <printint>
 5ae:	8bca                	mv	s7,s2
      state = 0;
 5b0:	4981                	li	s3,0
 5b2:	bfad                	j	52c <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 5b4:	06400793          	li	a5,100
 5b8:	02f68963          	beq	a3,a5,5ea <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5bc:	06c00793          	li	a5,108
 5c0:	04f68263          	beq	a3,a5,604 <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 5c4:	07500793          	li	a5,117
 5c8:	0af68063          	beq	a3,a5,668 <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 5cc:	07800793          	li	a5,120
 5d0:	0ef68263          	beq	a3,a5,6b4 <vprintf+0x1d2>
        putc(fd, '%');
 5d4:	02500593          	li	a1,37
 5d8:	855a                	mv	a0,s6
 5da:	e43ff0ef          	jal	41c <putc>
        putc(fd, c0);
 5de:	85ca                	mv	a1,s2
 5e0:	855a                	mv	a0,s6
 5e2:	e3bff0ef          	jal	41c <putc>
      state = 0;
 5e6:	4981                	li	s3,0
 5e8:	b791                	j	52c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ea:	008b8913          	addi	s2,s7,8
 5ee:	4685                	li	a3,1
 5f0:	4629                	li	a2,10
 5f2:	000ba583          	lw	a1,0(s7)
 5f6:	855a                	mv	a0,s6
 5f8:	e43ff0ef          	jal	43a <printint>
        i += 1;
 5fc:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5fe:	8bca                	mv	s7,s2
      state = 0;
 600:	4981                	li	s3,0
        i += 1;
 602:	b72d                	j	52c <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 604:	06400793          	li	a5,100
 608:	02f60763          	beq	a2,a5,636 <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 60c:	07500793          	li	a5,117
 610:	06f60963          	beq	a2,a5,682 <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 614:	07800793          	li	a5,120
 618:	faf61ee3          	bne	a2,a5,5d4 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 61c:	008b8913          	addi	s2,s7,8
 620:	4681                	li	a3,0
 622:	4641                	li	a2,16
 624:	000ba583          	lw	a1,0(s7)
 628:	855a                	mv	a0,s6
 62a:	e11ff0ef          	jal	43a <printint>
        i += 2;
 62e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 630:	8bca                	mv	s7,s2
      state = 0;
 632:	4981                	li	s3,0
        i += 2;
 634:	bde5                	j	52c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 636:	008b8913          	addi	s2,s7,8
 63a:	4685                	li	a3,1
 63c:	4629                	li	a2,10
 63e:	000ba583          	lw	a1,0(s7)
 642:	855a                	mv	a0,s6
 644:	df7ff0ef          	jal	43a <printint>
        i += 2;
 648:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 64a:	8bca                	mv	s7,s2
      state = 0;
 64c:	4981                	li	s3,0
        i += 2;
 64e:	bdf9                	j	52c <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 650:	008b8913          	addi	s2,s7,8
 654:	4681                	li	a3,0
 656:	4629                	li	a2,10
 658:	000ba583          	lw	a1,0(s7)
 65c:	855a                	mv	a0,s6
 65e:	dddff0ef          	jal	43a <printint>
 662:	8bca                	mv	s7,s2
      state = 0;
 664:	4981                	li	s3,0
 666:	b5d9                	j	52c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 668:	008b8913          	addi	s2,s7,8
 66c:	4681                	li	a3,0
 66e:	4629                	li	a2,10
 670:	000ba583          	lw	a1,0(s7)
 674:	855a                	mv	a0,s6
 676:	dc5ff0ef          	jal	43a <printint>
        i += 1;
 67a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 67c:	8bca                	mv	s7,s2
      state = 0;
 67e:	4981                	li	s3,0
        i += 1;
 680:	b575                	j	52c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 682:	008b8913          	addi	s2,s7,8
 686:	4681                	li	a3,0
 688:	4629                	li	a2,10
 68a:	000ba583          	lw	a1,0(s7)
 68e:	855a                	mv	a0,s6
 690:	dabff0ef          	jal	43a <printint>
        i += 2;
 694:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 696:	8bca                	mv	s7,s2
      state = 0;
 698:	4981                	li	s3,0
        i += 2;
 69a:	bd49                	j	52c <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 69c:	008b8913          	addi	s2,s7,8
 6a0:	4681                	li	a3,0
 6a2:	4641                	li	a2,16
 6a4:	000ba583          	lw	a1,0(s7)
 6a8:	855a                	mv	a0,s6
 6aa:	d91ff0ef          	jal	43a <printint>
 6ae:	8bca                	mv	s7,s2
      state = 0;
 6b0:	4981                	li	s3,0
 6b2:	bdad                	j	52c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6b4:	008b8913          	addi	s2,s7,8
 6b8:	4681                	li	a3,0
 6ba:	4641                	li	a2,16
 6bc:	000ba583          	lw	a1,0(s7)
 6c0:	855a                	mv	a0,s6
 6c2:	d79ff0ef          	jal	43a <printint>
        i += 1;
 6c6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6c8:	8bca                	mv	s7,s2
      state = 0;
 6ca:	4981                	li	s3,0
        i += 1;
 6cc:	b585                	j	52c <vprintf+0x4a>
 6ce:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 6d0:	008b8d13          	addi	s10,s7,8
 6d4:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6d8:	03000593          	li	a1,48
 6dc:	855a                	mv	a0,s6
 6de:	d3fff0ef          	jal	41c <putc>
  putc(fd, 'x');
 6e2:	07800593          	li	a1,120
 6e6:	855a                	mv	a0,s6
 6e8:	d35ff0ef          	jal	41c <putc>
 6ec:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6ee:	00000b97          	auipc	s7,0x0
 6f2:	2b2b8b93          	addi	s7,s7,690 # 9a0 <digits>
 6f6:	03c9d793          	srli	a5,s3,0x3c
 6fa:	97de                	add	a5,a5,s7
 6fc:	0007c583          	lbu	a1,0(a5)
 700:	855a                	mv	a0,s6
 702:	d1bff0ef          	jal	41c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 706:	0992                	slli	s3,s3,0x4
 708:	397d                	addiw	s2,s2,-1
 70a:	fe0916e3          	bnez	s2,6f6 <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 70e:	8bea                	mv	s7,s10
      state = 0;
 710:	4981                	li	s3,0
 712:	6d02                	ld	s10,0(sp)
 714:	bd21                	j	52c <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 716:	008b8993          	addi	s3,s7,8
 71a:	000bb903          	ld	s2,0(s7)
 71e:	00090f63          	beqz	s2,73c <vprintf+0x25a>
        for(; *s; s++)
 722:	00094583          	lbu	a1,0(s2)
 726:	c195                	beqz	a1,74a <vprintf+0x268>
          putc(fd, *s);
 728:	855a                	mv	a0,s6
 72a:	cf3ff0ef          	jal	41c <putc>
        for(; *s; s++)
 72e:	0905                	addi	s2,s2,1
 730:	00094583          	lbu	a1,0(s2)
 734:	f9f5                	bnez	a1,728 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 736:	8bce                	mv	s7,s3
      state = 0;
 738:	4981                	li	s3,0
 73a:	bbcd                	j	52c <vprintf+0x4a>
          s = "(null)";
 73c:	00000917          	auipc	s2,0x0
 740:	25c90913          	addi	s2,s2,604 # 998 <malloc+0x150>
        for(; *s; s++)
 744:	02800593          	li	a1,40
 748:	b7c5                	j	728 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 74a:	8bce                	mv	s7,s3
      state = 0;
 74c:	4981                	li	s3,0
 74e:	bbf9                	j	52c <vprintf+0x4a>
 750:	64a6                	ld	s1,72(sp)
 752:	79e2                	ld	s3,56(sp)
 754:	7a42                	ld	s4,48(sp)
 756:	7aa2                	ld	s5,40(sp)
 758:	7b02                	ld	s6,32(sp)
 75a:	6be2                	ld	s7,24(sp)
 75c:	6c42                	ld	s8,16(sp)
 75e:	6ca2                	ld	s9,8(sp)
    }
  }
}
 760:	60e6                	ld	ra,88(sp)
 762:	6446                	ld	s0,80(sp)
 764:	6906                	ld	s2,64(sp)
 766:	6125                	addi	sp,sp,96
 768:	8082                	ret

000000000000076a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 76a:	715d                	addi	sp,sp,-80
 76c:	ec06                	sd	ra,24(sp)
 76e:	e822                	sd	s0,16(sp)
 770:	1000                	addi	s0,sp,32
 772:	e010                	sd	a2,0(s0)
 774:	e414                	sd	a3,8(s0)
 776:	e818                	sd	a4,16(s0)
 778:	ec1c                	sd	a5,24(s0)
 77a:	03043023          	sd	a6,32(s0)
 77e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 782:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 786:	8622                	mv	a2,s0
 788:	d5bff0ef          	jal	4e2 <vprintf>
}
 78c:	60e2                	ld	ra,24(sp)
 78e:	6442                	ld	s0,16(sp)
 790:	6161                	addi	sp,sp,80
 792:	8082                	ret

0000000000000794 <printf>:

void
printf(const char *fmt, ...)
{
 794:	711d                	addi	sp,sp,-96
 796:	ec06                	sd	ra,24(sp)
 798:	e822                	sd	s0,16(sp)
 79a:	1000                	addi	s0,sp,32
 79c:	e40c                	sd	a1,8(s0)
 79e:	e810                	sd	a2,16(s0)
 7a0:	ec14                	sd	a3,24(s0)
 7a2:	f018                	sd	a4,32(s0)
 7a4:	f41c                	sd	a5,40(s0)
 7a6:	03043823          	sd	a6,48(s0)
 7aa:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7ae:	00840613          	addi	a2,s0,8
 7b2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7b6:	85aa                	mv	a1,a0
 7b8:	4505                	li	a0,1
 7ba:	d29ff0ef          	jal	4e2 <vprintf>
}
 7be:	60e2                	ld	ra,24(sp)
 7c0:	6442                	ld	s0,16(sp)
 7c2:	6125                	addi	sp,sp,96
 7c4:	8082                	ret

00000000000007c6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7c6:	1141                	addi	sp,sp,-16
 7c8:	e422                	sd	s0,8(sp)
 7ca:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7cc:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d0:	00001797          	auipc	a5,0x1
 7d4:	8307b783          	ld	a5,-2000(a5) # 1000 <freep>
 7d8:	a02d                	j	802 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7da:	4618                	lw	a4,8(a2)
 7dc:	9f2d                	addw	a4,a4,a1
 7de:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7e2:	6398                	ld	a4,0(a5)
 7e4:	6310                	ld	a2,0(a4)
 7e6:	a83d                	j	824 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7e8:	ff852703          	lw	a4,-8(a0)
 7ec:	9f31                	addw	a4,a4,a2
 7ee:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7f0:	ff053683          	ld	a3,-16(a0)
 7f4:	a091                	j	838 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7f6:	6398                	ld	a4,0(a5)
 7f8:	00e7e463          	bltu	a5,a4,800 <free+0x3a>
 7fc:	00e6ea63          	bltu	a3,a4,810 <free+0x4a>
{
 800:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 802:	fed7fae3          	bgeu	a5,a3,7f6 <free+0x30>
 806:	6398                	ld	a4,0(a5)
 808:	00e6e463          	bltu	a3,a4,810 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 80c:	fee7eae3          	bltu	a5,a4,800 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 810:	ff852583          	lw	a1,-8(a0)
 814:	6390                	ld	a2,0(a5)
 816:	02059813          	slli	a6,a1,0x20
 81a:	01c85713          	srli	a4,a6,0x1c
 81e:	9736                	add	a4,a4,a3
 820:	fae60de3          	beq	a2,a4,7da <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 824:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 828:	4790                	lw	a2,8(a5)
 82a:	02061593          	slli	a1,a2,0x20
 82e:	01c5d713          	srli	a4,a1,0x1c
 832:	973e                	add	a4,a4,a5
 834:	fae68ae3          	beq	a3,a4,7e8 <free+0x22>
    p->s.ptr = bp->s.ptr;
 838:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 83a:	00000717          	auipc	a4,0x0
 83e:	7cf73323          	sd	a5,1990(a4) # 1000 <freep>
}
 842:	6422                	ld	s0,8(sp)
 844:	0141                	addi	sp,sp,16
 846:	8082                	ret

0000000000000848 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 848:	7139                	addi	sp,sp,-64
 84a:	fc06                	sd	ra,56(sp)
 84c:	f822                	sd	s0,48(sp)
 84e:	f426                	sd	s1,40(sp)
 850:	ec4e                	sd	s3,24(sp)
 852:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 854:	02051493          	slli	s1,a0,0x20
 858:	9081                	srli	s1,s1,0x20
 85a:	04bd                	addi	s1,s1,15
 85c:	8091                	srli	s1,s1,0x4
 85e:	0014899b          	addiw	s3,s1,1
 862:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 864:	00000517          	auipc	a0,0x0
 868:	79c53503          	ld	a0,1948(a0) # 1000 <freep>
 86c:	c915                	beqz	a0,8a0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 86e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 870:	4798                	lw	a4,8(a5)
 872:	08977a63          	bgeu	a4,s1,906 <malloc+0xbe>
 876:	f04a                	sd	s2,32(sp)
 878:	e852                	sd	s4,16(sp)
 87a:	e456                	sd	s5,8(sp)
 87c:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 87e:	8a4e                	mv	s4,s3
 880:	0009871b          	sext.w	a4,s3
 884:	6685                	lui	a3,0x1
 886:	00d77363          	bgeu	a4,a3,88c <malloc+0x44>
 88a:	6a05                	lui	s4,0x1
 88c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 890:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 894:	00000917          	auipc	s2,0x0
 898:	76c90913          	addi	s2,s2,1900 # 1000 <freep>
  if(p == (char*)-1)
 89c:	5afd                	li	s5,-1
 89e:	a081                	j	8de <malloc+0x96>
 8a0:	f04a                	sd	s2,32(sp)
 8a2:	e852                	sd	s4,16(sp)
 8a4:	e456                	sd	s5,8(sp)
 8a6:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8a8:	00000797          	auipc	a5,0x0
 8ac:	76878793          	addi	a5,a5,1896 # 1010 <base>
 8b0:	00000717          	auipc	a4,0x0
 8b4:	74f73823          	sd	a5,1872(a4) # 1000 <freep>
 8b8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8ba:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8be:	b7c1                	j	87e <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 8c0:	6398                	ld	a4,0(a5)
 8c2:	e118                	sd	a4,0(a0)
 8c4:	a8a9                	j	91e <malloc+0xd6>
  hp->s.size = nu;
 8c6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8ca:	0541                	addi	a0,a0,16
 8cc:	efbff0ef          	jal	7c6 <free>
  return freep;
 8d0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8d4:	c12d                	beqz	a0,936 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8d8:	4798                	lw	a4,8(a5)
 8da:	02977263          	bgeu	a4,s1,8fe <malloc+0xb6>
    if(p == freep)
 8de:	00093703          	ld	a4,0(s2)
 8e2:	853e                	mv	a0,a5
 8e4:	fef719e3          	bne	a4,a5,8d6 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 8e8:	8552                	mv	a0,s4
 8ea:	b0bff0ef          	jal	3f4 <sbrk>
  if(p == (char*)-1)
 8ee:	fd551ce3          	bne	a0,s5,8c6 <malloc+0x7e>
        return 0;
 8f2:	4501                	li	a0,0
 8f4:	7902                	ld	s2,32(sp)
 8f6:	6a42                	ld	s4,16(sp)
 8f8:	6aa2                	ld	s5,8(sp)
 8fa:	6b02                	ld	s6,0(sp)
 8fc:	a03d                	j	92a <malloc+0xe2>
 8fe:	7902                	ld	s2,32(sp)
 900:	6a42                	ld	s4,16(sp)
 902:	6aa2                	ld	s5,8(sp)
 904:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 906:	fae48de3          	beq	s1,a4,8c0 <malloc+0x78>
        p->s.size -= nunits;
 90a:	4137073b          	subw	a4,a4,s3
 90e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 910:	02071693          	slli	a3,a4,0x20
 914:	01c6d713          	srli	a4,a3,0x1c
 918:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 91a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 91e:	00000717          	auipc	a4,0x0
 922:	6ea73123          	sd	a0,1762(a4) # 1000 <freep>
      return (void*)(p + 1);
 926:	01078513          	addi	a0,a5,16
  }
}
 92a:	70e2                	ld	ra,56(sp)
 92c:	7442                	ld	s0,48(sp)
 92e:	74a2                	ld	s1,40(sp)
 930:	69e2                	ld	s3,24(sp)
 932:	6121                	addi	sp,sp,64
 934:	8082                	ret
 936:	7902                	ld	s2,32(sp)
 938:	6a42                	ld	s4,16(sp)
 93a:	6aa2                	ld	s5,8(sp)
 93c:	6b02                	ld	s6,0(sp)
 93e:	b7f5                	j	92a <malloc+0xe2>
