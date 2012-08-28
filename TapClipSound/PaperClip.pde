class PaperClip {
  
  final int NUM_CLIPS = 3;
  ArrayList <Clip> clips = new ArrayList();
  
}



class Clip {
  
    Box soundBox;
    int touchThreshold;
    
    Clip(Box b) {
      this.soundBox = b;
    }
    
    Box getBox() {
      return soundBox;
    }
    
    void setBox(Box b) {
      this.soundBox = b;  
    }
    
    void isPressed() {
        
    }
}
