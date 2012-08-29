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
    private int final clipMap[] = {0x01, 0x02, 0x04};


    PaperClip(Minim m) {

        this.m = m;

        for(int i=0; i < NUM_CLIPS; i++) {
          clips.add(new Clip(this), clipMap[i]);
        } 

    }
  
    public void update(int capVal) {

        TapSample ts = null;

        // scan over active clips
        for(int i = 0; i < NUM_CLIPS; i++) {
            if(clips[i].isPressed(capVal)) {
                if(!clips[i].isHeld()) { 
                    if(clips[i].isRecording) {
                        ts = clips[i].getSample();
                        ts.save();  
                    } else {
                        clips[i].trigger();
                    }
                } else {
                    TapSample ts = new TapSample(m);
                    ts.record(); 
                    clips[i].isRecording = true;
                    clips[i].setSample(ts);
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
    int lastPressed;        // last pressed time 
    
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
      return soundBox;
    }
    
    TapSample setSample(TapSample s) {
      this.soundBox = s;  
    }
    
    void trigger() {
        try {
            this.soundSample.trigger(); 
        } catch(NullPointerException e) {
            println("No sound associated with clip " + clipMask);
        }
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
