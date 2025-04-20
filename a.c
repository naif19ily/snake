#include <stdio.h>
#include <fcntl.h>

int main ()
{
    printf("%d\n", F_GETFL);
    printf("%d\n", F_SETFL);
    printf("%d\n", O_NONBLOCK);
}



