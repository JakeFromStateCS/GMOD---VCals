# GMOD---VCals

Latest demonstration of decal editor:
https://www.youtube.com/watch?v=IA_jBwBOvpU

Some progress pictures:

Started getting the meshes created from ray traces and textures applied, though the tray traces hit the world model rather than the view model causing a lack of precision with collision positions.
The view models are far higher poly (Due to them not being used for collision simulations) which results in the mesh rendering under the view model as seen here:

https://i.imgur.com/nabeogb.jpg

The oven model has a view model which pretty closely matches the view model which means the mesh appears to conform to the view model. There were incorrect texture maths done here though:

https://i.imgur.com/xvD382Q.jpg

We get some interesting effects when the vertice positions for the mesh span multiple entities:

https://i.imgur.com/7aD0mS8.jpg

https://i.imgur.com/x2dl31i.jpg

More examples of the world model not matching the view model:

https://i.imgur.com/WJaZU9k.jpg


09/19/2018 - Finally started getting custom textures created programmatically to draw onto meshes. The world model is being drawn for reference:

https://i.imgur.com/aR53GN0.jpg

10/22/2018 - Added support for text drawing on the custom decals/textures:

https://i.imgur.com/6oTFXxd.jpg

12/17/2018 - Started work on tackling the world model/view model discrepancy to fix mesh placement

https://i.imgur.com/xhXMZld.jpg

Eventually started parsing the view model into its own mesh in order to do proper traces onto it.
