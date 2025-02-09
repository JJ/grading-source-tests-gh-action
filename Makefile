OS := $(shell uname)

all: fatpack

installdeps:
	cpanm --installdeps .

fatpack:
	@if [ OS = "Darwin" ]; then\
		echo "No sabemos si fatpack funciona bien en ${OS}";\
	else\
		fatpack pack iv-checks-on-source.pl > dist/iv-checks-on-source.pl;\
	fi

