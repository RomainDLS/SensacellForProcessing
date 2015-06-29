import java.math.BigInteger;
import java.util.HashMap;

public class Sensacell{
  private int height;
  private int width;
  private int nbModules;
  private Cell[][] cell;
  private HashMap<Integer,Integer> addressList = new HashMap<Integer,Integer>();
  Serial sensaPort;
  private boolean proportionnalMode;
  private Cell[][] previous;  
  
  public Sensacell(Serial sensaPort){
      this.sensaPort = sensaPort;
    //default value :
    // BinaryMode
    sensaPort.write("0B00a00");
    sensaPort.write(13);
    delay(50);
    proportionnalMode = false;
  }
  
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
    println("End Of autoAddressing\nheight :" + height + "\t width :"+width);
  }
  
  public void fileAddressing(String fileName){
    HashMap<Integer,Integer> addressList = new HashMap<Integer,Integer>();
    BufferedReader reader = createReader(fileName);
    String line;
    int values[];
    int height=0,width=0;
    try {
      line = reader.readLine();
      values = int(split(line," "));
      height=values[1];
      width=values[0];
      while((line = reader.readLine())!= null){
        values = int(split(line," "));
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
  
  public void setSerial(Serial sensaPort){
    this.sensaPort = sensaPort;
    //default value :
    // BinaryMode :
    sensaPort.write("0B00a00");
    sensaPort.write(13);
    delay(50);
  }
  
  public void setProportionnalMode(){
    sensaPort.write("0B01a00");
    sensaPort.write(13);
    delay(50);
    proportionnalMode = true;
  }
  
  public void setBinaryMode(){
    sensaPort.write("0B00a00");
    sensaPort.write(13);
    delay(50);
    proportionnalMode = false;
  }
  
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
  
  public void fullDisplay(){
        sensaPort.write("01"+String.format("%02X", nbModules)+"a01");
        sensaPort.write(13);
        int couleur = 0x0F0F0F;
        int coord, i, j;
        
        for(int z=1; z<=nbModules; z++){
          //println("z :" + nbModules);
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
                for(int i=0;i<data.length()-1;i+=4){
                  setModuleSensorValue(data.substring(i,i+4),j);
                  j++;
                }
              }
              else
                println("no data - (fullListtenning)");
          }
          else
            println("sensaPort not available - (fullListtenning)");
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
  
  public void moduleListening(int moduleAddress){
    if(!proportionnalMode){
      sensaPort.write("r"+String.format("%02X", moduleAddress));
      sensaPort.write(13);
      delay(50);
      String data = "";
      if(sensaPort.available() > 0){
        data = sensaPort.readStringUntil(13);
        if (data != null){
          //println(data);
          setModuleSensorValue(data.substring(0,4),moduleAddress);
        }
        else
          println("no data - (fullListtenning)");
      }
      else
            println("sensaPort not available - (moduleListening)");
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
    String binaryLine[] = ((new BigInteger("1"+line, 16).toString(2)).substring(1, 17)).split("");
    int coord = addressList.get(moduleAddress);
    int i = coord/100;
    int j = coord%100;
    
    int k=1;
      for(int x=j;x<j+4;x++)
         for(int y=i;y<i+4;y++){
           cell[y][x].setSensorValue(int(binaryLine[k])*15);
           k++;
         }
  }
  
  protected void setAddress(int x, int y, int address){
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
  
  private void setSensorValue(int x, int y, int sensorValue){
    cell[x][y].setSensorValue(sensorValue);
  }
    
  public int getAddress(int x, int y){
    return cell[x][y].getModuleAddress();
  }
  
  public int getSensorValue(int x, int y){
    return cell[x][y].getSensorValue();
  }
  
  public int getColor(int x, int y){
    return cell[x][y].getColorValue();
  }
  
  public void setColor(int x, int y, int colorValue){
    if(x >= 0 && x < width && y >= 0 && y < height){
      cell[x][y].setColorValue(colorValue);
      //moduleDisplay(cell[x][y].getModuleAddress());
    }
  }

  public int getHeight() {
    return height;
  }

  public int getWidth() {
    return width;
  }
  
  
  public void Update(){
    fullListening();
    for(Integer i : getDifferentModule(cell,previous))
      moduleDisplay(i);
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
      for(int i=0;i<width;i++){
        if(cell[i][j].getColorValue() != previous[i][j].getColorValue()){
          addressList.add(cell[i][j].getModuleAddress());
        }
      }
      
    return addressList;
  }
}

