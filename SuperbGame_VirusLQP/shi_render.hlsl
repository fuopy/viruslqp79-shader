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

#include "shi_shared.hlsl"
#include "shi_renderlib.hlsl"

#pragma region LQP_Player

/// \brief Draws the player to the screen, relative to the camera position.
float4 Player::draw(int2 screenPos, Texture2D tex)
{
	float4 finalColor = okayFloat4;
	
	if ((flashTime % 8) < 4)
	{
		int spriteIndex = frame + 4 * direction;
		int2 spriteUV = Sprites::uv16x16(spriteIndex);
		PIXEL(finalColor, Sprites::blit(screenPos, tex, position - sharedState.mapPosition, player_size, player_uv_base + spriteUV));
	}
	return okayFloat4;
}

/// \brief Draws the player life bar to the the top left of the screen.
float4 Player::drawLife(int2 screenPos, Texture2D tex)
{
	float4 finalColor = okayFloat4;
	
	// Calculate the position of the first heart.
	int2 heartPositionOnScreen = int2(0, 0);

	// Draw each heart.
	for (int lifePointsRemainingToDraw = health; lifePointsRemainingToDraw > 0; lifePointsRemainingToDraw -= 2)
	{
		// Draw a full heart if we still have whole hearts to process.
		if (lifePointsRemainingToDraw >= 2)
		{
			// Draw the full heart sprite.
			int2 spriteUV = Sprites::uv9x8(1);
			PIXEL(finalColor, Sprites::blit(screenPos, tex, heartPositionOnScreen, life_size, life_uv_base + spriteUV));

			// Calculate the position of the next heart.
			heartPositionOnScreen.x += life_size.x;
		}
		// Draw a half heart and stop if there is less than a full heart to process.
		else if (lifePointsRemainingToDraw == 1)
		{
			// Draw the half heart sprite.
			int2 spriteUV = Sprites::uv9x8(0);
			PIXEL(finalColor, Sprites::blit(screenPos, tex, heartPositionOnScreen, life_size, life_uv_base + spriteUV));
			break;
		}
		// Stop drawing if there are no hearts left.
		else
		{
			break;
		}
	}

	return finalColor;
}

/// \brief Draws the player's shot cooldown meter near the top of the screen.
float4 Player::drawCoolDown(int2 screenPos, Texture2D tex)
{
	float4 finalColor = okayFloat4;
	int i = 0;
	
	if (coolDownVisible)
	{
		for (i = 0; i < coolDownCounter; i++)
		{
			PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(i, 7), cooldown_size, cooldown_uv_base));
		}
		PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(i, 7), cooldown_size, cooldown_uv_base + int2(1, 0)));
	}

	return finalColor;
}
#pragma endregion 

#pragma region LQP_Bullets

/// \brief Draws a single bullet, relative to camera position.
float4 Bullet::draw(int2 screenPos, Texture2D tex)
{
	float4 finalColor = okayFloat4;
	if (!active) return finalColor;
	// CONSIDER: Don't draw if we're off-screen.
	PIXEL(finalColor, Sprites::blit(screenPos, tex, position - sharedState.mapPosition, bullet_size, bullet_uv_base));
	return finalColor;
}

#pragma endregion 

#pragma region LQP_Level


/// \brief Draws the level tile data, scrolled by camera position.
static float4 Level::draw(int2 screenPos, Texture2D tex)
{
	float4 finalColor = okayFloat4;
	
	// Given a pixel on the screen and camera, find the tile x/y position.
	int2 tilePos = (sharedState.mapPosition + screenPos) / 8;
	int2 tileInnerPos = (sharedState.mapPosition + screenPos) % 8;

	// Get the tile id.
	int tileId = getTileType(tilePos);

	// Draw the tile sprite.
	int2 tileUV = Sprites::uv8x8(tileId);

	//tileUV = Sprites::uv8x8(5);
	finalColor = tex[tileUV + tileInnerPos];
	
	return finalColor;
}

#pragma endregion 

#pragma region LQP_Door

