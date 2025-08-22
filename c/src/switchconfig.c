#include <stdio.h>
#include <sconf.h>

int main(int argc, char **argv){
    int     sockfd, n;
    int     sendbytes;
    struct  sockaddr_in servaddr;
    char    sendline[MAXLINE]; // SO_SNDBUF
    char    recvline[MAXLINE]; // SO_RCVBUF

    // usage check; darn users!
    if (argc != 2)
       dead_an_gone("usage: %s <serv addr>\n", argv[0]);
   
    // Create a socket 
    // okay we need to call socket from sys/socket.h which allows us to communicate with clients 
    // AF_INET means v4  SOCK_STREAM TCPint socket(int domain, int type, int protocol);
    // 
    // see man socket(2) 
    //
    if ( ( sockfd = socket(AF_INET, SOCK_STREAM, 0)) < 0)
       dead_an_gone("BORK!!! we are FOOBAR'd capitain\n");

    memset(&servaddr,0,sizeof(servaddr));
    servaddr.sin_family = AF_INET;
    servaddr.sin_port = htons(SERVER_PORT); // htons == host to network short aka network standard byte order

    if (inet_pton(AF_INET, argv[1], &servaddr.sin_addr) <= 0)
      dead_an_gone("ptonnnnn error for %s\n", argv[1]);

    if (connect(sockfd, (SA *) &servaddr, sizeof(servaddr)) < 0 )
      dead_an_gone("connect said nah bro!");
   
    // gimmme index.html
    sprintf(sendline, "GET / HTTP/1.1\r\n\r\n");
    sendbytes = strlen(sendline);

    if(write(sockfd, sendline, sendbytes) != sendbytes)
      dead_an_gone("write error");

    memset(recvline, 0, MAXLINE);

    while ( ( n=read(sockfd, recvline, MAXLINE-1)) > 0)
    {
      printf("%s", recvline);
    }
    if(n < 0)
      dead_an_gone("read error");

    exit(0);
}
