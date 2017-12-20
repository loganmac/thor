ELM = elm

all: install start

api:
	@echo "Setting up mock API server..."
	@json-server --watch src/js/db.json --port 4000 || \
	npm install -g json-server && json-server --watch src/js/db.json --port 4000

deploy:
	@elm-app build && surge -p ./build -d nanobox-app-admin.surge.sh

clean:
	@echo "Removing build artifacts..."
	@rm -rf ./elm-stuff/build-artifacts && \
	rm -rf ./build
	@echo "Cleaned successfully."

install:
	elm-package install -y

start:
	@echo "Setting up live server..."
	@elm-app start || \
	npm install -g elm loganmac/create-elm-app && elm-app start
  # this is a holdover if/until they accept SCSS support for create-elm-app
	# upstream. for now it's just a fork that supports scss
