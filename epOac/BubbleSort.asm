.data
	#ler arquivo
	# tem que usar caminho absoluto, se nao essa joca n�o funciona
	ArquivoLocal: .asciiz "/home/karina/Documentos/mars/epOac/ArquivoLeitura.txt"
	ConteudoArquivo: .space 1024 # espa�o para ler
	ErroAbrir: .asciiz "Erro: arquivo nao encontrado ;("
	

	##lw l� o conteudo da RAM e coloca na CPU
	##sw escreve o conteudo de um registrador da CPU na RAM
	
	##Bubble sort
	.align 2   # for�a alinhamento para palavras 2^2 (4 bytes)
	Vetor: .space 400 # vetor para 100 floats de 400 bytes
	TamVetor: .word 0 # tam do vetor que vai ser preenchido
	Espaco: .asciiz " " # espa�o para separar os n�meros na impress�o
	
.text	
	# abrir arquivo
	li $v0, 13 # solicita abertura
	la $a0, ArquivoLocal # endereco do arquivo em $a0
	li $a1, 0 #0 para leitura, 1 para escrita
	syscall # descritor do arquivo vai para $v0
	move $s0, $v0 #copia do descritor
	
	# apois abrir arquivo vai continuar se tudo ok e vai dar erro se der problema
	bgez $s0, AbriuCerto
	la $a0, ErroAbrir
	li $v0, 4
	syscall
	j FecharArquivo

    AbriuCerto:
	# ler arquivo
	li $v0, 14 # ler conteudo do arquivo de $a0
	move $a0, $s0 # descritor em $a0
	la $a1, ConteudoArquivo # buffer de armazenamento
	li $a2, 1023 # tamanho do buffer, tem que ser maior que o arquivo
	syscall # leitura realizada
	
	# null terminator
	la $t0, ConteudoArquivo
	add $t0, $t0, $v0 # posicao final
	sb $zero, 0($t0) # armazena 0 no final
	
	

	# converter de string para float
	la $s1, ConteudoArquivo  # endere�o do conte�do
	la $s2, Vetor            # endere�o do vetor
	li $s3, 0                # contador de n�meros (tam)
	
    loopConversao:
	lb $t5, 0($s1)        # carrega caractere
	beqz $t5, fimConversao # termina se null
		
	# Ignora espa�os/quebras
	li $t6, ' '
	beq $t5, $t6, avanca
	li $t6, '\n'
	beq $t5, $t6, avanca
	li $t6, '\r'
	beq $t5, $t6, avanca
	li $t6, '\t'
	beq $t5, $t6, avanca
		
	# Processa n�mero
	li $t7, 0 # sinal (1=negativo)
	li $t8, 0 # parte inteira
	li $t9, 0 # parte decimal
	li $s4, 0 # casas decimais
	li $s5, 0 # flag ponto
		
	# Verifica sinal
	bne $t5, '-', positivo
	li $t7, 1             # marca negativo
	addi $s1, $s1, 1      # avan�a caractere
	lb $t5, 0($s1)
	
    positivo:
		
	# Loop inteiros
    loopInteiro:
	blt $t5, '0', pontoDecimal
	bgt $t5, '9', pontoDecimal
	mul $t8, $t8, 10
	addi $t5, $t5, -48
	add $t8, $t8, $t5
	addi $s1, $s1, 1
	lb $t5, 0($s1)
	j loopInteiro
		
	# Verifica ponto
    pontoDecimal:
	bne $t5, '.', fimNumero
	li $s5, 1 # marca ponto decimal
	addi $s1, $s1, 1
	lb $t5, 0($s1)
		
	# Loop decimais
    loopDecimal:
	blt $t5, '0', fimNumero
	bgt $t5, '9', fimNumero
	mul $t9, $t9, 10
	addi $t5, $t5, -48
	add $t9, $t9, $t5
	addi $s4, $s4, 1   # incrementa casas
	addi $s1, $s1, 1
	lb $t5, 0($s1)
	j loopDecimal
		
	# Combina partes
    fimNumero:
	mtc1 $t8, $f0
	cvt.s.w $f0, $f0 # inteiro para float
		
	beqz $s5, semDecimal
	mtc1 $t9, $f1
	cvt.s.w $f1, $f1
	# Calcula divisor (10^casas)
	li $s6, 10
	mtc1 $s6, $f2
	cvt.s.w $f2, $f2
	li $s6, 1
	mtc1 $s6, $f3
	cvt.s.w $f3, $f3
		
    loopDivisor:
	blez $s4, fimDivisor
	div.s $f3, $f3, $f2
	addi $s4, $s4, -1
	j loopDivisor

    fimDivisor:
	mul.s $f1, $f1, $f3  # decimal * divisor
	add.s $f0, $f0, $f1  # soma partes
		
    semDecimal:
	# Aplica sinal
	beqz $t7, armazena
	neg.s $f0, $f0
		
	# Armazena no vetor
    armazena:
	swc1 $f0, 0($s2)
	addi $s2, $s2, 4
	addi $s3, $s3, 1
	j loopConversao
		
    avanca:
	addi $s1, $s1, 1
	j loopConversao
		
    fimConversao:
	sw $s3, TamVetor        # atualiza tamanho
	
	# bubblesort
	la $t0, Vetor # carrega endere�o base do vetor
	lw $t1, TamVetor # carrega tamanho do vetor
	
	li $t2, 0 # inicializa contador (i = 0)

    loopI:
    	addi $t3, $t1, -1 # TamVetor - 1 (n - 1)
	bge $t2, $t3, imprime #  if(i >= TamVetor - 1) print
    
	li $t3, 0              # Inicializa cntador (j = 0)
	sub $t4, $t1, $t2      # TamVetor - i (n - i)
	addi $t4, $t4, -1      # TamVetor - i - 1 (n - i - 1)
	
    loopJ:
	bge $t3, $t4, fimJ # if j>= (TamVetor - i - 1), encerra loop
	
	sll $t5, $t3, 2 # $t5 recebe de $t3 o valor de j e desloca 2^2 bytes para a esquerda
	add $t5, $t0, $t5 # endereco de arr[j]
	lwc1 $f0, 0($t5) # carrega o valor na posicao atual (arr[j])
	lwc1 $f1, 4($t5) # carrega o valor na prox posicao (arr[j+1])
	
	# para pular a troca caso necessario
	c.lt.s $f1, $f0 # compare if $f1 p� less than $f0 com precisao simples if (arr[j] > arr[j+1]) (f1 < f0)
	bc1f semTroca # se condi��o falsa, n�o troca
    
	# fazer a troca
	swc1 $f1, 0($t5) # armazena o valor de arr[j+1] na atual arr [j] (arr[j] = arr[j+1])
	swc1 $f0, 4($t5) # armazena o valor de arr[j] na prox posicao arr[j+1] (arr[j+1] = arr[j])
    
    # loopJ
    semTroca:
    	# j++
	addi $t3, $t3, 1
	j loopJ

    fimJ:
	# i++
	addi $t2, $t2, 1
	j loopI

    imprime:
	li $t2, 0 # reinicia contador (i = 0)
	la $t0, Vetor # recarrega endere�o do vetor

    loopImpressao:
	bge $t2, $t1, fim # if(i >= tamanho) termina
    
	# carrega e imprime os elementos
	lwc1 $f12, 0($t0) # carrega float
	li $v0, 2 # imprime float
	syscall
    
	# Imprime espa�o
	li $v0, 4
	la $a0, Espaco
	syscall
    
	addi $t0, $t0, 4 # avan�a para pr�ximo elemento
	addi $t2, $t2, 1 # incrementa contador em 1
	j loopImpressao
	
    FecharArquivo:
	# fecha o arquivo
	li $v0, 16
	move $a0, $s0
	syscall
	
    fim:
    	# encerra
	li $v0, 10
	syscall
