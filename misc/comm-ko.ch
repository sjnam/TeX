Change file for CWEB's COMMON, so that a .w file can be written in Korean.

A line of the .w file is read into a buffer of buf_size bytes, and one Hangul
syllable takes three of them in UTF-8.  With the standard buf_size of 100 a
Korean source line holds barely thirty characters before CWEAVE and CTANGLE
stop with "Input line too long", which is no way to write prose.  A kilobyte
of buffer is a few hundred Korean characters and costs a kilobyte.

This is the change that matters: |buffer| itself, |buffer_end| and
|change_buffer| are declared here in common.w.  The same constant is written
out again in ctangle.w and in cweave.w, where the manual says in so many words
that a change to it has to be made here as well; ctang-ko.ch and cweav-ko.ch
keep those two in step.  All three belong in the same build:

  make CCHANGES=comm-ko.ch TCHANGES=ctang-ko.ch WCHANGES=cweav-ko.ch

@x l.153
@d buf_size 100 /* for \.{CWEAVE} and \.{CTANGLE} */
@y
@d buf_size 1000 /* for \.{CWEAVE} and \.{CTANGLE}; Hangul takes 3 bytes */
@z
