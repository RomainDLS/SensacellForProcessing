public class coord{
  private int x;
  private int y;
 
  protected coord(int x, int y){
    this.x = x;
    this.y = y;    
  }
  
  protected int getX(){
    return x;
  }
  
  protected int getY(){
    return y;
  }
  
  protected void setX(int x){
    this.x = x;
  }
  
  protected void setY(int y){
    this.y = y;
  }
}