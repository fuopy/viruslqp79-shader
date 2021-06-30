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

#pragma region LQP_ForwardDeclares
void mapCollide(inout int x, inout int y, bool horizontal, inout int vel, int w, int h);
void checkPause();
#pragma endregion 

#pragma region LQP_Player

/// \brief sets the default values for player
void Player::initialize()
{
	score = 0;
	rollingScore = 0;
	
	direction = PLAYER_FACING_SOUTH;
	health = PLAYER_START_HEALTH;
	flashTime = 0;
	shotDelay = 10;
	coolDownVisible = true;
	overHeated = false;
	coolDownCounter = 0;
}

/// \brief updates the player according to game rules
void Player::update()
{
	if (coolDownCounter > WEAPON_OVERHEAT) overHeated = true;
	// Input velocity
	int2 velocity = {0, 0};

	int id;
	int2 tileMax = {0, 0};
	int inputDirection = direction;

	///////////
	// input //
	///////////

	bool left = LEFT_DOWN;
	bool right = RIGHT_DOWN;
	bool up = UP_DOWN;
	bool down = DOWN_DOWN;

	bool rungun = A_DOWN;
	bool standgun = B_DOWN;
	bool strafegun = rungun;

	walking = up || down || left || right;
	//obj.walking = (standgun && !rungun) ? false : obj.walking;

	////////////
	// timers //
	////////////

	// Diagonal anti-jerk timer
	if (diagonalTime > 0)
		diagonalTime--;
	if ((up && left) || (down && left) || (up && right) || (down && right))
		diagonalTime = 4;

	// Bullet timer
	if (shotDelay > 0) shotDelay--;

	////////////////////////
	// horizontal physics //
	////////////////////////

	// input
	if (left)
		velocity.x = -1;
	else if (right)
		velocity.x = 1;

	// update position
	//if(strafegun || !standgun)
	position.x += velocity.x;

	// collide with zombies
	Enemy::updateCollision(position, logic_player_size, true, velocity.x);

	// collide with walls
	mapCollide(position.x, position.y, true, velocity.x, logic_player_size.x, logic_player_size.y);

	//////////////////////
	// vertical physics //
	//////////////////////

	// input
	if (up)
		velocity.y = -1;
	else if(down)
		velocity.y = 1;

	// update position
	//if(strafegun || !standgun)
	position.y += velocity.y;

	// collide with zombies
	Enemy::updateCollision(position, logic_player_size, false, velocity.y);

	// collide with walls
	mapCollide(position.x, position.y, false, velocity.y, logic_player_size.x, logic_player_size.y);

	// collide with survivors
	Element::updateCollision(position, logic_player_size);

	// collide with door
	if (exitDoor.checkCollision(position, logic_player_size)) sharedState.gameState = STATE_GAME_PREPARE_LEVEL;

	// collide with pickup
	Pickup::updateCollision(position, logic_player_size);

	///////////////
	// direction //
	///////////////

	// Update camera direction according to the way the player is moving

	if (!strafegun)
	{
		if (left)
		{
			inputDirection = PLAYER_FACING_WEST;
			if (up) inputDirection = PLAYER_FACING_NORTHWEST;
			else if (down) inputDirection = PLAYER_FACING_SOUTHWEST;
		}
		else if (right)
		{
			inputDirection = PLAYER_FACING_EAST;
			if (up) inputDirection = PLAYER_FACING_NORTHEAST;
			else if (down) inputDirection = PLAYER_FACING_SOUTHEAST;
		}
		else if (up)
		{
			inputDirection = PLAYER_FACING_NORTH;
		}
		else if (down)
		{
			inputDirection = PLAYER_FACING_SOUTH;
		}
	}

	direction = inputDirection;

	// the camera will only be updated if moving nondiagonally or look mode
	if ((standgun && !rungun) || (direction % 2) == 0)
	{
		camDirection = inputDirection;
	}

	////////////
	// timers //
	////////////
	if (everyXFrames(4))
	{
		if (coolDownCounter > 1) coolDownCounter--;
		if ((A_DOWN || B_DOWN) && !overHeated) coolDownCounter += 2;
		if (overHeated) coolDownVisible = !coolDownVisible;
	}

	if ((standgun || rungun) && !overHeated)
	{
		if (shotDelay == 0)
		{
			Bullet::add(int2(position.x + 10, position.y + 12), int2(0, 0), direction);
			shotDelay = 10;
		}
	}

	if ((overHeated == true) && (coolDownCounter < 2))
	{
		overHeated = false;
		coolDownVisible = true;
	}

	// Update animation
	if (everyXFrames(6) && walking) frame++;
	if (frame > 3) frame = 0;

	// update score
	if (rollingScore > 0)
	{
		rollingScore -= 5;
		score += 5;
	}

	// update flashing
	if (flashTime > 0)
		flashTime--;

	////////////
	// camera //
	////////////

	// update camera
	int2 mapGoalPosition = {position.x - screen_size.x / 2 + logic_player_size.x / 2,
	position.y - screen_size.y / 2 + logic_player_size.y / 2 - 4}; // hud offset

	// offset the goal by the direction
	mapGoalPosition.x += BulletXVelocities[coolGirl.camDirection] * 4;
	mapGoalPosition.y += BulletXVelocities[(coolGirl.camDirection + 6) % 8] * 4;

	// move the camera toward the desired location
	sharedState.mapPosition.x = burp(sharedState.mapPosition.x, mapGoalPosition.x, 3);
	sharedState.mapPosition.y = burp(sharedState.mapPosition.y, mapGoalPosition.y, 3);

	// Clamp on screen boundaries
	sharedState.mapPosition.x = (sharedState.mapPosition.x < 0) ? 0 : sharedState.mapPosition.x;
	sharedState.mapPosition.x = (sharedState.mapPosition.x > logic_level_size.x - screen_size.x) ? logic_level_size.x - screen_size.x : sharedState.mapPosition.x;
	sharedState.mapPosition.y = (sharedState.mapPosition.y < 0) ? 0 : sharedState.mapPosition.y;
	sharedState.mapPosition.y = (sharedState.mapPosition.y > logic_level_size.y - screen_size.y) ? logic_level_size.y - screen_size.y : sharedState.mapPosition.y;
}

