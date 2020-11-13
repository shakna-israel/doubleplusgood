LIBLUA=`pkg-config --libs --cflags lua5.3`
INCLUDES=-Iinclude
OUTNAME=doublegoodplus
PREFIX=/usr/local/bin/

all: template.h
	$(CC) -g $(LIBLUA) $(INCLUDES) src/main.c -o $(OUTNAME)

.PHONY: install
install: all
	install $(OUTNAME) $(PREFIX)

.PHONY: template.h
template.h:
	-mkdir include
	xxd -i src/template.lua > include/template.h

clean:
	-rm include/template.h
	-rm $(OUTNAME)
