#if WIN32

    // WINDOWS
    #include <string.h>
    #include <stdio.h>
    #include <winsock2.h>
    #include <ws2tcpip.h>
    #include <windows.h>
    int testkey(void)
    {
        CHAR ch;
        DWORD dw;
        HANDLE keyboard;
        INPUT_RECORD input;
        keyboard = GetStdHandle(STD_INPUT_HANDLE);
        dw = WaitForSingleObject(keyboard, 0);
        if (dw != WAIT_OBJECT_0)
            return 0;
        dw = 0;
        // Read an input record.
        ReadConsoleInput(keyboard, &input, 1, &dw);
        ch = 0;
        // Process a key down input event.
        if (!(input.EventType == KEY_EVENT
            && input.Event.KeyEvent.bKeyDown))
        {
            return 0;
        }
        // Retrieve the character that was pressed.
        ch = input.Event.KeyEvent.uChar.AsciiChar;
        // Function keys filtration
        if (input.Event.KeyEvent.dwControlKeyState &
            (LEFT_ALT_PRESSED | LEFT_CTRL_PRESSED | RIGHT_ALT_PRESSED |
            RIGHT_CTRL_PRESSED)
            )
            return 0;
        // if( ch == 13 )
        //  ...;  // enter pressed
        return ch;
    }

#else

    // POSIX
    #include <stdio.h>
    #include <stdlib.h>
    #include <stdbool.h>
    #include <string.h>
    #include <sys/types.h>
    #include <sys/socket.h>
    #include <sys/select.h>
    #include <netinet/in.h>
    #include <netdb.h> 
    #include <termios.h>
    #include <unistd.h>
    #include <fcntl.h>
    #include <arpa/inet.h>
    #include <ifaddrs.h>
    // #include <linux/if_link.h>
    int kbhit (void)
    {
      struct timeval tv;
      fd_set rdfs;
 
      tv.tv_sec = 0;
      tv.tv_usec = 0;
 
      FD_ZERO(&rdfs);
      FD_SET (STDIN_FILENO, &rdfs);
 
      select(STDIN_FILENO+1, &rdfs, NULL, NULL, &tv);
      return FD_ISSET(STDIN_FILENO, &rdfs);
 
    }
    void changemode(int dir)
    {
      static struct termios oldt, newt;
 
      if ( dir == 1 )
      {
        tcgetattr( STDIN_FILENO, &oldt);
        newt = oldt;
        newt.c_lflag &= ~( ICANON | ECHO );
        tcsetattr( STDIN_FILENO, TCSANOW, &newt);
      }
      else
        tcsetattr( STDIN_FILENO, TCSANOW, &oldt);
    }
    int testkey(void) { if (kbhit()) return getchar(); return 0; }
#endif

// Common definitions
#define UNUSED(...) (void)(__VA_ARGS__)
#define BYTE unsigned char


// ------------------------------
// Game Control API
// ------------------------------
#define TCP_PORT 8080
#define UNICAST_ADDR   inet_addr("127.0.0.1");

char txbuff[255];
char* setPlayer1(char* playerName) {
    sprintf(txbuff, "{\"event\": \"setPlayer1\", \"value\": {\"name\" : \"%s\" } }", playerName);
    return txbuff;
}
char* setPlayer2(char* playerName) {
    sprintf(txbuff, "{\"event\": \"setPlayer2\", \"value\": {\"name\" : \"%s\" } }", playerName);
    return txbuff;
}
char* start() {
    sprintf(txbuff, "{\"event\": \"start\"}");
    return txbuff;
}
char* stop() {
    sprintf(txbuff, "{\"event\": \"stop\"}");
    return txbuff;
}
char* player1Scan(int idx) {
    sprintf(txbuff, "{\"event\": \"player1Scan\", \"value\": %i }", idx);
    return txbuff;
}
char* player2Scan(int idx) {
    sprintf(txbuff, "{\"event\": \"player2Scan\", \"value\": %i }", idx);
    return txbuff;
}
char* showInstruction(BOOL enabled) {
    sprintf(txbuff, "{\"event\": \"showInstruction\", \"value\": { \"enabled\" : %s } }", enabled?"true":"false" );
    return txbuff;
}
char* showAdvert(BOOL enabled) {
    sprintf(txbuff, "{\"event\": \"showAdvert\", \"value\": { \"enabled\" : %s } }", enabled?"true":"false" );
    return txbuff;
}
char* shuffleProducts() {
    sprintf(txbuff, "{\"event\": \"shuffleProducts\" }");
    return txbuff;
}





