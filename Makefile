CC=g++
CFLAGS=-Wall -w
all: parser.l
	lex parser.l
	$(CC) $(CFLAGS) lex.yy.c -o Parser
clean:
	rm lex.yy.c
	rm Parser
