//http://ahoj.io/libwebsockets-simple-http-server

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <libwebsockets.h>
unsigned char txbuff[] = { 'h','e','l','l','o','\0'};

static int callback_http(struct lws_context *context,
                         const struct lws_extension *ext, struct lws *wsi,
                          enum lws_extension_callback_reasons reason,
                          void *user, void *in, size_t len)
{
   switch (reason)
   {
        case LWS_CALLBACK_HTTP: {
            //memcpy(txbuff, "Hello World!\0", strlen(txbuff)+1);
            lws_write(wsi, txbuff, 6, LWS_WRITE_HTTP);
            break;
        }
        
        default:
            printf("unhandled callback\n");
            break;
    }   
    return 0;
}

// list of supported protocols and callbacks
static struct lws_protocols protocols[] = {
    // first protocol must always be HTTP handler
    {
        "http-only",        // name
        callback_http,      // callback
        0,                  // per_session_data_size
    },
    { NULL, NULL, 0, 0 } /* terminator */
};

int main(void) {
    
    // create lws context representing this server
    lws_context_creation_info info = {0};
    
    info.port = 8081;
    info.protocols = protocols;
    
    struct lws_context *context;
    context = lws_create_context(&info);    
    if (context == NULL) {
        fprintf(stderr, "lws init failed\n");
        return -1;
    }
    
    printf("starting server...\n");
    
    // infinite loop, to end this server send SIGTERM. (CTRL+C)
    while (1) {
        lws_service(context, 50);
        // lws_service will process all waiting events with their
        // callback functions and then wait 50 ms.
        // (this is a single threaded webserver and this will keep our server
        // from generating load while there are not requests to process)
    }
    
    lws_context_destroy(context);
    
    return 0;
}
