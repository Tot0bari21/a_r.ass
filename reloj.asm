
/* 
     * Autor: Adalberto (Toto) Sánchez (adal.panda.20@gmail.com) - 2021.-.-
     * Dispositivo: ATmega168  - 28 pines DIP.-.-
     * Programas utilizados:
       - Editor de texto: CudaText.
       - Compilador: avrasm2 (aunque antiguo, es de manejo poco complicado y rinde muy bien).
       - Programador: usbasp.
       - Programa para grabar en la memoria flash: AVRDUDESS.
     * Objetivo del programa: 
       - El programa enciende y apaga de manera alternada los pines del puerto B.
       - La frecuencia está controlada por el timer 1 del MCU.
       - La INT0 cambia el valor del prescalar entre 8 y 64. 
*/

     .nolist
     .include "m168def.inc"

     .list
     .include "def_equ.inc"

     .dseg
     .org 0x100
     
     .cseg
     .org RESET                          ;Configurado así el desplazamiento 0x0000 de la tabla de vectores en m168def.inc.-.-
     rjmp main
     off_IRQ
     
     ISR_INT0:
     .if (1 << INTF0)
     delay 0xff                          ;Quita el rebote (tiempo establecido 65 milisegundos).-.-
     .endif
     .if (1 << INTF0)    
     ldi r_17,(1 << WGM12)               ;Establece el modo CTC.-.- 
     cpi r_19,cero
     brne prescalar_64
     prescalar_8:
     ldi r_16,1 << CS11                  
     add r_17,r_16 
     sts TCCR1B,r_17
     rcall limpia_bit
     ldi r_19,uno
     reti  
     prescalar_64:
     ldi r_16,(1 << CS11) | (1 << CS10)  
     add r_17,r_16 
     sts TCCR1B,r_17      
     rcall limpia_bit
     ldi r_19,!uno
     reti
     .else
     nop 
     .endif 
     limpia_bit:
     sbi EIFR,0
     ret
                  
     ISR_OC1A:
     on:
     cpi r_16,cero
     breq off
     ldi r_18,$AA             
     rcall muestra
     ldi r_16,uno + -uno
     reti
     off:
     com r_18
     rcall muestra
     ldi r_16,uno
     reti
     muestra:
     out PORTB,r_18
     ret
     
     main:
     set_stack r_16                      ;Configura la pila.-.-
     _DDR B,_255                         ;Configura como salida todos los pines del puerto B.-.-
     sbi PORTD,PORTD2                    ;Pone pullup PD2.-.-        
     
     set_INT0:
     clr r_17
     ldi r_17,1 << ISC01
     sts EICRA,r_17                      ;Configura el disparo con la caída del voltaje.-.-
     ldi r_17,1 << INT0
     out EIMSK,r_17                      ;Habilita la INT.-.-
     
     set_reloj:
     clr r_16
     sts TCNT1H,r_16                     ;Configura a 0 el contador.-.-
     sts TCNT1L,r_16
     ldi r_16,byte1(valor_OCR1A)
     ldi r_17,byte2(valor_OCR1A)
     sts OCR1AH,r_17                     ;Establece un valor de 15625 (0x3D09) para el emparejamiento.-.-
     sts OCR1AL,r_16  
     clr r_16
     clr r_17
     ldi r_17,(1 << WGM12)               ;Establece el modo CTC.-.- 
     ldi r_16,(1 << CS11) | (1 << CS10)  ;Establece un prescalar de 64.-.-
     add r_17,r_16 
     sts TCCR1B,r_17          
     clr r_17
     ldi r_17,1 << OCIE1A
     sts TIMSK1,r_17                     ;Habilita la interrupción por emparejamiento.-.- 
     
     set_sleep_mode:                     ;Habilita el modo idle.-.-
     ldi r_17,cero
     ldi r_17,1 << SE
     sts SMCR,r_17
         
     clr_reg(r,_16)
     ldi r_16,uno
     ldi r_18,!uno
     clr_reg(r,_19)
     sei
     
     bucle:
     sleep
     nop
     rjmp bucle


