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

#ifndef _SUPERB_SHARED_HLSL_
#define _SUPERB_SHARED_HLSL_

#include "shi_leveldata.hlsl"
#include "shi_random.hlsl"

#pragma region Superb_Constants

#define LO(v) ((v)&0xff)
#define HI(v) (((v)>>8)&0xff)
#define SLO(v) (((v)>>16)&0xff)
#define SHI(v) (((v)>>24)&0xff)
#define PACK(v) ((asuint(LO(v)))/255.0)
#define UNPACK(v) (floor((v)*255))

#define BYTE_ONE(v) ((v)&0xff)
#define BYTE_TWO(v) (((v)>>8)&0xff)
#define BYTE_THREE(v) (((v)>>16)&0xff)
#define BYTE_FOUR(v) (((v)>>24)&0xff)

#define A_DOWN new_a
#define A_PRESSED (new_a && !old_a)
#define A_RELEASED (!new_a && old_a)

#define B_DOWN new_b
#define B_PRESSED (new_b && !old_b)
#define B_RELEASED (!new_b && old_b)

#define UP_DOWN new_up
#define UP_PRESSED (new_up && !old_up)
#define UP_RELEASED (!new_up && old_up)

#define DOWN_DOWN new_down
#define DOWN_PRESSED (new_down && !old_down)
#define DOWN_RELEASED (!new_down && old_down)

#define LEFT_DOWN new_left
#define LEFT_PRESSED (new_left && !old_left)
#define LEFT_RELEASED (!new_left && old_left)

#define RIGHT_DOWN new_right
#define RIGHT_PRESSED (new_right && !old_right)
#define RIGHT_RELEASED (!new_right && old_right)

#define POWER_DOWN new_power
#define POWER_PRESSED (new_power && !old_power)
#define POWER_RELEASED (!new_power && old_power)

static const float4 nullFloat4 = { 0, 0, 0, 1 };
static const float4 okayFloat4 = { 0, 0, 0, 0 };

// Standard colors.
static const float4 blackColor = { 0, 0, 0, 1 };
static const float4 whiteColor = { 1, 1, 1, 1 };
static const float4 redColor = { 255, 0, 0, 1 };
static const float4 greenColor = { 0, 255, 0, 1 };
static const float4 blueColor = { 0, 0, 255, 1 };

#pragma endregion 

#pragma region Superb_Funcs
#define PIXEL(var, color) var = (color); if (var[3] > 0.5) return var;
#define PIXEL_NOBLACK(var, color) var = (color); if (var[3] > 0.5 && (var[0] > 0 || var[1] > 0 || var[2] > 0)) return var;

float4 pack_it(uint val)
{
	// Dumb bitwise placement.
	return float4(PACK(val), PACK(HI(val)), PACK(SLO(val)), PACK(SHI(val)));
}
float4 pack_it(int val)
{
	uint us = asuint(val);
	float4 result = {(us&0xff) / 255.0, ((us>>8)&0xff) / 255.0, ((us>>16)&0xff) / 255.0, ((us>>24)&0xff) / 255.0};
	return result;
}
float4 pack_it(float val)
{
	return float4(val, 0, 0, 1);
}
int unpack_int(float4 val)
{
	uint a = (val[0]*255);
	uint b = ((uint)(val[1]*255)) << 8;
	uint c = ((uint)(val[2]*255)) << 16;
	uint d = ((uint)(val[3]*255)) << 24;
	uint e = (a | b | c | d);
	int f = asint(e);
	return f;
}
uint unpack_uint(float4 val)
{
	uint a = UNPACK(val[0]);
	uint b = ((uint)UNPACK(val[1]) << 8);
	uint c = ((uint)UNPACK(val[2]) << 16);
	uint d = ((uint)UNPACK(val[3]) << 24);
	return a | b | c | d;
}

float load_float(Texture2D tex, int2 pos)
{
	return tex[pos].r;
}

int load_val(Texture2D tex, int2 pos)
{
	float4 val = tex[pos];
	uint a = (val[0]*255);
	uint b = ((uint)(val[1]*255)) << 8;
	uint c = ((uint)(val[2]*255)) << 16;
	uint d = ((uint)(val[3]*255)) << 24;
	uint e = (a | b | c | d);
	int f = asint(e);
	return f;
}

#define SAVE_BOOL(x) (pack_it((uint)(x ? -1 : 0)))

#pragma endregion

#pragma region Superb_Rows

#define ROW_SINGLE 0
#define ROW_SINGLE_LQP 1

#define ROW_BULLET_POSITION_X 2
#define ROW_BULLET_POSITION_Y 3
#define ROW_BULLET_ACTIVE 4
#define ROW_BULLET_VELOCITY_X 5
#define ROW_BULLET_VELOCITY_Y 6

#define ROW_PICKUP_POSITION_X 12
#define ROW_PICKUP_POSITION_Y 13
#define ROW_PICKUP_TYPE 14
#define ROW_PICKUP_FRAME 15 
#define ROW_PICKUP_COUNTER 16
#define ROW_PICKUP_ISVISIBLE 17

#define ROW_ELEMENT_POSITION_X 18
#define ROW_ELEMENT_POSITION_Y 19
#define ROW_ELEMENT_ACTIVE 20

#define ROW_ENEMY_POSITION_X 21
#define ROW_ENEMY_POSITION_Y 22
#define ROW_ENEMY_FRAME 23
#define ROW_ENEMY_DIRECTION 24
#define ROW_ENEMY_HEALTH 25
#define ROW_ENEMY_ACTIVE 26
#define ROW_ENEMY_FLASHTIME 27
#define ROW_ENEMY_TYPE 28

#define ROW_INPUT_HISTORY 29
#define ROW_FRAME_HISTORY 30
#define ROW_INPUT_FUTURE 31
#define ROW_FRAME_FUTURE 32

#pragma endregion 

