---
layout: post
title:  "Google Summer of Code 2024 Week 13: RGM, Season 2"
date:   2024-08-19 00:00:00 +0300
categories: blog
---

This blog post is related to my Google Summer of Code 2024 project: [Procedural Fragment Shader Generation Using Classic Machine Learning][my-google-summer-of-code-2024-project].

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

Now you know why I called it [Google Summer of Code 2024 Week 7, 8, and 9: My Boogeyperiod](https://k0t0z.github.io/gsoc24-blog/blog/2024/07/07/google-summer-of-code-2024-week-7-8-and-9-my-boogeyperiod.html). This is because I spent nearly 1.5 months on this issue.

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

## RGM And ENIGMA

RGM invokes the server (emake) using QProcess technology. This server requires the shared packages that are built by ENIGMA. I have modified the build system to move the built files to the ENIGMA submodule root. Keep this in mind while developing RGM.

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
