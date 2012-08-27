/*
 *
 * Sound Box
 *
 * This represents a box of some kind.
 */

class Box {

    float x, y;
    color f_color;
    
    Box(float x, float y) {
     
      this.f_color = color(0);
      this.x = x;
      this.y = y;
    }

    public void drawBox(float width, float height) {
        rectMode(CENTER);
        fill(f_color); 
        rect(this.x, this.y, width, height);
    }
}

