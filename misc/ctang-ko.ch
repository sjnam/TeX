Change file for CTANGLE, so that a .w file can be written in Korean.

CTANGLE has a copy of buf_size as well, and it reads the same .w file CWEAVE
does, so it must not be left behind: with the standard hundred bytes it would
stop with "Input line too long" on the very lines CWEAVE now accepts.  The
buffer itself is common.w's -- see comm-ko.ch -- and all three changes belong
in the same build:

  make CCHANGES=comm-ko.ch TCHANGES=ctang-ko.ch WCHANGES=cweav-ko.ch

@x l.121
@d buf_size 100 /* for \.{CWEAVE} and \.{CTANGLE} */
@y
@d buf_size 1000 /* for \.{CWEAVE} and \.{CTANGLE}; Hangul takes 3 bytes */
@z
