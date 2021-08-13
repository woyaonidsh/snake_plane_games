.386
.model flat,stdcall
option casemap:none
include C:/masm32/include/msvcrt.inc
includelib msvcrt.lib
include C:/masm32/include/winmm.inc   ;timeGetTime函数头文件
includelib winmm.lib


printf proto C :ptr byte,:vararg
scanf  proto C :ptr byte,:vararg
_kbhit  proto C
_getch proto C
_sleep proto C:dword
;gui
srand proto C:dword
rand proto C
time proto C:dword
system proto C:ptr sbyte

.data
HEIGHT equ 20
WEIGHT equ 18
temp equ WEIGHT+2
Graph byte (HEIGHT+2)dup((WEIGHT+2)dup(0))
bottom DD 1
right DD 0
left DD 0
score DD 0
endGame DD 0
init DD 0
block DW 2222h,0F000h,
	6600h,
	2700h,2320h,0720h,2620h, 
	3600h,8C40h,
	0C600h,4C80h,
	4460h,7400h,6220h,2E00h,
	2260h,8E00h,6440h,7100h
blockpos DB 0,3,2,2 ;I
		 DB 0,0,0,3
		 DB 0,1,1,2 ;O
		 DB 0,1,1,3 ;T
		 DB 0,2,2,3
		 DB 1,2,1,3
		 DB 0,2,1,2
		 DB 0,1,1,3
		 DB 0,2,0,1
		 DB 0,2,1,2
		 DB 0,1,1,3
		 DB 0,2,1,2
		 DB 0,1,0,2
		 DB 0,2,1,2
		 DB 0,1,0,2
		 DB 0,2,1,2
		 DB 0,1,1,3
block_state STRUC  8
	typenum dd ?
	top dd ?
	bot dd ?
	left dd ?
	right dd ?
	emp1 dd ?
	emp2 dd ?
	emp3 dd ?
block_state ENDS
nowBlock block_state <>
chget byte 0
msgch byte '%c',0
msgscore byte '得分：%d',0ah,0
msgend byte '游戏结束',0ah,0
wall byte '■',0
blockSign byte '□',0 ;如果方格是下落物体，打印这个
emptySign byte '  ',0 ;如果方格没有东西，则打印这个
enterSign byte 0ah,0
msgright byte 'yes',0ah,0
clearScreen byte 'cls',0
;I型随机有问题
;
.code
initPaint proc C
;错误
  LOCAL i:dword
  LOCAL j:dword
L0:  
	  mov i,0
	  jmp L2
L1:
	inc i
L2:
	  cmp i,14h
	  jge L4
L3:
	  mov ecx,i
	  mov Graph[ecx],1
	  mov Graph[(HEIGHT+1)*(WEIGHT+2)+ecx],1
	  jmp L1
L4:  
	  mov i,0
	  jmp L6
L5:
	inc i
L6:
	  cmp i,16h
	  jge L8
L7:
	  mov eax,WEIGHT+2
	  mov ebx,i
	  mul ebx
	  mov Graph[eax+0],1
	  mov Graph[eax+WEIGHT+1],1
	  jmp L5
L8:

 ret
initPaint endp
;gui
randomType proc C
	LOCAL ran:dword,number:dword
	mov ebx,offset nowBlock
	xor ebx,ebx
	xor eax,eax
	invoke time,0
	invoke srand,eax
	invoke rand
	mov bx,20
	div bx ;dx里存放rand结果
	mov eax,edx
	AND eax,00FFh
	mov nowBlock.typenum,eax
	;mov nowBlock.typenum,3
	mov nowBlock.top,1
	mov nowBlock.bot,4
findRand:
	invoke time,0
	invoke srand,eax
	invoke rand
	mov bx,WEIGHT
	div bx
	mov ax,dx
	AND eax,00FFh
	mov ran,eax
	cmp ran,1
	jb findRand ;ran<1
	mov eax,WEIGHT-2
	cmp ran,eax
	jae findRand ;ran+3>=weight+1
	mov eax,ran
	mov nowBlock.left,eax
	ADD eax,3
	mov nowBlock.right,eax
	ret
randomType endp

rotate proc C
LOCAL reLeft,reTop,reType:dword
		LOCAL flag,shiftNum:dword
		LOCAL i,j:dword

		mov flag,0
		mov shiftNum,0

		mov ebx,nowBlock.typenum
		
		cmp ebx,1
		jle type0

		cmp ebx,2
		jle type1

		cmp ebx,6
		jle type2

		cmp ebx,8
		jle type3

		cmp ebx,10
		jle type4
		
		cmp ebx,14
		jle type5

		cmp ebx,18
		jle type6

