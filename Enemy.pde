public class Enemy {
  public PVector position;
  public float orientation;
  public float rotation = 0;
  public PVector velocity = new PVector(0,0);
  public PVector target; 
  public float maxSpeed;
  public PVector acceleration = new PVector(0,0);
  public float maxAccel = 10;
  public float gravSpeed = 4f;
  public EnemyType type;
  public float separation = 300;
  
  public Enemy(int startX, int startY, float orientation, float maxSpeed, EnemyType type) {
    this.orientation = orientation;
    position = new PVector(startX, startY);
    this.maxSpeed = maxSpeed;
    this.type = type;
    behaviour(player.position.x, player.position.y); //make sure target is set correctly as soon as an enemy spawns
  }
  
  public void behaviour(float targetX, float targetY) {
    if (type == EnemyType.SEEKER) {
      target = new PVector(targetX - position.x, targetY-position.y);
      acceleration = target.copy();
    } else if (type == EnemyType.WANDER) {
      target = new PVector(targetX - position.x, targetY-position.y);
      if (frame==30) {
        bullets.add(new Bullet(position.x, position.y, 1280*cos(rotation), position.y*sin(rotation), false));
        bullets.add(new Bullet(position.x, position.y , 1*cos(rotation), position.y * sin(rotation), false));
        bullets.add(new Bullet(position.x , position.y , position.x * cos(rotation), 720 * sin(rotation), false));
        bullets.add(new Bullet(position.x, position.y, position.x * cos(rotation), 1 * sin(rotation), false));
      }
    } else if (type == EnemyType.SHOOTER) {
      target = new PVector(targetX - position.x, targetY-position.y);
      PVector sepV = target.copy();
      float distance = sepV.mag();
      if (distance < separation) {
        sepV.normalize();
        sepV.mult(maxAccel * (separation - distance) / separation);
        acceleration.add(sepV);
      } else {
        acceleration = target.copy();
      }
    }
  }
  
  public void gravityBehavior(float targetX, float targetY) {
    target = new PVector(targetX - position.x, targetY-position.y);
    velocity = target.copy();
    velocity.normalize();
    velocity.mult(gravSpeed);
    position.add(velocity);
  }
  
  public void integrate() {
    if (type == EnemyType.SEEKER) {
      velocity.add(acceleration);
      velocity.normalize() ;
      velocity.mult(maxSpeed) ;
    
      orientation = atan2(velocity.y, velocity.x);
    } else if (type == EnemyType.WANDER) {
    velocity.x = cos(orientation) ;
    velocity.y = sin(orientation) ;
    velocity.mult(maxSpeed) ;
    
    orientation += random(0, PI/64) - random(0, PI/64) ;
    
    rotation += PI/64;
    
    if (rotation > PI) rotation -= PI*2 ;
    else if (rotation < -PI) rotation += PI*2;
    
    if (orientation > PI) orientation -= PI*2;
    else if (orientation < -PI) orientation += PI*2 ;
    
    
    if ((position.x-15 <= 0) || (position.x + 15 >= customWidth)) orientation += PI;
    if ((position.y-15 <= 0) || (position.y + 15 >= customHeight)) orientation += PI;
    
    } else if (type == EnemyType.SHOOTER) {
      velocity.add(acceleration);
      velocity.normalize() ;
      velocity.mult(maxSpeed) ;
      
      orientation = atan2(player.position.y - position.y, player.position.x - position.x);
    }
    
    position.add(velocity);
  }
}