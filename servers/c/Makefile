CC=gcc
#sudo apt-cache show libwebsockets-dev
#ldconfig -p | grep libwebsockets
#./include/libwebsockets.h
#./lib/arm-linux-gnueabihf/libwebsockets.a
#Version: 1.2.2-1

#-Wall -Werror -fvisibility=hidden  -pthread -O3 -DNDEBUG -I/home/jdo/libwebsockets/build -I/home/jdo/libwebsockets/lib    -o CMakeFiles/test-server-extpoll.dir/test-server/test-server.c.o   -c /home/jdo/libwebsockets/test-server/test-server.c


LIBPATH=/home/jdo/libwebsockets/build/lib
#CFLAGS=-W -std=c++11 -Wall -Wno-unused-parameter -Wno-missing-field-initializers -fpermissive -D_GNU_SOURCE -pedantic -I$(LIBPATH)/Headers
CFLAGS=-Wall -Werror -fvisibility=hidden  -pthread -O3 -I$(LIBPATH)/Headers
LDFLAGS=-L$(LIBPATH) -lwebsockets
EXEC=websocket
OBJS = main.o

all: $(EXEC)

websocket: $(OBJS)
	$(CC) -o  $@  $^  $(LDFLAGS)
	
%.o: %.c
	$(CC) -o $@ -c $< $(CFLAGS)

clean:
	@rm -f *.o
	@rm -f $(EXEC)	