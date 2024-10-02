---
layout: post
title:  "Google Summer of Code 2024 Week 6: The Rush Summer"
date:   2024-07-01 00:00:00 +0300
categories: blog
---

This blog post is related to my Google Summer of Code 2024 project: [Procedural Fragment Shader Generation Using Classic Machine Learning][my-google-summer-of-code-2024-project].

## ENIGMA and Google Protobuf

ENIGMA depends on Protobuf is many things. RGM is considered to be a MVC application or Model View Controller. Every UI component of RGM is part of a proto message. This is also how ENIGMA serializes/deserializes its project files.

> Josh — 01/07/2024 at 08:14

> you can eliminate a lot of that boilerplate using proto, @Saif
> in fact, I recommend it, as you'll need proto on hand to serialize to EGM etc

> add_node is a great example
> of boilerplate, I mean; literally that is a function that protobuf would generate
> check out the other resource messages
> just search RGM for proto files

> Josh — 01/07/2024 at 09:25

> I suspect some of what I've written will still be necessary, but I suggest you try writing these node classes as protobuf messages and see where that gets you

> proto should save you a lot of effort here

> proto is just what C++ classes should look like

> well, sorry; as a storage layer, proto is certainly not what C++ classes should look like
> but in terms of the features that a proto message offers....
> there is absolutely no reason a modern programming language should not offer these features for its classes
> proto just lets you do things like serialize and deserialize, use reflection, etc

## The AI Agent Phases

When reaching the ML part, there are 3 main phases that we need to consider:

1. Fixed nodes, fixed connections, variable parameters (Fixed-Node layout).
2. Fixed nodes, variable connections, variable parameters.
3. Variable nodes, variable connections, variable parameters.

Each phase should increase the complexity of the AI agent. The first phase is the easiest one. 

> Josh — 01/07/2024 at 09:20

> the node graph editor is a good chunk of work, and then the hard part is genetic recombination of node graphs
> your first prototype should probably use a fixed node layout

> you can absolutely implement one that allows the ML to add or delete nodes, but then you need rules for handling recombination and crossover

> changing the counts and connections is simple enough, but leads to problems when cross-breeding two specimens with different graph structures

> in the end, the AI should generate the whole graph
> but it's totally okay if you don't get that far

> I am pushing for a genetic algorithm
> you have not heard the end of genetic algorithms
> they are old school but will once again revolutionize artificial intelligence in the next ten years
> in particular they will become important to avoid overfitting in DNN training

> their importance is about to skyrocket

> genetic algorithms are due for a Renaissance, is what I'm saying

## ``VisualShader`` Class

Now enough theory, let's talk about the important class I was working on during the past weeks.

The VisualShader class contains the graph and its main functionalities. As Josh said, these main functionalities should be part of the proto message, however, I like finishing it out and then refactoring. The ``Graph`` is a simple struct as follows:

{% highlight cpp %}
struct Graph {
    std::map<int, VisualShader::Node> nodes;
    std::vector<VisualShader::Connection> connections;
} graph;
{% endhighlight %}

The main functions are:

 - generate_shader
 - generate_preview_shader
 - generate_shader_for_each_node

The ``generate_shader`` function is the main function that will be called by the user. It will contains a recursively algorithm that will go through the graph starting from the output node. The ``Output`` node is the special node in the graph as it can't be added or deleted. It has the id of 0.

The ``generate_preview_shader`` is a simplified version of the ``generate_shader`` function. It will be used to generate the shader for the preview window. The preview window is expected to use ENIGMA's Graphics System to render the shader. It is necessary because it can generate the shader starting from any node in the graph.

Both functions will call the ``generate_shader_for_each_node`` function. This function will be called for each node in the graph. It will generate the shader for the node and its children.

Now let's walk through the ``generate_shader`` function. In order to generate the shader code correctly, first we have to separate the shader code into 3 parts:
 - global code
 - global code for each node
 - local code for each node

The ``global code`` must be generated once. So if we have a node that is used multiple times in the graph, we don't want to generate the code for it multiple times. The ``global code for each node`` is the code that is generated for each node in the graph. The ``local code for each node`` is the code that is generated for each node and its children.

That's why at the start of the function I created multiple buffers to store the code and send them by reference to the recursive function.

{% highlight cpp %}
std::string global_code;
std::string global_code_per_node;
std::string shader_code;
{% endhighlight %}

Another important step that I need to mention is that the connections are stored inside ``std::vector``. This will increase the time complexity of the algorithm. This can be solved by the following snippet:

{% highlight cpp %}
std::map<ConnectionKey, const Connection*> input_connections;
std::map<ConnectionKey, const Connection*> output_connections;

std::string func_code;
std::unordered_set<int> processed;

for (const Connection& c : g->connections) {
    ConnectionKey from_key;
    from_key.node = c.from_node;
    from_key.port = c.from_port;

    output_connections[from_key] = &c;

    ConnectionKey to_key;
    to_key.node = c.to_node;
    to_key.port = c.to_port;

    input_connections[to_key] = &c;
}
{% endhighlight %}

Now, we can call ``generate_shader_for_each_node`` function for the output node. The function will be called recursively for each node in the graph. First we check the inputs of the current node until we reach a node that has no inputs (the input node). Then we generate the code for the node and its children.

The ``generate_shader`` function took ``160 μs`` to generate the shader for the graph in the ``VisualShaderTest.Test_generate_shader`` test. I can improve this time however, as I said, I want to waste ZERO time here.

The ``ConnectionKey`` union is defined as follows:

{% highlight cpp %}
union ConnectionKey {
    struct FragmentedKey {
        uint64_t node : 32;
        uint64_t port : 32;
    } f_key;
    uint64_t key = 0;
    bool operator<(const ConnectionKey& key) const { return this->key < key.key; }
};
{% endhighlight %}

![Connection Key Theory](/gsoc24-blog/assets/connection-key-theory.png)

This union will be used as a key for each ``Connection`` object in ``std::map``. The key is a 64-bit integer that contains the node id in the first 32 bits and the port id in the second 32 bits. This will allow us to search for the connection in ``O(1)`` time complexity using only a node id and a port id.

## Changing The Structure Of The Project

After talking with Greg, I found out that anything inside ``ENIGMAsystem/`` must provide user functions. The EDL functions that the game developer will use. The ``VisualShader`` class is actually a class that will be used by RGM only. So, I moved the class to ``ENIGMAsystem/shared/ResourceTransformations/VisualShader/`` as Josh recommended.

The tests as well must be part of ``test-runner`` not ``emake-tests``. I will move them to ``CommandLine/testing/Tests/``.

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
│           └── visual_shader_nodes_tests.cpp
│
└── shared
    └── ResourceTransformations
        └── VisualShader
            ├── ...
            ├── visual_shader.h
            ├── visual_shader.cpp
            ├── visual_shader_nodes.h
            └── visual_shader_nodes.cpp

```

[my-google-summer-of-code-2024-project]: https://summerofcode.withgoogle.com/programs/2024/projects/wYTZuQbA
