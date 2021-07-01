# viruslqp79-shader
Port of Virus LQP 79 to shader code

## About
Virus LQP-79 is a game made by TEAM a.r.g. in 2016 for the Arduino-based game system, Arduboy.
The Arduboy is a nifty little 8-bit game handheld with a monochrome OLED. This repo is a part of a larger project which will bring several Arduboy games to VRChat!
Check out the Arduboy at https://arduboy.com/

## Original game
The original code has been archived here. This is a snapshot of the most recent version of the code.
https://github.com/Team-ARG-Museum/ID-40-VIRUS-LQP-79

# World Builder's Manual

## Usage
1. Install the [dependencies](#dependencies).
2. Add the SuperbGame_VirusLQP directory of this repo to Assets/ in your Unity project.
3. Drop the SuperbGame_VirusLQP prefab into your scene.
4. Done!

## Tips
- You might want to find a good way of locking the player in place while playing the game. If you look at my official world in VRChat, it may give you some ideas. Sample code is available here: https://github.com/fuopy/vrc-game-inputs/
- I suggest using Silent's Pixel shader instead of the default point filtering here. Silent's shader is available at: https://gitlab.com/s-ilent/pixelstandard. For Silent's pixel shader to work, you'll need to change the filtering on crt_render from "point" to either "Bilinear" or "Trilinear".

## Current Limitations
- No sound. I'm looking into generating sound instead of using samples as was done in glove-shader.
- Local only. People cannot watch you play. I want to add sync. This codebase actually has some subtle differences from glove-shader to make frame rate easier to manage, which is an important building block for adding sync.
- No saving. I'm waiting for the official support for persistence in VRChat before adding saving.

## Dependencies
### Required
- VRCSDK3 for Worlds: Log into your VRChat account and download the official SDK off the website.
- UdonSharp by Merlin: https://github.com/MerlinVR/UdonSharp

### Suggested
- CyanEmu by CyanLaser: https://github.com/CyanLaser/CyanEmu

# Gameplay Manual

## Archived Story and Bestiary:
https://web.archive.org/web/20170317211312/http://www.team-arg.org/vlqp-manual.html

## Controls:
Input Name | Desktop A | Desktop B | VR
--- | --- | --- | ---
Move Up | Up Arrow | W | Movement stick Y Up
Move Down | Down Arrow | S | Movement stick Y Down
Move Left | Left Arrow | A | Movement stick X Left
Move Right | Right Arrow | D | Movement stick X Right
Shoot and Run | X | J | Use
Shoot and Strafe | V | K | Jump
Pause | X + V | J + K | Jump + Use

Tip: If you are having trouble controlling the game, check to see if you've rebound your inputs!


