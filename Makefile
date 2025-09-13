build-android: build-apk build-appbundle

build-apk:
	flutter build apk --release

build-appbundle:
	flutter build appbundle --release
