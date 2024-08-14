---
layout: post
title:  "Google Summer of Code 2024 Week 9: For after the midterms"
date:   2024-07-22 00:00:00 +0300
categories: blog
---

This blog post is related to my [Google Summer of Code 2024 project][my-google-summer-of-code-2024-project].

After my conversation with Josh last week, I have talked with Robert as he contributed to ENIGMA's Graphics System.

> Saif — 29/07/2024 19:58

> I also favor the cmake route
> I need to talk to u about how to create a ShaderProgram that visualizes a shader code in a game?
> i have a shader code in a string, and I want to firstly get an image and then apply that shader on it and then viewing the output somehow (not necessarily in a game)

> R0bert — 29/07/2024 20:03

> enigma should have shader_add which is not in GM i think
> or you can create the shader resource in GMX or LGM
> i know the shaders in LGM work i've used them before

> Saif — 30/07/2024 06:16

> interesting!!
> i will try that
> can apply this shader resource on some other resource? like textures, meshes, …

> R0bert — 30/07/2024 11:33

> you can apply it to any polygon/primitive yeah
> to apply it to a texture you have to use render-to-texture via surface_create and surface_set and background_add_from_surface or surface_get_texture (edited)

> R0bert — 30/07/2024 13:36

> if you get stuck making it work, let me know, i guarantee 100% we can get a shader working


[my-google-summer-of-code-2024-project]: https://summerofcode.withgoogle.com/programs/2024/projects/wYTZuQbA
