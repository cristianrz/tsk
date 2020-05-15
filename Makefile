DEST = ${HOME}/.local

all: tsk # tsk.1

tsk: tsk.sh
	cat tsk.sh > tsk
	chmod +x tsk

# tsk.1: tsk.md
# 	pandoc -s -f markdown -t man -o tsk.1 tsk.md

install: all
	mkdir -p $(DEST)/bin
	mv tsk $(DEST)/bin

	@# mkdir -p $(DEST)/man/man1
	@# mv tsk.1 $(DEST)/man/man1

uninstall:
	rm -f $(DEST)/bin/tsk $(DEST)/man/man1/tsk.1

clean:
	rm -f tsk tsk.1
