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

Shader "SuperbGame_VirusLQP/sh_logic"
{
    Properties
    {
        _LogicCanvas("LogicCanvas", 2D) = "gray" {}
		_PlayerOneJoystick("PlayerOneJoystick", Float) = 0
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#include "UnityCustomRenderTexture.cginc"
			#include "shi_logic.hlsl"

			#pragma vertex CustomRenderTextureVertexShader
			#pragma fragment frag
			#pragma target 5.0 

			uniform Texture2D _LogicCanvas; // Read, Write.
			uniform float _PlayerOneJoystick;

			void runGameLogic()
			{
				[call] switch (sharedState.gameState)
				{
				case STATE_MENU_INTRO: LogicState::MenuIntro(); break;
				case STATE_MENU_MAIN: LogicState::MenuMain(); break;
				case STATE_MENU_HELP: LogicState::MenuHelp(); break;
				case STATE_MENU_PLAY: LogicState::MenuPlay(); break;
				case STATE_MENU_INFO: LogicState::MenuInfo(); break;
				case STATE_MENU_SOUNDFX: LogicState::MenuSoundfx(); break;
				case STATE_GAME_PREPARE_LEVEL: LogicState::GamePrepareLevel(); break;
				case STATE_GAME_NEXT_LEVEL: LogicState::GameNextLevel(); break;
				case STATE_GAME_PLAYING: LogicState::GamePlaying(); break;
				case STATE_GAME_OVER: LogicState::GameOver(); break;
				case STATE_GAME_PAUSE: LogicState::GamePause(); break;
				case STATE_GAME_END: LogicState::GameEnd(); break;
				case STATE_GAME_NEW: LogicState::GameNew(); break;
				case STATE_GAME_CONTINUE: LogicState::GameContinue(); break;
				case STATE_GAME_MAYHEM: LogicState::GameMayhem(); break;

				default: break;
				}
			}

			float4 frag(v2f_customrendertexture IN) : COLOR
			{
				static const float IMAGE_WIDTH = 128.0;
				static const float IMAGE_HEIGHT = 128.0;
				int x = floor(IN.localTexcoord[0] * IMAGE_WIDTH);
				int y = floor(IN.localTexcoord[1] * IMAGE_HEIGHT);
				int maxFrameSkip = 1;

				load_state(_LogicCanvas);

				// Advance deltaTime
				deltaTimeBuffer += unity_DeltaTime.r;

				// If enough time has passed, process another frame.
				[fastopt] while (deltaTimeBuffer >= 0.0167 && maxFrameSkip > 0)
				{
					deltaTimeBuffer -= 0.0167;
					--maxFrameSkip;

					updateInput(_PlayerOneJoystick);
					++sharedState.frameCounter;
					[call] runGameLogic();
				}

				if (POWER_DOWN)
				{
					return float4(0, 0, 0, 0);
				}

				return save_state(x, y);
			}
			ENDCG
		}
	}
}