type0:
		mov eax,1
		sub eax,nowBlock.typenum
		mov reType,eax
		jmp L0
type1:
		mov eax,nowBlock.typenum
		mov reType,eax
		jmp L0
type2:
		mov eax,nowBlock.typenum
		sub eax,2
		xor edx,edx
		mov ebx,4
		div ebx
		add edx,3
		mov reType,edx
		jmp L0
type3:
		mov eax,15
		sub eax,nowBlock.typenum
		mov reType,eax
		jmp L0
type4:
		mov eax,19
		sub eax,nowBlock.typenum
		mov reType,eax
		jmp L0
type5:
		mov eax,nowBlock.typenum
		sub eax,10
		xor edx,edx
		mov ebx,4
		div ebx
		add edx,11
		mov reType,edx
		jmp L0
type6:
		mov eax,nowBlock.typenum
		sub eax,14
		xor edx,edx
		mov ebx,4
		div ebx
		add edx,15
		mov reType,edx
		jmp L0
L0:
		mov eax,4
		mov ebx,reType
		mul ebx
		mov bl,blockpos[eax+2]
		mov eax,nowBlock.left
		add eax,ebx
		mov reLeft,eax

		mov eax,4
		mov ebx,reType
		mul ebx
		mov bl,blockpos[eax+0]
		mov eax,nowBlock.top
		add eax,ebx
		mov reTop,eax

		mov eax,nowBlock.top
		mov i,eax
		jmp L2
L1:
		inc i
L2:
		cmp flag,0
		jnz L10

		mov eax,4
		mov ebx,reType
		mul ebx
		mov bl,blockpos[eax+1]
		mov eax,nowBlock.top
		add eax,ebx
		cmp j,eax
		jg L10
L3:
		mov eax,nowBlock.left
		mov j,eax
		jmp L5
L4:
		inc j
L5:
		mov eax,4
		mov ebx,reType
		mul ebx
		mov bl,blockpos[eax+3]
		mov eax,nowBlock.left
		add eax,ebx
		cmp j,eax
		jg L9
L6:
		mov eax,nowBlock.top-1
		add eax,4
		sub eax,i
		mov ebx,4
		mul ebx
		mov ecx,eax

		mov eax,nowBlock.left-1
		add eax,4
		sub eax,i

		add ecx,eax
		mov shiftNum,ecx

		mov eax,reType
		mov ax,block[eax]
		shr eax,cl
		and eax,1
		cmp eax,1
		jnz L8

		mov eax,WEIGHT+2
		mov ebx,i
		mul ebx
		mov ebx,j
		sub ebx,1
		cmp Graph[eax+ebx],2
		jnz L8
L7:
		mov flag,1
		jmp L1
L8:
		jmp L4
L9:
		jmp L1
L10:
		cmp flag,0
		jnz L12
L11:
		mov eax,reType
		mov nowBlock.typenum,eax
L12:
		ret
rotate endp


;gui
freshPaint proc C
	LOCAL i:DWORD,j:DWORD
	LOCAL iline:DWORD
	LOCAL shiftNum:DWORD

	invoke system,offset clearScreen
	xor eax,eax
	mov i,eax
	mov j,eax
	mov shiftNum,eax
	mov iline,eax
	

outLoopJudge:
	cmp i,HEIGHT+2
	jae endPrint

	xor ebx,ebx
inLoopJudge:
	cmp ebx,WEIGHT+2
	jae inLoopEnd

	mov eax,iline
	cmp Graph[eax][ebx],1
	jnz situation2
	push ebx
	invoke printf,offset wall
	pop ebx
	jmp inLoopAdd

situation2:
	mov eax,iline
	cmp Graph[eax][ebx],2
	jnz otherS
	push ebx
	invoke printf,offset blockSign
	pop ebx
	jmp inLoopAdd