#pragma region Superb_Singles
static const int2 SINGLE_Superb_deltaTimeBuffer = {0, ROW_SINGLE};
static const int2 SINGLE_Superb_new_a = {32, ROW_SINGLE};
static const int2 SINGLE_Superb_new_b = {33, ROW_SINGLE};
static const int2 SINGLE_Superb_new_up = {34, ROW_SINGLE};
static const int2 SINGLE_Superb_new_left = {35, ROW_SINGLE};
static const int2 SINGLE_Superb_new_down = {36, ROW_SINGLE};
static const int2 SINGLE_Superb_new_right = {37, ROW_SINGLE};
static const int2 SINGLE_Superb_old_a = {38, ROW_SINGLE};
static const int2 SINGLE_Superb_old_b = {39, ROW_SINGLE};
static const int2 SINGLE_Superb_old_up = {40, ROW_SINGLE};
static const int2 SINGLE_Superb_old_left = {41, ROW_SINGLE};
static const int2 SINGLE_Superb_old_down = {42, ROW_SINGLE};
static const int2 SINGLE_Superb_old_right = {43, ROW_SINGLE};
static const int2 SINGLE_Superb_new_power = {44, ROW_SINGLE};
static const int2 SINGLE_Superb_old_power = {45, ROW_SINGLE};
static const int2 SINGLE_Superb_frameNumber = {46, ROW_SINGLE};
#pragma endregion


#pragma region Superb_Globals
static float deltaTimeBuffer;
static bool new_a;
static bool new_b;
static bool new_up;
static bool new_left;
static bool new_down;
static bool new_right;
static bool old_a;
static bool old_b;
static bool old_up;
static bool old_left;
static bool old_down;
static bool old_right;
static bool new_power;
static bool old_power;
static int frameNumber;
#pragma endregion


#pragma region LQP_Constants

// Logic sizes.
static const int2 screen_size = {128, 64};
static const int2 game_size = {128, 64};
static const int2 logic_bullet_size = {2, 2};
static const int2 logic_player_size = {16, 16};
static const int2 logic_survivor_size = {16, 16};
static const int2 logic_level_size = {512, 256}; 
static const int2 tile_size = {8, 8};
static const int2 logic_zombie_size = {16, 16};

// Sprite sizes.
static const int2 life_size = {9, 8};
static const int2 life_uv_base = {120, 152};
static const int2 player_size = {16, 16};
static const int2 player_uv_base = {0, 48};
static const int2 cooldown_size = {1, 3};
static const int2 cooldown_uv_base = {32, 205};
static const int2 bullet_size = {2, 2};
static const int2 bullet_uv_base = {112, 152};
static const int2 font_tiny_size = {3, 8};
static const int2 font_tiny_uv_base = {0, 152};
static const int2 font_small_size = {8, 8};
static const int2 font_small_uv_base = {32, 152};
static const int2 font_big_size = {8, 16};
static const int2 font_big_uv_base = {0, 160};
static const int2 enemy_size = {16, 16};
static const int2 enemy_uv_base = {0, 112};
static const int2 enemy2_uv_base = {64, 96};

static const int2 titleScreen00_size = {62, 64};
static const int2 titleScreen00_uv_base = {192, 192};
static const int2 titleScreen01_size = {37, 32};
static const int2 titleScreen01_uv_base = {152, 192};
static const int2 titleScreen02_size = {62, 32};
static const int2 titleScreen02_uv_base = {96, 160};
static const int2 titleScreen03_size = {6, 32};
static const int2 titleScreen03_uv_base = {160, 160};

static const int2 madeby00_size = {57, 32};
static const int2 madeby00_uv_base = {106, 224};
static const int2 madeby01_size = {21, 8};
static const int2 madeby01_uv_base = {163, 248};
static const int2 madeby02_size = {16, 8};
static const int2 madeby02_uv_base = {163, 240};

static const int2 qrcode_size = {32, 8};
static const int2 qrcode_uv_base = {104, 200};

static const int2 menutext_size = {32, 8};
static const int2 menutext_uv_base = {0, 128};

static const int2 pickup_size = {8, 8};
static const int2 pickup_uv_base = {128, 144};
static const int2 survivor_size = {16, 16};
static const int2 survivor_uv_base = {0, 80};
static const int2 help_size = {32, 16};
static const int2 help_uv_base = {0, 192};

static const int2 textnormal_size = {48, 8};
static const int2 textnormal_uv_base = {56, 224};
static const int2 textmayhem_size = {48, 8};
static const int2 textmayhem_uv_base = {56, 232};
static const int2 gameover_size = {105, 16};
static const int2 gameover_uv_base = {0, 240};
static const int2 presskey_size = {56, 8};
static const int2 presskey_uv_base = {64, 192};
static const int2 youwon_size = {84, 16};
static const int2 youwon_uv_base = {64, 208};
static const int2 pause_size = {56, 16};
static const int2 pause_uv_base = {0, 208};

static const int2 exitopen_size = {8, 8};
static const int2 exitopen_uv_base = {0, 144};
static const int2 exitclosed_size = {16, 16};
static const int2 exitclosed_uv_base = {0, 176};

static const int2 bonuspoints_size = {33, 8};
static const int2 bonuspoints_uv_base = {65, 200};
static const int2 nextlevel_size = {52, 16};
static const int2 nextlevel_uv_base = {0, 224};

// VIRUS LQP DEFINES /////////////////////////////////////////////////////////
// #define OFFSET_VLQP_START             (EEPROM_STORAGE_SPACE_START + 64)
// #define OFFSET_LEVEL                  (OFFSET_VLQP_START + sizeof(byte))
// #define OFFSET_SCORE                  (OFFSET_LEVEL + sizeof(int))
// #define OFFSET_HEALTH                 (OFFSET_SCORE + sizeof(unsigned long))
// #define OFFSET_VLQP_END               (OFFSET_HEALTH + sizeof(byte))

#define STATE_MENU_INTRO         0
#define STATE_MENU_MAIN          1
#define STATE_MENU_HELP          2
#define STATE_MENU_PLAY          3
#define STATE_MENU_INFO          4
#define STATE_MENU_SOUNDFX       5

