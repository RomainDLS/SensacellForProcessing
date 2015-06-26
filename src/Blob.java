import processing.core.PImage;
import blobscanner.*;

public class Blob{
	Detector bd;

	public Blob(Detector bd){
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
		PImage img = new PImage(tab.getWidth(), tab.getHeight());
		img.loadPixels();
		int k=0;  
		for(int i=0;i<tab.getHeight();i++)
			for(int j=0;j<tab.getWidth();j++){
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