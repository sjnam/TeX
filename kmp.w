\input kocweb

\def\mytitle{크누스-모리스-프랫 문자열 검색 알고리즘}
\def\title{\kotitle\mytitle}
\def\topofcontents{\null\vfill
  \centerline{\titlefont \mytitle}\vfill}

\def\bb{\hbox{\lower2.5pt\vbox{\hrule%
  \hbox to 9pt{\vrule height 10pt\hfill\vrule}\hrule}}}%\hskip2pt}
\def\alnum#1{\rlap{\hbox to9pt{\hss\.{#1}\hss}}}
\def\mm#1{\alnum#1\bb}

@* 크누스-모리스-프랫 알고리즘.
문자열 검색 알고리즘은 비교적 긴 텍스트 문자열과 그 텍스트에 비해
상대적으로 짧은 패턴 문자열이 주어졌을 때, 그 텍스트 내에 주어진
패턴이 몇 번이나 나오는지를 구하는 알고리즘 이다. 이 글에서는 많은
문자열 검색 알고리즘 중에서 ``KMP 알고리즘''이라고 알려진
크누스-모리스-프랫 알고리즘에 대해서 살펴보겠다. 

KMP 알고리즘을 비롯해서 문자열 검색 알고리즘은 이해하기 힘든
알고리즘으로 악명이 높습니다. 사실은 전혀 그렇지 않습니다. 물론
수학적으로 알고리즘 분석에 들어가면 얘기가 달라지지만, 알고리즘 자체는
매우 단순하며 오히려 자연스럽기까지 합니다. 

문자열 검색 알고리즘에는 재미있는 역사가 있습니다. 1970년에 쿡${}^{\hbox{\sc S. A.
Cook}}$이라는 사람이 문자열 검색에는 최악의 경우 $O(m+n)$ 만큰의 실행   
시간이 걸리는 알고리즘이 존재한다는 것을 증명했습니다. 크누스와 프랫은
쿡의 증명을 따라가서 실제로 구현할 수 있는 다소 간단한 알고리즘을
만들어 내는데 성공했습니다. 이와 거의 동시에 모리스${}^{\hbox{\sc J. H.
Morris}}$라는 사람이 독자적으로 새로운 알고리즘을 개발했는데, 그것이
크누스와 프랫의 알고리즘과 거의 동일했다고 합니다. 

크누스, 모리스, 프랫은 그들이 개발한 알고리즘을 1976년까지 발표를 하지
않았는데, 그러는 동안에 보이어${}^{\hbox{\sc R. S. Boyer}}$와
무어${}^{\hbox{\sc J. S. Moore}}$라는 사람들이 매우 빠른 알고리즘을
개발해 냈고, 대부분의 텍스트 
에디터에서 구현하고 있는 문자열 검색 알고리즘이 그들의 것이라고
합니다.

크누스-모리스-프랫과 보이어-무어 알고리즘은 모두 주어진 패턴에 대해서
약간 복잡한  전처리 단계가 필요한데, 이 단계가 이해하기가 쉽지
않습니다. 일화로 어떤 시스템 프로그래머는 그의 시스템에 사용된
모리스의 알고리즘이 이해하기 너무 어려워서 단순 무식한 방법의
알고리즘으로 바꾸기도 했다고 합니다. 

KMP 알고리즘을 알아보기에 앞서 단순 무식한 문자열 검색 알고리즘이 어떤
것인지 살펴 봅시다. 

@* 단순 무식한 방법.
KMP 문자열 검색 알고리즘이 효율적이라고들 말하는데, 무엇에 비해서
효율적이라고 하는지, 비교 대상을 찾아 봅시다. 그 비교 대상은 당연히
문자열 검색 하면 가장 먼저 떠올리 수 있고, 매우 단순하고 무식하지만
막강한 방법 일 것입니다. 그리고 그 방법은 다음과 같습니다. 

@<프로그램...@>=
int brute_force(char *p, char *s)
{
    int i, j, k;

    for (i=0; s[i] != '\0'; i++) {
        for (j=i, k=0; p[k] != '\0' && s[j]==p[k]; j++, k++) ;
        if (k > 0 && p[k] == '\0')
            return i;
    }
    return -1;
}

