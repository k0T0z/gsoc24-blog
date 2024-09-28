---
layout: post
title:  "Google Summer of Code 2024 Week 14 & 15 & 16 & 17: No Extension Allowed"
date:   2024-08-26 00:00:00 +0300
categories: blog
---

This blog post is related to my Google Summer of Code 2024 project: [Procedural Fragment Shader Generation Using Classic Machine Learning][my-google-summer-of-code-2024-project].

This week my mentors told me that I am not allowed to extend the deadline anymore, Ouch!!

I was planning to add the extension to be able to dig into the Genetic Algorithm part. I may still be able to do that, but I need to hurry up.

## A decision to make

I have decided to cancel depending on the nodeeditor library and implement the system from scratch for a couple of reasons:

1. The nodeeditor library contains the backend that I have already implemented before the midterm evaluation. It is not a fully GUI Library, it is something bigger.
2. There are many bugs inside the library that I will waste a lot of time to fix.
3. I tried integrating the library with my midterm evaluation code, and it was a mess. I don't even know if it is possible to integrate them together because I stopped trying after a couple of days.
4. ... and many other reasons.

I made a simpler version of the nodeeditor library that will serve my needs, which is the genetic algorithm part. Let's walk through the differences and the improvements that I needed to make.

### Drawing the nodes and the connections.

In drawing the node, I only needed to draw the name, the embed, the input ports, and the output ports. The input and output ports are graphics objects that are children of the node. This is an improvement I made because most of the time you will be interacting with the ports, not the node itself. The nodeeditor library draws the node and the ports in the same graphics object, which makes it hard to interact with the ports. They wrote a lot of code to make the ports interactable.

Because of this improvement, I was able to include my logic in three main fucntions:

1. void on_port_pressed(QGraphicsObject* port, const QPointF& coordinate);
2. void on_port_dragged(QGraphicsObject* port, const QPointF& coordinate);
3. void on_port_dropped(QGraphicsObject* port, const QPointF& coordinate);

## [Difference between Mocks, Fakes, Stubs and Dummies](http://xunitpatterns.com/Mocks,%20Fakes,%20Stubs%20and%20Dummies.html)

Pattern	--> Purpose	

Dummy Object --> Attribute or Method Parameter
Test Stub --> Verify indirect inputs of SUT
Mock Object	--> Verify indirect outputs of SUT
Fake Object	--> Run (unrunnable) tests (faster)

Note: SUT = System Under Test

[my-google-summer-of-code-2024-project]: https://summerofcode.withgoogle.com/programs/2024/projects/wYTZuQbA
