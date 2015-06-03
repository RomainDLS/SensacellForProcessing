public class Setting{
  private Array tab;
  //private HashMap<Integer,Integer> addressList = new HashMap<Integer,Integer>();
  Serial sensaPort;
  
  public Setting(Serial sensaPort){
    tab = new Array(8*4,6*4);
    //Addressing("Addressing.txt");
    //Initialization("Initialization.txt");
    this.sensaPort = sensaPort;
    tab.setSerial(sensaPort);
    Initialization("Initialization.txt");
    tab.fullDisplay();
  }
  
  public void Initialization(String fileName){
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
      output.print(data);
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
          for(int i=x;i<x+4;i++)
            for(int j=y;j<y+4;j++){
              tab.setAddress(i,j,address);
            }
          //output.print(data);
        }
      }
    }
    tab.setAddressList(addressList);
    output.flush();
    output.close();
    println("End Of Initialization\nheight :" + height + "\t width :"+width);
  }
  
  public void Addressing(String fileName){
    HashMap<Integer,Integer> addressList = new HashMap<Integer,Integer>();
    BufferedReader reader = createReader(fileName);
    String line;
    Integer coord = 0;
    int width = tab.getWidth();
    int height = tab.getHeight();
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
              tab.setAddress(y,x,Addresses[k]);
            }
          k++;
        }
    } catch (IOException e) {
      e.printStackTrace();
      line = null;
    }
    
    tab.setAddressList(addressList);
  }
  
  public void Update(){
    tab.fullListenning();
  }
  
  public Array getArray(){
    return tab;
  }
  
  public void setArray(Array tab){
    this.tab = tab;
  }
}
