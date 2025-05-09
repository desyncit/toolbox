#!/bin/awk -f 

# first method
for n in {1..100}; do 
	printf "\n[${n}]\t\t\t|==== %(%F-%T)T =====|\n"; 
	printf %.1s -{1..87} $'\n' ; 

	awk '{
		if($0 !~ /[A-Za-z0-9]+$/){
			printf("\n%s\n",$0);
			next 
		}
		{
		printf("%-2d -| packet_process=%-20'"'"'d\tpacket_drop=%-10d\ttime_squeeze=%-10d\n",NR,strtonum("0x"$1),strtonum("0x"$2),strtonum("0x"$3))
		}
	     }' /proc/net/softnet_stat; sleep 1.0; 
done

# second method

let c=0; 
	
while :; do 
	let c++; 
	printf "\n[${c}]\t\t\t|==== %(%F-%T)T =====|\n"; 
	printf %.1s -{1..87} $'\n' ; 

	awk '{
		if($0 !~ /[A-Za-z0-9]+$/){
			printf("\n%s\n",$0);
			next 
		}
		{
			printf("%-2d -| packet_process=%-20'"'"'d\tpacket_drop=%-10d\ttime_squeeze=%-10d\n",NR,strtonum("0x"$1),strtonum("0x"$2),strtonum("0x"$3))
		}
	     }' /proc/net/softnet_stat; sleep 1.0; 
done

# third method
for c in {1..100}; do 
	awk '{
		if($0 !~ /[A-Za-z0-9]+$/)next
	     }
	     {
		pck+=strtonum("0x"$1)
	     }
	     {
		drp+=strtonum("0x"$2)
	     }
	     END{
		  printf("[%d] +%s\n-\033[%db\n\t`Total Packets: %'"'"'d\n\t`Drops found: %'"'"'d\n\n",'${c}',FILENAME,75,pck,drps)
 		}' /proc/net/softnet_stat; sleep 1; 
done


# fourth method
for ((;;)); 
	do 
		awk '{
			if($0 !~ /[A-Za-z0-9]+$/)next
		     }
		     {
			pck+=strtonum("0x"$1)
		     }
		     {
			drp+=strtonum("0x"$2)
		     }
		     {
			ndrop+=$3
		     }
		     END{
			printf("[%d] +%s\n-\033[%db\n\t`Packets Processed: %'"'"'d\n\t`Drops found: %'"'"'13d\n\t`Nic Drops: %'"'"'15d\n\n",++i,FILENAME,75,pck,drps,ndrps)
			}' /proc/net/softnet_stat; sleep 1; 
done
[1] +/proc/net/softnet_stat
