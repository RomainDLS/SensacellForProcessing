 import blobscanner.*;
 
public class CentroidDetection{
   Detector bd;
   
   public CentroidDetection(Detector bd){
     this.bd = bd;
   }
   
   public void CentroidColoring(Array tab, int Color){
     PImage img = arrayToPImage(tab);
     bd.imageFindBlobs(img);
     bd.loadBlobsFeatures();
     bd.findCentroids();
     for(int i = 0; i < bd.getBlobsNumber(); i++) {
       println("BLOB " + (i+1) + "centroid coord :"  + bd.getCentroidX(i) + " - " +  + bd.getCentroidY(i));
     }
     Array
   }
   
   private PImage arrayToPImage(Array tab){
     PImage img = createImage(tab.width, tab.height, RGB);
     img.loadPixels();
     int k=0;  
     for(int i=0;i<tab.height;i++)
       for(int j=0;j<tab.width;j++){
         if(tab.getSensorValue(j,i)!=0)
             img.pixels[k]=0xFFFFFF;
         else
             img.pixels[k]=0x000000;
         k++;
       }
       img.updatePixels();
       
       return img;
   }
   
}
