BIN=~/.local/bin

install:
	@echo copying script to ${BIN}
	@cp shelldrop.sh ${BIN}/shelldrop
	@chmod 711 ${BIN}/shelldrop
