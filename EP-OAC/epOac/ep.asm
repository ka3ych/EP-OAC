.data
    arq_nome:     .asciiz "C:/Users/isacm/Downloads/ALAN/EP-OAC/epOac/Arquivos_de_numero/10numeros.txt"
    msg_ord:      .asciiz "\n\nELEMENTOS ORDENADOS\n\n"
    newline:      .asciiz "\n"
    
    byte_lido:    .space 1
    linha_buf:    .space 32
    
    flt_zero:     .float 0.0
    flt_dec:      .float 100000.0
    flt_um:       .float 1.0
    
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
    li $s7, 0              # flag para indicar se há conteúdo na linha atual

# Loop que conta as linhas do arquivo
le_loop:
    li $v0, 14
    add $a0, $s0, $zero
    la $a1, byte_lido
    li $a2, 1
    syscall
    
    slt $t0, $v0, $zero
    bne $t0, $zero, fim_arq
    beq $v0, $zero, verifica_ultima_linha
    
    lb $t0, byte_lido
    li $t1, 10             # '\n'
    beq $t0, $t1, incrementa_linha
    
    # Se não é \n, marca que há conteúdo na linha
    li $s7, 1
    j le_loop

incrementa_linha:
    addi $s1, $s1, 1
    li $s7, 0              # reseta flag de conteúdo
    j le_loop

verifica_ultima_linha:
    # Se há conteúdo na última linha (sem \n), conta ela também
    beq $s7, $zero, fim_arq
    addi $s1, $s1, 1

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

    # Converte float para string - VERSÃO SIMPLIFICADA
    la $a0, linha_buf
    
    # Limpa buffer primeiro
    li $t8, 0
limpa_buffer:
    add $t9, $a0, $t8
    sb $zero, 0($t9)
    addi $t8, $t8, 1
    li $s6, 32
    bne $t8, $s6, limpa_buffer
    
    # Chama conversão
    jal float_para_str_simples
    
    # Calcula tamanho manualmente para evitar erro
    la $t4, linha_buf
    li $t5, 0
    
calc_tam_loop:
    add $t6, $t4, $t5
    lb $t7, 0($t6)
    beq $t7, $zero, fim_calc_tam
    addi $t5, $t5, 1
    li $t8, 31              # limite de segurança
    beq $t5, $t8, fim_calc_tam
    j calc_tam_loop
    
fim_calc_tam:
    # Se não encontrou nada, usa tamanho mínimo
    bne $t5, $zero, escreve_numero
    li $t5, 1               # tamanho mínimo
    
escreve_numero:
    # Escreve numero com tamanho calculado
    li $v0, 15
    add $a0, $s4, $zero
    la $a1, linha_buf
    add $a2, $t5, $zero
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

#FUNCAO ORDENA
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

# Função corrigida para ler uma linha do arquivo
ler_linha:
    la $t0, linha_buf
    li $t1, 0
    
le_char:
    li $v0, 14
    add $a0, $s0, $zero
    la $a1, byte_lido
    li $a2, 1
    syscall
    
    # Verifica se houve erro na leitura
    slt $t2, $v0, $zero
    bne $t2, $zero, fim_linha
    
    # Verifica se chegou ao fim do arquivo (EOF)
    beq $v0, $zero, verifica_conteudo
    
    lb $t2, byte_lido
    li $t3, 10             # '\n'
    beq $t2, $t3, fim_linha
    
    # Armazena o caractere lido
    add $t4, $t0, $t1
    sb $t2, 0($t4)
    addi $t1, $t1, 1
    
    # Verifica se não excedeu o tamanho do buffer
    li $t5, 30
    bne $t1, $t5, le_char
    
    j fim_linha

verifica_conteudo:
    # Se chegou ao EOF mas leu alguns caracteres, considera como linha válida
    bne $t1, $zero, fim_linha
    # Se não leu nada, retorna 0
    add $v0, $zero, $zero
    jr $ra
    
fim_linha:
    # Adiciona terminador nulo
    add $t4, $t0, $t1
    sb $zero, 0($t4)
    # Retorna o tamanho da linha lida
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
    # Converte para float usando soma sucessiva em vez de cvt.s.w
    l.s $f0, flt_zero      # começa com 0.0
    l.s $f1, flt_um        # 1.0 para somar
    add $t0, $t1, $zero    # copia parte inteira
    
int_para_float:
    beq $t0, $zero, processa_decimal_conv
    add.s $f0, $f0, $f1    # adiciona 1.0
    addi $t0, $t0, -1
    j int_para_float
    
processa_decimal_conv:
    beq $t3, $zero, aplica_sinal
    
    # Converte parte decimal usando soma sucessiva
    l.s $f2, flt_zero      # parte decimal em float
    l.s $f3, flt_um        # 1.0
    add $t0, $t2, $zero    # copia parte decimal
    
decimal_para_float:
    beq $t0, $zero, divide_decimal
    add.s $f2, $f2, $f3    # adiciona 1.0
    addi $t0, $t0, -1
    j decimal_para_float
    
