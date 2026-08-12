% wc-ko: kotexcweb.tex을 시험하기 위한 wc.w의 한글판
% 원본: wc.w -- An example of CWEB by Silvio Levy and Donald E. Knuth
% cweave wc-ko.w && luatex wc-ko.tex

\input kotexcweb
\nocon % 목차는 생략한다
\datethis % 목록에 날짜를 찍는다
\def\title{워드 카운트}
\def\SPARC{SPARC\-\kern.1em station}

@* {\tt CWEB} 보기. 이 보기는 Klaus Guntermann과 Joachim Schrod의
프로그램[{\sl TUGboat\/ \bf7} (1986), 134--137]을 바탕으로 \UNIX/의
``word count'' 프로그램을 \.{CWEB}으로 다시 써서, \CEE/로 문학적
프로그래밍을 하는 모습을 보이려는 것이다. 이 문서는 가르칠 뜻으로
일부러 아주 자세하게 적었다. 여기서 낱낱이 밝힌 것 가운데 많은 것은
다른 프로그램에서는 굳이 설명할 필요가 없다.

\.{wc}가 하는 일은 파일 목록에 든 줄과 낱말, 글자의 수를 세는
것이다. 파일의 줄 수는 그 안에 든 줄바꿈 문자의 수다. 글자 수는
바이트로 잰 파일의 길이다. ``낱말''이란 줄바꿈이나 빈칸, 탭이 아닌
문자가 잇달아 늘어선 가장 긴 토막으로, 눈에 보이는 글자를 적어도
하나는 담은 것을 말한다. 원래의 \.{wc}는 ``눈에 보이는 글자''를
ASCII로만 쳤지만, 이 판은 UTF-8로 적힌 한글도 낱말의 글자로 친다.
아래에서 그 까닭을 밝힌다.

이 판의 \.{wc}에는 표준에 없는 ``조용한'' 옵션(\.{-s})이 있는데,
모든 파일에 대한 총계만 남기고 나머지 출력을 지운다.

@ 대부분의 \.{CWEB} 프로그램은 얼개가 엇비슷하다. 조각을 하나씩
덧붙이고 싶다면 여러 부분을 모두 이름 없는 절에 둘 수도 있지만,
전체 얼개를 첫머리에 또렷이 밝혀 두는 편이 아마 좋을 것이다.

그러면 이 \.{CWEB} 프로그램 \.{wc-ko.w}가 정의하는 파일
\.{wc-ko.c}를 한눈에 보자.

@c
@<포함할 헤더 파일@>@/
@<전역 변수@>@/
@<함수들@>@/
@<주 프로그램@>

@ 표준 입출력 정의를 넣어야 한다. |stdout|과 |stderr|로 서식 있는
출력을 보내려 하기 때문이다.

@<포함할...@>=
#include <stdio.h>

@ |status| 변수는 실행이 잘되었는지를 운영 체제에 알려 주고,
|prog_name|은 오류 메시지를 찍어야 할 때 쓴다.

@d OK 0 /* 실행이 잘되었을 때의 |status| 코드 */
@d usage_error 1 /* 문법이 잘못되었을 때의 |status| 코드 */
@d cannot_open_file 2 /* 파일 접근 오류일 때의 |status| 코드 */

@<전역 변수@>=
int status=OK; /* 명령의 종료 상태, 처음에는 |OK| */
char *prog_name; /* 우리가 누구인지 */

@ 이제 |main| 함수의 전체 배치를 볼 차례다.

@<주 프로...@>=
main (argc,argv)
    int argc; /* \UNIX/ 명령줄에 놓인 인자의 수 */
    char **argv; /* 인자 그 자체, 문자열의 배열 */
{
  @<|main|의 지역 변수@>@;
  prog_name=argv[0];
  @<옵션 선택을 마련한다@>;
  @<파일을 모두 처리한다@>;
  @<파일이 여럿이면 총계를 찍는다@>;
  exit(status);
}

@ 첫 인자가 `\.{-}'로 시작하면 사용자가 어떤 수를 셀지와 그것을
어떤 차례로 보일지를 고르는 것이다. 고르는 방법은 첫 글자를 적는
것이다(줄, 낱말, 글자). 이를테면 `\.{-cl}'이라고 하면 글자 수와 줄
수만 그 차례로 찍힌다. 특별한 인자를 주지 않았을 때의 기본값은
`\.{-lwc}'다.

이 문자열을 지금 처리하지는 않는다. 그저 어디에 있는지만 기억해
둔다. 이것은 출력할 때 서식을 다스리는 데 쓰인다.

`\.{-}' 바로 뒤에 `\.{s}'가 오면 총계만 찍는다.

@<|main|의 지역 변수@>=
int file_count; /* 파일이 몇 개인지 */
char *which; /* 어떤 수를 찍을지 */
int silent=0; /* 조용한 옵션을 골랐으면 0이 아니다 */

