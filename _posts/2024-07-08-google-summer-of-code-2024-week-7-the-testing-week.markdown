---
layout: post
title:  "Google Summer of Code 2024 Week 7: The Testing Week"
date:   2024-07-08 00:00:00 +0300
categories: blog
---

This blog post is related to my [Google Summer of Code 2024 project][my-google-summer-of-code-2024-project].

After I finished writing the generator outside the main codebase, Josh and Greg told me to change the project structure. This is because the engine provides only user functions to the user and the generator is just a class that will be used by RGM (no user functions at all). Anyway here is the new project structure:

```

enigma-dev
├── ...
├── CommandLine
│   ├── ...
│   └── testing
│       ├── ...
│       └── Tests
│           ├── ...
│           ├── visual_shader_tests.cpp
│           └── visual_shader_nodes_tests.cpp
│
└── shared
    └── ResourceTransformations
        └── VisualShader
            ├── ...
            ├── visual_shader.h
            ├── visual_shader.cpp
            ├── visual_shader_nodes.h
            └── visual_shader_nodes.cpp

```

## Weird DSO linking error

Before anything, I hate Google's technologies including gRPC, Protobuf, Abseil because Google doesn't care about you facing issues as long as it is working inside their pipelines. Remember the issue I faced in the bonding period while trying to build RGM? The one that presists on my Ubuntu installation and 2 Arch installations? Well, I can't build the ``test-runner`` because of it:

```bash
/usr/bin/ld: .eobjs/EnigmaPlugin.o: undefined reference to symbol '_ZN4absl12lts_2024011612log_internal21CheckOpMessageBuilderC1EPKc'
/usr/bin/ld: /usr/lib/libabsl_log_internal_check_op.so.2401.0.0: error adding symbols: DSO missing from command line
collect2: error: ld returned 1 exit status
make[1]: *** [../../Default.mk:23: ../../emake] Error 1
make[1]: Leaving directory '/home/k0t0z/Desktop/gsoc24/enigma-dev/CommandLine/emake'
make: *** [Makefile:51: emake] Error 2
```

I am not the only genius trying to work this around, it is everywhere:

- https://bbs.archlinux.org/viewtopic.php?id=289986
- https://github.com/protocolbuffers/protobuf/issues/14500#issuecomment-1781292098
- https://github.com/qgis/QGIS/issues/55114
- https://github.com/protocolbuffers/protobuf/issues/15604#issuecomment-1929929148

By combining all the solutions, here is the output:

```bash
/usr/bin/ld: .eobjs/Server.o: undefined reference to symbol 'gpr_inf_future'
/usr/bin/ld: /usr/lib/libgpr.so.41: error adding symbols: DSO missing from command line
collect2: error: ld returned 1 exit status
make[1]: *** [../../Default.mk:23: ../../emake] Error 1
make[1]: Leaving directory '/home/k0t0z/Desktop/gsoc24/enigma-dev/CommandLine/emake'
make: *** [Makefile:51: emake] Error 2
```

That's great another dead end. These two errors above are twins and they are here to finish me.


[my-google-summer-of-code-2024-project]: https://summerofcode.withgoogle.com/programs/2024/projects/wYTZuQbA
