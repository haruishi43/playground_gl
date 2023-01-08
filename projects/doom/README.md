# Doom Engine (Renderer) in Python

Based on the original codebase by [jordansavant](https://github.com/jordansavant/doomengine.python).

# Installation

## macOS

Follow `pygame` installation [https://www.pygame.org/wiki/MacCompile].

```Bash
brew install sdl2 sdl2_image sdl2_mixer sdl2_ttf pkg-config portmidi
brew install --cask xquartz
```

Install `pygame` on your python of choice:
```Bash
pip install pygame
```

Test if the modules are working:

```Bash
python -m pygame.tests
```

## Linux

WIP

## Common:

Install dependencies:

```Bash
pip install -r requirements.txt
```

Test if this project runs:

- run: `python main.py`
- run: `python main_opengl.py`


# Running the code:

## Running DIY DOOM

- Support efforts of original project (this is a port from C++ to Python: https://github.com/amroibrahim/DIYDoom)
- Get a DOOM WAD file. Comes with any original install of Doom or Doom 2.
- Put wad file in `wads/` dir
- Run with `python3 main_diy.py wads/DOOM.wad [map]` where optionally `[map]` is a doom map name: eg `E1M1`

---

In awe of the 1993 doom engine rendering logic regarding Binary Space Partitioning I explored its concepts using a recreation of this engine in Python using pygame as the display portion. The result was great respect for Id Software's work they accomplished.

![](.readme/assets/DIYDOOM.gif)

# How it works:

## The Binary Space Partition
- Two connected vertices define a LineDef
- A LineDef has an outward face to define which side of it is considered open and which side is solid
- A list of LineDefs form a Polygon that can define the boundaries of a room, or "sector"
- A Binary Space Partition class accepts the worlds list of LineDefs
  - The BSP chooses a best candidate "splitter" LineDef by which to judge all other LineDefs
  - The BSP creates two child BSPs to place other LineDefs behind or in front of the splitter
  - LineDefs that cross the plane of the splitter and split into smaller LineDefs to be sorted
- The BSP sorts all LineDefs recursively in the child trees
- Using the BSP we can test whether a position is in open space with a depth search
- Using the BSP we can also render all walls from either back to front or front to back
  - Doom rendered them front to back and used culling to prevent overdraw
  - Other engines have rendered back to front called the Painters Algorithm
- The BSP Tree is built before the game begins as a means of significant performance gain

## The 3D Projection

In DOOM the world, walls and its occupants all live within a 2D plane essentially on an X,Y coordinate system. So at any point the player is surrounded by 2d lines and points that represent walls and enemies.

When it comes time to render the walls in classic DOOM it would traverse its Binary Space Partition testing each wall's 2d start and end positions against the player's 2d position. If the wall was facing the player it would be put in a list. After the traversal this list of walls would be the only walls that needed to be rendered to the screen, all others would be culled.

In fact this list of walls could be further culled because though they all "face" the player, they may not be within the viewport of the camera, such as if they were behind DOOM guy.

Interestingly enough, the order of traversal in the BSP could produce the list in two ways: if the tree was depth-first searched it would produce a list of walls that were sorted by closest to furthest, and if searched oppositely, ie testing at the roots it would produce a list of walls that were sorted furthest to closest.

The order of the resultant list could allow you to render them with the classic "Painter's Algorithm" or inversely how DOOM decided to to it. The Painter's algorithm basically involves rendering the further walls first so that nearby walls get "painted" on top of other walls to produce the correct layering of walls. This was a bit wasteful so in the DOOM engine they rendered in reverse.

Roughly, the DOOM method rendered closest to furthest. It would inspect the closest wall and would run a hardcoded *_3D_* projection matrix against the wall's position at every horizontal pixel on the screen. This would produce a number of vertical pixels (colored and textured) to render at that horizontal pixel position. From there it would test the next wall and if it produced a horizontal position of pixels that overlapped a prior wall's calculation it could be culled.

## Pass 1 - Pure Pygame Polygons

I am not an expert on 3D or Linear Algebra so at first I relied heavily on resources listed below to get it "right". The world is defined in 2D space. Each of the LineDefs as well can have a height property.

The Field of View was hard coded into the matrix mathematics to project the 2D wall into the camera very similarly to the DOOM engine.

For rendering I went with Pygame's basic 2D shapes such as the polygon for rendering walls. I glued together various tutorials from other programmers such as Bisqwit to get my hardcoded projection matrices to produce the correct rendering. The result was as follows:

![](.readme/assets/demo_pygame_render.gif)

*initial engine written purely in pygame worked but had a lot of projection issues*

It worked and worked pretty well considering. I chose to render with the Painter's Algorithm instead of DOOM's method because testing and culling on a large resolution is very expensive, and the painter method is pretty simple to do.

However the wall rendering had two major problems: 1, pygame did not handle rendering polygons that bled off screen well at all, so I had to cut out cross sections of the walls that would only project to the screen. 2, my math for this was not well done so at certain perspectives the wall heights would jump up and down as the projection thought the wall extended to infinity when it was cut at the screens edges. It was hard to understand and though ultimately proved that the engine worked left me a bit dissatisfied.

## Pass 2 - OpenGL Rendering

The separation of logic and rendering was done well enough I was confident I could implement an OpenGL renderer in lieu of pygame polygons. This would allow me to translate the 2d walls into 3d positions at render time and have OpenGL do the matrix mathematics in its natural manner to produce proper projection and offscreen culling.

I learned a lot about matrix transformations: modelview scale, rotation and translation as well as view matrices and projection. I glued together more examples to bring FPS controls into the mix and after a lot of plugging away was able to replace the Pygame Polygon renderering engine with a 3D and 2D OpenGL rendering.

![](.readme/assets/demo_opengl_render.gif)

*opengl engine worked significantly better as expected*

The result was a lot more stable and better looking than the pure pygame method.


## Pass 3 - DIY Doom Port

`amroibrahim` over at `https://github.com/amroibrahim/DIYDoom` has an awesome rebuild of the original DOOM engine in C++. I recreated his project (up to chapter 17) in Python with efforts established in Passes 1 and 2.

It is capable of:
- Loading maps from original DOOM wad file
- Pulling BSP and level data
- Rendering map overview with algorithms for bsp traversal, rendering and clipping like the original DOOM game
- It results in a small raytracing overlay of the engine
    - Being raytracing, the original engine does not scale well to larger resolutions (more horizontal pixels more processing required).
- You can navigate the map with: wasd
- You can look with left and right arrows
- Up and down arrows render each chapters build result live in the screen

![](.readme/assets/DIYDOOM.gif)

---

# Resources
- Bisqwit Tut: https://bisqwit.iki.fi/jutut/kuvat/programming_examples/portalrendering.html
- BSP Tut: https://www.cs.utah.edu/~jsnider/SeniorProj/BSP1/default.html
- CS Resources: http://www.flipcode.com
- Vector Maths: http://math.hws.edu/graphicsbook/c3/s5.html
- Wolfenstein: https://lodev.org/cgtutor/raycasting.html
- OpenGL surfaces: https://pythonprogramming.net/coloring-pyopengl-surfaces-python-opengl
- FPS spectation: https://3dengine.org/Spectator_(PyOpenGL)/
- 2D over 3D: https://stackoverflow.com/questions/43130842/python-opengl-issues-displaying-2d-graphics-over-a-3d-scene
- Coding Train 3D Projection: https://www.youtube.com/watch?v=p4Iz0XJY-Qk
- World, View and Projection Transformation Matrices: http://www.codinglabs.net/article_world_view_projection_matrix.aspx
- DIY Doom: https://github.com/amroibrahim/DIYDoom
- DOOM WAD: https://store.steampowered.com/app/2280/Ultimate_Doom/

