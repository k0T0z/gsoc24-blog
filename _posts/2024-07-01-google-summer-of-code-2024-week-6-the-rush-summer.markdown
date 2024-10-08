---
layout: post
title:  "Google Summer of Code 2024 Week 6: The Rush Summer"
date:   2024-07-01 00:00:00 +0300
categories: blog
---

This blog post is related to my Google Summer of Code 2024 project: [Procedural Fragment Shader Generation Using Classic Machine Learning][my-google-summer-of-code-2024-project].

## ENIGMA and Google Protobuf

ENIGMA relies on Protobuf for various functionalities. RGM is structured as a Model-View-Controller (MVC) application, where each UI component of RGM is represented as part of a Protobuf message. This approach is also how ENIGMA handles the serialization and deserialization of its project files.

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

When we reach the machine learning component, there are three main phases to consider:

1. **Fixed nodes, fixed connections, variable parameters** (Fixed-Node layout).
2. **Fixed nodes, variable connections, variable parameters**.
3. **Variable nodes, variable connections, variable parameters**.

Each phase progressively increases the complexity of the AI agent, with the first phase being the simplest.

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

Now that we’ve covered the theory, let’s discuss the important class I have been working on over the past few weeks.

The **VisualShader** class encompasses the graph and its core functionalities. As Josh mentioned, these primary functionalities should ideally be included in the Protobuf message; however, I prefer to complete the implementation first and then refactor as needed. The **Graph** is structured simply, as follows:

{% highlight cpp %}
struct Graph {
    std::map<int, VisualShader::Node> nodes;
    std::vector<VisualShader::Connection> connections;
} graph;
{% endhighlight %}

The main functions within the **VisualShader** class are as follows:

- **generate_shader**
- **generate_preview_shader**
- **generate_shader_for_each_node**

The **generate_shader** function serves as the primary entry point for users. It contains a recursive algorithm that traverses the graph, starting from the output node. The **Output** node is a special node in the graph; it cannot be added or deleted and has an ID of 0.

The **generate_preview_shader** function is a simplified version of **generate_shader**. It is designed to generate the shader for the preview window, which will utilize ENIGMA's Graphics System for rendering. This function is essential because it can generate the shader starting from any node in the graph.

Both **generate_shader** and **generate_preview_shader** will call the **generate_shader_for_each_node** function. This function is invoked for each node in the graph, generating the shader for that node and its children.

Now, let’s delve into the **generate_shader** function. To generate the shader code accurately, we first need to separate the code into three distinct parts:

- **Global code**
- **Global code for each node**
- **Local code for each node**

The **global code** must be generated only once. Therefore, if a node is used multiple times in the graph, we want to avoid generating the code for it repeatedly. The **global code for each node** pertains to the code generated for each node in the graph, while the **local code for each node** is specific to each node and its children.

To facilitate this, I created multiple buffers at the start of the function to store the code and pass them by reference to the recursive function.

{% highlight cpp %}
std::string global_code;
std::string global_code_per_node;
std::string shader_code;
{% endhighlight %}

Another important aspect to mention is that the connections are stored within a `std::vector`. While this approach provides flexibility, it can increase the time complexity of the algorithm. However, this issue can be addressed using the following snippet:

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

Now, we can call the **generate_shader_for_each_node** function for the output node. This function will be executed recursively for each node in the graph. We begin by checking the inputs of the current node until we reach a node that has no inputs (the input node). Once we identify such a node, we proceed to generate the code for that node and its children.

In the **VisualShaderTest.Test_generate_shader** test, the **generate_shader** function took **160 μs** to generate the shader for the graph. While I believe there is room for improvement in this time, my priority is to ensure that no time is wasted during this process.

The **ConnectionKey** union is defined as follows:

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

This union will serve as the key for each **Connection** object in a `std::map`. The key is a 64-bit integer, with the first 32 bits representing the node ID and the second 32 bits representing the port ID. This structure allows us to efficiently search for connections in constant time, **O(1)**, using just the node ID and port ID.

## Changing The Structure Of The Project

After discussing with Greg, I learned that anything within the `ENIGMAsystem/` directory must provide user-facing functions, specifically the EDL functions that game developers will use. Since the **VisualShader** class is intended for use by RGM only, I followed Josh's recommendation and moved the class to `ENIGMAsystem/shared/ResourceTransformations/VisualShader/`.

Additionally, the tests for this class should be part of the `test-runner` instead of `emake-tests`, so I will relocate them to `CommandLine/testing/Tests/`.

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
