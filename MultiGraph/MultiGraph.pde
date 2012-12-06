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
final char END = 0x0a;

// color scheme for each row
//int[] colors = {0xff7d837d, 0xff515a5e, 0xff514f5c, 0xff5f5e62, 0xff70756f}; // tasteful colors 
int[] colors = new int[5];



void setup () {
size(500, 500);        
for(int i=0;i < 5;i++) {
    colors[i] = color(random(0,255), random(0, 255), random(0, 255));
}

// List all the available serial ports
println(Serial.list());
myPort = new Serial(this, Serial.list()[0], 14400);

// don't generate a serialEvent() unless you get a newline character:
myPort.bufferUntil(10);
// set inital background:
background(0);
}

void draw () {
// everything happens in the serialEvent()
}


void serialEvent (Serial myPort) {
   int inByte, inByte_t;
   int rowHeight = floor(height/numPins);
   char lf = 0x0a;

   byte[] inBuffer = new byte[7];

   int bytesRead = myPort.readBytesUntil(lf, inBuffer);

   // Make sure we've read something interesting
   if(bytesRead > 0 && (inBuffer[0] == START) && (inBuffer[inBuffer.length -1 ] == END)) {

        // first and last bytes are not interesting
        for(int i=0; i < inBuffer.length - 2; i++) {

           inByte_t = int(inBuffer[i + 1]); 
           inByte = floor(map(inByte_t, 0, 255,  0, rowHeight));
           stroke(colors[i]);

           // draw the line:
           int t = height - rowHeight * i;
           println(t);
           t = height - rowHeight * i + inByte;
           println(t);
           line(xPos, height - rowHeight * i, xPos, height - rowHeight * i - inByte);
        }

       // at the edge of the screen, go back to the beginning:
        if (xPos >= width) {
        xPos = 0;
        background(0); 
        } else {
        // increment the horizontal position:
        xPos++;
        }
       } else {
           myPort.clear();  
       }
}


