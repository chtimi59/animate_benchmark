CC=gcc
CFLAGS=-W -Wall -std=c99 -pedantic 
LDFLAGS=

.PHONY: clean

all: client

client: client.c
	$(CC) -o client.o -c client.c $(CFLAGS)
	$(CC) $(LDFLAGS) -o client client.o

clean:
	@rm -f *.o
	@rm -f client


