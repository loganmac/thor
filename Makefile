ELM = elm
OUTPUT = build/elm.js
SRC = src/elm/Main.ELM

all: install live

build:
	elm-make $(SRC) --output=$(OUTPUT)

install:
	elm-package install -y

live:
	@echo "Setting up live server..."
	@elm-live $(SRC) --output=$(OUTPUT) --open --debug || \
	npm install -g elm elm-live && elm-live $(SRC) --output=$(OUTPUT) --open --debug

clean:
	@echo "Removing build artifacts..."
	@rm -rf ./elm-stuff/build-artifacts && \
	rm -rf ./build
	@echo "Cleaned successfully."