#define STATE_GAME_PREPARE_LEVEL 6
#define STATE_GAME_NEXT_LEVEL    7
#define STATE_GAME_PLAYING       8
#define STATE_GAME_OVER          9
#define STATE_GAME_PAUSE         10
#define STATE_GAME_END           11
#define STATE_GAME_NEW           12
#define STATE_GAME_CONTINUE      13
#define STATE_GAME_MAYHEM        14

#define BULLET_MAX        6
#define BULLET_WIDTH      2
#define BULLET_HEIGHT     2
#define BULLET_DIRECTIONS 8

#define EXIT_FACING_SOUTH       0
#define EXIT_FACING_WEST        1
#define EXIT_FACING_NORTH       2
#define EXIT_FACING_EAST        3
#define EXIT_ON_SOUTH_BORDER    0
#define EXIT_ON_WEST_BORDER     496
#define EXIT_ON_NORTH_BORDER    240
#define EXIT_ON_EAST_BORDER     0

#define PICKUP_TYPE_INACTIVE 0
#define PICKUP_TYPE_COIN 1
#define PICKUP_TYPE_HEART 2
#define PICKUP_MAX 3

#define SURVIVOR_FRAME_SKIP      10
#define SURVIVOR_FRAME_COUNT     4
#define SURVIVOR_MAX             5

#define PLAYER_FACING_SOUTH       0
#define PLAYER_FACING_SOUTHWEST   1
#define PLAYER_FACING_WEST        2
#define PLAYER_FACING_NORTHWEST   3
#define PLAYER_FACING_NORTH       4
#define PLAYER_FACING_NORTHEAST   5
#define PLAYER_FACING_EAST        6
#define PLAYER_FACING_SOUTHEAST   7
#define PLAYER_FLASH_TIME         60
#define PLAYER_MAXHEALTH          8
#define PLAYER_START_HEALTH       5
#define WEAPON_OVERHEAT           35

#define FONT_TINY                     0
#define FONT_SMALL                    1
#define FONT_BIG                      2

#define NUM_MAPS                      32
#define LEVEL_TO_START_WITH           1               // normal game starts with level 1
#define TOTAL_LEVEL_AMOUNT            (NUM_MAPS * 4)

#define ENEMY_FACING_WEST        0
#define ENEMY_FACING_EAST        1
#define ZOMBIE_FRAME_SKIP        2
#define ZOMBIE_FRAME_COUNT       8
#define ZOMBIE_MAX               24
#define ZOMBIE_SPEED             1
#define ZOMBIE_STEP_DELAY        3
#define ZOMBIE_FLASH_TIME        5

#define INPUT_HISTORY_MAX        64
#define INPUT_FUTURE_MAX         64

// Lookup table for trig.
static const int BulletXVelocities[8] = { 0, -2, -3, -2, 0, 2, 3, 2 };

// Pickup spawn order list.
static const int pickupsAvailable[] = {
	PICKUP_TYPE_COIN,
	PICKUP_TYPE_COIN,
	PICKUP_TYPE_COIN,
	PICKUP_TYPE_INACTIVE,
	PICKUP_TYPE_COIN,
	PICKUP_TYPE_HEART,
	PICKUP_TYPE_INACTIVE,
	PICKUP_TYPE_COIN,
	PICKUP_TYPE_INACTIVE,
	PICKUP_TYPE_COIN
};

#pragma endregion



#pragma region LQP_Funcs
// burp
// returns the value a given percent distance between start and goal
// percent is given in 4.4 fixed point
int burp(int start, int goal, unsigned int step)
{
	int a = goal;
	int b = start;
	int sign = 0;

	if (start > goal)
	{
		a = start;
		b = goal;
		sign = -1;
	}
	else if (start < goal)
	{
		sign = 1;
	}

	start += sign * (1 + ((a - b) * step) / 16);
	if (a < b) return goal;

	return start;
}

// TODO: Implement random.
int random(int max)
{
	return random() % max;
}
int random(int min, int max)
{
	return random(max-min) + min;
}

// TODO: Implement tone.
void tone(int x, int y)
{
	; // Do nothing.
}

#pragma endregion

#pragma region LQP_Type_SharedState

struct SharedState
{
	int gameID; // ???
	int gameState; // Current game state. Used for rendering and drawing to decide what to do on a frame.
	int gameType; // Normal or Mayham.
	int globalCounter; // Used for UI.
	int slideCounter; // Used for UI.
	int menuSelection; // Used for UI.
	int level; // The current level number.

	int pickupsCounter;
	int gameSubState; // For UI.
	int displayLevel; // For UI.

	bool bonusVisible; // For UI.
	bool nextLevelVisible; // For UI.
	bool pressKeyVisible; // For UI.
	int leftX;
	int rightX;
	
	int2 mapPosition;
	int survivorFrame;
	bool showHelp;
	int amountActiveSurvivors;

	int frameCounter;
};
static SharedState sharedState;

bool everyXFrames(int frameCount)
{
	return (sharedState.frameCounter % frameCount) == 0;
}

