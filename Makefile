DEST = ${HOME}

all:

tsk: tsk.sh
	cat tsk.sh > tsk
	chmod +x tsk

install: all
	mv tsk $(DEST)/bin

clean:
	rm -f tsk