divide_decimal:
    # Converte divisor para float usando soma sucessiva
    l.s $f4, flt_zero      # divisor em float
    l.s $f5, flt_um        # 1.0
    add $t0, $t3, $zero    # copia divisor
    
divisor_para_float:
    beq $t0, $zero, fazer_divisao
    add.s $f4, $f4, $f5    # adiciona 1.0
    addi $t0, $t0, -1
    j divisor_para_float
    
fazer_divisao:
    div.s $f2, $f2, $f4    # decimal / divisor
    add.s $f0, $f0, $f2    # inteira + decimal
    
aplica_sinal:
    li $t7, -1
    bne $t4, $t7, fim_str_float
    l.s $f1, flt_zero
    sub.s $f0, $f1, $f0
    
fim_str_float:
    jr $ra

# Função float_para_str SEM cvt.s.w e cvt.w.s
float_para_str_sem_cvt:
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
    bc1f positivo_sem_cvt
    li $t0, 45             # '-'
    sb $t0, 0($a0)
    addi $a0, $a0, 1
    sub.s $f12, $f0, $f12
    
positivo_sem_cvt:
    # MÉTODO: Multiplicar por 100000, truncar usando subtrações e depois dividir
    l.s $f1, flt_dec       # 100000.0
    mul.s $f2, $f12, $f1   # número × 100000
    
    # Truncar para inteiro usando subtrações sucessivas de 1.0
    li $t1, 0              # será nosso "inteiro truncado"
    l.s $f3, flt_um        # 1.0
    
truncar_loop_sem_cvt:
    c.lt.s $f2, $f3        # se número < 1.0, terminou
    bc1t fim_truncar_sem_cvt
    sub.s $f2, $f2, $f3    # número = número - 1.0
    addi $t1, $t1, 1       # incrementa inteiro
    j truncar_loop_sem_cvt
    
fim_truncar_sem_cvt:
    # Agora $t1 contém (número_original × 100000) truncado
    # Dividir por 100000 para separar parte inteira e decimal
    
    li $t2, 100000
    div $t1, $t2
    mflo $t3               # parte inteira
    mfhi $t4               # parte decimal × 100000
    
    # Converte parte inteira
    add $t5, $zero, $a0    # salva posição inicial
    beq $t3, $zero, zero_inteiro_sem_cvt
    
conv_int_sem_cvt:
    li $t6, 10
    div $t3, $t6
    mfhi $t7               # dígito
    mflo $t3               # resto
    addi $t7, $t7, 48      # converte para ASCII
    sb $t7, 0($a0)
    addi $a0, $a0, 1
    bne $t3, $zero, conv_int_sem_cvt
    j inverter_sem_cvt
    
zero_inteiro_sem_cvt:
    li $t7, 48             # '0'
    sb $t7, 0($a0)
    addi $a0, $a0, 1
    
inverter_sem_cvt:
    # Inverte a parte inteira
    sub $t6, $a0, $t5
    addi $t6, $t6, -1
    add $t3, $zero, $t6
    
inv_loop_sem_cvt:
    slt $at, $zero, $t3
    beq $at, $zero, decimal_sem_cvt
    lb $t7, 0($t5)
    lb $t1, -1($a0)
    sb $t1, 0($t5)
    sb $t7, -1($a0)
    addi $t5, $t5, 1
    addi $a0, $a0, -1
    addi $t3, $t3, -2
    j inv_loop_sem_cvt
    
decimal_sem_cvt:
    # Processa parte decimal se não for zero
    beq $t4, $zero, fim_sem_cvt
    
    # Remove zeros à direita
    li $t6, 5              # máximo 5 dígitos decimais
remove_zeros_sem_cvt:
    li $t7, 10
    div $t4, $t7
    mfhi $t1               # resto
    bne $t1, $zero, escrever_decimais_sem_cvt # se resto != 0, para de remover
    mflo $t4               # quociente
    addi $t6, $t6, -1      # diminui contador
    bne $t6, $zero, remove_zeros_sem_cvt
    
escrever_decimais_sem_cvt:
    beq $t6, $zero, fim_sem_cvt
    
    li $t0, 46             # '.'
    sb $t0, 0($a0)
    addi $a0, $a0, 1
    
    # Calcula divisor apropriado baseado no número de dígitos
    li $t7, 1
    add $t1, $t6, $zero
calc_divisor_sem_cvt:
    beq $t1, $zero, escrever_digs_sem_cvt
    li $t0, 10
    mult $t7, $t0
    mflo $t7
    addi $t1, $t1, -1
    j calc_divisor_sem_cvt
    
escrever_digs_sem_cvt:
    li $t0, 10
    div $t7, $t0           # ajusta divisor
    mflo $t7
    
