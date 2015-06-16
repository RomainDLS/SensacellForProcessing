 import blobscanner.*;
 
public class CentroidDetection{
   Detector bd;
   
   public CentroidDetection(Detector bd){
     this.bd = bd;
   }
   
   public coord[] getCentroids(Sensacell tab){
     coord coordList[];
     PImage img = arrayToPImage(tab);
     bd.imageFindBlobs(img);
     bd.loadBlobsFeatures();
     bd.findCentroids();
     coordList = new coord[bd.getBlobsNumber()];
     for(int i = 0; i < bd.getBlobsNumber(); i++) {
       coordList[i] = new coord(Math.round(bd.getCentroidX(i)), Math.round((int)bd.getCentroidY(i)));
     }
     
     return coordList;
   }
   
   private PImage arrayToPImage(Sensacell tab){
     PImage img = createImage(tab.width, tab.height, RGB);
     img.loadPixels();
     int k=0;  
     for(int i=0;i<tab.height;i++)
       for(int j=0;j<tab.width;j++){
         if(tab.getSensorValue(j,i)>4)
             img.pixels[k]=0xFFFFFF;
         else
             img.pixels[k]=0x000000;
         k++;
       }
       img.updatePixels();

       return img;
   }
   
}

public class coord{
  private int x;
  private int y;
 
  public coord(int x, int y){
    this.x = x;
    this.y = y;    
  }
  
  public int getX(){
    return x;
  }
  
  public int getY(){
    return y;
  }
  
  public void setX(int x){
    this.x = x;
  }
  
  public void setY(int y){
    this.y = y;
  }
}
