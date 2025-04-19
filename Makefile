objs = main.o data.o
flag =
assb = as
name = snake

all: $(name)

$(name): $(objs)
	ld	-o $(name) $(objs)
%.o: %.s
	as	$< -o $@
clean:
	rm	-f $(objs) $(name)
