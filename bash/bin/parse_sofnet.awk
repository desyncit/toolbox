#!/bin/awk -f 

BEGIN {
      printf("%-2d -| packet_process=%-20'"'"'d\tpacket_drop=%-10d\ttime_squeeze=%-10d\n",NR,strtonum("0x"$1),strtonum("0x"$2),strtonum("0x"$3))
}

{
  if($0 !~ /[A-Za-z0-9]+$/){
	printf("\n%s\n",$0);
	next 
    }
}
