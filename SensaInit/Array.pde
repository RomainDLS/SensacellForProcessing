import java.math.BigInteger;
import java.util.HashMap;

public class Array {
  private int height;
  private int width;
  private Cell[][] cell;
  private HashMap<Integer,Integer> addressList = new HashMap<Integer,Integer>();
  Serial sensaPort;
  
  public Array(int width, int height) {
    // TODO Auto-generated constructor stub
    this.height = height;
    this.width = width;
    cell = new Cell[width][height];
    for(int i = 0; i<width; i++)
      for(int j = 0; j<height; j++)
        cell[i][j] = new Cell(0x000000); //default color : 0x000000
  }
  
  public void setSerial(Serial sensaPort){
    this.sensaPort = sensaPort;
  }
  
  public void UpdateModule(int moduleAddress){
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
  
  public void FullDisplay(){
        sensaPort.write("0130a01");
        sensaPort.write(13);
        int couleur = 0x0F0F0F;
        int coord, i, j;
        
        for(int z=1; z<=48; z++){
          coord = addressList.get(z);
          i = coord/100;
          j = coord%100;
          for(int a=i;a<i+4;a++)
            for(int b=j;b<j+4;b++)
               for(int k=2; k>=0; k--){
                  sensaPort.write((byte)(cell[a][b].getColorValue()>>((k)*8))&0xFF); 
               }
        }
  }  
  
  public void sensorListenning(){
        sensaPort.write("0030a01");
        sensaPort.write(13);
        delay(50);
        String data="";
        if (sensaPort.available() > 0) {
          data = sensaPort.readStringUntil(13);   
            if (data != null) {
              int j = 1;
              for(int i=0;i<data.length()-1;i+=4){
                sensorActivating(data.substring(i,i+4),j);
                j++;
              }
           //   println(data+" "+data.length());
            }
            else
              println("no data");
        }
        else
          println("sensaPort not available");
  }
  
  private void sensorActivating(String line, int moduleAddress){
    String binaryLine[] = ((new BigInteger("1"+line, 16).toString(2)).substring(1, 17)).split("");
    int coord = addressList.get(moduleAddress);
    int i = coord/100;
    int j = coord%100;
    
    int k=1;
      for(int x=j;x<j+4;x++)
         for(int y=i;y<i+4;y++){
           cell[y][x].setSensorValue(int(binaryLine[k]));
           k++;
         }
  }
  
  public void Addressing(String fileName){
    BufferedReader reader = createReader(fileName);
    String line;
    Integer coord = 0;
    try {
      line = reader.readLine();
      int[] Addresses = int(split(line," "));
      int k =0;
      for(int i=0;i<height;i+=4)
        for(int j=0;j<width;j+=4){
          coord = j*100 + i;
          addressList.put(Addresses[k],coord);
          //println(Addresses[k] + " : " + addressList.get(Addresses[k])/100 + " " + addressList.get(Addresses[k])%100);
          for(int x=i;x<i+4;x++)
            for(int y=j;y<j+4;y++){
              cell[y][x].setAddressModule(Addresses[k]);
            }
          k++;
        }
    } catch (IOException e) {
      e.printStackTrace();
      line = null;
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
    if(x >= 0 && x <= width && y >= 0 && y < height){
      cell[x][y].setColorValue(colorValue);
      UpdateModule(cell[x][y].getModuleAddress());
    }
    else
      println("ArrayIndexOutOfBoundsException -> x = "+x+" y = "+y);
  }

  public int getHeight() {
    return height;
  }

  public void setHeight(int height) {
    this.height = height;
  }

  public int getWidth() {
    return width;
  }

  public void setWidth(int width) {
    this.width = width;
  }
}

