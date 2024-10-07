---
layout: post
title:  "Google Summer of Code 2024 Week 11 and 12: RGM"
date:   2024-08-05 00:00:00 +0300
categories: blog
---

This blog post is related to my Google Summer of Code 2024 project: [Procedural Fragment Shader Generation Using Classic Machine Learning][my-google-summer-of-code-2024-project].

```
Note: Before trying to build gRPC from scratch, see this: [Local Not Needed](https://k0t0z.github.io/gsoc24-blog/blog/2024/08/04/google-summer-of-code-2024-week-11-12-and-13-rgm.html#local-not-needed).
```

The Final evaluation work will be inside [#2399](https://github.com/enigma-dev/enigma-dev/pull/2399).

## Back To ``test-runner`` Issue On Arch Linux

Remember that I am working on my Ubuntu VM as ``test-runner`` gives a link error on Arch Linux. However, RGM gives a linking error on both Ubuntu and Arch Linux. Because of this, I have decided to make ``test-runner`` work on Arch Linux.

As I explained in [Google Summer of Code 2024 Bonding Period](https://k0t0z.github.io/gsoc24-blog/blog/2024/05/15/google-summer-of-code-2024-bonding-period.html) post, the error is about linking ``emake`` failed. ``emake`` is the way to build games without a GUI as explained by Greg.

This error appears only on Arch linux, not Ubuntu. I guess that's because of the differences between old and new absl. I think the new absl has new targets that we need to link as well. Anyway, I asked Fares to give me the versions of Absl, Protobuf, and gRPC that he is using on Ubuntu. I will try to use the same versions on Arch.

 - Absl: 20210324.2
 - Protobuf: 3.12.4
 - gRPC: 1.30.2

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

[my-google-summer-of-code-2024-project]: https://summerofcode.withgoogle.com/programs/2024/projects/wYTZuQbA