static const int2 SINGLE_SharedState_gameID = {12, ROW_SINGLE_LQP};
static const int2 SINGLE_SharedState_gameState = {13, ROW_SINGLE_LQP};
static const int2 SINGLE_SharedState_gameType = {14, ROW_SINGLE_LQP};
static const int2 SINGLE_SharedState_globalCounter = {15, ROW_SINGLE_LQP};
static const int2 SINGLE_SharedState_slideCounter = {16, ROW_SINGLE_LQP};
static const int2 SINGLE_SharedState_menuSelection = {17, ROW_SINGLE_LQP};
static const int2 SINGLE_SharedState_level = {18, ROW_SINGLE_LQP};
static const int2 SINGLE_SharedState_pickupsCounter = {19, ROW_SINGLE_LQP};
static const int2 SINGLE_SharedState_gameSubState = {20, ROW_SINGLE_LQP};
static const int2 SINGLE_SharedState_displayLevel = {21, ROW_SINGLE_LQP};
static const int2 SINGLE_SharedState_bonusVisible = {22, ROW_SINGLE_LQP};
static const int2 SINGLE_SharedState_nextLevelVisible = {23, ROW_SINGLE_LQP};
static const int2 SINGLE_SharedState_pressKeyVisible = {24, ROW_SINGLE_LQP};
static const int2 SINGLE_SharedState_leftX = {25, ROW_SINGLE_LQP};
static const int2 SINGLE_SharedState_rightX = {26, ROW_SINGLE_LQP};
static const int2 SINGLE_SharedState_mapPosition_x = {27, ROW_SINGLE_LQP};
static const int2 SINGLE_SharedState_mapPosition_y = {28, ROW_SINGLE_LQP};
static const int2 SINGLE_SharedState_survivorFrame = {29, ROW_SINGLE_LQP};
static const int2 SINGLE_SharedState_showHelp = {30, ROW_SINGLE_LQP};
static const int2 SINGLE_SharedState_amountActiveSurvivors = {31, ROW_SINGLE_LQP};
static const int2 SINGLE_SharedState_frameCounter = {32, ROW_SINGLE_LQP};
static const int2 SINGLE_randomNext = {33, ROW_SINGLE_LQP};

#pragma endregion

#pragma region LQP_Type_Player

struct Player
{
	int2 position;
	int score; // Player's current score.
	int rollingScore; // Used for UI.
	bool walking;
	int direction;
	int frame;
	int shotDelay;
	int health;
	int flashTime;
	int camDirection;
	int diagonalTime;
	bool coolDownVisible;
	bool overHeated;
	int coolDownCounter;
	
	float4 draw(int2 screenPos, Texture2D tex);
	float4 drawLife(int2 screenPos, Texture2D tex);
	float4 drawCoolDown(int2 screenPos, Texture2D tex);

	void initialize();
	void update();
	void healthOffset(int amount);
};
static const int2 SINGLE_Player_position_x = {40, ROW_SINGLE_LQP};
static const int2 SINGLE_Player_position_y = {41, ROW_SINGLE_LQP};
static const int2 SINGLE_Player_score = {42, ROW_SINGLE_LQP};
static const int2 SINGLE_Player_rollingScore = {43, ROW_SINGLE_LQP};
static const int2 SINGLE_Player_walking = {44, ROW_SINGLE_LQP};
static const int2 SINGLE_Player_direction = {45, ROW_SINGLE_LQP};
static const int2 SINGLE_Player_frame = {46, ROW_SINGLE_LQP};
static const int2 SINGLE_Player_shotDelay = {47, ROW_SINGLE_LQP};
static const int2 SINGLE_Player_health = {48, ROW_SINGLE_LQP};
static const int2 SINGLE_Player_flashTime = {49, ROW_SINGLE_LQP};
static const int2 SINGLE_Player_camDirection = {50, ROW_SINGLE_LQP};
static const int2 SINGLE_Player_diagonalTime = {51, ROW_SINGLE_LQP};
static const int2 SINGLE_Player_coolDownVisible = {52, ROW_SINGLE_LQP};
static const int2 SINGLE_Player_overHeated = {53, ROW_SINGLE_LQP};
static const int2 SINGLE_Player_coolDownCounter = {54, ROW_SINGLE_LQP};

struct Level
{
	static float4 draw(int2 screenPos, Texture2D tex);
	
	/// \brief Gets the tile type, given tile position in current level.
	static int getTileType(int2 tilePos)
	{
		// Format: Map -> Block -> Tile ID.
		// Step 1: What map? (Answer: current map.)
		int mapId = sharedState.level - 1;

		// Step 2: Which block byte? And which nibble?
		int blockByte = ((tilePos.y/8)*4) + (tilePos.x/16);
		bool lowByte = (tilePos.x/8) & 0x01;
		int blockId = lowByte ? (maps[mapId][blockByte] & 0x0f) : (maps[mapId][blockByte] >> 4) & 0x0f;

		// Step 3: What tile?
		// Each block is 8x8 tiles.
		int2 innerTilePos = tilePos % 8;
		int innerTileIndex = innerTilePos.x + innerTilePos.y * 8;
	
		return blocks[blockId][innerTileIndex];
	}
};
struct Bullet {
	int2 position;
	int2 velocity;
	
	int active;

	float4 draw(int2 screenPos, Texture2D tex);
	
	bool set(int2 position, int2 velocity);
	void update();
	
	static void add(int2 _position, int2 _velocity, int direction);
	static void updateAll();
	static void clearAll();
};
struct Door {
	int2 position;
	
	int active;
	int orientation;
	int frame;
	int counter;
	int loseLifeCounter;
	
	float4 draw(int2 screenPos, Texture2D tex);

	int getOrientation();
	void setPosition(int2 _position);
	bool checkCollision(int2 _position, int2 _size);
	void update();
};
static const int2 SINGLE_Door_position_x = {60, ROW_SINGLE_LQP};
static const int2 SINGLE_Door_position_y = {61, ROW_SINGLE_LQP};
static const int2 SINGLE_Door_active = {62, ROW_SINGLE_LQP};
static const int2 SINGLE_Door_orientation = {63, ROW_SINGLE_LQP};
static const int2 SINGLE_Door_frame = {64, ROW_SINGLE_LQP};
static const int2 SINGLE_Door_counter = {65, ROW_SINGLE_LQP};
static const int2 SINGLE_Door_loseLifeCounter = {66, ROW_SINGLE_LQP};

struct Pickup
{
	int2 position;
	int type;
	int frame;
	int counter;
	bool isVisible;
	
	float4 draw(int2 screenPos, Texture2D tex);
	void update();

	static bool add(int2 _position);
	static void updateAll();
	static void updateCollision(int2 _position, int2 _size);
	static void clearAll();
};
struct Element
{
	int2 position;
	int active;
	
