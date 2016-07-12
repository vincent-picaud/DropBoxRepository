all: bench

bench: libjaccard.so
	@julia --optimize --check-bounds=no jaccard.jl

libjaccard.so: jaccard.c
	@gcc -O2 -shared -fPIC jaccard.c -o libjaccard.so

