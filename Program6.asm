TITLE            (Program6.asm)
;// This program uses stack frames
;//
;// This program will take in as input a four digit hex number
;// from keyboard. A proc will handle the "stuff" to convert it
;// back to its original form (from ascii representation) and pass
;// its value to eax
;//
;//---------------------------DATA SEGMENT-----------------------------
INCLUDE Irvine32.inc		;// Irvine32 library
INCLUDE Macros.inc			;// Irvine32 Macro library

;// Globals
	Base_16 = 16			;// variable to keep base 16 for hex
	Sixteen_Raised_Three = 4096 
	Sixteen_Raised_Two	 = 256
	Sixteen_Raised_One	 = 16 
	Sixteen_Raised_Zero  = 1 
	
.data
;// Variables
	HexNum_ASCII  DWORD 10 DUP(0) ;// Variable that keeps user input
	HexNum_Actual DWORD 0		;// Variable to hold Actual representaion
	count	    DWORD ?	     ;// Count variable 
	decision	    BYTE	?		;// Variable to hold decision

;// Prompts
	Msg1	BYTE "Please enter a four digit hex number below!", 0
	Msg2 BYTE "[PRESS ENTER after input]-----> ", 0
;//---------------------------CODE SEGMENT-----------------------------
.code
;// ***************Prototypes***************
Get_Hex PROTO,				
	HexNum:PTR DWORD

Start_Over:
;// ************** BEGIN MAIN **************
main PROC

;// Prompt user for a string
	mov	edx, OFFSET Msg1
	call WriteString
	call Crlf
	mov	edx, OFFSET Msg2
	call WriteString

;// Read strung 	
	mov	edx, OFFSET HexNum_ASCII 
	mov  ecx, 5  						;// max characters + null terminator
	call ReadString					;// input the string
	mov	count, eax					;// number of characters
	call CRLF 

;// Get the hex values represented by ascii
	INVOKE Get_Hex, ADDR HexNum_ASCII 		;// value will be returned in eax 
		mov	HexNum_Actual, eax
		;// if ebx = 0001 exit program
		cmp	ebx, 0001
		je	Quit 
;// Show user input hex number
	mWrite "User Supplied: "

;// Load number and count
	mov	esi, OFFSET HexNum_ASCII			;// load number to element
	mov	ecx, 3						;// load count 
Show:
	mov	al, [esi]						;// esi => first num
	call	WriteChar 
	mov	al, '-'
	call WriteChar 
	inc	esi 
	Loop Show
	
;// Loop ended one char early so write it out
	mov al, [esi]
	call WriteChar 
	call Crlf
	call Crlf
	
;// Show user acual number representation
	mWrite "Hex Number is: "	
	
	mov	eax, HexNum_Actual 
	mov	ebx, TYPE WORD				;// Print out hex in WORD style (2 bytes)
	call WriteHexB
	call Crlf	
	call Crlf				
		 

;// Ask if user wants to try again
	mWrite "Would you like to do it again? (Y/y): "
	mov	edx, OFFSET decision 
	mov  ecx, 2  						;// max characters + null terminator
	call ReadString					;// input the string
						
check:	
	.IF (decision == 'Y') || (decision == 'y') 
	;// If a repeat clear screen
		call Clrscr
		jmp	Start_Over 
	.ELSEIF (decision == 'N') || (decision == 'n')
		jmp	Quit
	.ELSE
		mWrite "Invalid Decision try again: "
		mov	edx, OFFSET decision 
		mov  ecx, 2  						;// max characters + null terminator
		call ReadString					;// input the string
		Loop check
	.ENDIF
	
Quit:
;// Exit main
	exit
main ENDP
;//-----------------------------------SUBROUTINES--------------------------------------
;// Name: Get_Hex
;// 
;// Recieves: 
;//		HexNum, an address to a variable that hold the string 
;// Returns:
;//		eax, the number represented by string 
;//		ebx, error code if invalid input 
;//-------------------------------------------------------------------------------------
Get_Hex PROC USES ecx edx esi,
	HexNum:PTR DWORD  
	LOCAL temp: BYTE
	LOCAL retVal: DWORD 

;// Load first character of esi and set the count to 4 (4 bytes)
	mov	esi, HexNum
	mov	ecx, count	

;// Set ebx and edx to zero
	mov  ebx, 0
	mov  edx, 0			

;// Now convert to hex byte by byte 
Convert_Hex:
	mov	al, [esi]
	cmp	al, 30h		;// Is al < 30h (ascii representation of 0) ? 
	jb   Dont_Care		;//		Yes, jump to dont care 
	cmp  al, 3Ah		;// Is al > 39h (ascii representation of ':' the character after 9) ? 
	jae	Check_Upper	;//		Yes, check to see if letter 
	jb	Is_Num		;//		No, then it's a number (since it didnt jump to Dont Care)

Check_Upper:
	cmp	al, 41h		;// Is al < 41h ? (ascii representation of 'A')
	jb	Dont_Care		;//		Yes, this character doesnt matter 	
	cmp	al, 46h		;// Is al >= 46h (ascii represnetaion of 'F', last hex letter)
	ja	Check_Lower	;//		Yes? CHeck if its a lower case
	jb	Is_Upper		;//		No? THen its a Upper case

