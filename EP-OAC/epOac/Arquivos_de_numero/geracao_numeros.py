# -*- coding: utf-8 -*-
"""
Geração de números de entrada para os códigos de algoritmos de ordenação
"""

import random

def generate_random_numbers(n):
    """
    Gera 'n' números aleatórios no intervalo [1, 10) com sinal aleatório
    e precisão de até 5 casas decimais.
    """
    numbers = []
    for _ in range(n):
        # Gera número positivo entre 1 (inclusive) e 10 (exclusive)
        num = random.uniform(1, 10 - 1e-9)  # Evita arredondamento para 10.0
        
        # Escolhe sinal aleatório (positivo ou negativo)
        if random.choice([True, False]):
            num = -num
        
        # Formata para 5 casas decimais
        numbers.append(f"{num:.5f}")
    return numbers

# Configuração
random.seed(42)  # Garante reprodutibilidade
sizes = [10, 100, 10000]    # 1000 numeros fornecido pelo professor

# Gera arquivos
for size in sizes:
    data = generate_random_numbers(size)
    with open(f"{size}numeros.txt", "w") as f:
        f.write("\n".join(data))