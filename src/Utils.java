
public class Utils {
	Sensacell tab;


	public Utils(Sensacell Array){
		tab = Array;
	}

	public void DrawFilledCircle(int x0, int y0, int radius, int Color){
		int x = radius;
		int y = 0;
		int xChange = 1 - (radius << 1);
		int yChange = 0;
		int radiusError = 0;

		while (x >= y){
			for (int i = x0 - x; i <= x0 + x; i++){
				tab.setColor(i, y0 + y, Color);
				tab.setColor(i, y0 - y, Color);
			}
			for (int i = x0 - y; i <= x0 + y; i++){
				tab.setColor(i, y0 + x, Color);
				tab.setColor(i, y0 - x, Color);
			}

			y++;
			radiusError += yChange;
			yChange += 2;
			if (((radiusError << 1) + xChange) > 0){
				x--;
				radiusError += xChange;
				xChange += 2;
			}
		}
	}

	public void DrawCircle(int x0, int y0, int radius, int Color){
		int x = radius;
		int y = 0;
		int decisionOver2 = 1 - x;   // Decision criterion divided by 2 evaluated at x=r, y=0

				while(x >= y){
					tab.setColor( x + x0,  y + y0, Color);
					tab.setColor( y + x0,  x + y0, Color);
					tab.setColor(-x + x0,  y + y0, Color);
					tab.setColor(-y + x0,  x + y0, Color);
					tab.setColor(-x + x0, -y + y0, Color);
					tab.setColor(-y + x0, -x + y0, Color);
					tab.setColor( x + x0, -y + y0, Color);
					tab.setColor( y + x0, -x + y0, Color);
					y++;
					if (decisionOver2<=0){
						decisionOver2 += 2 * y + 1;   // Change in decision criterion for y -> y+1
					}
					else{
						x--;
						decisionOver2 += 2 * (y - x) + 1;   // Change for y -> y+1, x -> x-1
					}
				}
	}
}
