/*
 * Represents the entire board, containing @param NUM_CLIPS clips
 *
 */

class PaperClip {

    Minim m;
  
    final int NUM_CLIPS = 3;
  
    private int TIMER = 1000;
    private ArrayList <Clip> clips = new ArrayList();
  
    // Clip mapping from PaperClip board
    private int[] clipMap = {0x01, 0x02, 0x04};


    PaperClip(Minim m) {

        this.m = m;

        for(int i=0; i < NUM_CLIPS; i++) {
          clips.add(new Clip(this, clipMap[i]));
        } 

    }
  
    public void update(int capVal) {

        TapSample ts = null;
        Clip c = null;

        // scan over active clips
        for(int i = 0; i < NUM_CLIPS; i++) {
            c = clips.get(i);
            if(c.isPressed(capVal)) {
                if(!c.isHeld()) { 
                    if(c.isRecording) {
                        c.isRecording = false;
                        ts = c.getSample();
                        ts.save();  
                    } else {
                        c.trigger();
                    }
                } else {
                    if(!c.isRecording) {
                        ts = new TapSample(m);
                        ts.record(); 
                        c.isRecording = true;
                        c.setSample(ts);
                    }
                }

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
      this.clipMap = c;
      this.isPressed = false; // everything should be initalized unpressed
      this.isRecording = false; // we're not recording now, punk

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
        } catch(NullPointerException e) {
            println("No sound associated with clip " + clipMap);
        }
    }
    
 
    protected boolean isPressed(int bitMask) {

        // record last state
        lastState = isPressed;

        if((bitMask & clipMap ) != 0) {
            isPressed = true;
        } else {
            isPressed = false;     
        } 
        
        if(lastState && isPressed) {
            // we haven't changed state after all
            if(millis() - lastTimePressed > parent.TIMER) {
                isHeld = true; // this should trigger record in the mothership 
            } 
        }

        if(!lastState && isPressed) {
            // we've toggled
            lastTimePressed = millis();
        }

        return isPressed;
    }
    
    boolean isHeld() {
        return this.isHeld;    
    }
    
    boolean isRecording() {
        return this.isRecording;    
    }
}
