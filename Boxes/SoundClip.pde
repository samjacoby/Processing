import ddf.minim.*;

class SoundClip {
  
  AudioRecorder recorder;
  AudioPlayer clip;
  AudioInput in;
  Minim minim; 
  String filename;
  
  SoundClip(Minim m) {
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
    clip = m.loadFile(filename);
  }

  protected void save() {
    recorder.save();
  }
  
}

