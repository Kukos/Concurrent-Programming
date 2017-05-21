GOCMD=go
GOBUILD=$(GOCMD) build
GOINSTALL=$(GOCMD) install

packages=train configs client myswitch track graph driver fifo
main=main
EXEC=main

all: $(EXEC)

$(EXEC):
	$(GOBUILD) $(packages) && \
	$(GOBUILD) -o $(EXEC) $(main)

clean:
	rm -f $(EXEC)
