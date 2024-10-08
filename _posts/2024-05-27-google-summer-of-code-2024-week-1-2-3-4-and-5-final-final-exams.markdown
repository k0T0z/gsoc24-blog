---
layout: post
title:  "Google Summer of Code 2024 Week 1, 2, 3, 4, and 5: Final Final Exams"
date:   2024-05-27 00:00:00 +0300
categories: blog
---

This blog post is related to my Google Summer of Code 2024 project: [Procedural Fragment Shader Generation Using Classic Machine Learning][my-google-summer-of-code-2024-project].

I should note that I am currently working at a slower pace due to being occupied with my final exams and graduation preparations.

I draw inspiration from the Godot Game Engine, particularly as I aim to reach the machine learning phase of the project. On June 16th, I discovered that Godot implements its Visual Shader system using a [Red-Black Tree in C][red-black-tree-c-code], which can be found in the [Godot Visual Shader code (lines 129-132)][godot-visual-shader-h-129-132]. As Josh pointed out, `std::map` in C++ is also based on a red-black tree, which I hadn’t realized before.

One interesting insight I've gained is why Godot developers created their own implementation of red-black trees. I once had a conversation with one of them about their decision not to rely on the Standard Template Library (STL).

> December 29, 2023
 
> k0T0z 12:55 AM

> guys, i have a question in mind, i know that godot doesn't require any installation setup and wondered what the installation setup gives? I mean why just not every program out there use the same approach there must be something

> Calinou 1:50 AM

> installers allow for better system integration like desktop icons, start menu entries, entries in Add/Remove Programs
> that's why there is still some demand for them. It is possible to do this stuff manually or with external tools like Scoop, but some people (companies in particular) value a built-in solution for large-scale deployments
>
> it is possible to create installers that work without administrator privileges if the app is installed for a single user only

> AThousandShips 12:56 AM

> Godot is self contained in a single file, many programs aren't, that's generally why they require installers, and have libraries they depend on etc.

> k0T0z 12:57 AM

> wait a minute, Godot doesn't depend on any library?

> AThousandShips 12:58 AM

> Not any other than system ones, it contains all the third party things

> k0T0z 12:58 AM

> also what do u mean by self-contained in a single file?

> AThousandShips 12:58 AM

> It is a single file? It doesn't have a lot of extra files like many programs have, it embeds all the data of it in the executable

> k0T0z 12:59 AM

> hmmm, interesting, I guess <std::string> is from system as well, why not use it?

> AThousandShips 12:59 AM

