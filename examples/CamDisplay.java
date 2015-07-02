import processing.core.PApplet;
import processing.serial.Serial;
import processing.video.Capture;

public class CamDisplay extends PApplet {

	private static final long serialVersionUID = -2005070667588406968L;
	int CamRatio;
	Capture cam;
	Sensacell tab;
	Utils Tools;

	public void setup() {
		tab = new Sensacell(new Serial(this,Serial.list()[0],230400),this);
		tab.autoAddressing("Config.txt");
		Tools = new Utils(tab);
		cam = new Capture(this, Capture.list()[0]);
		cam.start();
		tab.fullDisplay();
		size(640,480);
	}

	public void draw() {
		if (cam.available() == true) {
			cam.read();
			Tools.loadImage(cam, 16, 12, 0, 0);
			tab.fullDisplay();
		}
		//Tools.loadImage(cam, 16, 12, 0, 0);
		// The following does the same, and is faster when just drawing the image
		// without any additional resizing, transformations, or tint.
		image(cam, 0, 0);
	}
}
