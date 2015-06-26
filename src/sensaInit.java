import blobscanner.Detector;
import processing.serial.Serial;
import processing.core.*;

public class sensaInit extends PApplet{
	private static final long serialVersionUID = 1L;
	Sensacell tab;
	Blob blobs;
	Utils Tools;

	public static void main(String args[]) {
		PApplet.main(new String[] { "--present", "MyProcessingSketch" });
	}

	public void setup() {
		blobs = new Blob(new Detector(this, 255));
		//Initializes a newly created Sensacell object connected to the only available serial
		tab = new Sensacell(new Serial(this,Serial.list()[0],230400),this);
		//The virtual array is initialized with the sensacell initialization protocol 
		tab.fileAddressing("Config.txt");

		//Set the size of the processing windows
		size(tab.getWidth()*20,tab.getHeight()*20);
		tab.setProportionnalMode();
		tab.fullDisplay();
		//Display on sensacell the virtual array
		//tab.setColor(1,2,0x13217C);

		Tools = new Utils(tab);
	}

	public void draw() {
		background(255);
		tab.Update();
		//tab.fullListening();
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
		coord coordList[] = blobs.getCentroids(tab);
	         for(coord coords : coordList){
	           fill(0x00FF00);
	           ellipse(coords.getX()*20+10,coords.getY()*20+10,20,20);
	           Tools.DrawCircle(coords.getX(),coords.getY(),3,0xFFFFFF);
	           Tools.DrawFilledCircle(coords.getX(),coords.getY(),2,0xFF0000);
	           //Tools.DrawFilledCircle(coords.getX(),coords.getY(),1,0xFF9E00);
	           //Tools.DrawFilledCircle(coords.getX(),coords.getY(),0,0xF6FF00);
	         }
		if(frameCount%10==0)
			println("frameRate = " + frameRate);
	}

	//fill HexaColors
	public void fill(int hexaColor){
		fill((hexaColor & 0xFF0000) >> 16,(hexaColor & 0xFF00) >> 8,(hexaColor & 0xFF));
	}
}
