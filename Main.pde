import com.dhchoi.*;
import java.text.DecimalFormat;

//screen variables
int customWidth = 1280;
int customHeight = 720;

//visual assets
PShape playerShip, shipBody, leftWing, rightWing; 
PShape seeker, seekerBody, seekerRight, seekerLeft; 
PShape wanderer, wanderBody, wanderUp, wanderDown, wanderLeft, wanderRight;
PShape shooter, shooterBody, shooterLeft, shooterRight;

//player variables
Player player = new Player(640, 360, 0, playerShip);
boolean alive = true;
int lives = 3;
boolean invincible = false;

//particles
ArrayList<Bullet> bullets = new ArrayList();
int numStars = 100;
ArrayList<Star> stars = new ArrayList(numStars);

//enemies
int difficulty = 0;
ArrayList<Enemy> enemies = new ArrayList();
ArrayList<PVector> portals = new ArrayList();

//timers
CountdownTimer waveTimer = CountdownTimerService.getNewCountdownTimer(this);
CountdownTimer multiplierLoss = CountdownTimerService.getNewCountdownTimer(this);
CountdownTimer gravityCooldown = CountdownTimerService.getNewCountdownTimer(this);
CountdownTimer respawnTimer = CountdownTimerService.getNewCountdownTimer(this);
CountdownTimer portalTimer = CountdownTimerService.getNewCountdownTimer(this);
CountdownTimer invincibilityTimer = CountdownTimerService.getNewCountdownTimer(this);

//scoring
double score = 0;
float multiplier = 1;
DecimalFormat format = new DecimalFormat("#.#");

//input handling variables
boolean mouseHeld = false;
boolean rightMouseHeld = false;
int frame = 0;
boolean w, a, s, d;

//gravity drive
boolean gravOn = false;
boolean recharge = true;
float powerLevel = 300;

void settings() {
  size(customWidth, customHeight);
}

void setup() {
  playerShip = createShape(GROUP);
  shipBody = createShape(TRIANGLE, 10, 0, 5, 30, 15, 30);
  shipBody.setFill(255);
  leftWing = createShape(TRIANGLE, 5, 10, 0, 30, 10, 30);
  leftWing.setFill(255);
  rightWing = createShape(TRIANGLE, 15, 10, 10, 30, 20, 30);
  rightWing.setFill(255);

  playerShip.addChild(shipBody);
  playerShip.addChild(leftWing);
  playerShip.addChild(rightWing);

  seeker = createShape(GROUP);
  seekerBody = createShape(TRIANGLE, 10, 0, 5, 30, 15, 30);
  seekerBody.setFill(169);
  seekerLeft = createShape(TRIANGLE, 5, 10, 0, 30, 10, 30);
  seekerLeft.setFill(169);
  seekerRight = createShape(TRIANGLE, 15, 10, 10, 30, 20, 30);
  seekerRight.setFill(169);

  seeker.addChild(seekerBody);
  seeker.addChild(seekerLeft);
  seeker.addChild(seekerRight);

  wanderer = createShape(GROUP);
  wanderBody = createShape(RECT, 0, 0, 10, 10);
  wanderBody.setFill(169);
  wanderUp = createShape(TRIANGLE, 0, 0, 10, 0, 5, -10);
  wanderUp.setFill(169);
  wanderDown = createShape(TRIANGLE, 0, 10, 10, 10, 5, 20);
  wanderDown.setFill(169);
  wanderLeft = createShape(TRIANGLE, 0, 0, 0, 10, -10, 5);
  wanderLeft.setFill(169);
  wanderRight = createShape(TRIANGLE, 10, 0, 10, 10, 20, 5);
  wanderRight.setFill(169);

  wanderer.addChild(wanderBody);
  wanderer.addChild(wanderUp);
  wanderer.addChild(wanderDown);
  wanderer.addChild(wanderLeft);
  wanderer.addChild(wanderRight);

  shooter = createShape(GROUP);
  shooterBody = createShape(RECT, 0, 0, 10, 10);
  shooterBody.setFill(169);
  shooterLeft = createShape(RECT, -10, -5, 10, 20);
  shooterLeft.setFill(169);
  shooterRight = createShape(RECT, 10, -5, 10, 20);
  shooterRight.setFill(169);

  shooter.addChild(shooterBody);
  shooter.addChild(shooterLeft);
  shooter.addChild(shooterRight);

  for (int i = 0; i < numStars; i++)
    stars.add(new Star(random(0, customWidth), random(0, customHeight)));

  //setup timers
  waveTimer.configure(1000, 10000); //ten seconds between waves
  multiplierLoss.configure(1000, 5000); //five seconds without hitting an enemy will cause the player's multiplier to reset
  gravityCooldown.configure(500, 5000); //Players must wait a full five seconds before the gravity power starts recharging
  respawnTimer.configure(1000, 3000); //players must wait three seconds after a death before they can respawn
  portalTimer.configure(1000, 1500); //time until portal turns into enemy
  invincibilityTimer.configure(1000, 3000); //time that the player will be invincible following a respawn

  //TODO temporary
  spawnWave();
  waveTimer.start();
}

