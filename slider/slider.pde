import processing.serial.*;

Serial myPort;        // The serial port

final int NUMPINS = 5;      // Number of inputs 

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
final int MESSAGESIZE = 8;

// List of the number of segments in the slider
final int OFFSET = 1;
List<Segment> segmentList = new ArrayList<Segment>();

/**
 * Utility Variables
 **/
Boolean calibrate = false;
Boolean wrapAround = true; // should we wrap around?
// Anything below this isn't a touch.
float THRESHOLD = .2; 
// Average over a number of samples
float sampleVal = 0;
int sampleCount = 0;
int sampleMax = 3;

// Things to Draw
Marker m;

void setup () {//{{{

    background(0);
    size(400, 400);

    try {
        println(Serial.list());
        myPort = new Serial(this, Serial.list()[0], 57600);
    } catch(Exception e) { 
        println(e.getMessage());
    }

    // don't generate a serialEvent() unless you get an END charachter
    myPort.bufferUntil(int(END));

    int offset[] = {4,3,1,2,5}; // control ordering

    for(int i=0; i< NUMPINS;i++) {
        segmentList.add(new Segment(offset[i])); 
    }

    m = new Marker();

}//}}}

void draw () {//{{{
    // Nothing happens here at all. 
}//}}}

void calibrate() {//{{{
    calibrate = !calibrate;
    for(Segment s: segmentList) {
        if(!calibrate) 
            println(s.maxVal);
        else {
        s.maxVal = 0;
        }
    }
}
//}}}
class Segment {//{{{

    int segmentOffset; // this value determines the segments position
    int maxVal = 1;
    int currentVal = 0;

    Segment nextSegement = null;


    Segment(int segmentOffset) {
        this.segmentOffset = segmentOffset;
    }

    void setMax(int newMax) {
        maxVal = (newMax > maxVal) ? newMax: maxVal; 
    }

    float normVal(int val, float normal) {
        if(val > maxVal) { // keep track of maximum values
            println("Value out of range: recalibrating..."); 
            this.setMax(val);
        }
        float normedVal = ((float)val/maxVal)/normal;
        float norm = normedVal * segmentOffset; // normalize & apply offset 
        //println(val + " : " + maxVal +" : " + normedVal  + " : " + normal);
        return norm;
    }
}//}}}
void calibrateSegments(byte[] inBuffer) {//{{{
    int i = 0;
    for(Segment s: segmentList) {
        s.setMax(inBuffer[i+2]);
        i++;
    }
}//}}}

void serialEvent(Serial myPort) {//{{{

    background(0);
    /*
    sampleCount++;
    if(sampleCount >= sampleMax) {
        background(0);
        println(sampleVal);
        fill(200);
        m.update(sampleVal/sampleMax, 200);
        m.display();
        sampleVal = 0;
        sampleCount = 0; 
    }
    */

    byte[] inBuffer = new byte[MESSAGESIZE];
    int[] inBufferInt = new int[NUMPINS];

    int i = 0, mappedVal;
    float totalNormalized = 0, sumValues = 0, finalVal = 0, mappedVal_f;
    int bytesRead = myPort.readBytesUntil(END, inBuffer);

    if(bytesRead > 0 && (inBuffer[0] == START) && (inBuffer[MESSAGESIZE - 1] == END)) { 

        if(calibrate) {
            calibrateSegments(inBuffer);
        } else {

            for(i=0;i < NUMPINS; i++ ){
                // java has no unsigned bytes. boo.
                inBufferInt[i] = (inBuffer[i+2] < 0) ? inBuffer[i+2] + 256 : inBuffer[i+2]; 
            }

            //println(inBufferInt);

            // get normalization values
            i = 0;
            for(Segment s: segmentList) {
                assert(inBufferInt[i] >= 0); 
                sumValues += (float)inBufferInt[i]/s.maxVal; // normalize each value
                i++;
            }

            if(sumValues > THRESHOLD) {
                i = 0;
                for(Segment s: segmentList) {
                    totalNormalized += s.normVal(inBufferInt[i], sumValues);
                    i++;
                }

                //println(totalNormalized);
                
                finalVal = totalNormalized/NUMPINS;
                mappedVal_f = floor(map(finalVal, .2, 1, 10, 390));
                //mappedVal_f = map(finalVal, .2, 1, 0, 2*PI);
                //sampleVal += mappedVal_f;
                m.update(mappedVal_f, 200);
                m.display();
            }
        }
    } else {
        myPort.clear();
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

class Marker {
    float x, y;
    float w=20, h=20;

    void update(float x, float y ) {
        this.x = x;
        this.y = y;
    }

    void update(float x, float y, float w, float h) {
        this.x = x;
        this.y = y;
        this.w = w; 
        this.h = h;
    }
    
    void display() {
        fill(160, 100, 35);
        //ellipse(75 * cos(val) + 200, 75 * sin(val) + 200, 18,18);
        ellipse(x, y, w, h);
    }//}}}
        
    
    
}





