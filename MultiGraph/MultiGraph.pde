/* Processing code for this example

// Graphing sketch


// This program takes ASCII-encoded strings
// from the serial port at 9600 baud and graphs them. It expects values in the
// range 0 to 1023, followed by a newline, or newline and carriage return
*/

import processing.serial.*;

Serial myPort;        // The serial port

int xPos = 1;         // horizontal position of the graph
int numPins = 5;      // Number of datapoints we want to graph

final int START = -2;
// Buffer until something < 127 or bufferUntil fails
final char END = 0x71;

// color scheme for each row
int[] colors = new int[numPins];

ArrayList<Integer> graphList = new ArrayList<Integer>();


void setup () {

    size(400, 500);        
    for(int i=0;i < 5;i++) {
        colors[i] = color(random(0,255), random(0, 255), random(0, 255));
    }
    // tasteful colors
    //colors = {0xff7d837d, 0xff515a5e, 0xff514f5c, 0xff5f5e62, 0xff70756f}; 

    // List all the available serial ports
    println(Serial.list());
    myPort = new Serial(this, Serial.list()[0], 57600);

    // don't generate a serialEvent() unless you get an END charachter
    myPort.bufferUntil(int(END));
    // set inital background:
    setUpBackground(0);
}

void draw () {
// everything happens in the serialEvent()
}

/**
 * Process a SerialEven from TapClip
 *
 * Byte format as follows:
 *
 * | START | DATA[5] | END  |
 * | 0xEF  | DATA[5] | 0xFA |
 *
 **/

void serialEvent (Serial myPort) {

   byte[] inBuffer = new byte[8];
   byte touchMask;
   int inByte, inByte_t;
   int startLinePos, endLinePos;
   int rowHeight = getRowHeight();

   int bytesRead = myPort.readBytesUntil(END, inBuffer);

   // Make sure we've read something interesting
   if(bytesRead > 0 && (inBuffer[0] == START) && (inBuffer[inBuffer.length -1 ] == END)) {

        // wipe background. we'll redraw everything everytime. why not?
        setUpBackground(0);

        // color background according to touchmask
        for(int i=0; i<numPins; i++) {
            if(((1L << i) & inBuffer[1]) != 0) {
                fill(193);
                rect(0, rowHeight * (4 - i), width, rowHeight);
            }
        }
        

        int offsetHeight = height - 2;
        // first and last bytes are not interesting.
        for(int i=0; i < inBuffer.length - 3; i++) {
            println(i);


           inByte_t = int(inBuffer[i + 2]); 

           inByte = floor(map(inByte_t, 0, 255,  0, rowHeight));


           startLinePos = offsetHeight - rowHeight * i;
           endLinePos = startLinePos - inByte;
           for(int j=0; j < graphList.size(); j +=3) {
                stroke(colors[(j/3) % numPins]);  // cycle through the five colors
                line(graphList.get(j), graphList.get(j+1), graphList.get(j), graphList.get(j+2)); 
           }
           
           startLinePos = offsetHeight - rowHeight * i;
           endLinePos = startLinePos - inByte;
           
           // set various colors
           stroke(colors[i]);
           fill(colors[i]);

           // draw new line
           text(inByte_t, width - floor(width/10), startLinePos - rowHeight + 20);
           line(xPos, startLinePos, xPos, endLinePos);

           // add new line to list
           graphList.add(new Integer(xPos));
           graphList.add(new Integer (startLinePos));
           graphList.add(new Integer(endLinePos));
        }

        // at the edge of the screen, go back to the beginning:
        if (xPos >= width) {
            graphList.clear();
            xPos = 0;
            setUpBackground(0);
        } else {
            // increment the horizontal position:
            xPos++;
        }
       } else {
           println("Nothing read.");
           myPort.clear();  
       }
}

void setUpBackground(int colors) {
    background(colors); 
    int rowHeight = getRowHeight();
    stroke(255);
    int offsetHeight = height - 2;
    for(int i=0; i < 5; i++) {
        line(0, offsetHeight - rowHeight * i, width, offsetHeight - rowHeight * i);
    }
}

int getRowHeight() {
    return floor(height/numPins);
}

