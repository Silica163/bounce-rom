#!/usr/bin/bash

nvim '+set syntax=nasm' main.asm && nasm main.asm -o main && qemu-system-x86_64 main
