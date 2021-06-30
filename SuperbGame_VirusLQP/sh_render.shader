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

Shader "SuperbGame_VirusLQP/sh_render"
{
    Properties
    {
        _LogicCanvas("LogicCanvas", 2D) = "gray" {}

        _GameSprites("GameSprites", 2D) = "gray" {}
        _Font("Font", 2D) = "gray" {}
		_HelpImage("HelpImage", 2D) = "gray" {}

		[ToggleUI]_TestNumber("TestNumber", Float) = 0
		[IntRange]_TestNumber2("TestNumber2", Range(0, 65535)) = 0
		[IntRange]_TestNumber3("TestNumber3", Range(0, 65535)) = 0

	    _BackgroundColor("BackgroundColor", Color) = (0, 0, 0, 0)
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #include "shi_render.hlsl"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment fragr
            #pragma target 5.0

            uniform Texture2D _LogicCanvas; // Read Only.
            uniform Texture2D _GameSprites;
            uniform Texture2D _Font;
			uniform Texture2D _HelpImage;

            uniform Float _TestNumber; // A debugging number, shown in blue.
            uniform Float _TestNumber2; // A debugging number, shown in green.
            uniform Float _TestNumber3; // A debugging number, shown in red.

			uniform float4 _BackgroundColor; // The background color (defaults to black).


            float4 fragr(v2f_customrendertexture IN) : COLOR
            {
                static const float IMAGE_WIDTH = 128.0;
                static const float IMAGE_HEIGHT = 64.0;
                int x = floor(IN.localTexcoord[0] * IMAGE_WIDTH);
                int y = floor(IN.localTexcoord[1] * IMAGE_HEIGHT);
                int2 screenPos = {x, y};
                
                load_state(_LogicCanvas);

                float4 finalColor = okayFloat4;
				float tn1 = _TestNumber;
				float tn2 = _TestNumber2;
				float tn3 = _TestNumber3;
                
                if (tn1 > 0)
                {
                    int xPos = 0;
                    int yPos = 56;
                    finalColor = draw_integer(x, y, xPos, yPos, tn1, _Font);
                    if (finalColor[0] > .5)
                    {
                        return blueColor;
                    }
                }
                if (tn2 > 0)
                {
                    int xPos = 0;
                    int yPos = 48;
                    finalColor = draw_integer(x, y, xPos, yPos, tn2, _Font);
                    if (finalColor[0] > .5)
                    {
                        return greenColor;
                    }
                }
                if (tn3 > 0)
                {
                    int xPos = 0;
                    int yPos = 40;
                    finalColor = draw_integer(x, y, xPos, yPos, tn3, _Font);
                    if (finalColor[0] > .5)
                    {
                        return redColor;
                    }
                }
                
                switch(sharedState.gameState)
                {
                case STATE_MENU_INTRO: PIXEL_NOBLACK(finalColor, RenderState::MenuIntro(screenPos, _GameSprites)); break;
                case STATE_MENU_MAIN: PIXEL_NOBLACK(finalColor, RenderState::MenuMain(screenPos, _GameSprites)); break;
                case STATE_MENU_HELP: PIXEL_NOBLACK(finalColor, RenderState::MenuHelp(screenPos, _HelpImage)); break;
                case STATE_MENU_PLAY: PIXEL_NOBLACK(finalColor, RenderState::MenuPlay(screenPos, _GameSprites)); break;
                case STATE_MENU_INFO: PIXEL_NOBLACK(finalColor, RenderState::MenuInfo(screenPos, _GameSprites)); break;
                case STATE_MENU_SOUNDFX: PIXEL_NOBLACK(finalColor, RenderState::MenuSoundfx(screenPos, _GameSprites)); break;
                case STATE_GAME_PREPARE_LEVEL: PIXEL_NOBLACK(finalColor, RenderState::GamePrepareLevel(screenPos, _GameSprites)); break;
                case STATE_GAME_NEXT_LEVEL: PIXEL_NOBLACK(finalColor, RenderState::GameNextLevel(screenPos, _GameSprites)); break;
                case STATE_GAME_PLAYING: PIXEL_NOBLACK(finalColor, RenderState::GamePlaying(screenPos, _GameSprites)); break;
                case STATE_GAME_OVER: PIXEL_NOBLACK(finalColor, RenderState::GameOver(screenPos, _GameSprites)); break;
                case STATE_GAME_PAUSE: PIXEL_NOBLACK(finalColor, RenderState::GamePause(screenPos, _GameSprites)); break;
                case STATE_GAME_END: PIXEL_NOBLACK(finalColor, RenderState::GameEnd(screenPos, _GameSprites)); break;
                case STATE_GAME_NEW: PIXEL_NOBLACK(finalColor, RenderState::GameNew(screenPos, _GameSprites)); break;
                case STATE_GAME_CONTINUE: PIXEL_NOBLACK(finalColor, RenderState::GameContinue(screenPos, _GameSprites)); break;
                case STATE_GAME_MAYHEM: PIXEL_NOBLACK(finalColor, RenderState::GameMayhem(screenPos, _GameSprites)); break;
                    
                default: break;
                }

                return _BackgroundColor;
            }
            ENDCG
        }
    }
}
