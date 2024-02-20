;
; Lab3.asm
;
; Created: 2/18/2024 10:03:37 PM
//*****************************************************************************
//UNIVERSIDAD DEL VALLE DE GUATEMALA
//IE2023: Programación de microcontroladores
//Autora: Brittany Barillas
//Proyecto: timer 0
//Archivo: tmr0.asm
// Hardware: ATMEGA328P
// Created: 2/6/2024 1:27:57 PM

//*****************************************************************************
.include "M328PDEF.inc"
.cseg
.org 0x00
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
TABLAD7seg: .DB 0x30, 0x6D, 0x79, 0x33,0x5B, 0x5F, 0x70, 0x7F, 0x73, 0x77, 0x1F, 0x4E, 0x7E, 0x4F, 0x47, 0x7C
Setup:
	;SBI DDRB, PB5
	;CBI PORTB, PB5

	CALL TMR_0

	LDI R20,0

	LDI R16, (1<<CLKPCE)
	LDI R16, 0b0000_0111
	STS CLKPR, R16

	OUT DDRD, R16

	; Inicialización de registros adicionales
	LDI R18, 0 ; Inicializa R18 en 0
	LDI R21, 0 ; Inicializa R21 en 0
	LDI ZH, HIGH(TABLAD7seg <<1) ; Carga la parte alta de la dirección de la tabla de 7 segmentos en ZH
	LDI ZL, LOW(TABLAD7seg <<1) ; Carga la parte baja de la dirección de la tabla de 7 segmentos en ZL
	ADD ZL, R18 ; Añade el valor de R18 a ZL
	LPM R18, Z ; Lee el valor de la tabla de 7 segmentos y lo guarda en R18

Loop:
	CALL TMR_0
	SBRC R18, PC6 ; Comprueba si el bit PC6 de R18 está limpio
	OUT PORTD, R18 ; Envía el valor de R18 a PORTD
	IN R16, TIFR0 ; Lee el estado del registro de banderas del temporizador TMR0
	SBRS R16, OCF0A ; Comprueba si la bandera de comparación de salida A del temporizador TMR0 está establecida
	RJMP LOOP ; Salta al bucle principal
	SBI TIFR0, OCF0A ; Establece la bandera de comparación de salida A del temporizador TMR0
	INC R20 ; Incrementa R20
	CPI R20, 1 ; Compara R20 con 1
	BRNE LOOP ; Salta al bucle principal si no son iguales
	CLR R20 ; Limpia R20
	SBI PINB, PB3 ; Establece el bit PB3 de PORTB
	CALL AUMENTAR
	RJMP LOOP
//*****************************************************************************
AUMENTAR:
	INC R21
	OUT PORTD, R21
	LDI ZH, HIGH (TABLAD7seg <<1)
	LDI ZL, LOW (TABLAD7seg <<1)
	ADD ZL, R18
	LPM R18, Z
	RJMP LOOP
;IN R16, TIFR0
;CPI R16, (1<<TOV0)
;BRNE LOOP ;SIN--O ESTA ENCENCIDA, ESPERA

TMR_0:

	LDI R16, 100 ;CARGA VALOR DE DESBORDAMIENTO
	OUT TCNT0, R16 ;CARGA VALOR INICIAL CONT

	SBI TIFR0, TOV0 ;apago la bandera encendiendola


	INC R20
	CPI R20, 100;repito la instruccion 100veces para hacerlo de 1000ms

	BRNE LOOP

	CLR R20

	SBI PINB, PB5

RJMP LOOP
