
user/_toggle_case:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <strcat_custom>:
*/

// Custom string concatenation function
void
strcat_custom(char *dest, const char *src)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    // Find the end of the destination string
    while (*dest != '\0') {
   8:	00054783          	lbu	a5,0(a0)
   c:	c789                	beqz	a5,16 <strcat_custom+0x16>
        dest++;
   e:	0505                	addi	a0,a0,1
    while (*dest != '\0') {
  10:	00054783          	lbu	a5,0(a0)
  14:	ffed                	bnez	a5,e <strcat_custom+0xe>
    }

    // Copy the source string to the destination
    while (*src != '\0') {
  16:	0005c783          	lbu	a5,0(a1)
  1a:	cb81                	beqz	a5,2a <strcat_custom+0x2a>
        *dest = *src;
  1c:	00f50023          	sb	a5,0(a0)
        dest++;
  20:	0505                	addi	a0,a0,1
        src++;
  22:	0585                	addi	a1,a1,1
    while (*src != '\0') {
  24:	0005c783          	lbu	a5,0(a1)
  28:	fbf5                	bnez	a5,1c <strcat_custom+0x1c>
    }

    // Null-terminate the result
    *dest = '\0';
  2a:	00050023          	sb	zero,0(a0)
}
  2e:	60a2                	ld	ra,8(sp)
  30:	6402                	ld	s0,0(sp)
  32:	0141                	addi	sp,sp,16
  34:	8082                	ret

0000000000000036 <main>:

int
main(int argc, char *argv[])
{
  36:	7171                	addi	sp,sp,-176
  38:	f506                	sd	ra,168(sp)
  3a:	f122                	sd	s0,160(sp)
  3c:	1900                	addi	s0,sp,176
    if (argc < 2) {
  3e:	4785                	li	a5,1
  40:	04a7df63          	bge	a5,a0,9e <main+0x68>
  44:	ed26                	sd	s1,152(sp)
  46:	e94a                	sd	s2,144(sp)
  48:	e54e                	sd	s3,136(sp)
  4a:	e152                	sd	s4,128(sp)
  4c:	fcd6                	sd	s5,120(sp)
  4e:	f8da                	sd	s6,112(sp)
  50:	89aa                	mv	s3,a0
        printf("Usage: toggle_case <string>\n");
        exit(0);
    }

    char str[100] = {0};  // Buffer to hold the concatenated string
  52:	f4043c23          	sd	zero,-168(s0)
  56:	f6043023          	sd	zero,-160(s0)
  5a:	f6043423          	sd	zero,-152(s0)
  5e:	f6043823          	sd	zero,-144(s0)
  62:	f6043c23          	sd	zero,-136(s0)
  66:	f8043023          	sd	zero,-128(s0)
  6a:	f8043423          	sd	zero,-120(s0)
  6e:	f8043823          	sd	zero,-112(s0)
  72:	f8043c23          	sd	zero,-104(s0)
  76:	fa043023          	sd	zero,-96(s0)
  7a:	fa043423          	sd	zero,-88(s0)
  7e:	fa043823          	sd	zero,-80(s0)
  82:	fa042c23          	sw	zero,-72(s0)

    // Concatenate all arguments into one string with spaces
    for (int i = 1; i < argc; i++) {
  86:	00858913          	addi	s2,a1,8
  8a:	4485                	li	s1,1
        strcat_custom(str, argv[i]);
  8c:	f5840a13          	addi	s4,s0,-168
        if (i < argc - 1) {
  90:	fff50a9b          	addiw	s5,a0,-1
            strcat_custom(str, " ");
  94:	00001b17          	auipc	s6,0x1
  98:	8ecb0b13          	addi	s6,s6,-1812 # 980 <malloc+0x118>
  9c:	a025                	j	c4 <main+0x8e>
  9e:	ed26                	sd	s1,152(sp)
  a0:	e94a                	sd	s2,144(sp)
  a2:	e54e                	sd	s3,136(sp)
  a4:	e152                	sd	s4,128(sp)
  a6:	fcd6                	sd	s5,120(sp)
  a8:	f8da                	sd	s6,112(sp)
        printf("Usage: toggle_case <string>\n");
  aa:	00001517          	auipc	a0,0x1
  ae:	8b650513          	addi	a0,a0,-1866 # 960 <malloc+0xf8>
  b2:	6fe000ef          	jal	7b0 <printf>
        exit(0);
  b6:	4501                	li	a0,0
  b8:	2ee000ef          	jal	3a6 <exit>
    for (int i = 1; i < argc; i++) {
  bc:	2485                	addiw	s1,s1,1
  be:	0921                	addi	s2,s2,8
  c0:	00998e63          	beq	s3,s1,dc <main+0xa6>
        strcat_custom(str, argv[i]);
  c4:	00093583          	ld	a1,0(s2)
  c8:	8552                	mv	a0,s4
  ca:	f37ff0ef          	jal	0 <strcat_custom>
        if (i < argc - 1) {
  ce:	ff54d7e3          	bge	s1,s5,bc <main+0x86>
            strcat_custom(str, " ");
  d2:	85da                	mv	a1,s6
  d4:	8552                	mv	a0,s4
  d6:	f2bff0ef          	jal	0 <strcat_custom>
  da:	b7cd                	j	bc <main+0x86>
        }
    }

    printf("Original String: %s\n", str);
  dc:	f5840493          	addi	s1,s0,-168
  e0:	85a6                	mv	a1,s1
  e2:	00001517          	auipc	a0,0x1
  e6:	8a650513          	addi	a0,a0,-1882 # 988 <malloc+0x120>
  ea:	6c6000ef          	jal	7b0 <printf>

    // Call the toggle_case system call
    toggle_case(str);
  ee:	8526                	mv	a0,s1
  f0:	356000ef          	jal	446 <toggle_case>

    printf("Modified String: %s\n", str);
  f4:	85a6                	mv	a1,s1
  f6:	00001517          	auipc	a0,0x1
  fa:	8aa50513          	addi	a0,a0,-1878 # 9a0 <malloc+0x138>
  fe:	6b2000ef          	jal	7b0 <printf>
    exit(0);
 102:	4501                	li	a0,0
 104:	2a2000ef          	jal	3a6 <exit>

0000000000000108 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
 108:	1141                	addi	sp,sp,-16
 10a:	e406                	sd	ra,8(sp)
 10c:	e022                	sd	s0,0(sp)
 10e:	0800                	addi	s0,sp,16
  extern int main();
  main();
 110:	f27ff0ef          	jal	36 <main>
  exit(0);
 114:	4501                	li	a0,0
 116:	290000ef          	jal	3a6 <exit>

000000000000011a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 11a:	1141                	addi	sp,sp,-16
 11c:	e406                	sd	ra,8(sp)
 11e:	e022                	sd	s0,0(sp)
 120:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 122:	87aa                	mv	a5,a0
 124:	0585                	addi	a1,a1,1
 126:	0785                	addi	a5,a5,1
 128:	fff5c703          	lbu	a4,-1(a1)
 12c:	fee78fa3          	sb	a4,-1(a5)
 130:	fb75                	bnez	a4,124 <strcpy+0xa>
    ;
  return os;
}
 132:	60a2                	ld	ra,8(sp)
 134:	6402                	ld	s0,0(sp)
 136:	0141                	addi	sp,sp,16
 138:	8082                	ret

000000000000013a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 13a:	1141                	addi	sp,sp,-16
 13c:	e406                	sd	ra,8(sp)
 13e:	e022                	sd	s0,0(sp)
 140:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 142:	00054783          	lbu	a5,0(a0)
 146:	cb91                	beqz	a5,15a <strcmp+0x20>
 148:	0005c703          	lbu	a4,0(a1)
 14c:	00f71763          	bne	a4,a5,15a <strcmp+0x20>
    p++, q++;
 150:	0505                	addi	a0,a0,1
 152:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 154:	00054783          	lbu	a5,0(a0)
 158:	fbe5                	bnez	a5,148 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 15a:	0005c503          	lbu	a0,0(a1)
}
 15e:	40a7853b          	subw	a0,a5,a0
 162:	60a2                	ld	ra,8(sp)
 164:	6402                	ld	s0,0(sp)
 166:	0141                	addi	sp,sp,16
 168:	8082                	ret

000000000000016a <strlen>:

uint
strlen(const char *s)
{
 16a:	1141                	addi	sp,sp,-16
 16c:	e406                	sd	ra,8(sp)
 16e:	e022                	sd	s0,0(sp)
 170:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 172:	00054783          	lbu	a5,0(a0)
 176:	cf99                	beqz	a5,194 <strlen+0x2a>
 178:	0505                	addi	a0,a0,1
 17a:	87aa                	mv	a5,a0
 17c:	86be                	mv	a3,a5
 17e:	0785                	addi	a5,a5,1
 180:	fff7c703          	lbu	a4,-1(a5)
 184:	ff65                	bnez	a4,17c <strlen+0x12>
 186:	40a6853b          	subw	a0,a3,a0
 18a:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 18c:	60a2                	ld	ra,8(sp)
 18e:	6402                	ld	s0,0(sp)
 190:	0141                	addi	sp,sp,16
 192:	8082                	ret
  for(n = 0; s[n]; n++)
 194:	4501                	li	a0,0
 196:	bfdd                	j	18c <strlen+0x22>

0000000000000198 <memset>:

void*
memset(void *dst, int c, uint n)
{
 198:	1141                	addi	sp,sp,-16
 19a:	e406                	sd	ra,8(sp)
 19c:	e022                	sd	s0,0(sp)
 19e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1a0:	ca19                	beqz	a2,1b6 <memset+0x1e>
 1a2:	87aa                	mv	a5,a0
 1a4:	1602                	slli	a2,a2,0x20
 1a6:	9201                	srli	a2,a2,0x20
 1a8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1ac:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1b0:	0785                	addi	a5,a5,1
 1b2:	fee79de3          	bne	a5,a4,1ac <memset+0x14>
  }
  return dst;
}
 1b6:	60a2                	ld	ra,8(sp)
 1b8:	6402                	ld	s0,0(sp)
 1ba:	0141                	addi	sp,sp,16
 1bc:	8082                	ret

00000000000001be <strchr>:

char*
strchr(const char *s, char c)
{
 1be:	1141                	addi	sp,sp,-16
 1c0:	e406                	sd	ra,8(sp)
 1c2:	e022                	sd	s0,0(sp)
 1c4:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1c6:	00054783          	lbu	a5,0(a0)
 1ca:	cf81                	beqz	a5,1e2 <strchr+0x24>
    if(*s == c)
 1cc:	00f58763          	beq	a1,a5,1da <strchr+0x1c>
  for(; *s; s++)
 1d0:	0505                	addi	a0,a0,1
 1d2:	00054783          	lbu	a5,0(a0)
 1d6:	fbfd                	bnez	a5,1cc <strchr+0xe>
      return (char*)s;
  return 0;
 1d8:	4501                	li	a0,0
}
 1da:	60a2                	ld	ra,8(sp)
 1dc:	6402                	ld	s0,0(sp)
 1de:	0141                	addi	sp,sp,16
 1e0:	8082                	ret
  return 0;
 1e2:	4501                	li	a0,0
 1e4:	bfdd                	j	1da <strchr+0x1c>

00000000000001e6 <gets>:

char*
gets(char *buf, int max)
{
 1e6:	7159                	addi	sp,sp,-112
 1e8:	f486                	sd	ra,104(sp)
 1ea:	f0a2                	sd	s0,96(sp)
 1ec:	eca6                	sd	s1,88(sp)
 1ee:	e8ca                	sd	s2,80(sp)
 1f0:	e4ce                	sd	s3,72(sp)
 1f2:	e0d2                	sd	s4,64(sp)
 1f4:	fc56                	sd	s5,56(sp)
 1f6:	f85a                	sd	s6,48(sp)
 1f8:	f45e                	sd	s7,40(sp)
 1fa:	f062                	sd	s8,32(sp)
 1fc:	ec66                	sd	s9,24(sp)
 1fe:	e86a                	sd	s10,16(sp)
 200:	1880                	addi	s0,sp,112
 202:	8caa                	mv	s9,a0
 204:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 206:	892a                	mv	s2,a0
 208:	4481                	li	s1,0
    cc = read(0, &c, 1);
 20a:	f9f40b13          	addi	s6,s0,-97
 20e:	4a85                	li	s5,1
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 210:	4ba9                	li	s7,10
 212:	4c35                	li	s8,13
  for(i=0; i+1 < max; ){
 214:	8d26                	mv	s10,s1
 216:	0014899b          	addiw	s3,s1,1
 21a:	84ce                	mv	s1,s3
 21c:	0349d563          	bge	s3,s4,246 <gets+0x60>
    cc = read(0, &c, 1);
 220:	8656                	mv	a2,s5
 222:	85da                	mv	a1,s6
 224:	4501                	li	a0,0
 226:	198000ef          	jal	3be <read>
    if(cc < 1)
 22a:	00a05e63          	blez	a0,246 <gets+0x60>
    buf[i++] = c;
 22e:	f9f44783          	lbu	a5,-97(s0)
 232:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 236:	01778763          	beq	a5,s7,244 <gets+0x5e>
 23a:	0905                	addi	s2,s2,1
 23c:	fd879ce3          	bne	a5,s8,214 <gets+0x2e>
    buf[i++] = c;
 240:	8d4e                	mv	s10,s3
 242:	a011                	j	246 <gets+0x60>
 244:	8d4e                	mv	s10,s3
      break;
  }
  buf[i] = '\0';
 246:	9d66                	add	s10,s10,s9
 248:	000d0023          	sb	zero,0(s10)
  return buf;
}
 24c:	8566                	mv	a0,s9
 24e:	70a6                	ld	ra,104(sp)
 250:	7406                	ld	s0,96(sp)
 252:	64e6                	ld	s1,88(sp)
 254:	6946                	ld	s2,80(sp)
 256:	69a6                	ld	s3,72(sp)
 258:	6a06                	ld	s4,64(sp)
 25a:	7ae2                	ld	s5,56(sp)
 25c:	7b42                	ld	s6,48(sp)
 25e:	7ba2                	ld	s7,40(sp)
 260:	7c02                	ld	s8,32(sp)
 262:	6ce2                	ld	s9,24(sp)
 264:	6d42                	ld	s10,16(sp)
 266:	6165                	addi	sp,sp,112
 268:	8082                	ret

000000000000026a <stat>:

int
stat(const char *n, struct stat *st)
{
 26a:	1101                	addi	sp,sp,-32
 26c:	ec06                	sd	ra,24(sp)
 26e:	e822                	sd	s0,16(sp)
 270:	e04a                	sd	s2,0(sp)
 272:	1000                	addi	s0,sp,32
 274:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 276:	4581                	li	a1,0
 278:	16e000ef          	jal	3e6 <open>
  if(fd < 0)
 27c:	02054263          	bltz	a0,2a0 <stat+0x36>
 280:	e426                	sd	s1,8(sp)
 282:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 284:	85ca                	mv	a1,s2
 286:	178000ef          	jal	3fe <fstat>
 28a:	892a                	mv	s2,a0
  close(fd);
 28c:	8526                	mv	a0,s1
 28e:	140000ef          	jal	3ce <close>
  return r;
 292:	64a2                	ld	s1,8(sp)
}
 294:	854a                	mv	a0,s2
 296:	60e2                	ld	ra,24(sp)
 298:	6442                	ld	s0,16(sp)
 29a:	6902                	ld	s2,0(sp)
 29c:	6105                	addi	sp,sp,32
 29e:	8082                	ret
    return -1;
 2a0:	597d                	li	s2,-1
 2a2:	bfcd                	j	294 <stat+0x2a>

00000000000002a4 <atoi>:

int
atoi(const char *s)
{
 2a4:	1141                	addi	sp,sp,-16
 2a6:	e406                	sd	ra,8(sp)
 2a8:	e022                	sd	s0,0(sp)
 2aa:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2ac:	00054683          	lbu	a3,0(a0)
 2b0:	fd06879b          	addiw	a5,a3,-48
 2b4:	0ff7f793          	zext.b	a5,a5
 2b8:	4625                	li	a2,9
 2ba:	02f66963          	bltu	a2,a5,2ec <atoi+0x48>
 2be:	872a                	mv	a4,a0
  n = 0;
 2c0:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2c2:	0705                	addi	a4,a4,1
 2c4:	0025179b          	slliw	a5,a0,0x2
 2c8:	9fa9                	addw	a5,a5,a0
 2ca:	0017979b          	slliw	a5,a5,0x1
 2ce:	9fb5                	addw	a5,a5,a3
 2d0:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2d4:	00074683          	lbu	a3,0(a4)
 2d8:	fd06879b          	addiw	a5,a3,-48
 2dc:	0ff7f793          	zext.b	a5,a5
 2e0:	fef671e3          	bgeu	a2,a5,2c2 <atoi+0x1e>
  return n;
}
 2e4:	60a2                	ld	ra,8(sp)
 2e6:	6402                	ld	s0,0(sp)
 2e8:	0141                	addi	sp,sp,16
 2ea:	8082                	ret
  n = 0;
 2ec:	4501                	li	a0,0
 2ee:	bfdd                	j	2e4 <atoi+0x40>

00000000000002f0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2f0:	1141                	addi	sp,sp,-16
 2f2:	e406                	sd	ra,8(sp)
 2f4:	e022                	sd	s0,0(sp)
 2f6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2f8:	02b57563          	bgeu	a0,a1,322 <memmove+0x32>
    while(n-- > 0)
 2fc:	00c05f63          	blez	a2,31a <memmove+0x2a>
 300:	1602                	slli	a2,a2,0x20
 302:	9201                	srli	a2,a2,0x20
 304:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 308:	872a                	mv	a4,a0
      *dst++ = *src++;
 30a:	0585                	addi	a1,a1,1
 30c:	0705                	addi	a4,a4,1
 30e:	fff5c683          	lbu	a3,-1(a1)
 312:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 316:	fee79ae3          	bne	a5,a4,30a <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 31a:	60a2                	ld	ra,8(sp)
 31c:	6402                	ld	s0,0(sp)
 31e:	0141                	addi	sp,sp,16
 320:	8082                	ret
    dst += n;
 322:	00c50733          	add	a4,a0,a2
    src += n;
 326:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 328:	fec059e3          	blez	a2,31a <memmove+0x2a>
 32c:	fff6079b          	addiw	a5,a2,-1
 330:	1782                	slli	a5,a5,0x20
 332:	9381                	srli	a5,a5,0x20
 334:	fff7c793          	not	a5,a5
 338:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 33a:	15fd                	addi	a1,a1,-1
 33c:	177d                	addi	a4,a4,-1
 33e:	0005c683          	lbu	a3,0(a1)
 342:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 346:	fef71ae3          	bne	a4,a5,33a <memmove+0x4a>
 34a:	bfc1                	j	31a <memmove+0x2a>

000000000000034c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 34c:	1141                	addi	sp,sp,-16
 34e:	e406                	sd	ra,8(sp)
 350:	e022                	sd	s0,0(sp)
 352:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 354:	ca0d                	beqz	a2,386 <memcmp+0x3a>
 356:	fff6069b          	addiw	a3,a2,-1
 35a:	1682                	slli	a3,a3,0x20
 35c:	9281                	srli	a3,a3,0x20
 35e:	0685                	addi	a3,a3,1
 360:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 362:	00054783          	lbu	a5,0(a0)
 366:	0005c703          	lbu	a4,0(a1)
 36a:	00e79863          	bne	a5,a4,37a <memcmp+0x2e>
      return *p1 - *p2;
    }
    p1++;
 36e:	0505                	addi	a0,a0,1
    p2++;
 370:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 372:	fed518e3          	bne	a0,a3,362 <memcmp+0x16>
  }
  return 0;
 376:	4501                	li	a0,0
 378:	a019                	j	37e <memcmp+0x32>
      return *p1 - *p2;
 37a:	40e7853b          	subw	a0,a5,a4
}
 37e:	60a2                	ld	ra,8(sp)
 380:	6402                	ld	s0,0(sp)
 382:	0141                	addi	sp,sp,16
 384:	8082                	ret
  return 0;
 386:	4501                	li	a0,0
 388:	bfdd                	j	37e <memcmp+0x32>

