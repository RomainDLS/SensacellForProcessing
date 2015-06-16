 import processing.serial.*;
 
  Sensacell tab;
  CentroidDetection CD;

    public void setup() {
      int sIndex = 0;
      frameRate(60);
    
       for(int i=0;i<Serial.list().length;i++){
          if(Serial.list()[i]!=null)
          {
            println(i+" "+Serial.list()[i]);
            sIndex=i;
          }
        }
        CD = new CentroidDetection(new Detector(this, 255));
        tab = new Sensacell(new Serial(this,Serial.list()[0],230400));
        tab.fileAddressing("Config.txt");
        size(tab.getWidth()*20,tab.getHeight()*20);
        //tab.setProportionnalMode();
        tab.fullDisplay();
    }
    
    public void draw() {
      background(255);
      tab.Update();
      for(int i = 0; i<tab.getWidth();i++)
        for(int j=0; j<tab.getHeight();j++){
              noStroke();
              fill(0xFFFFFF);
              if(tab.getSensorValue(i,j)>3){
                int touchColor = 255 - tab.getSensorValue(i,j)*17;
                fill(touchColor,touchColor,touchColor);
                tab.setColor(i,j,0x13217C);
              }
              ellipse(i*20+10,j*20+10,20,20);
         }
         coord coordList[] = CD.getCentroids(tab);
         for(coord coords : coordList){
           fill(0x00FF00);
           ellipse(coords.getX()*20+10,coords.getY()*20+10,20,20);
           DrawCircle(coords.getX(),coords.getY(),3,0xFFFFFF);
         }
         if(frameCount%10==0)
           println("frameRate = " + frameRate);
      }
      
      //fill HexaColors
      public void fill(int hexaColor){
        fill((hexaColor & 0xFF0000) >> 16,(hexaColor & 0xFF00) >> 8,(hexaColor & 0xFF));
      }
