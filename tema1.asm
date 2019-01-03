%include "io.inc"

section .data
	%include "input.inc"

section .text
global CMAIN
CMAIN:
	mov ebp, esp

	xor ecx,ecx

convert:
	; ecx -> pozitia elementului curent din vector
	cmp ecx,[nums]
	jz exit

	; testarea corectitudinii bazei
	cmp word[base_array+ecx*4],16
	ja bazagresita
	cmp word[base_array+ecx*4],2
	jb bazagresita

	xor eax,eax
	xor edi,edi
	xor edx,edx

	; impartirea la un numar de 32 de biti
	; eax -> deimpartitul, elementul de pe pozitia curenta din vector
	; ebx -> impartitorul, baza in care trebuie convertit elementul
	; edx -> restul impartirii
	; eax -> catul impartirii
	mov eax,dword[nums_array+ecx*4]

	mov ebx,dword[base_array+ecx*4]
	div ebx

	; daca edx este un numar natural din intervalul [0,9]
	; adaugam la codul sau ASCII doar 48
	; daca edx este un numar natural din intervalul [10,15]
	; adaugam la codul sau ASCII inca 39, adica in total 87
	add edx,48
	cmp edx,57
	ja numb_10_15
	jbe printedx

numb_10_15:
	add edx,39

	; punem restul impartirii pe stiva
	; edi -> numarul de push-uri
printedx:
	xor esi,esi
	mov esi,edx
	push esi
	inc edi

	; daca catul impartirii precedente a fost 0 am terminat conversia
	cmp eax,0
	jz inc_ecx

	; daca catul impartirii precedente poate fi reprezentat pe
	; cel mult 16 biti, impartim la un numar de 16 biti, altfel 
	; repetam impartirea la un numar de 32 de biti
	cmp eax,65535
	jbe div_16_biti
	ja repet_div_32_biti

repet_div_32_biti:
	xor edx,edx

	mov ebx,dword[base_array+ecx*4]
	div ebx

	add edx,48
	cmp edx,57
	ja numbers_10_15
	jbe print_again_edx

numbers_10_15:
	add edx,39

print_again_edx:
	xor esi,esi
	mov esi,edx
	push esi
	inc edi

	cmp eax,0
	jz inc_ecx

	cmp eax,65535
	jbe div_16_biti
	ja repet_div_32_biti

	; impartirea la un numar de 16 biti
	; ax -> partea inferioara a deimpartitului
	; dx -> partea superioara a deimpartitului
	; bx -> impartitorul
	; dx -> restul
	; ax -> catul
div_16_biti:
	xor edx,edx
	mov edx,eax
	shr edx,16
	
	mov bx,word[base_array+ecx*4]
	div bx
	
	; repetam ce am facut anterior pentru restul pe 32 de biti
	; pentru restul curent reprezentat pe 16 biti
	add dx,48
	cmp dx,57
	ja num_10_15
	jbe printdx

num_10_15:
	add dx,39

	; punem restul pe stiva
printdx:
	xor esi,esi
	movzx esi,dx
	push esi
	inc edi

	; testam daca s-a terminat conversia
	cmp ax,0
	jz inc_ecx

	; daca catul poate fi reprezentat pe cel mult 8 biti
	; impartim la un numar de 8 biti, altfel 
	; repetam impartirea la un numar de 16 biti
	cmp ax,255
	jbe div_8_biti
	ja repet_div_16_biti

repet_div_16_biti:
	xor dx,dx
	
	mov bx,word[base_array+ecx*4]
	div bx
	
	add dx,48
	cmp dx,57
	ja numere_interval_10_15
	jbe print_again_dx

numere_interval_10_15:
	add dx,39

print_again_dx:
	xor esi,esi
	movzx esi,dx
	push esi
	inc edi

	cmp ax,0
	jz inc_ecx

	cmp ax,255
	jbe div_8_biti
	ja repet_div_16_biti

	; impartirea la un numar de 8 biti
	; ax -> deimpartitul
	; bx -> impartitorul
	; ah -> restul
	; al -> catul
div_8_biti:
	mov bl,byte[base_array+ecx*4]
	div bl

	; construim reprezentarea in cod ASCII a restului curent
	add ah,48
	cmp ah,57
	ja numere_intre_10_15
	jbe printah

numere_intre_10_15:
	add ah,39	

	; punem restul pe stiva	
printah:
	xor esi,esi
	movzx esi,ah
	push esi
	inc edi
	
	; testam daca s-a terminat conversia sau repetam
	; impartirea la un numar de 8 biti
	cmp al,0
	jnz repet_div_8_biti
	jz inc_ecx

repet_div_8_biti:
	xor ah,ah
	mov bl,byte[base_array+ecx*4]
	div bl
	
	add ah,48
	cmp ah,57
	ja numere_10_15
	jbe afisah

numere_10_15:
	add ah,39	
	
afisah:
	xor esi,esi
	movzx esi,ah
	push esi
	inc edi

	cmp al,0
	jnz repet_div_8_biti

inc_ecx:

	; luam fiecare rest din varful stivei si le afisam, 
	; astfel ca acestea vor fi afisate in ordine inversa;
	; numarul de push-uri este egal cu numarul de pop-uri	
afis:
	dec edi
	pop eax
	PRINT_CHAR eax
	jnz afis		

	; trecem la urmatorul element din vector	
	inc ecx	
	
	; daca elementul curent era ultimul element din vector
	; printam NEWLINE si iesim din program	
	cmp ecx,[nums]
	jnz newline

	cmp ecx,[nums]
	jnz convert
	jz exit

newline:
	NEWLINE
	jmp convert

bazagresita:
	PRINT_STRING "Baza incorecta"
	NEWLINE
	
	inc ecx
	jmp convert

exit:
	xor eax,eax
	ret
