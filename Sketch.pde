int playerX, playerY;
int playerSize = 20;
float playerSpeed = 3.9;

ArrayList<Projectile> projectiles;
ArrayList<Enemy> enemies;

int enemySpawnInterval = 60; // Spawn an enemy every 60 frames
int frameCount = 0;

int score = 0;
int playerHealth = 100; // Player health starts at 100

boolean gameStarted = false; // New variable to track the game state
boolean gameOver = false;
boolean spacePressed = false; // Track if the spacebar is pressed
boolean paused = false; // Track if the game is paused

int ammoCount = 20;
int maxAmmo = 20;
boolean reloading = false;
int reloadTime = 45; // Frames needed to reload
int reloadTimer = 0;

AmmoType currentAmmoType = AmmoType.STANDARD;

// Define available skins and the chosen skin
String[] skins = {"Blue", "Purple", "Green", "Ginger", "Black"};
int chosenSkinIndex = 0;

void setup() {
  size(1000, 800);
  playerX = width / 2;
  playerY = height - 40;
  projectiles = new ArrayList<Projectile>();
  enemies = new ArrayList<Enemy>();
}

void draw() {
  if (!gameStarted) {
    startScreen();
  } else if (paused) {
    pauseScreen();
  } else if (playerHealth > 0) {
    gameScreen();
  } else {
    gameOverScreen();
  }
}

void displayCurrentAmmoType() {
  fill(255);
  textSize(16);
  String ammoTypeString = "";
  switch(currentAmmoType) {
  case STANDARD:
    ammoTypeString = "Standard";
    break;
  case SPREAD:
    ammoTypeString = "Spread";
    break;
  case BOMB:
    ammoTypeString = "Bomb";
    break;
  }
  text("AmmoType: " + ammoTypeString, 70, 120);
}

void startScreen() {
  background(0);
  fill(255);
  textSize(32);
  textAlign(CENTER, CENTER);
  text("Press ENTER to Start", width / 2, height / 2 - 40);

  // Display skin options
  textSize(24);
  text("Choose Skin:", width / 2, height / 2);
  text(skins[chosenSkinIndex], width / 2, height / 2 + 40);
  textSize(16);
  text("Press LEFT/RIGHT to change skin", width / 2, height / 2 + 80);
}

void pauseScreen() {
  background(0);
  fill(255);
  textSize(32);
  textAlign(CENTER, CENTER);
  text("Game Paused", width / 2, height / 2);
  textSize(16);
  text("Press P to Resume", width / 2, height / 2 + 40);
}

