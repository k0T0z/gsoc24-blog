---
layout: post
title:  "Google Summer of Code 2024 Bonding Period"
date:   2024-05-16 00:00:00 +0300
categories: blog
---

This blog post is related to my Google Summer of Code 2024 project: [Procedural Fragment Shader Generation Using Classic Machine Learning][my-google-summer-of-code-2024-project].

After installing Arch Linux, I can build RGM, just to do something in this period. Of courcse, it won't run from the first time and I am gonna leave the error here for future reference:
    
```bash
    [ 76%] Linking CXX executable emake
    /usr/bin/ld: CMakeFiles/emake.dir/EnigmaPlugin.cpp.o: undefined reference to symbol '_ZN4absl12lts_2024011612log_internal21CheckOpMessageBuilderC1EPKc'
    /usr/bin/ld: /usr/lib/libabsl_log_internal_check_op.so.2401.0.0: error adding symbols: DSO missing from command line
    collect2: error: ld returned 1 exit status
    make[2]: *** [Submodules/enigma-dev/CommandLine/emake/CMakeFiles/emake.dir/build.make:203: Submodules/enigma-dev/CommandLine/emake/emake] Error 1
    make[1]: *** [CMakeFiles/Makefile2:625: Submodules/enigma-dev/CommandLine/emake/CMakeFiles/emake.dir/all] Error 2
    make: *** [Makefile:136: all] Error 2
```

Before installing Arch Linux, I tried to build RGM using my Ubuntu machine but same error. That was before being accepted in GSoC.

In this bonding period, I didn't do much as I was busy with my final exams. 

Late in the bonding period, specifically on May 24th, I want to start writing some code so started wondering where to put it. The whole organization of the project is still unclear.

Anyway, The graph backend is not related to the ``Graphics_Systems``, although, it will require a system to render the generated shader. I think the most suitable location is inside ``Universal_System``. Josh was also fine with this location.

The expected structure of my files will be:
    
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

When the graph is implemented, I will start implementing the generator although I am not sure how I am gonna visualize the output shader. I will talk to my mentor about this however maybe I will have to integrate the node editor with RGM which is something I don't want to do.


[my-google-summer-of-code-2024-project]: https://summerofcode.withgoogle.com/programs/2024/projects/wYTZuQbA
