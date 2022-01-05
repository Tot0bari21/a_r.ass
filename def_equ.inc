 
.def r_16 = r16
.def r_17 = r17
.def r_18 = r18
.def r_19 = r19
.def r_20 = r20
.def r_21 = r21
.def r_22 = r22
.def r_23 = r23
.def r_24 = r24
.def r_25 = r25

/* ****************************************** */

.equ cero = ~$ff                              
.equ uno = !0
.equ _255 = ~cero

.equ reloj = 1000000
.equ prescalar = 64
.equ valor_OCR1A = reloj/prescalar
 
#define clr_reg(a,b)  \
        clr a##b      \
        #

; ===========================================

.macro off_IRQ                     ;Conseguí que funcionara con esta configuración.-.-
       .org INT0addr
       rjmp ISR_INT0
       reti ; INT1
	   reti ; PCI0
	   reti ; PCI1
	   reti ; PCI2
	   reti ; WDT
	   reti ; OC2A
	   reti ; OC2B
	   reti ; OVF2
	   reti ; ICP1
	   .org OC1Aaddr
	   rjmp ISR_OC1A 
	   reti ; OC1B
	   reti ; OVF1
	   reti ; OC0A
	   reti ; OC0B
	   reti ; OVF0
	   reti ; SPI
	   reti ; URXC
	   reti ; UDRE
	   reti ; UTXC
	   reti ; ADCC
	   reti ; ERDY
	   reti ; ACI
	   reti ; TWI
	   reti ; SPMR
       exit:
.endm  

.macro set_stack                   ;Contiene una macro anidada.-.-
        eor @0,@0
        ldi @0,byte2(RAMEND)
        _sp r_16,H
        ldi @0,low(RAMEND)
        _sp r_16,L
        exit:
.endm

.macro _sp
        out SP@1,@0
        exit:
.endm

.macro _DDR
       ldi r_17,@1
       out DDR##@0,r_17
       exit:
.endm 

.macro delay
       clr r_21
       clr r_22
       bucle:
       ldi r_21,@0
       uno:
       dec r_21
       brne uno
       dos:
       inc r_22
       brne bucle
       exit:
.endm
       





