/* objective
   write a program in C that takes four integers 
   of any size
   
   -> contraints
     1. the logic must return only the smallest and the largest integers
     2. You may use if statements but only four
*/
#include <stdio.h>

int main(void){
   int a,b,c,d;
 
   printf("Can I have four integers please?\n");
   scanf("%d%d%d%d",&a,&b,&c,&d);
    
    int s=a;
    int l=a;
   // Test for largest 
    (void)(b > l && (l=b));
    (void)(c > l && (l=c));
    (void)(d > l && (l=d));
   
   // Test for smallest
    (void)(b < s && (s=b));
    (void)(c < s && (s=c));
    (void)(d < s && (s=d));

     printf("From the set given\n");
     printf("%d was found to be the largest\n", l);
     printf("%d was found to be the smallest\n", s);

  return 0;
}

   

   
  
