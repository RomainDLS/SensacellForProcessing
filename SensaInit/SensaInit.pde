 import processing.serial.*;
 
  Drawing draw;
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
        draw = new Drawing();
        draw.setSensaPort(new Serial(this,Serial.list()[0],230400));
        size(640,480);
        CD = new CentroidDetection(new Detector(this, 255));
    }
    
    public void draw() {
      background(255);
      Array tab;
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
              fill(255,255,255);
              if(tab.getSensorValue(i,j)!=0){
                fill(0,0,0);
              }
              ellipse(i*20+10,j*20+10,20,20);
              draw.setArray(tab);
          /*    fill(0);
              textSize(8);
              text(i+"."+j,i*20,j*20+14);*/
         }
         coord coordList[] = CD.getCentroids(tab);
         for(coord coords : coordList){
           fill(0,255,0);
           ellipse(coords.getX()*20+10,coords.getY()*20+10,20,20);
           println(frameRate + " " + coords.getX() + " " + coords.getY() + " " + coordList.length);
         }
      }
