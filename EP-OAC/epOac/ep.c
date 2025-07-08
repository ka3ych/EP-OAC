#include <stdio.h>
#include <stdlib.h>

void ordena_quick(float vet[], int ini, int fim) {
    if (ini < fim) {
        int pivot, i, j;
        float temp;

        pivot = ini;
        i = ini;
        j = fim;

        while (i < j) {
            while (vet[i] <= vet[pivot] && i < fim) {
                i++;
            }
            while (vet[j] > vet[pivot]) {
                j--;
            }
            if (i < j) {
                temp = vet[i];
                vet[i] = vet[j];
                vet[j] = temp;
            }
        }

        temp = vet[pivot];
        vet[pivot] = vet[j];
        vet[j] = temp;

        ordena_quick(vet, ini, j - 1);
        ordena_quick(vet, j + 1, fim);
    }
}

void ordena_bubble(float *vet, int tam) {
    int i, j;
    float temp;
    
    for (i = 0; i < tam - 1; i++) {
        for (j = 0; j < tam - i - 1; j++) {
            if (vet[j] > vet[j + 1]) {
                temp = vet[j];
                vet[j] = vet[j + 1];
                vet[j + 1] = temp;
            }
        }
    }
}

float *ordena(int tam, int tipo, float *vet) {
    if (tipo == 1) {
        ordena_bubble(vet, tam);
    } else if (tipo == 2) {
        ordena_quick(vet, 0, tam - 1);
    }
    return vet;
}

int main() {
    FILE *arq;
    float *nums;
    int qtd = 0;
    int cap = 100;
    float temp;
    int i;
    int tipo_ord = 1; // 1 = bubble sort, 2 = quicksort

    nums = (float*)malloc(cap * sizeof(float));

    arq = fopen("numeros.txt", "r");
    if (!arq) {
        free(nums);
        return 1;
    }

    // Le numeros do arquivo
    while (fscanf(arq, "%f", &temp) == 1) {
        if (qtd >= cap) {
            cap *= 2;
            nums = (float*) realloc(nums, cap * sizeof(float));
        }
        nums[qtd] = temp;
        qtd++;
    }
    fclose(arq);

    nums = (float*) realloc(nums, qtd * sizeof(float));

    // Chama rotina de ordenacao
    nums = ordena(qtd, tipo_ord, nums);

    arq = fopen("numeros.txt", "a");
    fprintf(arq, "\n\nELEMENTOS ORDENADOS\n\n");
    
    for (i = 0; i < qtd; i++) {
        fprintf(arq, "%.5f\n", nums[i]);
    }

    fclose(arq);
    free(nums);

    return 0;
}