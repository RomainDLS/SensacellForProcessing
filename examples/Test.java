import processing.serial.Serial;
import processing.core.*;

public class Test extends PApplet{
	private static final long serialVersionUID = 1L;
	Sensacell tab;
	Utils Tools;

	public static void main(String args[]) {
		PApplet.main(new String[] { "--present", "SensaInit" });
	}

	public void setup() {
		tab = new Sensacell(new Serial(this,Serial.list()[0],230400),this);
		tab.fileAddressing("examples\\Config.txt");
		size(tab.getWidth()*20,tab.getHeight()*20);
		tab.fullDisplay();
		Tools = new Utils(tab);
		
		Tools.DrawRectangle(0, 0, 10, 10, 0xFF00FF);
		tab.Update();
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
		if(frameCount%10==0)
			println("frameRate = " + frameRate);
	}
}