/// \brief make player take damage
void Player::healthOffset(int amount)
{
	if (flashTime == 0)
	{
		health += amount;

		if (amount < 0)
		{
			flashTime = PLAYER_FLASH_TIME;
			tone(880, 20);
		}

		if (health > PLAYER_MAXHEALTH)
		{
			health = PLAYER_MAXHEALTH;
		}
		else if (health == 0)
		{
			sharedState.gameState = STATE_GAME_OVER;
		}
	}
}
#pragma endregion 

#pragma region LQP_Bullet

/// \brief sets the position and the velocity of a bullet
bool Bullet::set(int2 _position, int2 _velocity)
{
	if (!active)
	{
		position = _position;
		velocity = _velocity;
		active = true;
		return true;
	}
	return false;
}

/// \brief searches the bullet list for an empty slot, adds one if available
static void Bullet::add(int2 _position, int2 _velocity, int direction)
{
	for (int id = 0; id < BULLET_MAX; id++)
	{
		//if (bullets[id].set(int2(16, 16), int2(0, 1)))
		if (bullets[id].set(
			_position - logic_bullet_size/2,
			int2(_velocity.x + BulletXVelocities[direction], _velocity.y + BulletXVelocities[(direction + 6) % 8])))
		{
			tone(440, 20);
			break;
		}
	}
}

/// \brief updates a bullet according to the game rules
void Bullet::update()
{
	bool done;
	
	//if (true) return;
	if (active)
	{
		// Update horizontal and vertical simultaneously.
		position += velocity;

		// collide with zombies
		for (int id = 0; id < ZOMBIE_MAX; id++)
		{
			if (!done)
			{
				if (zombies[id].checkCollision(position, logic_bullet_size))
				{
					active = false;
					zombies[id].healthOffset(-1);
				
					// For some reason, having a 'break' statement here crashes the HLSL compiler in Unity 2018.4.20f1
					// If this ever gets fixed, uncomment this break statement. For now, we'll use a temporary "done"
					// variable instead. Remove the done variable once it's possible to.
					done = true;
					//break;
				}
			}
		}

		if (Level::getTileType(int2(position.x / tile_size.x, position.y / tile_size.y)) > 10)
		{
			active = false;
		}

		// delete if gone off screen
		if ((position.x < sharedState.mapPosition.x) ||
			(position.y < sharedState.mapPosition.y) ||
			(position.x > game_size.x + sharedState.mapPosition.x) ||
			(position.y > game_size.y + sharedState.mapPosition.y))
		{
			active = false;
		}
	}
}

