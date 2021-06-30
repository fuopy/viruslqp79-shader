/*
  VIRUS LQP-79: http://www.team-arg.org/zmbt-manual.html

  Arduboy version 1.6.0:  http://www.team-arg.org/zmbt-downloads.html

  MADE by TEAM a.r.g. : http://www.team-arg.org/more-about.html

  2016 - FUOPY - JO3RI - STG - CASTPIXEL - JUSTIN CYR

  Game License: MIT : https://opensource.org/licenses/MIT

  Shader version 0.1.0:  https://github.com/fuopy/viruslqp79-shader

  PORTED by FUOPY : https://github.com/fuopy

  2021 - FUOPY

*/

using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;

public class s_logic_viruslqp : UdonSharpBehaviour
{
    public Material gameLogicMaterial;

    private int Communication_PackInputState(float vx, float vy, bool b, bool a, bool power)
    {
        int state = 0;

        if (a) state |= 1;
        if (b) state |= 2;
        if (vx < 0) state |= 4;
        if (vx > 0) state |= 8;
        if (vy < 0) state |= 16;
        if (vy > 0) state |= 32;
        if (power) state |= 64;

        return state;
    }

    private int Communication_GetInputState()
    {
        var triggerDeadzone = .3;
        var stickDeadzone = .3;

        var b_button = Input.GetAxis("Oculus_CrossPlatform_SecondaryIndexTrigger") > triggerDeadzone;
        var a_button = Input.GetButton("Fire2") || Input.GetButton("Cancel");
        var power_button = Input.GetKey("p");

        b_button |= Input.GetKey("x") || Input.GetKey("j");
        a_button |= Input.GetKey("v") || Input.GetKey("k");

        float vx = Input.GetAxis("Oculus_CrossPlatform_PrimaryThumbstickHorizontal");
        float vy = -Input.GetAxis("Oculus_CrossPlatform_PrimaryThumbstickVertical");

        if (Mathf.Abs(vx) < stickDeadzone)
        {
            vx = 0;
        }
        if (Mathf.Abs(vy) < stickDeadzone)
        {
            vy = 0;
        }
        if (Input.GetKey("up") || Input.GetKey("w") || Input.GetKey("z"))
        {
            vy = -1;
        }
        else if (Input.GetKey("down") || Input.GetKey("s"))
        {
            vy = 1;
        }

        if (Input.GetKey("left") || Input.GetKey("a") || Input.GetKey("q"))
        {
            vx = -1;
        }
        else if (Input.GetKey("right") || Input.GetKey("d"))
        {
            vx = 1;
        }

        return Communication_PackInputState(vx, vy, b_button, a_button, power_button);
    }

    private void Update()
    {
        var inputState = Communication_GetInputState();
        gameLogicMaterial.SetFloat("_PlayerOneJoystick", inputState);
    }
}
