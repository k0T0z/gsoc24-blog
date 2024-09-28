---
layout: post
title:  "Google Summer of Code 2024 Week 19: Wrapping Up"
date:   2024-09-30 00:00:00 +0300
categories: blog
---

This blog post is related to my Google Summer of Code 2024 project: [Procedural Fragment Shader Generation Using Classic Machine Learning][my-google-summer-of-code-2024-project].

What a project! I can say that I would be happier if I had more time to work on it. I have learned a lot of things, and I have implemented a lot of things. This is another reason for me to continue working on this project after the Google Summer of Code program. I will actaully do that. What I loved about working on this project is that I faced a couple of issues that I overcame after a hackup long time. I will walk through each one now.

## The first issue: ``test-runner`` doesn't work on Arch Linux

The ``test-runner`` which will include my tests doesn't work on my main machine however, it is worked on an Ubuntu VM. That's why I moved to an Ubuntu VM for a couple of weeks. I was unsatisfied to look the other way and pretend that there are no issues so I decided to fix it. The issue first shown up before getting accepted to the Google Summer of Code program when I tried building RGM on my Ubuntu machine. I first explained it here: [Google Summer of Code 2024 Bonding Period](https://k0t0z.github.io/gsoc24-blog/blog/2024/05/15/google-summer-of-code-2024-bonding-period.html). It was first appeared with the CMake build system with RGM on an Ubuntu machine. It is also appeared in week 7: [google-summer-of-code-2024-week-7-the-testing-week.html#weird-dso-linking-error](https://k0t0z.github.io/gsoc24-blog/blog/2024/07/07/google-summer-of-code-2024-week-7-the-testing-week.html#weird-dso-linking-error). I thought at first that this is because of a problem between Abseil, Protobuf, and gRPC packages. I asked my friend Fares to tell what versions he was using on his Ubuntu machine so that I use them but I found out that these versions are too old to have a CMake build system. That's why I created this solution: [absl-proto-grpc-ci](https://github.com/k0T0z/absl-proto-grpc-ci) to find the working three versions of all packages together. I graped these 3 versions and cloned, built, and installed the three packages locally to me ``/usr/local/`` but the same problem presisted.

I started working on it after the midterm evaluation when it is the time to build RGM: [google-summer-of-code-2024-week-11-rgm.html](https://k0t0z.github.io/gsoc24-blog/blog/2024/08/04/google-summer-of-code-2024-week-11-rgm.html). Remember that this same problem appeared when building RGM on both Arch and Ubuntu Linux machines. I managed to solve it the week after: [google-summer-of-code-2024-week-12-rgm-season-2.html](https://k0t0z.github.io/gsoc24-blog/blog/2024/08/11/google-summer-of-code-2024-week-12-rgm-season-2.html), it was a simple missing library to the ``LD`` variable: ``-lgpr`` and ``-labseil_dll``/``-labsl_log_internal_message -labsl_log_internal_check_op``.

## The second issue: RGM Runtime Error

For solving this issue, I took the chance to refactor the whole RGM's CMake build system. I made a lot of improvements. This issue is explained well inside: [google-summer-of-code-2024-week-12-rgm-season-2.html#runtime-story](https://k0t0z.github.io/gsoc24-blog/blog/2024/08/11/google-summer-of-code-2024-week-12-rgm-season-2.html#runtime-story).

[my-google-summer-of-code-2024-project]: https://summerofcode.withgoogle.com/programs/2024/projects/wYTZuQbA
