import ddf.minim.*;

class TapSample {
  
  AudioSample clip;
  AudioRecorder recorder;
  AudioInput in;
  Minim minim; 
  
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
    
    recorder.beginRecord();
  }
  
  public void endRecording() {  
    recorder.endRecord();
    
    in.close();
    this.save();   
    
    clip = minim.loadSample(this.filename, 2048);
  }

  protected void save() {
    recorder.save();
  }
  
}
