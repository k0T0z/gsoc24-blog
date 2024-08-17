---
layout: post
title:  "Google Summer of Code 2024 Week 8: GUI is a necessary overhead?"
date:   2024-07-15 00:00:00 +0300
categories: blog
---

This blog post is related to my Google Summer of Code 2024 project: [Procedural Fragment Shader Generation Using Classic Machine Learning][my-google-summer-of-code-2024-project].

I had a long talk with Josh about whether we should use a GUI or not as I think the generator is enough for start writing the Genetic Algorithm.


> Saif — 28/07/2024 21:13

> a better way? I will be able to see the output but theo problem is I won't be able to evaluate it if it is a small graph with for example 5 nodes
> 5 nodes won't be able to create a grass
> so we need more nodes like 100
> a 100 nodes using my way means very very large numer of lines

> Josh — 28/07/2024 21:14

> my guess is that grass would need more like 25, rust would need 12-18

> Saif — 28/07/2024 21:15

> still large enough
> btw i am talking about an AI that modifies only parameters as a start
> the AI won't be able to add/delete nodes

> Josh — 28/07/2024 21:15

> yeah, I think you'll max out its capability pretty quick
> and you'll either find yourself building ever more complicated graphs yourself, by hand, wanting an editor, or else letting the AI build them and wanting a way to visualize

> Saif — 28/07/2024 21:16

> yeah, maybe 25 nodes can be created manually without a GUI and then test its output

> Saif — 28/07/2024 21:17

> all roads leads to this yeah
> alright then, i will complete the GUI work myself before the AI

> Josh — 28/07/2024 21:17

> I think the only road that prolongs it enough is using graphviz instead, but even then it's not really my recommendation
> well, don't take my word for it; explore and let necessity guide you
> you'll enjoy the project a lot more that way
> like, don't do things just to have them done

> Saif — 28/07/2024 21:18

> because I am afraid to achieve nothing in the AI part due to lack of a GUI though

> Josh — 28/07/2024 21:18

> do as little as possible while still exploring this problem space

> Saif — 28/07/2024 21:19

> I don't need to see the graph itself

> Josh — 28/07/2024 21:19

> that will lead to a better product

> Saif — 28/07/2024 21:19

> i am only intersetd in the outpuut

> Josh — 28/07/2024 21:19

> eh... I think you'll be surprised, especially if you hand AI the reigns, there
> but like I said, play around
> I'm just explaining why I expect you to need a UI 
> and the tooling I recommend for creating one, of course

> Saif — 28/07/2024 21:20

> Cool, Josh, I understood, I tthink I will need to talk about that with Robert then


[my-google-summer-of-code-2024-project]: https://summerofcode.withgoogle.com/programs/2024/projects/wYTZuQbA