void gameScreen() {
  background(#EDE269);
  drawPlayer();
  movePlayer();
  if (spacePressed) {
    fireProjectile();
  }
  handleProjectiles();
  handleEnemies();
  checkCollisions();
  displayScoreAndHealth();
  displayAmmoAndReloadStatus();
  displayCurrentAmmoType(); // Added line to display current ammo type

  if (reloading) {
    reloadTimer++;
    if (reloadTimer >= reloadTime) {
      ammoCount = maxAmmo;
      reloading = false;
    }
  }
}

void drawPlayer() {
  strokeWeight(2);
  stroke(255, 0, 0);

  // Choose fill color based on selected skin
  switch (skins[chosenSkinIndex]) {
  case "Blue":
    stroke(#0F7789);
    fill(69, 204, 227);
    break;
  case "Purple":
    stroke(#750A93);
    fill(192, 12, 242);
    break;
  case "Green":
    stroke(#0A9310);
    fill(0, 255, 0);
    break;
  case "Ginger":
    stroke(#CB9021);
    fill(#F7B202);
    break;
  case "Black":
    noStroke();
    fill(0);
    break;
  }
  
  rect(playerX, playerY, playerSize, playerSize);
}

void movePlayer() {
  if (keyPressed) {
    if (key == 'a' || key == 'A') {
      playerX -= playerSpeed;
    } else if (key == 'd' || key == 'D') {
      playerX += playerSpeed;
    } else if (key == 'w' || key == 'W') {
      playerY -= playerSpeed;
    } else if (key == 's' || key == 'S') {
      playerY += playerSpeed;
    }
  }

  playerX = constrain(playerX, 0, width - playerSize);
  playerY = constrain(playerY, 0, height - playerSize);
}

void fireProjectile() {
  if (ammoCount > 0 && !reloading) {
    projectiles.add(new Projectile(playerX + playerSize / 2.5, playerY, currentAmmoType));
    ammoCount--;
  } else if (ammoCount == 0) {
    startReloading();
  }
}

void startReloading() {
  reloading = true;
  reloadTimer = 0;
}

void handleProjectiles() {
  for (int i = projectiles.size() - 1; i >= 0; i--) {
    Projectile p = projectiles.get(i);
    p.update();
    p.display();
    if (p.offScreen()) {
      projectiles.remove(i);
    }
  }
}

void handleEnemies() {
  if (frameCount % enemySpawnInterval == 0) {
    float rand = random(1);
    if (rand < 0.5) {
      enemies.add(new Enemy((int)random(0, width - playerSize), 0));
    } else if (rand < 0.7) {
      enemies.add(new FastEnemy((int)random(0, width - playerSize), 0));
    } else if (rand < 0.85) {
      enemies.add(new ShootingEnemy((int)random(0, width - playerSize), 0));
    } else {
      enemies.add(new ZigzagEnemy((int)random(0, width - playerSize), 0));
    }
  }
  for (int i = enemies.size() - 1; i >= 0; i--) {
    Enemy e = enemies.get(i);
    e.update();
    e.display();
    if (e.offScreen()) {
      enemies.remove(i);
    }
  }
  frameCount++;
}

void checkCollisions() {
  for (int i = enemies.size() - 1; i >= 0; i--) {
    Enemy e = enemies.get(i);
    for (int j = projectiles.size() - 1; j >= 0; j--) {
      Projectile p = projectiles.get(j);
      if (e.hits(p)) {
        e.health -= p.damage;
        if (e.health <= 0) {
          enemies.remove(i);
          score++; // Increase score when an enemy is eliminated
        }
        projectiles.remove(j);
        break; // Exit inner loop since the projectile has hit an enemy
      }
    }
    if (e.hitsPlayer(playerX, playerY, playerSize)) {
      enemies.remove(i);
      playerHealth -= 10; // Decrease health by 10 when hit
    }
  }
}

void displayScoreAndHealth() {
  fill(255);
  textSize(16);
  text("Score: " + score, 40, 20);

  // Display health bar
  fill(255, 0, 0);
  rect(40, 40, 100, 10); // Background bar
  fill(0, 255, 0);
  rect(40, 40, playerHealth, 10); // Health bar

  text("Health: " + playerHealth, 40, 60);
}

void displayAmmoAndReloadStatus() {
  fill(255);
  textSize(16);
  text("Ammo: " + ammoCount, 40, 80);
  if (reloading) {
    text("Reloading...", 40, 100);
  }
}

void gameOverScreen() {
  background(0);
  fill(255, 0, 0);
  textSize(32);
  textAlign(CENTER, CENTER);
  text("Game Over", width / 2, height / 2);
  textSize(16);
  text("Final Score: " + score, width / 2, height / 2 + 40);
  text("Press ENTER to Restart", width / 2, height / 2 + 80);
}

void keyPressed() {
  if (key == ENTER) {
    if (!gameStarted) {
      gameStarted = true;
    } else if (playerHealth <= 0) {
      resetGame();
    }
  }
  if (key == ' ') {
    spacePressed = true;
  }
  if (key == 'p' || key == 'P') {
    paused = !paused; // Toggle the pause state
  }
  if (key == '1') {
    currentAmmoType = AmmoType.STANDARD;
  }
  if (key == '2') {
    currentAmmoType = AmmoType.SPREAD;
  }
  if (key == '3') {
    currentAmmoType = AmmoType.BOMB;
  }

  // Skin selection logic
  if (!gameStarted) {
    if (keyCode == LEFT) {
      chosenSkinIndex = (chosenSkinIndex - 1 + skins.length) % skins.length;
    } else if (keyCode == RIGHT) {
      chosenSkinIndex = (chosenSkinIndex + 1) % skins.length;
    }
  }
}

void keyReleased() {
  if (key == ' ') {
    spacePressed = false;
  }
}

void resetGame() {
  score = 0;
  playerHealth = 100; // Reset health to 100
  frameCount = 0;
  playerX = width / 2;
  playerY = height - 40;
  projectiles.clear();
  enemies.clear();
  gameStarted = true;
  paused = false;
  ammoCount = maxAmmo;
  reloading = false;
}

enum AmmoType {
  STANDARD,
    SPREAD,
    BOMB
}

class Projectile {
  float x, y;
  float speed = 10;
  float damage = 10;
  AmmoType type;

  Projectile(float x, float y, AmmoType type) {
    this.x = x;
    this.y = y;
    this.type = type;
    if (type == AmmoType.SPREAD) {
      damage = 5;
    } else if (type == AmmoType.BOMB) {
      damage = 20;
    }
  }

  void update() {
    y -= speed;
    if (type == AmmoType.SPREAD) {
      // Add spread behavior
    } else if (type == AmmoType.BOMB) {
      // Add bomb behavior
    }
  }

  void display() {
    if (type == AmmoType.STANDARD) {
      stroke(0);
      fill(255);
      rect(x, y, 5, 10);
    } else if (type == AmmoType.SPREAD) {
      stroke(#DDE50E);
      fill(36, 209, 34);
      rect(x, y, 7, 12);
    } else if (type == AmmoType.BOMB) {
      stroke(0);
      fill(255, 0, 0);
      rect(x, y, 10, 15);
    }
  }

  boolean offScreen() {
    return y < 0;
  }
}

class Enemy {
  float x, y;
  float speed = 2;
  int size = 20;
  float health = 20; // Default health for enemies

  Enemy(float x, float y) {
    this.x = x;
    this.y = y;
  }

  void update() {
    y += speed;
  }

  void display() {
    stroke(#9B0E0E);
    fill(255, 0, 0);
    rect(x, y, size, size);
    displayHealthBar();
  }

  void displayHealthBar() {
    fill(255, 0, 0);
    rect(x, y - 5, size, 5); // Background bar
    fill(0, 255, 0);
    rect(x, y - 5, (health / 20) * size, 5); // Health bar
  }

  boolean offScreen() {
    return y > height;
  }

  boolean hits(Projectile p) {
    return p.x > x && p.x < x + size && p.y > y && p.y < y + size;
  }

  boolean hitsPlayer(int playerX, int playerY, int playerSize) {
    return playerX < x + size && playerX + playerSize > x && playerY < y + size && playerY + playerSize > y;
  }
}

class FastEnemy extends Enemy {
  FastEnemy(float x, float y) {
    super(x, y);
    speed = 4; // Faster speed
    health = 15; // Less health
  }
}




class ShootingEnemy extends Enemy {
  int shootInterval = 120; // Shoot every 120 frames
  int shootTimer = 0;

  ShootingEnemy(float x, float y) {
    super(x, y);
    health = 30; // More health
  }

  @Override
    void update() {
    super.update();
    shootTimer++;
    if (shootTimer >= shootInterval) {
      shootProjectile();
      shootTimer = 0;
    }
  }

  void shootProjectile() {
    // Add a new projectile from the enemy's position
    enemies.add(new EnemyProjectile(x + size / 2, y + size));
  }
}

class ZigzagEnemy extends Enemy {
  float direction = 1; // 1 for right, -1 for left
  float zigzagSpeed = 2; // Horizontal speed

  ZigzagEnemy(float x, float y) {
    super(x, y);
    health = 25; // Moderate health
  }

  @Override
    void update() {
    super.update();
    x += direction * zigzagSpeed;
    if (x < 0 || x > width - size) {
      direction *= -1; // Change direction when hitting screen edges
    }
  }
}

class EnemyProjectile extends Enemy {
  EnemyProjectile(float x, float y) {
    super(x, y);
    speed = 5;
    health = 0; // Projectiles do not have health
  }

  @Override
    void update() {
    y += speed;
  }

  @Override
    void display() {
    stroke(#7E7C00);
    fill(255, 255, 0); // Different color for enemy projectiles
    rect(x, y, 5, 10);
  }
}
