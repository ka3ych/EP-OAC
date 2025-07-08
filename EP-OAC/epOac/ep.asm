.data
    arq_nome:     .asciiz "C:/Users/alanm/Nova pasta/EP-OAC/EP-OAC/epOac/Arquivos_de_numero/10numeros.txt"
    msg_ord:      .asciiz "\n\nELEMENTOS ORDENADOS\n\n"
    newline:      .asciiz "\n"
    
    byte_lido:    .space 1
    linha_buf:    .space 32
    
    flt_zero:     .float 0.0
    flt_dec:      .float 100000.0
    flt_um:       .float 1.0
    
    tipo_ord:     .word 2 # 1 para Bubble Sort e 2 para QuickSort

.text
.globl main

main:

    # abre o arquivo 'arq_nome' para leitura
    li $v0, 13              
    la $a0, arq_nome        
    li $a1, 0
    syscall
    
    add $s0, $v0, $zero
    li $s1, 0
    li $s7, 0 # flag que será utilizada para indicar se há conteúdo na linha atual

# loop que conta as linhas do arquivo
le_loop:
    li $v0, 14
    add $a0, $s0, $zero
    la $a1, byte_lido
    li $a2, 1
    syscall
    
    slt $t0, $v0, $zero
    bne $t0, $zero, fim_arq # vai para o 'fim_arq'
    beq $v0, $zero, verifica_ultima_linha # vai para o verifiica_ultima_linha
    
    lb $t0, byte_lido
    li $t1, 10 # utilizado para o new line, '\n' equivalente em C
    beq $t0, $t1, incrementa_linha
    
    # se não for new line, marca que há conteúdo na linha, e ai vai ao 'le_loop'
    li $s7, 1
    j le_loop

incrementa_linha:
    addi $s1, $s1, 1
    li $s7, 0 # reseta flag de conteúdo, que criamos fora do loop
    j le_loop

verifica_ultima_linha:
    # se não tiver new line na última linha conta ela também
    beq $s7, $zero, fim_arq
    addi $s1, $s1, 1

	# parte do 'fim_arq' onde alocamos memoria do array e reabrimos para leitura
fim_arq:
    li $v0, 16
    add $a0, $s0, $zero
    syscall

    # aloca memoria do array
    add $t0, $s1, $zero
    li $t1, 4
    mult $t0, $t1
    mflo $a0

    li $v0, 9
    syscall
    add $s2, $v0, $zero

    # reabre arquivo 'arq_nome' para realizar a leitura
    li $v0, 13              
    la $a0, arq_nome        
    li $a1, 0
    syscall
    add $s0, $v0, $zero

    li $s3, 0

# loop para ler as linhas do arquivo 'arq_nome'
le_nums:
    jal ler_linha
    beq $v0, $zero, chamar_ordena

    la $a0, linha_buf
    jal str_para_float

    #será armazenado no array
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

    add $a0, $s1, $zero # '$a0' será usado como tamanho
    lw $a1, tipo_ord #'$a1' é o o tipo ordenação
    add $a2, $s2, $zero # '$a2' é a array
    jal ordena
    add $s2, $v0, $zero
    j imprimir

# 'imprimir' é usada para imprimir o resultado, e os "ELEMENTOS ORDENADOS" em 'msg_ord'
imprimir:
    li $v0, 13
    la $a0, arq_nome
    li $a1, 9
    li $a2, 0
    syscall
    add $s4, $v0, $zero

    # aqui chama o 'msg_ord' e imprime a mensagem de "ELEMENTOS ORDENADOS"
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

    # converte de float para string
    la $a0, linha_buf
    
    # limpa o buffer primeiro
    li $t8, 0
    
limpa_buffer:
    add $t9, $a0, $t8
    sb $zero, 0($t9)
    addi $t8, $t8, 1
    li $s6, 32
    bne $t8, $s6, limpa_buffer
    
    jal float_para_str
    
    # calcula o tamanho para evitar o erro e ter certeza que vai tudo funcionar
    la $t4, linha_buf
    li $t5, 0
    
calc_tam_loop:
    add $t6, $t4, $t5
    lb $t7, 0($t6)
    beq $t7, $zero, fim_calc_tam
    addi $t5, $t5, 1
    li $t8, 31 # limite com '31', para segurança
    beq $t5, $t8, fim_calc_tam
    j calc_tam_loop
    
fim_calc_tam:
    # se não tem nada, usa o tamanho mínimo
    bne $t5, $zero, escreve_numero
    li $t5, 1
    
 # Escreve numero com tamanho calculado e new line