@ @<옵션 선택...@>=
which="lwc"; /* 옵션을 주지 않으면 세 값을 모두 찍는다 */
if (argc>1 && *argv[1] == '-') {
  argv[1]++;
  if (*argv[1]=='s') silent=1,argv[1]++;
  if (*argv[1]) which=argv[1];
  argc--; argv++;
}
file_count=argc-1;

@ 이제 남은 인자를 훑으며 될 수 있으면 파일을 연다. 파일을 처리하고
그 통계를 내놓는다. 파일 이름을 주지 않았으면 표준 입력에서 읽어야
하므로 |do|~\dots~|while| 반복문을 쓴다.

@<파일을 모두...@>=
argc--;
do@+{
  @<파일이 주어졌으면 |*(++argv)|를 연다. 열지 못하면 |continue|@>;
  @<포인터와 계수기를 초기화한다@>;
  @<파일을 훑는다@>;
  @<파일의 통계를 쓴다@>;
  @<파일을 닫는다@>;
  @<총계를 갱신한다@>; /* 파일이 하나뿐이어도 그렇게 한다 */
}@+while (--argc>0);

@ 파일을 여는 코드다. 이름을 주지 않았을 때 |stdin|에서 들어오는
입력을 다룰 수 있게 하는 재주를 하나 부린다. |stdin|의 파일 서술자가
0임을 떠올리라. 그것을 처음 값으로 쓴다.

@<|main|의 지...@>=
int fd=0; /* 파일 서술자, |stdin|으로 초기화한다 */

@ @d READ_ONLY 0 /* 시스템 |open| 루틴에 줄 읽기 접근 코드 */

@<파일이 주어졌으면...@>=
if (file_count>0 && (fd=open(*(++argv),READ_ONLY))<0) {
  fprintf (stderr, "%s: %s 파일을 열 수 없다\n", prog_name, *argv);
@.파일을 열 수 없다@>
  status|=cannot_open_file;
  file_count--;
  continue;
}

@ @<파일을 닫는다@>=
close(fd);

@ 일을 빨리 하려고 버퍼링을 손수 조금 해 둔다. 문자를 처리하기 전에
|buffer| 배열로 읽어 들이는 것이다. 그러려면 알맞은 포인터와 계수기를
마련해야 한다.

@d buf_size BUFSIZ /* \.{stdio.h}의 |BUFSIZ|를 효율을 위해 골랐다 */

@<|main|의 지...@>=
char buffer[buf_size]; /* 입력을 이 배열로 읽어 들인다 */
register char *ptr; /* |buffer|에서 아직 처리하지 않은 첫 문자 */
register char *buf_end; /* |buffer|에서 쓰지 않은 첫 자리 */
register int c; /* 지금 문자, 또는 방금 읽은 문자의 수 */
int in_word; /* 낱말 안에 있는가? */
long word_count, line_count, char_count; /* 지금까지 이 파일에서
    찾은 낱말과 줄, 글자의 수 */

@ @<포인터와...@>=
ptr=buf_end=buffer; line_count=word_count=char_count=0; in_word=0;

@ 총계는 프로그램이 시작할 때 0으로 초기화해야 한다. 이 변수들을
|main|의 지역 변수로 두었다면 그 초기화를 손수 적어야 했을 것이다.
그러나 \CEE/의 전역 변수는 저절로 0이 된다. (아니, ``정적으로''
0이 된다고 해야 하나.) (알아들으셨는지?)
@^농담@>

@<전역 변수@>=
long tot_word_count, tot_line_count, tot_char_count;
 /* 낱말과 줄, 글자의 총수 */

@ 세는 일에 들어가기 앞서, 어떤 바이트를 낱말의 글자로 볼지 정해야
한다. 원래의 \.{wc}는 눈에 보이는 ASCII 코드, 즉 빈칸보다 크고
\T{\~177}보다 작은 값만 낱말의 글자로 쳤다.

그러면 한글은 낱말이 되지 못한다. UTF-8에서 한글 한 글자는 세
바이트이고 그 바이트는 모두 \T{\^80}보다 크다. 그런데 \CEE/의
|char|는 대개 부호가 있어서 그런 바이트를 |c|에 담으면 음수가 되고,
따라서 |c>' '|가 거짓이 된다. 그래서 손대지 않은 \.{wc}로 한글
파일을 세면 낱말 수가 0으로 나온다.

고치는 방법은 간단하다. ASCII가 아닌 바이트를 모두 낱말의 글자로
치면 된다. 부호 없는 값으로 견주는 것이 요령이다. UTF-8은 여러
바이트로 된 문자의 모든 바이트를 \T{\^80} 이상으로 정해 두었으므로,
첫 바이트든 뒤따르는 바이트든 한결같이 낱말 안에 있는 것으로 여겨져
한글 한 글자가 낱말을 끊지 않는다.