/// \brief updates the entire list of bullets
static void Bullet::updateAll()
{
	for (int id = 0; id < BULLET_MAX; ++id)
	{
		bullets[id].update();
	}
}

/// \brief clears the entire list of bullets
static void Bullet::clearAll()
{
	for (int id = 0; id < BULLET_MAX; ++id)
	{
		bullets[id].active = false;
	}
}

#pragma endregion

#pragma region LQP_Level

void mapCollide(inout int x, inout int y, bool horizontal, inout int vel, int w, int h)
{
	int2 tileMax = {
		(x % tile_size.x) != 0 ? 1 : 0,
		(y % tile_size.y) != 0 ? 1 : 0
	};
	
	int2 tile = {0, 0};
	for (tile.x = x / tile_size.x; tile.x < x / tile_size.x + 2 + tileMax.x; tile.x++)
	{
		for (tile.y = y / tile_size.y; tile.y < y / tile_size.y + 2 + tileMax.y; tile.y++)
		{
			if (Level::getTileType(int2(tile.x, tile.y)) > 10)
			{
				if (horizontal)
				{
					if (vel < 0)
						x = tile.x * tile_size.x + tile_size.x;
					else if (vel > 0)
						x = tile.x * tile_size.x - w;
				}
				else
				{
					if (vel < 0)
						y = tile.y * tile_size.y + tile_size.y;
					else if (vel > 0)
						y = tile.y * tile_size.y - h;
				}
				vel = 0;
			}
		}
	}
}

#pragma endregion 

#pragma region LQP_Door

int Door::getOrientation()
{
	if (position.y == EXIT_ON_SOUTH_BORDER) return EXIT_FACING_SOUTH;
	if (position.x == EXIT_ON_WEST_BORDER) return EXIT_FACING_WEST;
	if (position.y == EXIT_ON_NORTH_BORDER) return EXIT_FACING_NORTH;
	if (position.x == EXIT_ON_EAST_BORDER) return EXIT_FACING_EAST;
	return 0; // Default.
}

void Door::setPosition(int2 _position)
{
	position = _position;
	orientation = getOrientation();
	active = false;
	counter = 255;
	loseLifeCounter = 255;
}

bool Door::checkCollision(int2 _position, int2 _size)
{
	return
		(active) &&
		(position.x < _position.x + _size.x) &&
		(position.x + _size.x > _position.x) &&
		(position.y < _position.y + _size.y) &&
		(position.y + _size.y > _position.y);
}

void Door::update()
{
	if (active)
	{
		if ((!counter) && (loseLifeCounter > 0))
		{
			loseLifeCounter--;
		}
		if (loseLifeCounter < 1)
		{
			coolGirl.healthOffset(-1);
			loseLifeCounter = 255;
		}
		if (everyXFrames(10))
		{
			frame++;
			if (counter > 0)
			{
				counter--;
			}
		}
		if (counter == 1) coolGirl.healthOffset(-1);
		if (frame > 3)
		{
			frame = 0;
		}
	}
}

#pragma endregion 

#pragma region LQP_Elements

/// \brief searches the survivor list for an empty slot, adds one if available
static void Element::swapSurvivorPool()
{
	for (int i = 0; i < 5; i++)
	{
		int k = random(5);
		int temp = survivorType[i];
		survivorType[i] = survivorType[k];
		survivorType[k] = temp;
	}
}

/// \brief updates the survivor states
static void Element::updateAll()
{
	// advance the frame
	if (everyXFrames(SURVIVOR_FRAME_SKIP)) sharedState.survivorFrame++;

	// clamp to 4 frames
	if (sharedState.survivorFrame >= SURVIVOR_FRAME_COUNT) sharedState.survivorFrame = 0;

	// Alternate showing the "Help!" speech bubble every now and again.
	if (everyXFrames(30)) sharedState.showHelp = !sharedState.showHelp;
}

/// \brief takes a survivor, collision box to test against returns true if collision boxes intersect
bool Element::checkCollision(int2 _position, int2 _size)
{
	return
		(active) &&
		(position.x < _position.x + _size.x) &&
		(position.x + _size.x > _position.x) &&
		(position.y < _position.y + _size.y) &&
		(position.y + _size.y > _position.y);
}

/// \brief takes a survivor, sets it inactive. returns false if no survivors are left on the map, otherwise true
bool Element::collect()
{
	active = false;
	tone(660, 20);
	coolGirl.rollingScore += 500;

	for (int id = 0; id < SURVIVOR_MAX; id++)
	{
		if (survivors[id].active)
			return false;
	}

	return true;
}

