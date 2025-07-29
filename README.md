# Zig SDL3 Cross Template
Cross Compile from one SDL3 project to Mobile, Desktop and the Web

## Supported targets

Target \ Host | Windows | Linux | macOS | Notes
------------ | :-----: | :----: | :----: | --------
x86_64-windows-gnu | ✅ | ✅ | ✅ | Works out of the box
aarch64-windows-gnu | 🧪 | 🧪 | 🧪 | Works out of the box (experimental)
x86_64-linux-gnu | ✅ | ✅ | ✅ | Works out of the box
aarch64-linux-gnu | 🧪 | 🧪 | 🧪 | Works out of the box (experimental)
x86_64-macos-none | ❌ | ❌ | ✅ | Doesn't work without macOS SDK
aarch64-macos-none | ❌ | ❌ | ✅ | Doesn't work without macOS SDK
x86_64-linux-android | 🉑 | 🉑 | 🉑 | Requires Android SDK and NDK
x86-linux-android | 🉑 | 🉑 | 🉑 | Requires Android SDK and NDK
aarch64-linux-android | 🉑 | 🉑 | 🉑 | Requires Android SDK and NDK
arm-linux-android | 🉑 | 🉑 | 🉑 | Requires Android SDK and NDK
x86_64-ios | ❌ | ❌ | ✅ | Doesn't work without iOS SDK
aarch64-ios | ❌ | ❌ | ✅ | Doesn't work without iOS SDK
wasm32-emscripten-musl | 🉑 | 🉑 | 🉑 | Requires EMSDK
wasm64-emscripten-musl | 🉑 | 🉑 | 🉑 | Requires EMSDK


### Windows

Building for x86-64 Windows works out of the box while AArch64 Windows is still experimental but should work:
```sh
zig build -Dtarget=x86_64-windows-gnu # or -Dtarget=aarch64-windows-gnu
```

### Linux 

Building for x86-64 Linux works out of the box while AArch64 Linux is still experimental but should work.
```sh
zig build -Dtarget=x86_64-linux-gnu # or -Dtarget=aarch64-linux-gnu
```

### macOS

Building for x86-64 or AArch64 macOS requires Xcode 14.0 or later to be installed on the host macOS system.

> [!NOTE]
> **Cross-compiling for macOS from Windows or Linux host systems is not supported** because [the Xcode and Apple SDKs Agreement](https://www.apple.com/legal/sla/docs/xcode.pdf) explicitly prohibits using macOS SDK files from non-Apple-branded computers or devices.

When building for non-native macOS targets (for example for x86-64 from an AArch64 Mac), you need to provide a path to the macOS SDK sysroot via `--sysroot`:

```sh
zig build -Dtarget=x86_64-macos --sysroot "$(xcrun --sdk macosx --show-sdk-path)"
```

### Emscripten (Web)

Building for the Web in this project requires the <a href="https://emscripten.org/docs/getting_started/downloads.html">emsdk</a>. Also,Zig doesn't support Emscripten as a first-class compilation target, so you have to compile it to a static library first and use emscripten to compile to the final webpage. To simplify this project uses <a href="https://github.com/zig-gamedev/zemscripten">zemscripten</a>.
Finally, to build the project for the Web you have to run the following:
```bash
zig build -Dtarget=wasm32-emscripten --sysroot /path/to/emsdk/upstream/emscripten/cache/sysroot
```

### Android 

Building for Android is like building for the Web is still not first-class for compilation in Zig, so you also need to first builda static library and only then you can use android studio to build the final apk. But this project also uses <a href="https://github.com/silbinarywolf/zig-android-sdk">zig-android-sdk</a> to simplify this build process. 
Finally, to build the project for Android you have to run the following (for all ABIs):
```sh 
zig build -Dandroid
```

For only ABI you can run (all others are listed above):
```sh 
zig build -Dtarget=x86_64-linux-android
```

### iOS

Building for x86-64 or AArch64 iOS requires Xcode 14.3 or later to be installed on the host macOS system.

> [!NOTE]
> **Cross-compiling for iOS from Windows or Linux host systems is not supported** because [the Xcode and Apple SDKs Agreement](https://www.apple.com/legal/sla/docs/xcode.pdf) explicitly prohibits using iOS SDK files from non-Apple-branded computers or devices.

When building building for iOS, you always need to provide a path to the iOS SDK sysroot via `--sysroot`:

```sh
zig build -Dtarget=x86_64-ios --sysroot "$(xcrun --sdk iphoneos --show-sdk-path)"
```


