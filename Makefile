
all:
	gcc -c wayland.s -o wayland.o
	gcc -fno-pie -no-pie -nostartfiles wayland.o -o wayland -lwayland-client

test:
	./wayland

debug:
	gdb wayland

clean:
	rm wayland wayland.o
