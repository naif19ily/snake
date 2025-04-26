objs = sys.o data.o fpx86.o main.o err.o graph.o
name = snake

all: $(name)

$(name): $(objs)
	ld	-o $(name) $(objs)
%.o: %.asm
	as	-o $@ $<
clean:
	rm	-rf $(objs) $(name) && clear
