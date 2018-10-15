# mC-to-MIPS-compiler

This is a compiler which compiles a C-like language mC (minimal C) into MIPS assembly language.


## Language/Tool used in this compiler
Scanner: Lex

Parser/Semantic Analyzer: Yacc

Code generator: C


## Installation
- parser.y
- scanner.l
- driver.c
- strtab.h
- tree.h
- tree.c
- makefile

Put above files together and use `make` command to compile.

Use `./mcc < [filename].mc` to input a .mc file and process.

## About the program
Most of the requirements for the feature of mC are met.

## Known bugs
Some scoop issues are not perfect yet.


## Reference:
http://epaperpress.com/lexandyacc/

http://stackoverflow.com/questions/1737460/how-to-find-shift-reduce-conflict-in-this-yacc-file

http://stackoverflow.com/questions/1760083/how-to-resolve-this-shift-reduce-conflict-in-yacc

http://www.iis.sinica.edu.tw/~tshsu/compiler2005/slides/slide5.pdf
