SHELL := /bin/bash

debug: clean_up generate_android_debug

release: clean_up generate_android generate_ios

clean_up:
	@echo "Step: Removing target"
	rm -rf ./target
	@echo "Cleaning up"

generate_android:
	@echo "Step: Generating Android builds"
	source .ndk_home
	@echo "1: arm64-v8a"
	cargo ndk -t arm64-v8a build -p ur-registry-ffi --release
	@echo "2: armeabi-v7a"
	cargo ndk -t armeabi-v7a build -p ur-registry-ffi --release
	@echo "3: x86"
	cargo ndk -t x86 build -p ur-registry-ffi --release
	@echo "Android buildup"

generate_ios:
	@echo "Step: Generate iOS builds"
	cargo lipo --release

generate_android_debug:
	@echo "Step: Generating Android builds"
	source .ndk_home
	@echo "1: arm64-v8a"
	cargo ndk -t arm64-v8a build -p ur-registry-ffi
	@echo "2: armeabi-v7a"
	cargo ndk -t armeabi-v7a build -p ur-registry-ffi
	@echo "3: x86"
	cargo ndk -t x86 build -p ur-registry-ffi
	@echo "Android buildup"
