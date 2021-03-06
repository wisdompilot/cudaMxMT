PROJECT_DIR=.
BLOCK_DIM=8
OPTIMIZATION=-O3
cudaVersion=-arch=compute_30 -code=sm_30
oFLAG=-D BW$(BLOCK_DIM) --ptxas-options=-v -maxrregcount 60

all: MxMT.out
	
MxMT.out: MxMTagent.o main.o seqMatrix.o cudaMxMT.o cuBLAS_MxMT.o cudaGFlopTimer.o ompMxMT.o
	nvcc $(cudaVersion) $(OPTIMIZATION) $(oFLAG) \
	-lcublas -Xcompiler -fopenmp \
	$(PROJECT_DIR)/Debug/main.o \
	$(PROJECT_DIR)/Debug/MxMTagent.o \
	$(PROJECT_DIR)/Debug/seqMatrix.o \
	$(PROJECT_DIR)/Debug/cudaMxMT.o \
	$(PROJECT_DIR)/Debug/cuBLAS_MxMT.o \
	$(PROJECT_DIR)/Debug/cudaGFlopTimer.o \
	$(PROJECT_DIR)/Debug/ompMxMT.o \
	-o $(PROJECT_DIR)/Debug/MxMT.out$(BLOCK_DIM)

MxMTagent.o:
	nvcc -c $(cudaVersion) $(OPTIMIZATION) $(oFLAG) \
	-lcublas \
	$(PROJECT_DIR)/src/MxMTagent.cu \
	-o $(PROJECT_DIR)/Debug/MxMTagent.o

main.o: $(PROJECT_DIR)/src/main.cu
	nvcc -c $(cudaVersion) $(OPTIMIZATION) $(oFLAG) \
	$(PROJECT_DIR)/src/main.cu \
	-o $(PROJECT_DIR)/Debug/main.o
	
seqMatrix.o: $(PROJECT_DIR)/src/seqMatrix.cpp
	g++ -c $(PROJECT_DIR)/src/seqMatrix.cpp \
	-o $(PROJECT_DIR)/Debug/seqMatrix.o

cudaMxMT.o: $(PROJECT_DIR)/src/cudaMxMT.cu
	nvcc -c $(cudaVersion) $(OPTIMIZATION) $(oFLAG) \
	$(PROJECT_DIR)/src/cudaMxMT.cu \
	-o $(PROJECT_DIR)/Debug/cudaMxMT.o

cuBLAS_MxMT.o:
	nvcc -c $(cudaVersion) $(OPTIMIZATION) $(oFLAG) \
	$(PROJECT_DIR)/src/cuBLAS_MxMT.cu \
	-o $(PROJECT_DIR)/Debug/cuBLAS_MxMT.o -lcublas
	
cudaGFlopTimer.o:
	nvcc -c $(cudaVersion) $(OPTIMIZATION) $(oFLAG) \
	$(PROJECT_DIR)/src/cudaGFlopTimer.cu \
	-o $(PROJECT_DIR)/Debug/cudaGFlopTimer.o

ompMxMT.o:
	g++ -c -fopenmp \
	$(PROJECT_DIR)/src/ompMxMT.cpp \
	-o $(PROJECT_DIR)/Debug/ompMxMT.o
	

clean:
	rm -fr Debug/*.o Debug/*.out
	rm -fr src/*.o src/*.out
	rm -fr *.o *.out
	
run:
	srun -p gpudev -n 1 -t 00:10:00 ./Debug/outMxMT.out
	
	