# UR Registry Rust
Yet another implementation for BC-UR registries. 

## Libs
### [UR-Registry](./libs/ur-registry/README.md)
### [UR-Registry-FFI](./libs/ur-registry-ffi/README.md)

## Interfaces
### [flutter](./interfaces/ur_registry_flutter/README.md)

## Build
1. Install Android NDK 27.x or later (required for 16KB page size support)
> Open your `Android Studio`
> 
> Open `SDK manager`
> 
> Open tab `SDK tools`
> 
> Check `Show package Details`
> 
> Find target version (NDK 27.x or later)

2. Install Rust nightly toolchain (required due to external dependencies)
> rustup install nightly
> 
> rustup target add --toolchain nightly aarch64-linux-android armv7-linux-androideabi i686-linux-android
> 
> rustup target add --toolchain nightly aarch64-apple-ios x86_64-apple-ios aarch64-apple-ios-sim

3. Install cargo-lipo and cargo-ndk
> cargo install cargo-lipo
>
> cargo install cargo-ndk

4. Configure Android NDK

Copy `.ndk_home.example` to `.ndk_home` and update it with your NDK path:
> cp .ndk_home.example .ndk_home
> 
> Edit .ndk_home to point to your NDK installation

5. Build

Debug: 

> make

Release: 

> source .ndk_home && make release
