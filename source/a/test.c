#include <stdio.h>
#include <time.h>

 int main(void)
 {
     time_t result;
     result = time(NULL);
     time_t days = result / 86400;

     time_t months = result / 2.628e+6;

     printf("%ld\n", months);

     time_t d = days, y = 1970;

     while (d >= 365)
     {
         if (y % 4 == 0) d -= 366; 
         else d -= 365;
         y++;
     }

     d = days;
     time_t Y = 1970;

     while (Y <= y)
     {
        time_t a = 365;
        if (Y % 4 == 0) { a = 366; }

        if (d < a) break;

        months -= 12;
        Y++;
        d -= a;
     }
     d++;



     printf("%ld year\n", y);
     printf("%ld month\n", months);
     printf("%ld days\n", d - (151));

     return(0);
 }