float4 Door::draw(int2 screenPos, Texture2D tex)
{
	float4 finalColor = okayFloat4;
	
	if (active)
	{
		int2 spriteUV = Sprites::uv8x8(frame + 4 * orientation);
		PIXEL(finalColor, Sprites::rectblit(screenPos, tex, int2(position - sharedState.mapPosition), int2(16, 16), exitopen_size, exitopen_uv_base + spriteUV));
	}
	else
	{
		int2 spriteUV = Sprites::uv8x8(orientation);
		PIXEL(finalColor, Sprites::blit(screenPos, tex, position - sharedState.mapPosition, exitclosed_size, exitclosed_uv_base + spriteUV));
	}

	return finalColor;
}

#pragma endregion

#pragma region LQP_Elements

/// \brief draws every active survivor in the list to the display
float4 Element::draw(int2 screenPos, Texture2D tex, int id)
{
	float4 finalColor = okayFloat4;
	if (!active) return finalColor;

	// Draw the survivor sprite.
	//int2 spriteUV = Sprites::uv16x16(sharedState.survivorFrame);
	int2 spriteUV = Sprites::uv16x16(sharedState.survivorFrame + (4 * survivorType[id]));
	PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(position - sharedState.mapPosition), survivor_size, survivor_uv_base + spriteUV));
	PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(position - sharedState.mapPosition) + int2(16, -9), help_size, help_uv_base));


	//PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(0 - sharedState.mapPosition), survivor_size, survivor_uv_base + spriteUV));

	return finalColor;
}

float4 drawAmountSurvivors(int2 screenPos, Texture2D tex)
{
	float4 finalColor = okayFloat4;
	int2 spriteUV = Sprites::uv9x8(2);
	
	for (int amountSurvivors = 0; amountSurvivors < countAmountActiveSurvivors(); amountSurvivors++) // needs the amount of active survivors
	{
		PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(40 + amountSurvivors * 9, 0), life_size, life_uv_base + spriteUV));
	}
	if (!countAmountActiveSurvivors())
	{
		// Draw flashing "Exit" icon.
		if (sharedState.showHelp)
		{
			spriteUV = Sprites::uv9x8(3);
			PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(45, 0), life_size, life_uv_base + spriteUV));
			spriteUV = Sprites::uv9x8(4);
			PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(54, 0), life_size, life_uv_base + spriteUV));
		}

		// Draw countdown timer digits.
		int2 pos = { 68, 1 };
		PIXEL(finalColor, Sprites::draw_integer(screenPos, tex, pos, FONT_TINY, exitDoor.counter, 2, 1));

		// Draw countdown timer BG.
		spriteUV = Sprites::uv9x8(5);
		PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(65, 0), life_size, life_uv_base + spriteUV));
		spriteUV = Sprites::uv9x8(6);
		PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(74, 0), life_size, life_uv_base + spriteUV));
	}
	return finalColor;
}

#pragma endregion 

#pragma region LQP_Pickups


float4 Pickup::draw(int2 screenPos, Texture2D tex)
{
	int4 finalColor = okayFloat4;
	if ((type > PICKUP_TYPE_INACTIVE) && isVisible)
	{
		int2 spriteUV = Sprites::uv8x8(frame + (6 * (type - 1)));
		//PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(0, 0), pickup_size, pickup_uv_base));
		PIXEL(finalColor, Sprites::blit(screenPos, tex, position - sharedState.mapPosition, pickup_size, pickup_uv_base + spriteUV));
	}
	
	return finalColor;
}

#pragma endregion 

#pragma region LQP_Zombie

