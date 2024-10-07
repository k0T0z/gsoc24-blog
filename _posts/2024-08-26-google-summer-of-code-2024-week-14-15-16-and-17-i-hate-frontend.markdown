---
layout: post
title:  "Google Summer of Code 2024 Week 14, 15, 16, and 17: I Hate Frontend"
date:   2024-08-26 00:00:00 +0300
categories: blog
---

This blog post is related to my Google Summer of Code 2024 project: [Procedural Fragment Shader Generation Using Classic Machine Learning][my-google-summer-of-code-2024-project].

After encountering numerous challenges with the [nodeeditor](https://github.com/k0T0z/nodeeditor) package, I made the strategic decision to develop a custom implementation. This decision was driven by the need for precision and maintainability, especially considering that this project's ultimate goal extends beyond a Visual Shader Editor to a machine learning approach for shader generation.

## Analysis of Third-Party Solution

### Limitations of nodeeditor Package
1. **Scope Mismatch**: The library encompasses backend functionality that I had already implemented prior to the midterm evaluation. It exceeds the requirements of a GUI library, introducing unnecessary complexity.
2. **Bug Density**: The package contains numerous bugs that would require significant time investment to resolve.
3. **Integration Challenges**: Attempts to integrate the library with my midterm evaluation code proved problematic, potentially rendering integration unfeasible.
4. **Architectural Constraints**: As documented in [Issue #149](https://github.com/paceholder/nodeeditor/issues/149), the global theming system prevents the creation of multiple editor instances. While a fix exists in [PR #172](https://github.com/paceholder/nodeeditor/pull/172), it remains unmerged.

## Custom Implementation Benefits

### Simplified Port Management
The nodeeditor library appears to use a complex algorithm for port detection and event handling. My approach simplifies this by treating ports as discrete objects:

1. **Port Objects as Children**: By making ports children of nodes, we achieve clearer object hierarchy and simpler event propagation.
2. **Event Handler Reduction**: This approach requires only three key functions:

   #### `on_port_pressed`
   Initializes or resets the "temporary" connection object. A temporary connection exists in a dragging state, remaining uncommitted until finalized.

   #### `on_port_dragged`
   Manages the continuous update of temporary connections during mouse movement. The implementation is straightforward, focusing solely on creation and updating of the temporary connection object.

   #### `on_port_dropped`
   Handles the connection finalization when the mouse is released. Port detection is simplified as each port is a discrete object.

While implementing this custom solution was time-intensive and occasionally daunting due to its scope, the resulting system is more maintainable and aligned with our specific needs.

### Event System Architecture
The implementation uses a simple but effective upward event propagation model:
- Events emit from widgets and traverse up the widget tree until reaching the target
- This ensures encapsulation, as children cannot directly access parents
- Event handling occurs at the appropriate level in the widget hierarchy

## Testing Framework Development

### Visual Shader Editor Testing Infrastructure
I've established a new `Tests` subdirectory within RGM, focusing on:
- Foundation for testing `MainWindow` and `VisualShaderEditor` classes
- Exploration of various testing methodologies, guided by resources like [Difference between Mocks, Fakes, Stubs and Dummies](http://xunitpatterns.com/Mocks,%20Fakes,%20Stubs%20and%20Dummies.html)

### Testing Challenges and Solutions
1. **Protobuf and Model Mocking**: Initial attempts to mock `MessageModel` and `ProtoModel` classes proved problematic
2. **Isolation vs. Integration**: Balancing the need to test the `VisualShaderEditor` in isolation while also testing system integration
3. **Workaround Implementation**: Created a parameter-less constructor for `VisualShaderEditor` to facilitate testing

### Current Testing Status
While UI testing presents significant challenges, we've established a solid foundation:
- Created the `Tests` directory structure
- Implemented tests for the `VisualShader` class
- Acknowledged the complexity of comprehensive UI testing and prioritized accordingly

## Project Extension Considerations
Despite aspirations to extend the project to include machine learning components, time constraints have necessitated focusing on core functionality. The integration complexity between Qt5, Protobuf, gRPC, `VisualShader`, `VisualShaderEditor`, JDI, and ENIGMA's Graphics System requires careful consideration and extensive testing.

## Notes
As confirmed by Robert on August 30, 2024:

> R0bert — 30/08/2024 17:58

> be careful im not sure if we can extend yours again this year, so dont count on it
> i saw mentor thread talking about that

This reinforces our focus on delivering a robust core implementation rather than expanding scope.

[my-google-summer-of-code-2024-project]: https://summerofcode.withgoogle.com/programs/2024/projects/wYTZuQbA
