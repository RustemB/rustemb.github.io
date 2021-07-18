all: opt

build:
	elm make src/Main.elm --optimize --output=elm.js

opt: build
	google-closure-compiler -O ADVANCED elm.js --js_output_file elm.opt.js
	mv elm.opt.js elm.js
