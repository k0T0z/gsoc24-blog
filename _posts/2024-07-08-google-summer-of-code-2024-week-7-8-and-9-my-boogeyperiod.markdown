---
layout: post
title:  "Google Summer of Code 2024 Week 7, 8, and 9: My Boogeyperiod"
date:   2024-07-08 00:00:00 +0300
categories: blog
---

This blog post is related to my Google Summer of Code 2024 project: [Procedural Fragment Shader Generation Using Classic Machine Learning][my-google-summer-of-code-2024-project].

I was planning to start testing the ``VisualShader`` class after I reach a stable state with the generator.

## Weird DSO linking error

Before anything, I hate Google's technologies including gRPC, Protobuf, Abseil because Google doesn't care about you facing issues as long as it is working inside their pipelines. Remember the issue I faced in the bonding period ([Google Summer of Code 2024 Bonding Period](https://k0t0z.github.io/gsoc24-blog/blog/2024/05/15/google-summer-of-code-2024-bonding-period.html)) while trying to build RGM? The one that presists on my Ubuntu installation and 2 Arch installations? Well, I can't build the ``test-runner`` because of it:

```bash
/usr/bin/ld: .eobjs/EnigmaPlugin.o: undefined reference to symbol '_ZN4absl12lts_2024011612log_internal21CheckOpMessageBuilderC1EPKc'
/usr/bin/ld: /usr/lib/libabsl_log_internal_check_op.so.2401.0.0: error adding symbols: DSO missing from command line
collect2: error: ld returned 1 exit status
make[1]: *** [../../Default.mk:23: ../../emake] Error 1
make[1]: Leaving directory '/home/k0t0z/Desktop/gsoc24/enigma-dev/CommandLine/emake'
make: *** [Makefile:51: emake] Error 2
```

This time, it is not about RGM. I made some simple research and founc out that I am not the only genius trying to work this around, it is everywhere:

- https://bbs.archlinux.org/viewtopic.php?id=289986
- https://github.com/protocolbuffers/protobuf/issues/14500#issuecomment-1781292098
- https://github.com/qgis/QGIS/issues/55114
- https://github.com/protocolbuffers/protobuf/issues/15604#issuecomment-1929929148

A lot of variations from the above link error showed up on each change, however, none of these changes solve the problem.

Josh and I thought at first that it is because the linking interface between gRPC, Protobuf, and Abseil is not stable. This means in order to solve this problem, I am gonna diverge and build gRPC, Protobuf, and Abseil from scratch. I asked my mate Fares to give me the versions he is using on Ubuntu and actually these versions are too old to have even a CMake build system. This motivated my memory to remember that Ubuntu actually is a stable distro and doesn't have the latest versions of the libraries. 

At this point, I decided to move to Ubuntu for now because my Midterm Evaluation is coming and I need to show some progress.

## ``VisualShader`` Types

In order to complete the ``generate_shader_for_each_node`` function, I needed some types to use. Some of these types are actually implemented inside the engine, such as [variant](https://github.com/enigma-dev/enigma-dev/blob/3590b681f20174ccf24156769d2bbb94b10673e3/ENIGMAsystem/SHELL/Universal_System/var4.h#L279), however, I don't know if this possible or not because remember our ``VisualShader`` class is not part of the engine, it is part of the ``shared`` library. In which case, I created a new temporary custom type as follows:

{% highlight cpp %}
using TVariant = std::variant<std::monostate, float, int, TVector2, TVector3, TVector4, bool, std::string>;
{% endhighlight %}

The ``T`` in all types is for ``Temporary``. Actually, the ``VisualShader`` class is not injected into anything yet, it is a stanalone class that can be built by a simple g++ command. The other types are also temporary and will be replaced by the engine types when they are here if they are not already.

## Most Important Operations In The Generator

> Saif — 19/07/2024 20:37

> What type of operation that will be useful for the generated code? for example: - + / * mod ... also but what about color effects?
> like color blend or darken and lighten and all that?

> Josh — 19/07/2024 20:39

> matrix and arithmetic operations make a ton of sense
> for me, the important operation is range mapping
> so, you can check out the SVG specification for a pretty meh implementation of generalized filters
> but what I think is missing is the ability to create step functions
> basically, the ability to say "for values 0-0.5, use this filter; for values 0.5-1, use this one"
> especially if it can automatically interpolate between them
> by matrix operations, I just mean multiplying color channels
> so basically, you have [r,g,b,a, const...] and the user specifies the matrix to multiply that by

Let me explain the above conversation. The aim of this project is to generate some meaningful art using noise filters. This means we can't have normal nodes like other game engines such as ``Godot`` or ``Unity``, however, we need custom nodes that our AI Agent will be able to use. Of course the most reasonable nodes are the arthmetic operations for scalars and vectors.

Beside custom nodes, we need more parameters for each node to give our AI Agent a lot of choices to pick from. For example, the ``ValueNoise`` node which is the first one I created, currently has ``scale`` parameter. This is not enough, we need more parameters such as inside this amazing application [FastNoiseLite](https://auburn.github.io/FastNoiseLite/).

> Josh — 21/07/2024 19:38

> octaves and frequency (preferably h/v separately) are the most important
> the domain warp should be a separate step
> distance function for lerp is also good to have, but less important for perlin noise
> yeah, perlin noise is 2D, so it often has two frequencies, but I suppose if we're allowing transformations on domain and range, frequency doesn't even matter
> you can force the perlin noise to have a domain of 0-1 and make the user map it differently

There will be more detailed explanation about this when I reach the AI part.

![Fast Noise Tool](/gsoc24-blog/assets/fast-noise-tool.png)

## The Renderer

Why we are implementing the ``Visual Shader Editor`` in the first place? Well, because in order to see how good our AI Agent perform. We will need to render the generated shader. Of course we will have an error function that will tell us how good the shader is, but we need to see it with our eyes as Josh recommended.

When it come for rendering and graphics, then you mean Robert. I am not ready yet for the renderer, but I like to know things in advance. I wanted to know how I am gonna apply my shader to a specific resource. For example, if I have a sprite or a background, how I am gonna apply the shader to it. Like if I want to make a disappering effect, how I am gonna apply it to a sprite. There are some built in variables that ENIGMA prepends to the shader code.

> R0bert — 23/07/2024 19:28

> ENIGMA has a little abstraction, the shaders are intended to have built in variables
> like gm_Matrix and stuff, but idk if each backend to sets all the variables its supposed to like GM does
> but not a language abstraction yet
> its just uniform variable declarations that we prepend to the code of every user shader
> its just our way of communicating things like the projection to the user's shaders
> yeah i think there's gm_Texture too
> d3d and opengl have 8 texture samplers built in or w/e
> the shader gets a sampler object, so gm_Texture is an array i think of 8 or something
> we bind the texture to the texture sampler
> and then it can read it
> opengl calls them texture units, direct3d calls them texture stages
> sampler refers to the gpu side, in both cases
> https://registry.khronos.org/OpenGL-Refpages/gl4/html/glBindTextureUnit.xhtml

> Saif — 23/07/2024 19:37

> if i have a shader code that changes the color (vec4), it calculates it firstly and then applies it, this way of applying the effect on the texture is done by?

> R0bert — 23/07/2024 19:38

> it sounds like you're describing render-to-texture, i've never done that in glsl before
> in typical case you'd render a flat 2d plane with the texture
> you might be able to write to a texture buffer from glsl idk
> and yes you need render-to-texture to postprocessing mostly...
> so i think all you need to do is render a 2d quad
> and create a surface (aka render-to-texture texture)
> surface_create(width, height)
> surface_set(mysurfid)
> shader_set(saifsshaderid)
> draw_rectangle(0,0,width,height)
> those are the functions you need
> put your texture in a background or sprite
> you dont need to get at the actual texture
> just draw it with draw_background_stretched
> albeit i did add special texture_add functions to enigma, but ignore those ENIGMA only
> easier if you just use background/make it self contained
> anyway yeah then...
> you can use surface_save and surface_get_texture if you want to do anything with the surface
> @Saif you can dump it out or draw other objects with the effected texturealbeit i did add special texture_add functions to enigma, but ignore those ENIGMA only

I had all this conversation with Robert because I wanted to know how I am gonna use ENIGMA's Graphics System to render the shader. So most of these function that Robert mentioned are also part of the engine such as ``surface_create``, ``surface_set``, ``shader_set``, ``draw_rectangle``, ``draw_background_stretched``, ``surface_save``, and ``surface_get_texture``.

[my-google-summer-of-code-2024-project]: https://summerofcode.withgoogle.com/programs/2024/projects/wYTZuQbA
