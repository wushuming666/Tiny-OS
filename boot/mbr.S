;2023.5.11
;主引导程序
;直接操作显卡
;----------------------------------
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
	mov byte [gs:0x01],0x20	; A表示绿色背景闪烁, 4表示前景色为红色

	mov byte [gs:0x02],' '
	mov byte [gs:0x03],0x91

	mov byte [gs:0x04],'M'
	mov byte [gs:0x05],0x96
	
	mov byte [gs:0x06],'B'
	mov byte [gs:0x07],0x94

	mov byte [gs:0x08],'R'
	mov byte [gs:0x09],0x94

	jmp $			; 跳转到当前指令的地址, 通过死循环使程序悬停在此

	times 510-($-$$) db 0	; $代表当前位置指令的地址, $$代表当前节段的起始地址
				; MBR 的最后两字节是固定的 0x55 0xaa 牵引扇区签名
	db 0x55,0xaa

