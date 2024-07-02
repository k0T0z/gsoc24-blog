---
layout: post
title:  "Google Summer of Code 2024 Week 6: The Rush Summer"
date:   2024-07-01 00:00:00 +0300
categories: blog
---

This blog post is related to my [Google Summer of Code 2024 project][my-google-summer-of-code-2024-project].

This week I had clearer view of what I need to do, thanks to Josh of course.

> Josh — 01/07/2024 at 08:14

> you can eliminate a lot of that boilerplate using proto, @Saif
> in fact, I recommend it, as you'll need proto on hand to serialize to EGM etc

> Saif — 01/07/2024 at 08:26

> @Josh what boilerplate code? I have written only the model class:
> graph, add_node, …etc
> also, how proto can be beneficial? If u can send some article to read or something, i would really appreciate it
> Lastly, is it better to complete the generator this way (Testing a GTest unit test) or use another approach?

> Josh — 01/07/2024 at 08:55

> add_node is a great example
> of boilerplate, I mean; literally that is a function that protobuf would generate
> check out the other resource messages
> just search RGM for proto files

> Saif — 01/07/2024 at 09:06

> interesting, so because the add_node is a button in RGM, protobuf is used instead

> Saif — 01/07/2024 at 09:13

> u said you want the generation to be transparent
> then why we would need the nodeeditor for example?

> Josh — 01/07/2024 at 09:15

> the generation of the shader script from the nodes, not the generation of the nodes
> the nodes are the main representation of these shaders now, is all I was saying
> these particular shaders
> we don't want to store generated code alongside them
> it's the parameters of the nodes we're tuning with AI

> Saif — 01/07/2024 at 09:17

> okay it becomes clearer now, so why u said here it’s an extra effort?
> oh u mean the generated shader itself, kinda make sense now
> okay so my plan was to implement that editor and finish it (not planing to implement all features of shaders inside) and the start writing the shader generation algorithm from that specific graph

> Josh — 01/07/2024 at 09:20

> yeah, generating the shader from the nodes should be extremely easy

> Saif — 01/07/2024 at 09:20

> which means the graph itself won’t be generated, however it will be written by the user

> Josh — 01/07/2024 at 09:20

> the node graph editor is a good chunk of work, and then the hard part is genetic recombination of node graphs
> your first prototype should probably use a fixed node layout

> Saif — 01/07/2024 at 09:21

> yeah that’s right however finding the best parameters is the tricky part

> Josh — 01/07/2024 at 09:21

> i.e. users select the nodes and their types, then the ML selects the parameters

> Saif — 01/07/2024 at 09:21

> fixed node layout?

> Saif — 01/07/2024 at 09:22

> got it

> Josh — 01/07/2024 at 09:23

> you can absolutely implement one that allows the ML to add or delete nodes, but then you need rules for handling recombination and crossover

> Saif — 01/07/2024 at 09:23

> okay so that was my plan and I was implementing the backend code until you said that the protobuf is a shortcut

> Saif — 01/07/2024 at 09:23

> interesting, let’s keep it simple for now and i can this it looks interesting

> Josh — 01/07/2024 at 09:24

> yes—like I said, prototype can and probably should use a fixed graph layout

> Saif — 01/07/2024 at 09:25

> there will be another files inside RGM itself to handle the add_node code so why you me to remove the code inside ENIGMA?

> Saif — 01/07/2024 at 09:25

> a fixed graph is for the parameters only right? or you mean a whole fixed graph with also nodes already specified?

> Josh — 01/07/2024 at 09:25

> I suspect some of what I've written will still be necessary, but I suggest you try writing these node classes as protobuf messages and see where that gets you

> Saif — 01/07/2024 at 09:26

> as we always do, alright got it

> Josh — 01/07/2024 at 09:26

> not sure I understand, but I do mean a graph where all the nodes are specified, and the ML only changes the values, not the node counts or connections
> changing the counts and connections is simple enough, but leads to problems when cross-breeding two specimens with different graph structures

> Saif — 01/07/2024 at 09:28

> okay just a second, i can let the user choose the graph nodes without any parameter tuning, so for example a “color” node or a “add” node, and the values of the color or the addition operation will be determined by the AI

> Josh — 01/07/2024 at 09:28

> correct

> Saif — 01/07/2024 at 09:29

> okay so the AI will also change connections, this is new

> Josh — 01/07/2024 at 09:29

> in the end, the AI should generate the whole graph
> but it's totally okay if you don't get that far

> Saif — 01/07/2024 at 09:29

> cross-breeding is a well known problem? I am not I know what that is

> Josh — 01/07/2024 at 09:29

> I am pushing for a genetic algorithm
> you have not heard the end of genetic algorithms
> they are old school but will once again revolutionize artificial intelligence in the next ten years
> in particular they will become important to avoid overfitting in DNN training

> Saif — 01/07/2024 at 09:31

> okay got it so actually we can say:
> fixed nodes, fixed parameters, fixed connections
> variable nodes, fixed parameters, fixed connections
> …etc
> 
> until
> variable nodes, variable parameters, variable connections

> Josh — 01/07/2024 at 09:32

> yeah, though the parameters will probably be the first thing your ML tweaks, not nodes
> you have not heard the end of genetic algorithms

> Saif — 01/07/2024 at 09:32

> I have learned it in my AI course and also learned about it to write the proposal but didn’t dig this deeper though

> Josh — 01/07/2024 at 09:32

> their importance is about to skyrocket

> Saif — 01/07/2024 at 09:32

> yeah, it looks easier that way
> and the importance of course

> Josh — 01/07/2024 at 09:33

> genetic algorithms are due for a Renaissance, is what I'm saying

> Saif — 01/07/2024 at 09:33

> so I will continue as I was working trying to finish the generator but this time I will in parallel with protobuf

> Josh — 01/07/2024 at 09:33

> sounds good
> proto should save you a lot of effort here

> Saif — 01/07/2024 at 09:34

> Sounds perfect

> Saif — 01/07/2024 at 09:34

> hmmm, the effort or the must of doing it?

> Josh — 01/07/2024 at 09:35

> both?

> Saif — 01/07/2024 at 09:35

> I mean when to use protobuf and when not to use it, it depends maybe on what is protobuf
> i will see what i can do

> Josh — 01/07/2024 at 09:35

> proto is just what C++ classes should look like

> Saif — 01/07/2024 at 09:35

> hmmm, truly i have no idea

> Josh — 01/07/2024 at 09:35

> well, sorry; as a storage layer, proto is certainly not what C++ classes should look like
> but in terms of the features that a proto message offers....
> there is absolutely no reason a modern programming language should not offer these features for its classes
> proto just lets you do things like serialize and deserialize, use reflection, etc



[my-google-summer-of-code-2024-project]: https://summerofcode.withgoogle.com/programs/2024/projects/wYTZuQbA