000000000000038a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 38a:	1141                	addi	sp,sp,-16
 38c:	e406                	sd	ra,8(sp)
 38e:	e022                	sd	s0,0(sp)
 390:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 392:	f5fff0ef          	jal	2f0 <memmove>
}
 396:	60a2                	ld	ra,8(sp)
 398:	6402                	ld	s0,0(sp)
 39a:	0141                	addi	sp,sp,16
 39c:	8082                	ret

000000000000039e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 39e:	4885                	li	a7,1
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3a6:	4889                	li	a7,2
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <wait>:
.global wait
wait:
 li a7, SYS_wait
 3ae:	488d                	li	a7,3
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3b6:	4891                	li	a7,4
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <read>:
.global read
read:
 li a7, SYS_read
 3be:	4895                	li	a7,5
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <write>:
.global write
write:
 li a7, SYS_write
 3c6:	48c1                	li	a7,16
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <close>:
.global close
close:
 li a7, SYS_close
 3ce:	48d5                	li	a7,21
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3d6:	4899                	li	a7,6
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <exec>:
.global exec
exec:
 li a7, SYS_exec
 3de:	489d                	li	a7,7
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <open>:
.global open
open:
 li a7, SYS_open
 3e6:	48bd                	li	a7,15
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3ee:	48c5                	li	a7,17
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3f6:	48c9                	li	a7,18
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3fe:	48a1                	li	a7,8
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <link>:
.global link
link:
 li a7, SYS_link
 406:	48cd                	li	a7,19
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 40e:	48d1                	li	a7,20
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 416:	48a5                	li	a7,9
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <dup>:
.global dup
dup:
 li a7, SYS_dup
 41e:	48a9                	li	a7,10
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 426:	48ad                	li	a7,11
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 42e:	48b1                	li	a7,12
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 436:	48b5                	li	a7,13
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 43e:	48b9                	li	a7,14
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <toggle_case>:
.global toggle_case
toggle_case:
 li a7, SYS_toggle_case
 446:	48d9                	li	a7,22
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 44e:	1101                	addi	sp,sp,-32
 450:	ec06                	sd	ra,24(sp)
 452:	e822                	sd	s0,16(sp)
 454:	1000                	addi	s0,sp,32
 456:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 45a:	4605                	li	a2,1
 45c:	fef40593          	addi	a1,s0,-17
 460:	f67ff0ef          	jal	3c6 <write>
}
 464:	60e2                	ld	ra,24(sp)
 466:	6442                	ld	s0,16(sp)
 468:	6105                	addi	sp,sp,32
 46a:	8082                	ret

