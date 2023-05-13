nasm -o mbr.bin mbr2.S
dd if=./mbr.bin of=/home/wsm/bochs/hd60M.img bs=512 count=1 conv=notrunc
