Change file for CWEAVE, so that a .w file can be written in Korean.

CWEAVE keeps its own copy of the constants that describe the input buffer, and
the section right above them says that a change to buf_size has to be made in
common.w too.  It is the other way round, really: common.w is where |buffer|
is declared and where "Input line too long" is reported, so comm-ko.ch is the
change that does the work and this one keeps CWEAVE's copy in step -- CWEAVE
reads |long_buf_size| when it collects a section name, and that has to be the
size of the array common.c actually allocated.  See comm-ko.ch for why a
hundred bytes is not much of a line in Korean, and build all three together:

  make CCHANGES=comm-ko.ch TCHANGES=ctang-ko.ch WCHANGES=cweav-ko.ch

@x l.127
@d buf_size 100 /* maximum length of input line, plus one */
@y
@d buf_size 1000 /* maximum length of input line, plus one */
@z