/// \brief draws a single zombie
float4 Enemy::draw(int2 screenPos, Texture2D tex)
{
	float4 finalColor = okayFloat4;

	int spriteIndex;
	int2 spriteUV;

	// // Decrement the flash timer.
	// if (flashTime > 0)
	// {
	// 	flashTime--;
	// }

	// If we're visible, draw!
	if (active)
	{
		if ((flashTime % 8) < 4)
		{
			if (!type)
			{
				spriteIndex = frame + 8 * direction;
				spriteUV = Sprites::uv16x16(spriteIndex) + enemy_uv_base;
			}
			else
			{
				spriteIndex = (frame % 2) + 2 * direction;
				spriteUV = Sprites::uv16x16(spriteIndex) + enemy2_uv_base;
			}
			PIXEL(finalColor, Sprites::blit(screenPos, tex, position - sharedState.mapPosition, enemy_size, spriteUV));
		}
	}
	else
	{
		// Draw explosion.
		if (flashTime > 0)
		{
			flashTime--;
			PIXEL(finalColor, draw_circle(screenPos, int2(position.x - sharedState.mapPosition.x + logic_zombie_size.x / 2, position.y - sharedState.mapPosition.y + logic_zombie_size.y / 2), 12 - flashTime * 2, whiteColor));
			// 	drawCircle(x - mapPositionX + ZOMBIE_WIDTH / 2, y - mapPositionY + ZOMBIE_HEIGHT / 2, 12 - flashTime * 2, 1);
		}
	}

	return finalColor;
}

#pragma endregion 

#pragma region LQP_Menu

float4 drawTitleScreen(int2 screenPos, Texture2D tex)
{
	float4 finalColor = okayFloat4;

	PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(0, 0), titleScreen00_size, titleScreen00_uv_base));
	PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(62, 32), titleScreen01_size, titleScreen01_uv_base));
	PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(66, 0), titleScreen02_size, titleScreen02_uv_base));

	return finalColor;
}

float4 drawBadge(int2 screenPos, Texture2D tex)
{
	float4 finalColor = okayFloat4;

	PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(30, 0), titleScreen02_size, titleScreen02_uv_base));
	PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(92, 0), titleScreen03_size, titleScreen03_uv_base));

	return finalColor;
}

#pragma endregion 


#pragma region LQP_RenderStates

static float4 RenderState::MenuHelp(int2 screenPos, Texture2D tex)
{
	float4 finalColor = okayFloat4;

	PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(0, 0), int2(128, 64), int2(0, 0)));

	return finalColor;
}

static float4 RenderState::MenuSoundfx(int2 screenPos, Texture2D tex)
{
	float4 finalColor = okayFloat4;

	// Draw "SFX"
	int2 spriteUV = Sprites::uv32x8(4);
	PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(128 - sharedState.slideCounter, 25), menutext_size, menutext_uv_base + spriteUV));
	if (false) // audio.enabled
	{
		// Draw "OFF"
		spriteUV = Sprites::uv32x8(5);
		PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(128 - sharedState.slideCounter, 34), menutext_size, menutext_uv_base + spriteUV));

		// Draw "ON"
		spriteUV = Sprites::uv32x8(6);
		PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(128 - sharedState.slideCounter - sharedState.globalCounter, 43), menutext_size, menutext_uv_base + spriteUV));
	}
	else
	{
		// Draw "ON"
		spriteUV = Sprites::uv32x8(6);
		PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(128 - sharedState.slideCounter, 43), menutext_size, menutext_uv_base + spriteUV));

		// Draw "OFF"
		spriteUV = Sprites::uv32x8(5);
		PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(128 - sharedState.slideCounter - sharedState.globalCounter, 34), menutext_size, menutext_uv_base + spriteUV));
	}

	// Draw title screen.
	PIXEL(finalColor, drawTitleScreen(screenPos, tex));

	return finalColor;
}

static float4 RenderState::MenuInfo(int2 screenPos, Texture2D tex)
{
	float4 finalColor = okayFloat4;
	
	PIXEL(finalColor, drawBadge(screenPos, tex));
	PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(48, 33), madeby00_size, madeby00_uv_base));
	PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(22, 33), madeby01_size, madeby01_uv_base));
	PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(27, 47), madeby02_size, madeby02_uv_base));

	return finalColor;
}

static float4 RenderState::MenuPlay(int2 screenPos, Texture2D tex)
{
	float4 finalColor = okayFloat4;
	int additonalOffset = 0;

	// Draw "NEW"
	int2 spriteUV = Sprites::uv32x8(7);
	additonalOffset = (sharedState.menuSelection == 2) ? sharedState.globalCounter : 0;
	PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(128 - sharedState.slideCounter - additonalOffset, 25), menutext_size, menutext_uv_base + spriteUV));
	
	// Draw "CONT"
	spriteUV = Sprites::uv32x8(8);
	additonalOffset = (sharedState.menuSelection == 3) ? sharedState.globalCounter : 0;
	PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(128 - sharedState.slideCounter - additonalOffset, 34), menutext_size, menutext_uv_base + spriteUV));
	
	// Draw "HELL"
	spriteUV = Sprites::uv32x8(9);
	additonalOffset = (sharedState.menuSelection == 4) ? sharedState.globalCounter : 0;
	PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(128 - sharedState.slideCounter - additonalOffset, 43), menutext_size, menutext_uv_base + spriteUV));

	PIXEL(finalColor, drawTitleScreen(screenPos, tex));
	return finalColor;
}

