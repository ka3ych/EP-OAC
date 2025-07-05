.data
    arq_nome:     .asciiz "numeros.txt"
    msg_ord:      .asciiz "\n\nELEMENTOS ORDENADOS\n\n"
    newline:      .asciiz "\n"
    
    byte_lido:    .space 1
    linha_buf:    .space 32
    
    flt_zero:     .float 0.0
    flt_dec:      .float 100000.0
    
    tipo_ord:     .word 2            # 1 = bubble sort, 2 = quicksort

.text
.globl main

main:

    # Abre arquivo para leitura
    li $v0, 13              
    la $a0, arq_nome        
    li $a1, 0
    syscall
    
    add $s0, $v0, $zero
    li $s1, 0

# Loop que conta as linhas do arquivo
le_loop:
    li $v0, 14
    add $a0, $s0, $zero
    la $a1, byte_lido
    li $a2, 1
    syscall
    
    slt $t0, $v0, $zero
    bne $t0, $zero, fim_arq
    beq $v0, $zero, fim_arq
    
    lb $t0, byte_lido
    li $t1, 10             # '\n'
    bne $t0, $t1, le_loop
    
    addi $s1, $s1, 1
    j le_loop

fim_arq:
    li $v0, 16
    add $a0, $s0, $zero
    syscall

    # Aloca memória do array
    add $t0, $s1, $zero
    li $t1, 4
    mult $t0, $t1
    mflo $a0

    li $v0, 9
    syscall
    add $s2, $v0, $zero

    # Reabre o arquivo para realizar leitura
    li $v0, 13              
    la $a0, arq_nome        
    li $a1, 0
    syscall
    add $s0, $v0, $zero

    li $s3, 0

# Loop para ler as linhas do arquivo
le_nums:
    jal ler_linha
    beq $v0, $zero, chamar_ordena

    la $a0, linha_buf
    jal str_para_float

    # Armazena no array
    li $t0, 4
    mult $s3, $t0
    mflo $t1
    add $t2, $s2, $t1
    s.s $f0, 0($t2)

    addi $s3, $s3, 1
    j le_nums

chamar_ordena:
    li $v0, 16
    add $a0, $s0, $zero
    syscall

    add $a0, $s1, $zero     #$a0 = tamanho
    lw $a1, tipo_ord        #$a1 = tipo ordenação
    add $a2, $s2, $zero     # $a2 = array
    jal ordena
    add $s2, $v0, $zero
    j imprimir

# Imprime resultado
imprimir:
    li $v0, 13
    la $a0, arq_nome
    li $a1, 9
    li $a2, 0
    syscall
    add $s4, $v0, $zero

    # Escreve "ELEMENTOS ORDENADOS"
    li $v0, 15
    add $a0, $s4, $zero
    la $a1, msg_ord
    li $a2, 25
    syscall

    li $t0, 0
    
printa_loop:
    beq $t0, $s1, fecha_arquivo

    li $t1, 4
    mult $t0, $t1
    mflo $t2
    add $t3, $s2, $t2
    l.s $f12, 0($t3)

    # Converte float para string
    la $a0, linha_buf
    jal float_para_str
    
    # Escreve numero
    li $v0, 15
    add $a0, $s4, $zero
    la $a1, linha_buf
    li $a2, 31
    syscall

    # Escreve \n
    li $v0, 15
    move $a0, $s4
    la $a1, newline
    li $a2, 1
    syscall

    addi $t0, $t0, 1
    j printa_loop

fecha_arquivo:
    li $v0, 16
    add $a0, $s4, $zero
    syscall
    j fim

fim:
    li $v0, 10
    syscall

