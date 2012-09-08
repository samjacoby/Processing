/*
 * Represents the entire board, containing @param NUM_CLIPS clips
 *
 */

class PaperClip {

    Minim m;
  
    final int NUM_CLIPS = 5;
  
    private int TIMER = 2000;
    private ArrayList <Clip> clips = new ArrayList();
  
    // Clip mapping from PaperClip board
    private int[] clipMap = {1, 2, 4, 8, 16 };

    private int lastCapVal = 0;
    
    private color[] clipColors;
    private String name; 

    PaperClip(Minim m) {

        this.m = m;

        for(int i=0; i < NUM_CLIPS; i++) {
          clips.add(new Clip(this, clipMap[i]));
        } 

    }
    
    PaperClip(Minim m, String[] filenames) {
        
        TapSample ts;
        Clip c;
        this.m = m; 
        
        for(int i=0; i < NUM_CLIPS; i++) {
          c = new Clip(this, clipMap[i]);
          println(filenames[i]);
          println(filenames[i].getClass().getName());
          if(!filenames[i].equals("none")) {
            println("!??");
            ts = new TapSample(m, filenames[i]);
            c.setSample(ts);
          }
          println("here?");
          clips.add(c);
        } 

      
    }
  
    public int numClips() {
       return NUM_CLIPS; 
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
                        if(c.soundSample != null) {
                          delay(c.soundSample.clip.length());
                        }
                                                c.isRecording = true;

                   println("####### NOW! on clip " + c.clipMap);

                        ts = new TapSample(m);
                        ts.record(); 
    
                       c.setSample(ts);
   
              } else if (!c.isTriggered) {
    
                    c.trigger();
                    c.isTriggered = true;
                }

            } else if(c.isRecording) {
              
                println("Finishing recording on clip " + c.clipMap);
                
                c.isRecording = false;
                ts = c.getSample();
                delay(200);
                ts.endRecording();
                ts.save();
                c.clipLength = ts.getLength();
              
          }
        }
    }
    
    Iterator <Clip> getClipsIter() {
      return clips.iterator();  
    }
}



class Clip {
  
    TapSample soundSample;  // this clip's sample

    int touchThreshold;     // sensitivity of the trigger

    boolean lastState;      // last pressed state of this clip
    int lastTimePressed;    // last pressed time 
    
    int clipLength;         // the clip length in millis
    
    int clipMap;            // ID of pin on board 

    /*
     * TODO: take care of this rats nests of booleans.
     *
     */
     

    boolean isPressed;      // is this pin pressed?
    boolean isHeld;         // forget pressed -- is it held down?
    boolean isReleased;     // was this clip just released? 
    boolean isTriggered;    // has this clip been triggered?
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
    
    public String getFilename() {
      return this.getSample().getFilename();
          }
    
    void setSample(TapSample s) {
      this.soundSample = s;  
    }
    
    public boolean hasSample() {
      if(soundSample != null) {
        return true;
      }
      return false;
    }
    
    void clearSample() {
      this.soundSample = null;  
    }
    
    public boolean isPlaying() {
      if(millis() - lastTimePressed < clipLength) {
        return true;  
      }
      
      return false;
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
        if(inBuffer[0] == PRESS) {  // first byte holds the event type
            if((inBuffer[1] & clipMap) != 0) {  // is this clip touched?
              isPressed = true;
              lastTimePressed = millis();
            } else if(((inBuffer[1] & clipMap) == 0) && isPressed) { // was this clip touched--and released?
              isPressed = false;
              isHeld = false;
              isTriggered = false;
            }
         } 
         
         // check if we're still pressed and initiate hold if we are
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
