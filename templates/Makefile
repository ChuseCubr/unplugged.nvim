cc := gcc.exe
cflags := -Wall -Wextra -Werror

src := src/main.c
target := build/out

$(target): $(src)
	$(cc) $(src) $(cflags) -o $(target)

run: $(target)
	./$(target)