/// \brief clears the entire list of survivors
static void Element::clearAll()
{
	for (int id = 0; id < SURVIVOR_MAX; id++)
	{
		survivors[id].active = false;
	}
}

static void Element::updateCollision(int2 _position, int2 _size)
{
	for (int id = 0; id < SURVIVOR_MAX; id++)
	{
		if (survivors[id].checkCollision(_position, _size))
		{
			if (survivors[id].collect())
			{
				exitDoor.active = true;
			}
		}
	}
}

#pragma endregion 

#pragma region LQP_Pickup

/// \brief tries to add a pickup to the world. returns true if succsessful
static bool Pickup::add(int2 _position)
{
	for (int id = 0; id < PICKUP_MAX; id++)
	{
		if (!pickups[id].type)
		{
			pickups[id].isVisible = true;
			pickups[id].counter = 0;
			pickups[id].position = _position;
			pickups[id].type = pickupsAvailable[sharedState.pickupsCounter];
			sharedState.pickupsCounter++;
			if (sharedState.pickupsCounter > 9) sharedState.pickupsCounter = 0;
			return true;
		}
	}
	return false;
}

void Pickup::update()
{
	if (everyXFrames(6))
	{
		counter++;
		frame++;
	}
	if ((everyXFrames(2)) && (counter > 25)) isVisible = !isVisible;
	if (counter > 30) type = PICKUP_TYPE_INACTIVE;
	if (frame > 5) frame = 0;

}

static void Pickup::updateAll()
{
	int id;
	for (id = 0; id < PICKUP_MAX; ++id)
	{
		pickups[id].update();
	}
}

/// \brief checks for collision against the player, and handles it
static void Pickup::updateCollision(int2 _position, int2 _size)
{
	for (int id = 0; id < PICKUP_MAX; id++)
	{
		if (
			(pickups[id].type) &&
			(pickups[id].position.x < _position.x + _size.x) &&
			(pickups[id].position.x + _size.x > _position.x) &&
			(pickups[id].position.y < _position.y + _size.y) &&
			(pickups[id].position.y + _size.y > _position.y))
		{
			if (pickups[id].type == PICKUP_TYPE_HEART)
			{
				tone(660, 20);
				coolGirl.healthOffset(2);
			}
			else
			{
				tone(880, 20);
				coolGirl.rollingScore += 100;
			}
			pickups[id].type = PICKUP_TYPE_INACTIVE;
		}
	}
}

/// \brief clears the entire list of pickups
static void Pickup::clearAll()
{
	for (int id = 0; id < PICKUP_MAX; id++)
	{
		pickups[id].type = PICKUP_TYPE_INACTIVE;
	}
}

#pragma endregion 

#pragma region LQP_Zombie

/// \brief sets the position of a zombie, and enables that instance
void Enemy::set(int2 _position, int _type)
{
	frame = 0;
	active = true;
	direction = ENEMY_FACING_WEST;
	position = _position;
	type = _type;
	if (type) health = 2;
	else health = 3;
	flashTime = 0;
}

/// \brief adds a zombie in a random place in the map returns true if success, false if failure
static bool Enemy::spawn()
{
	int2 position = {
		random(16, logic_level_size.x - logic_zombie_size.x - 16),
		random(16, logic_level_size.y - logic_zombie_size.y - 16)
	};

	if ((position.x < coolGirl.position.x - game_size.x)
		|| (position.x > coolGirl.position.x + game_size.x)
		|| (position.y < coolGirl.position.y - game_size.y)
		|| (position.y > coolGirl.position.y + game_size.y))
	{
		return add(position);
	}

	return false;
}

/// \brief searches the zombies list for an empty slot, adds one if available returns true if successful, false otherwise
static bool Enemy::add(int2 _position)
{
	for (int id = 0; id < ZOMBIE_MAX; id++)
	{
		if (!zombies[id].active)
		{
			zombies[id].set(_position, random(0, 1));
			return true;
		}
	}
	return false;
}

