---
layout: post
title:  "Google Summer of Code 2024 Week 11, 12, and 13: RGM"
date:   2024-08-05 00:00:00 +0300
categories: blog
---

This blog post is related to my Google Summer of Code 2024 project: [Procedural Fragment Shader Generation Using Classic Machine Learning][my-google-summer-of-code-2024-project].

```
Note: Before trying to build gRPC from scratch, see this: [Google Summer of Code 2024 Week 12: RGM, Season 2]().
```

The Final evaluation work will be inside [#2399](https://github.com/enigma-dev/enigma-dev/pull/2399).

## Back To ``test-runner`` Issue On Arch Linux

Remember that I am working on my Ubuntu VM as ``test-runner`` gives a link error on Arch Linux. However, RGM gives a linking error on both Ubuntu and Arch Linux. Because of this, I have decided to make ``test-runner`` work on Arch Linux.

As I explained in [Google Summer of Code 2024 Bonding Period]() post, the error is about linking ``emake`` failed. ``emake`` is the way to build games without a GUI as explained by Greg.

This error appears only on Arch linux, not Ubuntu. I guess that's because of the differences between old and new absl. I think the new absl has new targets that we need to link as well. Anyway, I asked Fares to give me the versions of Absl, Protobuf, and gRPC that he is using on Ubuntu. I will try to use the same versions on Arch.

Absl: 20210324.2
Protobuf: 3.12.4
gRPC: 1.30.2

I cloned these versions using -b option and found out that Absl doesn't have a CMake system yet. So let's change plans and try to build a proper versions of Absl, Protobuf, and gRPC from scratch.

I created this solution to do this task for me, [absl-proto-grpc-ci](https://github.com/k0T0z/absl-proto-grpc-ci), you can get the working verions from the README file. Also, you can take the commands from the scripts and run them on your machine.

Before installing them to your local, try to empty these dirs first:

```bash
sudo rm -rf /usr/local/lib/*
```

```bash
sudo rm -rf /usr/local/include/*
```

```bash
sudo rm -rf /usr/local/bin/*
```

This is to get rid of the old versions of the libraries (if any). If you have any locally installed libraries, be careful with the above commands.

Now, building those libraries is very easy, as well as installing them. It took me a couple of days to polish it off however, it is fine now. Maybe the only missing thing for this example is to build ``emake`` with it.

## Prioritizing local over system

After installing all libraries to my local and build ``emake``, this warning shows up:

```
/usr/bin/ld: warning: libprotobuf.so.27.3.0, needed by /usr/local/lib/libgrpc++.so, may conflict with libprotobuf.so.27
```

This is because the system has a version of Protobuf already installed. When trying to remove it:

```bash
sudo pacman -Rns protobuf
```

```
checking dependencies...
error: failed to prepare transaction (could not satisfy dependencies)
:: removing protobuf breaks dependency 'protobuf' required by libphonenumber
:: removing protobuf breaks dependency 'libprotobuf.so=27-64' required by libphonenumber
:: removing protobuf breaks dependency 'protobuf' required by protobuf-c
```

I can't remove it as it is required by other packages. So I need to prioritize the local version over the system version. I did this by adding these simple lines to ``enigma-dev/Config.mk`` file:

```makefile
# Which search priority to use for libraries (system or local)
CUSTOM_LIB_SEARCH_PRIORITY := local

ifeq ($(CUSTOM_LIB_SEARCH_PRIORITY), local)
    LDFLAGS += -L/usr/local/lib
endif
```

Now, you can set the search priority to local by changing the value of ``CUSTOM_LIB_SEARCH_PRIORITY`` to ``local``.

## Export Issue

Other error show up that ``grpc_cpp_plugin`` is unable to load some packages.

```bash
ldd $(which grpc_cpp_plugin)
```

> linux-vdso.so.1 (0x000071154c52f000)
> libsystemd.so.0 => /usr/lib/libsystemd.so.0 (0x000071154c3f5000)
> <span style="color: red;">libgrpc_plugin_support.so.1.65 => not found</span>
> libm.so.6 => /usr/lib/libm.so.6 (0x000071154c30a000)
> <span style="color: red;">libprotoc.so.27.3.0 => not found</span>
> <span style="color: red;">libprotobuf.so.27.3.0 => not found</span>
> <span style="color: red;">libabseil_dll.so.2407.0.0 => not found</span>
> libstdc++.so.6 => /usr/lib/libstdc++.so.6 (0x000071154c000000)
> libgcc_s.so.1 => /usr/lib/libgcc_s.so.1 (0x000071154c2db000)
> libc.so.6 => /usr/lib/libc.so.6 (0x000071154be14000)
> libcap.so.2 => /usr/lib/libcap.so.2 (0x000071154c2cf000)
> /lib64/ld-linux-x86-64.so.2 => /usr/lib64/ld-linux-x86-64.so.2 (0x000071154c531000)

There are ``not found`` libraries as you can see. If you used ``which`` with any of the nof founded libs, you will find it inside ``/usr/local/lib``. The solution is to export the path to the libraries by adding this line to your ``.bashrc`` file:

```bash
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
```

Now, you can run the command again:

```bash
ldd $(which grpc_cpp_plugin)
```

> linux-vdso.so.1 (0x0000765352968000)
> libsystemd.so.0 => /usr/lib/libsystemd.so.0 (0x000076535282d000)
> <span style="color: blue;">libgrpc_plugin_support.so.1.65 => /usr/local/lib/libgrpc_plugin_support.so.1.65 (0x00007653527a6000)</span>
> libm.so.6 => /usr/lib/libm.so.6 (0x00007653526bb000)
> <span style="color: blue;">libprotoc.so.27.3.0 => /usr/local/lib/libprotoc.so.27.3.0 (0x0000765352200000)</span>
> <span style="color: blue;">libprotobuf.so.27.3.0 => /usr/local/lib/libprotobuf.so.27.3.0 (0x0000765351e00000)</span>
> <span style="color: blue;">libabseil_dll.so.2407.0.0 => /usr/local/lib/libabseil_dll.so.2407.0.0 (0x0000765351cc7000)</span>
> libstdc++.so.6 => /usr/lib/libstdc++.so.6 (0x0000765351a00000)
> libgcc_s.so.1 => /usr/lib/libgcc_s.so.1 (0x00007653521d3000)
> libc.so.6 => /usr/lib/libc.so.6 (0x0000765351814000)
> libcap.so.2 => /usr/lib/libcap.so.2 (0x00007653521c7000)
> /lib64/ld-linux-x86-64.so.2 => /usr/lib64/ld-linux-x86-64.so.2 (0x000076535296a000)
> libz.so.1 => /usr/local/lib/libz.so.1 (0x00007653521a6000)

All fixes done above didn't solve the link issue because as I said we need to link according to new absl library.

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

On 9th August 2024, The changes to ``enigma-dev/CommandLine/emake/Makefile`` fixed the linking issues and now my tests which I wrote on Ubuntu VM are passing on my Arch Linux machine.

## ``grpc_cpp_plugin`` path

If you take a look at this line here: [shared/protos/CMakeLists.txt#L30](https://github.com/enigma-dev/enigma-dev/blob/3590b681f20174ccf24156769d2bbb94b10673e3/shared/protos/CMakeLists.txt#L30), you will see that the path to ``grpc_cpp_plugin`` is hardcoded. As we installed the libraries to ``/usr/local``, we need to change this path to ``/usr/local/bin/grpc_cpp_plugin``.

I provided this PR [#2387](https://github.com/enigma-dev/enigma-dev/pull/2387) to fix this issue.

Now you can add this line in ``RadialGM/CMakeLists.txt``:

```cmake
set(GRPC_EXE "/usr/local/bin/grpc_cpp_plugin")
```

## Moving To RGM

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

## RGM Build

Now, build and linking ``emake`` is done. I can now leave my Ubuntu VM and move back to my Arch Linux machine. The next step is to build RGM.

As Robert merged a last PR without checking the CI, there are a lot of cleanup that must be done in order for RGM to build properly. I provided this PR [#238](https://github.com/enigma-dev/RadialGM/pull/238) to fix this issue.

The above PR contains many changes as follows:

- Linking [nodeeditor](https://github.com/k0T0z/nodeeditor) library to RGM.
- Multiple fixes to the Room Editor.
- Fixed and improved the Server Plugin.
- Multiple fixes to the CMake build system.

On 13th August 2024, RGM can be built without any issues.

## Runtime Nightmare

Now, RGM can be built without issues. However, life still doesn't want to surrender. When running RGM, I got this error:

```
./RadialGM: error while loading shared libraries: libEGM.so: cannot open shared object file: No such file or directory
```

Let's see the ldd result:

```bash
ldd RadialGM
```

> linux-vdso.so.1 (0x0000796337afc000)
> libpugixml.so.1 => /usr/lib/libpugixml.so.1 (0x0000796337a96000)
> libyaml-cpp.so.0.8 => /usr/lib/libyaml-cpp.so.0.8 (0x00007963377b1000)
> libgrpc++.so.1.65 => /usr/local/lib/libgrpc++.so.1.65 (0x00007963376b9000)
> libprotobuf.so.27.3.0 => /usr/local/lib/libprotobuf.so.27.3.0 (0x0000796337200000)
> libssl.so.3 => /usr/lib/libssl.so.3 (0x00007963375df000)
> libcrypto.so.3 => /usr/lib/libcrypto.so.3 (0x0000796336c00000)
> libQt5PrintSupport.so.5 => /usr/lib/libQt5PrintSupport.so.5 (0x0000796337571000)
> libQt5Multimedia.so.5 => /usr/lib/libQt5Multimedia.so.5 (0x0000796337104000)
> <span style="color: red;">libEGM.so => not found</span>
> <span style="color: red;">libENIGMAShared.so => not found</span>
> libfreetype.so.6 => /usr/lib/libfreetype.so.6 (0x0000796336b37000)
> libjpeg.so.8 => /usr/lib/libjpeg.so.8 (0x0000796336a9b000)
> libharfbuzz.so.0 => /usr/lib/libharfbuzz.so.0 (0x0000796336981000)
> libpcre2-16.so.0 => /usr/lib/libpcre2-16.so.0 (0x00007963368ef000)
> libdouble-conversion.so.3 => /usr/lib/libdouble-conversion.so.3 (0x000079633755a000)
> libgrpc.so.42 => /usr/local/lib/libgrpc.so.42 (0x0000796335e00000)
> libgpr.so.42 => /usr/local/lib/libgpr.so.42 (0x000079633753c000)
> libupb_json_lib.so.42 => /usr/local/lib/libupb_json_lib.so.42 (0x000079633750f000)
> libupb_textformat_lib.so.42 => /usr/local/lib/libupb_textformat_lib.so.42 (0x00007963370df000)
> libutf8_range_lib.so.42 => /usr/local/lib/libutf8_range_lib.so.42 (0x0000796337a8b000)
> libupb_message_lib.so.42 => /usr/local/lib/libupb_message_lib.so.42 (0x0000796337a80000)
> libupb_base_lib.so.42 => /usr/local/lib/libupb_base_lib.so.42 (0x000079633750a000)
> libupb_mem_lib.so.42 => /usr/local/lib/libupb_mem_lib.so.42 (0x0000796337505000)
> libre2.so.9 => /usr/local/lib/libre2.so.9 (0x0000796336862000)
> libssl.so => /usr/local/lib/libssl.so (0x0000796335d90000)
> libcrypto.so => /usr/local/lib/libcrypto.so (0x0000796335a00000)
> libaddress_sorting.so.42 => /usr/local/lib/libaddress_sorting.so.42 (0x00007963370da000)
> libsystemd.so.0 => /usr/lib/libsystemd.so.0 (0x0000796335c9d000)
> libabseil_dll.so.2407.0.0 => /usr/local/lib/libabseil_dll.so.2407.0.0 (0x00007963358c7000)
> libQt5Widgets.so.5 => /usr/lib/libQt5Widgets.so.5 (0x0000796335200000)
> libQt5Gui.so.5 => /usr/lib/libQt5Gui.so.5 (0x0000796334a00000)
> libQt5Network.so.5 => /usr/lib/libQt5Network.so.5 (0x0000796335094000)
> libQt5Core.so.5 => /usr/lib/libQt5Core.so.5 (0x0000796334400000)
> <span style="color: red;">libProtocols.so => not found</span>
> libstdc++.so.6 => /usr/lib/libstdc++.so.6 (0x0000796334000000)
> libm.so.6 => /usr/lib/libm.so.6 (0x0000796334315000)
> libgcc_s.so.1 => /usr/lib/libgcc_s.so.1 (0x0000796335c70000)
> libc.so.6 => /usr/lib/libc.so.6 (0x0000796333e14000)
> /lib64/ld-linux-x86-64.so.2 => /usr/lib64/ld-linux-x86-64.so.2 (0x0000796337afe000)
> libz.so.1 => /usr/local/lib/libz.so.1 (0x0000796336843000)
> libpulse.so.0 => /usr/lib/libpulse.so.0 (0x0000796335c1b000)
> libbz2.so.1.0 => /usr/lib/libbz2.so.1.0 (0x00007963358b4000)
> libpng16.so.16 => /usr/lib/libpng16.so.16 (0x00007963349c6000)
> libbrotlidec.so.1 => /usr/lib/libbrotlidec.so.1 (0x0000796335c0c000)
> libglib-2.0.so.0 => /usr/lib/libglib-2.0.so.0 (0x0000796333cc6000)
> libgraphite2.so.3 => /usr/lib/libgraphite2.so.3 (0x00007963349a4000)
> libcap.so.2 => /usr/lib/libcap.so.2 (0x00007963358a8000)
> libGL.so.1 => /usr/lib/libGL.so.1 (0x000079633428f000)
> libmd4c.so.0 => /usr/lib/libmd4c.so.0 (0x000079633498e000)
> libgssapi_krb5.so.2 => /usr/lib/libgssapi_krb5.so.2 (0x000079633493a000)
> libproxy.so.1 => /usr/lib/libproxy.so.1 (0x000079633683e000)
> libicui18n.so.75 => /usr/lib/libicui18n.so.75 (0x0000796333800000)
> libicuuc.so.75 => /usr/lib/libicuuc.so.75 (0x0000796333606000)
> libzstd.so.1 => /usr/lib/libzstd.so.1 (0x0000796333be7000)
> libpulsecommon-17.0.so => /usr/lib/pulseaudio/libpulsecommon-17.0.so (0x000079633357f000)
> libdbus-1.so.3 => /usr/lib/libdbus-1.so.3 (0x0000796333b96000)
> libbrotlicommon.so.1 => /usr/lib/libbrotlicommon.so.1 (0x000079633355c000)
> libpcre2-8.so.0 => /usr/lib/libpcre2-8.so.0 (0x00007963334bd000)
> libGLdispatch.so.0 => /usr/lib/libGLdispatch.so.0 (0x0000796333405000)
> libGLX.so.0 => /usr/lib/libGLX.so.0 (0x00007963333d3000)
> libkrb5.so.3 => /usr/lib/libkrb5.so.3 (0x00007963332fb000)
> libk5crypto.so.3 => /usr/lib/libk5crypto.so.3 (0x00007963332cd000)
> libcom_err.so.2 => /usr/lib/libcom_err.so.2 (0x00007963358a2000)
> libkrb5support.so.0 => /usr/lib/libkrb5support.so.0 (0x0000796335086000)
> libkeyutils.so.1 => /usr/lib/libkeyutils.so.1 (0x0000796334288000)
> libresolv.so.2 => /usr/lib/libresolv.so.2 (0x0000796333b84000)
> libpxbackend-1.0.so => /usr/lib/libproxy/libpxbackend-1.0.so (0x00007963332be000)
> libgobject-2.0.so.0 => /usr/lib/libgobject-2.0.so.0 (0x000079633325f000)
> libicudata.so.75 => /usr/lib/libicudata.so.75 (0x0000796331400000)
> libsndfile.so.1 => /usr/lib/libsndfile.so.1 (0x00007963331d8000)
> libxcb.so.1 => /usr/lib/libxcb.so.1 (0x00007963331ad000)
> libasyncns.so.0 => /usr/lib/libasyncns.so.0 (0x0000796333b7c000)
> libX11.so.6 => /usr/lib/libX11.so.6 (0x00007963312c2000)
> libcurl.so.4 => /usr/lib/libcurl.so.4 (0x00007963311fb000)
> libgio-2.0.so.0 => /usr/lib/libgio-2.0.so.0 (0x000079633102e000)
> libduktape.so.207 => /usr/lib/libduktape.so.207 (0x0000796333160000)
> libffi.so.8 => /usr/lib/libffi.so.8 (0x0000796333155000)
> libogg.so.0 => /usr/lib/libogg.so.0 (0x0000796331024000)
> libvorbisenc.so.2 => /usr/lib/libvorbisenc.so.2 (0x0000796330f79000)
> libFLAC.so.12 => /usr/lib/libFLAC.so.12 (0x0000796330f33000)
> libopus.so.0 => /usr/lib/libopus.so.0 (0x0000796330a00000)
> libmpg123.so.0 => /usr/lib/libmpg123.so.0 (0x00007963309a5000)
> libmp3lame.so.0 => /usr/lib/libmp3lame.so.0 (0x000079633092d000)
> libvorbis.so.0 => /usr/lib/libvorbis.so.0 (0x00007963308ff000)
> libXau.so.6 => /usr/lib/libXau.so.6 (0x0000796335081000)
> libXdmcp.so.6 => /usr/lib/libXdmcp.so.6 (0x0000796330f2b000)
> libnghttp3.so.9 => /usr/lib/libnghttp3.so.9 (0x00007963308dc000)
> libnghttp2.so.14 => /usr/lib/libnghttp2.so.14 (0x00007963308b2000)
> libidn2.so.0 => /usr/lib/libidn2.so.0 (0x0000796330890000)
> libssh2.so.1 => /usr/lib/libssh2.so.1 (0x0000796330847000)
> libpsl.so.5 => /usr/lib/libpsl.so.5 (0x0000796330833000)
> libgmodule-2.0.so.0 => /usr/lib/libgmodule-2.0.so.0 (0x0000796330f24000)
> libmount.so.1 => /usr/lib/libmount.so.1 (0x00007963307e4000)
> libunistring.so.5 => /usr/lib/libunistring.so.5 (0x0000796330634000)
> libblkid.so.1 => /usr/lib/libblkid.so.1 (0x00007963305fb000)


The not found libraries are all engima-dev libraries. I need to export the path to the libraries by adding this line to my ``.bashrc`` file:

```bash
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/path/to/RadialGM/Submodules/enigma-dev
```

Note: Add your own path to the libraries.

Now everything is fine:

> linux-vdso.so.1 (0x000078394efc5000)
> libpugixml.so.1 => /usr/lib/libpugixml.so.1 (0x000078394ef5f000)
> libyaml-cpp.so.0.8 => /usr/lib/libyaml-cpp.so.0.8 (0x000078394ef10000)
> libgrpc++.so.1.65 => /usr/local/lib/libgrpc++.so.1.65 (0x000078394eb08000)
> libprotobuf.so.27.3.0 => /usr/local/lib/libprotobuf.so.27.3.0 (0x000078394e800000)
> libssl.so.3 => /usr/lib/libssl.so.3 (0x000078394e726000)
> libcrypto.so.3 => /usr/lib/libcrypto.so.3 (0x000078394e200000)
> libQt5PrintSupport.so.5 => /usr/lib/libQt5PrintSupport.so.5 (0x000078394eea0000)
> libQt5Multimedia.so.5 => /usr/lib/libQt5Multimedia.so.5 (0x000078394e104000)
> <span style="color: blue;">libEGM.so => /home/k0t0z/Desktop/gsoc24/RadialGM/build/Submodules/enigma-dev/CommandLine/libEGM/libEGM.so (0x000078394de00000)</span>
> <span style="color: blue;">libENIGMAShared.so => /home/k0t0z/Desktop/gsoc24/RadialGM/build/Submodules/enigma-dev/shared/libENIGMAShared.so (0x000078394dd39000)</span>
> libfreetype.so.6 => /usr/lib/libfreetype.so.6 (0x000078394dc70000)
> libjpeg.so.8 => /usr/lib/libjpeg.so.8 (0x000078394dbd4000)
> libharfbuzz.so.0 => /usr/lib/libharfbuzz.so.0 (0x000078394daba000)
> libpcre2-16.so.0 => /usr/lib/libpcre2-16.so.0 (0x000078394da28000)
> libdouble-conversion.so.3 => /usr/lib/libdouble-conversion.so.3 (0x000078394ee87000)
> libgrpc.so.42 => /usr/local/lib/libgrpc.so.42 (0x000078394ce00000)
> libgpr.so.42 => /usr/local/lib/libgpr.so.42 (0x000078394e708000)
> libupb_json_lib.so.42 => /usr/local/lib/libupb_json_lib.so.42 (0x000078394e6db000)
> libupb_textformat_lib.so.42 => /usr/local/lib/libupb_textformat_lib.so.42 (0x000078394da03000)
> libutf8_range_lib.so.42 => /usr/local/lib/libutf8_range_lib.so.42 (0x000078394ee80000)
> libupb_message_lib.so.42 => /usr/local/lib/libupb_message_lib.so.42 (0x000078394e6d0000)
> libupb_base_lib.so.42 => /usr/local/lib/libupb_base_lib.so.42 (0x000078394e0ff000)
> libupb_mem_lib.so.42 => /usr/local/lib/libupb_mem_lib.so.42 (0x000078394e0fa000)
> libre2.so.9 => /usr/local/lib/libre2.so.9 (0x000078394d976000)
> libssl.so => /usr/local/lib/libssl.so (0x000078394d906000)
> libcrypto.so => /usr/local/lib/libcrypto.so (0x000078394ca00000)
> libaddress_sorting.so.42 => /usr/local/lib/libaddress_sorting.so.42 (0x000078394e0f5000)
> libsystemd.so.0 => /usr/lib/libsystemd.so.0 (0x000078394cd0d000)
> libabseil_dll.so.2407.0.0 => /usr/local/lib/libabseil_dll.so.2407.0.0 (0x000078394c8c7000)
> libQt5Widgets.so.5 => /usr/lib/libQt5Widgets.so.5 (0x000078394c200000)
> libQt5Gui.so.5 => /usr/lib/libQt5Gui.so.5 (0x000078394ba00000)
> libQt5Network.so.5 => /usr/lib/libQt5Network.so.5 (0x000078394c094000)
> libQt5Core.so.5 => /usr/lib/libQt5Core.so.5 (0x000078394b400000)
> <span style="color: blue;">libProtocols.so => /home/k0t0z/Desktop/gsoc24/RadialGM/build/Submodules/enigma-dev/shared/protos/libProtocols.so (0x000078394b000000)</span>
> libstdc++.so.6 => /usr/lib/libstdc++.so.6 (0x000078394ac00000)
> libm.so.6 => /usr/lib/libm.so.6 (0x000078394cc22000)
> libgcc_s.so.1 => /usr/lib/libgcc_s.so.1 (0x000078394d8d9000)
> libc.so.6 => /usr/lib/libc.so.6 (0x000078394aa14000)
> /lib64/ld-linux-x86-64.so.2 => /usr/lib64/ld-linux-x86-64.so.2 (0x000078394efc7000)
> libz.so.1 => /usr/local/lib/libz.so.1 (0x000078394d8ba000)
> libpulse.so.0 => /usr/lib/libpulse.so.0 (0x000078394d863000)
> libpng16.so.16 => /usr/lib/libpng16.so.16 (0x000078394b9c6000)
> libbz2.so.1.0 => /usr/lib/libbz2.so.1.0 (0x000078394d850000)
> libbrotlidec.so.1 => /usr/lib/libbrotlidec.so.1 (0x000078394d841000)
> libglib-2.0.so.0 => /usr/lib/libglib-2.0.so.0 (0x000078394b2b2000)
> libgraphite2.so.3 => /usr/lib/libgraphite2.so.3 (0x000078394c8a5000)
> libcap.so.2 => /usr/lib/libcap.so.2 (0x000078394cc16000)
> libGL.so.1 => /usr/lib/libGL.so.1 (0x000078394b940000)
> libmd4c.so.0 => /usr/lib/libmd4c.so.0 (0x000078394b29c000)
> libgssapi_krb5.so.2 => /usr/lib/libgssapi_krb5.so.2 (0x000078394b248000)
> libproxy.so.1 => /usr/lib/libproxy.so.1 (0x000078394cc11000)
> libicui18n.so.75 => /usr/lib/libicui18n.so.75 (0x000078394a600000)
> libicuuc.so.75 => /usr/lib/libicuuc.so.75 (0x000078394a406000)
> libzstd.so.1 => /usr/lib/libzstd.so.1 (0x000078394af21000)
> libgrpc++_unsecure.so.1.65 => /usr/local/lib/libgrpc++_unsecure.so.1.65 (0x000078394ae94000)
> libpulsecommon-17.0.so => /usr/lib/pulseaudio/libpulsecommon-17.0.so (0x000078394a98d000)
> libdbus-1.so.3 => /usr/lib/libdbus-1.so.3 (0x000078394a3b5000)
> libbrotlicommon.so.1 => /usr/lib/libbrotlicommon.so.1 (0x000078394b225000)
> libpcre2-8.so.0 => /usr/lib/libpcre2-8.so.0 (0x000078394a316000)
> libGLdispatch.so.0 => /usr/lib/libGLdispatch.so.0 (0x000078394a25e000)
> libGLX.so.0 => /usr/lib/libGLX.so.0 (0x000078394a22c000)
> libkrb5.so.3 => /usr/lib/libkrb5.so.3 (0x000078394a154000)
> libk5crypto.so.3 => /usr/lib/libk5crypto.so.3 (0x000078394a126000)
> libcom_err.so.2 => /usr/lib/libcom_err.so.2 (0x000078394c89f000)
> libkrb5support.so.0 => /usr/lib/libkrb5support.so.0 (0x000078394c086000)
> libkeyutils.so.1 => /usr/lib/libkeyutils.so.1 (0x000078394b939000)
> libresolv.so.2 => /usr/lib/libresolv.so.2 (0x000078394a114000)
> libpxbackend-1.0.so => /usr/lib/libproxy/libpxbackend-1.0.so (0x000078394ae85000)
> libgobject-2.0.so.0 => /usr/lib/libgobject-2.0.so.0 (0x000078394a0b5000)
> libicudata.so.75 => /usr/lib/libicudata.so.75 (0x0000783948200000)
> libgrpc_unsecure.so.42 => /usr/local/lib/libgrpc_unsecure.so.42 (0x0000783947a00000)
> libsndfile.so.1 => /usr/lib/libsndfile.so.1 (0x000078394a02e000)
> libxcb.so.1 => /usr/lib/libxcb.so.1 (0x000078394a003000)
> libasyncns.so.0 => /usr/lib/libasyncns.so.0 (0x000078394a985000)
> libX11.so.6 => /usr/lib/libX11.so.6 (0x00007839480c2000)
> libcurl.so.4 => /usr/lib/libcurl.so.4 (0x0000783947939000)
> libgio-2.0.so.0 => /usr/lib/libgio-2.0.so.0 (0x000078394776c000)
> libduktape.so.207 => /usr/lib/libduktape.so.207 (0x0000783949fb6000)
> libffi.so.8 => /usr/lib/libffi.so.8 (0x0000783949fab000)
> libogg.so.0 => /usr/lib/libogg.so.0 (0x0000783949fa1000)
> libvorbisenc.so.2 => /usr/lib/libvorbisenc.so.2 (0x00007839476c1000)
> libFLAC.so.12 => /usr/lib/libFLAC.so.12 (0x0000783949f5b000)
> libopus.so.0 => /usr/lib/libopus.so.0 (0x0000783947000000)
> libmpg123.so.0 => /usr/lib/libmpg123.so.0 (0x0000783947666000)
> libmp3lame.so.0 => /usr/lib/libmp3lame.so.0 (0x00007839475ee000)
> libvorbis.so.0 => /usr/lib/libvorbis.so.0 (0x00007839475c0000)
> libXau.so.6 => /usr/lib/libXau.so.6 (0x000078394a980000)
> libXdmcp.so.6 => /usr/lib/libXdmcp.so.6 (0x0000783949f53000)
> libnghttp3.so.9 => /usr/lib/libnghttp3.so.9 (0x000078394759d000)
> libnghttp2.so.14 => /usr/lib/libnghttp2.so.14 (0x0000783947573000)
> libidn2.so.0 => /usr/lib/libidn2.so.0 (0x0000783947551000)
> libssh2.so.1 => /usr/lib/libssh2.so.1 (0x0000783946fb7000)
> libpsl.so.5 => /usr/lib/libpsl.so.5 (0x00007839480ae000)
> libgmodule-2.0.so.0 => /usr/lib/libgmodule-2.0.so.0 (0x00007839480a7000)
> libmount.so.1 => /usr/lib/libmount.so.1 (0x0000783946f68000)
> libunistring.so.5 => /usr/lib/libunistring.so.5 (0x0000783946db8000)
> libblkid.so.1 => /usr/lib/libblkid.so.1 (0x0000783946d7f000)

Now, another issue appeared when trying to run RGM:

```
WARNING: All log messages before absl::InitializeLog() is called are written to STDERR
E0000 00:00:1723829087.769865   68641 metrics.cc:49] Metric name grpc.lb.wrr.rr_fallback has already been registered.
Aborted (core dumped)
```

The above error doesn't help much anyway. Robert suggested that not linking gRPC and proceed to work on the UI part without the engine. Of course, RGM built correctly without gRPC but I need to fix the gRPC issue to be able to send and receive messages between RGM and ``emake``.

![GSoC 2024 RGM Without gRPC](/gsoc24-blog/assets/gsoc24-rgm-without-grpc.png)

## Local Not Needed

That error is because of grpc not loading correctly. Anyway, I thought at first that this is due to the manually built packages so let's clean them up and use ``pacman``. I already know what to do.

Back to the absl link error, just like linking ``-labseil_dll`` worked, after using trail and error, I found that linking ``-labsl_log_internal_message -labsl_log_internal_check_op`` fixed the issue. Anyway, I can now run RGM with the pacman installed packages, however, the same error is still there.

## Back To The Runtime Issue

When I face a problem, I can't get it out of my brain. Although, Robert told me to continue my work and not worry about it now, I kept trying on it. On 17th August 2024, I managed to fix the runtime issue by luck (الحمدلله). Now let me explain and wrap up this whole thing.

In CMake, we have two ways for finding a package or in other words, two files to use for finding a package. The first one is ``Find<package>.cmake`` and the second one is ``<package>Config.cmake``. What I know about these files at this point is that the second one is the modern way to find a package, however, as ENIGMA is 16 years old, it finds packages using the first way.

I worked on RGM and fixed some issues inside its CMake files and one of them is the way for finding gRPC and protobuf. The thing is that I didn't check other CMakes. More specifically, I didn't check ``enigma-dev/shared/CMakeLists.txt``, ``enigma-dev/shared/protos/CMakeLists.txt``, ``enigma-dev/CommandLine/emake/CMakeLists.txt``, and ``enigma-dev/CommandLine/libEGM/CMakeLists.txt``. All these files were using the following way to find gRPC and protobuf:

```cmake
include(FindProtobuf)
target_link_libraries(${LIB_EGM} PRIVATE ${Protobuf_LIBRARY})
```

or

```cmake
include_directories(${Protobuf_INCLUDE_DIRS})
target_link_libraries(${LIB_PROTO} PRIVATE ${Protobuf_LIBRARIES})
```

I replaced these lines with the following:

```cmake
find_package(Protobuf CONFIG REQUIRED)
target_link_libraries(${LIB_PROTO} PRIVATE protobuf::libprotobuf)
```

The new lines are working fine if you used the system packages or the local ones.

Now, how is this related to this runtime issue? The thing is that I don't know what are the differences between these two files however, I do know that mixing them up will cause this runtime issue. This is not a predictable issue because everything was fine, linking completed successfully, nothing wrong and if you take a look at the error above, I bet that you will be able to find the issue. Even by debugging the code, take a look at the stack trace:

```
[k0t0z@archlinux build]$ gdb ./RadialGM

(gdb) run
Starting program: /home/k0t0z/Desktop/gsoc24/RadialGM/build/RadialGM 
WARNING: All log messages before absl::InitializeLog() is called are written to STDERR                                                                                                                       
E0000 00:00:1723739441.404244    1995 metrics.cc:49] Metric name grpc.lb.pick_first.disconnections has already been registered.

Program received signal SIGABRT, Aborted.
0x00007ffff3ea8e44 in ?? () from /usr/lib/libc.so.6
(gdb) bt
#0  0x00007ffff3ea8e44 in ?? () from /usr/lib/libc.so.6
#1  0x00007ffff3e50a30 in raise () from /usr/lib/libc.so.6
#2  0x00007ffff3e384c3 in abort () from /usr/lib/libc.so.6
#3  0x00007ffff7d123ed in grpc_core::Crash(std::basic_string_view<char, std::char_traits<char> >, grpc_core::SourceLocation) () from /usr/local/lib/libgpr.so.42
#4  0x00007ffff6931c1a in grpc_core::GlobalInstrumentsRegistry::RegisterInstrument(grpc_core::GlobalInstrumentsRegistry::ValueType, grpc_core::GlobalInstrumentsRegistry::InstrumentType, std::basic_string_view<char, std::char_traits<char> >, std::basic_string_view<char, std::char_traits<char> >, std::basic_string_view<char, std::char_traits<char> >, bool, absl::lts_20240722::Span<std::basic_string_view<char, std::char_traits<char> > const>, absl::lts_20240722::Span<std::basic_string_view<char, std::char_traits<char> > const>) () from /usr/local/lib/libgrpc.so.42
#5  0x00007ffff6830452 in grpc_core::GlobalInstrumentsRegistry::RegistrationBuilder<(grpc_core::GlobalInstrumentsRegistry::ValueType)2, (grpc_core::GlobalInstrumentsRegistry::InstrumentType)1, 1ul, 0ul>::Build() () from /usr/local/lib/libgrpc.so.42
#6  0x00007ffff64c25ef in _GLOBAL__sub_I_pick_first.cc () from /usr/local/lib/libgrpc.so.42
#7  0x00007ffff7fce2e7 in ?? () from /lib64/ld-linux-x86-64.so.2
#8  0x00007ffff7fce3dd in ?? () from /lib64/ld-linux-x86-64.so.2
#9  0x00007ffff7fe57a0 in ?? () from /lib64/ld-linux-x86-64.so.2
#10 0x0000000000000001 in ?? ()
#11 0x00007fffffffe85b in ?? ()
#12 0x0000000000000000 in ?? ()
```

Found the issue? I bet you won't and I fixed this issue by luck. Robert, Kartik, and I tried many many solutions and options but nothing worked until I fixed it on 17th August 2024. Robert gave a thumbs up to every message I posted this day. It was challenging but fun.

> kartik — 17/08/2024 20:23

> nope never seen this before, but glad that you're able to build the rgm

> R0bert — 17/08/2024 20:26

> this is beautiful and im not surprised at all
> based on the debugging from yesterday i was suspecting something was going wrong with linking
> i suspect the old way was linking twice as you said and the static initialization was called twice
> so this is great, this is excellent
> im giving every comment here a thumbs up because that is some good stuff!
> now onward and upward with the project

Anyway, building RGM is done now and I am ready to work on the UI part.

By the way, I want to note that, these changes won't work on Ubuntu as Ubuntu is 1000 versions behind Arch Linux. This means you will have to build absl, protobuf, and gRPC manually if you are using Ubuntu.

Inside here, I have decided also to refactor the whole CMake build system. All the changes now can be found inside these two PRs:

- [#238](https://github.com/enigma-dev/RadialGM/pull/238)
- [#2399](https://github.com/enigma-dev/enigma-dev/pull/2399)

Now you know why I called it [Google Summer of Code 2024 Week 7, 8, and 9: My Boogeyperiod](). This is because I spent nearly 1.5 months on this issue.

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

## Debugging RGM: [#238](https://github.com/enigma-dev/RadialGM/pull/238)

Before talking about the UI integration, let's talk about how to set breakpoints in RGM. The only way I found easy is to use Microsoft Visual Studio Code's ability with CMake power. All I had to do is adding this commit [fc9a84a78f6d43e24a3edf43917bcf8054b90b16](https://github.com/enigma-dev/RadialGM/pull/238/commits/fc9a84a78f6d43e24a3edf43917bcf8054b90b16) and [ebc4031dbf0ef4b883a6de1a1835d19c0e330ce0](https://github.com/enigma-dev/RadialGM/pull/238/commits/ebc4031dbf0ef4b883a6de1a1835d19c0e330ce0), then using CMake extension from the left panel, set the build variant to `Debug` and then ``configure`` and ``build``. After the build is done, you can then debug the ``RadialGM-Debug`` executable.

## EMake Not Found: [#238](https://github.com/enigma-dev/RadialGM/pull/238)

While working on this issue, I decided to refactor the whole CMake build system and improve it. These two commits specifically [b01c765404fb91a4d8db3dfe79195b2fc4041af0](https://github.com/enigma-dev/RadialGM/pull/238/commits/b01c765404fb91a4d8db3dfe79195b2fc4041af0) and [4774b30cc96ef7f993945fa831990b45630d7461](https://github.com/enigma-dev/enigma-dev/pull/2399/commits/4774b30cc96ef7f993945fa831990b45630d7461).

It is very studpid that I was trying to ``start`` a directory not an executable haha. The fix to EMake not found is provided here in this commit [5ec507b1d8ba82d763ad9e09f9ae9d93f8bff98e](https://github.com/enigma-dev/RadialGM/pull/238/commits/5ec507b1d8ba82d763ad9e09f9ae9d93f8bff98e). I just modified:
```cpp
process->start(program, arguments);
```
to
```cpp
process->start(emakeFileInfo.filePath(), arguments);
```

You can try my playground project [qprocesstest.zip](/gsoc24-blog/assets/qprocesstest.zip).

I made also multiple improvements in this commit related to some memory leaks and some other issues. For example, I fixed the search paths for the emake executable and I added a little bit a hack to the build system to move all built files to ENIGMA's submodule root, as emake depends on those files. The fix for this is here: [3ef991e31893e89bfa868a259142f5502afac6fa](https://github.com/enigma-dev/RadialGM/pull/238/commits/3ef991e31893e89bfa868a259142f5502afac6fa) and by the way, i generalized it afterwords.

I tried to run a game now but it failed as expected haha. Robert just told me that he was able to build an empty game with RGM and that's true. Additionally, he told me that RGM only missing the extensions support that must be passed as a csv data to the server (emake).

> R0bert — 24/08/2024 20:10

> i was able to build an empty game only when i last built the infrastructure
> that's all i can tell ya

> R0bert — 25/08/2024 01:23

> it should be able to handle real games you just need to add the settings panel for what extensions to enable
> i believe i already did the UI for it, just need to convert it to csv string and pass it i think
> through plugin api ofc, dont have the server plugin directly read the settings panel, add some signals/slots to the RGMPlugin API class
> so it's decoupled

## [nodeeditor](https://github.com/k0T0z/nodeeditor) Integration: [#238](https://github.com/enigma-dev/RadialGM/pull/238)

Anyway, the shader editor integration doesn't require emake to be up and running, it is all about GUI stuff. I will try to add tests to the shader editor as well, just to make sure that it is working as expected.

I managed to integrate the ``QtNodes`` library into RGM without issues. Just to note at the time of writing this there was an issue where the path to the shared library is unknown, so keep in mind that you might need to export the path to the shared library in your ``LD_LIBRARY_PATH``:

```bash
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/path/to/RadialGM/build/lib
```

> Josh — 01/09/2024 at 18:26

> wow, that looks quite beautiful

![QtNodes Finally Integrated](/gsoc24-blog/assets/qtnodes-finally-integrated.png)

The project I used to test the integration is [qtnodestest.zip](/gsoc24-blog/assets/qtnodestest.zip).

## Draft - Don't bother reading this section :)

> R0bert — 25/08/2024 19:29

> there's one more thing, there's a layer above your project that could be future project
> @Saif generating 3d models from images...
> seems complicated but i assure itd just be what youve done plus a few more layers of surfaces and shaders and abstraction


> R0bert — 25/08/2024 19:36

> you might mean signed distance fonts by valve, which are similar in concept yes
> but they are are for making vectorized fonts
> but yes, i know what you mean
> i was studying that for enigma too that might be useful later on because im curious if we could vectorize sprites
> a huge issue i have is that older games which were sprite based dont scale well on our modern 16:9 and hidpi displays and stuff
> vectorizing them could fix a lot of problems
> but for ENIGMA, i suck at making sprites, so if there were a tool that could take my poor low-resolution handmade sprites and turn them into beautiful 3d vectors, i would USE IT

[my-google-summer-of-code-2024-project]: https://summerofcode.withgoogle.com/programs/2024/projects/wYTZuQbA
