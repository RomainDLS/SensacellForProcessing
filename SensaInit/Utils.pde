void DrawCircle(int x0, int y0, int radius, int Color){
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
