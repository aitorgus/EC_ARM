        .include  "inter.inc"
.text
/* Agrego vector interrupcion */
        ADDEXC  0x18, irq_handler

/* Inicializo la pila en modos IRQ y SVC */
        mov     r0, #0b11010010   @ Modo IRQ, FIQ&IRQ desact
        msr     cpsr_c, r0
        mov     sp, #0x8000
        mov     r0, #0b11010011   @ Modo SVC, FIQ&IRQ desact
        msr     cpsr_c, r0
        mov     sp, #0x8000000

/* Configuro GPIO 9 como salida */
        ldr     r0, =GPBASE
/* guia bits           xx999888777666555444333222111000*/
        mov     r1, #0b00001000000000000000000000000000
        str     r1, [r0, #GPFSEL0]

/* Programo contador C3 para futura interrupcion */
        ldr     r0, =STBASE
        ldr     r1, [r0, #STCLO]
		ldr	r2, =500000     @ 0.5 segundos
        add     r1, r2
        str     r1, [r0, #STC3]

/* Habilito interrupciones, local y globalmente */
        ldr     r0, =INTBASE
        mov     r1, #0b1000						@OJO AQUÍ HAY QUE CAMBIAR DIRECCIONES DE MEMORIA PARA C3 ES 1000, PARA C1 ES 0010
        str     r1, [r0, #INTENIRQ1]
        mov     r0, #0b01010011   @ Modo SVC, IRQ activo @OJO AQUÍ HAY QUE CAMBIAR DIRECCIONES DE MEMORIA
        msr     cpsr_c, r0

/* Repetir para siempre */
bucle:  b       bucle

/* Rutina de tratamiento de interrupción */
irq_handler:
        push    {r0, r1}          @ Salvo registros

        ldr     r0, =GPBASE
/* guia bits           10987654321098765432109876543210*/
        ldr     r1, =0b00000000000000000000001000000000
        str     r1, [r0, #GPSET0] @ Enciendo LED

        pop     {r0, r1}          @ Recupero registros
        subs    pc, lr, #4        @ Salgo de la RTI