000000000000046c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 46c:	7139                	addi	sp,sp,-64
 46e:	fc06                	sd	ra,56(sp)
 470:	f822                	sd	s0,48(sp)
 472:	f426                	sd	s1,40(sp)
 474:	f04a                	sd	s2,32(sp)
 476:	ec4e                	sd	s3,24(sp)
 478:	0080                	addi	s0,sp,64
 47a:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 47c:	c299                	beqz	a3,482 <printint+0x16>
 47e:	0605ce63          	bltz	a1,4fa <printint+0x8e>
  neg = 0;
 482:	4e01                	li	t3,0
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 484:	fc040313          	addi	t1,s0,-64
  neg = 0;
 488:	869a                	mv	a3,t1
  i = 0;
 48a:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 48c:	00000817          	auipc	a6,0x0
 490:	53480813          	addi	a6,a6,1332 # 9c0 <digits>
 494:	88be                	mv	a7,a5
 496:	0017851b          	addiw	a0,a5,1
 49a:	87aa                	mv	a5,a0
 49c:	02c5f73b          	remuw	a4,a1,a2
 4a0:	1702                	slli	a4,a4,0x20
 4a2:	9301                	srli	a4,a4,0x20
 4a4:	9742                	add	a4,a4,a6
 4a6:	00074703          	lbu	a4,0(a4)
 4aa:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4ae:	872e                	mv	a4,a1
 4b0:	02c5d5bb          	divuw	a1,a1,a2
 4b4:	0685                	addi	a3,a3,1
 4b6:	fcc77fe3          	bgeu	a4,a2,494 <printint+0x28>
  if(neg)
 4ba:	000e0c63          	beqz	t3,4d2 <printint+0x66>
    buf[i++] = '-';
 4be:	fd050793          	addi	a5,a0,-48
 4c2:	00878533          	add	a0,a5,s0
 4c6:	02d00793          	li	a5,45
 4ca:	fef50823          	sb	a5,-16(a0)
 4ce:	0028879b          	addiw	a5,a7,2

  while(--i >= 0)
 4d2:	fff7899b          	addiw	s3,a5,-1
 4d6:	006784b3          	add	s1,a5,t1
    putc(fd, buf[i]);
 4da:	fff4c583          	lbu	a1,-1(s1)
 4de:	854a                	mv	a0,s2
 4e0:	f6fff0ef          	jal	44e <putc>
  while(--i >= 0)
 4e4:	39fd                	addiw	s3,s3,-1
 4e6:	14fd                	addi	s1,s1,-1
 4e8:	fe09d9e3          	bgez	s3,4da <printint+0x6e>
}
 4ec:	70e2                	ld	ra,56(sp)
 4ee:	7442                	ld	s0,48(sp)
 4f0:	74a2                	ld	s1,40(sp)
 4f2:	7902                	ld	s2,32(sp)
 4f4:	69e2                	ld	s3,24(sp)
 4f6:	6121                	addi	sp,sp,64
 4f8:	8082                	ret
    x = -xx;
 4fa:	40b005bb          	negw	a1,a1
    neg = 1;
 4fe:	4e05                	li	t3,1
    x = -xx;
 500:	b751                	j	484 <printint+0x18>