> Look at any one software on your computer, in for example Program Files on Windows
> See [here](https://docs.godotengine.org/en/stable/about/faq.html#doc-faq-why-not-stl) 🙂

> AThousandShips 1:00 AM

> We use our custom String type, as the one provided by STL is too basic and lacks proper internationalization support.
> STL templates create very large symbols, which results in huge debug binaries. We use few templates with very short names instead.

> Also the STL library is infamous for standards iffyness
> With various, quite serious, inconsistencies between different implementations
> Some areas of the STL doesn't provide any guarantees or details on things like performance, or safety, it leaves it entirely up to the implementation
> Came across a case of it some time ago when discussing this very topic but forget what it was now, but it was pretty glaring
> Even trivial things like exception handling is weird in some libraries, see [here](https://github.com/godotengine/godot-cpp/issues/1326), where one implementation of the library on Arch Linux is broken with exceptions disabled

This shouldn’t pose a problem for ENIGMA! 🤣 Unlike Godot, ENIGMA is designed to be simple to use and develop, so I don't foresee any issues with incorporating the Standard Template Library (STL). However, I must remember that to progress to the AI component, I need to complete the entire editor as quickly as possible, which is a significant undertaking.

By the way, I have already planned to extend my project to a maximum of 22 weeks, which is the longest extension allowed. I also aim to implement the Matching Machine Learning algorithm during this time.

> gfundies — 25/06/2024 21:44

> @Josh @Saif https://developers.google.com/open-source/gsoc/help/project-dates what date did you want?
> need to pick from those

In addition to implementing the graph, I needed to gain a better understanding of the project's use case—specifically, how game developers will utilize it. This knowledge will help me determine the next steps in the project. Fortunately, Josh provided a clear explanation that greatly assisted my understanding.

> Josh — 29/06/2024 17:34

> converting textures to this is just a way to prime it; few people would start with a sprite and convert it to a shader. Instead, they'd obtain a photograph of something—grass, wood, rust—and use your tool to convert that photograph into a seamless (infinite) artistic representation that can be tweaked for stylistic consistency with the rest of their game
> the shaders would then be used to color objects, obviously, whether that's a skybox or background texture that doesn't end or just a way to color boxes so that no two boxes look the same
> the goal is largely to avoid repetition and predictability by taking an example and mathematically generalizing it
> clearly the predictability remains high since you've literally found a mathematical way of creating it, but artistically your eyes won't go "wow it's the same thing over and over again"

## Graph Lifecycle

I’d like to elaborate on this approach for the benefit of future contributors who may take on this project—hopefully, I will have the opportunity to mentor them.

First, the game developer will load a resource into the Visual Shader Editor, choosing between backgrounds and sprites. For now, let’s keep it simple and focus on backgrounds. Once the resource is loaded, the game developer can click a "Match Image" button that will be created.

At this point, the AI agent takes over, generating the graph and optimizing the parameters based on the loaded resource image until it converges.

After the AI agent completes its work, the compiler will write a resource ID to the generated shader based on this graph.

This is how the graph editor and the graph will be utilized during game development. For instance, if I want to create a volcano surface, I simply need to provide a volcano background image, and the AI agent will handle the rest.

## Godot's Role

To develop an effective approach for the Visual Shader, I decided to work in parallel with Godot's Visual Shader Editor to enhance my implementations. You can refer to the following pull requests for more details: [#93791](https://github.com/godotengine/godot/pull/93791), [#93988](https://github.com/godotengine/godot/pull/93988), and [#93992](https://github.com/godotengine/godot/pull/93992).

## Debugging ENIGMA ``emake-tests`` inside VSCode

I have always wanted to run the debug session directly from Visual Studio Code instead of doing it manually. Below are the task and launch configuration objects I created for this purpose:

{% highlight json %}
// task object:
{
    "label": "build emake-tests",
    "group": "build",
    "type": "shell",
    "command": "make emake-tests", // ENIGMA uses make (not CMake) at the time of writing this.
}
{% endhighlight %}

{% highlight json %}
// launch configuration object:
{
    "name": "Launch emake-tests",
    "type": "cppdbg",
    "request": "launch",
    "program": "${workspaceFolder}/emake-tests",
    "args": [ "--gtest_filter=" ], // TODO: Add your filter here.
    "stopAtEntry": false,
    "cwd": "${workspaceFolder}",
    "environment": [],
    "externalConsole": false,
    "setupCommands":
    [
        {
            "description": "Enable pretty-printing for gdb",
            "text": "-enable-pretty-printing",
            "ignoreFailures": true
        }
    ],
    "preLaunchTask": "build emake-tests"
}
{% endhighlight %}

[my-google-summer-of-code-2024-project]: https://summerofcode.withgoogle.com/programs/2024/projects/wYTZuQbA
[gtest-running-a-subset-of-the-tests]: https://google.github.io/googletest/advanced.html#running-a-subset-of-the-tests
[red-black-tree-c-code]: https://web.archive.org/web/20120507164830/https://web.mit.edu/~emin/www/source_code/red_black_tree/index.html
[godot-visual-shader-h-129-132]: https://github.com/godotengine/godot/blob/705b7a0b0bd535c95e4e8fb439f3d84b3fb4f427/scene/resources/visual_shader.h#L129-L132
