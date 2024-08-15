---
layout: post
title:  "Google Summer of Code 2024 Week 12: RGM, Season 2"
date:   2024-08-12 00:00:00 +0300
categories: blog
---

This blog post is related to my [Google Summer of Code 2024 project][my-google-summer-of-code-2024-project].

All fixes done last week didn't solve the link issue because as I said we need to link according to new absl library.

After clean build, this error showed up:

```
/usr/bin/ld: .eobjs/Server.o: undefined reference to symbol 'gpr_inf_future'
/usr/bin/ld: /usr/local/lib/libgpr.so.42: error adding symbols: DSO missing from command line
```

It is too clear to see that the ``-lgpr`` is missing from ``LDFLAGS`` variable. After adding it, the next error is:

```
/usr/bin/ld: .eobjs/EnigmaPlugin.o: undefined reference to symbol '_ZN4absl12lts_2024072212log_internal15LogMessageFatalC1EPKciSt17basic_string_viewIcSt11char_traitsIcEE'
/usr/bin/ld: /usr/local/lib/libabseil_dll.so.2407.0.0: error adding symbols: DSO missing from command line
```

I gave too much time to this error but I realized that may be the new absl has a new target to add it to the linker as well. That new target is ``-labseil_dll``.

These changes to ``enigma-dev/CommandLine/emake/Makefile`` fixed the linking issues and now my tests which I wrote on Ubuntu machine are passing.

## ``grpc_cpp_plugin`` path