/// \brief updates the zombie according to game rules zombies are "removed" (set inactive) when health reaches zero
void Enemy::update()
{
	if (active)
	{
		if (flashTime > 0)
		{
			flashTime--;
		}
		int2 velocity = { 0, 0 };

		//if (true) return;

		if (everyXFrames(ZOMBIE_STEP_DELAY))
		{
			///////////
			// input //
			///////////

			// chase player
			if (position.x < coolGirl.position.x) velocity.x = ZOMBIE_SPEED;
			if (position.x > coolGirl.position.x) velocity.x = -ZOMBIE_SPEED;

			if (position.y < coolGirl.position.y) velocity.y = ZOMBIE_SPEED;
			if (position.y > coolGirl.position.y) velocity.y = -ZOMBIE_SPEED;

			// if out of bounds, delete this
			if ((position.x < 0) || (position.y < 0) || (position.x >= logic_level_size.x) || (position.y >= logic_level_size.y))
			{
				active = false;
				return;
			}

			// update orientation
			if (velocity.x < 0)
				direction = ENEMY_FACING_WEST;
			else if (velocity.x > 0)
				direction = ENEMY_FACING_EAST;

			////////////////////////
			// horizontal physics //
			////////////////////////

			// update position
			position.x += velocity.x;

			// collide with other zombies

			updateCollision(position, logic_zombie_size, true, velocity.x);

			// collide with player
			if (checkCollision(coolGirl.position, logic_player_size))
			{
				if (velocity.x > 0)
					position.x = coolGirl.position.x - logic_zombie_size.x;
				else if (velocity.x < 0)
					position.x = coolGirl.position.x + logic_player_size.x;

				coolGirl.healthOffset(-1);
				velocity.x = 0;
			}

			// collide with walls
			mapCollide(position.x, position.y, true, velocity.x, logic_zombie_size.x, logic_zombie_size.y);

			//////////////////////
			// vertical physics //
			//////////////////////

			// update position
			position.y += velocity.y;

			// collide with other zombies
			updateCollision(position, logic_zombie_size, false, velocity.y);

			// collide with player
			if (checkCollision(coolGirl.position, logic_player_size))
			{
				if (velocity.y > 0)
					position.y = coolGirl.position.y - logic_zombie_size.y;
				else if (velocity.y < 0)
					position.y = coolGirl.position.y + logic_player_size.y;

				coolGirl.healthOffset(-1);
				velocity.y = 0;
			}

			// collide with walls
			mapCollide(position.x, position.y, false, velocity.y, logic_zombie_size.x, logic_zombie_size.y);

			///////////////
			// animation //
			///////////////

			if (velocity.x || velocity.y)
			{
				// Advance animation frame
				if (everyXFrames(ZOMBIE_FRAME_SKIP)) frame++;

				// Just 4 frames
				if (frame >= ZOMBIE_FRAME_COUNT) frame = 0;
			}
			else
			{
				frame = 0;
			}
		}

		if (health == 0)
		{
			active = false;
		}
	}
	else
	{
		if (flashTime > 0)
		{
			flashTime--;
		}
	}
}

/// \brief updates every active zombie in the list
static void Enemy::updateAll()
{
	for (int i = 0; i < ZOMBIE_MAX; i++)
	{
		//if (!zombies[i].active) continue;
		zombies[i].update();
	}
}

/// \brief takes a value to be added to zombie health kills the zombie if health goes below zero
bool Enemy::healthOffset(int amount)
{
	health += amount;

	// killed
	if (health <= 0)
	{
		tone(220, 20);
		flashTime = ZOMBIE_FLASH_TIME;
		active = false;
		coolGirl.rollingScore += 100;
		Pickup::add(position + 4);
		return true;
	}
	else if (amount < 0)
	{
		flashTime = ZOMBIE_FLASH_TIME;
		tone(640, 20);
	}
	return false;
}

/// \brief takes zombie id, collision box to test against returns true if collision boxes intersect
bool Enemy::checkCollision(int2 _position, int2 _size)
{
	return
		(active) &&
		(position.x < _position.x + _size.x) &&
		(position.x + logic_zombie_size.x > _position.x) &&
		(position.y < _position.y + _size.y) &&
		(position.y + logic_zombie_size.y > _position.y);
}

/// \brief clears the entire list of zombies
static void Enemy::clearAll()
{
	for (int id = 0; id < ZOMBIE_MAX; ++id)
	{
		zombies[id].active = false;
	}
}

