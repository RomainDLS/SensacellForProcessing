public class Setting{
  private Array tab;
  Serial sensaPort;
  private Array previousArray;
  
  public Setting(Serial sensaPort){
    this.sensaPort = sensaPort;
    tab = autoAddressing("Config.txt");
    previousArray = colorCopy();
    tab.fullDisplay();
  }
  
  public Array autoAddressing(String fileName){
    HashMap<Integer,Integer> addressList = new HashMap<Integer,Integer>();
    Array tab;
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
    tab = new Array(width*4,height*4);
    tab.setSerial(sensaPort);
    tab.setAddressList(addressList);
    output.println(width + " " + height);
    for(Integer mapKey : addressList.keySet()){
      output.println(mapKey + " " + addressList.get(mapKey));
    }
    output.flush();
    output.close();
    println("End Of autoAddressing\nheight :" + height + "\t width :"+width);
    
    return tab;
  }
  
  public Array fileAddressing(String fileName){
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
    Array tab = new Array(width*4,height*4);
    tab.setSerial(sensaPort);
    tab.setAddressList(addressList);
    return tab;
  }
  
  public void Update(){
    tab.fullListenning();
    for(Integer i : getDifferentModule(tab,previousArray))
      tab.moduleDisplay(i);
    previousArray = colorCopy();
    
  }
  
  private ArrayList<Integer> getDifferentModule(Array firstTab, Array LastTab){
    ArrayList<Integer> addressList = new ArrayList<Integer>();
    
    for(int j=0;j<firstTab.getHeight();j++)
      for(int i=0;i<firstTab.getWidth();i++){
        if(firstTab.getColor(i,j) != LastTab.getColor(i,j)){
          addressList.add(firstTab.getAddress(i,j));
        }
      }
      
    return addressList;
  }
  
  public Array getArray(){
    return tab;
  }
  
  private Array colorCopy(){
    Array copy = new Array(this.tab.getWidth(), this.tab.getHeight());
    for(int j=0; j<tab.getHeight(); j++)
      for(int i=0; i<tab.getWidth(); i++){
        copy.setColor(i,j,tab.getColor(i,j));
      }
    
    return copy;
  }
}
