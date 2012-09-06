/*
 * Represents the entire board, containing @param NUM_CLIPS clips
 *
 */

class PaperClip {

    Minim m;
  
    final int NUM_CLIPS = 6;
  
    private int TIMER = 5000;
    private ArrayList <Clip> clips = new ArrayList();
  
    // Clip mapping from PaperClip board
    private int[] clipMap = {1, 2, 4, 8, 16, 32 };

    private int lastCapVal = 0;

    PaperClip(Minim m) {

        this.m = m;

        for(int i=0; i < NUM_CLIPS; i++) {
          clips.add(new Clip(this, clipMap[i]));
        } 

    }

    public void closeAll() {
      
        TapSample ts = null;
        Clip c = null;
        
        for(int i = 0; i < NUM_CLIPS; i++) {
            c = clips.get(i);
            if(c.isRecording) {
                ts = c.getSample();
                ts.endRecording();
                ts.save();
            }
            c.clearSettings();
        }
    }
  
    public void update(byte[] buffer) {

        TapSample ts = null;
        Clip c = null;

        // scan over active clips
        for(int i = 0; i < NUM_CLIPS; i++) {
            
          c = clips.get(i);

            if(c.isPressed(buffer)) {
              
                if(c.isHeld & !c.isRecording) {
                  println("####### Recording on clip " + c.clipMap);
                        ts = new TapSample(m);
                        ts.record(); 
                        c.isRecording = true;
    
                       c.setSample(ts);
   
              } else if (!c.isTriggered) {
    
                    c.trigger();
                    c.isTriggered = true;
                }

            } else if(c.isRecording) {
                println("Finishing recording on clip " + c.clipMap);
                c.isRecording = false;
                ts = c.getSample();
                ts.endRecording();
                ts.save();  
            }
        }
    }
}



class Clip {
  
    SoundBox soundBox;      // presently unused
    TapSample soundSample;  // this clip's sample

    int touchThreshold;     // sensitivity of the trigger

    boolean lastState;      // last pressed state of this clip
    int lastTimePressed;        // last pressed time 
    
    int clipMap;            // ID of pin on board 

    boolean isPressed;      // is this pin pressed?
    boolean isHeld;         // forget pressed -- is it held down?
    boolean isReleased;     // was this clip just released? 
    boolean isTriggered;      // has this clip been triggered?
    boolean isRecording;    // are we recording NOW?
    
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
      this.clipMap = c;  // actual values relayed from hardware
      
      this.isPressed = false; // everything should be initalized false
      this.isTriggered = false;
      this.isRecording = false; 
      this.isReleased = false;
      

    }

    TapSample getSample() {
      return soundSample;
    }
    
    void setSample(TapSample s) {
      this.soundSample = s;  
    }
    
    void trigger() {
        try {
            this.soundSample.trigger(); 
            println("Play sound here.");
        } catch(NullPointerException e) {
            println("No sound associated with clip " + clipMap);
        }
    }
    
 
    protected boolean isPressed(byte[] inBuffer) {

        // check serial data against this clip's value
        if(inBuffer[0] == PRESS) {
            if((inBuffer[1] & clipMap) != 0) {
              isPressed = true;
              lastTimePressed = millis();
              println("PRESS");
            } else if(((inBuffer[1] & clipMap) == 0) && isPressed) {
              println("RELEASE");
              isPressed = false;
              isHeld = false;
              isTriggered = false;
            }
         } 
         
         // check if we're still pressed
         if(!isHeld && isPressed && (millis() - lastTimePressed > parent.TIMER)) {
             println("HOLD");
             isHeld = true;
         }

        return isPressed;
    }
    
    boolean isHeld() {
        return this.isHeld;    
    }
    
    boolean isRecording() {
        return this.isRecording;    
    }

    void clearSettings() {
      this.isPressed = false; // everything should be initalized false
      this.isRecording = false; 
      this.isReleased = false; 
      this.isHeld = false;
    }


}
