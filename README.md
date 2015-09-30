Spectra
=======

This is a library for building on top of Metal for iOS and OSX.
 This is one of my first forays into graphics programming, so you've been warned.

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

#### What should manage the CommandBufferProvider and command buffers?

#### Do I need a separate pool of command buffers for Compute functions?

it seems like maybe i wouldn't, but that I also don't want to allocate new command buffers, so maybe i do need a separate pool.

#### How does the Scene class relate to the Renderer and View?  

I want an easy way to list a bunch of objects on screen and have them be rendered using various settings and textures.  

#### How should I manage the render encoders in my app? 

I should "only create one per render pass" is the advice given in the wwdc talk. At least, until I need multiples per render pass.  My point is, i shouldn't need one per Renderer and i shouldn't need one renderer per object.

#### How are resources and settings swapped out for render encoders?  

it looks like a render encoder only works for like one vertex/fragment function, but that can't be true.  How would i render hundreds of objects with separate textures, etc?

#### How to manage buffers for multiple objects?


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



