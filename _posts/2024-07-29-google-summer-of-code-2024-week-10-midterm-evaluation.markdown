---
layout: post
title:  "Google Summer of Code 2024 Week 10: Midterm Evaluation"
date:   2024-07-29 00:00:00 +0300
categories: blog
---

This blog post is related to my Google Summer of Code 2024 project: [Procedural Fragment Shader Generation Using Classic Machine Learning][my-google-summer-of-code-2024-project].

As I said in my previous blog post, I am running at a low pace due to my master's preparation as well as the army service. Josh and Greg gave me a pass even though I didn't do much. Anyway, thanks to them for their understanding. Here is my midterm feedback and the work done so far and why.

## Midterm 2024 Evaluation Feedback

![Midterm 2024 Evaluation Feedback](/gsoc24-blog/assets/midterm-2024-evaluation-feedback.png)

## Summary

The midterm work exists in PR [#2397](https://github.com/enigma-dev/enigma-dev/pull/2397).

In my proposal, I said that I will make the generator ready by the midterm evaluation. It is in a good shape now. It will be refactored during the Rendering and Machine Learning phases. In these two next phases, I will make the generator more for ENIGMA's Graphics System and the Genetic Algorithm (Machine Learning) respectively. The work done in the generator can be presented as follows:

### Constants, Operators, and Functions

All constants, operators, and functions are supported. Constants include ``float``, ``int``, ``uint``, ``vec2``, ``vec3``, and ``vec4``. Operators include arithmetic, logical, and bitwise operations. Functions include trigonometric, exponential, logarithmic, and other functions. Both scalar and vector operations are supported. Both Operations and Functions types depend on the type of the operands.


Operations for ``float`` types: ``+``, ``-``, ``*``, ``/``, ``mod``, ``pow``, ``max``, ``min``, ``atan``, and ``step``.
Operations for ``int`` types: ``+``, ``-``, ``*``, ``/``, ``%``, ``max``, ``min``, ``&``, ``|``, ``^``, ``<<``, and ``>>``.
Operations for ``uint`` types: Same as ``int`` types.
Operations for ``vec2``, ``vec3``, and ``vec4`` types: ``+``, ``-``, ``*``, ``/``, ``mod``, ``pow``, ``max``, ``min``, ``cross``, ``atan2``, and ``reflect``. Note that ``cross`` is only for ``vec3`` types.

Functions for ``float`` types: ``sin``, ``cos``, ``tan``, ``asin``, ``acos``, ``atan``, ``sinh``, ``cosh``, ``tanh``, ``log``, ``exp``, ``sqrt``, ``abs``, ``sign``, ``floor``, ``round``, ``ceil``, ``fract``, ``saturate``, ``negate``, ``acosh``, ``asinh``, ``atanh``, ``degrees``, ``exp2``, ``inverse_sqrt``, ``log2``, ``radians``, ``reciprocal``, ``roundeven``, ``trunc``, and ``oneminus``.
Functions for ``int`` types: ``abs``, ``-1 *``, ``sign`` and ``~``.
Functions for ``uint`` types: ``-1 *`` and ``~``.
Functions for ``vec2``, ``vec3``, and ``vec4`` types: ``normalize``, ``saturate``, ``negate``, ``reciprocal``, ``abs``, ``acos``, ``acosh``, ``asin``, ``asinh``, ``atan``, ``atanh``, ``ceil``, ``cos``, ``cosh``, ``degrees``, ``exp``, ``exp2``, ``floor``, ``fract``, ``inverse_sqrt``, ``log``, ``log2``, ``radians``, ``round``, ``roundeven``, ``sign``, ``sin``, ``sinh``, ``sqrt``, ``tan``, ``tanh``, ``trunc``, and ``oneminus``.

### Special Nodes

Some important nodes are also implemented for the AI Agent such as:
- ``dot``: The dot product of two vectors.
- ``length``: The length of a vector.
- ``clamp``: Clamps a value between a minimum and maximum value.
- ``derivative``: The derivative of a value.
- ``step``: The step function.
- ``smoothstep``: The smoothstep function.
- ``distance``: The distance between two points.
- ``mix``: Linearly interpolates between two values.

### Logic Nodes

Some logic nodes are also implemented for the AI Agent such as: ``if``, ``switch``, ``is``, and ``compare``.

### Filters

Most importantly, the generator supports filters such as noise filters. The noise filters include ``Value`` Noise for now.

## Work To Be Done

As I explained in [Google Summer of Code 2024 Week 7, 8, and 9: My Boogeyperiod## Most Important Operations In The Generator](), many nodes will be modified during the Rendering and Machine Learning phases.

There are a couple of tasks as well that will be nice if we had. Supporting comments in the shader code is one of them as well as loops.

The integration of a node editor library into RGM is also a must task to be done. This will help in creating large graphs.

## Working Example

I have created a working example for the Value Noise filter. This is the same example that I have used in my proposal. The graph and the generated code are as follows:

![Godot Visual Shader Value Noise Filter Graph Example](/gsoc24-blog/assets/godot-visual-shader-value-noise-filter-graph-example.png)

{% highlight glsl %}
in vec2 TexCoord;
uniform float uTime;
float noise_random_value(vec2 uv) {
	return fract(sin(dot(uv, vec2(12.9898, 78.233)))*43758.5453);
}

float noise_interpolate(float a, float b, float t) {
	return (1.0-t)*a + (t*b);
}

float value_noise(vec2 uv) {
	vec2 i = floor(uv);
	vec2 f = fract(uv);
	f = f * f * (3.0 - 2.0 * f);
	
	uv = abs(fract(uv) - 0.5);
	vec2 c0 = i + vec2(0.0, 0.0);
	vec2 c1 = i + vec2(1.0, 0.0);
	vec2 c2 = i + vec2(0.0, 1.0);
	vec2 c3 = i + vec2(1.0, 1.0);
	float r0 = noise_random_value(c0);
	float r1 = noise_random_value(c1);
	float r2 = noise_random_value(c2);
	float r3 = noise_random_value(c3);
	
	float bottom_of_grid = noise_interpolate(r0, r1, f.x);
	float top_of_grid = noise_interpolate(r2, r3, f.x);
	float t = noise_interpolate(bottom_of_grid, top_of_grid, f.y);
	return t;
}

void generate_value_noise_float(vec2 uv, float scale, out float out_buffer) {
	float t = 0.0;
	
	float freq = pow(2.0, float(0));
	float amp = pow(0.5, float(3-0));
	t += value_noise(vec2(uv.x*scale/freq, uv.y*scale/freq))*amp;
	
	freq = pow(2.0, float(1));
	amp = pow(0.5, float(3-1));
	t += value_noise(vec2(uv.x*scale/freq, uv.y*scale/freq))*amp;
	
	freq = pow(2.0, float(2));
	amp = pow(0.5, float(3-2));
	t += value_noise(vec2(uv.x*scale/freq, uv.y*scale/freq))*amp;
	
	out_buffer = t;
}

out vec4 FragColor;

void main() {
// Input:1
	vec2 var_from_n1_p0 = TexCoord;

// ValueNoise:4
	// Value Noise
	float out_buffer = 0.0;
	generate_value_noise_float(var_from_n1_p0, 100.000000, out_buffer);
	vec4 var_from_n4_p0 = vec4(out_buffer, out_buffer, out_buffer, 1.0);
	
// Input:2
	float var_from_n2_p0 = uTime;

// FloatFunc:3
	float var_from_n3_p0 = sin(var_from_n2_p0);

// FloatOp:5
	float var_from_n5_p0 = var_from_n4_p0.x / var_from_n3_p0;

// Output:0
	FragColor = vec3(var_from_n5_p0);
}
{% endhighlight %}

Of course I can't show you any GUI work because I am not there yet. The above picture is from Godot Engine's Visual Shader Editor. Also, note that Godot uses a noise library that is not the same as the one I am using. As requested by Josh, I am creating my noise using shader code. No texture is included as Godot does.

> Josh — 01/09/2024 19:28

> admittedly unity's is pretty nice, except this: the FIRST TIME I can see perlin noise in that view is in the FloatOp
> this is infuriating, because by inspection, it CLEARLY comes from the Texture2D op before it
> which, hilariously, is loading perlin noise as a texture.
> literally they have taken the simplest possible noise kernel and loaded it from a PNG image instead of just generating it live at a fixed resolution
> *barf*
> so my chief technical complaint is the extreme inefficiency resulting from not providing noise kernels as a generator op
> and my chief UX complaint is that I can't even fucking tell where that noise is coming from! because they don't even preview it!
> it's just so bad.
> do they offer a noise source? i.e. did you just decide to load that perlin turbulence texture from a file? or were you forced to?
> another point of feedback on the Unity editor: float func "round" is ugly; we should use a layercake method instead
> what I mean is, we want a "step function" multiplexer node that takes an input float, and then divides that float into ranges to choose inputs to combine
> so round() would be this step function node with black and white as its texture inputs, float value as its mux input
> similarly, you could do a "heat map" by instantiating this with blue, yellow, red, and white as texture inputs, the floating value remaining as the mux input, but cutoff values of [0, .25, .5, .75, 1]
> for this idea, the interpolation range to also be configurable; for round(), you don't want interpolation, because anything up to 0.5 should be pure black, and anything above that should be pure white
> for the heatmap, you'd use interpolation for every step of the way; only the exact values in that array would return [black, blue, yellow, red, white]
> everything else would be an interpolation of the two nearest neighbors

> Saif — 02/09/2024 07:48

> Black and white = noise?

> Josh — 02/09/2024 08:53

> no; one full-black RGB channel source "image" (infinite pixels, all sampling black), and another for white; you then pipe those two images into the multiplexer
> set a single threshold point at 0.5
> otherwise it works just like the heat map


[my-google-summer-of-code-2024-project]: https://summerofcode.withgoogle.com/programs/2024/projects/wYTZuQbA
