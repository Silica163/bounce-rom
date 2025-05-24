all: main

main: main.asm
	nasm main.asm -o main

run: main
	qemu-system-x86_64 main