	float4 draw(int2 screenPos, Texture2D tex, int id);

	static void swapSurvivorPool();
	static void updateAll();
	bool checkCollision(int2 _position, int2 _size);
	bool collect();
	static void clearAll();
	static void updateCollision(int2 _position, int2 _size);
};
struct Enemy
{
	int2 position;
	int frame;
	int direction;
	int health;
	int active;
	int flashTime;
	int type;
	
	float4 draw(int2 screenPos, Texture2D tex);

	void set(int2 _position, int _type);
	static bool spawn();
	static bool add(int2 _position);
	void update();
	static void updateAll();
	bool healthOffset(int amount);
	bool checkCollision(int2 _position, int2 _size);
	static void clearAll();
	static void updateCollision(inout int2 _position, int2 _size, bool horizontal, inout int vel);
};


struct LogicState
{
	static void MenuHelp();
	static void MenuSoundfx();
	static void MenuInfo();
	static void MenuPlay();
	static void MenuIntro();
	static void MenuMain();
	static void GamePlaying();
	static void GameNextLevel();
	static void GamePrepareLevel();
	static void GameOverEnd();
	static void GameOver();
	static void GameEnd();
	static void GamePause();
	static void GameNew();
	static void GameContinue();
	static void GameMayhem();
};
struct RenderState
{
	static float4 MenuHelp(int2 screenPos, Texture2D tex);
	static float4 MenuSoundfx(int2 screenPos, Texture2D tex);
	static float4 MenuInfo(int2 screenPos, Texture2D tex);
	static float4 MenuPlay(int2 screenPos, Texture2D tex);
	static float4 MenuIntro(int2 screenPos, Texture2D tex);
	static float4 MenuMain(int2 screenPos, Texture2D tex);
	static float4 GamePlaying(int2 screenPos, Texture2D tex);
	static float4 GameNextLevel(int2 screenPos, Texture2D tex);
	static float4 GamePrepareLevel(int2 screenPos, Texture2D tex);
	static float4 GameOverEnd(int2 screenPos, Texture2D tex);
	static float4 GameOver(int2 screenPos, Texture2D tex);
	static float4 GameEnd(int2 screenPos, Texture2D tex);
	static float4 GamePause(int2 screenPos, Texture2D tex);
	static float4 GameNew(int2 screenPos, Texture2D tex);
	static float4 GameContinue(int2 screenPos, Texture2D tex);
	static float4 GameMayhem(int2 screenPos, Texture2D tex);
};

struct LogicSubState
{
	static void nextLevelStart();
	static void nextLevelBonusCount();
	static void nextLevelWait();
	static void nextLevelSlideToMiddle();
	static void nextLevelEnd();
	static void GameOverEnd();

	static void RunNextLevelSubstate(int stateIndex);
	static void RunGameOverSubstate(int stateIndex);
};

#pragma endregion

#pragma region LQP_Globals

//static int survivorType[5] = { 0, 1, 2, 3, 4 };
static int survivorType[5] = { 0, 0, 0, 0, 0 };
static Bullet bullets[BULLET_MAX];
static Pickup pickups[PICKUP_MAX];
static Element survivors[SURVIVOR_MAX];
static Door exitDoor;
static Enemy zombies[ZOMBIE_MAX];
static Player coolGirl;
static float inputhistory[INPUT_HISTORY_MAX];
static float framehistory[INPUT_HISTORY_MAX];
static float inputfuture[INPUT_FUTURE_MAX]; // The future buffer: Input
static float framefuture[INPUT_FUTURE_MAX]; // The future buffer: Frame number.

#pragma endregion

#pragma region Superb_Methods
void updateInput(float inputState)
{
	int iState = inputState;

	// Copy new to old and unmask new.
	old_a = new_a;
	old_b = new_b;
	old_left = new_left;
	old_right = new_right;
	old_up = new_up;
	old_down = new_down;
	old_power = new_power;
	new_a = iState & 1;
	new_b = iState & 2;
	new_left = iState & 4;
	new_right = iState & 8;
	new_up = iState & 16;
	new_down = iState & 32;
	new_power = iState & 64;

	// Copy input state and frame history. Oldest stuff is at the top. Everything else copies up.
	[unroll] for (int i = 0; i < INPUT_HISTORY_MAX-1; ++i)
	{
		inputhistory[i] = inputhistory[i+1];
		framehistory[i] = framehistory[i+1];
	}
	inputhistory[INPUT_HISTORY_MAX-1] = iState;
	framehistory[INPUT_HISTORY_MAX-1] = sharedState.frameCounter;
}

// Returns true if we have buttons to simulate.
// Returns false if the button is empty--This means the sim should pause.
bool simulateInput(float frameHist[INPUT_HISTORY_MAX], float inputHist[INPUT_HISTORY_MAX])
{
	// Copy to the history buffers. (for now. add a latch to only copy sometimes/append later on.)
	for (int frameIter = 0; frameIter < INPUT_HISTORY_MAX; ++frameIter)
	{
		inputfuture[frameIter] = inputHist[frameIter];
		framefuture[frameIter] = frameHist[frameIter];
	}

	// If our current frame number is ahead of anything in the future buffer, we've
	// gone to far somehow. Pause and wait for inputs.
	if (sharedState.frameCounter >= framefuture[0])
	{
		return false;
	}

	// Otherwise let's pop a frame input. The top one becomes the new input. Move everything upwards.
	int iState = inputfuture[INPUT_FUTURE_MAX-1];
	[unroll] for (int i = 0; i < INPUT_FUTURE_MAX-1; ++i)
	{
		inputfuture[i] = inputfuture[i+1];
		framefuture[i] = framefuture[i+1];
	}

	// Copy new to old and unmask new.
	old_a = new_a;
	old_b = new_b;
	old_left = new_left;
	old_right = new_right;
	old_up = new_up;
	old_down = new_down;
	old_power = new_power;
	new_a = iState & 1;
	new_b = iState & 2;
	new_left = iState & 4;
	new_right = iState & 8;
	new_up = iState & 16;
	new_down = iState & 32;
	new_power = iState & 64;

	return true;
}

