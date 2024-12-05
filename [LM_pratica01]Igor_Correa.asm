	; nasm -f elf64 [LM_pratica01]Igor_Correa.asm ; ld [LM_pratica01]Igor_Correa.o -o [LM_pratica01]Igor_Correa.x
	
	%define maxChars 3
	%define createopenw  101o ; flag open() - criar + escrita
	%define userWR 644o       ; Read+Write+Execute: -rw-r--r--
	
	section .data
   	strOla : db "Digite o n-esimo numero padovan buscado: "
   	strOlaL: equ $ - strOla
	
   	strBye : db "Falha, tamanho incorreto"
   	strByeL: equ $ - strBye
	
   	strLF  : db 10 ; quebra de linha
   	strLFL : equ 1
   	
   	;Variaveis usadas no padovan
   	n0 : dq 1
   	n1 : dq 1
   	n2 : dq 1
   	n3 : dq 2
   	p  : dq 2
   	
   	fileName1 : db "p(", 10 ;
   	fileName2: db ").bin", 10
   	
	
	
	section .bss
   	strLida   : resb maxChars ;string lida 
   	strLidaL : resd 1
   	strBuffer : resb 1 ;variavel para limpar o buffer
   	numerolido : resd 1 ;variavel para armazenar a string transformada em numero
   	fileHandle : resd 1 ;variavel para manejar o arquivo
   	fileNameFinal: resb 20
	
	
	section .text
   	global _start
	
	_start:
   	; ssize_t write(int fd , const void *buf, size_t count);
   	; rax     write(int rdi, const void *rsi, size_t rdx  );
   	mov rax, 1  ; WRITE
   	mov rdi, 1  ; STDOUT
   	lea rsi, [strOla]
   	mov edx, strOlaL
   	syscall
	
	leitura:
   	; Prepara o buffer e a quantidade de bytes a serem lidos
   	mov dword [strLidaL], maxChars
	
   	; ssize_t read(int fd , const void *buf, size_t count);
   	; rax     read(int rdi, const void *rsi, size_t rdx  );
   	mov rax, 0  ; READ
   	mov rdi, 0  ; STDIN
   	lea rsi, [strLida]
   	mov edx, [strLidaL]
   	syscall
   	
   	; Salva o número de bytes realmente lidos
    	mov [strLidaL], rax
		cmp rax, 1
		je falha
		lea rsi, [strLida]
   		mov eax, [strLidaL]
   		cmp byte [strLida + eax-1], 10
   		je conversao
	
	limparbuffer: 
    	preBloco:               
        	cmp byte [strBuffer], 10 ;enquanto nao for /n, continuar limpando o buffer
        	je falha
    	blocoFor:
        	mov rax, 0
        	mov rdi, 1
        	lea rsi, [strBuffer]
        	mov edx, 1
        	syscall
        	jmp preBloco
	
         	
		
	falha:
   	mov rax, 1  ; WRITE
   	mov rdi, 1  ; STDOUT
   	lea rsi, [strBye] ;print de falha "Falha, tamanho incorreto"
   	mov edx, strByeL
   	syscall
  	
   	mov rax, 1  ; WRITE
   	mov rdi, 1  ; STDOUT
   	lea rsi, [strLF] ;\n
   	mov edx, strLFL
   	syscall
   	jmp fim
	
	conversao:
		lea rsi, [strLida] ;preparar para entrar no loop
		mov eax, 0
		mov ecx, 0
	
	loop_convert:
		mov bl, [esi] ;se for \n, pular pra o fim
		cmp bl, 10
		je fim_conversao
		
		;se nao for \n
		sub bl, '0' ;transformar o caractere em inteiro
		mov ecx, 10 ; multiplicar o numero que ja esta no eax por 10
		mul ecx
		add eax, ebx ; somar o novo caractere
		
		inc esi ; ir para a proxima posicao
		jmp loop_convert
		
	fim_conversao:
		mov [numerolido], eax	
	
	start_padovan: ;setar as variaveis de forma inicial
		cmp eax, 3 ; se for um dos primeiros 3 numeros, será ou 1 ou 2, dependendo da label que for utilizada
		jl padovan_0 
		je padovan_2
		mov ebx, 3
		mov r8, [n0]
		mov r9, [n1]
		mov r10, [n2]
		mov r11, [n3]
		mov r12, [p]
		
	padovan:
		mov r12, r9
		add r12, r10
		mov r8, r9
		mov r9, r10
		mov r10, r11
		mov r11, r12
		inc ebx
		cmp ebx, eax
		jl padovan
		mov [p], r12
		jmp arquivo ;apos terminar o calculo, ir para o arquivo
		
	padovan_0:
		mov  qword [p], 1
		jmp arquivo
	
	padovan_2:
		mov  qword [p], 2
		jmp arquivo
		
	arquivo:
	
	;Criar o nome do arquivo
		xor rcx, rcx
		xor ebx, ebx
		xor r8, r8
		
		file1: ;copiar "p(" para o nome
			mov sil, [fileName1 + rcx]
			cmp sil, 10
			je file2
			mov [fileNameFinal+rcx], sil
			inc rcx
			jmp file1
		
		file2: ;Copiar o a str do input para o nome
			mov sil, [strLida+ebx]
			cmp sil, 10
			je file3
			mov [fileNameFinal+rcx], sil
			inc ebx
			inc rcx
			jmp file2
			
		file3: ;Copiar o ").bin" para o nome
			mov sil, [fileName2 + r8]
			cmp sil, 10
			je fileopen
			mov [fileNameFinal+rcx], sil
			inc rcx
			inc r8
			jmp file3
			
	
	fileopen:
		mov rax, 2          ; open file
    	lea rdi, [fileNameFinal] ; *pathname
    	mov esi, createopenw; flags
    	mov edx, userWR    ; mode
    	syscall
    	mov [fileHandle], eax
    	
    	mov rax, 1  ; WRITE
    	mov rdi, [fileHandle]
    	lea rsi, [p]
    	mov edx, 8
    	syscall
    	
   	
    	mov rax, 3  ; fechar arquivo
    	mov edi, [fileHandle]
    	syscall
		
	
	fim:
   	; void _exit(int status);
   	; void _exit(int rdi   );
   	mov rax, 60
   	mov rdi, 0
   	syscall
	
