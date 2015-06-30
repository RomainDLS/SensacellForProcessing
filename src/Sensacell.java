import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.HashMap;

import processing.serial.Serial;
import processing.core.*;

/**
 * @author Romain
 */
public class Sensacell extends PApplet{
	private static final long serialVersionUID = 7145179468355755361L;
	private int height;
	private int width;
	private int nbModules;
	private Cell[][] cell;
	private HashMap<Integer,Integer> addressList = new HashMap<Integer,Integer>();
	private Serial sensaPort;
	private boolean proportionnalMode;
	private Cell[][] previous;  
	private PApplet parent;

	/**
	 * Initializes a newly created Sensacell object so that it represents the Sensacell array connected to the serial sensaPort.
	 * @param sensaPort
	 * @param parent
	 */
	public Sensacell(Serial sensaPort, PApplet parent){
		this.sensaPort = sensaPort;
		this.parent = parent;
		//default value :
		// BinaryMode
		sensaPort.write("0B00a00");
		sensaPort.write(13);
		delay(50);
		proportionnalMode = false;
	}

	protected PApplet getPApplet(){
		return parent;
	}

	/**
	 * The virtual array is initialized with the sensacell initialization protocol and then the configuration is saved on a file named filename.
	 * @param fileName
	 * name of the saved file
	 */
	public void autoAddressing(String fileName){
		HashMap<Integer,Integer> addressList = new HashMap<Integer,Integer>();
		int x,y,coord,address;
		int height = 0;
		int width = 0;
		PrintWriter output = createWriter(fileName); 
		String data = "";

		sensaPort.write("13EAa00");
		sensaPort.write(13);
		delay(8000);

		while(sensaPort.available() > 0){
			data = sensaPort.readStringUntil(13);
			if(data.length() == 9){
				if(data.substring(0,1).equals("0")||data.substring(0,1).equals("1")||data.substring(0,1).equals("5")){
					x=4*(Integer.parseInt(data.substring(4,6),16)-1);
					y=4*(Integer.parseInt(data.substring(2,4),16)-1);
					if(x/4>width){
						width = x/4 + 1;
					}
					if(y/4>height){
						height = y/4 + 1;
					}
					coord=x*100+y;
					address=Integer.parseInt(data.substring(6,8),16);
					addressList.put(address,coord);
				}
			}
		}
		sizeSetting(width*4,height*4);
		setAddressList(addressList);
		output.println(width + " " + height);
		for(Integer mapKey : addressList.keySet()){
			output.println(mapKey + " " + addressList.get(mapKey));
		}
		output.flush();
		output.close();
		PApplet.println("End Of autoAddressing\nheight :" + height + "\t width :"+width);
	}

	/**
	 * The virtual array is initialized with the file named filename.
	 * @param fileName
	 * name of the loaded file
	 */
	public void fileAddressing(String fileName){
		HashMap<Integer,Integer> addressList = new HashMap<Integer,Integer>();
		BufferedReader reader = createReader(fileName);
		String line;
		String valuesArray[];
		int values[];
		int height=0,width=0;
		try {
			line = reader.readLine();
			valuesArray = line.split(" ");
			values = new int[valuesArray.length];
			for(int i = 0; i < valuesArray.length; i++) {
				values[i] = Integer.parseInt(valuesArray[i]);
			}
			height=values[1];
			width=values[0];
			while((line = reader.readLine())!= null){
				valuesArray = line.split(" ");
				values = new int[valuesArray.length];
				for(int i = 0; i < valuesArray.length; i++) {
					values[i] = Integer.parseInt(valuesArray[i]);
				}
				addressList.put(values[0],values[1]);
			}
		} catch (IOException e) {
			e.printStackTrace();
			line = null;
		}

		sizeSetting(width*4,height*4);
		setAddressList(addressList);
	}

	private void sizeSetting(int width, int height) {
		this.height = height;
		this.width = width;
		cell = new Cell[width][height];
		for(int i = 0; i<width; i++)
			for(int j = 0; j<height; j++)
				cell[i][j] = new Cell(0x000000); //default color : 0x000000
		previous = new Cell[width][height];
		for(int i = 0; i<width; i++)
			for(int j = 0; j<height; j++)
				previous[i][j] = new Cell(0x000000);
		nbModules = height*width / (4*4);
	}

