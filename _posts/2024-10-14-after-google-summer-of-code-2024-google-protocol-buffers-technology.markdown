---
layout: post
title:  "AFTER Google Summer of Code 2024: Google Protocol Buffers Technology"
date:   2024-10-14 00:00:00 +0300
categories: blog
---

This blog post is related to my Google Summer of Code 2024 project: [Procedural Fragment Shader Generation Using Classic Machine Learning][my-google-summer-of-code-2024-project].

I have learnt so much things including the right way to write code. I can say now that I can write code better because I don't care about how good it looks. I care about how others can understand it.

You know what was the problem in my work? I didn't follow ENIGMA's way of doing things. So in order to explain this, consider the code snippet below:

{% highlight cpp %}
struct Graph {
    std::map<int, VisualShader::Node> nodes;
    std::vector<VisualShader::Connection> connections;
} graph;
{% endhighlight %}

This is where I save my nodes and my connections. This all is being saved dynamically. However, in ENIGMA, we should be able to serialize and deserialize this data in a file called "project file". Got it? RadialGM is an IDE that is able to load/save full projects. How ENIGMA do it? Well, they use Model-View-Controller (MVC) architecture. But that's not everything. They also use Google Protocol Buffers as their model. This means everything you do in your project is being sent to Protobuf and then serialize this model to YAML.

By the way, ENIGMA doesn't use Protobuf's built-in serialization/deserialization functions. However, ENIGMA has its own module for managing all that called [libEGM](https://github.com/enigma-dev/enigma-dev/tree/master/CommandLine/libEGM). This module takes a mutable message using Reflection and then serialize it to YAML. This is how ENIGMA saves its project files.

So here is what I must do:

1. I need to make an integration between the Visual Shader Editor and the model.
2. I need to change the VisualShader class to become only a Generator.

And this what Josh was trying to say to me. I have covered this in [Google Summer of Code 2024 Week 18, 19, and 20: Wrapping Up and Final Evaluation](https://k0t0z.github.io/gsoc24-blog/blog/2024/09/22/google-summer-of-code-2024-week-18-19-and-20-wrapping-up-and-final-evaluation.html#protobuf-work).

Separating my concerns means NO NEED TO STORE GUI RELATED DATA IN MY BACKEND. Anything that is related to the frontend should be stored in the protobuf model. So don't do this:

{% highlight cpp %}
std::string VisualShaderNodeFloatConstant::get_caption() const { return "FloatConstant"; }

int VisualShaderNodeFloatConstant::get_input_port_count() const { return 0; }

VisualShaderNode::PortType VisualShaderNodeFloatConstant::get_input_port_type([[maybe_unused]] const int& port) const {
  return PORT_TYPE_SCALAR;
}

std::string VisualShaderNodeFloatConstant::get_input_port_name([[maybe_unused]] const int& port) const {
  return std::string();
}

int VisualShaderNodeFloatConstant::get_output_port_count() const { return 1; }

VisualShaderNode::PortType VisualShaderNodeFloatConstant::get_output_port_type([[maybe_unused]] const int& port) const {
  return PORT_TYPE_SCALAR;
}

std::string VisualShaderNodeFloatConstant::get_output_port_name([[maybe_unused]] const int& port) const { return ""; }
{% endhighlight %}

However, do this:

{% highlight proto %}
message VisualShaderNodeFloatConstant {
    option (node_caption) = "Float Constant";
    option (node_input_port_count) = 0;
    option (node_input_port_type) = PORT_TYPE_SCALAR;
    option (node_input_port_caption) = "";
    
    option (node_output_port_count) = 1;
    option (node_output_port_type) = PORT_TYPE_SCALAR;
    option (node_output_port_caption) = "";

    optional double value = 1;
}
{% endhighlight %}

This means ports, captions, and values should be stored in the protobuf model. This is how ENIGMA does it. This is how I should do it.

This means the VisualShader class should only be a generator. It should not store any data. It should only takes a number of nodes and connections and then generate a shader code.

After working on RGM for so long, I have decided to complete this on a simpler version of RGM because RGM is really big and my CPU is crying on every build. Also, see the pic below? This issue happens too much on RGM's codebase. It is so difficult to determine the reason. Why? Well, consider the code snippet below:

{% highlight cpp %}
const google::protobuf::FieldDescriptor* field {some_descriptor->FindFieldByNumber(some_field_number)};
if (field == nullptr) {
    std::cerr << "Field not found: " << field->full_name() << std::endl;
}
{% endhighlight %}

Notice the problem? If `field` is `nullptr`, then `field->full_name()` will cause a segmentation fault. However, the issue in the pic below will show up. I have no reasonable explanation for this and this is just a simple example. RGM's codebase is considered to be legacy (in my opinion) with enough complexity that makes it difficult to determine the reason for the issue.

![Protobuf Runtime Issue](/gsoc24-blog/assets/protobuf_runtime_issue.png)

After working continuously on my mini-RGM, I can finally guess what RGM's model needs. I have created a separate model for the `oneof`s and this helps with separating the complexiness from the MessageModel class becasue according to Protobuf's syntax, `oneof`s are only allowed to be in the message scope.

Of course, RGM's model is way complex than mine. RGM's model employs many - if not all - features of QAbstractItemModel such as role and also not to mention that RGM's model is made for many editors at once (not only one such as mine heh).

Anyway, I have made it and now my model works fine starting from [b17ce5b](https://github.com/k0T0z/shader-gen/commit/b17ce5beff8165a9569b5260c9159e679e2a62d8).

[my-google-summer-of-code-2024-project]: https://summerofcode.withgoogle.com/programs/2024/projects/wYTZuQbA
