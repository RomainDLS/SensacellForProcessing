import java.math.BigInteger;
import java.util.HashMap;

public class Array{
  private int height;
  private int width;
  private int nbModules;
  private Cell[][] cell;
  private HashMap<Integer,Integer> addressList = new HashMap<Integer,Integer>();
  Serial sensaPort;
  private boolean proportionnalMode;
    
  public Array(int width, int height) {
    this.height = height;
    this.width = width;
    cell = new Cell[width][height];
    for(int i = 0; i<width; i++)
      for(int j = 0; j<height; j++)
        cell[i][j] = new Cell(0x000000); //default color : 0x000000
    nbModules = height*width / (4*4);
    proportionnalMode = false;
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
  
  public void fullListenning(){
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
  
  public void moduleListenning(int moduleAddress){
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
          println("sensaPort not available - (moduleListenning)");
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
  
  public void setAddressList(HashMap<Integer,Integer> addressList){
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
  
  public void setSensorValue(int x, int y, int sensorValue){
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
}

