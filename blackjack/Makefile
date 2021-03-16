.PHONY: all clean debug

all:
	as main.s -o main.o
	ld main.o -o main
clean:
	rm -f main.o main
debug:
	as main.s -o main.o -g
	ld main.o -o main -g
