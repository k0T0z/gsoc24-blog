---
layout: post
title:  "Google Summer of Code 2024 Week 5: Here we go!"
date:   2024-06-24 00:00:00 +0300
categories: blog
---

This blog post is related to my [Google Summer of Code 2024 project][my-google-summer-of-code-2024-project].

Now my mentor Greg increased my project period to 18 weeks, so I can have more time before the midterms. So my new midterm deadline is Aug 02, 2024 which gives me enough time to implement a proper solution for the project.

I will use a GTest unit test for testing my code and I will keep this https://google.github.io/googletest/advanced.html#running-a-subset-of-the-tests as a reference because I always forget about it.

Now for the first important question: What are my inputs and outputs?

## Inputs and Outputs

In my unit test, I will create a bunch of Nodes and Connections to build a graph and then I will have a function that converts this graph to a shader code and another function that will serialize this graph to JSON. The problem is I know nothing about how I am gonna run this shader code for preview or how I am gonna apply it to a resource. That said, it is not a big deal now. What I need to do now is to finish all these implementations as I am off schedule and I need to catch up. I think I see how Godot devs did it first then implmenet my own.

## Godot Visual Shader

I will need to debug the project I linked in my proposal using this:
    
    ```bash
    ./bin/godot.linuxbsd.editor.x86_64 -e --path ~/Desktop/godot_visual_shader_editor_showcase
    ```

It is very easy to compile Godot as it doesn't have any dependencies.

## The plan

I figured out my next steps now after talking to Josh, I will start by creating my graph and the generator. I will try to make it work for the simple example I used in my proposal and then extend it over time. I decided also to work in parallel on Godot's Visual Shader Editor to improve my implementations. This PR is the one [#93791](https://github.com/godotengine/godot/pull/93791).

## Debugging ENIGMA emake-tests inside VSCode

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
