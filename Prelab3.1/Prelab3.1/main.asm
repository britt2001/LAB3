//*****************************************************************************
//UNIVERSIDAD DEL VALLE DE GUATEMALA
//IE2023: Programación de microcontroladores
//Autora: Brittany Barillas
//Proyecto: Prelab3 con ejemplo Pablo
//Archivo: Prelab3.1.asm
// Hardware: ATMEGA328P
//Created: 2/17/2024 11:09:46 AM
//*****************************************************************************
.include "M328PDEF.inc"
.cseg
.org 0x0000
	JMP MAIN
.org 0x0006 ;Vector de ISR: PCINT0, SI... PORTB=0, PORTC=1, PORTD=2
	JMP ISR_PCINT0 

MAIN:
//*****************************************************************************
// STACK
//*****************************************************************************
LDI R16, LOW(RAMEND)
OUT SPL, R16 ;Selecciona r16 y lo carga a SPL
LDI R17, HIGH(RAMEND)
OUT SPH, R17
//*****************************************************************************
// CONFIGURACION
//*****************************************************************************
Setup:
	SBI DDRB, PB5
	CBI PORTB, PB5 ;apaga PB5

	LDI R16, (1<<PC3)|(1<<PC2)|(1<<PC1)|(1<<PC0)
	OUT DDRC, R16 ;Habilitando PC0, PC1 y PC2 como salidas

	LDI R16, 0;
	OUT PORTC, R16;

	SBI PORTB, PB0 ;Habilitando PULL-UP en PB0
	CBI DDRB, PB0  ;Habilitando PB0 como entrada

	SBI PORTB, PB1 ;Habilitando PULL-UP en PB1
	CBI DDRB, PB1  ;Habilitando PB0 como entrada

	LDI R16, (1<<PCINT1)|(1<<PCINT0)
	STS PCMSK0, R16 ;Habilitando PCINT en los pines PCINT0 y PCINT1

	LDI R16, (1<<PCIE0)
	STS PCICR, R16 ;Habilitando la ISR PCINT[7:0]

	SEI ;Habilita interrupciones globales GIE

	LDI R20,0 ;Contador en 0
	LDI R21,0 ; MUESTRO EL DATO EN R21

Loop:
	MOV R21, R20
	OUT PORTC, R21
	JMP LOOP

//*****************************************************************************
//SUBRUTINAS de ISR INT0
//*****************************************************************************
ISR_PCINT0:
	PUSH R16 ;Guardamos en la pila el registro R16
	IN R16, SREG
	PUSH R16 ;Guardamos en la pila el registro SREG

	IN R18, PINB

	SBRC R18, PB0
	JMP CHECKPB1
	INC R20
	CPI R20, 16 ;Que solo vaya de 1-15
	BRNE SALIR
	LDI R20, 0
	JMP SALIR  

CHECKPB1:
	SBRC R18, PB1
	JMP SALIR
	DEC R20
	BRNE SALIR
	LDI R20, 15

SALIR:
	SBI PINB, PB5		;Toggle de PB5
	SBI PCIFR, PCIF0	;Apagar la bandera de ISR PCINT0

	POP R16				;Obtener el valor de SREG
	OUT SREG, R16		;Restaurar los valores antiguos de SREG
	POP R16				;Obtener el valor de R16
	RETI				;Retornamos de la ISR
//*****************************************************************************