Check_Lower:
	cmp	al, 61h		;// Is al < 61h (ascii representation of 'a')
	jb	Dont_Care		;//		Yes, this character doesnt matter
	cmp	al, 66h		;// Is al > 66h (ascii representation of 'f', last hex letter)
	ja	Dont_Care		;//		Yes, character doesnt matter
	jmp	Is_Lower		;//	This means character is a lower case letter 
	
;// Jump accordingly 
;//	.IF (al >= 30h) || (al <= 39h)	;// If al >= '0' or al <= '9'
;//		jmp	Is_Num				;//		then its a number
;//	.ELSEIF (al >= 4Dh) || (al <= 5Ah)	;// If al >= 'A' or al <= 'Z'
;//		jmp	Is_Upper				;//		Then it's an upper case letter
;//	.ELSEIF (al >= 61h) || (al <= 7Ah)	;// If al >= 'a' or al <= 'z'
;//		jmp	Is_Lower				;//		Then it's an lower case letter
;//	.ELSE						;// Else it is a "dont care" value
;//		jmp	Dont_Care 
;//	.ENDIF		


	;// Convert to number
	Is_Num:
		sub	al, 30h	
		mov  temp, al 	
		mov eax, 0000
		;// Check what place is is
			;// 0s place?
			cmp	ecx, 1		
			je	Byte_1
			;// 1s place?
			cmp	ecx, 2
			je	Byte_2 
			;// 2s place?
			cmp	ecx, 3
			je	Byte_3
			;// 3s place?
			cmp	ecx, 4
			je	Byte_4
		
		;// Since its in 3s place, 16^3 = 4096
		Byte_4:
			mov	eax, Sixteen_Raised_Three
			mov	bl, temp 
			mul	ebx 
			mov	retVal, eax 
			inc  esi
			dec	ecx				;// to far to use LOOP so usea jump instead
			mov	temp, 0
			jne	Convert_Hex		
		;// Since its in 2s place, 16^2 = 256
		Byte_3:
			mov	eax, Sixteen_Raised_Two
			mov	bl, temp 
			mul	ebx 
			add	retVal, eax 
			inc  esi
			dec	ecx				;// to far to use LOOP so usea jump instead
			mov	temp, 0
			jne	Convert_Hex		
		;// Since its in 1s place, 16^1 = 16
		Byte_2:
			mov	eax, Sixteen_Raised_One
			mov	bl, temp 
			mul	ebx 
			add	retVal, eax
			inc  esi
			dec	ecx				;// to far to use LOOP so usea jump instead
			mov	temp, 0
			jne	Convert_Hex		
		;// Since its in 1 place, 16^0 = 1
		Byte_1:
			mov	eax, Sixteen_Raised_Zero 
			mov	bl, temp 
			mul	ebx 
			add	retVal, eax
			inc  esi
			dec	ecx				;// to far to use LOOP so usea jump instead
			mov	temp, 0
			jne	Convert_Hex		

;// Convert to upper case and change it to the actual number
Is_Lower:
	sub	al, 20h		;// convert to upper case (20 is offset btwn a upper and lower)
	mov  [esi], al		;// Change the lower case letter 
	
