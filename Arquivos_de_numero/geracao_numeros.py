import random

def generate_random_numbers(n):
    numbers = []
    for _ in range(n):
        # Gera numero positivo entre 1 (inclusive) e 10 (exclusive)
        num = random.uniform(1, 10 - 1e-9)  
        # ultima parte evita arredondamento para 10.0
        
        # sinal positivo ou negativo
        if random.choice([True, False]):
            num = -num
        
        # Formata para 5 casas decimais
        numbers.append(f"{num:.5f}")
    return numbers

# Configuracao
random.seed(42)
sizes = [100, 1000, 10000]

# Gera arquivos
for size in sizes:
    data = generate_random_numbers(size)
    with open(f"{size}numeros.txt", "w", encoding="utf-8") as f:
        f.write("\n".join(data))