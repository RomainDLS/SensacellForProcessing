 import processing.serial.*;
 
  Drawing draw;
  CentroidDetection CD;

    public void setup() {
      int sIndex = 0;
      frameRate(15);
    
       for(int i=0;i<Serial.list().length;i++){
          if(Serial.list()[i]!=null)
          {
            println(i+" "+Serial.list()[i]);
            sIndex=i;
          }
        }
        draw = new Drawing();
        draw.setSensaPort(new Serial(this,Serial.list()[0],230400));
        size(640,480);
        CD = new CentroidDetection(new Detector(this, 255));
    }
    
    public void draw() {
      Array tab;
      background(0xFFFFFF);
      draw.Update();
      tab = draw.getArray();
      int hexaColor, r, g, b;
      for(int i = 0; i<tab.getWidth();i++)
        for(int j=0; j<tab.getHeight();j++){
          hexaColor = tab.getColor(i, j);
              r = (hexaColor & 0xFF0000) >> 16;
              g = (hexaColor & 0xFF00) >> 8;
              b = (hexaColor & 0xFF);
              noStroke();
              if(tab.getSensorValue(i,j)==0){
                fill(0x000000);
              }
              else{
                fill(0xFFFFFF);
                tab.setColor(i,j,0xFFFFFF);
              }
              //fill(r,g,b);
              rect(i*20,j*20,20,20);
              draw.setArray(tab);
          /*    fill(0);
              textSize(8);
              text(i+"."+j,i*20,j*20+14);*/
         }
       if(frameCount==20){
         CD.CentroidColoring(tab, 0X00FF00);
       }
    }
