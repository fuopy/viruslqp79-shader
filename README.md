# viruslqp79-shader
Port of Virus LQP 79 to shader code

# About
Virus LQP-79 is a game made by TEAM a.r.g. in 2016 for the Arduino-based game system, Arduboy.

# Original game
The original code has been archived here. This is a snapshot of the most recent version of the code.
https://github.com/Team-ARG-Museum/ID-40-VIRUS-LQP-79

# Usage
1. Add the SuperbGame_VirusLQP79 directory of this repo to Assets/ in your Unity project.
2. Drop the SuperbGame_VirusLQP79 prefab into your scene.
3. Done!

# Tips
- You might want to find a good way of locking the player in place while playing the game. If you look at my official world in VRChat, it may give you some ideas.
- I suggest using Silent's Pixel shader instead of the default point filtering here. Silent's shader is available at: https://gitlab.com/s-ilent/pixelstandard. For Silent's pixel shader to work, you'll need to change the filtering on crt_render from "point" to either "Bilinear" or "Trilinear".

# Current Limitations
- No sound. I'm looking into generating sound instead of using samples as was done in glove-shader.
- Local only. People cannot watch you play. I want to add sync. This codebase actually has some subtle differences from glove-shader to make frame rate easier to manage, which is an important building block for adding sync.
- No saving. I'm waiting for the official support for persistence in VRChat before adding saving.
