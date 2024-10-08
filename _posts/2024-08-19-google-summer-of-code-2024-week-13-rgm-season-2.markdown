---
layout: post
title:  "Google Summer of Code 2024 Week 13: RGM, Season 2"
date:   2024-08-19 00:00:00 +0300
categories: blog
---

This blog post is related to my Google Summer of Code 2024 project: [Procedural Fragment Shader Generation Using Classic Machine Learning][my-google-summer-of-code-2024-project].

## Local Not Required

The error I encountered stemmed from gRPC not loading correctly. Initially, I suspected that this issue was due to the manually built packages, so I decided to clean them up and switch to using `pacman`. I knew the steps to take.

Regarding the Abseil linking error, similar to how linking `-labseil_dll` resolved a previous issue, I discovered through trial and error that adding `-labsl_log_internal_message` and `-labsl_log_internal_check_op` also fixed the problem. Consequently, I could run RGM with the packages installed via `pacman`, but unfortunately, the same error persisted.

## Revisiting the Runtime Issue

When I encounter a problem, it tends to occupy my thoughts until I find a solution. Despite Robert advising me to focus on my work and not dwell on the issue, I continued to investigate. By sheer luck, on August 17, 2024, I managed to resolve the runtime issue (الحمدلله). Let me explain the situation and summarize the entire process.

In CMake, there are two methods for locating a package, represented by two types of files: `Find<package>.cmake` and `<package>Config.cmake`. While the latter is considered the modern approach, ENIGMA, being 16 years old, still relies on the former method to find packages.

As I worked on RGM, I addressed some issues within its CMake files, particularly regarding how to locate gRPC and protobuf. However, I neglected to check other CMake files, specifically `enigma-dev/shared/CMakeLists.txt`, `enigma-dev/shared/protos/CMakeLists.txt`, `enigma-dev/CommandLine/emake/CMakeLists.txt`, and `enigma-dev/CommandLine/libEGM/CMakeLists.txt`. All of these files utilized the following method to find gRPC and protobuf:

```cmake
include(FindProtobuf)
target_link_libraries(${LIB_EGM} PRIVATE ${Protobuf_LIBRARY})
```

or 

```cmake
include_directories(${Protobuf_INCLUDE_DIRS})
target_link_libraries(${LIB_PROTO} PRIVATE ${Protobuf_LIBRARIES})
```

I replaced these lines with:

```cmake
find_package(Protobuf CONFIG REQUIRED)
target_link_libraries(${LIB_PROTO} PRIVATE protobuf::libprotobuf)
```

These new lines function correctly whether using system packages or local ones.

So, how is this related to the runtime issue? Although I’m unsure about the exact differences between the two file types, I do know that mixing them can lead to runtime errors. This issue is particularly unpredictable because everything appeared to work fine during the linking process, which completed successfully. However, if you look at the error output, you might be able to identify the problem. Even after debugging the code and examining the stack trace:

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

Did you spot the issue? It’s challenging, and I managed to resolve it purely by chance. Robert, Kartik, and I explored numerous solutions, but nothing worked until I finally fixed it on August 17, 2024. Robert acknowledged my progress with a thumbs-up for every message I sent that day. The process was challenging yet enjoyable.

> kartik — 17/08/2024 20:23

> nope never seen this before, but glad that you're able to build the rgm

> R0bert — 17/08/2024 20:26

> this is beautiful and im not surprised at all
> based on the debugging from yesterday i was suspecting something was going wrong with linking
> i suspect the old way was linking twice as you said and the static initialization was called twice
> so this is great, this is excellent
> im giving every comment here a thumbs up because that is some good stuff!
> now onward and upward with the project

Building RGM is now complete, and I am ready to focus on the UI development.

I would like to point out that the recent changes will not work on Ubuntu, as it lags significantly behind Arch Linux by about 1,000 versions. This means that if you are using Ubuntu, you will need to build Abseil, protobuf, and gRPC manually.

Additionally, I have decided to refactor the entire CMake build system. All the changes can be found in the following two pull requests:

