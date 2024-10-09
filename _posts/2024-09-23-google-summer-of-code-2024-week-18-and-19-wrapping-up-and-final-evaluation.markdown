---
layout: post
title:  "Google Summer of Code 2024 Week 18 and 19: Wrapping Up and Final Evaluation"
date:   2024-09-23 00:00:00 +0300
categories: blog
---

This blog post is related to my Google Summer of Code 2024 project: [Procedural Fragment Shader Generation Using Classic Machine Learning][my-google-summer-of-code-2024-project].

My final evaluation report: [Procedural Fragment Shader Generation Using Classic Machine Learning Google Summer Of Code 2024 Final Report](https://docs.google.com/document/d/1ahKWo3m9fgqAfR9a3cqaIA08Sns05O68nhalpMNjDd8/edit?usp=sharing).

What an incredible journey this project has been with more than 15k newly added lines of code! While I wish I had more time to devote to it, I'm immensely proud of what I've accomplished and the knowledge I've gained. The challenges I encountered have only fueled my determination to continue developing this project beyond the Google Summer of Code program. Let me share some of the significant hurdles I overcame and what I learned from them.

## Major Challenges

### 1. Test Runner Compatibility Issues

One of the first obstacles I faced was that the `test-runner` wouldn't function on my Arch Linux machine, though it worked fine in an Ubuntu VM. Rather than simply working around this by using the VM, I decided to tackle the issue head-on. This problem had actually first surfaced before my acceptance into the program when attempting to build RGM on Ubuntu.

The issue manifested as a linking error involving Abseil, Protobuf, and gRPC packages. My initial approach was to:
1. Create a solution called [absl-proto-grpc-ci](https://github.com/k0T0z/absl-proto-grpc-ci) to identify compatible versions of all three packages
2. Manually clone, build, and install these versions locally to `/usr/local/`

Despite these efforts, the problem persisted until I discovered the root cause: missing library references. The solution was to add `-lgpr` and `-labseil_dll`/`-labsl_log_internal_message -labsl_log_internal_check_op` to the `LD` variable.

### 2. RGM Runtime Error Resolution

Addressing the RGM runtime error led to a complete refactoring of RGM's CMake build system. This process resulted in numerous improvements to the overall build architecture. For detailed information about this issue, I've documented it thoroughly in my blog post: [Google Summer of Code 2024 Week 11, 12, and 13: RGM: Runtime Nightmare](https://k0t0z.github.io/gsoc24-blog/blog/2024/08/04/google-summer-of-code-2024-week-11-12-and-13-rgm.html#runtime-nightmare).

## Implementation Highlights

### The Renderer

As the project wrapped up, I implemented a simplified renderer solution. While ideally, we would have used ENIGMA's Graphics System, time constraints led to a different approach. The current implementation uses Qt and includes:
- A standalone class for shader preview
- Modifications to the `VisualShader` class to generate appropriate header code

In my proposal, I mentioned that the Renderer will be done after the generator is done. The thing is I need a context to render the shader on, this could be [GLFW](https://www.glfw.org/) or Qt. I decided it will be Qt so moved finishing the Renderer AFTER the ``Visual Shader Editor`` is done.

Robert talked to me about that in [Google Summer of Code 2024 Week 7, 8, and 9: My Boogeyperiod](https://k0t0z.github.io/gsoc24-blog/blog/2024/07/07/google-summer-of-code-2024-week-7-8-and-9-my-boogeyperiod.html) by the way.

> R0bert — 25/08/2024 18:48

> are you saying you want to have  a "Preview" window on your shader editor?
> that might be more difficult then if you want to do a live preview of that but we can talk about it

Here's a glimpse of how the shader code is set:

{% highlight cpp %}
shader_program.reset(new QOpenGLShaderProgram());

const char* vertex_shader_source = R"(
    #version 330 core
    layout(location = 0) in vec2 aPos;
    layout(location = 1) in vec2 aTexCoord;

    out vec2 TexCoord;

    void main() {
    gl_Position = vec4(aPos, 0.0, 1.0);
    TexCoord = aTexCoord;
    }
)";

std::string fragment_shader_source {code.empty() ? R"(
    #version 330 core
    out vec4 FragColor;
    in vec2 TexCoord;

    uniform float uTime;

    void main() {
    FragColor = vec4(0.0, 0.0, 0.0, 1.0);
    }
)" : "#version 330 core\n\n" + code};

if (!shader_program->addShaderFromSourceCode(QOpenGLShader::Vertex, vertex_shader_source)) {
    qWarning() << "Vertex shader compilation failed:" << shader_program->log();
}

if (!shader_program->addShaderFromSourceCode(QOpenGLShader::Fragment, fragment_shader_source.c_str())) {
    qWarning() << "Fragment shader compilation failed:" << shader_program->log();
}

if (!shader_program->link()) {
    qWarning() << "Shader program linking failed:" << shader_program->log();
}

shader_needs_update = false;
{% endhighlight %}

See the ``#version 330 core`` line in the header, this line is not required by ENIGMA's Graphics System. This means when it comes to integrate the Renderer with ENIGMA's Graphics System, some modifications will be made for sure.

if you wanna try the Renderer, you can download this Qt project: [testshaderrenderer.zip](/gsoc24-blog/assets/testshaderrenderer.zip).

## Protobuf Work

Josh told me to start with this task a while ago [Google Summer of Code 2024 Week 6: The Rush Summer: ENIGMA and Google Protobuf](https://k0t0z.github.io/gsoc24-blog/blog/2024/06/30/google-summer-of-code-2024-week-6-the-rush-summer.html#enigma-and-google-protobuf) and I decided to move on and make that change when the editor is done. Now, actually I don't know how much time it will take to finish this task 🙂. That introduces a very important lesson: DO NOT IGNORE ANY THING THAT JOSH SAYS haha 🤣.

Anyway, I remember talking with Josh and Robert about this task and to handle it.

> Josh — 31/08/2024 08:10

> I think the trouble we're running into here is that we lack a clear separation of concerns—for a (somewhat outdated) example, model-view-controller
> these classes I'm seeing are great for adapting myriad node types to a common UI; as an example, he seems to implement stuff like get_caption so that each node type can just tell the UI what to render for the node
> that's fine; what we want to do is take the stuff inside of those configurable objects and extract those to protos
> so we need logic to take a node message and generate the correct node subclass; that's easy to come up with once the storage format on disk for that info is chosen
> basically, all the variables that each box needs to configure with input boxes and sliders and whatever need to be fields in a message; that FloatOpGraphNode message looks more or less fine, modulo some missing tag numbers and optionals

> from there, I would store the appropriate message in each GraphNode; personally, I'd probably use a template to accomplish this:
{% highlight cpp %}
template<typename Proto> class GraphNode {
 public:
  std::string get_caption() const {
    // use Qt translation routines to get the human-readable caption for our message type.
    // A map would be fine for this, too. Or a custom attribute declared in the proto source.
    return _T(Proto::descriptor()->name() + "-caption");
  }
};
{% endhighlight %}

> a custom attribute would look like this:
{% highlight cpp %}
package whatever_proto_package;
extend google.protobuf.MessageOptions {
  string editor_caption = 50001;  // Define a custom option with a unique field number
}
message FloatOpGraphNode {
  option (editor_caption) = "Floating Point Operation";
}
{% endhighlight %}

> then the C++ would do this:
{% highlight cpp %}
std::string get_caption() const {
  // Still translate it because we translate all Qt user strings
  return _T(Proto::descriptor()->options().GetExtension(whatever_proto_package::editor_caption));
}
{% endhighlight %}

> I omitted a lot of checking for, e.g, the descriptor being null or the option missing or whatever
> I'd also advise putting our message extensions in a single proto source for the entire project
> like, anywhere we're already extending MessageOptions, we should define any editor_caption field there
> if we're already doing that, I apologize for the confusion 
> and so we're clear, use whatever of that is helpful to you; I don't care how you pull that off, protobuf is meant to be a tool to make your life easier
> it can just be serialized and written directly to disk or read directly from disk, so I'd expect your UI code to read the entire graph from one binproto/textproto dump, then generate the UI graph nodes from message pointers as we do with our other Qt models
> those Qt models are probably a good reference if they don't confuse you to tears
> if they do, ask me

> yeah, and storing that data is where the template comes in, though honestly, you can avoid the entirely using proto reflection if you prefer

> R0bert — 31/08/2024 19:34

> Josh explained, "separate your concerns", have a GraphNode message that's templated to take the rest of the parameters for the node
> the only reason the source you linked has 50 classes is because its make a type for each one instead of separating the node from the ui

Yeah, so now this is the biggest problem in my project now. The thing is that ENIGMA is mainly depends on Protobuf for serialization, deserialization, and many other purposes.

### Noise Kernels

I successfully implemented two additional noise kernels:
- Perlin Noise
- Worley Noise

## Project Structure

The final implementation is integrated into two main repositories:

1. [enigma-dev](https://github.com/enigma-dev/enigma-dev)
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
    │           ├── visual_shader_nodes_tests.cpp
    │           └── vs_noise_nodes_tests.cpp  
    |
    └── shared
        ├── ...
        └── ResourceTransformations
            └── VisualShader
                ├── README.md
                ├── visual_shader.h
                ├── visual_shader.cpp
                ├── visual_shader_nodes.h
                ├── visual_shader_nodes.cpp
                ├── vs_noise_nodes.h
                └── vs_noise_nodes.cpp
```

2. [RadialGM](https://github.com/enigma-dev/RadialGM)
```
    RadialGM
    ├── ...
    ├── Editors
    │   ├── ...
    │   ├── VisualShaderEditor.h
    │   └── VisualShaderEditor.cpp
    |
    └── Tests
        ├── CMakeLists.txt
        ├── tests_main.cpp
        ├── MainWindowTests.h
        ├── MainWindowTests.cpp
        └── Editors
            ├── VisualShaderEditorTests.h
            └── VisualShaderEditorTests.cpp
```

## Outputs With Graphs

I've recreated several textures from [The Book of Shaders](https://thebookofshaders.com/), including:

A simple Wood texture from The Book Of Shaders:

![Wood Texture](/gsoc24-blog/assets/wood-texture.png)

My project's output:

![ENIGMA Visual Shader Wood Texture](/gsoc24-blog/assets/ENIGMA-visual-shader-wood-texture.png)
![ENIGMA Visual Shader Wood Texture](/gsoc24-blog/assets/ENIGMA-visual-shader-wood-texture2.png)

Check out the texture demo at [https://youtu.be/9F7YYRG7MkM?si=mdgc4BBncT7IXNKa](https://youtu.be/9F7YYRG7MkM?si=mdgc4BBncT7IXNKa).

---

A simple Splatter texture from The Book Of Shaders:

![Splatter Texture](/gsoc24-blog/assets/splatter-texture.png)

My project's output:

![ENIGMA Visual Shader Splatter Texture](/gsoc24-blog/assets/ENIGMA-visual-shader-splatter-texture.png)
![ENIGMA Visual Shader Splatter Texture](/gsoc24-blog/assets/ENIGMA-visual-shader-splatter-texture2.png)

Check out the texture demo at [https://youtu.be/AgsveEXKu8Y?si=G_VDLM0u-G-0w-wJ](https://youtu.be/AgsveEXKu8Y?si=G_VDLM0u-G-0w-wJ).

The Splatter texture implementation led to several important fixes in the noise kernels, documented in these commits:
 - [4c716895d46130ec2cf7bbd8fd95806124563977](https://github.com/enigma-dev/enigma-dev/pull/2399/commits/4c716895d46130ec2cf7bbd8fd95806124563977)
 - [55a050609592a0b2b1cfac8a526c84c133ed6c7d](https://github.com/enigma-dev/enigma-dev/pull/2399/commits/55a050609592a0b2b1cfac8a526c84c133ed6c7d)
 - [7a8aa69d1445c6f77895b2f6d2784104c717fbc1](https://github.com/enigma-dev/enigma-dev/pull/2399/commits/7a8aa69d1445c6f77895b2f6d2784104c717fbc1)

---

[my-google-summer-of-code-2024-project]: https://summerofcode.withgoogle.com/programs/2024/projects/wYTZuQbA