	/**
	 * Return the number of Modules of Sensacell
	 * @return
	 * the number of Modules of Sensacell
	 */
	public int getNbModules(){
		return nbModules;
	}

	/**
	 * Set the serial which is connected to the sensacell array.
	 * @param sensaPort
	 * Serial connected to sensacell
	 */
	public void setSerial(Serial sensaPort){
		this.sensaPort = sensaPort;
		//default value :
		// BinaryMode :
		sensaPort.write("0B00a00");
		sensaPort.write(13);
		delay(50);
	}

	/**
	 * Set the proportional read mode on sensacell.
	 */
	public void setProportionnalMode(){
		sensaPort.write("0B01a00");
		sensaPort.write(13);
		delay(50);
		proportionnalMode = true;
	}

	/**
	 * Set the binary read mode on sensacell.
	 */
	public void setBinaryMode(){
		sensaPort.write("0B00a00");
		sensaPort.write(13);
		delay(50);
		proportionnalMode = false;
	}

	/**
	 * Display on sensacell the values contains in the module number moduleAddress.
	 * @param moduleAddress
	 * module number (must be <= nbModules)
	 */
	public void moduleDisplay(int moduleAddress){
		sensaPort.write("0101a"+String.format("%02X", moduleAddress));
		sensaPort.write(13);
		int coord = addressList.get(moduleAddress);
		int i = coord/100;
		int j = coord%100;
		for(int a=j;a<j+4;a++)
			for(int b=i;b<i+4;b++)
				for(int k=2; k>=0; k--){
					sensaPort.write((byte)(cell[b][a].getColorValue()>>((k)*8))&0xFF); 
				}
	}

	/**
	 * Display on sensacell all the values of the virtual array.
	 */
	public void fullDisplay(){
		sensaPort.write("01"+String.format("%02X", nbModules)+"a01");
		sensaPort.write(13);
		int coord, i, j;

		for(int z=1; z<=nbModules; z++){
			coord = addressList.get(z);
			i = coord/100;
			j = coord%100;
			for(int a=j;a<j+4;a++)
				for(int b=i;b<i+4;b++)
					for(int k=2; k>=0; k--){
						sensaPort.write((byte)(cell[b][a].getColorValue()>>((k)*8))&0xFF); 
					}
		}
	}

	/**
	 * Set on the virtual array all the sensors values of the sensacell array.
	 */
	public void fullListening(){
		sensaPort.write("00"+String.format("%02X", nbModules)+"a01");
		sensaPort.write(13);
		delay(50);
		if(!proportionnalMode){
			String data="";
			if (sensaPort.available() > 0) {
				data = sensaPort.readStringUntil(13);   
				if (data != null) {
					int j = 1;
					//println(data);
					for(int i=0;i<data.length()-1;i+=4){
						setModuleSensorValue(data.substring(i,i+4),j);
						j++;
					}
				}
				else
					PApplet.println("no data - (fullListtenning)");
			}
			else
				PApplet.println("sensaPort not available - (fullListtenning)");
		}
		else{
			int data=0;
			for(int z=1; z<=nbModules; z++){
				int coord = addressList.get(z);
				int i = coord/100;
				int j = coord%100;
				for(int b=j;b<j+4;b++)
					for(int a=i;a<i+4;a+=2){
						if(sensaPort.available() > 0)
							data = sensaPort.read();
						cell[a][b].setSensorValue(data>>4);
						cell[a+1][b].setSensorValue(data - ((data>>4)<<4));
					}
			}
		}
	}

	/**
	 * Set on the virtual array the sensors values of the module number moduleAddress.
	 * @param moduleAddress
	 * module number (must be <= nbModules)
	 */
	public void moduleListening(int moduleAddress){
		if(!proportionnalMode){
			sensaPort.write("r"+String.format("%02X", moduleAddress));
			sensaPort.write(13);
			delay(50);
			String data = "";
			if(sensaPort.available() > 0){
				data = sensaPort.readStringUntil(13);
				if (data != null){
					//parent.println(data);
					setModuleSensorValue(data.substring(0,4),moduleAddress);
				}
				else
					PApplet.println("no data - (moduleListening)");
			}
			else
				PApplet.println("sensaPort not available - (moduleListening)");
		}
		else{
			sensaPort.write("p"+String.format("%02X", moduleAddress));
			sensaPort.write(13);
			delay(50);
			String data = "";
			int k=0;
			int coord = addressList.get(moduleAddress);
			int i = coord/100;
			int j = coord%100;
			if(sensaPort.available() > 0)
				data = sensaPort.readStringUntil(13);
			for(int b=j;b<j+4;b++)
				for(int a=i;a<i+4;a++){
					cell[a][b].setSensorValue(Integer.parseInt(data.substring(k,k+1), 16));
					k++;
				}
		}
	}

