---
layout: post
title:  "Google Summer of Code 2024 Week 10: Midterm Evaluation"
date:   2024-07-29 00:00:00 +0300
categories: blog
---

This blog post is related to my [Google Summer of Code 2024 project][my-google-summer-of-code-2024-project].

As I said in my previous blog post, I am running at a low pace due to my master's preparation as well as the army service. Josh and Greg gave me a pass even though I didn't do much. Anyway, thanks to them for their understanding. Here is my midterm feedback and the work done so far and why.

## Midterm 2024 Evaluation Feedback

![Midterm 2024 Evaluation Feedback](/assets/midterm-2024-evaluation-feedback.png)

## Work Done So Far

The generator is now finished and it has the following features:
- Input node: Foe example, if you want to use a UV.
- Output node: The implementation is finished, however, there is no intergartion with ENIGMA's Graphics System yet.
- Constants: You can use a constant value in your shader code. This includes float, int, uint, vec2, vec3, and vec4.
- Operators: Many operations are supported for float, int, uint, vec2, vec3, and vec4 types. Color operations are also supported.
- Functions: Many functions are supported such as sin, cos, tan, ... etc.
- UV with parameters: You can use UV with parameters such as scale, offset, and rotation. Polar coordinates are also supported.
- Dot product is supported.
- Others: ``Length()``, ``Clamp()``, ... etc are supported.

### Filters

- Noise: You can use noise functions such as simplex, perlin, and worley.


## TODO

- I need to support comments in the shader code.
- I need to integrate a node editor into RGM to be able to create large graphs.
- I need to work with Robert to integrate the VisualShader with ENIGMA's Graphics System.
- After all the previous TODOs are done, I am ready to design a Genetic approach to modify the parameters of the shader code (as a start only, later on, the Genetic Algorithm will be able to add/delete nodes and connections).

## Notes

The generator is implemented for creating a shader code manually, however, the integration with a Genetic Algorithm will require a lot of changes to the generator. For example, the Clamp function must be modified so that I can say for this range use this filter and for this range use this filter and so on.

The midterm work exists in PR [#2397](https://github.com/enigma-dev/enigma-dev/pull/2397).


[my-google-summer-of-code-2024-project]: https://summerofcode.withgoogle.com/programs/2024/projects/wYTZuQbA
