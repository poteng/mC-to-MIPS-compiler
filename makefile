GRAMMAR = parser.y

CFLAGS = -I. -funsigned-char -g -DYYDEBUG 	
YFLAGS = -v -d

mcc: y.tab.o lex.yy.o tree.o 
	gcc $(CFLAGS) -o mcc y.tab.o lex.yy.o tree.o -ll

y.tab.o: y.tab.c y.tab.h 
	gcc $(CFLAGS) -c y.tab.c 

y.tab.c: $(GRAMMAR)
	yacc $(YFLAGS) $(GRAMMAR)

lex.yy.o: lex.yy.c y.tab.h 
	gcc $(CFLAGS) -c lex.yy.c

lex.yy.c: scanner.l
	lex scanner.l

tree.o: tree.c tree.h
	gcc $(CFLAGS) -c tree.c

clean:
	rm -f y.tab.* y.output lex.yy.* *.o *~ mcc     