- [#238](https://github.com/enigma-dev/RadialGM/pull/238)
- [#2399](https://github.com/enigma-dev/enigma-dev/pull/2399)

This brings me to the reason I titled my update [Google Summer of Code 2024 Week 7, 8, and 9: My Boogeyperiod](https://k0t0z.github.io/gsoc24-blog/blog/2024/07/07/google-summer-of-code-2024-week-7-8-and-9-my-boogeyperiod.html)—I spent nearly 1.5 months tackling this issue.

## Unexpected Issues

Even after fixing emake, I encountered an error when trying to build emake using VSCode tasks:

```
/usr/local/bin/grpc_cpp_plugin: error while loading shared libraries: libgrpc_plugin_support.so.1.65: cannot open shared object file: No such file or directory
--grpc_out: protoc-gen-grpc: Plugin failed with status code 127.
```

This issue is perplexing because the same command runs without problems when executed directly from the terminal. I do not see anything wrong with my configuration files:

**launch.json**:
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
          "args": ["--gtest_filter=VisualShaderTest.*"],
          "stopAtEntry": false,
          "cwd": "${workspaceFolder}",
          "environment": [],
          "externalConsole": false,
          "setupCommands": [
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

**tasks.json**:
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
            "args": ["test-runner"]
        }
    ]
}
```

## Debugging RGM: [#238](https://github.com/enigma-dev/RadialGM/pull/238)

Before diving into the UI integration, let's discuss how to set breakpoints in RGM. I found it easiest to leverage Microsoft Visual Studio Code’s integration with CMake. By adding the following commits—[fc9a84a78f6d43e24a3edf43917bcf8054b90b16](https://github.com/enigma-dev/RadialGM/pull/238/commits/fc9a84a78f6d43e24a3edf43917bcf8054b90b16) and [ebc4031dbf0ef4b883a6de1a1835d19c0e330ce0](https://github.com/enigma-dev/RadialGM/pull/238/commits/ebc4031dbf0ef4b883a6de1a1835d19c0e330ce0), I was able to set the build variant to `Debug` using the CMake extension from the left panel. After configuring and building, you can debug the `RadialGM-Debug` executable.

## EMake Not Found: [#238](https://github.com/enigma-dev/RadialGM/pull/238)

While addressing this issue, I undertook a comprehensive refactor of the CMake build system to enhance its functionality. Two specific commits are noteworthy: [b01c765404fb91a4d8db3dfe79195b2fc4041af0](https://github.com/enigma-dev/RadialGM/pull/238/commits/b01c765404fb91a4d8db3dfe79195b2fc4041af0) and [4774b30cc96ef7f993945fa831990b45630d7461](https://github.com/enigma-dev/enigma-dev/pull/2399/commits/4774b30cc96ef7f993945fa831990b45630d7461).

It was rather silly of me to try to `start` a directory instead of an executable! The fix for the EMake not found issue is detailed in this commit: [5ec507b1d8ba82d763ad9e09f9ae9d93f8bff98e](https://github.com/enigma-dev/RadialGM/pull/238/commits/5ec507b1d8ba82d763ad9e09f9ae9d93f8bff98e), where I modified the code from:

```cpp
process->start(program, arguments);
```

to:

```cpp
process->start(emakeFileInfo.filePath(), arguments);
```

You can also explore my playground project [qprocesstest.zip](/gsoc24-blog/assets/qprocesstest.zip).

Additionally, I made multiple improvements in this commit to address memory leaks and other issues. For instance, I fixed the search paths for the emake executable and introduced a workaround in the build system to relocate all built files to the root of ENIGMA's submodule, as emake relies on those files. The fix for this can be found in this commit: [3ef991e31893e89bfa868a259142f5502afac6fa](https://github.com/enigma-dev/RadialGM/pull/238/commits/3ef991e31893e89bfa868a259142f5502afac6fa), and I generalized it afterward.

I attempted to run a game, but as expected, it failed. Robert mentioned that he successfully built an empty game with RGM, which is true. He also pointed out that RGM is currently lacking support for extensions that must be passed as CSV data to the server (emake).

> R0bert — 24/08/2024 20:10

> i was able to build an empty game only when i last built the infrastructure
> that's all i can tell ya

> R0bert — 25/08/2024 01:23

> it should be able to handle real games you just need to add the settings panel for what extensions to enable
> i believe i already did the UI for it, just need to convert it to csv string and pass it i think
> through plugin api ofc, dont have the server plugin directly read the settings panel, add some signals/slots to the RGMPlugin API class
> so it's decoupled

## [nodeeditor](https://github.com/k0T0z/nodeeditor) Integration: [#238](https://github.com/enigma-dev/RadialGM/pull/238)

The integration of the shader editor does not require emake to be operational, as it primarily involves GUI components. I also plan to add tests for the shader editor to ensure it functions as expected.

I successfully integrated the **QtNodes** library into RGM without any issues. However, please note that at the time of this writing, there is a known issue regarding the path to the shared library being undefined. To resolve this, you may need to export the path to the shared library in your `LD_LIBRARY_PATH` environment variable. You can do this by running the following command:

```bash
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/path/to/RadialGM/build/lib
```

> Josh — 01/09/2024 at 18:26

> wow, that looks quite beautiful

![QtNodes Finally Integrated](/gsoc24-blog/assets/qtnodes-finally-integrated.png)

I used the project [qtnodestest.zip](/gsoc24-blog/assets/qtnodestest.zip) to test the integration.

## RGM and ENIGMA

RGM utilizes QProcess technology to invoke the server (emake). This server depends on shared packages that are built by ENIGMA. To facilitate this process, I modified the build system to move the built files to the root of the ENIGMA submodule. Please keep this in mind while developing RGM.

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
