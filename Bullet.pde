public class Bullet {
  public PVector position;
  public PVector velocity;
  public float maxSpeed = 3f;
  public boolean playerBullet;
  
  public Bullet(float startX, float startY, float targetX, float targetY, boolean playerBullet) {
    position = new PVector(startX, startY);
    velocity = new PVector(targetX-startX, targetY-startY);
    velocity.normalize();
    this.playerBullet = playerBullet;
    if (playerBullet) {
      velocity.setMag(10);
    }
    else {
      velocity.setMag(5);
    }
  }
  
  void integrate() {
    position.add(velocity);
    
    //if ((position.x < 0) || (position.x > width)) { bullets.remove(this);} 
    //if ((position.y < 0) || (position.y > height)) {bullets.remove(this);}
  }
}