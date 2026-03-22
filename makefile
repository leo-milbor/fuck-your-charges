# Makefile

# Variables
FLUTTER=flutter

.PHONY: ci analyze test test-coverage format-check

# Existing targets
run:
	$(FLUTTER) run

build:
	$(FLUTTER) build

# New targets
ci:
	$(FLUTTER) pub get
	$(FLUTTER) analyze
	$(FLUTTER) test
	$(FLUTTER) test --coverage

analyze:
	$(FLUTTER) analyze

test:
	$(FLUTTER) test
test-coverage:
	$(FLUTTER) test --coverage

format-check:
	$(FLUTTER) format --set-exit-if-changed .