0000000000000502 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 502:	711d                	addi	sp,sp,-96
 504:	ec86                	sd	ra,88(sp)
 506:	e8a2                	sd	s0,80(sp)
 508:	e4a6                	sd	s1,72(sp)
 50a:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 50c:	0005c483          	lbu	s1,0(a1)
 510:	26048663          	beqz	s1,77c <vprintf+0x27a>
 514:	e0ca                	sd	s2,64(sp)
 516:	fc4e                	sd	s3,56(sp)
 518:	f852                	sd	s4,48(sp)
 51a:	f456                	sd	s5,40(sp)
 51c:	f05a                	sd	s6,32(sp)
 51e:	ec5e                	sd	s7,24(sp)
 520:	e862                	sd	s8,16(sp)
 522:	e466                	sd	s9,8(sp)
 524:	8b2a                	mv	s6,a0
 526:	8a2e                	mv	s4,a1
 528:	8bb2                	mv	s7,a2
  state = 0;
 52a:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 52c:	4901                	li	s2,0
 52e:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 530:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 534:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 538:	06c00c93          	li	s9,108
 53c:	a00d                	j	55e <vprintf+0x5c>
        putc(fd, c0);
 53e:	85a6                	mv	a1,s1
 540:	855a                	mv	a0,s6
 542:	f0dff0ef          	jal	44e <putc>
 546:	a019                	j	54c <vprintf+0x4a>
    } else if(state == '%'){
 548:	03598363          	beq	s3,s5,56e <vprintf+0x6c>
  for(i = 0; fmt[i]; i++){
 54c:	0019079b          	addiw	a5,s2,1
 550:	893e                	mv	s2,a5
 552:	873e                	mv	a4,a5
 554:	97d2                	add	a5,a5,s4
 556:	0007c483          	lbu	s1,0(a5)
 55a:	20048963          	beqz	s1,76c <vprintf+0x26a>
    c0 = fmt[i] & 0xff;
 55e:	0004879b          	sext.w	a5,s1
    if(state == 0){
 562:	fe0993e3          	bnez	s3,548 <vprintf+0x46>
      if(c0 == '%'){
 566:	fd579ce3          	bne	a5,s5,53e <vprintf+0x3c>
        state = '%';
 56a:	89be                	mv	s3,a5
 56c:	b7c5                	j	54c <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 56e:	00ea06b3          	add	a3,s4,a4
 572:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 576:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 578:	c681                	beqz	a3,580 <vprintf+0x7e>
 57a:	9752                	add	a4,a4,s4
 57c:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 580:	03878e63          	beq	a5,s8,5bc <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 584:	05978863          	beq	a5,s9,5d4 <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 588:	07500713          	li	a4,117
 58c:	0ee78263          	beq	a5,a4,670 <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 590:	07800713          	li	a4,120
 594:	12e78463          	beq	a5,a4,6bc <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 598:	07000713          	li	a4,112
 59c:	14e78963          	beq	a5,a4,6ee <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 5a0:	07300713          	li	a4,115
 5a4:	18e78863          	beq	a5,a4,734 <vprintf+0x232>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5a8:	02500713          	li	a4,37
 5ac:	04e79463          	bne	a5,a4,5f4 <vprintf+0xf2>
        putc(fd, '%');
 5b0:	85ba                	mv	a1,a4
 5b2:	855a                	mv	a0,s6
 5b4:	e9bff0ef          	jal	44e <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 5b8:	4981                	li	s3,0
 5ba:	bf49                	j	54c <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 5bc:	008b8493          	addi	s1,s7,8
 5c0:	4685                	li	a3,1
 5c2:	4629                	li	a2,10
 5c4:	000ba583          	lw	a1,0(s7)
 5c8:	855a                	mv	a0,s6
 5ca:	ea3ff0ef          	jal	46c <printint>
 5ce:	8ba6                	mv	s7,s1
      state = 0;
 5d0:	4981                	li	s3,0
 5d2:	bfad                	j	54c <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 5d4:	06400793          	li	a5,100
 5d8:	02f68963          	beq	a3,a5,60a <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5dc:	06c00793          	li	a5,108
 5e0:	04f68263          	beq	a3,a5,624 <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 5e4:	07500793          	li	a5,117
 5e8:	0af68063          	beq	a3,a5,688 <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 5ec:	07800793          	li	a5,120
 5f0:	0ef68263          	beq	a3,a5,6d4 <vprintf+0x1d2>
        putc(fd, '%');
 5f4:	02500593          	li	a1,37
 5f8:	855a                	mv	a0,s6
 5fa:	e55ff0ef          	jal	44e <putc>
        putc(fd, c0);
 5fe:	85a6                	mv	a1,s1
 600:	855a                	mv	a0,s6
 602:	e4dff0ef          	jal	44e <putc>
      state = 0;
 606:	4981                	li	s3,0
 608:	b791                	j	54c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 60a:	008b8493          	addi	s1,s7,8
 60e:	4685                	li	a3,1
 610:	4629                	li	a2,10
 612:	000ba583          	lw	a1,0(s7)
 616:	855a                	mv	a0,s6
 618:	e55ff0ef          	jal	46c <printint>
        i += 1;
 61c:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 61e:	8ba6                	mv	s7,s1
      state = 0;
 620:	4981                	li	s3,0
        i += 1;
 622:	b72d                	j	54c <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 624:	06400793          	li	a5,100
 628:	02f60763          	beq	a2,a5,656 <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 62c:	07500793          	li	a5,117
 630:	06f60963          	beq	a2,a5,6a2 <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 634:	07800793          	li	a5,120
 638:	faf61ee3          	bne	a2,a5,5f4 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 63c:	008b8493          	addi	s1,s7,8
 640:	4681                	li	a3,0
 642:	4641                	li	a2,16
 644:	000ba583          	lw	a1,0(s7)
 648:	855a                	mv	a0,s6
 64a:	e23ff0ef          	jal	46c <printint>
        i += 2;
 64e:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 650:	8ba6                	mv	s7,s1
      state = 0;
 652:	4981                	li	s3,0
        i += 2;
 654:	bde5                	j	54c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 656:	008b8493          	addi	s1,s7,8
 65a:	4685                	li	a3,1
 65c:	4629                	li	a2,10
 65e:	000ba583          	lw	a1,0(s7)
 662:	855a                	mv	a0,s6
 664:	e09ff0ef          	jal	46c <printint>
        i += 2;
 668:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 66a:	8ba6                	mv	s7,s1
      state = 0;
 66c:	4981                	li	s3,0
        i += 2;
 66e:	bdf9                	j	54c <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 670:	008b8493          	addi	s1,s7,8
 674:	4681                	li	a3,0
 676:	4629                	li	a2,10
 678:	000ba583          	lw	a1,0(s7)
 67c:	855a                	mv	a0,s6
 67e:	defff0ef          	jal	46c <printint>
 682:	8ba6                	mv	s7,s1
      state = 0;
 684:	4981                	li	s3,0
 686:	b5d9                	j	54c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 688:	008b8493          	addi	s1,s7,8
 68c:	4681                	li	a3,0
 68e:	4629                	li	a2,10
 690:	000ba583          	lw	a1,0(s7)
 694:	855a                	mv	a0,s6
 696:	dd7ff0ef          	jal	46c <printint>
        i += 1;
 69a:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 69c:	8ba6                	mv	s7,s1
      state = 0;
 69e:	4981                	li	s3,0
        i += 1;
 6a0:	b575                	j	54c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a2:	008b8493          	addi	s1,s7,8
 6a6:	4681                	li	a3,0
 6a8:	4629                	li	a2,10
 6aa:	000ba583          	lw	a1,0(s7)
 6ae:	855a                	mv	a0,s6
 6b0:	dbdff0ef          	jal	46c <printint>
        i += 2;
 6b4:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6b6:	8ba6                	mv	s7,s1
      state = 0;
 6b8:	4981                	li	s3,0
        i += 2;
 6ba:	bd49                	j	54c <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 6bc:	008b8493          	addi	s1,s7,8
 6c0:	4681                	li	a3,0
 6c2:	4641                	li	a2,16
 6c4:	000ba583          	lw	a1,0(s7)
 6c8:	855a                	mv	a0,s6
 6ca:	da3ff0ef          	jal	46c <printint>
 6ce:	8ba6                	mv	s7,s1
      state = 0;
 6d0:	4981                	li	s3,0
 6d2:	bdad                	j	54c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6d4:	008b8493          	addi	s1,s7,8
 6d8:	4681                	li	a3,0
 6da:	4641                	li	a2,16
 6dc:	000ba583          	lw	a1,0(s7)
 6e0:	855a                	mv	a0,s6
 6e2:	d8bff0ef          	jal	46c <printint>
        i += 1;
 6e6:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6e8:	8ba6                	mv	s7,s1
      state = 0;
 6ea:	4981                	li	s3,0
        i += 1;
 6ec:	b585                	j	54c <vprintf+0x4a>
 6ee:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 6f0:	008b8d13          	addi	s10,s7,8
 6f4:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6f8:	03000593          	li	a1,48
 6fc:	855a                	mv	a0,s6
 6fe:	d51ff0ef          	jal	44e <putc>
  putc(fd, 'x');
 702:	07800593          	li	a1,120
 706:	855a                	mv	a0,s6
 708:	d47ff0ef          	jal	44e <putc>
 70c:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 70e:	00000b97          	auipc	s7,0x0
 712:	2b2b8b93          	addi	s7,s7,690 # 9c0 <digits>
 716:	03c9d793          	srli	a5,s3,0x3c
 71a:	97de                	add	a5,a5,s7
 71c:	0007c583          	lbu	a1,0(a5)
 720:	855a                	mv	a0,s6
 722:	d2dff0ef          	jal	44e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 726:	0992                	slli	s3,s3,0x4
 728:	34fd                	addiw	s1,s1,-1
 72a:	f4f5                	bnez	s1,716 <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 72c:	8bea                	mv	s7,s10
      state = 0;
 72e:	4981                	li	s3,0
 730:	6d02                	ld	s10,0(sp)
 732:	bd29                	j	54c <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 734:	008b8993          	addi	s3,s7,8
 738:	000bb483          	ld	s1,0(s7)
 73c:	cc91                	beqz	s1,758 <vprintf+0x256>
        for(; *s; s++)
 73e:	0004c583          	lbu	a1,0(s1)
 742:	c195                	beqz	a1,766 <vprintf+0x264>
          putc(fd, *s);
 744:	855a                	mv	a0,s6
 746:	d09ff0ef          	jal	44e <putc>
        for(; *s; s++)
 74a:	0485                	addi	s1,s1,1
 74c:	0004c583          	lbu	a1,0(s1)
 750:	f9f5                	bnez	a1,744 <vprintf+0x242>
        if((s = va_arg(ap, char*)) == 0)
 752:	8bce                	mv	s7,s3
      state = 0;
 754:	4981                	li	s3,0
 756:	bbdd                	j	54c <vprintf+0x4a>
          s = "(null)";
 758:	00000497          	auipc	s1,0x0
 75c:	26048493          	addi	s1,s1,608 # 9b8 <malloc+0x150>
        for(; *s; s++)
 760:	02800593          	li	a1,40
 764:	b7c5                	j	744 <vprintf+0x242>
        if((s = va_arg(ap, char*)) == 0)
 766:	8bce                	mv	s7,s3
      state = 0;
 768:	4981                	li	s3,0
 76a:	b3cd                	j	54c <vprintf+0x4a>
 76c:	6906                	ld	s2,64(sp)
 76e:	79e2                	ld	s3,56(sp)
 770:	7a42                	ld	s4,48(sp)
 772:	7aa2                	ld	s5,40(sp)
 774:	7b02                	ld	s6,32(sp)
 776:	6be2                	ld	s7,24(sp)
 778:	6c42                	ld	s8,16(sp)
 77a:	6ca2                	ld	s9,8(sp)
    }
  }
}
 77c:	60e6                	ld	ra,88(sp)
 77e:	6446                	ld	s0,80(sp)
 780:	64a6                	ld	s1,72(sp)
 782:	6125                	addi	sp,sp,96
 784:	8082                	ret

0000000000000786 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 786:	715d                	addi	sp,sp,-80
 788:	ec06                	sd	ra,24(sp)
 78a:	e822                	sd	s0,16(sp)
 78c:	1000                	addi	s0,sp,32
 78e:	e010                	sd	a2,0(s0)
 790:	e414                	sd	a3,8(s0)
 792:	e818                	sd	a4,16(s0)
 794:	ec1c                	sd	a5,24(s0)
 796:	03043023          	sd	a6,32(s0)
 79a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 79e:	8622                	mv	a2,s0
 7a0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7a4:	d5fff0ef          	jal	502 <vprintf>
}
 7a8:	60e2                	ld	ra,24(sp)
 7aa:	6442                	ld	s0,16(sp)
 7ac:	6161                	addi	sp,sp,80
 7ae:	8082                	ret