@ 위 코드는 너무도 직관적이기 때문에, 이해를 돕고 말고 할 것도 없지만, 
실제적인 예를 들어 이 알고리즘이 왜 단순 무식한지 살펴 봅시다. 주어진
텍스트 |s| 를 ``\.{ABC\ ABCDAB\ ABCDABCDABDE}'' 라고 하고, 
찾고자 하는 패턴 |p| 를 ``\.{ABCDABD}'' 라고 합시다. 그러면 위의
코드는 다음과 같이 그림으로 나타낼 수 있습니다.
\font\erm=cmr8
\count255=0
\def\step{\global\advance\count255 by1 
  \hbox to2.5em{\hfont{nanummjmo}{at 8pt}단계\hss\erm\number\count255}}
$$p=\.{ABCDABD}$$
$$\vbox{\halign{\hfil# :&&\ \ \hfil\hbox to1em{\hfil\.{#}\hfil}\hfil\cr
$i$&\erm0&\erm1&\erm2&\erm3&\erm4&\erm5&\erm6&\erm7&\erm8&\erm9&\erm10&\erm11&
\erm12&\erm13&\erm14&\erm15&\erm16&\erm17&\erm18&\erm19&\erm20&\erm21&\erm22\cr
$s$&A&B&C&\ &A&B&C&D&A&B&\ &A&B&C&D&A&B&C&D&A&B&D&E\cr
\step&A&B&C&\mm D&A&B&D&\cr
\step&&\mm A&B&C&D&A&B&D&\cr
\step&&&\mm A&B&C&D&A&B&D&\cr
\step&&&&\mm A&B&C&D&A&B&D&\cr
\step&&&&&A&B&C&D&A&B&\mm D&\cr
\step&&&&&&\mm A&B&C&D&A&B&D&\cr
\step&&&&&&&\mm A&B&C&D&A&B&D&\cr
\step&&&&&&&&\mm A&B&C&D&A&B&D&\cr
\step&&&&&&&&&A&B&\mm C&D&A&B&D&\cr
\step&&&&&&&&&&\mm A&B&C&D&A&B&D&\cr
\step&&&&&&&&&&&\mm A&B&C&D&A&B&D&\cr
\step&&&&&&&&&&&&A&B&C&D&A&B&\mm D&\cr
\step&&&&&&&&&&&&&\mm A&B&C&D&A&B&D&\cr
\step&&&&&&&&&&&&&&\mm A&B&C&D&A&B&D&\cr
\step&&&&&&&&&&&&&&&\mm A&B&C&D&A&B&D&\cr
\step&&&&&&&&&&&&&&&&A&B&C&D&A&B&D&\cr
\step&&&&&&&&&&&&&&&&&\mm A&B&C&D&A&B&D&\cr}}
$$
위 그림에서 \bb 는 텍스트와 패턴의 해당 문자가 서로 일치하지 않는
위치를 나타냅니다. 위의 그림과 같이 단순 무식한 방법은 패턴과 텍스트를
하나씩 비교해 나가다가 그 둘이 서로  다르면, 패턴을 오른쪽으로 한 칸
옮겨서 다음 단계로 이동한 후, 패턴의 처음 문자부터 텍스트의 
문자와 하나씩 비교해 나갑니다. 어찌보면 당연해 보이는 이 방법은 
하지 않아도 될 문자 비교를 하는 문제점이 있습니다. 하지 않아도 될 문자
비교가 어떤 것인지는 KMP 알고리즘에서 자세히 살펴 볼 것입니다.

이 단순 무식한 방법을 수학적으로 분석해 봅시다. 텍스트 문자열 |s|의
길이를 $n$, 패턴 문자열 |p|의 길이를 $m$ 이라고 하면, 최악의 경우
$m(n-m)$ 만큼의 비교를 하게 됩니다. $n$이 $m$에 비해서 상대적으로 매우
크다고 보면, $mn-m^2$ 에서 $m^2$은 무시 할 수 있으므로 이 방법의 실행
시간은 $O(mn)$이 됩니다. 사실 $O(mn)$은 최악의 경우이고, 대개는
$O(m+n)$ 만큼의 시간이 걸린다고 합니다.

