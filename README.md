# UR Registry Rust
Yet another implementation for BC-UR registries. 

## Libs
### [UR-Registry](./libs/ur-registry/README.md)
### [UR-Registry-FFI](./libs/ur-registry-ffi/README.md)

## Interfaces
### [flutter](./interfaces/ur_registry_flutter/README.md)

## Build
1. Install Android NDK 22.1.7171670
> Open your `Android Studio`
> 
> Open `SDK manager`
> 
> Open tab `SDK tools`
> 
> Check `Show package Details`
> 
> Found target version.  

2. Install cargo-lipo, cbindgen and cargo-ndk
> cargo install cargo-lipo
>
> cargo install cargo-ndk

3. Add rust components

Android:
> rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android


iOS:
> 
> rustup target add aarch64-apple-ios x86_64-apple-ios aarch64-apple-ios-sim

4. Config

Android:

Make sure you only have NDK 22.1.7171670, if not, you should setup the environment variable firstly:

Copy the file .ndk_home.example and change the content to your version;

5. Build

Debug: 

> make

Release: 

> source .ndk_home && make release
