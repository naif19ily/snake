#                  _        
#  ___ _ __   __ _| | _____ 
# / __| '_ \ / _` | |/ / _ \
# \__ \ | | | (_| |   <  __/
# |___/_| |_|\__,_|_|\_\___|

objs = main.o fp86.o boardata.o sys.o game.o over.o args.o fatal.o score.o gn.o date.o max.o
flag =
assb = as
name = snake

all: $(name)

$(name): $(objs)
	ld	-o $(name) $(objs)
%.o: %.asm
	as	$< -o $@
clean:
	rm	-f $(objs) $(name)
