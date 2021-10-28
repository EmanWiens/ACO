public class City {
  private PVector pos; 
  private int id; 
  
  public City(int id, PVector pos) {
    this.pos = pos; 
    this.id = id; 
  }
  
  public void draw() {
    fill(0); 
    noStroke(); 
    ellipse(pos.x, pos.y, 5, 5); 
    fill(0); 
    text(id, pos.x, pos.y); 
  } 
  
  public int getId() {
    return id; 
  }
}
