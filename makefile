# Makefile

# Variables
FLUTTER=flutter

.PHONY: ci analyze test test-coverage format-check build-android build-apk build-appbundle

# Existing targets
run:
	$(FLUTTER) run

build-android: build-apk build-appbundle

build-apk:
	$(FLUTTER) build apk --release

build-appbundle:
	$(FLUTTER) build appbundle --release

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