static void Enemy::updateCollision(inout int2 _position, int2 _size, bool horizontal, inout int vel)
{
	for (int id = 0; id < ZOMBIE_MAX; ++id)
	{
		if (zombies[id].checkCollision(_position, _size))
		{
			if (_position.x == zombies[id].position.x && _position.y == zombies[id].position.y) continue;
			if (horizontal)
			{
				if (vel > 0)
					_position.x = zombies[id].position.x - _size.x;
				else if (vel < 0)
					_position.x = zombies[id].position.x + logic_zombie_size.x;
			}
			else
			{
				if (vel > 0)
					_position.y = zombies[id].position.y - _size.y;
				else if (vel < 0)
					_position.y = zombies[id].position.y + logic_zombie_size.y;
			}
			vel = 0;
		}
	}
}

#pragma endregion 

#pragma region LQP_Game

int2 readSurvivorData(int index)
{

	return survivorLocation[(sharedState.level - 1) * 10 + index] * tile_size.x;
}

int readPlayerAndExitData(int index)
{
	int tempLevel;
	if (sharedState.gameType != STATE_GAME_MAYHEM)
	{
		tempLevel = sharedState.displayLevel;
	}
	else
	{
		tempLevel = sharedState.level;
	}

	return playerAndExitLocation[((tempLevel - 1) * 4 + index)] * tile_size.x;
}

static void LogicSubState::nextLevelStart()
{
	sharedState.leftX = -50;
	sharedState.rightX = 154;
	if ((sharedState.displayLevel == 1) || (sharedState.gameType == STATE_GAME_CONTINUE))
	{
		sharedState.bonusVisible = false;
		sharedState.nextLevelVisible = true;
		sharedState.pressKeyVisible = false;
		sharedState.gameSubState = 4;
	}
	else
	{
		sharedState.bonusVisible = true;
		sharedState.nextLevelVisible = false;
		sharedState.pressKeyVisible = false;
		sharedState.gameSubState++;
	}
}

static void LogicSubState::nextLevelBonusCount()
{
	if (exitDoor.counter > 0)
	{
		exitDoor.counter--;
		coolGirl.score += 5;
	}
	else
	{
		if ((sharedState.displayLevel < 129) || (sharedState.gameType == STATE_GAME_MAYHEM)) sharedState.gameSubState++;
		else
		{
			sharedState.gameState = STATE_GAME_END;
			sharedState.gameSubState = 0;
		}
	}
}

static void LogicSubState::nextLevelWait()
{
	if (everyXFrames(4)) sharedState.globalCounter++;
	if (sharedState.globalCounter > 8)
	{
		sharedState.gameSubState++;
		sharedState.globalCounter = 0;
	}
}

static void LogicSubState::nextLevelSlideToMiddle()
{
	sharedState.bonusVisible = false;
	sharedState.nextLevelVisible = true;
	if (sharedState.leftX < 21)
	{
		sharedState.leftX += 4;
		sharedState.rightX -= 4;
	}
	else sharedState.gameSubState++;
}

static void LogicSubState::nextLevelEnd()
{
	int maxId;
	if (everyXFrames(30)) sharedState.pressKeyVisible = !sharedState.pressKeyVisible;
	if (A_PRESSED || B_PRESSED)
	{
		sharedState.gameState = STATE_GAME_PLAYING;
		sharedState.gameSubState = 0;
		sharedState.bonusVisible = false;
		sharedState.nextLevelVisible = false;
		sharedState.pressKeyVisible = false;
		sharedState.leftX = -50;
		sharedState.rightX = 154;

		coolGirl.position.x = readPlayerAndExitData(0);
		coolGirl.position.y = readPlayerAndExitData(1);
		exitDoor.setPosition(int2(readPlayerAndExitData(2), readPlayerAndExitData(3)));
		Element::swapSurvivorPool();

		// TODO: When Persistence update comes out.
		if (sharedState.gameType != STATE_GAME_MAYHEM)
		{
		// 	EEPROM.write(OFFSET_VLQP_START, gameID);
		// 	EEPROM.put(OFFSET_LEVEL, level - 1);
		// 	EEPROM.put(OFFSET_SCORE, scorePlayer);
		// 	EEPROM.put(OFFSET_HEALTH, coolGirl.health);
		// 	EEPROM.write(OFFSET_VLQP_END, gameID);
			maxId = (((sharedState.displayLevel % TOTAL_LEVEL_AMOUNT) - 1) / NUM_MAPS) + 2;
		}
		else maxId = 5;

		// Read pairs of X, Y from survivor data.
		for (int id = 0; id < maxId; id++)
		{
			//int mapRow = 10 * (sharedState.level - 1) - 1;
			//int mapColumn = (2 * id) - 1;

			int mapRow = 10 * (sharedState.level - 1); // 0
			int mapColumn = (2 * id); // 2

			int2 survivorPosition = {
				survivorLocation[mapRow + mapColumn] * tile_size.x,    // X position
				survivorLocation[mapRow + mapColumn + 1] * tile_size.y // Y position
			};

			survivors[id].position = survivorPosition;
			survivors[id].active = true;
		}
	}
}


