---
layout: post
title:  "Google Summer of Code 2024 Week 3 & 4: Red Black Trees"
date:   2024-06-10 00:00:00 +0300
categories: blog
---

This blog post is related to my [Google Summer of Code 2024 project][my-google-summer-of-code-2024-project].

on 16th of June, I officially started looking into the project. After a quick search, I found out that Godot uses something called Red Black Trees for the visual shader graph. So let's understand and implement this data structure as a start point.

Oh boi, it is the std::map in C++! Hmmm, Godot developers have their own implementation of the Red Black Trees. I made a converstation with one of them once about why they are not using the standard template library or STD.

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
See [here](https://docs.godotengine.org/en/stable/about/faq.html#doc-faq-why-not-stl) 🙂

> AThousandShips 1:00 AM

> We use our custom String type, as the one provided by STL is too basic and lacks proper internationalization support.
> STL templates create very large symbols, which results in huge debug binaries. We use few templates with very short names instead.

> Also the STL library is infamous for standards iffyness
> With various, quite serious, inconsistencies between different implementations
> Some areas of the STL doesn't provide any guarantees or details on things like performance, or safety, it leaves it entirely up to the implementation
> Came across a case of it some time ago when discussing this very topic but forget what it was now, but it was pretty glaring
> Even trivial things like exception handling is weird in some libraries, see [here](https://github.com/godotengine/godot-cpp/issues/1326), where one implementation of the library on Arch Linux is broken with exceptions disabled

There are many things to learn btw from this conversation, however, at the moment, I think it is not a big deal to use the std::map inside ENIGMA.

[my-google-summer-of-code-2024-project]: https://summerofcode.withgoogle.com/programs/2024/projects/wYTZuQbA
