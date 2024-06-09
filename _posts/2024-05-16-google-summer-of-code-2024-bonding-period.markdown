---
layout: post
title:  "Google Summer of Code 2024 Bonding Period"
date:   2024-05-16 00:00:00 +0300
categories: blog
---

This blog post is related to my [Google Summer of Code 2024 project][my-google-summer-of-code-2024-project].

After installing Arch Linux, I can build RGM, just to do something in this period. The problem is that I tried to build RGM on my Ubuntu machine and it failed. It gives me this error:
    
```bash
    [ 76%] Linking CXX executable emake
    /usr/bin/ld: CMakeFiles/emake.dir/EnigmaPlugin.cpp.o: undefined reference to symbol '_ZN4absl12lts_2024011612log_internal21CheckOpMessageBuilderC1EPKc'
    /usr/bin/ld: /usr/lib/libabsl_log_internal_check_op.so.2401.0.0: error adding symbols: DSO missing from command line
    collect2: error: ld returned 1 exit status
    make[2]: *** [Submodules/enigma-dev/CommandLine/emake/CMakeFiles/emake.dir/build.make:203: Submodules/enigma-dev/CommandLine/emake/emake] Error 1
    make[1]: *** [CMakeFiles/Makefile2:625: Submodules/enigma-dev/CommandLine/emake/CMakeFiles/emake.dir/all] Error 2
    make: *** [Makefile:136: all] Error 2
```

Even with my Arch Linux machine, I can't build RGM. Last time, I built eveything from scratch including gRPC and protobuf but didn't work. I thought the problem is with the manual build of gRPC and protobuf, so I tried to build them using `pacman` but it didn't work either.

Anyway, thanks god this is not a high priority task. I guess I am gonna switch tasks now. If at any chance you read my proposal, you will know that this project is splitted into 2 parts:

1. The backend, including the graph and the generator.
2. The frontend, including the editor (both the visual and the code editor).

In order for this to go without problems, I need to see the output shader, which mean I will have to implement a shader renderer that I can use to render the output shader. It has to be separated from the engine as it must has a GUI stuff in order to see the animated shader.

For now, I am gonna start implementing the graph functionalities. Where is the location in the codebase? Well let's figure this out before the coding period starts.

By the way, I found a problem with the current CMakeLists.txt file. It doesn't link all required Qt5 libraries. The one that is missing is `qscintilla-qt5`. Hmmmm, I don't think this lib has a CMake configuration files for ``find_package`` command to work. To be continued...

Anyway, The graph backend is not related to the ``Graphics_Systems``, although, it will require a system to render the generated shader. I think the most suitable location is inside ``Universal_System``.

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
