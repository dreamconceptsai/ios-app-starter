.PHONY: setup generate open test clean

## setup: install the command-line tools this project needs
setup:
	brew install xcodegen

## generate: create StarterApp.xcodeproj from project.yml
generate:
	xcodegen generate

## open: generate the project and open it in Xcode
open: generate
	open StarterApp.xcodeproj

## test: run unit and UI tests on a simulator
test:
	./scripts/test.sh

## clean: remove the generated project and build output
clean:
	rm -rf StarterApp.xcodeproj DerivedData build
