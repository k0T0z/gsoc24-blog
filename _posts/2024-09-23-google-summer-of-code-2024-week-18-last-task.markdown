---
layout: post
title:  "Google Summer of Code 2024 Week 18: Last Task"
date:   2024-09-23 00:00:00 +0300
categories: blog
---

This blog post is related to my Google Summer of Code 2024 project: [Procedural Fragment Shader Generation Using Classic Machine Learning][my-google-summer-of-code-2024-project].

This week I worked real fast on finishing up what's left. The documentation is still a thing. There are two tasks left before the documentation. The first one is to finish the VisualShader protobuf message. This will allow RGM to be able to store the graph in a file and be able to load it as well (AKA Serialization). The second task is the rendering part. I need to render the shader to be able to see something on the screen. This will help us to identify if our Machine Learning algorithm is progressing forward or not.

The two tasks are important so I can't miss even a single one of them. I will start with the rendering part because it is the easiest one. 

[my-google-summer-of-code-2024-project]: https://summerofcode.withgoogle.com/programs/2024/projects/wYTZuQbA
