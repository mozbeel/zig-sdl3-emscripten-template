# zig-sdl3-emscripten-template
A simple template for a <a href="https://github.com/Gota7/zig-sdl3">zig-sdl3</a> project with the zemscripten build abstraction

## How to build the Project:
1. Choose a template:
   - This project currently shows off two templates:
     - Basic SDL3 (no callbacks)
     - Basic SDL3 (callbacks)
2. Install <a href="https://emscripten.org/docs/getting_started/downloads.html">Emscripten</a>
3. Build via
```bash
    zig build -Dtarget=wasm32-emscripten -Doptimize=ReleaseSmall --sysroot <path/to/emsdk>/upstream/emscripten/cache/sysroot

```
Due to NixOS' immutable environment you will have to run via the ```steam-run``` prefix. You might get an error like this otherwise:

```bash
    Could not start dynamically linked executable: /home/leeb/.cache/zig/p/N-V-__8AAOG3BQCJ9cn-N2swm2o5cLmDhmdHmtwNngOChK78/upstream/bin/clang
    NixOS cannot run dynamically linked executables intended for generic
    linux environments out of the box. For more information, see:
    https://nix.dev/permalink/stub-ld
    emcc: error: '/home/leeb/.cache/zig/p/N-V-__8AAOG3BQCJ9cn-N2swm2o5cLmDhmdHmtwNngOChK78/upstream/bin/clang --version' failed (returned 127)


```
So the full command becomes:
```bash
    steam-run zig build -Dtarget=wasm32-emscripten -Doptimize=ReleaseSmall --sysroot <path/to/emsdk>/upstream/emscripten/cache/sysroot

```

4. Run it via
```bash
    emrun --no_browser zig-out/web/MyGame.html --port 8080
```

If you picked either of the Basic SDL3 templates it should look like this:
![Screenshot](templates/callbacks/Screenshot.png)

Also if you'd like to use raylib this might be a good reference for it:
<a href="https://github.com/aidanaden/aztewoidz/blob/53508a0c8a3a759a06b321308b1c1da6c2b4976f/build.zig#L125">https://github.com/aidanaden/aztewoidz/blob/53508a0c8a3a759a06b321308b1c1da6c2b4976f/build.zig#L125</a>
