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

[my-google-summer-of-code-2024-project]: https://summerofcode.withgoogle.com/programs/2024/projects/wYTZuQbA
