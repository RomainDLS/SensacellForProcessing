
public class Drawing{
  private Array tab;
  private Serial sensaPort;
  
  public Drawing(){
    tab = new Array(8*4,6*4);
    tab.Addressing("Addressing.txt");    
  }
  
  public void setSensaPort(Serial sensaPort){
    this.sensaPort = sensaPort;
    tab.setSerial(sensaPort);
    tab.FullDisplay();
  }
  
  public void Update(){
    tab.sensorListenning();
  }
  
  
  public Array getArray(){
    return tab;
  }
  
  public void setArray(Array tab){
    this.tab = tab;
  }
}
