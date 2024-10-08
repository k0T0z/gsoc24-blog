---
layout: post
title:  "Google Summer of Code 2024 Bonding Period"
date:   2024-05-16 00:00:00 +0300
categories: blog
---

This blog post is related to my Google Summer of Code 2024 project: [Procedural Fragment Shader Generation Using Classic Machine Learning][my-google-summer-of-code-2024-project].

After installing Arch Linux, I plan to build RGM as a productive task during this period. Naturally, it won't run successfully on the first attempt, so I'll document the error here for future reference:
    
```bash
    [ 76%] Linking CXX executable emake
    /usr/bin/ld: CMakeFiles/emake.dir/EnigmaPlugin.cpp.o: undefined reference to symbol '_ZN4absl12lts_2024011612log_internal21CheckOpMessageBuilderC1EPKc'
    /usr/bin/ld: /usr/lib/libabsl_log_internal_check_op.so.2401.0.0: error adding symbols: DSO missing from command line
    collect2: error: ld returned 1 exit status
    make[2]: *** [Submodules/enigma-dev/CommandLine/emake/CMakeFiles/emake.dir/build.make:203: Submodules/enigma-dev/CommandLine/emake/emake] Error 1
    make[1]: *** [CMakeFiles/Makefile2:625: Submodules/enigma-dev/CommandLine/emake/CMakeFiles/emake.dir/all] Error 2
    make: *** [Makefile:136: all] Error 2
```

Before installing Arch Linux, I attempted to build RGM on my Ubuntu machine, but encountered the same error. This was before I was accepted into GSoC.

During the bonding period, I wasn’t able to contribute much, as I was occupied with my final exams.

Later in the bonding period, specifically on May 24th, I wanted to begin writing some code but was unsure where to place it, as the overall project structure was still unclear.

In any case, the graph backend isn't directly related to the `Graphics_Systems`, although it will require a system for rendering the generated shaders. After some thought, I concluded that the most suitable location for it would be within the `Universal_System`, and Josh agreed with this placement.

Here’s the expected structure of my files:
    
```
enigma-dev
├── ...
├── CommandLine
│   ├── ...
│   └── emake-tests
│       ├── ...
│       └── ShaderGraphTests
│           ├── ...
│           ├── GraphTests.cpp
│           └── NodeTests.cpp
└── ENIGMAsystem
    └── SHELL
        ├── ...
        └── Universal_System
            ├── ...
            └── ShaderGraph
                ├── ...
                ├── Graph.cpp
                ├── Graph.h
                ├── Node.cpp
                └── Node.h
```

Once the graph is implemented, I will move on to developing the generator. However, I'm unsure how I will visualize the output shader. I'll discuss this with my mentor, but there's a possibility that I might need to integrate the node editor with RGM, which I would prefer to avoid.


[my-google-summer-of-code-2024-project]: https://summerofcode.withgoogle.com/programs/2024/projects/wYTZuQbA
