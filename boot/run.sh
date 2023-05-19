# 路径!!!  就用绝对路径
nasm -I /home/wsm/bochs/include/ -o /home/wsm/bochs/boot/mbr.bin /home/wsm/bochs/boot/mbr.S
dd if=/home/wsm/bochs/boot/mbr.bin of=/home/wsm/bochs/hd60M.img bs=512 count=1 conv=notrunc

nasm -I /home/wsm/bochs/include/ -o /home/wsm/bochs/boot/loader.bin /home/wsm/bochs/boot/loader.S
dd if=/home/wsm/bochs/boot/loader.bin of=/home/wsm/bochs/hd60M.img bs=512 count=2 seek=2 conv=notrunc