escreve_numero:
    li $v0, 15
    add $a0, $s4, $zero
    la $a1, linha_buf
    add $a2, $t5, $zero
    syscall

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
    j fim_programa

fim_programa:
    li $v0, 10
    syscall

# aqui começa a função ordena, e vao ser chamados parametros que a gente havia especificado anteriormente
# '$s0' é o tamanho, '$s2' é o tipo (especificado em .data) e '$s2' é a array
ordena:
    addi $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)
    sw $s1, 4($sp)
    sw $s2, 0($sp)
    
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

# ------------ Algoritmo Bubble Sort ------------------- #
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
    
    # essa parte é utilizada para comparação e troca, caso for ocorrer
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
    
# ------------ Algoritmo Quick Sort ------------------- #
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
    
    # a metade do lado esquerdo
    add $a0, $s0, $zero
    add $a1, $s1, $zero
    addi $a2, $s3, -1
    jal ordena_quick
    
    # a metade do lado direito
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
    
    # elemento para separar em dois arrays, 'pivô'
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

ler_linha:
    la $t0, linha_buf
    li $t1, 0
    
	# ler caractere
le_char:
    li $v0, 14
    add $a0, $s0, $zero
    la $a1, byte_lido
    li $a2, 1
    syscall
    
    # verificação para verificar se houve erro na leitura
    slt $t2, $v0, $zero
    bne $t2, $zero, fim_linha
    
    # aqui para veirficar se chegou ao final do arquivo
    beq $v0, $zero, verifica_conteudo
    
    lb $t2, byte_lido
    li $t3, 10 # new line
    beq $t2, $t3, fim_linha
    
    #armazena o caractere lido durante o loop
    add $t4, $t0, $t1
    sb $t2, 0($t4)
    addi $t1, $t1, 1
    
    # verificação se não é maior que o tamanho do 'buffer'
    li $t5, 30
    bne $t1, $t5, le_char
    
    j fim_linha

verifica_conteudo:
    # se chegou ao final do arquivo, mas por alguma razao leu alguns caracteres, considera como linha válida
    bne $t1, $zero, fim_linha
    # caso nada foi lido, retorna 0
    add $v0, $zero, $zero
    jr $ra
    
fim_linha:
    # adiciona o terminador nulo (NULL)
    add $t4, $t0, $t1
    sb $zero, 0($t4)
    # essa parte retorna o tamanho da linha lida
    add $v0, $t1, $zero
    jr $ra

# converte o 'string' para 'float'
str_para_float:
    add $t0, $a0, $zero
    li $t1, 0 # parte inteira
    li $t2, 0 # parte decimal
    li $t3, 0 # divisor
    li $t4, 1 # sinal
    li $t5, 0 # flag
    lb $t6, 0($t0)
    li $t7, 45 # '-'
    bne $t6, $t7, conv_digitos
    li $t4, -1
    addi $t0, $t0, 1
    
conv_digitos:
    lb $t6, 0($t0)
    beq $t6, $zero, fim_conv
    li $t7, 46 # '.'
    beq $t6, $t7, decimal_flag
    li $t7, 48 # '0'
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

    # converte para 'float', usando soma sucessiva, começa com zero, 1.0 para somar e copia a parte inteira
fim_conv:
    l.s $f0, flt_zero
    l.s $f1, flt_um
    add $t0, $t1, $zero
    
int_para_float:
    beq $t0, $zero, processa_decimal_conv
    add.s $f0, $f0, $f1	# adiciona 1.0
    addi $t0, $t0, -1
    j int_para_float
    
processa_decimal_conv:
    beq $t3, $zero, aplica_sinal
    
    # converte 'int' para 'float' usando soma sucessiva
    l.s $f2, flt_zero
    l.s $f3, flt_um
    add $t0, $t2, $zero 
    
decimal_para_float:
    beq $t0, $zero, divide_decimal
    add.s $f2, $f2, $f3    # adiciona 1.0
    addi $t0, $t0, -1
    j decimal_para_float
    
divide_decimal:
    # converte 'divisor' para 'float' usando soma sucessiva
    l.s $f4, flt_zero
    l.s $f5, flt_um
    add $t0, $t3, $zero
    
divisor_para_float:
    beq $t0, $zero, fazer_divisao
    add.s $f4, $f4, $f5 # adiciona 1.0
    addi $t0, $t0, -1
    j divisor_para_float
    
