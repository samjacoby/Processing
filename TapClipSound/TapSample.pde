import ddf.minim.*;

class TapSample {
  
  AudioSample clip;
  AudioRecorder recorder;
  AudioInput in;
  Minim minim; 
  
  private final float thresholdSound = .001;
  
  String filename;
  
  TapSample(Minim m) {
    this.minim = m;
    this.in = minim.getLineIn(Minim.STEREO, 2048);
    this.filename = String.format("%s.%s", java.util.UUID.randomUUID(), "wav");  
    this.recorder = minim.createRecorder(in, filename, true);
  }
  
  public boolean isRecording() {
    return recorder.isRecording();
  }

  public void record() {
    
   // Don't record until we get meaningful levels
   while(in.mix.level() < thresholdSound);

   recorder.beginRecord();
  }
  
  public void trigger() {
    this.clip.trigger();
  }
  
  public void endRecording() {  
    recorder.endRecord();
    
    in.close();
    this.save();   
    
    this.loadSample();
    
  }
  
  private void loadSample() {
    clip = minim.loadSample(this.filename, 2048);
  }
  
  private void whiteSpaceScrub() {
    
       
    
         float[] leftChannel = clip.getChannel(BufferedAudio.LEFT);
         float[] rightChannel = clip.getChannel(BufferedAudio.RIGHT);
         println(leftChannel.length);
         println(rightChannel.length);
         float maxi = 0;
         float mini = 0;
           
         for(int i=0; i < leftChannel.length; i++ ){
           if(leftChannel[i] > thresholdSound) {
            break; 
           }
         }
         
  }


  protected void save() {
    recorder.save();
  }
  
}