void draw() {
  if (lives > 0) {
    keyHandler();
    drawMap();
    drawPlayer();
    drawBullets();
    drawEnemies();
    drawUI();
    if (!portals.isEmpty())
      drawPortals();
    detectCollisions();
    gravityHandler();
    frame = (frame+1)%60;
  } else {
    gameOver();
  }
  //System.out.println(keyPressed);
}

void gameOver() {
  fill(255);
  textSize(60);
  text("Game Over!", 450, 100);
  textSize(20);
  text("You scored " + score + " points and survived " + difficulty + " waves!", 400, 400);
}

void drawMap() {
  background(0);
  fill(255, 255, 255);
  for (Star star : stars)
    ellipse(star.position.x, star.position.y, 3, 3);
}

void drawPlayer() {
  if (alive) {
    pushMatrix();
    translate(player.position.x, player.position.y);
    rotate(player.orientation + PI/2);
    if(gravOn) { 
      fill(0, 255, 0);
      ellipse(0, 0, 40, 40);
    }
    if(invincible) {
      fill(0, 0, 255);
      ellipse(0, 0, 40, 40);
    }
    shape(playerShip, -10, -15);
    player.integrate();
    popMatrix();
  }
}

void drawEnemies() {
  for (int i = 0; i < enemies.size(); i++) {
    pushMatrix();
    Enemy enemy = enemies.get(i);
    translate(enemy.position.x, enemy.position.y);
    if (enemy.type == EnemyType.SEEKER) {
      rotate(enemy.orientation + PI/2);
      shape(seeker, -10, -15);
    } else if (enemy.type == EnemyType.WANDER) {
      rotate(enemy.rotation);
      shape(wanderer, -5, -5);
    } else if (enemy.type == EnemyType.SHOOTER) {
      rotate(enemy.orientation + PI/2);
      if (frame == 59 && ! gravOn) {
        bullets.add(new Bullet(enemy.position.x + 10, enemy.position.y, player.position.x, player.position.y, false));
      }
      shape(shooter, -5, -5);
    }
    if (!gravOn) {
      enemy.behaviour(player.position.x, player.position.y);
      if (alive) {
        enemy.integrate(); //don't want enemies to collide with invisible player
      }
    } else {
      enemy.gravityBehavior(player.position.x, player.position.y);
    }
    popMatrix();
  }
}

void drawBullets() { 
  if (alive && !gravOn) {
    if (mouseHeld && frame%5==0)
      bullets.add(new Bullet(player.position.x, player.position.y, mouseX, mouseY, true));
    for (Bullet bullet : bullets) {
      if (bullet.playerBullet) {
        fill(100, 100, 255);
        ellipse(bullet.position.x, bullet.position.y, 5, 5);
        bullet.integrate();
      } else {
        fill(255, 150, 0);
        ellipse(bullet.position.x, bullet.position.y, 7, 7);
        bullet.integrate();
      }
    }
  } else {
    bullets.clear();
  }
}

void drawUI() {
  //score
  textSize(20);
  fill(255);
  text("Score: " + score, 30, 20);

  //lives
  text("Lives: " + lives, 30, 700);

  //multiplier
  if (multiplierLoss.getTimeLeftUntilFinish() > 3000)
    fill(0, 255, 0);
  else if (multiplierLoss.getTimeLeftUntilFinish() > 1000)
    fill(255, 255, 0);
  else
    fill(255, 0, 0);
  text(format.format(multiplier) + "x", 600, 20);

  //gravity power
  fill(255);
  text("Gravity Power: ", 800, 20);
  for (int i = 1; i < 100; i++) {
    if (i > powerLevel/3) {
      fill(255, 0, 0);
    } else {
      fill(0, 255, 0);
    }
    rect(900 + (i*2), 20, 2, 10);
  }
}

void drawPortals() {
  for (int i = 0; i < portals.size(); i++) {
    fill (0, 0, 255);
    //ellipse(portal.x, portal.y, 40, 40);
    ellipse(portals.get(i).x, portals.get(i).y, 40, 40);
  }
}