# faz a divisão com 'decimal / divisor' e 'int + decimal'
fazer_divisao:
    div.s $f2, $f2, $f4
    add.s $f0, $f0, $f2
    
aplica_sinal:
    li $t7, -1
    bne $t4, $t7, fim_str_float
    l.s $f1, flt_zero
    sub.s $f0, $f1, $f0
    
fim_str_float:
    jr $ra

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
    
    # verifica se é negativo
    l.s $f0, flt_zero
    c.lt.s $f12, $f0
    bc1f positivo
    li $t0, 45 # '-'
    sb $t0, 0($a0)
    addi $a0, $a0, 1
    sub.s $f12, $f0, $f12

    # multiplica por 100000 com 'flt_dec', truncar (apenas usa a parte int) usando subtrações e depois divide
positivo:
    l.s $f1, flt_dec
    mul.s $f2, $f12, $f1 # número * 100000
    
    # trunca para inteiro usando subtrações sucessivas de 1.0
    li $t1, 0 # será nosso "inteiro truncado"
    l.s $f3, flt_um # 1.0
    
truncar_loop:
    c.lt.s $f2, $f3 # se número < 1.0, terminou
    bc1t fim_truncar
    sub.s $f2, $f2, $f3 # número = número - 1.0
    addi $t1, $t1, 1 # incrementa inteiro
    j truncar_loop
    
fim_truncar:
    # agora no final '$t1' contém (número_original * 100000) truncado
    # Dividir por 100000 para separar parte inteira e decimal
    
    li $t2, 100000
    div $t1, $t2
    mflo $t3 # parte inteira
    mfhi $t4 # parte decimal * 100000
    
    # converte a parte inteira
    add $t5, $zero, $a0
    beq $t3, $zero, zero_inteiro
    
conv_int:
    li $t6, 10
    div $t3, $t6
    mfhi $t7 # dígito
    mflo $t3 # resto
    addi $t7, $t7, 48 # converte para ASCII e transforma num em caractere
    sb $t7, 0($a0)
    addi $a0, $a0, 1
    bne $t3, $zero, conv_int
    j inverter
    
zero_inteiro:
    li $t7, 48 # '0' inteiro
    sb $t7, 0($a0)
    addi $a0, $a0, 1
    
    # parte para inverter a parte inteira
inverter:
    sub $t6, $a0, $t5
    addi $t6, $t6, -1
    add $t3, $zero, $t6
    
inv_loop:
    slt $at, $zero, $t3
    beq $at, $zero, decimal
    lb $t7, 0($t5)
    lb $t1, -1($a0)
    sb $t1, 0($t5)
    sb $t7, -1($a0)
    addi $t5, $t5, 1
    addi $a0, $a0, -1
    addi $t3, $t3, -2
    j inv_loop
    
    # processa a parte decimal se não for zero
decimal:
    beq $t4, $zero, fim_float_para_str
    
    # remove zeros a direita com máximo de 5 digitos decimais
    li $t6, 5
remove_zeros:
    li $t7, 10
    div $t4, $t7
    mfhi $t1 # resto
    bne $t1, $zero, escrever_decimais # se resto for diferente de 0, para de remover
    mflo $t4 # quociente
    addi $t6, $t6, -1 # diminui contador
    bne $t6, $zero, remove_zeros
    
escrever_decimais:
    beq $t6, $zero, fim_float_para_str
    
    li $t0, 46 # '.'
    sb $t0, 0($a0)
    addi $a0, $a0, 1
    
    # parte para calcular o divisor que vai ser usado, com base no número de dígitos
    li $t7, 1
    add $t1, $t6, $zero
calc_divisor:
    beq $t1, $zero, escrever_digs
    li $t0, 10
    mult $t7, $t0
    mflo $t7
    addi $t1, $t1, -1
    j calc_divisor
    
escrever_digs:
    li $t0, 10
    div $t7, $t0 # ajustar o divisor
    mflo $t7
    
loop_dig:
    beq $t6, $zero, fim_float_para_str
    div $t4, $t7
    mflo $t1 # dígito
    mfhi $t4 # resto
    addi $t1, $t1, 48 # ASCII
    sb $t1, 0($a0)
    addi $a0, $a0, 1
    
    li $t0, 10
    div $t7, $t0
    mflo $t7 # próximo divisor
    addi $t6, $t6, -1
    j loop_dig
    
fim_float_para_str:
    li $t0, 0
    sb $t0, 0($a0) # terminador nulo (NULL)
    
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












