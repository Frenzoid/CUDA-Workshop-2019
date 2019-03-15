
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <iostream>

void suma_vectores_gpu(float* pA, float* pB, float* pC, const int cN) {
	int idX_ = blockIdx.x * blockDim.x + threadIdx.x ; // La formula para atacar memorias = blockIdx.x * blockDim.x + threadIdx.x (la x es para porque es unidimensional (viene de un struct interno)).
	pC[idX_] = pA[idX_] + pB[idX_];
}

void suma_vectores(float* pA, float* pB, float* pC, const int cN) { // Funcion que suma vectores.
	for (unsigned int i = 0; i < cN; i++) {
		pC[i] = pA[i] + pB[i];
	}
}

int main(void) {
	const int kNumElemets = 25600;
	const size_t kNumBytes = kNumElemets * sizeof(float);

	// PASO 0: Seleccionar el dispositivo (tarjeta grafica).
	cudaSetDevice(0); // Tarjeta 0, primera tarjeta que usa el dispositivo.

	// PASO 1: Declaracion de memoria en la GPU.
	float* d_a_ = NULL; // Por convencion se inicializa a NULL.
	float* d_b_ = NULL; // La d_ especifica que la variable se alojará en la GPU (es un convenio en CUDA).
	float* d_c_ = NULL;

	cudaMalloc((void **)&d_a_, kNumBytes); // La GPU no entiende de tipos, por ello hay que castear a void, usamos & para pasar el puntero.
	cudaMalloc((void **)&d_b_, kNumBytes); // cudaMalloc es igual que malloc pero en la RAM de la GPU (VRAM).
	cudaMalloc((void **)&d_c_, kNumBytes); 

	float* h_a_ = (float *)malloc(kNumBytes); // La h_ especifica que la variable se alojará en la CPU (es un convenio en CUDA).
	float* h_b_ = (float *)malloc(kNumBytes); // malloc allocates the requested memory and returns a pointer to it.
	float* h_c_ = (float *)malloc(kNumBytes);

	if (h_a_ == NULL || h_b_ == NULL || h_c_ == NULL) { // Comprobamos que el ordenador tiene memoria suficiente par alojar las variables.
		std::cerr << "Fallo al reservar la memoria";
		getchar();
		exit(-1);
	}

	for (unsigned int i = 0; i < kNumElemets; i++) { // Rellenamos los vectores con datos aleatorios.
		h_a_[i] = rand() / (float)RAND_MAX;
		h_b_[i] = rand() / (float)RAND_MAX;
	}

	// PASO 2: Copia de datos CPU a GPU.
	cudaMemcpy(d_a_, h_a_, kNumBytes, cudaMemcpyHostToDevice); // Destino, Origen, Cantidad de bytes a copiar, flag que especifica en que direccion (de CPU a GPU).
	cudaMemcpy(d_b_, h_b_, kNumBytes, cudaMemcpyHostToDevice);

	// PASO 3: Lanzar kernel (ejecutar computo).
	// FORMULA PARA LA DIRECCIONACION DE LA POSICION DE MEMORIA: 

	//suma_vectores(h_a_, h_b_, h_c_, kNumElemets);

	const int thread_per_block_ = 256;
	const int blocks_per_grid_ = kNumElemets / thread_per_block_;

	dim3 tpb_(thread_per_block_, 1, 1);
	dim3 bpg_(blocks_per_grid_, 1, 1);

}