If you take a look at this line here: [shared/protos/CMakeLists.txt#L30](https://github.com/enigma-dev/enigma-dev/blob/3590b681f20174ccf24156769d2bbb94b10673e3/shared/protos/CMakeLists.txt#L30), you will see that the path to ``grpc_cpp_plugin`` is hardcoded. As we installed the libraries to ``/usr/local``, we need to change this path to ``/usr/local/bin/grpc_cpp_plugin``.

I provided this PR [#2387](https://github.com/enigma-dev/enigma-dev/pull/2387) to fix this issue.

Now you can add this line in ``RadialGM/CMakeLists.txt``:

```cmake
set(GRPC_EXE "/usr/local/bin/grpc_cpp_plugin")
```

## Moving to RGM

The next step is RGM. RGM uses CMake build system and powered by Qt5. When running CMake, I got this error:

```
[ 76%] Linking CXX executable emake
/usr/bin/ld: CMakeFiles/emake.dir/EnigmaPlugin.cpp.o: undefined reference to symbol '_ZN4absl12lts_2024072212log_internal15LogMessageFatalC1EPKciSt17basic_string_viewIcSt11char_traitsIcEE'
/usr/bin/ld: /usr/local/lib/libabseil_dll.so.2407.0.0: error adding symbols: DSO missing from command line
```

That's the absl again. The same change I did to ``enigma-dev/CommandLine/emake/Makefile`` should be done to ``RadialGM/Submodules/enigma-dev/CommandLine/emake/CMakeLists.txt``, however, I need to do it CMake style.

```cmake
# Find absl
find_package(absl CONFIG REQUIRED)
target_link_libraries(${CLI_TARGET} PRIVATE absl::base absl::strings absl::synchronization absl::time absl::status absl::statusor)
```

This change fixed the linking issues and now we a have last task to do.

As Robert merged a last PR without checking the CI, there are a lot of cleanup that must be done in order for RGM to build properly. I provided this PR [#238](https://github.com/enigma-dev/RadialGM/pull/238) to fix this issue.

Now, RGM is built without any issues.

## Runtime nightmare

When running RGM, I got this error:

```
./RadialGM: error while loading shared libraries: libEGM.so: cannot open shared object file: No such file or directory
```

Let's see the ldd result:

```bash
ldd RadialGM
```

```
	linux-vdso.so.1 (0x0000796337afc000)
	libpugixml.so.1 => /usr/lib/libpugixml.so.1 (0x0000796337a96000)
	libyaml-cpp.so.0.8 => /usr/lib/libyaml-cpp.so.0.8 (0x00007963377b1000)
	libgrpc++.so.1.65 => /usr/local/lib/libgrpc++.so.1.65 (0x00007963376b9000)
	libprotobuf.so.27.3.0 => /usr/local/lib/libprotobuf.so.27.3.0 (0x0000796337200000)
	libssl.so.3 => /usr/lib/libssl.so.3 (0x00007963375df000)
	libcrypto.so.3 => /usr/lib/libcrypto.so.3 (0x0000796336c00000)
	libQt5PrintSupport.so.5 => /usr/lib/libQt5PrintSupport.so.5 (0x0000796337571000)
	libQt5Multimedia.so.5 => /usr/lib/libQt5Multimedia.so.5 (0x0000796337104000)
	<span style="color: red;">libEGM.so => not found</span>
	<span style="color: red;">libENIGMAShared.so => not found</span>
	libfreetype.so.6 => /usr/lib/libfreetype.so.6 (0x0000796336b37000)
	libjpeg.so.8 => /usr/lib/libjpeg.so.8 (0x0000796336a9b000)
	libharfbuzz.so.0 => /usr/lib/libharfbuzz.so.0 (0x0000796336981000)
	libpcre2-16.so.0 => /usr/lib/libpcre2-16.so.0 (0x00007963368ef000)
	libdouble-conversion.so.3 => /usr/lib/libdouble-conversion.so.3 (0x000079633755a000)
	libgrpc.so.42 => /usr/local/lib/libgrpc.so.42 (0x0000796335e00000)
	libgpr.so.42 => /usr/local/lib/libgpr.so.42 (0x000079633753c000)
	libupb_json_lib.so.42 => /usr/local/lib/libupb_json_lib.so.42 (0x000079633750f000)
	libupb_textformat_lib.so.42 => /usr/local/lib/libupb_textformat_lib.so.42 (0x00007963370df000)
	libutf8_range_lib.so.42 => /usr/local/lib/libutf8_range_lib.so.42 (0x0000796337a8b000)
	libupb_message_lib.so.42 => /usr/local/lib/libupb_message_lib.so.42 (0x0000796337a80000)
	libupb_base_lib.so.42 => /usr/local/lib/libupb_base_lib.so.42 (0x000079633750a000)
	libupb_mem_lib.so.42 => /usr/local/lib/libupb_mem_lib.so.42 (0x0000796337505000)
	libre2.so.9 => /usr/local/lib/libre2.so.9 (0x0000796336862000)
	libssl.so => /usr/local/lib/libssl.so (0x0000796335d90000)
	libcrypto.so => /usr/local/lib/libcrypto.so (0x0000796335a00000)
	libaddress_sorting.so.42 => /usr/local/lib/libaddress_sorting.so.42 (0x00007963370da000)
	libsystemd.so.0 => /usr/lib/libsystemd.so.0 (0x0000796335c9d000)
	libabseil_dll.so.2407.0.0 => /usr/local/lib/libabseil_dll.so.2407.0.0 (0x00007963358c7000)
	libQt5Widgets.so.5 => /usr/lib/libQt5Widgets.so.5 (0x0000796335200000)
	libQt5Gui.so.5 => /usr/lib/libQt5Gui.so.5 (0x0000796334a00000)
	libQt5Network.so.5 => /usr/lib/libQt5Network.so.5 (0x0000796335094000)
	libQt5Core.so.5 => /usr/lib/libQt5Core.so.5 (0x0000796334400000)
	<span style="color: red;">libProtocols.so => not found</span>
	libstdc++.so.6 => /usr/lib/libstdc++.so.6 (0x0000796334000000)
	libm.so.6 => /usr/lib/libm.so.6 (0x0000796334315000)
	libgcc_s.so.1 => /usr/lib/libgcc_s.so.1 (0x0000796335c70000)
	libc.so.6 => /usr/lib/libc.so.6 (0x0000796333e14000)
	/lib64/ld-linux-x86-64.so.2 => /usr/lib64/ld-linux-x86-64.so.2 (0x0000796337afe000)
	libz.so.1 => /usr/local/lib/libz.so.1 (0x0000796336843000)
	libpulse.so.0 => /usr/lib/libpulse.so.0 (0x0000796335c1b000)
	libbz2.so.1.0 => /usr/lib/libbz2.so.1.0 (0x00007963358b4000)
	libpng16.so.16 => /usr/lib/libpng16.so.16 (0x00007963349c6000)
	libbrotlidec.so.1 => /usr/lib/libbrotlidec.so.1 (0x0000796335c0c000)
	libglib-2.0.so.0 => /usr/lib/libglib-2.0.so.0 (0x0000796333cc6000)
	libgraphite2.so.3 => /usr/lib/libgraphite2.so.3 (0x00007963349a4000)
	libcap.so.2 => /usr/lib/libcap.so.2 (0x00007963358a8000)
	libGL.so.1 => /usr/lib/libGL.so.1 (0x000079633428f000)
	libmd4c.so.0 => /usr/lib/libmd4c.so.0 (0x000079633498e000)
	libgssapi_krb5.so.2 => /usr/lib/libgssapi_krb5.so.2 (0x000079633493a000)
	libproxy.so.1 => /usr/lib/libproxy.so.1 (0x000079633683e000)
	libicui18n.so.75 => /usr/lib/libicui18n.so.75 (0x0000796333800000)
	libicuuc.so.75 => /usr/lib/libicuuc.so.75 (0x0000796333606000)
	libzstd.so.1 => /usr/lib/libzstd.so.1 (0x0000796333be7000)
	libpulsecommon-17.0.so => /usr/lib/pulseaudio/libpulsecommon-17.0.so (0x000079633357f000)
	libdbus-1.so.3 => /usr/lib/libdbus-1.so.3 (0x0000796333b96000)
	libbrotlicommon.so.1 => /usr/lib/libbrotlicommon.so.1 (0x000079633355c000)
	libpcre2-8.so.0 => /usr/lib/libpcre2-8.so.0 (0x00007963334bd000)
	libGLdispatch.so.0 => /usr/lib/libGLdispatch.so.0 (0x0000796333405000)
	libGLX.so.0 => /usr/lib/libGLX.so.0 (0x00007963333d3000)
	libkrb5.so.3 => /usr/lib/libkrb5.so.3 (0x00007963332fb000)
	libk5crypto.so.3 => /usr/lib/libk5crypto.so.3 (0x00007963332cd000)
	libcom_err.so.2 => /usr/lib/libcom_err.so.2 (0x00007963358a2000)
	libkrb5support.so.0 => /usr/lib/libkrb5support.so.0 (0x0000796335086000)
	libkeyutils.so.1 => /usr/lib/libkeyutils.so.1 (0x0000796334288000)
	libresolv.so.2 => /usr/lib/libresolv.so.2 (0x0000796333b84000)
	libpxbackend-1.0.so => /usr/lib/libproxy/libpxbackend-1.0.so (0x00007963332be000)
	libgobject-2.0.so.0 => /usr/lib/libgobject-2.0.so.0 (0x000079633325f000)
	libicudata.so.75 => /usr/lib/libicudata.so.75 (0x0000796331400000)
	libsndfile.so.1 => /usr/lib/libsndfile.so.1 (0x00007963331d8000)
	libxcb.so.1 => /usr/lib/libxcb.so.1 (0x00007963331ad000)
	libasyncns.so.0 => /usr/lib/libasyncns.so.0 (0x0000796333b7c000)
	libX11.so.6 => /usr/lib/libX11.so.6 (0x00007963312c2000)
	libcurl.so.4 => /usr/lib/libcurl.so.4 (0x00007963311fb000)
	libgio-2.0.so.0 => /usr/lib/libgio-2.0.so.0 (0x000079633102e000)
	libduktape.so.207 => /usr/lib/libduktape.so.207 (0x0000796333160000)
	libffi.so.8 => /usr/lib/libffi.so.8 (0x0000796333155000)
	libogg.so.0 => /usr/lib/libogg.so.0 (0x0000796331024000)
	libvorbisenc.so.2 => /usr/lib/libvorbisenc.so.2 (0x0000796330f79000)
	libFLAC.so.12 => /usr/lib/libFLAC.so.12 (0x0000796330f33000)
	libopus.so.0 => /usr/lib/libopus.so.0 (0x0000796330a00000)
	libmpg123.so.0 => /usr/lib/libmpg123.so.0 (0x00007963309a5000)
	libmp3lame.so.0 => /usr/lib/libmp3lame.so.0 (0x000079633092d000)
	libvorbis.so.0 => /usr/lib/libvorbis.so.0 (0x00007963308ff000)
	libXau.so.6 => /usr/lib/libXau.so.6 (0x0000796335081000)
	libXdmcp.so.6 => /usr/lib/libXdmcp.so.6 (0x0000796330f2b000)
	libnghttp3.so.9 => /usr/lib/libnghttp3.so.9 (0x00007963308dc000)
	libnghttp2.so.14 => /usr/lib/libnghttp2.so.14 (0x00007963308b2000)
	libidn2.so.0 => /usr/lib/libidn2.so.0 (0x0000796330890000)
	libssh2.so.1 => /usr/lib/libssh2.so.1 (0x0000796330847000)
	libpsl.so.5 => /usr/lib/libpsl.so.5 (0x0000796330833000)
	libgmodule-2.0.so.0 => /usr/lib/libgmodule-2.0.so.0 (0x0000796330f24000)
	libmount.so.1 => /usr/lib/libmount.so.1 (0x00007963307e4000)
	libunistring.so.5 => /usr/lib/libunistring.so.5 (0x0000796330634000)
	libblkid.so.1 => /usr/lib/libblkid.so.1 (0x00007963305fb000)
```

The not found libraries are all engima-dev libraries. I need to export the path to the libraries by adding this line to my ``.bashrc`` file:

```bash
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:path/to/RadialGM/build/Submodules/enigma-dev/CommandLine/emake
```

```bash
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:path/to/RadialGM/build/Submodules/enigma-dev/CommandLine/libEGM
```

```bash
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:path/to/RadialGM/build/Submodules/enigma-dev/CompilerSource
```

```bash
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:path/to/RadialGM/build/Submodules/enigma-dev/shared
```

```bash
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:path/to/RadialGM/build/Submodules/enigma-dev/shared/protos
```

Note: Add your own path to the libraries.

## Weird stuff

Even though we fixed emake, if we used vscode tasks to build emake, I got this error:

```
/usr/local/bin/grpc_cpp_plugin: error while loading shared libraries: libgrpc_plugin_support.so.1.65: cannot open shared object file: No such file or directory
--grpc_out: protoc-gen-grpc: Plugin failed with status code 127.
```

So weird issue because if I ran the same command from terminal, it runs without problems. I can't see anything wrong with my files:

```json
{
    // Use IntelliSense to learn about possible attributes.
    // Hover to view descriptions of existing attributes.
    // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
        {
          "name": "Launch test-runner",
          "type": "cppdbg",
          "request": "launch",
          "program": "${workspaceFolder}/test-runner",
          "args": [ "--gtest_filter=VisualShaderTest.*" ],
          "stopAtEntry": false,
          "cwd": "${workspaceFolder}",
          "environment": [],
          "externalConsole": false,
          "setupCommands":
          [
            {
              "description": "Enable pretty-printing for gdb",
              "text": "-enable-pretty-printing",
              "ignoreFailures": true
            }
          ],
          "preLaunchTask": "build"
      }
    ]
}
```

```json
{
    // See https://go.microsoft.com/fwlink/?LinkId=733558
    // for the documentation about the tasks.json format
    "version": "2.0.0",
    "tasks": [
        {
            "label": "build",
            "group": "build",
            "type": "shell",
            "command": "make",
            "args": [ "test-runner" ],
        }
    ]
}
```

[my-google-summer-of-code-2024-project]: https://summerofcode.withgoogle.com/programs/2024/projects/wYTZuQbA