void detectCollisions() {
  float collisionThreshold = 10;
  for (int i = enemies.size()-1; i >= 0; i--) { //enemies with player, have to reverse iterate so I can remove enemies
    if (enemies.get(i).target.mag() <= collisionThreshold) {
      System.out.println("Player/enemy collision with " + enemies.get(i).type);
      if (gravOn || invincible) {
        if (enemies.get(i).type == EnemyType.SEEKER) {
          score =  score + (10 * Math.floor(multiplier));
        } else if (enemies.get(i).type == EnemyType.WANDER) {
          score =  score + (20 * Math.floor(multiplier));
        } else if (enemies.get(i).type == EnemyType.SHOOTER) {
          score =  score + (15 * Math.floor(multiplier));
        }
        multiplier+=0.1;
        multiplierLoss.reset();
        multiplierLoss.start();
      } else {
        alive = false;
        respawnTimer.start();
      }
      enemies.remove(i);
    }
  }
  for (Bullet bullet : bullets) {
    if (bullet.playerBullet) { //player shoots enemy
      for (int j = enemies.size()-1; j >= 0; j--) {
        PVector collisionVector = new PVector(bullet.position.x - enemies.get(j).position.x, bullet.position.y - enemies.get(j).position.y);
        if (collisionVector.mag() <= collisionThreshold) {
          if (enemies.get(j).type == EnemyType.SEEKER) {
            score =  score + (10 * Math.floor(multiplier));
          } else if (enemies.get(j).type == EnemyType.WANDER) {
            score =  score + (20 * Math.floor(multiplier));
          } else if (enemies.get(j).type == EnemyType.SHOOTER) {
            score =  score + (15 * Math.floor(multiplier));
          }
          multiplier+=0.1;
          multiplierLoss.reset();
          multiplierLoss.start();
          enemies.remove(j);
          System.out.println("Player shot enemy");
        }
      }
    } else { //enemy shoots player
      PVector collisionVector = new PVector(bullet.position.x - player.position.x, bullet.position.y - player.position.y);
      if (collisionVector.mag() <= collisionThreshold && !invincible) {
        System.out.println("Enemy shot player");
        alive = false;
        respawnTimer.start();
      }
    }
  }
  if (enemies.isEmpty() && portals.isEmpty()) {
    spawnWave();
    waveTimer.reset();
    waveTimer.start();
  }
}

void gravityHandler() {
  if (alive) {
    if (rightMouseHeld) {
      if (powerLevel > 150) {
        if(!gravOn) {
          gravOn = true;
          recharge = false;
        }
        powerLevel--;
      } else if (gravOn && powerLevel > 0) {
        powerLevel--;
      } else if (powerLevel <= 0) {
        gravOn = false;
        if (!gravityCooldown.isRunning()) {
          gravityCooldown.reset();
          gravityCooldown.start();
        }
      }
    } else {
      gravOn = false;
      if (recharge) {
        if (powerLevel < 300)
          powerLevel++;
      } else if (!gravityCooldown.isRunning() && recharge == false) { 
        gravityCooldown.reset();
        gravityCooldown.start();
      }
    }
  } else {
    gravOn = false;
  }
}

void respawn() {
  lives--;
  multiplier=1;
  multiplierLoss.reset();
  multiplierLoss.start();
  player = new Player(640, 360, 0, playerShip);
  powerLevel = 300;
  invincible = true;
  invincibilityTimer.reset();
  invincibilityTimer.start();
  alive = true;
}

void spawnWave() {

  if (difficulty < 5) {
    portals.add(new PVector(random(1280), random(720)));
  }
  if (difficulty >= 5) {
    for (int i = 0; i < difficulty-3; i++)
      portals.add(new PVector(random(1280), random(720)));
  }

  portalTimer.start();
  difficulty++;
}

void spawner(int x, int y) {

  if (difficulty == 1) { //only one enemy
    //enemies.add(new Enemy (x, y, 0f, 1.75f, EnemyType.SEEKER));
    enemies.add(new Enemy(x, y, 0f, 1.75f, EnemyType.SEEKER));
  } else if (difficulty < 5) { //one cluster of three enemies
    enemies.add(new Enemy (x + 20, y + 20, 0f, 1.75f, EnemyType.SEEKER));
    enemies.add(new Enemy (x, y, 0f, 1.75f, EnemyType.SEEKER));
    enemies.add(new Enemy (x - 20, y - 20, 0f, 1.75f, EnemyType.SEEKER));
  } else {
    float RNG = random(0, 3);
    if (RNG >= 0 && RNG < 1) {
      enemies.add(new Enemy (x + 20, y + 20, 0f, 1.75f, EnemyType.SEEKER));
      enemies.add(new Enemy (x, y, 0f, 1.75f, EnemyType.SEEKER));
      enemies.add(new Enemy (x - 20, y - 20, 0f, 1.75f, EnemyType.SEEKER));
      enemies.add(new Enemy (x + 20, y - 20, 0f, 1.75f, EnemyType.SEEKER));
      enemies.add(new Enemy (x - 20, y + 20, 0f, 1.75f, EnemyType.SEEKER));
    } else if (RNG >= 1 && RNG < 2) {
      enemies.add(new Enemy(x, y, 0f, 1f, EnemyType.WANDER));
    } else if (RNG >= 2 && RNG < 3) {
      enemies.add(new Enemy(x, y, 0f, 1f, EnemyType.SHOOTER));
    }
  }
}

