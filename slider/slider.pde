import processing.serial.*;

Serial myPort;        // The serial port

final int NUMPINS = 5;      // Number of inputs we want to graph

/**
 * Packet Specifications 
 *
 * These parameters describe the protocol of the way that we interact with 
 * our Arduino application.
 **/

// Integer value of start byte 
final int START = -2;
// Buffer until something < 127 or bufferUntil fails
final char END = 0x71;
final int MESSAGESIZE = 15;

// List of the number of segments in the slider
final int OFFSET = 1;
ArrayList<Segment> segmentList = new ArrayList<Segment>();

// Utility variables
Boolean calibrate = false;

void setup () {//{{{

    println(Serial.list());
    try {
        myPort = new Serial(this, Serial.list()[0], 57600);
    } catch(Exception e) { 
        println(e.getMessage());
    }

    // don't generate a serialEvent() unless you get an END charachter
    myPort.bufferUntil(int(END));

    for(int i=0; i< NUMPINS;i++) {
        segmentList.add(new Segment(OFFSET + i)); 
    }
}//}}}

void draw () {//{{{
// everything happens in the serialEvent()
}

void calibrate() {
    calibrate = !calibrate;
    for(Segment s: segmentList) {
        if(!calibrate) 
            println(s.maxVal);
        else {
        s.maxVal = 0;
        }
    }
}//}}}
class Segment {//{{{
    int maxVal = 1;

    int segmentOffset;

    Segment nextSegment;
    Segment prevSegment;

    Segment(int segmentOffset) {
        this.segmentOffset = segmentOffset;
    }

    void setMax(int newMax) {
        maxVal = (newMax > maxVal) ? newMax: maxVal; 
    }

    float normVal(int val, float normal) {
        if(val > maxVal) {
            println("Value out of range: recalibrating..."); 
            this.setMax(val);
        }
        float norm = (float)val/normal * segmentOffset;
        println(val + " : " + norm + " : " + maxVal + " : " + segmentOffset);
        return norm;
    }
}//}}}

void calibrateSegments(byte[] inBuffer) {
    int i = 0;
    for(Segment s: segmentList) {
        s.setMax(inBuffer[i+2]);
        i++;
    }


}

void serialEvent(Serial myPort) {//{{{

    byte[] inBuffer = new byte[MESSAGESIZE];
    int i = 0, sumValues = 0;
    float totalNormalized = 0, finalVal = 0;
    int bytesRead = myPort.readBytesUntil(END, inBuffer);

    if(bytesRead > 0 && (inBuffer[0] == START) && (inBuffer[inBuffer.length -1 ] == END)) { 
        if(calibrate) {
            calibrateSegments(inBuffer);
        } else {
            for(i = 2; i < inBuffer.length - 1; i++) {
                sumValues += inBuffer[i]; 
            }
            i = 2;
            for(Segment s: segmentList) {
                totalNormalized += s.normVal(inBuffer[i], sumValues);
                i++;
            }
            finalVal = totalNormalized/NUMPINS;
            println(finalVal);
        }
    }
}//}}}
/**
 * Accept commands 
 **/
void keyReleased() {   //{{{
    if(key == ' ') {
        println("Sending signal.");
        myPort.write('a'); 
    } else if(key == 'c') {
        calibrate();
        if(calibrate) {
        println("Beginning calibration...");
        println("Please swipe your finger over.");
        } else {
        println("Ending calibration...");
        } 
    }
}//}}}