#pragma endregion

#pragma region LQP_Methods

int pgm_read_byte(int address);

int countAmountActiveSurvivors()
{
	int id;
	int countAmount = 0;
	for (id = 0; id < SURVIVOR_MAX; id++)
	{
		if (survivors[id].active) countAmount++;
	}
	return countAmount;
};
#pragma endregion 

#pragma region Game_LoadState


void load_state_superb(Texture2D tex)
{
	deltaTimeBuffer = load_float(tex, SINGLE_Superb_deltaTimeBuffer);
	new_a = load_val(tex, SINGLE_Superb_new_a);
	new_b = load_val(tex, SINGLE_Superb_new_b);
	new_up = load_val(tex, SINGLE_Superb_new_up);
	new_left = load_val(tex, SINGLE_Superb_new_left);
	new_down = load_val(tex, SINGLE_Superb_new_down);
	new_right = load_val(tex, SINGLE_Superb_new_right);
	old_a = load_val(tex, SINGLE_Superb_old_a);
	old_b = load_val(tex, SINGLE_Superb_old_b);
	old_up = load_val(tex, SINGLE_Superb_old_up);
	old_left = load_val(tex, SINGLE_Superb_old_left);
	old_down = load_val(tex, SINGLE_Superb_old_down);
	old_right = load_val(tex, SINGLE_Superb_old_right);
	new_power = load_val(tex, SINGLE_Superb_new_power);
	old_power = load_val(tex, SINGLE_Superb_old_power);
	frameNumber = load_val(tex, SINGLE_Superb_frameNumber);
}

