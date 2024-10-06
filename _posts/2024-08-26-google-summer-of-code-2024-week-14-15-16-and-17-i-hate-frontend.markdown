---
layout: post
title:  "Google Summer of Code 2024 Week 14, 15, 16, and 17: I Hate Frontend"
date:   2024-08-26 00:00:00 +0300
categories: blog
---

This blog post is related to my Google Summer of Code 2024 project: [Procedural Fragment Shader Generation Using Classic Machine Learning][my-google-summer-of-code-2024-project].

After experiencing many problems with the [nodeeditor](https://github.com/k0T0z/nodeeditor) package, I have decided to write my own code. I want to make everything right because it will be very annoying to fix the bugs later. This project isn't intended for a Visual Shader Editor annyway but for a Machine Learning approach to generate shaders.

## Cons Of nodeeditor Package

1. The nodeeditor library contains the backend that I have already implemented before the midterm evaluation. It is not a fully GUI Library, it is something bigger.
2. There are many bugs inside the library that I will waste a lot of time to fix.
3. I tried integrating the library with my midterm evaluation code, and it was a mess. I don't even know if it is possible to integrate them together because I stopped trying after a couple of days.
4. As mentioned in [#149](https://github.com/paceholder/nodeeditor/issues/149), the theming system is global and this won't allow creating multiple instances of the editor. The fix is inside [#172](https://github.com/paceholder/nodeeditor/pull/172), however, it is very stale.
4. ... and many other reasons.

## Pros Of Writing My Own Code

In the nodeeditor library, I think they are drawing the ports and using an algorithm to detect if the press event is done inside the port area. In my opinion, this results in a lot of complex code that is hard to maintain. I have decided to draw the ports as separate objects and make them children of the node. This will make the code simpler and easier to maintain. Using my approach, only 3 functions will take care of all thw work:

### ``on_port_pressed`` Function

This function resets the ``temporary`` connection object. A connection is called temporary when it is inside the dragging state. This means it is not connected and can be deleted or ignored at any time.

### ``on_port_dragged`` Function

This function is the one that is called continuously when the mouse is moving. The code inside it is very straightforward. It is just creates/updates the temporary connection object.

### ``on_port_dropped`` Function

This function is called when the mouse is released. It is easy to detect if the mouse is released inside a port area or not as the port is a separate object.

It took me very long to finish it by the way 🙂. I even was about to give up many times because it seemed a very big chunk of work at first.

## Event System

It is an simple as every widget inside the tree emits events till it hit the target widget upwards. The target widget will handle the event. This means, no child is allowed to access a parent directly.

## Visual Shader Editor Testing

I have added a new subdirectory to RGM called ``Tests``. I have added the basis for testing ``MainWindow`` and ``VisualShaderEditor`` classes. I have also encountered this webiste: [Difference between Mocks, Fakes, Stubs and Dummies](http://xunitpatterns.com/Mocks,%20Fakes,%20Stubs%20and%20Dummies.html), it has a nicely explained many types of testing objects. Note: SUT = System Under Test.

I tried many approachs regarding the testing but actually nothing worked. I wanted to create a dummy objects for anything related to Protobuf and the Model. By the way, Robert did a great job with RGM, it is based on the Model-View-Controller pattern. I only want to test the View and the Controller. 

The problem is that I couldn't mock the ``MessageModel`` or ``ProtoModel`` classes. Also, I want to use the real class when testing the whole system and the mocked one when testing the ``VisualShaderEditor`` alone. I tried to use MACROS from the CMake build system but nothing worked.

I came up with a work around, which is to create a new constructor for the ``VisualShaderEditor`` class that takes nothing. It worked fine.

Writing unit tests for a UI is very hard and I don't think it is worth it. It is fine for now that I wrote the ``Tests`` directory and the tests for the ``VisualShader`` class.

## No Extension Again

I actually wanted to extend my project again this year, but Robert shocked me with the news that I can't extend anymore, it was too late. I wanted to implement the Machine Learning part of the project as well as testing this thing requires a very long time because this will be an integration between many things: Qt5, Protobuf, gRPC, ``VisualShader``, ``VisualShaderEditor``, JDI, ENIGMA's Graphics System.

> R0bert — 30/08/2024 17:58

> be careful im not sure if we can extend yours again this year, so dont count on it
> i saw mentor thread talking about that

[my-google-summer-of-code-2024-project]: https://summerofcode.withgoogle.com/programs/2024/projects/wYTZuQbA