@* KMP 문자열 검색 알고리즘.
앞서의 단순 무식한 방법은 하지 않아도 될 비교를 한다고 했습니다. 그
비교는 어떤 것일까요? 
\count255=0
$$\vbox{\halign{\hfil# :&&\ \ \hfil\hbox to1em{\hfil\.{#}\hfil}\hfil\cr
$i$&\erm0&\erm1&\erm2&\erm3&\erm4&\erm5&\erm6&\erm7&\erm8&\erm9&\erm10&\erm11&
\erm12&\erm13&\erm14&\erm15&\erm16&\erm17&\erm18&\erm19&\erm20&\erm21&\erm22\cr
$s$&A&B&C&\ &A&B&C&D&A&B&\ &A&B&C&D&A&B&C&D&A&B&D&E\cr
\step&A&B&C&\mm D&A&B&D&\cr
\step&&\mm A&B&C&D&A&B&D&\cr
\step&&&\mm A&B&C&D&A&B&D&\cr
\step&&&&\mm A&B&C&D&A&B&D&\cr
\step&&&&&A&B&C&D&A&B&\mm D&\cr}}
$$
[단계1]과 [단계2]를 자세히 살펴 봅시다. [단계1]에서의 $i=3$ 일때,
패턴의 문자와 텍스트의 문자가 `\.{\ }'와 `\.{D}'로 서로 일치하지
않습니다. 이렇게 두 문자가 일치하지 않을 때 현 단계을 마치고 다음
단계로 넘어가는데, 다음 단계로 가서 패턴을 언제나 오른쪽으로 한 칸만
이동해서 검사를 시작 할 필요가 있을까요? 