static float4 RenderState::MenuIntro(int2 screenPos, Texture2D tex)
{
	float4 finalColor = okayFloat4;
	
	// PIXEL(finalColor, sprites.drawSelfMasked(34, 4, T_arg, 0));

	return finalColor;
}

static float4 RenderState::MenuMain(int2 screenPos, Texture2D tex)
{
	float4 finalColor = okayFloat4;
	int additonalOffset = 0;

	// Draw "HELP"
	int2 spriteUV = Sprites::uv32x8(0);
	additonalOffset = (sharedState.menuSelection == STATE_MENU_HELP) ? sharedState.globalCounter : 0;
	PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(128 - sharedState.slideCounter - additonalOffset, 25), menutext_size, menutext_uv_base + spriteUV));
	
	// Draw "PLAY"
	spriteUV = Sprites::uv32x8(1);
	additonalOffset = (sharedState.menuSelection == STATE_MENU_PLAY) ? sharedState.globalCounter : 0;
	PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(128 - sharedState.slideCounter - additonalOffset, 34), menutext_size, menutext_uv_base + spriteUV));
	
	// Draw "INFO"
	spriteUV = Sprites::uv32x8(2);
	additonalOffset = (sharedState.menuSelection == STATE_MENU_INFO) ? sharedState.globalCounter : 0;
	PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(128 - sharedState.slideCounter - additonalOffset, 43), menutext_size, menutext_uv_base + spriteUV));
	
	// Draw "CONF"
	spriteUV = Sprites::uv32x8(3);
	additonalOffset = (sharedState.menuSelection == STATE_MENU_SOUNDFX) ? sharedState.globalCounter : 0;
	PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(128 - sharedState.slideCounter - additonalOffset, 52), menutext_size, menutext_uv_base + spriteUV));
	
	PIXEL(finalColor, drawTitleScreen(screenPos, tex));

	return finalColor;
}

/// \brief called each frame the gamestate is set to playing
static float4 RenderState::GamePlaying(int2 screenPos, Texture2D tex)
{
	float4 finalColor = okayFloat4;
	
	int id;
	int x, y;
	// HUD
	int2 pos = {86, 0};
	PIXEL(finalColor, Sprites::draw_integer(screenPos, tex, pos, FONT_SMALL, coolGirl.score, 5, -1));
	PIXEL(finalColor, coolGirl.drawLife(screenPos, tex));
	PIXEL(finalColor, coolGirl.drawCoolDown(screenPos, tex));
	PIXEL(finalColor, drawAmountSurvivors(screenPos, tex));
	
	// Sprites
	PIXEL(finalColor, coolGirl.draw(screenPos, tex));
	PIXEL(finalColor, exitDoor.draw(screenPos, tex));

	for (int id1 = 0; id1 < SURVIVOR_MAX; ++id1)
	{
		PIXEL(finalColor, survivors[id1].draw(screenPos, tex, id1));	
	}
	for (int id2 = 0; id2 < ZOMBIE_MAX; ++id2)
	{
		PIXEL(finalColor, zombies[id2].draw(screenPos, tex));	
	}
	for (int id3 = 0; id3 < PICKUP_MAX; ++id3)
	{
		PIXEL(finalColor, pickups[id3].draw(screenPos, tex));	
	}
	for (int id4 = 0; id4 < BULLET_MAX; ++id4)
	{
		PIXEL(finalColor, bullets[id4].draw(screenPos, tex));	
	}

	// Tiles
	PIXEL(finalColor, Level::draw(screenPos, tex));

	return finalColor;
}

