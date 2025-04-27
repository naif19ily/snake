objs = sys.o data.o fpx86.o main.o err.o graph.o
name = snake

all: $(name)

$(name): $(objs)
	ld      -dynamic-linker /lib64/ld-linux-x86-64.so.2 -o snake /usr/lib/x86_64-linux-gnu/crt1.o /usr/lib/x86_64-linux-gnu/crti.o $(objs) -lc /usr/lib/x86_64-linux-gnu/crtn.o
%.o: %.asm
	as	-o $@ $<
clean:
	rm	-rf $(objs) $(name) && clear