otherS:
	;(i>=nowBlock.top&&i<=nowBlock.bot&&j>=nowBlock.left&&j<=nowBlock.right
	mov eax,nowBlock.top
	cmp i,eax
	jb default

	mov eax,nowBlock.bot
	cmp i,eax
	ja default

	cmp ebx,nowBlock.left
	jb default
	cmp ebx,nowBlock.right
	ja default

	xor eax,eax
	add eax,4-1
	add eax,nowBlock.top
	sub eax,i
	mov cl,2
	SHL eax,cl

	add eax,4-1
	add eax,nowBlock.left
	sub eax,ebx
	mov shiftNum,eax

	mov ecx,nowBlock.typenum
	mov ax,block[ecx]
	mov ecx,shiftNum
	SHR eax,cl
	AND eax,1
	cmp eax,1
	jnz default
	push ebx
	invoke printf,offset blockSign
	pop ebx
	jmp inLoopAdd

default:
	push ebx
	invoke printf,offset emptySign
	pop ebx

inLoopAdd:
	inc ebx
	jmp inLoopJudge

inLoopEnd:

	mov eax,WEIGHT+2
	add dword ptr[iline],eax

	mov eax,1
	add i,eax

	push ebx
	invoke printf,offset enterSign
	pop ebx

	jmp outLoopJudge

endPrint:
	invoke printf,offset msgscore,score
	cmp endGame,1
	jnz procend
	invoke printf,offset msgend
procend:
	ret
freshPaint endp

fullRelease proc C
	LOCAL i,j:dword
	LOCAL movei,movej:dword
	LOCAL flag:dword

	mov flag,0
L0:  
	mov i,HEIGHT
	jmp L2
L1:
	dec i
L2:
	cmp i,1
	jle L23
L3:
	mov flag,0
L4:
	mov j,1
	jmp L6
L5:
	inc j
L6:
	cmp j,WEIGHT+1
	jge L9
L7:
	mov eax,WEIGHT+2
	mov ebx,i
	mul ebx
	mov ebx,j

	cmp Graph[eax+ebx],2
	jz L8

	mov flag,1
L8:
	jmp L5
L9:
	cmp flag,0
	jnz L22

	inc score
L10:
	mov movej,1
	jmp L11
L11:
	inc movej
L12:
	cmp movej,WEIGHT+1
	jg L14
L13:
	mov eax,WEIGHT+2
	mov ebx,i
	mul ebx
	mov ebx,j
	mov Graph[eax+ebx],0
	jmp L11
L14:
	mov eax,i-1
	mov movei,eax
	jmp L16
L15:
	dec movei
L16:
	cmp movei,1
	jle L22
L17:
	mov movej,1
	jmp L19
L18:
	inc movej
L19:
	cmp movej,WEIGHT+1
	jg L21
L20:
	mov eax,WEIGHT+2
	mov ebx,movei
	mul ebx
	mov ebx,movej
	mov cl,Graph[eax+ebx]

	mov eax,WEIGHT+2
	mov ebx,movei+1
	mul ebx
	mov ebx,movej
	mov Graph[eax+ebx],cl

	jmp L18
L21:	
	jmp L15
L22:
	jmp L1
L23:
	mov i,1
	jmp L25
L24:
	inc i
L25:
	cmp i,WEIGHT
	jge L28
L26:
	mov eax,i
	cmp Graph[(WEIGHT+2)+eax],2
	jnz L27

	mov flag,2
	jmp L28
L27:
	jmp L24
L28:
	cmp flag,2
	jnz L29
	cmp init,0
	jz L29
	mov endGame,1
L29:
	ret
fullRelease endp

moveDirect proc C
LOCAL shiftNum:DWORD
LOCAL i,j,flag:DWORD
	mov shiftNum,0

	mov bl,chget
	cmp bl,'a'
	jz typeL
	cmp bl,'A'
	jz typeL

	cmp bl,'d'
	jz typeR
	cmp bl,'D'
	jz typeR

	cmp bl,'s'
	jz typeQ
	cmp bl,'S'
	jz typeQ
	
	cmp bl,'w'
	jz typeC
	cmp bl,'W'
	jz typeC


typeL:
		xor eax,eax
		xor ebx,ebx
		xor ecx,ecx
		mov eax,4
		mov ebx,nowBlock.typenum
		mul ebx
		mov bl,blockpos[eax+2]
		mov eax,nowBlock.left
		add eax,ebx

		cmp eax,1
		jg L1
L0:
		jmp endCase
L1:
		mov flag,0

		mov eax,nowBlock.left
		mov j,eax
		jmp L3
L2:
		inc j
L3:
		mov eax,nowBlock.right
		cmp j,eax
		jg L11
L4:
		mov eax,4
		mov ebx,nowBlock.typenum
		mul ebx
		mov bl,blockpos[eax+0]
		mov eax,nowBlock.top
		add eax,ebx
		mov i,eax
		jmp L6
L5:
		inc i
L6:
		mov eax,4
		mov ebx,nowBlock.typenum
		mul ebx
		mov bl,blockpos[eax+1]
		mov eax,nowBlock.top
		add eax,ebx

		cmp i,eax
		jg L10

		cmp flag,0
		jnz L10
L7:
		mov eax,nowBlock.top
		add eax,4
		sub eax,i
		sub eax,1

		mov ebx,4
		mul ebx
		mov ecx,eax

		mov eax,nowBlock.left
		add eax,4
		sub eax,i
		sub eax,1

		add ecx,eax
		mov shiftNum,ecx
		
		mov eax,nowBlock.typenum
		mov ax,block[eax]
		sar eax,cl
		and eax,1
		cmp eax,1
		jnz L9

		mov eax,WEIGHT+2
		mov ebx,i
		mul ebx
		mov ebx,j
		sub ebx,1

		cmp Graph[eax+ebx],2
		jnz L9
L8:
		mov flag,1
		jmp L2
L9:
		jmp L5
L10:
		jmp L2
L11:
		cmp flag,0
		jnz L13
L12:
		dec nowBlock.right
		dec nowBlock.left
L13:
		jmp endCase


typeR: ;右侧
		xor eax,eax
		xor ebx,ebx
		xor ecx,ecx
		mov eax,4
		mov ebx,nowBlock.typenum
		mul ebx
		mov bl,blockpos[eax+3]
		mov eax,nowBlock.left
		add eax,ebx
		cmp eax,WEIGHT
		jl R1
R0:
		jmp endCase
R1:
		mov flag,0
		mov eax,nowBlock.left
		mov j,eax
		jmp R3
R2:
		inc j
R3:
		mov eax,nowBlock.right
		cmp j,eax
		jg R11
R4:
		mov eax,4
		mov ebx,nowBlock.typenum
		mul ebx
		mov bl,blockpos[eax+0]
		mov eax,nowBlock.top
		add eax,ebx
		mov i,eax
		jmp R6
R5:
		inc i
R6:
		mov eax,4
		mov ebx,nowBlock.typenum
		mul ebx
		mov bl,blockpos[eax+1]
		mov eax,nowBlock.top
		add eax,ebx

		cmp i,eax
		ja R10

		cmp flag,0
		jnz R10
R7:
		mov eax,nowBlock.top
		add eax,4
		sub eax,i
		sub eax,1

		mov ebx,4
		mul ebx
		mov ecx,eax

		mov eax,nowBlock.left
		add eax,4
		sub eax,j ;这错了
		sub eax,1

		add ecx,eax
		mov shiftNum,ecx
		
		mov eax,nowBlock.typenum
		mov ax,block[eax]
		sar eax,cl
		and eax,1
		cmp eax,1
		jnz R9

		mov eax,WEIGHT+2
		mov ebx,i
		mul ebx
		mov ebx,j
		inc ebx
		cmp Graph[eax+ebx],2
		jnz R9
R8:
		mov flag,1
		jmp R2
R9:
		jmp R5
R10:
		jmp R2
R11:
		cmp flag,0
		jnz R13
R12:
		inc nowBlock.right
		inc nowBlock.left
R13:
		jmp endCase

typeQ:
		;+blockpos[nowBlock.type][1]
		mov eax,4
		mov ebx,nowBlock.typenum
		mul bx
		mov ecx,eax
		add ecx,1
		mov al,blockpos[ecx]
		;+nowBlock.bot
		add eax,nowBlock.bot
		;-3
		sub eax,3
		cmp eax,HEIGHT
		jb Q10
;if
		;i=nowBlock.top
		mov eax,nowBlock.top
		mov i,eax
		jmp Q1
Q0:
		inc i
Q1:
		cmp i,HEIGHT+2
		jge Q9
		;i>nowBlock.bot
		mov eax,nowBlock.bot
		cmp i,eax
		jg Q9
Q2:
		mov eax,nowBlock.left
		mov j,eax
		jmp Q4
Q3:
		inc j
Q4:
		cmp j,WEIGHT+2
		jge Q8

		mov eax,nowBlock.right
		cmp j,eax
		jg Q8
Q5:
		mov eax,nowBlock.top
		add eax,3
		sub eax,i

		mov ebx,4
		mul bx

		add eax,nowBlock.left
		add eax,4
		sub eax,j
		sub eax,1

		mov shiftNum,eax
		mov ecx,shiftNum
		mov ebx,nowBlock.typenum
		mov ax,block[ebx]
		shr eax,cl ;SAR不对，因为不能当作带符号数处理
		AND eax,1
		cmp eax,1
		jnz Q7
Q6:
		mov eax,WEIGHT+2
		mov ebx,i
		mul bx
		mov ebx,j
		mov Graph[eax+ebx],2 
Q7:
		jmp Q3
Q8:
		jmp Q0
Q9:
		mov bottom,1
		jmp endCase

;else
Q10:
		mov flag,0
		mov i,0
		mov j,0
Q11: ;i=nowBlock.top+blockpos[nowBlock.type][0]
		mov eax,4
		mov ebx,nowBlock.typenum
		mul bx
		mov bl,blockpos[eax+0]
		mov eax,nowBlock.top
		add eax,ebx
		mov i,eax
		jmp Q13
Q12:
		inc i
Q13:    ;i<=nowBlock.top+blockpos[nowBlock.type][1]
		mov eax,4
		mov ebx,nowBlock.typenum
		mul ebx
		mov bl,blockpos[eax+1]
		mov eax,nowBlock.top
		add eax,ebx

		cmp i,eax
		jg Q21
		;!flag
		cmp flag,0
		jnz Q21
Q14:
		mov eax,nowBlock.left
		mov j,eax
Q15:
		inc j
Q16:
		mov eax,nowBlock.right
		cmp j,eax
		jg Q20
Q17:
		mov eax,nowBlock.top
		add eax,3
		sub eax,i

		mov ebx,4
		mul bx

		add eax,nowBlock.left
		add eax,4
		sub eax,j
		sub eax,1
		;(block[nowBlock.type]>>shiftNum)&1 == 1
		mov shiftNum,eax
		mov ecx,shiftNum
		mov ebx,nowBlock.typenum
		mov ax,block[ebx]
		shr eax,cl
		and eax,1
		cmp eax,1
		jnz Q19
		;Graph[i+1][j]==2
		mov eax,WEIGHT+2
		mov ebx,i
		inc ebx
		mul bx
		mov ebx,j
		cmp Graph[eax+ebx],2
		;!=2跳转到j++
		jnz Q19
Q18:;flag=1;break;
		mov flag,1
		jmp Q21
Q19:
		jmp Q15
Q20:
		jmp Q12

Q21:
		cmp flag,1
		jnz Q32
;if		;i=nowBlock.top
		mov eax,nowBlock.top
		mov i,eax
		jmp Q23
Q22:
		inc i
Q23:
		mov eax,nowBlock.bot
		cmp i,eax
		jg Q31
Q24:	;j=nowBlock.left
		mov eax,nowBlock.left
		mov j,eax
		jmp Q26
Q25:
		inc j
Q26:
		mov eax,nowBlock.right
		cmp j,eax
		jg Q30
Q27:
		mov eax,nowBlock.top
		add eax,4
		sub eax,i
		sub eax,1

		mov ebx,4
		mul bx

		add eax,nowBlock.left
		add eax,4
		sub eax,j
		sub eax,1

		mov shiftNum,eax
		mov ecx,shiftNum

		mov ebx,nowBlock.typenum
		mov ax,block[ebx]
		shr eax,cl
		and eax,1
		cmp eax,1
		jnz Q29
Q28:
		mov eax,WEIGHT+2
		mov ebx,i
		mul ebx
		mov ebx,j
		mov Graph[eax+ebx],2
Q29:
		jmp Q25
Q30:
		jmp Q22
Q31:;每次bottom很奇怪
		mov eax,1
		mov dword ptr[bottom],eax
		jmp endCase
;else
Q32:
		inc nowBlock.top
		inc nowBlock.bot
		;mov eax,1
		;mov dword ptr[init],eax
		jmp endCase

typeC:
		invoke rotate
		jmp endCase

endCase:
		invoke fullRelease
		ret
moveDirect endp

start:
	xor eax,eax
	mov score,eax
	mov eax,1
	mov bottom,eax
	mov ebx,offset Graph
	invoke initPaint
	;invoke printf,offset msgright
	invoke freshPaint
inLoop:
	cmp dword ptr[endGame],1
	jz endLoop
	cmp dword ptr[bottom],1
	jnz findChar
	;invoke printf,offset msgright
	invoke randomType
	;invoke printf,offset msgright
	mov eax,0
	mov dword ptr[bottom],eax
findChar:
	invoke _kbhit
	cmp eax,0
	jz autoDown ;==0
	invoke _getch
	mov byte ptr[chget],al
	invoke moveDirect
	;
	jmp freshPic
autoDown:
	invoke _sleep,200
	mov al,'S'
	mov byte ptr[chget],al
	invoke moveDirect
freshPic:
	invoke freshPaint
	
	jmp inLoop
endLoop:
	invoke _getch
	ret
end start