주어진 패턴을 꼼꼼히 살펴 봅시다. 패턴의 문자열은
`\.{ABCDABD}'입니다. 바로 이 문자열이 다음  단계로 간 후에 오른쪽으로
몇 칸 이동 할 것인가에 대한 정보를 담고 있습니다. 패턴 문자열이 $i=3$
에서 일치하지 않는다는 말은 $i=0,1,2$에서는 일치 한다는 말입니다. 이는
다시, 텍스트 문자열의 $i=0,1,2$는 패턴의 그것들과 같은 `\.{ABC}' 라는
뜻입니다. 패턴을 자리를 옮겨서 새로운 비교를 할 때, 패턴은 $i=0$ 부터
비교를 시작하는데, 이 문자는 \.{A} 이고, 우리는 위 사실로 부터
$i=1,2,3$의 텍스트 문자열에는 \.{A}가 없다는 사실을 알고 있습니다.  
($i=0$ 일때의 `\.{A}'는 이미 [단계1]에서 비교를 했으므로 제외합니다.)
따라서 위에서 [단계 2, 3, 4]에서 한 비교는 모두 필요
없습니다. 왜냐하면 그 단계들의 텍스트 문자열은 `\.{A}'로 시작하지 않기
때문입니다. 그래서 곧바로 [단계5]로 가서 비교를 시작해도 됩니다.  
[단계1]에서 [단계5]로 곧바로 갔다는 뜻은 비교할 패턴를 오른쪽으로 한
칸만 이동한 것이 아니라  네 칸을 이동했다는 뜻입니다. 같은 원리를
적용하면 단순 무식한 방법에서의 비교가 많이 줄어들어 아래 그림과 같이
됩니다. 
\count255=0
$$\vbox{\halign{\hfil# :&&\ \ \hfil\hbox to1em{\hfil\.{#}\hfil}\hfil\cr
$i$&\erm0&\erm1&\erm2&\erm3&\erm4&\erm5&\erm6&\erm7&\erm8&\erm9&\erm10&\erm11&
\erm12&\erm13&\erm14&\erm15&\erm16&\erm17&\erm18&\erm19&\erm20&\erm21&\erm22\cr
$s$&A&B&C&\ &A&B&C&D&A&B&\ &A&B&C&D&A&B&C&D&A&B&D&E\cr
\step&A&B&C&\mm D&A&B&D&\cr
\step&&&&&A&B&C&D&A&B&\mm D&\cr
\step&&&&&&&&&A&B&\mm C&D&A&B&D&\cr
\step&&&&&&&&&&&&A&B&C&D&A&B&\mm D&\cr
\step&&&&&&&&&&&&&&&&A&B&C&D&A&B&D&\cr}}
$$
위에서 보듯이 실제로는 5개의 단계만 거치면 일치하는 문자열을 찾을 수
있습니다. 단순 무식한 방법에서 처럼 16개의 단계나 거칠 이유가 전혀
없습니다.  [단계1]에서 [단계2]로 갈때는 패턴이 오른쪽으로 4칸,
[단계2]에서 [단계3]로 갈때도 4칸, [단계3]에서 [단계4]로 갈때는 3칸,
[단계4]에서 [단계5]로 갈때는 4칸을 이동했습니다. 이러한 방법이 바로
크누스-모리스-프랫 알고리즘이 실제로 하는 일입니다. 

[단계2]에서 [단계3]으로 가는 과정을 유심히 살펴 봅시다. 
이 과정에서 패턴을 오른쪽으로 4칸 이동했는데, 이 4칸은 사실 다음과
같은 의미입니다. [단계2]에서 패턴과 텍스트의 문자열을 비교합니다. 처음
6개는 모두 일치하고 마지막 하나만 다릅니다. 그래서 앞에서 6개의 문자는
일치 했으므로, [단계3]에서 일단 6칸을 오른쪽으로 이동합니다. 그런데
이동하고 보니 그 6개의 문자열에서 처음의 두 개 `\.{AB}'와 마지막 두 개  
`\.{AB}'가 서로 일치합니다. 그래서 2칸 뒤로 되돌아가서 결국은
4($=6-2$)칸을 이동하게 된 것입니다. 되돌아가지 않는다면, 일치할 수도
있는 문자열을 놓칠 우려가 있습니다.

@ KMP 알고리즘은 일단 패턴을 비교하다가 일치하지 않았을 때의 위치를
기억해 두었다가 다음 단계에서 그 위치의 숫자만큼 오르쪽으로 
이동했다가 얼마가 될지는 모르겠지만 마법의 수만큼 뒤로 되돌아
갑니다. 이 마법의 수를 구하는 것이 KMP 알고리즘의 핵심이라고 할 수
있습니다. 여기서는 마법의 수를 알고 있다고 가정하고, KMP 알고리즘을
구현해 보겠습니다. 그 마법의 수를 구하는 과정은 함수 |kmp_table()|에서
자세히 살펴 볼 것입니다. 

@<프로그램...@>=
int kmp_search(p, s)
	char *p; /* 찾고자 하는 패턴 문자열 */
	char *s; /* 주어진 텍스트 문자열 */
{
  int j; /* 텍스트 문자열 스캔에 이용되는 인덱스 변수 */
  int i; /* 패턴 문자열 스캔에 이용되는 인덱스 변수 */

  j = i = 0; /* 각 문자열의 인덱스 변수를 0으로 초기화 하라 */

  while (s[j+i] != '\0'&&p[i] != '\0') { /* 검사할 텍스트 문자열이 남아 있고, 아직 패턴를 찾지 못했다면 */ 
	if (s[j+i] == p[i]) { /* 해당 텍스트 문자와 패턴 문자가 일치 하면 */
	  ++i; /* 패턴 문자열의 다음 패턴를 비교하기 위해서 인덱스를 1 증가시켜라 */
	}@+ else {
	  j += i - table[i]; /* 패턴을 |i-table[i]| 만큼 이동하라 */
      @<패턴을 이동 시킨 후에도 패턴의 처음 부터 비교할 필요가 없다@>;
	}
  }

if (p[i] == '\0') { /* 텍스트에서 패턴 문자열을 찾았다면 */
	return j;
  }@+ else { /* 그렇지 않다면 */
	return -1;
  }
}

@ 위의 코드에서 주의 깊게 봐야 할 것이 하나 있습니다. 
KMP 알고리즘은 마법의 수를 동원해서 [단계2]에서 [단계3]으로 가는
과정에서 4칸을 이동했습니다. 그런데 그 후 [단계3]에서 패턴의
문자열에서 첫번째 문자 부터 비교할 필요가 있을까요? 그럴 필요가
없습니다. 패턴을 오른쪽으로 6칸 이동했다가 뒤로 2칸을 후퇴했는데,
후퇴한 이유는 앞에서도 설명했듯이, 패턴에서 불일치가 발생한 위치에서 
바로 앞의 두 개의 문자들이 패턴 맨앞의 두 개의 문자와 같았기 때문입니다. 
따라서 패턴을 이동하고 난 다음에 패턴의 처음 두개의 문자는 텍스트의
그것들과 당연히 일치합니다. 그래서 패턴의 세번째 문자 `\.{C}' 부터
비교 해나가면 됩니다. 이 사실은 매우 중요합니다. 

KMP 알고리즘은 위의 방식대로 텍스트 문자열의 문자들을 한 번 이상
비교하지 않습니다. 따라서 KMP 알고리즘의 문자열 검색 부분에 걸리는
시간은 $O(n)$입니다. $n$은 텍스트 문자열의 길이입니다. ``주어진 텍스트
문자열의 문자들을 한번 이상 비교하지 않는다''는 것이 KMP 알고리즘의
목적이기도 합니다. 

@<패턴을 이동 시킨...@>=
if (i > 0)@/
    i = table[i]

@* KMP 마법 테이블 만들기.
드디어 마법의 수를 구하는 방법을 살펴 볼 때가 되었습니다. 패턴
문자열을 구성하는 각각의 문자는 마법의 수를 가지고 있습니다. 따라서
패턴 문자열의 길이가 $m$ 이라고 하면 그에 해당하는 |table[m]|이
존재합니다. 편의상, 여기서는 |table[m]|를 `KMP 테이블'  
이라고 부르겠습니다. 이 테이블을 전문 용어로는 `{\sl failure function\/}' 
혹은 `{\sl partial match\/} 테이블' 이라고
부릅니다. 패턴의 길이는 최대 100을 넘지 않는 것으로 하겠습니다.

@d MAXWORD 100  /* 패턴의 최대 길이 */

@<전역...@>=
int table[MAXWORD];

@ KMP 알고리즘의 목적을 다시 한 번 상기 하겠습니다. ``주어진 텍스트
문자열의 문자들을 한 번 이상 비교하지 않는다.'' 문자들을 한 번 이상
비교하지 않는다는 뜻은 그 실행시간이 선형 시간이 걸린다는
말입니다. 이러한 막중한 임무를 맡는 것이 KMP 테이블인데, 이에 대한
설명은 이미 앞에서 다 했습니다. 예제로 사용한 패턴 `\.{ABCDABD}'의 KMP
테이블을 살펴 보겠습니다.
$$\vbox{\offinterlineskip\tabskip0pt\def\tablerule{\noalign{\hrule}}%
\halign{\strut\vrule#&\quad\hfil#\hfil\quad&\vrule#&\quad#\quad&%
\vrule#&\quad#\quad&\vrule#&\quad#\quad&\vrule#&\quad#\quad&%
\vrule#&\quad#\quad&\vrule#&\quad#\quad&\vrule#&\quad#\quad&\vrule#&#\cr
\tablerule%
  &$i$&&0&&1&&2&&3&&4&&5&&6&\cr 
\tablerule%
  &$p[i]$&&\.{A}&&\.{B}&&\.{C}&&\.{D}&&\.{A}&&\.{B}&&\.{D}&\cr 
\tablerule%
  &$table[i]$&&\llap{$-$}1&&0&&0&&0&&0&&1&&2&\cr 
\tablerule}}
$$ 
마법의 수 |table[i]|가 의미하는 것은 얼마만큼 후퇴하느냐
입니다. 후퇴의 의미는 앞에서 이미 살펴보았습니다. 후퇴는 `패턴을
왼쪽으로 이동시킨다'는 뜻입니다. 그렇다면, $i=6$ 일때 
$table[6]=2$ 가 뜻하는 것은 $i=6$ 일때, 비교하는 두 문자가 일치하지
않으면 일단 패턴을 6만큼 오른쪽으로 이동했다가 다시 2만큼 왼쪽으로
후퇴하라는 뜻입니다. 그럼 $table[6]$ 어떻게 해서 2라는 값을 갖게
되었을까요? 패턴을 잘 살펴보니, $i=6$ 일때, 그 바로 앞의 $i=4,5$
일때의 문자들이 $i=0,1$ 일때와 같습니다. 이 뜻은 패턴의 $i=4$ 일때
그에 해당하는 텍스트의 문자열이 주어진 패턴과 일치 할 수도 있다는
말입니다.  $i=0$ 일때 $table[0]$의 값은 $-1$로써 음수 입니다. 음수의
값은 패턴을 오른쪽으로 이동시키라는 뜻이므로 $-1$은 오른쪽으로 1칸
이동하라는 뜻입니다. 이것은 첫번째 문자에서 텍스트와 패턴이 일치하지
않는다는 뜻이므로 패턴을 1칸 오른쪽으로 이동시키라는 당연한
주문입니다. 그래서 $table[0]$은 어떤 패턴이 오던 간에 언제나 $-1$
입니다. 같은 맥락으로 $table[1]$의 값은 언제나 0입니다. (이유를 생각해
보세요.)

@ 이제 KMP 테이블의 값들을 실제로 구해 보겠습니다. 
이 부분이 KMP 알고리즘 구현에서 제일 까다로운 부분이지만, KMP 테이블의
의미를 충분히 이했다면 아래의 코드를 못 따라가갈 것도 없습니다.
@<프로그램...@>=
void kmp_table(p)
	char *p; /* 찾고자 하는 패턴 */
{
  int i, j;

  @<KMP 테이블의 $i=0, 1$인 값을 초기화 하라@>;

  while (p[i] != '\0') {
	if (p[i-1] == p[j]) {/* 패턴의 초반부와 후반부에 일치하는 문자가 있으면 */
	  table[i] = j + 1; /* 당연히 앞의 값보다 1 클 것입니다 */
	  ++i;
	  ++j;
	}@+ else if (j > 0) { /* 패턴의 초반부와 후반부에 더이상 일치하는 문자가 없다면 */
	  j = table[j];
	}@+ else {
	  table[i] = 0;
	  ++i;
	  j = 0; /* 값을 0으로 초기화 시켜라 */
	}
  }
}

@ 앞의 설명헤서 |table[0]|과 |table[1]|의 값은 $-1$과 0으로 이미
주어졌으므로, 그 값들을 설정하고 실제로는 |table[2]| 부터 값을
구해가면 됩니다. 

@<KMP 테이블의...@>=
i = 2; /* |table[2]| 부터 값을 계산해 나간다. 패턴의 후반부에 해당 */
j = 0; /* 패턴의 초반부에 해당 */
table[0] = -1;
table[1] = 0;

@ KMP 테이블을 구하는 데는 패턴의 길이 만큼 반복을 하므로 실행시간은
패턴의 길이를 $m$ 이라고 했을 때, $O(m)$이 됩니다. 여기서 정리해보면
KMP 문자열 검색에 필요한 시간은 $O(n)$ 이므로 KMP 알고리즘의 총
실행시간은 $O(m+n)$이 됩니다. 

@* 테스트 프로그램. KMP 알고리즘 구현을 테스트하는 프로그램을 작성해
봅시다.  테스트 프로그램으로는 ``{\sl The \CEE/ Programming Language\/}'' 
책의 제4장(69쪽)에 나오는 
주어진 입력에서 특정 패턴이 있는 행을 출력하는 프로그램입니다. 

@s line x

@c
#include <stdio.h>

#define MAXLINE 1000 /* 입력 받는 행의 최대 길이*/

@<전역 변수@>@;
@<프로그램에 사용된 함수들@>@;

@#
int main(int argc, char *argv[])
{
    char line[MAXLINE];
    int found = 0;

    kmp_table(argv[1]); /* 몇 칸을 이동할지에 대한 정보를 제공해주는 마법의 테이블을 만들어라 */
    while (fgets(line, MAXLINE, stdin)) /* 더 받아들일 행이 있으면 */
        if (kmp_search(argv[1], line) >= 0) { /* 그 행이 찾고자하는 패턴을 가지고 있다면 */
            printf("%s", line); /* 패턴을 포함하는 행을 출력 */
            found++; /* 카운터를 1 증가 */
        }
    printf("\n%d lines are matched.\n", found);
    return 0;
}

@* 찾아보기.