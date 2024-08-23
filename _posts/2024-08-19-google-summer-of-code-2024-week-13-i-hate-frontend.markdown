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

[my-google-summer-of-code-2024-project]: https://summerofcode.withgoogle.com/programs/2024/projects/wYTZuQbA