00000000000007b0 <printf>:

void
printf(const char *fmt, ...)
{
 7b0:	711d                	addi	sp,sp,-96
 7b2:	ec06                	sd	ra,24(sp)
 7b4:	e822                	sd	s0,16(sp)
 7b6:	1000                	addi	s0,sp,32
 7b8:	e40c                	sd	a1,8(s0)
 7ba:	e810                	sd	a2,16(s0)
 7bc:	ec14                	sd	a3,24(s0)
 7be:	f018                	sd	a4,32(s0)
 7c0:	f41c                	sd	a5,40(s0)
 7c2:	03043823          	sd	a6,48(s0)
 7c6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7ca:	00840613          	addi	a2,s0,8
 7ce:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7d2:	85aa                	mv	a1,a0
 7d4:	4505                	li	a0,1
 7d6:	d2dff0ef          	jal	502 <vprintf>
}
 7da:	60e2                	ld	ra,24(sp)
 7dc:	6442                	ld	s0,16(sp)
 7de:	6125                	addi	sp,sp,96
 7e0:	8082                	ret

00000000000007e2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7e2:	1141                	addi	sp,sp,-16
 7e4:	e406                	sd	ra,8(sp)
 7e6:	e022                	sd	s0,0(sp)
 7e8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7ea:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ee:	00001797          	auipc	a5,0x1
 7f2:	8127b783          	ld	a5,-2030(a5) # 1000 <freep>
 7f6:	a02d                	j	820 <free+0x3e>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7f8:	4618                	lw	a4,8(a2)
 7fa:	9f2d                	addw	a4,a4,a1
 7fc:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 800:	6398                	ld	a4,0(a5)
 802:	6310                	ld	a2,0(a4)
 804:	a83d                	j	842 <free+0x60>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 806:	ff852703          	lw	a4,-8(a0)
 80a:	9f31                	addw	a4,a4,a2
 80c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 80e:	ff053683          	ld	a3,-16(a0)
 812:	a091                	j	856 <free+0x74>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 814:	6398                	ld	a4,0(a5)
 816:	00e7e463          	bltu	a5,a4,81e <free+0x3c>
 81a:	00e6ea63          	bltu	a3,a4,82e <free+0x4c>
{
 81e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 820:	fed7fae3          	bgeu	a5,a3,814 <free+0x32>
 824:	6398                	ld	a4,0(a5)
 826:	00e6e463          	bltu	a3,a4,82e <free+0x4c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 82a:	fee7eae3          	bltu	a5,a4,81e <free+0x3c>
  if(bp + bp->s.size == p->s.ptr){
 82e:	ff852583          	lw	a1,-8(a0)
 832:	6390                	ld	a2,0(a5)
 834:	02059813          	slli	a6,a1,0x20
 838:	01c85713          	srli	a4,a6,0x1c
 83c:	9736                	add	a4,a4,a3
 83e:	fae60de3          	beq	a2,a4,7f8 <free+0x16>
    bp->s.ptr = p->s.ptr->s.ptr;
 842:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 846:	4790                	lw	a2,8(a5)
 848:	02061593          	slli	a1,a2,0x20
 84c:	01c5d713          	srli	a4,a1,0x1c
 850:	973e                	add	a4,a4,a5
 852:	fae68ae3          	beq	a3,a4,806 <free+0x24>
    p->s.ptr = bp->s.ptr;
 856:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 858:	00000717          	auipc	a4,0x0
 85c:	7af73423          	sd	a5,1960(a4) # 1000 <freep>
}
 860:	60a2                	ld	ra,8(sp)
 862:	6402                	ld	s0,0(sp)
 864:	0141                	addi	sp,sp,16
 866:	8082                	ret

0000000000000868 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 868:	7139                	addi	sp,sp,-64
 86a:	fc06                	sd	ra,56(sp)
 86c:	f822                	sd	s0,48(sp)
 86e:	f04a                	sd	s2,32(sp)
 870:	ec4e                	sd	s3,24(sp)
 872:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 874:	02051993          	slli	s3,a0,0x20
 878:	0209d993          	srli	s3,s3,0x20
 87c:	09bd                	addi	s3,s3,15
 87e:	0049d993          	srli	s3,s3,0x4
 882:	2985                	addiw	s3,s3,1
 884:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 886:	00000517          	auipc	a0,0x0
 88a:	77a53503          	ld	a0,1914(a0) # 1000 <freep>
 88e:	c905                	beqz	a0,8be <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 890:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 892:	4798                	lw	a4,8(a5)
 894:	09377663          	bgeu	a4,s3,920 <malloc+0xb8>
 898:	f426                	sd	s1,40(sp)
 89a:	e852                	sd	s4,16(sp)
 89c:	e456                	sd	s5,8(sp)
 89e:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8a0:	8a4e                	mv	s4,s3
 8a2:	6705                	lui	a4,0x1
 8a4:	00e9f363          	bgeu	s3,a4,8aa <malloc+0x42>
 8a8:	6a05                	lui	s4,0x1
 8aa:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8ae:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8b2:	00000497          	auipc	s1,0x0
 8b6:	74e48493          	addi	s1,s1,1870 # 1000 <freep>
  if(p == (char*)-1)
 8ba:	5afd                	li	s5,-1
 8bc:	a83d                	j	8fa <malloc+0x92>
 8be:	f426                	sd	s1,40(sp)
 8c0:	e852                	sd	s4,16(sp)
 8c2:	e456                	sd	s5,8(sp)
 8c4:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8c6:	00000797          	auipc	a5,0x0
 8ca:	74a78793          	addi	a5,a5,1866 # 1010 <base>
 8ce:	00000717          	auipc	a4,0x0
 8d2:	72f73923          	sd	a5,1842(a4) # 1000 <freep>
 8d6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8d8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8dc:	b7d1                	j	8a0 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 8de:	6398                	ld	a4,0(a5)
 8e0:	e118                	sd	a4,0(a0)
 8e2:	a899                	j	938 <malloc+0xd0>
  hp->s.size = nu;
 8e4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8e8:	0541                	addi	a0,a0,16
 8ea:	ef9ff0ef          	jal	7e2 <free>
  return freep;
 8ee:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 8f0:	c125                	beqz	a0,950 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8f2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8f4:	4798                	lw	a4,8(a5)
 8f6:	03277163          	bgeu	a4,s2,918 <malloc+0xb0>
    if(p == freep)
 8fa:	6098                	ld	a4,0(s1)
 8fc:	853e                	mv	a0,a5
 8fe:	fef71ae3          	bne	a4,a5,8f2 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 902:	8552                	mv	a0,s4
 904:	b2bff0ef          	jal	42e <sbrk>
  if(p == (char*)-1)
 908:	fd551ee3          	bne	a0,s5,8e4 <malloc+0x7c>
        return 0;
 90c:	4501                	li	a0,0
 90e:	74a2                	ld	s1,40(sp)
 910:	6a42                	ld	s4,16(sp)
 912:	6aa2                	ld	s5,8(sp)
 914:	6b02                	ld	s6,0(sp)
 916:	a03d                	j	944 <malloc+0xdc>
 918:	74a2                	ld	s1,40(sp)
 91a:	6a42                	ld	s4,16(sp)
 91c:	6aa2                	ld	s5,8(sp)
 91e:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 920:	fae90fe3          	beq	s2,a4,8de <malloc+0x76>
        p->s.size -= nunits;
 924:	4137073b          	subw	a4,a4,s3
 928:	c798                	sw	a4,8(a5)
        p += p->s.size;
 92a:	02071693          	slli	a3,a4,0x20
 92e:	01c6d713          	srli	a4,a3,0x1c
 932:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 934:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 938:	00000717          	auipc	a4,0x0
 93c:	6ca73423          	sd	a0,1736(a4) # 1000 <freep>
      return (void*)(p + 1);
 940:	01078513          	addi	a0,a5,16
  }
}
 944:	70e2                	ld	ra,56(sp)
 946:	7442                	ld	s0,48(sp)
 948:	7902                	ld	s2,32(sp)
 94a:	69e2                	ld	s3,24(sp)
 94c:	6121                	addi	sp,sp,64
 94e:	8082                	ret
 950:	74a2                	ld	s1,40(sp)
 952:	6a42                	ld	s4,16(sp)
 954:	6aa2                	ld	s5,8(sp)
 956:	6b02                	ld	s6,0(sp)
 958:	b7f5                	j	944 <malloc+0xdc>