@d visible_ascii(c) ((c)>' ' && (c)<0177) /* 눈에 보이는 ASCII 코드 */
@d nonascii(c) ((unsigned char)(c)>=0200) /* UTF-8의 여러 바이트 문자 */
@d word_char(c) (visible_ascii(c) || nonascii(c))

@ \.{wc}의 {\it 존재 이유\/}인 세는 일을 하는 지금 이 절은 사실
쓰기에 가장 쉬운 축에 들었다. 문자를 하나씩 보면서 그것이 낱말을
열거나 닫으면 상태를 바꾼다.

@<파일을 훑는다@>=
while (1) {
  @<|buffer|가 비었으면 채운다. 파일 끝이면 |break|@>;
  c=*ptr++;
  if (word_char(c)) {
    if (!in_word) {word_count++; in_word=1;}
    continue;
  }
  if (c=='\n') line_count++;
  else if (c!=' ' && c!='\t') continue;
  in_word=0; /* |c|는 줄바꿈이나 빈칸, 탭이다 */
}

@ 버퍼를 쓰는 입출력 덕분에 글자 수는 거저 세는 것이나 다름없다.
다만 여기서 세는 것은 읽어 들인 바이트의 수임을 잊지 말자. UTF-8에서
한글 한 글자는 세 바이트이므로, 한글 파일의 ``글자 수''는 눈에 보이는
글자의 수가 아니라 그 세 곱절에 가깝다. 낱말과 달리 글자를 제대로
세려면 이어지는 바이트(\T{\^80}부터 \T{\^BF}까지)를 빼고 세야 하는데,
그러면 읽은 양을 한 번에 더하는 이 절의 재미가 사라진다.

@<|buffer|가 비었으면...@>=
if (ptr>=buf_end) {
  ptr=buffer; c=read(fd,ptr,buf_size);
  if (c<=0) break;
  char_count+=c; buf_end=buffer+c;
}

@ 통계를 내놓을 때는 |wc_print|라는 함수를 새로 정의하는 것이
편하다. 그러면 총계에도 같은 함수를 쓸 수 있다. 게다가 처리한 파일의
이름을 아는지, 아니면 그저 |stdin|이었는지도 여기서 가려야 한다.

@<파일의 통계...@>=
if (!silent) {
  wc_print(which, char_count, word_count, line_count);
  if (file_count) printf (" %s\n", *argv); /* |stdin|이 아니다 */
  else printf ("\n"); /* |stdin|이다 */
}

@ @<총계를 갱신...@>=
tot_line_count+=line_count;
tot_word_count+=word_count;
tot_char_count+=char_count;

@ 이왕이면 파일의 수까지 보여 주어 \UNIX/의 \.{wc}보다 조금 낫게
만들어도 좋겠다.

@<파일이 여럿...@>=
if (file_count>1 || silent) {
  wc_print(which, tot_char_count, tot_word_count, tot_line_count);
  if (!file_count) printf("\n");
  else printf(" 파일 %d개의 총계\n",file_count);
}

@ 이제 고른 옵션에 따라 값을 찍는 함수다. 줄바꿈은 부르는 쪽에서
넣기로 한다. 올바르지 않은 옵션 문자를 만나면 명령을 제대로 쓰는
법을 사용자에게 알린다. 수는 여덟 자리 자리에 찍어 세로로 줄이
맞도록 한다.

@d print_count(n) printf("%8ld",n)

@<함수들@>=
wc_print(which, char_count, word_count, line_count)
char *which; /* 어떤 수를 찍을지 */
long char_count, word_count, line_count; /* 주어진 총계 */
{
  while (*which)
    switch (*which++) {
    case 'l': print_count(line_count); break;
    case 'w': print_count(word_count); break;
    case 'c': print_count(char_count); break;
    default: if ((status & usage_error)==0) {
        fprintf (stderr, "\n쓰는 법: %s [-lwc] [파일 이름 ...]\n",
          prog_name);
@.쓰는 법: ...@>
        status|=usage_error;
      }
    }
}

@ 덧붙이자면, 이 프로그램을 \SPARC\ 에서 시스템의 \.{wc} 명령과
견주어 보았더니 ``공식'' \.{wc} 쪽이 조금 느렸다. 게다가 그 \.{wc}는
옵션 `\.{-abc}'에는 알맞은 오류 메시지를 냈으면서 옵션 `\.{-labc}'에
대해서는 아무 불평도 하지 않았다! 그 시스템 루틴을 만든 프로그래머가
좀 더 문학적인 방식을 따랐더라면 더 나았으리라고 감히 말해 볼까?

@* 색인.
여기 쓰인 식별자와 그것이 나오는 자리의 목록이 있다. 밑줄 그어진
항목은 정의된 자리를 가리킨다. 오류 메시지도 함께 보인다.
