---
layout: post
title:  "Google Summer of Code 2024 Week 13: I Hate Frontend"
date:   2024-08-19 00:00:00 +0300
categories: blog
---

This blog post is related to my Google Summer of Code 2024 project: [Procedural Fragment Shader Generation Using Classic Machine Learning][my-google-summer-of-code-2024-project].

## Debugging RGM

Before talking about the UI integration, let's talk about how to set breakpoints in RGM. The only way I found easy is to use Microsoft Visual Studio Code's ability with CMake power. All I had to do is adding this commit [fc9a84a78f6d43e24a3edf43917bcf8054b90b16](https://github.com/enigma-dev/RadialGM/pull/238/commits/fc9a84a78f6d43e24a3edf43917bcf8054b90b16) and [ebc4031dbf0ef4b883a6de1a1835d19c0e330ce0](https://github.com/enigma-dev/RadialGM/pull/238/commits/ebc4031dbf0ef4b883a6de1a1835d19c0e330ce0), then using CMake extension from the left panel, set the build variant to `Debug` and then ``configure`` and ``build``. After the build is done, you can then debug the ``RadialGM-Debug`` executable.

## EMake is not found

While working on this issue, I decided to refactor the whole CMake build system and improve it. These two commits specifically [b01c765404fb91a4d8db3dfe79195b2fc4041af0](https://github.com/enigma-dev/RadialGM/pull/238/commits/b01c765404fb91a4d8db3dfe79195b2fc4041af0) and [4774b30cc96ef7f993945fa831990b45630d7461](https://github.com/enigma-dev/enigma-dev/pull/2399/commits/4774b30cc96ef7f993945fa831990b45630d7461).

It is very studpid that I was trying to ``start`` a directory not an executable haha. The fix to EMake not found is provided here in this commit [5ec507b1d8ba82d763ad9e09f9ae9d93f8bff98e](https://github.com/enigma-dev/RadialGM/pull/238/commits/5ec507b1d8ba82d763ad9e09f9ae9d93f8bff98e). I just modified:
```cpp
process->start(program, arguments);
```
to
```cpp
process->start(emakeFileInfo.filePath(), arguments);
```

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

Anyway, the shader editor integration doesn't require emake to be up and running, it is all about GUI stuff. I will try to add tests to the shader editor as well, just to make sure that it is working as expected.

[my-google-summer-of-code-2024-project]: https://summerofcode.withgoogle.com/programs/2024/projects/wYTZuQbA