// context

#if WIN32
    SOCKET mysocket;
    SOCKADDR_IN srv_addr;
#else
    int mysocket;
    struct sockaddr_in srv_addr;
#endif
struct in_addr hostip = {0};

#define MAXUDP_PAYLOADSZ 65527
char* rxbuff = NULL;

void sendData(char* buff) {
    size_t len;
    printf("Tx %s\n", buff);
    len = strlen(buff);
    send(mysocket, buff, len,0);
}

int main(int argc, char** argv)
{
    UNUSED(argc);
    UNUSED(argv);
    
    // init rxbuffer
    rxbuff = (char* )malloc(MAXUDP_PAYLOADSZ);
    if (!rxbuff) {
        fprintf(stderr, "out of memory");
        return 1;
    }
    
#if WIN32
// init WinSock 
{
    WORD w = MAKEWORD(1, 1);
    WSADATA wsadata;
    WSAStartup(w, &wsadata);
}
#endif
    
    // create a socket
    mysocket = socket(AF_INET, SOCK_STREAM, 0);
    if (mysocket == -1) {
        fprintf(stderr, "Error in creating socket");
        return 1;
    }

     // create destination address
    memset(&srv_addr, 0, sizeof(srv_addr));
    srv_addr.sin_family = AF_INET;
    srv_addr.sin_port = htons(TCP_PORT);
    srv_addr.sin_addr.s_addr = UNICAST_ADDR;
    
    // Connect
    fprintf(stderr, "wait for connection...\n");
    if (connect(mysocket, (struct sockaddr*)&srv_addr, sizeof(srv_addr)) < 0) {
        fprintf(stderr, "Couldn't not connect");
        return 1;
    }

    printf("---------\n");
    printf("ENTER = QUIT\n");
    printf("---------\n");
    printf("'a' = setPlayer1(bob)\n");
    printf("'b' = setPlayer2(Zoby la mouche)\n");
    printf("---------\n");
    printf("'i' = showInstruction(true)\n");
    printf("'h' = showInstruction(false)\n");
    printf("---------\n");
    printf("'n' = showAdvert(true)\n");
    printf("'m' = showAdvert(false)\n");
    printf("---------\n");
    printf("'x' = shuffleProducts()\n");
    printf("---------\n");
    printf("'s' = start()\n");
    printf("'e' = stop()\n");
    printf("---------\n");
    printf("'p' = switch PLAYER\n");
    printf("'0-9' = ESL0-9\n");
    printf("---------\n");
    {
        int c = 0;
        int p = 0;
        #ifndef WIN32    
        changemode(1);
        #endif
        while (c!=13) {
            int i = (c-'0');
            switch(c) {
                case 'a': sendData(setPlayer1("bob")); break;
                case 'b': sendData(setPlayer2("Zoby la nouche")); break;

                case 'n': sendData(showAdvert(TRUE)); break;
                case 'm': sendData(showAdvert(FALSE)); break;

                case 'i': sendData(showInstruction(TRUE)); break;
                case 'h': sendData(showInstruction(FALSE)); break;

                case 'x': sendData(shuffleProducts()); break;

                case 's': sendData(start()); break;
                case 'e': sendData(stop()); break;

                case 'p': p++; p%=2; printf(p==0?"PLAYER1\n":"PLAYER2\n"); break;
                default: 
                    if (i>=0 && i<10) sendData((p==0)?player1Scan(i):player2Scan(i));
                    break;
            }
            c = testkey();
        }
        #ifndef WIN32    
        changemode(0);
        #endif
    }

#if WIN32
    closesocket(mysocket);
#else
    close(mysocket);
#endif    
    
    if (rxbuff) free(rxbuff);
    return 0;
}