/// \brief called each frame the gamestate is set to game over
static void LogicSubState::GameOverEnd()
{
	if (everyXFrames(30)) sharedState.pressKeyVisible = !sharedState.pressKeyVisible;
	if (A_PRESSED || B_PRESSED)
	{
		sharedState.gameState = STATE_MENU_MAIN;
		sharedState.gameSubState = 0;
		sharedState.pressKeyVisible = false;
	}
}

// State machine. No need to be packages as Fn Ptrs.
static void LogicSubState::RunNextLevelSubstate(int stateIndex)
{
	switch (stateIndex)
	{
		case 0: nextLevelStart(); break;
		case 1: nextLevelWait(); break;
		case 2: nextLevelBonusCount(); break;
		case 3: nextLevelWait(); break;
		case 4: nextLevelSlideToMiddle(); break;
		case 5: nextLevelWait(); break;
		case 6: nextLevelEnd(); break;
		
		default: GameOverEnd(); break;
	}
}
static void LogicSubState::RunGameOverSubstate(int stateIndex)
{
	switch (stateIndex)
	{
	case 0: nextLevelWait(); break;
	case 1: nextLevelWait(); break;
	case 2: nextLevelWait(); break;
	case 3: nextLevelWait(); break;
	case 4: GameOverEnd(); break;
		
	default: GameOverEnd(); break;
	}
}

void checkPause()
{
	if (A_DOWN && B_DOWN) sharedState.gameState = STATE_GAME_PAUSE;
}

#pragma endregion 

#pragma region LQP_Menu

void setSlidersToZero()
{
	sharedState.globalCounter = 0;
	sharedState.slideCounter = 0;
}

void makeItSlide()
{
	sharedState.slideCounter++;
	if (sharedState.slideCounter > 22)
	{
		sharedState.globalCounter++;
		sharedState.slideCounter = 22;
	}

	if (sharedState.globalCounter > 5)
	{
		sharedState.globalCounter = 5;
	}
}

#pragma endregion

#pragma region LQP_LogicStates

static void LogicState::MenuHelp()
{
	if (A_PRESSED || B_PRESSED) sharedState.gameState = STATE_MENU_MAIN;
}
static void LogicState::MenuSoundfx()
{
	if (DOWN_PRESSED)
	{
		//audio.on(); // TODO: AUDIO
		sharedState.globalCounter = 0;
	}
	if (UP_PRESSED)
	{
		//audio.off(); // TODO: AUDIO
		sharedState.globalCounter = 0;
	}
	if (A_PRESSED || B_PRESSED)
	{
		setSlidersToZero();
		//audio.saveOnOff();  // TODO: AUDIO
		sharedState.gameState = STATE_MENU_MAIN;
	}

	makeItSlide();
}

static void LogicState::MenuInfo()
{
	if (A_PRESSED || B_PRESSED) sharedState.gameState = STATE_MENU_MAIN;
}

static void LogicState::MenuPlay()
{
	if (DOWN_PRESSED && (sharedState.menuSelection < 4))
	{
		sharedState.menuSelection++;
		sharedState.globalCounter = 0;
	}
	if (UP_PRESSED && (sharedState.menuSelection > 2))
	{
		sharedState.menuSelection--;
		sharedState.globalCounter = 0;
	}
	if (A_PRESSED)
	{
		setSlidersToZero();
		// If "NEW" is selected...
		if (sharedState.menuSelection == 2)
		{
			sharedState.gameState = STATE_GAME_NEW;
			sharedState.gameType = sharedState.gameState;
		}
		// If "CONT" is selected...
		else if (sharedState.menuSelection == 3)
		{
			sharedState.gameState = STATE_GAME_CONTINUE;
			sharedState.gameType = sharedState.gameState;
		}
		// If "HELL" is selected...
		else if (sharedState.menuSelection == 4)
		{
			sharedState.gameState = STATE_GAME_MAYHEM;
			sharedState.gameType = sharedState.gameState;
		}
	}
	else if (B_PRESSED)
	{
		setSlidersToZero();
		sharedState.gameState = STATE_MENU_MAIN;
	}
	makeItSlide();
}

