# 2016-kts
2016 한국텍학회 학술대회 및 정기총회 발표자료, "루아텍 활용"

luajitlatex
-----------
발표 자료를 컴파일하기 위해서는 luajitlatex이 필요하다.

1. `kpsewhich fmtutil.cnf` 명령으로 fmtutil.cnf 파일의 위치를 확인한다.
1. fmtutil.cnf 파일을 열어서 luajitlatex으로 검색하여 그 줄의 주석을 해제한다.
1. `fmtutil-sys --byfmt luajitlatex` 명령을 실행하여 juajitlatex.fmt 를 생성한다.
1. `luajittex --fmt=luajitlatex.fmt foobar.tex`

편의를 위해서 아래와 같은 단축 명령어를 만든다.

```bash

  alias luajitlatex='luajittex --fmt=luajitlatex.fmt'
```
