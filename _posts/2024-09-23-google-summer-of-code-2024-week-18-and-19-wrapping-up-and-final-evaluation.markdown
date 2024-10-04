---
layout: post
title:  "Google Summer of Code 2024 Week 18 and 19: Wrapping Up and Final Evaluation"
date:   2024-09-23 00:00:00 +0300
categories: blog
---

This blog post is related to my Google Summer of Code 2024 project: [Procedural Fragment Shader Generation Using Classic Machine Learning][my-google-summer-of-code-2024-project].

My final evaluation report: [Procedural Fragment Shader Generation Using Classic Machine Learning Google Summer Of Code 2024 Final Report](https://docs.google.com/document/d/1ahKWo3m9fgqAfR9a3cqaIA08Sns05O68nhalpMNjDd8/edit?usp=sharing).

What a project! I can say that I would be happier if I had more time to work on it. I have learned a lot of things, and I have implemented a lot of things. This is another reason for me to continue working on this project after the Google Summer of Code program. I will actaully do that. What I loved about working on this project is that I faced a couple of issues that I overcame after a hackup long time. I will walk through each one now.

## The first issue: ``test-runner`` doesn't work on Arch Linux

The ``test-runner`` which will include my tests doesn't work on my main machine however, it is worked on an Ubuntu VM. That's why I moved to an Ubuntu VM for a couple of weeks. I was unsatisfied to look the other way and pretend that there are no issues so I decided to fix it. The issue first shown up before getting accepted to the Google Summer of Code program when I tried building RGM on my Ubuntu machine. I first explained it here: [Google Summer of Code 2024 Bonding Period](https://k0t0z.github.io/gsoc24-blog/blog/2024/05/15/google-summer-of-code-2024-bonding-period.html). It was first appeared with the CMake build system with RGM on an Ubuntu machine. It is also appeared in week 7: [Google Summer of Code 2024 Week 7, 8, and 9: My Boogeyperiod: Weird DSO Linking Error](https://k0t0z.github.io/gsoc24-blog/blog/2024/07/07/google-summer-of-code-2024-week-7-8-and-9-my-boogeyperiod.html#weird-dso-linking-error). I thought at first that this is because of a problem between Abseil, Protobuf, and gRPC packages. I asked my friend Fares to tell what versions he was using on his Ubuntu machine so that I use them but I found out that these versions are too old to have a CMake build system. That's why I created this solution: [absl-proto-grpc-ci](https://github.com/k0T0z/absl-proto-grpc-ci) to find the working three versions of all packages together. I graped these 3 versions and cloned, built, and installed the three packages locally to me ``/usr/local/`` but the same problem presisted.

I started working on it after the midterm evaluation when it is the time to build RGM: [Google Summer of Code 2024 Week 11, 12, and 13: RGM](https://k0t0z.github.io/gsoc24-blog/blog/2024/08/04/google-summer-of-code-2024-week-11-12-and-13-rgm.html). Remember that this same problem appeared when building RGM on both Arch and Ubuntu Linux machines. I managed to solve it the week after: [Google Summer of Code 2024 Week 11, 12, and 13: RGM](https://k0t0z.github.io/gsoc24-blog/blog/2024/08/04/google-summer-of-code-2024-week-11-12-and-13-rgm.html), it was a simple missing library to the ``LD`` variable: ``-lgpr`` and ``-labseil_dll``/``-labsl_log_internal_message -labsl_log_internal_check_op``.

## The second issue: RGM Runtime Error

For solving this issue, I took the chance to refactor the whole RGM's CMake build system. I made a lot of improvements. This issue is explained well inside: [Google Summer of Code 2024 Week 11, 12, and 13: RGM: Runtime Nightmare](https://k0t0z.github.io/gsoc24-blog/blog/2024/08/04/google-summer-of-code-2024-week-11-12-and-13-rgm.html#runtime-nightmare).

## The Renderer

I started implementing the Renderer while wrapping up as well. I wanted to implement a simple solution because I got a very small time here. Of course the best solution will be to use ENIGMA's Graphics System and this is because the generated shader will then be used by ENIGMA's Graphics System itself so it makes very sense to preview using it. If not, I will have to generate two shader codes, one for the preview and one for the final render. This is because ENIGMA's Graphics System requires a specific format for writing shaders. This is not a good solution because it will be very hard to maintain.

In my proposal, I mentioned that the Renderer will be done after the generator is done. The thing is I need a context to render the shader on, this could be [GLFW](https://www.glfw.org/) or Qt. I decided it will be Qt so moved finishing the Renderer AFTER the ``Visual Shader Editor`` is done.

Robert talked to me about that in [Google Summer of Code 2024 Week 7, 8, and 9: My Boogeyperiod](https://k0t0z.github.io/gsoc24-blog/blog/2024/07/07/google-summer-of-code-2024-week-7-8-and-9-my-boogeyperiod.html) by the way.

> R0bert — 25/08/2024 18:48

> are you saying you want to have  a "Preview" window on your shader editor?
> that might be more difficult then if you want to do a live preview of that but we can talk about it

I have implemented a standalone very simple class for preiewing my shaders and modified the ``VisualShader`` class accordingly. Why I modified the ``VisualShader`` class? because I need to generate a specific lines of code for the header for the shader to be compiled.

The Renderer is very simple. It has a ``void set_code(const std::string& code);`` function to set the shader code on each change in the graph. The shader code is set as follows:

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

## Noise Kernels

I implemented two more kernels in this period and tested them out:

- Perlin Noise
- Worley Noise

## The Documentation

The documentation is done as well in this period. It wasn't that hard because I was already adding comments to any part of the code that is complex or not clear.

## Final Project Structure

The first structure inside [enigma-dev](https://github.com/enigma-dev/enigma-dev):

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

The second structure inside [RadialGM](https://github.com/enigma-dev/RadialGM):

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

Note that some of these outputs are taken from [The Book Of Shaders](https://thebookofshaders.com/).



[my-google-summer-of-code-2024-project]: https://summerofcode.withgoogle.com/programs/2024/projects/wYTZuQbA
