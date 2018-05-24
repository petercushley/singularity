public class Star {
  PVector position;
  PVector velocity = new PVector(0,0);
  
  public Star(float xPos, float yPos) {
    position = new PVector(xPos, yPos);
  }
}