static void LogicState::MenuIntro()
{
	sharedState.globalCounter++;
	if (sharedState.globalCounter > 120)
	{
		sharedState.globalCounter = 0;
		sharedState.gameState = STATE_MENU_MAIN;
	}
}

static void LogicState::MenuMain()
{
	if (DOWN_PRESSED && (sharedState.menuSelection < 5))
	{
		sharedState.menuSelection++;
		sharedState.globalCounter = 0;
	}
	else if (UP_PRESSED && (sharedState.menuSelection > 2))
	{
		sharedState.menuSelection--;
		sharedState.globalCounter = 0;
	}
	if (B_PRESSED)
	{
		sharedState.menuSelection = STATE_MENU_PLAY;
	}
	else if (A_PRESSED || B_PRESSED)
	{
		setSlidersToZero();
		sharedState.gameState = sharedState.menuSelection;
		sharedState.menuSelection = STATE_GAME_NEW - 10; // Why. Why not just have an explicit if statement branch...?
	}
	makeItSlide();
}


/// \brief called each frame the gamestate is set to playing
static void LogicState::GamePlaying()
{
	int id;
	
	// Update Level
	int spawnTime;
	if (sharedState.gameType != STATE_GAME_MAYHEM) spawnTime = 60;
	else spawnTime = 15;
	if (everyXFrames(spawnTime * 3)) {
		Enemy::spawn();
	}

	// Check for Pause
	checkPause();

	// Update Objects
	coolGirl.update();
	Enemy::updateAll();
	Element::updateAll();
	Bullet::updateAll();
	Pickup::updateAll();
	exitDoor.update();
}
static void LogicState::GameNextLevel()
{
	LogicSubState::RunNextLevelSubstate(sharedState.gameSubState);
}


/// \brief called each frame the gamestate is set to next level
static void LogicState::GamePrepareLevel()
{
	Element::clearAll();
	Pickup::clearAll();
	Enemy::clearAll();

	sharedState.level++;

	if (sharedState.gameType != STATE_GAME_MAYHEM) sharedState.level = (sharedState.level - 1) % NUM_MAPS + 1;
	else sharedState.level = random(NUM_MAPS) + 1;
	sharedState.displayLevel++;

	sharedState.pickupsCounter = 0;
	sharedState.gameSubState = 0;
	sharedState.globalCounter = 0;

	sharedState.gameState = STATE_GAME_NEXT_LEVEL;
}

static void LogicState::GameOver()
{
	LogicSubState::RunGameOverSubstate(sharedState.gameSubState);
}

static void LogicState::GameEnd()
{
	LogicSubState::RunGameOverSubstate(sharedState.gameSubState);
}


static void LogicState::GamePause()
{
	if (A_PRESSED || B_PRESSED)
	{
		sharedState.gameState = STATE_GAME_PLAYING;
		//sprites.drawSelfMasked(22, 32, gameOver, 0); // TODO: UH OH!!! Overlap!
	}
}

static void LogicState::GameNew()
{
	sharedState.level = LEVEL_TO_START_WITH - 1;
	sharedState.displayLevel = sharedState.level;
	coolGirl.initialize();
	sharedState.gameState = STATE_GAME_PREPARE_LEVEL;
}

static void LogicState::GameContinue()
{
	// TODO: Add when persistence update comes out.
	// if ((EEPROM.read(OFFSET_VLQP_START) == gameID) && (EEPROM.read(OFFSET_VLQP_END) == gameID))
	// {
	// 	initializePlayer(coolGirl);
	// 	EEPROM.get(OFFSET_LEVEL, level);
	// 	displayLevel = level;
	// 	EEPROM.get(OFFSET_SCORE, scorePlayer);
	// 	EEPROM.get(OFFSET_HEALTH, coolGirl.health);
	//
	// 	gameState = STATE_GAME_PREPARE_LEVEL;
	// }
	// else
	// {
	// 	gameState = STATE_GAME_NEW;
	// }

	// FOR NOW JUST DO THIS:
	sharedState.gameState = STATE_GAME_NEW;
}

static void LogicState::GameMayhem()
{
	sharedState.displayLevel = 0;
	sharedState.gameState = STATE_GAME_PREPARE_LEVEL;
	coolGirl.initialize();
}


#pragma endregion 
