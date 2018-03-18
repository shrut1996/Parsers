CC=gcc
COFLAGS=
CWFLAGS=
CIFLAGS=
CMFLAGS=
CFLAGS= $(CWFLAGS)  $(COFLAGS)  $(CIFLAGS)  $(CMFLAGS)
beautify:
	beautify.o	symbol.o	init.o
	$(CC)   $(CFLAGS) -o beautify $<
.c.o:
	$(CC) $(CFLAGS) -c $<
beautify.c:
	beautify.l
	flex -0 beautify.c beautify.l
