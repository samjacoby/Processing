import ddf.minim.*;

class TapSample {

  Minim minim; 
  
  AudioSample clip;
  AudioRecorder recorder;
  AudioInput in;

  private AudioSnippet recordingChime;

  private final float thresholdSound = .007;
  
  String filename;
  String dir = "sounds";
  
  TapSample(Minim m) {
    this.minim = m;
    this.in = minim.getLineIn(Minim.STEREO, 2048);
    this.filename = dataPath(String.format("%s.%s", java.util.UUID.randomUUID(), "wav"));
    this.recorder = minim.createRecorder(in, filename, true);

    // play a chime when recording
    //recordingChime = m.loadSnippet("assets/ding.wav");
  }
  
  TapSample(Minim m, String filename) {
    
    this.minim = m;
    this.in = minim.getLineIn(Minim.STEREO, 2048);
    this.filename = filename;
    this.recorder = minim.createRecorder(in, filename, true);
    
    this.loadSample();
  }
  
  public boolean isRecording() {
    return recorder.isRecording();
  }

  public void record() {
   
    // this is going to cause problems 

  /* recordingChime.play();
   while(recordingChime.isPlaying()) {
    delay(5);
   }
   recordingChime.rewind();   
*/
   
   // don't record until we get meaningful levels
   while(in.mix.level() < thresholdSound);
   println("<<<<<<<<<<<<<<<<<< RECORDING >>>>>>>>>>>>>>>>>");
   recorder.beginRecord();

  }
  
  public void trigger() {
    this.clip.trigger();
  }
  
  public AudioSample getClip() {
    return clip;
  }
  
  public int getLength() {
    return this.clip.length();  
  }
  
  public String getFilename() {
    return this.filename;
    
  }
  
  public void endRecording() {  
    
    recorder.endRecord();
    
    in.close();
    this.save();   

    this.loadSample();  

  }
  
  private void loadSample() {
    clip = m.loadSample(this.filename);

  }


  protected void save() {
    recorder.save();
  }
  
}
