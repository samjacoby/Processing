/*
 * Represents the entire board, containing @param NUM_CLIPS clips
 *
 */

class PaperClip {

    Minim m;
  
    final int NUM_CLIPS = 3;
  
    private int TIMER = 5000;
    private ArrayList <Clip> clips = new ArrayList();
  
    // Clip mapping from PaperClip board
    private int[] clipMap = {0x01, 0x02, 0x04};

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
  
    public void update(int capVal) {

        TapSample ts = null;
        Clip c = null;

        // scan over active clips
        for(int i = 0; i < NUM_CLIPS; i++) {
            c = clips.get(i);

            if(c.isPressed(capVal)) {
                if(!c.isHeld()) { 
                    c.trigger();
                } else {
                    if(!c.isRecording) {
                        println("####### Recording on clip " + c.clipMap);
                        ts = new TapSample(m);
                        ts.record(); 
                        c.isRecording = true;
                        c.setSample(ts);
                    }
                }

            } else if(c.isReleased && c.isRecording) {
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
      this.isPressed = false; // everything should be initalized false
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
    
 
    protected boolean isPressed(int bitMask) {


        // check serial data against this clip's value
        if((bitMask & clipMap ) != 0) {
            isPressed = true;
        } else {
            isPressed = false;     
        } 

        if(!lastState && isPressed) {
            println("FIRST PRESS");
            for(int i=0;i< 10;i++) println("########");
            // we've just pressed the button for the first time 
            lastTimePressed = millis();
        }  
        
        if(lastState && isPressed) {
            // we're being held down, still 
            if(millis() - lastTimePressed > parent.TIMER) {
                println("WE ARE HELD.");
                isHeld = true; // this should trigger record in the mothership 
            } else {
               isHeld = false;
            } 
        }

        if(lastState && !isPressed) {
            // we've just let go of the button
            isReleased = true;
            // we could be transitioning straight from held
            isHeld = false;
        } else {
            isReleased = false;
        }

        // record last state
        lastState = isPressed;

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