void load_state(Texture2D tex)
{
    // Load all memory values.
	int id1, id2, id3, id4, id5, id6;

	deltaTimeBuffer = load_float(tex, SINGLE_Superb_deltaTimeBuffer);
	new_a = load_val(tex, SINGLE_Superb_new_a);
	new_b = load_val(tex, SINGLE_Superb_new_b);
	new_up = load_val(tex, SINGLE_Superb_new_up);
	new_left = load_val(tex, SINGLE_Superb_new_left);
	new_down = load_val(tex, SINGLE_Superb_new_down);
	new_right = load_val(tex, SINGLE_Superb_new_right);
	old_a = load_val(tex, SINGLE_Superb_old_a);
	old_b = load_val(tex, SINGLE_Superb_old_b);
	old_up = load_val(tex, SINGLE_Superb_old_up);
	old_left = load_val(tex, SINGLE_Superb_old_left);
	old_down = load_val(tex, SINGLE_Superb_old_down);
	old_right = load_val(tex, SINGLE_Superb_old_right);	
	new_power = load_val(tex, SINGLE_Superb_new_power);	
	old_power = load_val(tex, SINGLE_Superb_old_power);	
	frameNumber = load_val(tex, SINGLE_Superb_frameNumber);

	sharedState.gameID = load_val(tex, SINGLE_SharedState_gameID);
	sharedState.gameState = load_val(tex, SINGLE_SharedState_gameState);
	sharedState.gameType = load_val(tex, SINGLE_SharedState_gameType);
	sharedState.globalCounter = load_val(tex, SINGLE_SharedState_globalCounter);
	sharedState.slideCounter = load_val(tex, SINGLE_SharedState_slideCounter);
	sharedState.menuSelection = load_val(tex, SINGLE_SharedState_menuSelection);
	sharedState.level = load_val(tex, SINGLE_SharedState_level);
	sharedState.pickupsCounter = load_val(tex, SINGLE_SharedState_pickupsCounter);
	sharedState.gameSubState = load_val(tex, SINGLE_SharedState_gameSubState);
	sharedState.displayLevel = load_val(tex, SINGLE_SharedState_displayLevel);
	sharedState.bonusVisible = load_val(tex, SINGLE_SharedState_bonusVisible);
	sharedState.nextLevelVisible = load_val(tex, SINGLE_SharedState_nextLevelVisible);
	sharedState.pressKeyVisible = load_val(tex, SINGLE_SharedState_pressKeyVisible);
	sharedState.leftX = load_val(tex, SINGLE_SharedState_leftX);
	sharedState.rightX = load_val(tex, SINGLE_SharedState_rightX);
	sharedState.mapPosition.x = load_val(tex, SINGLE_SharedState_mapPosition_x);
	sharedState.mapPosition.y = load_val(tex, SINGLE_SharedState_mapPosition_y);
	sharedState.survivorFrame = load_val(tex, SINGLE_SharedState_survivorFrame);
	sharedState.showHelp = load_val(tex, SINGLE_SharedState_showHelp);
	sharedState.amountActiveSurvivors = load_val(tex, SINGLE_SharedState_amountActiveSurvivors);
	sharedState.frameCounter = load_val(tex, SINGLE_SharedState_frameCounter);
	randomNext = load_val(tex, SINGLE_randomNext);

	coolGirl.position.x = load_val(tex, SINGLE_Player_position_x);
	coolGirl.position.y = load_val(tex, SINGLE_Player_position_y);
	coolGirl.score = load_val(tex, SINGLE_Player_score);
	coolGirl.rollingScore = load_val(tex, SINGLE_Player_rollingScore);
	coolGirl.walking = load_val(tex, SINGLE_Player_walking);
	coolGirl.direction = load_val(tex, SINGLE_Player_direction);
	coolGirl.frame = load_val(tex, SINGLE_Player_frame);
	coolGirl.shotDelay = load_val(tex, SINGLE_Player_shotDelay);
	coolGirl.health = load_val(tex, SINGLE_Player_health);
	coolGirl.flashTime = load_val(tex, SINGLE_Player_flashTime);
	coolGirl.camDirection = load_val(tex, SINGLE_Player_camDirection);
	coolGirl.diagonalTime = load_val(tex, SINGLE_Player_diagonalTime);
	coolGirl.coolDownVisible = load_val(tex, SINGLE_Player_coolDownVisible);
	coolGirl.overHeated = load_val(tex, SINGLE_Player_overHeated);
	coolGirl.coolDownCounter = load_val(tex, SINGLE_Player_coolDownCounter);

	exitDoor.position.x = load_val(tex, SINGLE_Door_position_x);
	exitDoor.position.y = load_val(tex, SINGLE_Door_position_y);
	exitDoor.active = load_val(tex, SINGLE_Door_active);
	exitDoor.orientation = load_val(tex, SINGLE_Door_orientation);
	exitDoor.frame = load_val(tex, SINGLE_Door_frame);
	exitDoor.counter = load_val(tex, SINGLE_Door_counter);
	exitDoor.loseLifeCounter = load_val(tex, SINGLE_Door_loseLifeCounter);
	
	for (id1 = 0; id1 < ZOMBIE_MAX; ++id1)
	{
		zombies[id1].position.x = load_val(tex, int2(id1, ROW_ENEMY_POSITION_X));
		zombies[id1].position.y = load_val(tex, int2(id1, ROW_ENEMY_POSITION_Y));
		zombies[id1].frame = load_val(tex, int2(id1, ROW_ENEMY_FRAME));
		zombies[id1].direction = load_val(tex, int2(id1, ROW_ENEMY_DIRECTION));
		zombies[id1].health = load_val(tex, int2(id1, ROW_ENEMY_HEALTH));
		zombies[id1].active = load_val(tex, int2(id1, ROW_ENEMY_ACTIVE));
		zombies[id1].flashTime = load_val(tex, int2(id1, ROW_ENEMY_FLASHTIME));
		zombies[id1].type = load_val(tex, int2(id1, ROW_ENEMY_TYPE));
	}
	
	for (id2 = 0; id2 < BULLET_MAX; ++id2)
	{
		bullets[id2].position.x = load_val(tex, int2(id2, ROW_BULLET_POSITION_X));
		bullets[id2].position.y = load_val(tex, int2(id2, ROW_BULLET_POSITION_Y));
		bullets[id2].active = load_val(tex, int2(id2, ROW_BULLET_ACTIVE)) ? true : false;
		bullets[id2].velocity.x = load_val(tex, int2(id2, ROW_BULLET_VELOCITY_X));
		bullets[id2].velocity.y = load_val(tex, int2(id2, ROW_BULLET_VELOCITY_Y));
	}
	
	for (id3 = 0; id3 < SURVIVOR_MAX; ++id3)
	{
		survivors[id3].position.x = load_val(tex, int2(id3, ROW_ELEMENT_POSITION_X));
		survivors[id3].position.y = load_val(tex, int2(id3, ROW_ELEMENT_POSITION_Y));
		survivors[id3].active = load_val(tex, int2(id3, ROW_ELEMENT_ACTIVE));
	}
	
	for (id4 = 0; id4 < PICKUP_MAX; ++id4)
	{
		pickups[id4].position.x = load_val(tex, int2(id4, ROW_PICKUP_POSITION_X));
		pickups[id4].position.y = load_val(tex, int2(id4, ROW_PICKUP_POSITION_Y));
		pickups[id4].type = load_val(tex, int2(id4, ROW_PICKUP_TYPE));
		pickups[id4].frame = load_val(tex, int2(id4, ROW_PICKUP_FRAME));
		pickups[id4].counter = load_val(tex, int2(id4, ROW_PICKUP_COUNTER));
		pickups[id4].isVisible = load_val(tex, int2(id4, ROW_PICKUP_ISVISIBLE));
	}

	for (id5 = 0; id5 < INPUT_HISTORY_MAX; ++id5)
	{
		inputhistory[id5] = load_float(tex, int2(id5, ROW_INPUT_HISTORY));
		framehistory[id5] = load_float(tex, int2(id5, ROW_FRAME_HISTORY));
	}

	for (id6 = 0; id6 < INPUT_FUTURE_MAX; ++id6)
	{
		inputfuture[id6] = load_float(tex, int2(id6, ROW_INPUT_FUTURE));
		framefuture[id6] = load_float(tex, int2(id6, ROW_FRAME_FUTURE));
	}
}
#pragma endregion 