	private void setModuleSensorValue(String line, int moduleAddress){
		//PApplet.println(line);
		String binaryLine[] = ((new BigInteger("1"+line, 16).toString(2)).substring(1, 17)).split("");
		int coord = addressList.get(moduleAddress);
		int i = coord/100;
		int j = coord%100;

		int k=0;
		for(int x=j;x<j+4;x++)
			for(int y=i;y<i+4;y++){
				//print((Integer.parseInt(binaryLine[k])));
				cell[y][x].setSensorValue((Integer.parseInt(binaryLine[k]))*15);
				k++;
			}
	}

	private void setAddress(int x, int y, int address){
		cell[x][y].setAddressModule(address);
	}

	private void setAddressList(HashMap<Integer,Integer> addressList){
		this.addressList = addressList;
		int x,y,address;
		for(Integer mapKey : addressList.keySet()){
			address = mapKey;
			x = addressList.get(mapKey)/100;
			y = addressList.get(mapKey)%100;
			for(int i=x;i<x+4;i++)
				for(int j=y;j<y+4;j++)
					setAddress(i,j,address);
		}
	}

	/**
	 * Return the address of the module which contains the cell[x][y].
	 * @param x
	 * x coordinate
	 * @param y
	 * y coordinate
	 * @return
	 * a number of one module
	 */
	public int getAddress(int x, int y){
		return cell[x][y].getModuleAddress();
	}

	/**
	 * Return the value of the sensor of the cell[x][y].
	 * @param x
	 * x coordinate
	 * @param y
	 * y coordinate
	 * @return
	 * a value of one sensor
	 */
	public int getSensorValue(int x, int y){
		return cell[x][y].getSensorValue();
	}

	/**
	 * Return the color (hexadecimal value) of the cell[x][y].
	 * @param x
	 * x coordinate
	 * @param y
	 * y coordinate
	 * @return
	 * a color of one cell
	 */
	public int getColor(int x, int y){
		return cell[x][y].getColorValue();
	}

	/**
	 * Set the color (hexadecimal value) of the cell[x][y].
	 * @param x
	 * x coordinate
	 * @param y
	 * y coordinate
	 * @param colorValue
	 * color of the cell
	 */
	public void setColor(int x, int y, int colorValue){
		if(x >= 0 && x < width && y >= 0 && y < height){
			cell[x][y].setColorValue(colorValue);
			//moduleDisplay(cell[x][y].getModuleAddress());
		}
	}

	/**
	 * Return the height of the virtual array.
	 * @return
	 * height of sensacell
	 */
	@Override
	public int getHeight() {
		return height;
	}

	/** 
	 * Return the width of the virtual array.
	 * @return
	 * width of sensacell
	 */
	@Override
	public int getWidth() {
		return width;
	}


	/**
	 * Intelligent listening and displaying 
	 */
	public void Update(){
		fullListening();
		ArrayList<Integer> ChangedModule = getDifferentModule(cell,previous);
		if(ChangedModule.size()<(nbModules/8))
			for(Integer i : ChangedModule)
				moduleDisplay(i);
		else
			fullDisplay();
		colorCopy();
	}

	private void colorCopy(){
		for(int j=0; j<height; j++)
			for(int i=0; i<width; i++)
				previous[i][j].setColorValue(cell[i][j].getColorValue());
	}

	private ArrayList<Integer> getDifferentModule(Cell[][] cell, Cell[][] previous){
		ArrayList<Integer> addressList = new ArrayList<Integer>();

		for(int j=0;j<height;j++)
			for(int i=0;i<width;i++)
				if(cell[i][j].getColorValue() != previous[i][j].getColorValue())
					if(!addressList.contains(cell[i][j].getModuleAddress()))
						addressList.add(cell[i][j].getModuleAddress());

		return addressList;
	}
}
