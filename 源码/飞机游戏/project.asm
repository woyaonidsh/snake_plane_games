.386
.model flat, stdcall
option casemap:none
includelib msvcrt.lib
printf PROTO C :ptr sbyte, :VARARG

.data
height byte 00H		;设置显示方式为320*200彩色图形方式
width byte 04H

.code
start:
        mov ah,height		;设置显示方式为320*200彩色图形方式
        mov al,width
        int 10H
;画水平直线
;入口参数 CX相当于X0 DX相当于Y0,Y1 si图像长度 BL像素

sp_line proc
         pusH ax
         pusH bx
         MOV BL,2    ;飞机的颜色
         MOV AH,0cH
         MOV AL,BL
lop:   	 INT 10H
         inc CX
         dec si
         
         jnz lop
         pop bx
         pop ax
         ret
sp_line endp

;//画玩家飞机子程序 传入参数bx设置飞机的水平位置 BP设置飞机的垂直位置   BX,BP记录飞机的位置
play_plane proc    
	push cx
	push dx
	push es
	push si
	push di
	push ax
	jmp sk

play_plane_1: dw 6,1,1,5,2,3,5,3,3,5,4,3,4,5,5,3,6,7,1,7,11,1,8,11,4,9,5,5,10,3,4,11,5,3,12,7,4,13,2,7,13,2 ;X0,Y,长度

sk: 
	mov cx,ax
	mov ax,cs
	mov es,ax
	mov di,0
         
lop2: 
	mov cx,word ptr es:[play_plane_1+di]    ;x0
    add cx,bx
        mov dx,word ptr es:[play_plane_1+di+2]   ;y
        add dx,bp
        mov si,word ptr es:[play_plane_1+di+4]    ;长度
        
     	call sp_line
     	add di,6
     	cmp di,84
     	jne lop2
     	
	;plane_pos用于记录飞机的位置，此处更新飞机位置
	mov ds:[plane_pos],bx
        mov ds:[plane_pos+2],bp 

     	pop ax 
     	pop di
     	pop si
     	pop es
     	pop dx
     	pop cx
   
     	ret
play_plane endp

;画水平直线
;入口参数 CX相当于X0 DX相当于Y0,Y1 si图像长度 BL像素
sp_line1 proc
         pusH ax
         pusH bx
         pusH bp
         pusH di
     	 MOV bp,CX
      
         MOV di,11
         MOV BL,0    ;飞机的颜色 用来擦除原来的飞机
         MOV AH,0cH
         MOV AL,BL
lop1: 	 INT 10H
         inc CX
         dec di
         
         jnz lop1
         MOV CX,bp
         
         pop di
         pop bp
         pop bx
         pop ax
         ret
sp_line1 endp


play_plane1 proc ;擦除飞机轨迹子程序 传入参数CX,DX
     
      push si
      push di
   
      inc cx
      mov si,13
      
      mov di,0
lop5: inc di
      inc dx
      call sp_line1
      cmp di,14
      jne lop5
      pop di
      pop si

      ret
play_plane1 endp

;//发射子弹子程序
;入口参数 玩家飞机发射口的坐标bx+5,bp
shoot_plane proc
	push ax
	push bx
	push cx
	push dx
	push si
	push bp
	mov cx,bx
 	add cx,5	;x坐标BX+5
	mov dx,bp	;y坐标	
	dec	dx
	;擦除炮弹轨迹，移动炮弹
a0:	MOV BX,2	;宽度
	INC DX
a1:	MOV AH,0CH	;在绘图模式显示一点
	MOV AL,0	;颜色(黑色)，用于擦除上一个子弹	
	INT 10H
	INC CX
	DEC BX
	JNZ a1		;擦除炮弹宽度
 	SUB CX,2
	MOV BX,2
	DEC DX
	
a2:	MOV AH,0CH	;在绘图模式显示一点
	MOV AL,11	;颜色（白色），用于画新子弹	
	INT 10H
	INC CX
	DEC BX
	JNZ a2		;画出炮弹宽度
 	SUB CX,2
	CALL delay<span style="white-space:pre">	</span>;时延，可用来调整子弹的移动速度
	DEC DX
	CMP DX,6	;循环画炮弹,到顶端才停止
	JA a0
notdes:	
	;最后一次擦除
	mov bp,sp
	mov cx,word ptr ss:[bp+8]
	add cx,5
	mov dx,7
	MOV AH,0CH	;在绘图模式显示一点
	MOV AL,0	;颜色	
	INT 10H
	inc cx
	MOV AH,0CH	;在绘图模式显示一点
	MOV AL,0	;颜色	
	INT 10H
	pop bp
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
shoot_plane endp

 mov al,34h   ; 设控制字值 
    	out 43h,al   ; 写控制字到控制字寄存器 
    	mov ax,0ffffh ; 中断时间设置
    	out 40h,al   ; 写计数器 0 的低字节 
    	mov al,ah    ; AL=AH 
    	out 40h,al   ; 写计数器 0 的高字节 


	xor ax,ax			; AX = 0
	mov ds,ax			; DS = 0
	mov word ptr ds:[20h],offset Timer	; 设置时钟中断向量的偏移地址
	mov ax,cs 
	mov word ptr ds:[22h],ax		; 设置时钟中断向量的段地址=CS

lop3: 
      	call play_plane1	;擦除飞机轨迹
      	call play_plane		;画飞机		
      	mov cx,bx
      	mov dx,bp
again:		
	mov ah,01      ;检测是否有按键，没有的话循环检测
	int 16h
	jz again		;没有按键，显示移动，再次检测
        ;从键盘读入字符          
      	mov ah,0H	
      	int 16H
	 	  
        ;判断字符
      	cmp ah,72
      	je up
      	cmp ah,80
      	je down
      	cmp ah,75
      	je left
      	cmp ah,77
      	je right
	cmp ah,57	;空格
	je shoot
      	cmp ah,16	;Q退出
      	je quite
      	jmp lop3

up: 	sub bp,3
      	jmp lop3
down: 	add bp,3
      	jmp lop3
left: 	sub bx,3 
       	jmp lop3
right: 	add bx,3
        jmp lop3   

shoot:
	call shoot_plane
	jmp lop3

;退出程序
quite:   
	mov ah,4ch
	int 21h
    


Timer:
	push ax
	mov al,byte ptr ds:[timecontrol]   ;timecontrol为设定的敌人移动速度
	cmp byte ptr ds:[delay_timer],al   ;delay_timer等于timecontrol时才移动敌人,否则本次中断不做任何事
	pop ax
	jnz	goout
	mov byte ptr ds:[delay_timer],0
	call move_smile
	call play_smile		;画笑脸
goout:
	inc byte ptr [delay_timer]
	push ax
	mov al,20h			; AL = EOI
	out 20h,al			; 发送EOI到主8529A
	out 0A0h,al			; 发送EOI到从8529A
	pop ax
	iret			; 从中断返回



end start