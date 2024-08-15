---
layout: post
title:  "Google Summer of Code 2024 Week 11: RGM"
date:   2024-08-05 00:00:00 +0300
categories: blog
---

This blog post is related to my [Google Summer of Code 2024 project][my-google-summer-of-code-2024-project].

Building RGM is a very interesting task, but before building it, I need to make be able to build emake properly. emake is the way to build games without a GUI. Remember that I couldn't build emake in the bonding period? the error was as follows:

```bash
    [ 76%] Linking CXX executable emake
    /usr/bin/ld: CMakeFiles/emake.dir/EnigmaPlugin.cpp.o: undefined reference to symbol '_ZN4absl12lts_2024011612log_internal21CheckOpMessageBuilderC1EPKc'
    /usr/bin/ld: /usr/lib/libabsl_log_internal_check_op.so.2401.0.0: error adding symbols: DSO missing from command line
    collect2: error: ld returned 1 exit status
    make[2]: *** [Submodules/enigma-dev/CommandLine/emake/CMakeFiles/emake.dir/build.make:203: Submodules/enigma-dev/CommandLine/emake/emake] Error 1
    make[1]: *** [CMakeFiles/Makefile2:625: Submodules/enigma-dev/CommandLine/emake/CMakeFiles/emake.dir/all] Error 2
    make: *** [Makefile:136: all] Error 2
```

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

This is to get rid of the old versions of the libraries (if any).

Now, building those libraries is very easy, as well as installing them.

## Prioritizing local over system

When trying to build emake, this warning shows up:

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

```
linux-vdso.so.1 (0x000071154c52f000)
libsystemd.so.0 => /usr/lib/libsystemd.so.0 (0x000071154c3f5000)
<span style="color: red;">libgrpc_plugin_support.so.1.65 => not found</span>
libm.so.6 => /usr/lib/libm.so.6 (0x000071154c30a000)
<span style="color: red;">libprotoc.so.27.3.0 => not found</span>
<span style="color: red;">libprotobuf.so.27.3.0 => not found</span>
<span style="color: red;">libabseil_dll.so.2407.0.0 => not found</span>
libstdc++.so.6 => /usr/lib/libstdc++.so.6 (0x000071154c000000)
libgcc_s.so.1 => /usr/lib/libgcc_s.so.1 (0x000071154c2db000)
libc.so.6 => /usr/lib/libc.so.6 (0x000071154be14000)
libcap.so.2 => /usr/lib/libcap.so.2 (0x000071154c2cf000)
/lib64/ld-linux-x86-64.so.2 => /usr/lib64/ld-linux-x86-64.so.2 (0x000071154c531000)
```

There are ``not found`` libraries as you can see. If you used ``which`` with any of the nof founded libs, you will find it inside ``/usr/local/lib``. The solution is to export the path to the libraries by adding this line to your ``.bashrc`` file:

```bash
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
```

Now, you can run the command again:

```bash
ldd $(which grpc_cpp_plugin)
```

```
linux-vdso.so.1 (0x0000765352968000)
libsystemd.so.0 => /usr/lib/libsystemd.so.0 (0x000076535282d000)
<span style="color: blue;">libgrpc_plugin_support.so.1.65 => /usr/local/lib/libgrpc_plugin_support.so.1.65 (0x00007653527a6000)</span>
libm.so.6 => /usr/lib/libm.so.6 (0x00007653526bb000)
<span style="color: blue;">libprotoc.so.27.3.0 => /usr/local/lib/libprotoc.so.27.3.0 (0x0000765352200000)</span>
<span style="color: blue;">libprotobuf.so.27.3.0 => /usr/local/lib/libprotobuf.so.27.3.0 (0x0000765351e00000)</span>
<span style="color: blue;">libabseil_dll.so.2407.0.0 => /usr/local/lib/libabseil_dll.so.2407.0.0 (0x0000765351cc7000)</span>
libstdc++.so.6 => /usr/lib/libstdc++.so.6 (0x0000765351a00000)
libgcc_s.so.1 => /usr/lib/libgcc_s.so.1 (0x00007653521d3000)
libc.so.6 => /usr/lib/libc.so.6 (0x0000765351814000)
libcap.so.2 => /usr/lib/libcap.so.2 (0x00007653521c7000)
/lib64/ld-linux-x86-64.so.2 => /usr/lib64/ld-linux-x86-64.so.2 (0x000076535296a000)
libz.so.1 => /usr/local/lib/libz.so.1 (0x00007653521a6000)
```

[my-google-summer-of-code-2024-project]: https://summerofcode.withgoogle.com/programs/2024/projects/wYTZuQbA
