import matplotlib.pyplot as plt

sizes = [10, 50, 100, 1000]

# Tempos em segundos
bubble_times = [
    7.4122129,
    37.8775598,
    184.1572539,
    1863.1527325
]

quick_times = [
    7.4119473,
    37.6228547,
    72.1971946,
    726.4974244
]

# Plot
plt.figure(figsize=(10, 6))
plt.plot(sizes, bubble_times, label='Bubble Sort', marker='o')
plt.plot(sizes, quick_times, label='Quick Sort', marker='s')

plt.xlabel('Tamanho do vetor')
plt.ylabel('Tempo de execução (s)')
plt.title('Comparação de tempo: Bubble Sort vs Quick Sort')
plt.legend()
plt.grid(True)
plt.xticks(sizes)
plt.tight_layout()

plt.savefig("comparacao_sort.png", dpi=300)

plt.show()
