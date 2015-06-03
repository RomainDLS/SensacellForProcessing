 import processing.serial.*;
 
  Setting settings;
  CentroidDetection CD;

    public void setup() {
      int sIndex = 0;
      frameRate(13);
    
       for(int i=0;i<Serial.list().length;i++){
          if(Serial.list()[i]!=null)
          {
            println(i+" "+Serial.list()[i]);
            sIndex=i;
          }
        }
        settings = new Setting(new Serial(this,Serial.list()[0],230400));
        size(640,480);
        CD = new CentroidDetection(new Detector(this, 255));
    }
    
    public void draw() {
      background(255);
      Array tab;
      settings.Update();
      tab = settings.getArray();
      int hexaColor, r, g, b;
      for(int i = 0; i<tab.getWidth();i++)
        for(int j=0; j<tab.getHeight();j++){
              noStroke();
              fill(0xFFFFFF);
              if(tab.getSensorValue(i,j)!=0){
                fill(0);
              }
              ellipse(i*20+10,j*20+10,20,20);
              settings.setArray(tab);
          /*    fill(0);
              textSize(8);
              text(i+"."+j,i*20,j*20+14);*/
         }
         coord coordList[] = CD.getCentroids(tab);
         for(coord coords : coordList){
           fill(0x00FF00);
           ellipse(coords.getX()*20+10,coords.getY()*20+10,20,20);
           DrawCircle(coords.getX(),coords.getY(),3);
         }
      }
      
      //fill HexaColors
      public void fill(int hexaColor){
        fill((hexaColor & 0xFF0000) >> 16,(hexaColor & 0xFF00) >> 8,(hexaColor & 0xFF));
      }
      
      void DrawCircle(int x0, int y0, int radius)
{
  int x = radius;
  int y = 0;
  int decisionOver2 = 1 - x;   // Decision criterion divided by 2 evaluated at x=r, y=0
 
  while(x >= y)
  {
    settings.getArray().setColor( x + x0,  y + y0, 0xFF0000);
    settings.getArray().setColor( y + x0,  x + y0, 0xFF0000);
    settings.getArray().setColor(-x + x0,  y + y0, 0xFF0000);
    settings.getArray().setColor(-y + x0,  x + y0, 0xFF0000);
    settings.getArray().setColor(-x + x0, -y + y0, 0xFF0000);
    settings.getArray().setColor(-y + x0, -x + y0, 0xFF0000);
    settings.getArray().setColor( x + x0, -y + y0, 0xFF0000);
    settings.getArray().setColor( y + x0, -x + y0, 0xFF0000);
    y++;
    if (decisionOver2<=0)
    {
      decisionOver2 += 2 * y + 1;   // Change in decision criterion for y -> y+1
    }
    else
    {
      x--;
      decisionOver2 += 2 * (y - x) + 1;   // Change for y -> y+1, x -> x-1
    }
  }
}
