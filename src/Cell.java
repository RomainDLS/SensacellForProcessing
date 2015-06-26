
public class Cell {
	private int colorValue;
	private int moduleAddress;
	private int sensorValue;

	public int getModuleAddress() {
		return moduleAddress;
	}

	public void setAddressModule(int AddressModule) {
		this.moduleAddress = AddressModule;
	}

	public int getSensorValue() {
		return sensorValue;
	}

	public void setSensorValue(int sensorValue) {
		this.sensorValue = sensorValue;
	}

	public Cell(int colorValue) {
		// TODO Auto-generated constructor stub
		this.colorValue = colorValue;
		sensorValue = 0;
	}

	public int getColorValue() {
		return colorValue;
	}

	public void setColorValue(int colorValue) {
		this.colorValue = colorValue;
	}
}
