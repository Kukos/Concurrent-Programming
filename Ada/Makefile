GNATC=gnatmake

O_DIR=./obj
S_DIR=./src

SRC=$(wildcard $(S_DIR)/*.adb)
HDRS=$(wildcard $(S_DIR)/*.ads)

EXEC=main

$(EXEC): $(SRC) $(HDRS)
	$(GNATC) $(SRC) -O3 -D $(O_DIR)

clean:
	rm -f $(EXEC)
	rm -rf $(O_DIR)/*
