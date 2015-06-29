
public class Cell {
	private int colorValue;
	private int moduleAddress;
	private int sensorValue;

	protected int getModuleAddress() {
		return moduleAddress;
	}

	protected void setAddressModule(int AddressModule) {
		this.moduleAddress = AddressModule;
	}

	protected int getSensorValue() {
		return sensorValue;
	}

	protected void setSensorValue(int sensorValue) {
		this.sensorValue = sensorValue;
	}

	protected Cell(int colorValue) {
		// TODO Auto-generated constructor stub
		this.colorValue = colorValue;
		sensorValue = 0;
	}

	protected int getColorValue() {
		return colorValue;
	}

	protected void setColorValue(int colorValue) {
		this.colorValue = colorValue;
	}
}
