---
layout: post
title:  "Google Summer of Code 2024 Week 1, 2, 3, 4, and 5: Final Final Exams"
date:   2024-05-27 00:00:00 +0300
categories: blog
---

This blog post is related to my Google Summer of Code 2024 project: [Procedural Fragment Shader Generation Using Classic Machine Learning][my-google-summer-of-code-2024-project].

I want to note that currently, I am working with a low pace as I am very buzy with my final exams and graduation stuff.

I take my inspiration from Godot Game Engine as I want to reach the Machine Learning part of the project. on 16th of June, I noticed that Godot implements the Visual Shader using the [Red-Black Tree C Code][red-black-tree-c-code] and can be found at [Godot Visual Shader H 129-132][godot-visual-shader-h-129-132]. As Josh replied, ``std::map`` is a red black tree. I didn't know it earleir.

An interesting fact that I have learned is why Godot developers have their own implementation of the Red Black Trees. Actually, I made a converstation with one of them once about why they are not using the standard template library or STL.

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

It shouldn't be a problem for ENIGMA 🤣. Actually, unlike Godot, ENIGMA is meant to be simple to use and developed so I don't see any problem of using STL in ENIGMA. Also, I don't want to forget that in order to reach the AI part, I need to finish the whole editor as soon as possible which is a large chunk of work.

Oh by the way, I planned already to extend my project to 22 weeks. That the maximum number of weeks you can ever extend to. I want to implement the Matching Machine Learning algorithm as well.

> gfundies — 25/06/2024 21:44

> @Josh @Saif https://developers.google.com/open-source/gsoc/help/project-dates what date did you want?
> need to pick from those

Now, beside the implementation of the graph, I needed to know more about the use case of this project. How the game developers are going to use it. Then I can decide what can be done. Thanks to Josh he explained it very well.

> Josh — 29/06/2024 17:34

> converting textures to this is just a way to prime it; few people would start with a sprite and convert it to a shader. Instead, they'd obtain a photograph of something—grass, wood, rust—and use your tool to convert that photograph into a seamless (infinite) artistic representation that can be tweaked for stylistic consistency with the rest of their game
> the shaders would then be used to color objects, obviously, whether that's a skybox or background texture that doesn't end or just a way to color boxes so that no two boxes look the same
> the goal is largely to avoid repetition and predictability by taking an example and mathematically generalizing it
> clearly the predictability remains high since you've literally found a mathematical way of creating it, but artistically your eyes won't go "wow it's the same thing over and over again"

## Graph Lifecycle

I am gonna explain more about this approach just for future contributors who will take on this project and hopefully, I am mentoring them.

First of all, the game developer will load a resource into the Visual Shader Editor. The game developer will have the choice between Backgrounds and Sprites. Currently, let's keep it simple and focus of Backgrounds. The game developer can now match the loaded resource using a ``Match Image`` button that will be created.

The AI Agent take over and start generating the graph and matching the best parameters according to the resource image loaded until it converge.

At this point, the compiler will take over and writes a resource ID to the generated shader from this graph.

This is how the graph editor and the graph will be used while developing a game. The thing is that if I want to make a volcano surface for example, I will only need a volcano background image and the AI Agent will take care of all other stuff.

## Godot's Role

In order to implement an excellent approach for the Visual Shader, I decided to work in parallel on Godot's Visual Shader Editor to improve my implementations. See [#93791](https://github.com/godotengine/godot/pull/93791), [#93988](https://github.com/godotengine/godot/pull/93988), and [#93992](https://github.com/godotengine/godot/pull/93992).

## Debugging ENIGMA ``emake-tests`` inside VSCode

I always wanted to run the debug session from vscode instead of doing it manually and here are the task and launch objects:

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