#FUNCAO ORNDENA
# Parametros: $a0 -> tamanho
#             $a1 -> tipo (1=bubble, 2=quick)
#             $a2 -> array
ordena:
    addi $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)         # $s0 = tamanho
    sw $s1, 4($sp)         # $s1 = tipo ordenação
    sw $s2, 0($sp)         # $s2 = array
    
    add $s0, $a0, $zero
    add $s1, $a1, $zero
    add $s2, $a2, $zero
    
    li $t0, 1
    beq $s1, $t0, usa_bubble_sort
    
    li $t0, 2
    beq $s1, $t0, usa_quick_sort
    
    j usa_bubble_sort

usa_bubble_sort:
    add $a0, $s2, $zero
    add $a1, $s0, $zero
    jal ordena_bubble
    j fim_ordena

usa_quick_sort:
    add $a0, $s2, $zero
    li $a1, 0
    addi $a2, $s0, -1
    jal ordena_quick
    j fim_ordena

fim_ordena:
    add $v0, $s2, $zero
    lw $s2, 0($sp)
    lw $s1, 4($sp)
    lw $s0, 8($sp)
    lw $ra, 12($sp)
    addi $sp, $sp, 16
    jr $ra

#Bubblesort
ordena_bubble:
    addi $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)
    sw $s1, 4($sp)
    sw $s2, 0($sp)
    add $s0, $a0, $zero
    add $s1, $a1, $zero
    li $t0, 0
    
loop_externo:
    beq $t0, $s1, fim_bubble
    li $t1, 0
    sub $t2, $s1, $t0
    addi $t2, $t2, -1
    
loop_interno:
    beq $t1, $t2, prox_i
    li $t3, 4
    mult $t1, $t3
    mflo $t4
    add $t5, $s0, $t4
    addi $t6, $t1, 1
    mult $t6, $t3
    mflo $t7
    add $t8, $s0, $t7
    
    # Compara e troca
    l.s $f0, 0($t5)
    l.s $f1, 0($t8)
    c.le.s $f0, $f1
    bc1t nao_troca
    s.s $f1, 0($t5)
    s.s $f0, 0($t8)
    
nao_troca:
    addi $t1, $t1, 1
    j loop_interno
    
prox_i:
    addi $t0, $t0, 1
    j loop_externo
    
fim_bubble:
    lw $s2, 0($sp)
    lw $s1, 4($sp)
    lw $s0, 8($sp)
    lw $ra, 12($sp)
    addi $sp, $sp, 16
    jr $ra
    
#Quicksort
ordena_quick:
    addi $sp, $sp, -24
    sw $ra, 20($sp)
    sw $s0, 16($sp)
    sw $s1, 12($sp)
    sw $s2, 8($sp)
    sw $s3, 4($sp)
    sw $s4, 0($sp)
    
    add $s0, $a0, $zero
    add $s1, $a1, $zero
    add $s2, $a2, $zero
    
    slt $t0, $s1, $s2
    beq $t0, $zero, fim_quick
    
    add $a0, $s0, $zero
    add $a1, $s1, $zero
    add $a2, $s2, $zero
    jal particiona
    add $s3, $v0, $zero
    
    # Metade esquerda
    add $a0, $s0, $zero
    add $a1, $s1, $zero
    addi $a2, $s3, -1
    jal ordena_quick
    
    # Metade direita
    add $a0, $s0, $zero
    addi $a1, $s3, 1
    add $a2, $s2, $zero
    jal ordena_quick
    
fim_quick:
    lw $s4, 0($sp)
    lw $s3, 4($sp)
    lw $s2, 8($sp)
    lw $s1, 12($sp)
    lw $s0, 16($sp)
    lw $ra, 20($sp)
    addi $sp, $sp, 24
    jr $ra

particiona:
    addi $sp, $sp, -24
    sw $ra, 20($sp)
    sw $s0, 16($sp)
    sw $s1, 12($sp)
    sw $s2, 8($sp)
    sw $s3, 4($sp)
    sw $s4, 0($sp)
    
    add $s0, $a0, $zero
    add $s1, $a1, $zero
    add $s2, $a2, $zero
    
    # Pivot
    li $t0, 4
    mult $s2, $t0
    mflo $t1
    add $t2, $s0, $t1
    l.s $f0, 0($t2)
    
    addi $s3, $s1, -1
    add $s4, $s1, $zero
    
