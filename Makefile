all: opt

build:
	@echo "Compiling source code..."
	@elm make src/Main.elm --optimize --output=elm.js > /dev/null

opt: build
	@echo "Optimizing..."
	@google-closure-compiler -O ADVANCED elm.js --js_output_file elm.opt.js 2> /dev/null
	@mv elm.opt.js elm.js
