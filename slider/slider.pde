import processing.serial.*;
import java.math;

Serial myPort;        // The serial port

final int NUMPINS = 4;      // Number of inputs 

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

// Anything below this isn't a touch.
double THRESHOLD = .2; 

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

    //int offset[] = {4,3,1,2,5}; // control ordering
    double offset[] = {PI/2,PI,3*PI/2, 2*PI};

    for(int i=0; i< NUMPINS;i++) {
        Segment s = new Segment();
        segmentList.add(s); 
    }

    m = new Wheel();

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

void serialEvent(Serial myPort) {//{{{

    //background(0);

    byte[] inBuffer = new byte[MESSAGESIZE];
    int[] inBufferInt = new int[NUMPINS];

    int i = 0, mappedVal;
    double totalNormalized = 0, sumValues = 0, finalVal = 0, mappedVal_f;
    int bytesRead = myPort.readBytesUntil(END, inBuffer);

    if(bytesRead > 0 && (inBuffer[0] == START) && (inBuffer[MESSAGESIZE - 1] == END)) { 

        if(calibrate) {
            //calibrateSegments(inBuffer);
        } else {

            String smsg = ""; 
            for(i=0;i < NUMPINS; i++ ){
                // java has no unsigned bytes. boo. no negatives.
                inBufferInt[i] = (inBuffer[i+2] < 0) ? inBuffer[i+2] + 256 : inBuffer[i+2]; 
                smsg += inBufferInt[i] + ", ";
            }
            println(smsg);

            i = 0;
            for(Segment s: segmentList) {
                assert(inBufferInt[i] >= 0); 
                s.setRawVal(inBufferInt[i]);
                i++;
            }

            m.plot(segmentList);
            m.display();
        }
    } else {
        myPort.clear();
    }
}//}}}

/**
 * This is an interface element
 *
 **/ 
interface Marker {

    void update(double x, double y ); 
    void update(double x, double y, double w, double h); 
    void plot(List<Segment> segments);
    void display(); 

}

/**
 * This is a marker segment. It keeps track of its maximum 
 * value and normalizes itself against that. That's about it.
 *
 **/

class Segment {//{{{

    double rawVal;
    double maxVal;
    double selfNormalizedVal;
    double groupNormalizedVal;

    public void setRawVal(int newRawVal) {
        this.rawVal = (double) newRawVal;
        this.updateMax();
    }

    public double getSelfNormalizedVal() {
        selfNormalize();
        return selfNormalizedVal;
    
    }

    public double getGroupNormalizedVal(double totalVal) {
        groupNormalize(totalVal);
        return groupNormalizedVal; 
    }

    public void groupNormalize(double totalVal) {
        groupNormalizedVal = selfNormalizedVal / totalVal; 
    }

    private void updateMax() {
        maxVal = (rawVal > maxVal) ? rawVal: maxVal; 
    }

    public void selfNormalize() {
        selfNormalizedVal = rawVal / maxVal; 
    }


}//}}}

/**
 * This is a Slider.
 *
 **/
class Slider implements Marker {

    double direction[] = {4,3,1,2,5};

    double x, y;
    double w=20, h=20;

    void update(double v) {
        this.x = v;
        this.y = v;
    }

    void update(double x, double y ) {
        this.x = x;
        this.y = y;
    }

    void update(double x, double y, double w, double h) {
        update(x, y);
        this.w = w; 
        this.h = h;
    }

    void plot(List<Segment> segments) {
        int i = 0, j = 0;
        double totalValue = 0, checkValue = 0, averageValue = 0;

        // normalize initial values and get totals
        for(Segment s: segments) {
            totalValue += s.getSelfNormalizedVal(); 
        }

        // normalize each value against all values
        for(Segment s:segments) {
            s.groupNormalize(totalValue);
        }

        for(Segment s: segments) {
            checkValue += s.groupNormalizedVal;
        }

        // let it be a little fuzzy, eh?
        assert(checkValue >= .99 && checkValue <= 1.01);

        i = 0;
        for(Segment s: segments) {
            averageValue += s.groupNormalizedVal * direction[i];
            i++;
        }
        println(averageValue);

        update(averageValue, height/2);
    }
    
    void display() {
        fill(160, 100, 35);
        x = map(x, 0, 5, 0, width);
        ellipse(x, y, w, h);
    }
    
}

/**
 * This is a wheel. 
 *
 **/
class Wheel implements Marker {

    double direction[] = {PI/2,PI,3*PI/2, 2*PI};

    double x, y;
    double w=20, h=20;

    void update(double x, double y) {
        this.x = 100*cos(x) + width/2;
        this.y = 100*sin(y) + height/2;
    }

    void update(double x, double y, double w, double h) {
        update(x, y);
        this.w = w; 
        this.h = h;
    }

    void plot(List<Segment> segments) {
        int i = 0, j = 0;
        double totalValue = 0, checkValue = 0, averageValue = 0;

        // normalize initial values and get totals
        for(Segment s: segments) {
            totalValue += s.getSelfNormalizedVal(); 
        }

        // normalize each value against all values
        for(Segment s:segments) {
            s.groupNormalize(totalValue);
        }

        for(Segment s: segments) {
            checkValue += s.groupNormalizedVal;
        }

        assert(checkValue >= .99 && checkValue <= 1.01);

        double xVal = (segments.get(1).groupNormalizedVal * direction[1] - 
            segments.get(3).groupNormalizedVal * direction[3]) / 2;

        double yVal = (segments.get(0).groupNormalizedVal * direction[0] - 
            segments.get(2).groupNormalizedVal * direction[2]) / 2;

        double length = math. 


        update(xVal, yVal);
    
    }

    void display() {
        fill(200,220,140);
        ellipse(x, y, w, h);

    }

}

/**
 * Utilities and Bric-a-brac
 *
 **/

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