loop_particiona:
    beq $s4, $s2, fim_particiona
    
    li $t0, 4
    mult $s4, $t0
    mflo $t1
    add $t2, $s0, $t1
    l.s $f1, 0($t2)
    
    c.le.s $f1, $f0
    bc1f prox_j
    
    addi $s3, $s3, 1
    
    li $t0, 4
    mult $s3, $t0
    mflo $t1
    add $t2, $s0, $t1
    l.s $f2, 0($t2)
    
    s.s $f1, 0($t2)
    
    li $t0, 4
    mult $s4, $t0
    mflo $t1
    add $t2, $s0, $t1
    s.s $f2, 0($t2)
    
prox_j:
    addi $s4, $s4, 1
    j loop_particiona
    
fim_particiona:
    addi $s3, $s3, 1
    
    li $t0, 4
    mult $s3, $t0
    mflo $t1
    add $t2, $s0, $t1
    l.s $f1, 0($t2)
    
    li $t0, 4
    mult $s2, $t0
    mflo $t1
    add $t3, $s0, $t1
    
    s.s $f0, 0($t2)
    s.s $f1, 0($t3)
    
    add $v0, $s3, $zero
    
    lw $s4, 0($sp)
    lw $s3, 4($sp)
    lw $s2, 8($sp)
    lw $s1, 12($sp)
    lw $s0, 16($sp)
    lw $ra, 20($sp)
    addi $sp, $sp, 24
    jr $ra

#Le uma linha do arquvo
ler_linha:
    la $t0, linha_buf
    li $t1, 0
    
le_char:
    li $v0, 14
    add $a0, $s0, $zero
    la $a1, byte_lido
    li $a2, 1
    syscall
    slt $t2, $v0, $zero
    bne $t2, $zero, fim_linha
    beq $v0, $zero, fim_linha
    lb $t2, byte_lido
    li $t3, 10             # '\n'
    beq $t2, $t3, fim_linha
    add $t4, $t0, $t1
    sb $t2, 0($t4)
    addi $t1, $t1, 1
    li $t5, 30
    bne $t1, $t5, le_char
    
fim_linha:
    add $t4, $t0, $t1
    sb $zero, 0($t4)
    add $v0, $t1, $zero
    jr $ra

# Converte string para float
str_para_float:
    add $t0, $a0, $zero
    li $t1, 0              # parte inteira
    li $t2, 0              # parte decimal
    li $t3, 0              # divisor
    li $t4, 1              # sinal
    li $t5, 0              # flag
    lb $t6, 0($t0)
    li $t7, 45             # '-'
    bne $t6, $t7, conv_digitos
    li $t4, -1
    addi $t0, $t0, 1
    
conv_digitos:
    lb $t6, 0($t0)
    beq $t6, $zero, fim_conv
    li $t7, 46             # '.'
    beq $t6, $t7, decimal_flag
    li $t7, 48             # '0'
    sub $t6, $t6, $t7
    beq $t5, $zero, soma_int
    li $t7, 10
    mult $t2, $t7
    mflo $t2
    add $t2, $t2, $t6
    mult $t3, $t7
    mflo $t3
    j prox_char
    
soma_int:
    li $t7, 10
    mult $t1, $t7
    mflo $t1
    add $t1, $t1, $t6
    j prox_char
    
decimal_flag:
    li $t5, 1
    li $t3, 1
    
prox_char:
    addi $t0, $t0, 1
    j conv_digitos
    
fim_conv:
    # Converte para float
    mtc1 $t1, $f0
    cvt.s.w $f0, $f0
    beq $t3, $zero, aplica_sinal
    mtc1 $t2, $f1
    cvt.s.w $f1, $f1
    mtc1 $t3, $f2
    cvt.s.w $f2, $f2
    div.s $f1, $f1, $f2
    add.s $f0, $f0, $f1
    
