;*******************************************************************************
;   UNIVERSIDAD DEL VALLE DE GUATEMALA
;   IE2023 PROGRANACIÓN DE MICROCONTROLADORES 
;   AUTOR: JORGE SILVA
;   COMPILADOR: PIC-AS (v2.36), MPLAB X IDE (v6.00)
;   PROYECTO: Laboratorio 2, TMR0
;   HARDWARE: PIC16F887
;   CREADO: 08/08/2022
;   ÚLTIMA MODIFCACIÓN: 08/08/2022
;*******************************************************************************

PROCESSOR 16F887
#include <xc.inc>
    
;*******************************************************************************
;Palabra de configuración generada por MPLAB
;*******************************************************************************
; PIC16F887 Configuration Bit Settings

; CONFIG1
  CONFIG  FOSC = INTRC_NOCLKOUT 
  CONFIG  WDTE = OFF            
  CONFIG  PWRTE = ON           
  CONFIG  MCLRE = OFF           
  CONFIG  CP = OFF              
  CONFIG  CPD = OFF             
  CONFIG  BOREN = OFF           
  CONFIG  IESO = OFF            
  CONFIG  FCMEN = OFF           
  CONFIG  LVP = OFF             

; CONFIG2
  CONFIG  BOR4V = BOR40V        
  CONFIG  WRT = OFF    
  
;*******************************************************************************
;VARIABLES
;*******************************************************************************
PSECT updata_bank0
    valordisplay:	
		DS 2	;Esta variable ocupa 2 bytes en memoria
    comparador:		
		DS 2	;Esta variable ocupa 2 bytes en memoria
    nose:
		DS 2
    
;*******************************************************************************
;VECTOR RESET
;*******************************************************************************
PSECT restVect, class=CODE, delta=2, abs
org 0x0000
resetVect:
    pagesel main
    
    goto main
 
;*******************************************************************************
;CÓDIGO PRINCIPAL
;*******************************************************************************
PSECT code, delta=2, abs
ORG 100h	    ;Posición inicial para el código

main:			    
    call    basic
    call    oscilador
    call    configTMR0
    
   
loop:
    call    TMR0basic
    ;call    verificaciones
    call    contadorDISPLAY
    call    contadorpt1
    
    goto    loop

;*******************************************************************************
;TABLA DE VALORES HEXADECIMALES
;*******************************************************************************
tablahexa:
    clrf    PCLATH	    ;Esta tabla traduce los valores a hexadecimales
    bsf	    PCLATH, 0
    addwf   PCL, F
    retlw   3Fh
    retlw   06h	 
    retlw   5Bh	    
    retlw   4Fh	    
    retlw   66h	    
    retlw   6Dh	   
    retlw   7Dh	  
    retlw   07h	   
    retlw   7Fh	    
    retlw   6Fh	    
    retlw   77h	    
    retlw   7Ch	    
    retlw   39h	    
    retlw   5Eh	    
    retlw   79h	    
    retlw   71h
    
;*******************************************************************************
;SUBRUTINAS
;*******************************************************************************
basic: 
    banksel ANSEL   ;Limpiamos ambos ANSEL para declar pines digitales.
    clrf    ANSEL
    clrf    ANSELH
    
    banksel TRISC   ;Declaramos todo PORTC como entradas
    movlw   03h	  
    movwf   TRISC 
    
    banksel TRISA   ;Los siguintes TRIS se declaran como salidas digiles
    banksel TRISB
    banksel TRISD
    banksel TRISE
    clrf    TRISA   ;Salida para display
    clrf    TRISB   ;Salida para contador en segundos
    clrf    TRISD   ;Salida para TMR0
    clrf    TRISE   ;Salida para led que cambia de estado
    
    RETURN

oscilador:
    banksel OSCCON
    bcf	    IRCF2   ;Configuramos el Oscilador interno a 250kHz
    bsf	    IRCF1
    bcf	    IRCF0
    
    RETURN

configTMR0:
    bcf	    T0CS    ;Ponemos el modo temporizador del TMR0
    bcf	    PSA	    ;Ponemos el prescaler a 256
    bsf	    PS2
    bsf	    PS1
    bsf	    PS0
    banksel PORTC
    call    resetTMR0
    
    RETURN
    
resetTMR0:
    movlw   232	    ;Valor N calculado para obtener contador a 100ms
    movwf   TMR0
    bcf	    T0IF 
    
    RETURN
    
TMR0basic: 
    btfss   T0IF    ;Ponemos a funcionar el TMR0 a 100ms en PORTD
    goto    $-1
    call    resetTMR0
    incf    PORTD
    
    RETURN

contadorDISPLAY:
    btfsc   PORTC, 0	;Incrementamos si se apacha el botón
    call    inc1   
    
    btfsc   PORTC, 1	;Decrementamos si se apacha el botón
    call    dec1   
    
    movf    valordisplay, w	;Guardamos el valor en una variable
    call    tablahexa		;Usar la tabla pAra poner el valor hexadecimal
    movwf   PORTA		;El resultado se presenta en PORTA
    
    RETURN

inc1:
    btfsc   PORTC, 0		;Esto es un antirebote al presionar el botón
    goto    $-1
    
    incf    valordisplay, f	;Incrementamos PORTB
    ;movf    valordisplay, w
    ;movwf   comparador
    ;movf    comparador, w
    ;movwf   valordisplay
    
    btfsc   valordisplay, 4	;Si se pasa de 4 bits 
    clrf    valordisplay	;Reiniciamos contador
    
    RETURN
    
dec1:
    btfsc   PORTC, 1		;Esto es un antirebote al presionar el botón
    goto    $-1
    
    decf    valordisplay, f	;Decrementamos PORTB
    ;movf    valordisplay, w
    ;movwf   comparador
    ;movf    comparador, w
    ;movwf   valordisplay
    
    btfsc   valordisplay, 4	;Si se pasa de 4 bits
    call    decremento		;Llamamos una subrutina que nos pone en F
    
    RETURN
    
decremento:
    movlw   0Fh			;Ponemos el contador en F
    movwf   valordisplay
    
    RETURN
    
contadorpt1:		;Esto
    btfss   PORTD, 0
    call    contadorpt2

    RETURN
    
contadorpt2:		;Esto
    btfsc   PORTD, 1
    call    contadorpt3
    
    RETURN

contadorpt3:		;Esto
    btfss   PORTD, 2
    call    contadorpt4
    
    RETURN
    
contadorpt4:		;Y esto es para confirmar que TMR0 esté en 0101 (10)
    btfsc   PORTD, 3
    call    ahorasi
    
    RETURN
    
ahorasi:		;Si TMR0 está en 10
    incf    PORTB, F	;Incremntamos el contador de segundos
    btfsc   PORTB, 4	;Si se pasa de 4 bits
    clrf    PORTB	;Limpiar PORTB
    
    call    otravez	;Y reiniciamos el contador TMR0
    
    RETURN 
    
otravez:
    clrf    PORTD		;Limpiamos el puerto del TMR0
    call    resetTMR0		;Empezamos la cuenta desde 0
    
    RETURN

verificaciones:
    banksel PORTB
    movf    PORTB, w
    movwf   nose
    movf    valordisplay, w
    xorwf   nose, 0
    
    btfsc   STATUS, 2
    call estado
    
    RETURN

estado:	
    ;banksel PORTE
    clrf    PORTB
    ;movwf   1
    ;xorwf   PORTE, 1
    
    RETURN
    
END
