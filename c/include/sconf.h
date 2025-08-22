// Use for socket programming
#include <sys/socket.h>
#include <sys/time.h> // time sucks
#include <sys/types.h>
#include <sys/ioctl.h>
#include <arpa/inet.h>



#include <stdlib.h> 
#include <signal.h>
#include <string.h>
#include <unistd.h>
#include <stdarg.h> // for the variadics!
#include <errno.h>  // my fav!
#include <netdb.h>

#define SERVER_PORT 80       // Standard HTTP PORT
#define MAXLINE  4096     
#define SA struct sockaddr // less wordy

// This is a variadic function
void dead_an_gone(const char *fmt, ...){
     int errno_save;
     va_list ap;
     // save errno regardless of who calls it
     errno_save = errno;
     // send out error messages to stdout.
     va_start(ap, fmt);
     vfprintf(stdout, fmt, ap);
     fprintf(stdout, "\n");
     fflush(stdout);
     // print out error message is errno was set.

     if(errno_save != 0)
     {
       fprintf(stdout, "(errno = %d) : %s\n", errno_save,
       strerror(errno_save));
       fprintf(stdout,"\n");
       fflush(stdout);
     }

     va_end(ap);
     exit(1);  
}
