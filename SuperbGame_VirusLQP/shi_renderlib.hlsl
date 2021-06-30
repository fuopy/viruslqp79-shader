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


// HELPER ROUTINES //////////////////////////////////////////////////////////
#define FONT_WIDTH 8
#define FONT_HEIGHT 8

struct Sprites
{
	/// \brief Draws a single sprite.
	static float4 blit(int2 screenPos, Texture2D tex, int2 spritePos, int2 spriteSize, int2 spriteUV)
	{
		// Calculate the current pixel on the sprite to draw.
		int2 currentPixelOnSprite = screenPos - spritePos;

		// If the current pixel is out of bounds, draw nothing.
		if (currentPixelOnSprite.x < 0) return okayFloat4;
		if (currentPixelOnSprite.y < 0) return okayFloat4;
		if (currentPixelOnSprite.x >= spriteSize.x) return okayFloat4;
		if (currentPixelOnSprite.y >= spriteSize.y) return okayFloat4;

		// Draw the current pixel on the sprite.
		return tex[currentPixelOnSprite + spriteUV];
	}

	/// \brief Repeats a single sprite within the specified rectangle.
	static float4 rectblit(int2 screenPos, Texture2D tex, int2 rectPos, int2 rectSize, int2 spriteSize, int2 spriteUV)
	{
		// Calculate the current pixel on the sprite to draw.
		int2 currentPixelOnSprite = screenPos - rectPos;

		// If the current pixel is out of bounds, draw nothing.
		if (currentPixelOnSprite.x < 0) return okayFloat4;
		if (currentPixelOnSprite.y < 0) return okayFloat4;
		if (currentPixelOnSprite.x >= rectSize.x) return okayFloat4;
		if (currentPixelOnSprite.y >= rectSize.y) return okayFloat4;

		// Repeat the sprite depending on the sprite size.
		currentPixelOnSprite %= spriteSize;
		
		// Draw the current pixel on the sprite.
		return tex[currentPixelOnSprite + spriteUV];
	}

	static int2 uv16x16(int index)
	{
		return int2(((uint)index * 16) % 256, (((uint)index * 16) / 256) * 16);
	}
	static int2 uv8x16(int index)
	{
		return int2(((uint)index * 8) % 256, (((uint)index * 8) / 256) * 16);
	}
	static int2 uv32x8(int index)
	{
		return int2(((uint)index * 32) % 256, (((uint)index * 32) / 256) * 8);
	}
	static int2 uv9x8(int index)
	{
		return int2(((uint)index * 9) % 256, (((uint)index * 9) / 256) * 8);
	}
	static int2 uv8x8(int index)
	{
		return int2(((uint)index * 8) % 256, (((uint)index * 8) / 256) * 8);
	}
	static float4 draw_integer(int2 screenPos, Texture2D tex, inout int2 position, int size, int value, int padding, int spacing)
	{
		float4 finalColor = okayFloat4;

		// Convert the integer to a base-10 string.
		int i = value;
		int remainder;
		int finalNumberIter;
		int iterCount;

		int2 fontSize = font_small_size;
		int2 fontUV = font_small_uv_base;
	
		switch(size)
		{
		case FONT_TINY:
			fontSize = font_tiny_size;
			fontUV = font_tiny_uv_base;
			break;
		case FONT_SMALL:
			fontSize = font_small_size;
			fontUV = font_small_uv_base;
			break;
		case FONT_BIG:
			fontSize = font_big_size;
			fontUV = font_big_uv_base;
			break;
		}

		int digits[10] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };

		if (value < 0)
		{
			i = -i;
			// No negative numbers for now.
			//PIXEL(finalColor, Sprites::blit(screenPos, tex, Sprites::uv8x8(font) draw_character(x, y, destx, desty, '-', tex))
			//position.x += 6;
		}
		for (iterCount = 0; iterCount < 10; ++iterCount)
		{
			remainder = (uint)i % 10;
			i = (uint)i / 10;
			digits[iterCount] = remainder;
			if (i == 0) break;
		}
		iterCount = (iterCount < padding) ? padding : iterCount;
		for (finalNumberIter = 0; finalNumberIter <= iterCount; ++finalNumberIter)
		{
			PIXEL(finalColor, Sprites::blit(screenPos, tex, position, fontSize, fontUV + int2(fontSize.x * digits[iterCount - finalNumberIter], 0)));
			position.x += fontSize.x + spacing;
		}
		return finalColor;
	}
};


static Sprites sprites;

bool hitbox(float x1, float y1, float w1, float h1, float x2, float y2, float w2, float h2)
{
	return (x1 + w1 > x2) && (x1 < x2 + w2) && (y1 + h1 > y2) && (y1 < y2 + h2);
}
bool hitbox(int x1, int y1, int w1, int h1, int x2, int y2, int w2, int h2)
{
	return (x1 + w1 >= x2) && (x1 < x2 + w2) && (y1 + h1 >= y2) && (y1 < y2 + h2);
}
float4 draw_character(int x, int y, int sx, int sy, int id, Texture2D tex)
{
	if (hitbox(x, y, 0, 0, sx, sy, 5, 8))
	{
		int dx = x - sx;
		int dy = y - sy;
		int spx = 5 * (id % 16);
		int spy = 8 * (id / 16);
		int2 spritesheetPixel = int2(dx + spx, dy + spy);
		return tex[spritesheetPixel];
	}
	return okayFloat4;
}
float4 draw_integer(int x, int y, inout int destx, inout int desty, int val, Texture2D tex)
{
	float4 finalColor = okayFloat4;

	// Convert the integer to a base-10 string.
	int i = val;
	int remainder;
	int finalNumberIter;
	int iterCount;

	int digits[10] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };

	if (val < 0)
	{
		i = -i;
		PIXEL(finalColor, draw_character(x, y, destx, desty, '-', tex))
		destx += 6;
	}
	for (iterCount = 0; iterCount < 10; ++iterCount)
	{
		remainder = i % 10;
		i = i / 10;
		digits[iterCount] = remainder;
		if (i == 0) break;
	}
	for (finalNumberIter = 0; finalNumberIter <= iterCount; ++finalNumberIter)
	{
		PIXEL(finalColor, draw_character(x, y, destx, desty, digits[iterCount - finalNumberIter] + '0', tex));
		destx += 6;
	}
	return finalColor;
}

float4 draw_circle(int2 screenPos, int2 dest, int radius, float4 color)
{
	float dist = distance(dest, screenPos);
	if (dist < radius || dist > radius + 1)
	{
		return okayFloat4;
	}
	return color;
}
