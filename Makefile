SHELL := /bin/bash

# Include .ndk_home if it exists (for ANDROID_NDK_HOME)
-include .ndk_home

# Check for required environment
check_env:
	@if [ -z "$$ANDROID_NDK_HOME" ]; then \
		echo "$$ANDROID_NDK_HOME"; \
		echo "Error: ANDROID_NDK_HOME not set. Please create .ndk_home file from .ndk_home.example"; \
		exit 1; \
	fi

# Prefer nightly toolchain if available, otherwise use default
RUST_TOOLCHAIN_PATH := $(HOME)/.rustup/toolchains/nightly-aarch64-apple-darwin/bin
ifneq ($(wildcard $(RUST_TOOLCHAIN_PATH)),)
    export PATH := $(RUST_TOOLCHAIN_PATH):$(HOME)/.cargo/bin:$(PATH)
else
    export PATH := $(HOME)/.cargo/bin:$(PATH)
endif

debug: check_env clean_up generate_android_debug generate_ios_debug

release: check_env clean_up generate_android generate_ios

clean_up:
	@echo "Step: Removing target"
	rm -rf ./target
	rm -rf ./interfaces/ur_registry_flutter/android/src/main/jniLibs
	rm -f ./interfaces/ur_registry_flutter/ios/libur_registry_ffi.a
	mkdir ./interfaces/ur_registry_flutter/android/src/main/jniLibs
	mkdir ./interfaces/ur_registry_flutter/android/src/main/jniLibs/arm64-v8a
	mkdir ./interfaces/ur_registry_flutter/android/src/main/jniLibs/armeabi-v7a
	mkdir ./interfaces/ur_registry_flutter/android/src/main/jniLibs/x86
	@echo "Cleaning up"

generate_android:
	@echo "Step: Generating Android builds"
	@echo "1: arm64-v8a"
	cargo ndk -t arm64-v8a build -p ur-registry-ffi --release
	@echo "2: armeabi-v7a"
	cargo ndk -t armeabi-v7a build -p ur-registry-ffi --release
	@echo "3: x86"
	cargo ndk -t x86 build -p ur-registry-ffi --release
	@echo "Android buildup"
	cp ./target/aarch64-linux-android/release/libur_registry_ffi.so ./interfaces/ur_registry_flutter/android/src/main/jniLibs/arm64-v8a/libur_registry_ffi.so
	cp ./target/armv7-linux-androideabi/release/libur_registry_ffi.so ./interfaces/ur_registry_flutter/android/src/main/jniLibs/armeabi-v7a/libur_registry_ffi.so
	cp ./target/i686-linux-android/release/libur_registry_ffi.so ./interfaces/ur_registry_flutter/android/src/main/jniLibs/x86/libur_registry_ffi.so

generate_ios:
	@echo "Step: Generate iOS builds"
	cargo lipo --release
	cp ./target/universal/release/libur_registry_ffi.a ./interfaces/ur_registry_flutter/ios/

generate_xcframework:
	@echo "Step: Generate XCFramework"
	cargo build -r --target aarch64-apple-ios
	cargo build -r --target x86_64-apple-ios
	cargo build -r --target aarch64-apple-ios-sim
	mkdir -p target/sim
	lipo target/aarch64-apple-ios-sim/release/libur_registry_ffi.a target/x86_64-apple-ios/release/libur_registry_ffi.a -create -output target/sim/libur_registry_ffi.a
	xcodebuild -create-xcframework -library target/sim/libur_registry_ffi.a -headers include -library target/aarch64-apple-ios/release/libur_registry_ffi.a -headers include -output target/URRegistryFFI.xcframework

generate_ios_debug:
	@echo "Step: Generate iOS builds"
	cargo lipo
	cp ./target/universal/debug/libur_registry_ffi.a ./interfaces/ur_registry_flutter/ios/

generate_android_debug:
	@echo "Step: Generating Android builds"
	@echo "1: arm64-v8a"
	cargo ndk -t arm64-v8a build -p ur-registry-ffi
	@echo "2: armeabi-v7a"
	cargo ndk -t armeabi-v7a build -p ur-registry-ffi
	@echo "3: x86"
	cargo ndk -t x86 build -p ur-registry-ffi
	@echo "Android buildup"
	cp ./target/aarch64-linux-android/debug/libur_registry_ffi.so ./interfaces/ur_registry_flutter/android/src/main/jniLibs/arm64-v8a/libur_registry_ffi.so
	cp ./target/armv7-linux-androideabi/debug/libur_registry_ffi.so ./interfaces/ur_registry_flutter/android/src/main/jniLibs/armeabi-v7a/libur_registry_ffi.so
	cp ./target/i686-linux-android/debug/libur_registry_ffi.so ./interfaces/ur_registry_flutter/android/src/main/jniLibs/x86/libur_registry_ffi.so