;// If its an upper case just change it to actual number
Is_Upper:
	;// If al == 'A', then its 10
		.IF (al == 'A')
			mov eax, 0000		;// zero out eax reg
		Hex_A:
		;// First Check count which shows us the place
			.IF (ecx == 4)		
			;// Then use 16^3
				mov	eax, Sixteen_Raised_Three
				mov	ebx, 000Ah 
				mul	ebx 
				add	temp, al
				mov	temp, 0000
			.ELSEIF (ecx == 3)
			;// Then use 16^2
				mov	eax, Sixteen_Raised_Two
				mov	ebx, 000Ah 
				mul	ebx 
				add	RetVal, eax 
				mov	temp, 0000
			;// Then use 16^1
			.ELSEIF (ecx == 2)
				mov	eax, Sixteen_Raised_One
				mov	ebx, 000Ah 
				mul	ebx 
				add	RetVal, eax 
			;// Then use 16^0
			.ELSEIF (ecx == 1)
				mov	eax, Sixteen_Raised_Zero
				mov	ebx, 000Ah 
				mul	ebx 
				add	RetVal, eax 
			.ENDIF
	;// If al == 'B', then its 11
		.ELSEIF (al == 'B')
			mov eax, 0000		;// zero out eax reg
		Hex_B:	
			.IF (ecx == 4)		
			;// Then use 16^3
				mov	eax, Sixteen_Raised_Three
				mov	ebx, 000Bh 
				mul	ebx 
				add	temp, al
				mov	temp, 0000
			.ELSEIF (ecx == 3)
			;// Then use 16^2
				mov	eax, Sixteen_Raised_Two
				mov	ebx, 000Bh 
				mul	ebx 
				add	RetVal, eax 
				mov	temp, 0000
			;// Then use 16^1
			.ELSEIF (ecx == 2)
				mov	eax, Sixteen_Raised_One
				mov	ebx, 000Bh 
				mul	ebx 
				add	RetVal, eax 
			;// Then use 16^0
			.ELSEIF (ecx == 1)
				mov	eax, Sixteen_Raised_Zero
				mov	ebx, 000Bh 
				mul	ebx 
				add	RetVal, eax 
			.ENDIF
	;// If al == 'C', then its 12
		.ELSEIF (al == 'C')
			mov eax, 0000		;// zero out eax reg
		Hex_C:
			.IF (ecx == 4)		
			;// Then use 16^3
				mov	eax, Sixteen_Raised_Three
				mov	ebx, 000Ch 
				mul	ebx 
				add	temp, al
				mov	temp, 0000
			.ELSEIF (ecx == 3)
			;// Then use 16^2
				mov	eax, Sixteen_Raised_Two
				mov	ebx, 000Ch 
				mul	ebx 
				add	RetVal, eax 
				mov	temp, 0000
			;// Then use 16^1
			.ELSEIF (ecx == 2)
				mov	eax, Sixteen_Raised_One
				mov	ebx, 000Ch 
				mul	ebx 
				add	RetVal, eax 
			;// Then use 16^0
			.ELSEIF (ecx == 1)
				mov	eax, Sixteen_Raised_Zero
				mov	ebx, 000Ch 
				mul	ebx 
				add	RetVal, eax 
			.ENDIF
	;// If al == 'D', then its 13
		.ELSEIF (al == 'D')
			mov eax, 0000		;// zero out eax reg
		Hex_D:
			.IF (ecx == 4)		
			;// Then use 16^3
				mov	eax, Sixteen_Raised_Three
				mov	ebx, 000Dh 
				mul	ebx 
				add	temp, al
				mov	temp, 0000
			.ELSEIF (ecx == 3)
			;// Then use 16^2
				mov	eax, Sixteen_Raised_Two
				mov	ebx, 000Dh 
				mul	ebx 
				add	RetVal, eax 
				mov	temp, 0000
			;// Then use 16^1
			.ELSEIF (ecx == 2)
				mov	eax, Sixteen_Raised_One
				mov	ebx, 000Dh 
				mul	ebx 
				add	RetVal, eax 
			;// Then use 16^0
			.ELSEIF (ecx == 1)
				mov	eax, Sixteen_Raised_Zero
				mov	ebx, 000Dh 
				mul	ebx 
				add	RetVal, eax 
			.ENDIF
	;// If al == 'E', then its 14
		.ELSEIF (al == 'E')	
			mov eax, 0000		;// zero out eax reg
		Hex_E:
			.IF (ecx == 4)		
			;// Then use 16^3
				mov	eax, Sixteen_Raised_Three
				mov	ebx, 000Eh 
				mul	ebx 
				add	temp, al
				mov	temp, 0000
			.ELSEIF (ecx == 3)
			;// Then use 16^2
				mov	eax, Sixteen_Raised_Two
				mov	ebx, 000Eh 
				mul	ebx 
				add	RetVal, eax 
				mov	temp, 0000
			;// Then use 16^1
			.ELSEIF (ecx == 2)
				mov	eax, Sixteen_Raised_One
				mov	ebx, 000Eh 
				mul	ebx 
				add	RetVal, eax 
			;// Then use 16^0
			.ELSEIF (ecx == 1)
				mov	eax, Sixteen_Raised_Zero
				mov	ebx, 000Eh 
				mul	ebx 
				add	RetVal, eax 
			.ENDIF
	;// If al == 'F', then its 15
		.ELSE
			mov eax, 0000		;// zero out eax reg
		Hex_F:
			.IF (ecx == 4)		
			;// Then use 16^3
				mov	eax, Sixteen_Raised_Three
				mov	ebx, 000Fh 
				mul	ebx 
				add	temp, al
				mov	temp, 0000
			.ELSEIF (ecx == 3)
			;// Then use 16^2
				mov	eax, Sixteen_Raised_Two
				mov	ebx, 000Fh 
				mul	ebx 
				add	RetVal, eax 
				mov	temp, 0000
			;// Then use 16^1
			.ELSEIF (ecx == 2)
				mov	eax, Sixteen_Raised_One
				mov	ebx, 000Fh 
				mul	ebx 
				add	RetVal, eax 
			;// Then use 16^0
			.ELSEIF (ecx == 1)
				mov	eax, Sixteen_Raised_Zero
				mov	ebx, 000Fh 
				mul	ebx 
				add	RetVal, eax 
			.ENDIF
		.ENDIF 
		inc	esi 
		dec	ecx					;// to far to use LOOP so usea jump instead
		jne	Convert_Hex		
		jmp Leave_Proc				;// Skip dont care

;// Invalid character return an error code for program to handle 
Dont_Care:
	mWrite <"Error! Invalid Input!",0dh,0ah>
	mov	ebx, 00001				;// error code for program to handle
	ret	

Leave_Proc:	
;// mov eax the value 
	mov eax, retVal 
	ret 
Get_Hex ENDP
END main