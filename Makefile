ELM = elm
OUTPUT = build/elm.js
SRC = src/elm/Main.ELM

all: install live

api:
	@echo "Setting up mock API server..."
	@json-server --watch src/server/db.json || \
	npm install -g json-server && json-server --watch src/server/db.json

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
