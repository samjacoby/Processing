/*
 *
 * Sound Box
 *
 * This represents a  of some kind.
 */

class SoundBox {

   int x, y;
   int width, height;
   color f_color;
    
   TapSample sample;
    
   SoundBox(int x, int y) {
     
      this.f_color = color(0);
      this.x = x;
      this.y = y;
      
    }
    
    public void setSample(TapSample s) {
      
      this.sample = s;  
    
    }
    
    public void trigger() {
  
      this.sample.trigger();
  
    }
    
    public void drawBox() {
      
        rectMode(CORNER);
        fill(f_color);   
        rect(this.x, this.y, this.width, this.height);
    }

    
     public void drawBox(int width, int height) {
       
        rectMode(CORNER);
        fill(f_color);
        this.width = width;
        this.height = height;
        rect(this.x, this.y, width, height);
        
    }
    
    public void setDimensions(int width, int height) {
      
        this.width = width;
        this.height = height;  
        
    }
    

   public boolean mouseIsOver() {
     
     if(XIntersect() && YIntersect()) {
       return true;
     }
     return false;
   }
   
   private boolean XIntersect() {
       
       if(mouseX >= x && mouseX <= (x + width)) {
         return true; 
       }
       return false;
     }
   
   private boolean YIntersect() {
     if(mouseY >= y && mouseY <=(y + height)) {
       return true;
     }  
     return false;
   }
   
}