static float4 RenderState::GameNextLevel(int2 screenPos, Texture2D tex)
{
	float4 finalColor = okayFloat4;
	int2 pos = {0, 0};
	
	if (sharedState.bonusVisible)
	{
		PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(32, 16), bonuspoints_size, bonuspoints_uv_base));

		pos = int2(78, 16);
		PIXEL(finalColor, Sprites::draw_integer(screenPos, tex, pos, FONT_SMALL, exitDoor.counter, 2, -1));
		pos = int2(36, 36);
		PIXEL(finalColor, Sprites::draw_integer(screenPos, tex, pos, FONT_BIG, coolGirl.score, 5, 2));
	}
	if (sharedState.nextLevelVisible)
	{
		PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(sharedState.leftX, 24), nextlevel_size, nextlevel_uv_base));
		if (sharedState.pressKeyVisible)
		{
			if (sharedState.gameType == STATE_GAME_MAYHEM)
			{
				PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(41, 8), textmayhem_size, textmayhem_uv_base));
			}
			else
			{
				PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(43, 8), textnormal_size, textnormal_uv_base));
			}
			PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(37, 48), presskey_size, presskey_uv_base));
		}
		pos = int2(sharedState.rightX, 24); 
		PIXEL(finalColor, Sprites::draw_integer(screenPos, tex, pos, FONT_BIG, sharedState.displayLevel, 1, 2));
	}

	return finalColor;
}
static float4 RenderState::GamePrepareLevel(int2 screenPos, Texture2D tex)
{
	; // Nothing to do.
	return okayFloat4;
}
/// \brief called each frame the gamestate is set to game over
static float4 RenderState::GameOverEnd(int2 screenPos, Texture2D tex)
{
	; // Nothing to do.
	return okayFloat4;
}

static float4 RenderState::GameOver(int2 screenPos, Texture2D tex)
{
	float4 finalColor = okayFloat4;

	// "MAYHAM"
	if (sharedState.gameType == STATE_GAME_MAYHEM)
	{
		PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(41, 3), textmayhem_size, textmayhem_uv_base));
	}
	// "NORMAL"
	else
	{
		PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(41, 3), textnormal_size, textnormal_uv_base));
	}
	// "GAME OVER"
	PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(11, 15), gameover_size, gameover_uv_base));

	// score
	int2 pos = {35, 34};
	PIXEL(finalColor, Sprites::draw_integer(screenPos, tex, pos, FONT_BIG, coolGirl.score, 5, 2));

	// "PRESS KEY" (flashing)
	if (sharedState.pressKeyVisible)
	{
		PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(37, 53), presskey_size, presskey_uv_base));
	}

	return finalColor;
}

static float4 RenderState::GameEnd(int2 screenPos, Texture2D tex)
{
	float4 finalColor = okayFloat4;
	int2 pos;

	// "YOU WON"
	PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(22, 8), youwon_size, youwon_uv_base));

	// score
	pos = int2(36, 32);
	PIXEL(finalColor, Sprites::draw_integer(screenPos, tex, pos, FONT_BIG, coolGirl.score, 5, 2));

	// "PRESS KEY" (flashing)
	if (sharedState.pressKeyVisible)
	{
		PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(37, 56), presskey_size, presskey_uv_base));
	}
	
	return finalColor;
}

static float4 RenderState::GamePause(int2 screenPos, Texture2D tex)
{
	float4 finalColor = okayFloat4;
	
	PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(30, 0), titleScreen02_size, titleScreen02_uv_base));
	PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(92, 0), titleScreen03_size, titleScreen03_uv_base));
	PIXEL(finalColor, Sprites::blit(screenPos, tex, int2(37, 40), pause_size, pause_uv_base));

	return okayFloat4;
}

static float4 RenderState::GameNew(int2 screenPos, Texture2D tex)
{
	; // Nothing to do.
	return  okayFloat4;
}

static float4 RenderState::GameContinue(int2 screenPos, Texture2D tex)
{
	; // Nothing to do.
	return  okayFloat4;
}

static float4 RenderState::GameMayhem(int2 screenPos, Texture2D tex)
{
	; // Nothing to do.
	return  okayFloat4;
}

#pragma endregion 