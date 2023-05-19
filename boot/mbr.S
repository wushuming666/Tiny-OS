;2023.5.16
;保护模式
;主引导程序
;从硬盘加载一个内核程序并跳转到该程序的入口点
;----------------------------------
%include "boot.inc"
SECTION MBR vstart=0x7c00
	mov ax,cs
	mov ds,ax
	mov es,ax
	mov ss,ax
	mov fs,ax
	mov sp,0x7c00
	mov ax,0xb800
	mov gs,ax	; gs段寄存器,可以使用gs段寄存器来访问显存

; 清屏利用 0x60 号功能，上卷全部行，则可清屏
; ---------------------
; INT 0x10  功能号：0x06       功能描述：上卷窗口
;----------------------
; 输入：
; AH 功能号 = 0x06
; BH = 上卷行属性
; (CL, CH) = 窗口左上角的(X,Y)位置
; (DL, DH) = 窗口右下角的(X,Y)位置
; 无返回值
	mov ax, 0600h
	mov bx, 0700h
	mov cx, 0		; 左上角 (0,0)
	mov dx, 184fh		; 右下角 (80,25)
				; 一行只能80个字符,共25行
				; 下标从0开始,0x18=24, 0x4f=79
	int 	10h

; 输出背景色绿色, 前景色红色, 并且跳动的字符串"1 MBR"

	mov byte [gs:0x00],'1'
	mov byte [gs:0x01],0xA4	; A表示绿色背景闪烁, 4表示前景色为红色

	mov byte [gs:0x02],' '
	mov byte [gs:0x03],0xA4

	mov byte [gs:0x04],'M'
	mov byte [gs:0x05],0xA4
	
	mov byte [gs:0x06],'B'
	mov byte [gs:0x07],0xA4

	mov byte [gs:0x08],'R'
	mov byte [gs:0x09],0xA4

	mov eax, LOADER_START_SECTOR	; 起始扇区lba地址
	mov bx, LOADER_BASE_ADDR	; 写入的地址
	mov cx, 4			; 代写入的扇区数 修改为4
	call rd_disk_m_16		; rd_disk_m_16是函数,实现了从硬盘读取一个扇区的数据到内存中
					; 以下读取程序的起始部分(一个扇区)

	jmp LOADER_BASE_ADDR		; 将读取的数据写入

;--------------------
;功能:读取硬盘n个扇区
rd_disk_m_16:
;--------------------
					;eax=LBA 扇区号
					;bx=将数据写入的内存地址
					;cx=读入的扇区数
	mov esi,eax		;备份eax
	mov di,cx		;备份cx
;读写硬盘
;第1步:设置要读取的扇区数
	mov dx, 0x1f2
	mov al, cl		;cl是cx的低8位
	out dx, al		;out用于将数据传输到指定端口
				;读取扇区数

	mov eax,esi		;恢复eax

;第2步:将LBA地址存入0x1f3~0x1f6
	
	;LBA地址7~0位写入端口0x1f3
	mov dx, 0x1f3
	out dx, al

	;LBA地址15~8位写入端口0x1f4
	mov cl, 8
	shr eax, cl		;将eax中存储的扇区数量向右移动8位
	mov dx, 0x1f4	
	out dx, al

	;LBA地址23~16位写入端口0x1f5
	shr eax, cl
	mov dx, 0x1f5
	out dx, al

	shr eax, cl
	and al, 0x0f		; lba第24~27位
	or al, 0xe0		; 设置7~4位为1110,表示lba模式
	mov dx, 0x1f6
	out dx, al

; 第3步:向0x1f7端口写入读命令,0x20
	mov dx, 0x1f7
	mov al, 0x20
	out dx, al

; 第4步:检测硬件状态
    .not_ready:
	; 同一端口,写时表示写入命令字,读时表示读入硬盘状态
	nop					; 不做任何事情,填充下
	in al, dx			; 从端口读取数据
	and al, 0x88		; 第3位为1表示硬盘控制器已准备好数据传输
				; 第7位为1表示硬盘忙
	cmp al, 0x08		; 相等时ZF被置1  大于CF 1  小于SF 1
	jnz .not_ready		; 若未准备好,继续等

; 第5步:从0x1f0端口读数据
	mov ax, di
	mov dx, 256
	mul dx
	mov cx, ax
; di为要读取的扇区数,一个扇区有512字节,每次读入一个字
; 共需 di*512/2 次,所以di*256
	
	mov dx, 0x1f0
    .go_on_read:
	in ax, dx
	mov [bx], ax
	add bx, 2
	loop .go_on_read
	ret

	times 510-($-$$) db 0	; $代表当前位置指令的地址, $$代表当前节段的起始地址
				; MBR 的最后两字节是固定的 0x55 0xaa 牵引扇区签名
	db 0x55,0xaa