aplica_sinal:
    li $t7, -1
    bne $t4, $t7, fim_str_float
    l.s $f1, flt_zero
    sub.s $f0, $f1, $f0
    
fim_str_float:
    jr $ra
    
# Converte float para string
float_para_str:
    addi $sp, $sp, -32
    sw $ra, 28($sp)
    sw $t0, 24($sp)
    sw $t1, 20($sp)
    sw $t2, 16($sp)
    sw $t3, 12($sp)
    sw $t4, 8($sp)
    sw $t5, 4($sp)
    sw $t6, 0($sp)
    
    # Verifica se é negativo
    l.s $f0, flt_zero
    c.lt.s $f12, $f0
    bc1f positivo
    li $t0, 45             # '-'
    sb $t0, 0($a0)
    addi $a0, $a0, 1
    sub.s $f12, $f0, $f12
    
positivo:
    # Separa parte inteira e decimal
    add.s $f0, $f12, $f0
    cvt.w.s $f0, $f0
    mfc1 $t1, $f0
    mtc1 $t1, $f1
    cvt.s.w $f1, $f1
    sub.s $f2, $f12, $f1
    la $t0, flt_dec
    l.s $f3, 0($t0)
    mul.s $f2, $f2, $f3
    cvt.w.s $f2, $f2
    mfc1 $t2, $f2
    
    add $t3, $zero, $a0
    beq $t1, $zero, escreve_zero
    
# Converte parte inteiro
converte_int:
    li $t4, 10
    div $t1, $t4
    mfhi $t5
    mflo $t1
    addi $t5, $t5, 48
    sb $t5, 0($a0)
    addi $a0, $a0, 1
    bne $t1, $zero, converte_int
    j inverte_int
    
escreve_zero:
    li $t5, 48             # '0'
    sb $t5, 0($a0)
    addi $a0, $a0, 1
    
# Inverte parte inteira
inverte_int:
    sub $t6, $a0, $t3
    addi $t6, $t6, -1
    add $t4, $zero, $t6
    
inverte_loop:
    slt $at, $zero, $t4
    beq $at, $zero, processa_decimal
    lb $t5, 0($t3)
    lb $t1, -1($a0)
    sb $t1, 0($t3)
    sb $t5, -1($a0)
    addi $t3, $t3, 1
    addi $a0, $a0, -1
    addi $t4, $t4, -2
    j inverte_loop

# Processa parte decimal
processa_decimal:
    beq $t2, $zero, sem_decimal
    
    li $t0, 46             # '.'
    sb $t0, 0($a0)
    addi $a0, $a0, 1
    
    add $t6, $zero, $t2
    li $t4, 10000
    li $t7, 5
    
# Remove zeros à direita
remove_zeros_direita:
    li $t5, 10
    div $t6, $t5
    mfhi $t1                     
    bne $t1, $zero, escreve_decimais
    mflo $t6    
    div $t4, $t5
    mflo $t4
    addi $t7, $t7, -1
    slt $at, $zero, $t7
    bne $at, $zero, remove_zeros_direita
    
escreve_decimais:
    beq $t7, $zero, sem_decimal
    
loop_decimais:
    div $t6, $t4
    mflo $t1
    mfhi $t6
    addi $t1, $t1, 48
    sb $t1, 0($a0)
    addi $a0, $a0, 1
    
    li $t5, 10
    div $t4, $t5
    mflo $t4
    addi $t7, $t7, -1
    slt $at, $zero, $t7
    bne $at, $zero, loop_decimais
    
sem_decimal:
    li $t0, 0
    sb $t0, 0($a0)
    lw $t6, 0($sp)
    lw $t5, 4($sp)
    lw $t4, 8($sp)
    lw $t3, 12($sp)
    lw $t2, 16($sp)
    lw $t1, 20($sp)
    lw $t0, 24($sp)
    lw $ra, 28($sp)
    addi $sp, $sp, 32
    jr $ra