void onFinishEvent(CountdownTimer t) { //countdown timer has finished
  if (t == waveTimer) {
    spawnWave();
    waveTimer.start();
  } else if (t == respawnTimer) {
    respawn();
  } else if (t == multiplierLoss) {
    multiplier = 1;
  } else if (t == gravityCooldown) {
    recharge = true;
  } else if (t == portalTimer) {
    for (PVector portal : portals) {
      spawner((int)portal.x, (int)portal.y);
    }
    portals.clear();
    portalTimer.reset();
  } else if (t == invincibilityTimer) {
    invincible = false;
  }
}

void onTickEvent(CountdownTimer t, long timeLeftUntilFinish) {
}

void mousePressed() {
  if (mouseButton == LEFT) {
    mouseHeld = true;
    System.out.println("LMB");
  } else if (mouseButton == RIGHT) {
    rightMouseHeld = true;
    System.out.println("RMB");
  }
}

void mouseReleased() {
  mouseHeld = false;
  rightMouseHeld = false;
}

void keyPressed() {
  System.out.println("keyPressed" + frame + ":" + key);
  float velconst = 3f;
  if (key == 'w' || key == 'W') {
    //System.out.println("w");
    //if (player.velocity.mag() == 0) {
    //  player.velocity.set(0, -velconst);
    //} else {
    //  player.velocity.add(0, -velconst);
    //}
    w = true;
  }
  if (key == 'a' || key == 'A') {
    //System.out.println("a");
    //if (player.velocity.mag() == 0) {
    //  player.velocity.set(-velconst, 0);
    //} else {
    //  player.velocity.add(-velconst, 0);
    //}
    a = true;
  }
  if (key == 's' || key == 'S') {
    //System.out.println("s");
    //if (player.velocity.mag() == 0) {
    //  player.velocity.set(0, velconst);
    //} else {
    //  player.velocity.add(0, velconst);
    //}
    s = true;
  }
  if (key == 'd' || key == 'D') {
    //System.out.println("d");
    //if (player.velocity.mag() == 0) {
    //  player.velocity.set(velconst, 0);
    //} else {
    //  player.velocity.add(velconst, 0);
    //}
    d = true;
  }
}

void keyReleased() {
  System.out.println("keyReleased" + frame + ":" + key);
  float velconst = 3f;
  //if (keyPressed) {
  if (key == 'w' || key == 'W') {
    //System.out.println("w released");
    //player.velocity.sub(0, -velconst);
    w = false;
  }
  if (key == 'a' || key == 'A') {
    //System.out.println("a released");
    //player.velocity.sub(-velconst, 0);
    a = false;
  }
  if (key == 's' || key == 'S') {
    //System.out.println("s released");
    //player.velocity.sub(0, velconst);
    s = false;
  }
  if (key == 'd' || key == 'D') {
    //System.out.println("d released");
    //player.velocity.sub(velconst, 0);
    d = false;
  }
  //if (!keyPressed) {
  //  //player.velocity.setMag(0);
  //}
}

void keyHandler() {
  float velconst = 3f;
  if (w && player.position.y -15 > 0) {
    if (player.velocity.mag() == 0) {
      player.velocity.set(0, -velconst);
    } else {
      player.velocity.add(0, -velconst);
    }
  }
  if (a && player.position.x -15 > 0) {
    if (player.velocity.mag() == 0) {
      player.velocity.set(-velconst, 0);
    } else {
      player.velocity.add(-velconst, 0);
    }
  }
  if (s && player.position.y + 15 < height) {
    if (player.velocity.mag() == 0) {
      player.velocity.set(0, velconst);
    } else {
      player.velocity.add(0, velconst);
    }
  }
  if (d && player.position.x +15 < width) {
    if (player.velocity.mag() == 0) {
      player.velocity.set(velconst, 0);
    } else {
      player.velocity.add(velconst, 0);
    }
  }

  if (!w && !a && !s && !d) {
    player.velocity.setMag(0);
  }
}