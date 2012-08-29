/*
 * Represents the entire board, containing @param NUM_CLIPS clips
 *
 */

class PaperClip {
  
  final int NUM_CLIPS = 3;
  
  private int TIMEOUT;
  private ArrayList <Clip> clips = new ArrayList();
  
  // Clip mapping from PaperClip board
  private int final clipMap[] = {0x01, 0x02, 0x04};

  PaperClip() {
    
    for(int i=0; i < NUM_CLIPS; i++) {
      clips.add(new Clip(this), clipMap[i]);
    }  
  }
  
  public void update(int capVal) {
    
    // scan over active clips
    for(int i = 0; i < NUM_CLIPS; i++) {
        if(clips[i].isPressed(capVal)) {
            clips[i].trigger();
        } 
    }
  }
  

  
}



class Clip {
  
    Box soundBox;
    int touchThreshold;

    boolean lastState;
    int lastPressed;
    
    int clipMap;
    
    boolean isPressed;
    boolean isHeld;
    
    PaperClip parent;
    
    /* 
     * 
     * @param p
     *             the parent board of this specific clip 
     *
     * @param c
     *             the bitmapping of this specific clip
     *              
     */
     
    Clip(PaperClip p, int c) {
      this.parent = p;
      this.clipMap = c;
      this.isPressed = false; // everything should be initalized unpressed

    }
    
    Clip(Box b) {
      this.soundBox = b;
    }

    void trigger() {
        try {
            this.soundBox.trigger(); 
        } catch(NullPointerException e) {
            println("No sound associated with clip " + clipMask);
        }
    }

    
    Box getBox() {
      return soundBox;
    }
    
    void setBox(Box b) {
      this.soundBox = b;  
    }
 
    boolean protected isPressed(int bitMask) {

        // record last state
        lastState = isPressed;

        if((bitMask & clipMask ) != 0) {
            isPressed = true;
        } else {
            isPressed = false;     
        } 
        
        if(lastState && isPressed) {
            // we haven't changed state
            if(millis() - lastTimePressed > parent.TIMER) {
                // should trigger record 
            } 
        }

        if(!lastState && isPressed) {
            // we've toggled
            lastTimePressed = millis();
        }


        return isPressed;
    }
    
    void isHeld() {
        
    }
}