#pragma region Game_SaveState
float4 save_Single(int x)
{
    switch (x)
    {
	case 0: return pack_it(deltaTimeBuffer);
    case 32: return SAVE_BOOL(new_a);
    case 33: return SAVE_BOOL(new_b);
    case 34: return SAVE_BOOL(new_up);
    case 35: return SAVE_BOOL(new_left);
    case 36: return SAVE_BOOL(new_down);
    case 37: return SAVE_BOOL(new_right);
    case 38: return SAVE_BOOL(old_a);
    case 39: return SAVE_BOOL(old_b);
    case 40: return SAVE_BOOL(old_up);
    case 41: return SAVE_BOOL(old_left);
    case 42: return SAVE_BOOL(old_down);
    case 43: return SAVE_BOOL(old_right);
    case 44: return SAVE_BOOL(new_power);
    case 45: return SAVE_BOOL(old_power);
    case 46: return pack_it(frameNumber);
    
    default: return nullFloat4;
    }
}
float4 save_Single_LQP(int x)
{
    switch (x)
    {
    // SharedState
    case 12: return pack_it(sharedState.gameID);
    case 13: return pack_it(sharedState.gameState);
    case 14: return pack_it(sharedState.gameType);
    case 15: return pack_it(sharedState.globalCounter);
    case 16: return pack_it(sharedState.slideCounter);
    case 17: return pack_it(sharedState.menuSelection);
    case 18: return pack_it(sharedState.level);
    case 19: return pack_it(sharedState.pickupsCounter);
    case 20: return pack_it(sharedState.gameSubState);
    case 21: return pack_it(sharedState.displayLevel);
    case 22: return SAVE_BOOL(sharedState.bonusVisible);
    case 23: return SAVE_BOOL(sharedState.nextLevelVisible);
    case 24: return SAVE_BOOL(sharedState.pressKeyVisible);
    case 25: return pack_it(sharedState.leftX);
    case 26: return pack_it(sharedState.rightX);
    case 27: return pack_it(sharedState.mapPosition.x);
    case 28: return pack_it(sharedState.mapPosition.y);
    case 29: return pack_it(sharedState.survivorFrame);
    case 30: return SAVE_BOOL(sharedState.showHelp);
    case 31: return pack_it(sharedState.amountActiveSurvivors);
    case 32: return pack_it(sharedState.frameCounter);
    case 33: return pack_it(randomNext);

    case 40: return pack_it(coolGirl.position.x);
    case 41: return pack_it(coolGirl.position.y);
    case 42: return pack_it(coolGirl.score);
    case 43: return pack_it(coolGirl.rollingScore);
    case 44: return SAVE_BOOL(coolGirl.walking);
    case 45: return pack_it(coolGirl.direction);
    case 46: return pack_it(coolGirl.frame);
    case 47: return pack_it(coolGirl.shotDelay);
    case 48: return pack_it(coolGirl.health);
    case 49: return pack_it(coolGirl.flashTime);
    case 50: return pack_it(coolGirl.camDirection);
    case 51: return pack_it(coolGirl.diagonalTime);
    case 52: return SAVE_BOOL(coolGirl.coolDownVisible);
    case 53: return SAVE_BOOL(coolGirl.overHeated);
    case 54: return pack_it(coolGirl.coolDownCounter);
    	
    case 60: return pack_it(exitDoor.position.x);
    case 61: return pack_it(exitDoor.position.y);
    case 62: return pack_it(exitDoor.active);
    case 63: return pack_it(exitDoor.orientation);
    case 64: return pack_it(exitDoor.frame);
    case 65: return pack_it(exitDoor.counter);
    case 66: return pack_it(exitDoor.loseLifeCounter);
    
    default: return nullFloat4;
    }
}

#define MAXER(id, maxval, okayval) (((id) < (maxval)) ? pack_it(okayval) : nullFloat4)
#define MAXER_BOOL(id, maxval, okayval) (((id) < (maxval)) ? SAVE_BOOL(okayval) : nullFloat4)

float4 save_state_superb(int x, int y)
{
	switch (y)
	{
		case ROW_SINGLE: return save_Single(x);
		default: return nullFloat4;
	}
}


float4 save_state(int x, int y)
{
    switch (y)
    {
	case ROW_SINGLE: return save_Single(x);
    case ROW_SINGLE_LQP: return save_Single_LQP(x);
    	
    case ROW_BULLET_POSITION_X: return MAXER(x, BULLET_MAX, bullets[x].position.x);
    case ROW_BULLET_POSITION_Y: return MAXER(x, BULLET_MAX, bullets[x].position.y);
    case ROW_BULLET_VELOCITY_X: return MAXER(x, BULLET_MAX, bullets[x].velocity.x);
    case ROW_BULLET_VELOCITY_Y: return MAXER(x, BULLET_MAX, bullets[x].velocity.y);
    case ROW_BULLET_ACTIVE: return MAXER_BOOL(x, BULLET_MAX, bullets[x].active);
    case ROW_PICKUP_POSITION_X: return MAXER(x, PICKUP_MAX, pickups[x].position.x);
    case ROW_PICKUP_POSITION_Y: return  MAXER(x, PICKUP_MAX, pickups[x].position.y);
    case ROW_PICKUP_TYPE: return MAXER(x, PICKUP_MAX, pickups[x].type);
    case ROW_PICKUP_FRAME: return MAXER(x, PICKUP_MAX, pickups[x].frame);
    case ROW_PICKUP_COUNTER: return MAXER(x, PICKUP_MAX, pickups[x].counter);
    case ROW_PICKUP_ISVISIBLE: return MAXER_BOOL(x, PICKUP_MAX, pickups[x].isVisible);
    case ROW_ELEMENT_POSITION_X: return MAXER(x, SURVIVOR_MAX, survivors[x].position.x);
    case ROW_ELEMENT_POSITION_Y: return MAXER(x, SURVIVOR_MAX, survivors[x].position.y);
    case ROW_ELEMENT_ACTIVE: return MAXER_BOOL(x, SURVIVOR_MAX, survivors[x].active);
    case ROW_ENEMY_POSITION_X: return MAXER(x, ZOMBIE_MAX, zombies[x].position.x);
    case ROW_ENEMY_POSITION_Y: return MAXER(x, ZOMBIE_MAX, zombies[x].position.y);
    case ROW_ENEMY_FRAME: return MAXER(x, ZOMBIE_MAX, zombies[x].frame);
    case ROW_ENEMY_DIRECTION: return MAXER(x, ZOMBIE_MAX, zombies[x].direction);
    case ROW_ENEMY_HEALTH: return MAXER(x, ZOMBIE_MAX, zombies[x].health);
    case ROW_ENEMY_ACTIVE: return MAXER(x, ZOMBIE_MAX, zombies[x].active);
    case ROW_ENEMY_FLASHTIME: return MAXER(x, ZOMBIE_MAX, zombies[x].flashTime);
    case ROW_ENEMY_TYPE: return MAXER(x, ZOMBIE_MAX, zombies[x].type);
	case ROW_INPUT_HISTORY: return MAXER(x, INPUT_HISTORY_MAX, inputhistory[x]);
	case ROW_FRAME_HISTORY: return MAXER(x, INPUT_HISTORY_MAX, framehistory[x]);
	case ROW_INPUT_FUTURE: return MAXER(x, INPUT_FUTURE_MAX, inputfuture[x]);
	case ROW_FRAME_FUTURE: return MAXER(x, INPUT_FUTURE_MAX, framefuture[x]);

    default: return nullFloat4;
    }
}
#pragma endregion

#endif

