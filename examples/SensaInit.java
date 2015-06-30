import processing.serial.Serial;
import processing.core.*;

public class SensaInit extends PApplet{
	private static final long serialVersionUID = 1L;
	Sensacell tab;
	Blob blobs;
	Utils Tools;

	public static void main(String args[]) {
		PApplet.main(new String[] { "--present", "SensaInit" });
	}

	public void setup() {
		//Initializes a newly created Sensacell object connected to the only available serial
		tab = new Sensacell(new Serial(this,Serial.list()[0],230400),this);
		//The virtual array is initialized with the sensacell initialization protocol 
		tab.fileAddressing("examples\\Config.txt");

		//Set the size of the processing windows
		size(tab.getWidth()*20,tab.getHeight()*20);
		tab.setProportionnalMode();
		tab.fullDisplay();
		//Display on sensacell the virtual array
		//tab.setColor(1,2,0x13217C);

		Tools = new Utils(tab);
		blobs = new Blob(tab);
	}

	public void draw() {
		background(255);
		tab.Update();
		for(int i = 0; i<tab.getWidth();i++)
			for(int j=0; j<tab.getHeight();j++){
				noStroke();
				Tools.fill(0xFFFFFF);
				if(tab.getSensorValue(i,j)>3){
					int touchColor = 255 - tab.getSensorValue(i,j)*17;
					fill(touchColor,touchColor,touchColor);
					tab.setColor(i,j,0x13217C);
				}
				ellipse(i*20+10,j*20+10,20,20);
			}
		coord coordList[] = blobs.getCentroids();
	         for(coord coords : coordList){	
	           Tools.fill(0x00FF00);
	           ellipse(coords.getX()*20+10,coords.getY()*20+10,20,20);
	           Tools.DrawFilledCircle(coords.getX(),coords.getY(),1,0xFF0000);
	           //Tools.DrawFilledCircle(coords.getX(),coords.getY(),1,0xFF9E00);
	           //Tools.DrawFilledCircle(coords.getX(),coords.getY(),0,0xF6FF00);
	         }
		if(frameCount%10==0)
			println("frameRate = " + frameRate);
	}
}