loop_dig_sem_cvt:
    beq $t6, $zero, fim_sem_cvt
    div $t4, $t7
    mflo $t1               # dígito
    mfhi $t4               # resto
    addi $t1, $t1, 48      # ASCII
    sb $t1, 0($a0)
    addi $a0, $a0, 1
    
    li $t0, 10
    div $t7, $t0
    mflo $t7               # próximo divisor
    addi $t6, $t6, -1
    j loop_dig_sem_cvt
    
fim_sem_cvt:
    li $t0, 0
    sb $t0, 0($a0)         # terminador nulo
    
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

# Função float_para_str - VERSÃO HÍBRIDA (funcional + sem cvt)
float_para_str_simples:
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
    bc1f positivo_hibrido
    li $t0, 45             # '-'
    sb $t0, 0($a0)
    addi $a0, $a0, 1
    sub.s $f12, $f0, $f12
    
positivo_hibrido:
    # USAR O MÉTODO ORIGINAL MAS SUBSTITUIR CVT POR OPERAÇÕES MANUAIS
    
    # Separar parte inteira usando truncamento manual
    add.s $f1, $f12, $f0   # f1 = número original
    
    # Extrair parte inteira por subtrações de 1.0
    li $t1, 0              # contador da parte inteira
    l.s $f2, flt_um        # 1.0
    
extrair_inteira_hibrido:
    c.lt.s $f1, $f2        # se número < 1.0, terminou
    bc1t calcular_decimal_hibrido
    sub.s $f1, $f1, $f2    # número = número - 1.0
    addi $t1, $t1, 1       # incrementa parte inteira
    j extrair_inteira_hibrido
    
calcular_decimal_hibrido:
    # $t1 = parte inteira, $f1 = parte decimal
    
    # Reconstroi a parte inteira como float usando somas
    l.s $f3, flt_zero      # começar com 0.0
    l.s $f4, flt_um        # 1.0 para somar
    add $t0, $t1, $zero    # copia parte inteira
    
reconstruir_float_hibrido:
    beq $t0, $zero, subtrair_decimal_hibrido
    add.s $f3, $f3, $f4    # adiciona 1.0
    addi $t0, $t0, -1
    j reconstruir_float_hibrido
    
subtrair_decimal_hibrido:
    # $f3 agora tem a parte inteira como float
    sub.s $f2, $f12, $f3   # f2 = parte decimal precisa
    
    # Multiplica parte decimal por 100000
    l.s $f5, flt_dec       # 100000.0
    mul.s $f2, $f2, $f5    # decimal × 100000
    
    # Extrai como inteiro usando subtrações
    li $t2, 0
    l.s $f6, flt_um
    
extrair_decimal_int_hibrido:
    c.lt.s $f2, $f6
    bc1t processar_numeros_hibrido
    sub.s $f2, $f2, $f6
    addi $t2, $t2, 1
    j extrair_decimal_int_hibrido
    
processar_numeros_hibrido:
    # Agora temos: $t1 = parte inteira, $t2 = parte decimal × 100000
    
    add $t3, $zero, $a0    # salva posição inicial
    beq $t1, $zero, escrever_zero_hibrido
    
# Converte parte inteira normalmente
conv_int_hibrido:
    li $t4, 10
    div $t1, $t4
    mfhi $t5               # dígito
    mflo $t1               # resto
    addi $t5, $t5, 48      # ASCII
    sb $t5, 0($a0)
    addi $a0, $a0, 1
    bne $t1, $zero, conv_int_hibrido
    j inverter_hibrido
    
escrever_zero_hibrido:
    li $t5, 48             # '0'
    sb $t5, 0($a0)
    addi $a0, $a0, 1
    
# Inverte parte inteira
inverter_hibrido:
    sub $t6, $a0, $t3
    addi $t6, $t6, -1
    add $t4, $zero, $t6
    
inv_loop_hibrido:
    slt $at, $zero, $t4
    beq $at, $zero, decimal_hibrido
    lb $t5, 0($t3)
    lb $t1, -1($a0)
    sb $t1, 0($t3)
    sb $t5, -1($a0)
    addi $t3, $t3, 1
    addi $a0, $a0, -1
    addi $t4, $t4, -2
    j inv_loop_hibrido

# Processa parte decimal
decimal_hibrido:
    beq $t2, $zero, fim_hibrido
    
    li $t0, 46             # '.'
    sb $t0, 0($a0)
    addi $a0, $a0, 1
    
    add $t6, $zero, $t2
    li $t4, 10000
    li $t7, 5
    
# Remove zeros à direita
remove_zeros_hibrido:
    li $t5, 10
    div $t6, $t5
    mfhi $t1                     
    bne $t1, $zero, escrever_decimais_hibrido
    mflo $t6    
    div $t4, $t5
    mflo $t4
    addi $t7, $t7, -1
    slt $at, $zero, $t7
    bne $at, $zero, remove_zeros_hibrido
    
escrever_decimais_hibrido:
    beq $t7, $zero, fim_hibrido
    
loop_decimais_hibrido:
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
    bne $at, $zero, loop_decimais_hibrido
    
fim_hibrido:
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
