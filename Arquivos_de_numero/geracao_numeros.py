import random

def generate_random_numbers(n):
    """
    Gera 'n' números aleatórios no intervalo [1, 10) com sinal aleatório
    e precisão de até 5 casas decimais.
    """
    numbers = []
    for _ in range(n):
        num = random.uniform(1, 10 - 1e-9)
        
        if random.choice([True, False]):
            num = -num
        
        numbers.append(f"{num:.5f}")
    return numbers

# Configuração
random.seed(42)
sizes = [10, 50, 100, 1000]

# Gera arquivos
for size in sizes:
    data = generate_random_numbers(size)
    with open(f"{size}numeros.txt", "w", encoding="utf-8") as f:
        f.write("\n".join(data))