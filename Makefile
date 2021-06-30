CC      ?= cc
CFLAGS  ?= -O2
YACC    ?= byacc
LEX     ?= flex
PREFIX  ?= /usr/local
BINDIR  ?= $(PREFIX)/bin
DATADIR ?= $(PREFIX)/share
MANDIR  ?= $(DATADIR)/man/man1
EXTRA_CFLAGS = -Wall -Wextra -I. -Iopenbsd -DEXTENDED

OBJS = eval.o expr.o look.o main.o misc.o gnum4.o trace.o parser.o tokenizer.o \
	openbsd/ohash.o

PROGRAM = m4
INSTALL_NAME ?= $(PROGRAM)

.PHONY: clean

all: $(PROGRAM)

.c.o:
	$(CC) -c -o $@ $< $(EXTRA_CFLAGS) $(CFLAGS)

.y.o:
	$(YACC) -o $@ $<

.l.o:
	$(LEX) -o $@ $<

parser.c: parser.y
	$(YACC) -H parser.h -o parser.c parser.y

tokenizer.c: tokenizer.l parser.c
	$(LEX) --header-file=tokenizer.h -o tokenizer.c tokenizer.l

parser.o: parser.c
tokenizer.o: tokenizer.c

$(PROGRAM): $(OBJS)
	$(CC) $(EXTRA_CFLAGS) $(CFLAGS) $(LDFLAGS) $(OBJS) -o $(PROGRAM)

clean:
	rm -f $(OBJS) $(PROGRAM) tokenizer.c tokenizer.h parser.c parser.h

install:
	install -d $(DESTDIR)$(BINDIR)
	install -m 755 $(PROGRAM) $(DESTDIR)$(BINDIR)/$(INSTALL_NAME)
	install -d $(DESTDIR)$(MANDIR)
	install -m 644 $(PROGRAM).1 $(DESTDIR)$(MANDIR)/$(INSTALL_NAME).1
