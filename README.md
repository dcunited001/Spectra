# Spectra

[![CI Status](http://img.shields.io/travis/David Conner/Spectra.svg?style=flat)](https://travis-ci.org/David Conner/Spectra)
[![Version](https://img.shields.io/cocoapods/v/Spectra.svg?style=flat)](http://cocoapods.org/pods/Spectra)
[![License](https://img.shields.io/cocoapods/l/Spectra.svg?style=flat)](http://cocoapods.org/pods/Spectra)
[![Platform](https://img.shields.io/cocoapods/p/Spectra.svg?style=flat)](http://cocoapods.org/pods/Spectra)

This is a library for building on top of Metal for iOS and OSX.
This is one of my first forays into graphics programming, so you've been warned.

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

Spectra is available through [CocoaPods](http://cocoapods.org). To install, add `pod 'Spectra'` to your `Podfile`

## Author

David Conner, dconner.pro@gmail.com

## License

Spectra is available under the MIT license. See the LICENSE file for more info.


### READ: [Metal Programming Guide](https://developer.apple.com/library/ios/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40014221-CH1-SW1)

### READ: [Caltech Geometry Papers](http://www.geometry.caltech.edu/pubs.html)

- [Vertex Descriptor for Data Organization](https://developer.apple.com/library/ios/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Render-Ctx/Render-Ctx.html#//apple_ref/doc/uid/TP40014221-CH7-SW44)

- explore Swinject or Dip dependency injection

### Questions:

I wrote this basic OSX app [MetalSpectrograph](https://github.com/dcunited001/MetalSpectrograph)
with Metal. I just got an iPhone, so i want to refactor out my code into
this app.  Instead of just copying and pasting what I have (which can
barely render 20,000 triangles) I want to rewrite it, so it's at least
decent.  I don't want to use another 3d framework.

However, after watching and rewatching some of the WWDC videos from
2014/2015, I have a lot of questions I keep circling around to when
assessing how to get from my current design to one that is "decent" from
a performance and code maintainence/flexibility standpoint.

#### 3D geometry library

Need to check out `MathGeoLib`, which may be of use to include alongside Spectra.  But may be best not to tangle in with Spectra itself.

Need to check out the license for `CAGL`, which looks amazing, but it seems there's some restrictions for commercial application distribution

#### Nodes and Node Generators

Nodes are objects with uniformables, etc

Node generators generate vertexes and vertex-triangle maps, which can
also be used to index texture/color coordinates.

Nodes should just have a map of buffers?

NodeGenerators should also create vertex-face maps.  best way to
generate an ID for the faces?

vertex-face maps allow for vertex-face tesselation using compute
generator

need to better understand complicated geometry shhit like {3,2,,4} like
wtf does that even mean?  probably useful when creating compute
generators for geometry

vertex-morph maps: compute generators to create either random or
non-random maps of vertices to ID vertices to move as groups... whoa
dude

or like a 3D slice map: approximate all vertices that lie in a plane by
approximating the plane to a linear 3D slice or a slice of a 3D
funciton.  this generates a vertex morph map, to be used to modulate
vertex position or color

#### How to identify vertices that lie on a plane?

is this even a problem i want to worry about? or should this be user
defined?

#### Tensor Maps

Tensor maps need to be vertex-vertex maps defining the graph between nodes.
for simplicity, they should be limited to a set number of relationships
between each node (at first)

Tensor data lists contain one entry for every vertex-vertex edge and
define a set number of parameters for each edge. Tensor data lists can
be applied to modulate vertices, textures and colors.  Tensor data lists
will need to be input to compute/vertex/fragment shaders, and also
copied

#### What should manage the CommandBufferProvider and command buffers?

#### Do I need a separate pool of command buffers for Compute functions?

it seems like maybe i wouldn't, but that I also don't want to allocate new command buffers, so maybe i do need a separate pool.

#### How does the Scene class relate to the Renderer and View?

I want an easy way to list a bunch of objects on screen and have them be rendered using various settings and textures.

#### How should I manage the render encoders in my app?

change encode function to accept a block?  then configure behavior for
renderer in view or scene?

I should "only create one per render pass" is the advice given in the wwdc talk. At least, until I need multiples per render pass.  My point is, i shouldn't need one per Renderer and i shouldn't need one renderer per object.

#### How are resources and settings swapped out for render encoders?

it looks like a render encoder only works for like one vertex/fragment function, but that can't be true.  

any of the `.set` methods can be called on a renderEncoder without generating a new one.

the easiest and best option here would be to have a renderStrategy
object for a scene, which takes a list of pipelineState keys, along with 
blocks for each transition.  at this point, it's up to the user (via the scene) to
decide how to transition between each renderEncoder.  the renderStrategy
will accept the next block, which either transitions the renderEncoder
to an acceptable state, or creates a new one from the commandBuffer.

There should be an analogous computeStrategy.  renderStrategy should be
nestable.  these should provide enough flexibility.

#### How would i render hundreds of objects with separate textures, etc?

with an array texture or texture atlas

#### How to swap out various audio visualizations

create various pipelineStateDescriptors for each combination of vertex/fragment function.  pipelineStateDescriptors also describe the colorAttachments and depthAttachments

create map of pipelineState's during initilazation, then pass in renderEncoder and pipelineState to encode(), along with block for encoding vertexBuffers & fragmentBuffers

#### How to 'reset' a renderEncoder between pipelineState changes

could reset with a transition block, that defines commands to apply during the transition from one pipelineState to another

or i could reset to a known default state (for DepthStencilState and RenderPipelineState)

#### How to manage buffers for multiple objects?

device.createBuffer for each object?  or concatenate vertex, etc data for groups of objects and pass vertex start/count info for each object.

#### How to deal with vertex maps?

E.G. vertex-triangle maps. common structure for vertex-tensor maps, etc?
Interface for automatically allocating the required maps?

#### How to update vertex maps when vertex structure changes?

or explore using MTLVertexBufferLayoutDescriptor?

#### How to update buffer size (and buffers in pool) when vertex structure/size changes?

#### Common interface for objects using either buffer providers or just raw buffers?

just wrap buffers in buffer provider pattern?

#### How are buffer providers managed for nodes?

in the wwdc 2015 video for advanced metal, the dev mentions that what is written to a vertex/fragment buffer needs to stick around long enough after it's encoded for the GPU to render it.  But, if so, what's the point of StorageModeShared if you would have to constantly copy the updates you've made to other buffers in that buffer pool?

E.G. i want to stream audio waveform/fft data from EZAudio into
StorageModeShared (or managed) memory. However, if i should use a semaphore and pool
of buffers for this and then i need to copy updates from the last two
frames to the next frame's buffer, that pretty much negates the benefits i receive
from using this and makes it an order of magnitude more complicated.  So
that can't be the right answer.

At the same time, if i want to use the CPU to setup the next frame while
the GPU renders and i'm using a single vertex buffer, instead of a semaphore & buffer pool,
then I may be stomping all over my changes from the last frame. Maybe
this doesn't matter for my application, where I'm essentially streaming
in vertex data from FFT.

#### Do i need a similar 'provider' pattern for inputs to vertex/fragement shaders?

**update:** looks like no, encoder.setBytes() encodes using a copy of
data!  excellent.

By 'inputs', i mean the data i'm using below in `setBytes`.  similarly to the
situation described above, and perhaps more inportantly, if the data
referenced by the pointer &data changes between this frame and the next,
the the fragment shader may be receiving data that's invalid.

For me, this is important because i'm writing FFT audio to a circular
buffer, then using a BufferInput to tell the vertex shader where the
data starts.  Except I'm getting some very wierd behavior. I'm not sure
if this is the cause.  But, if the circular buffer start byte is lagging
behind, this may cause some wierd behavior.

```swift
renderEncoder.setVertexBytes(&data, length: data.size(), atIndex: bufferId)
```

#### Wow, so the reflection really excited me, but apparently it's a bit slow

In the advanced metal vid, the dev warns not to use reflection unless
needed.  I thought this would be an amazing way to make my
vertex/fragment shaders reusable.  I could reflect on the method
definitions to determine what kinds of data the function required, then
attach what I have (if i have it) and attach acceptable default values
if i don't.

I doubt I'd get to the point where I use metal reflection any time soon,
but I imagine it'd be incredibly useful for certain applications.

#### I've read that I can pass and use function pointers in Metal Shaders

how do i do this?  This is one of those features i saw mentioned in the
metal docs somewhere that sounds like it enables very flexible shader
code.


#### How can i metaprogram my shaders?

While one of the performance gains of Metal is compiling shaders at
build time, this implies the ability to compile them at run time (or
more preferably app startup time).  Or perhaps I can iterate through my
code and identify all the 'fragments' of vertex/fragment shaders that I
might need and use the metal command line tools to glue them together
and build a custom library (still at build time)  I know this is possible, but how do i do
it?
