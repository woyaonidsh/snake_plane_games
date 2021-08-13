.386
.model flat, stdcall
option casemap:none
includelib msvcrt.lib
printf PROTO C :ptr sbyte, :VARARG

.data
height byte 00H		;������ʾ��ʽΪ320*200��ɫͼ�η�ʽ
width byte 04H

.code
start:
        mov ah,height		;������ʾ��ʽΪ320*200��ɫͼ�η�ʽ
        mov al,width
        int 10H
;��ˮƽֱ��
;��ڲ��� CX�൱��X0 DX�൱��Y0,Y1 siͼ�񳤶� BL����

sp_line proc
         pusH ax
         pusH bx
         MOV BL,2    ;�ɻ�����ɫ
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

;//����ҷɻ��ӳ��� �������bx���÷ɻ���ˮƽλ�� BP���÷ɻ��Ĵ�ֱλ��   BX,BP��¼�ɻ���λ��
play_plane proc    
	push cx
	push dx
	push es
	push si
	push di
	push ax
	jmp sk

play_plane_1: dw 6,1,1,5,2,3,5,3,3,5,4,3,4,5,5,3,6,7,1,7,11,1,8,11,4,9,5,5,10,3,4,11,5,3,12,7,4,13,2,7,13,2 ;X0,Y,����

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
        mov si,word ptr es:[play_plane_1+di+4]    ;����
        
     	call sp_line
     	add di,6
     	cmp di,84
     	jne lop2
     	
	;plane_pos���ڼ�¼�ɻ���λ�ã��˴����·ɻ�λ��
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

;��ˮƽֱ��
;��ڲ��� CX�൱��X0 DX�൱��Y0,Y1 siͼ�񳤶� BL����
sp_line1 proc
         pusH ax
         pusH bx
         pusH bp
         pusH di
     	 MOV bp,CX
      
         MOV di,11
         MOV BL,0    ;�ɻ�����ɫ ��������ԭ���ķɻ�
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


play_plane1 proc ;�����ɻ��켣�ӳ��� �������CX,DX
     
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

;//�����ӵ��ӳ���
;��ڲ��� ��ҷɻ�����ڵ�����bx+5,bp
shoot_plane proc
	push ax
	push bx
	push cx
	push dx
	push si
	push bp
	mov cx,bx
 	add cx,5	;x����BX+5
	mov dx,bp	;y����	
	dec	dx
	;�����ڵ��켣���ƶ��ڵ�
a0:	MOV BX,2	;���
	INC DX
a1:	MOV AH,0CH	;�ڻ�ͼģʽ��ʾһ��
	MOV AL,0	;��ɫ(��ɫ)�����ڲ�����һ���ӵ�	
	INT 10H
	INC CX
	DEC BX
	JNZ a1		;�����ڵ����
 	SUB CX,2
	MOV BX,2
	DEC DX
	
a2:	MOV AH,0CH	;�ڻ�ͼģʽ��ʾһ��
	MOV AL,11	;��ɫ����ɫ�������ڻ����ӵ�	
	INT 10H
	INC CX
	DEC BX
	JNZ a2		;�����ڵ����
 	SUB CX,2
	CALL delay<span style="white-space:pre">	</span>;ʱ�ӣ������������ӵ����ƶ��ٶ�
	DEC DX
	CMP DX,6	;ѭ�����ڵ�,�����˲�ֹͣ
	JA a0
notdes:	
	;���һ�β���
	mov bp,sp
	mov cx,word ptr ss:[bp+8]
	add cx,5
	mov dx,7
	MOV AH,0CH	;�ڻ�ͼģʽ��ʾһ��
	MOV AL,0	;��ɫ	
	INT 10H
	inc cx
	MOV AH,0CH	;�ڻ�ͼģʽ��ʾһ��
	MOV AL,0	;��ɫ	
	INT 10H
	pop bp
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
shoot_plane endp

 mov al,34h   ; �������ֵ 
    	out 43h,al   ; д�����ֵ������ּĴ��� 
    	mov ax,0ffffh ; �ж�ʱ������
    	out 40h,al   ; д������ 0 �ĵ��ֽ� 
    	mov al,ah    ; AL=AH 
    	out 40h,al   ; д������ 0 �ĸ��ֽ� 


	xor ax,ax			; AX = 0
	mov ds,ax			; DS = 0
	mov word ptr ds:[20h],offset Timer	; ����ʱ���ж�������ƫ�Ƶ�ַ
	mov ax,cs 
	mov word ptr ds:[22h],ax		; ����ʱ���ж������Ķε�ַ=CS

lop3: 
      	call play_plane1	;�����ɻ��켣
      	call play_plane		;���ɻ�		
      	mov cx,bx
      	mov dx,bp
again:		
	mov ah,01      ;����Ƿ��а�����û�еĻ�ѭ�����
	int 16h
	jz again		;û�а�������ʾ�ƶ����ٴμ��
        ;�Ӽ��̶����ַ�          
      	mov ah,0H	
      	int 16H
	 	  
        ;�ж��ַ�
      	cmp ah,72
      	je up
      	cmp ah,80
      	je down
      	cmp ah,75
      	je left
      	cmp ah,77
      	je right
	cmp ah,57	;�ո�
	je shoot
      	cmp ah,16	;Q�˳�
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

;�˳�����
quite:   
	mov ah,4ch
	int 21h
    


Timer:
	push ax
	mov al,byte ptr ds:[timecontrol]   ;timecontrolΪ�趨�ĵ����ƶ��ٶ�
	cmp byte ptr ds:[delay_timer],al   ;delay_timer����timecontrolʱ���ƶ�����,���򱾴��жϲ����κ���
	pop ax
	jnz	goout
	mov byte ptr ds:[delay_timer],0
	call move_smile
	call play_smile		;��Ц��
goout:
	inc byte ptr [delay_timer]
	push ax
	mov al,20h			; AL = EOI
	out 20h,al			; ����EOI����8529A
	out 0A0h,al			; ����EOI����8529A
	pop ax
	iret			; ���жϷ���



end start