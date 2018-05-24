public class Player {  
  PShape playerShip;
  
  public PVector position;
  public float orientation;
  public PVector velocity = new PVector(0,0);
  public float maxSpeed = 3f;
  public float damping = 0.995f;
  
  
  public Player(int startX, int startY, float orientation, PShape playerShip) {
    this.orientation = orientation;
    position = new PVector(startX, startY);
    this.playerShip = playerShip;
  }
  
  void integrate() {
    position.add(velocity);
    velocity.normalize();
    velocity.mult(maxSpeed);
    velocity.mult(damping);
    orientation = atan2(mouseY - position.y, mouseX-position.x);
    
    //if ((position.x < 0) || (position.x > width)) { velocity.x = -velocity.x;} 
    //if ((position.y < 0) || (position.y > height)) {velocity.y = -velocity.y; }
    
    if (position.x -15 < 0) {a=false;}
    if (position.x + 15 > width) { d = false; } 
    if (position.y -15 < 0) {w = false;}
    if (position.y + 15 > height) {s= false; }
  }
}