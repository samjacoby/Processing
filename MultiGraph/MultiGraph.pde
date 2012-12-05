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

 // color scheme for each row
 int[] colors = {0xff7d837d, 0xff515a5e, 0xff514f5c, 0xff5f5e62, 0xff70756f}; 
 
 
 void setup () {
 // set the window size:
 size(600, 500);        
 
 // List all the available serial ports
 println(Serial.list());
 // I know that the first port in the serial list on my mac
 // is always my  Arduino, so I open Serial.list()[0].
 // Open whatever port is the one you're using.
 myPort = new Serial(this, Serial.list()[0], 9600);
 // don't generate a serialEvent() unless you get a newline character:
// myPort.bufferUntil(10);
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

    println("reading...");
    int bytesRead = myPort.readBytesUntil(lf, inBuffer);
    println(bytesRead);
 
    if (inBuffer != null && bytesRead > 0) {
        println(inBuffer);

         // first and last bytes are not interesting
         for(int i=0; i < inBuffer.length - 2; i++) {

            inByte_t = int(inBuffer[i + 1]); 
            inByte = floor(map(inByte_t, 0, 255,  0, rowHeight));
            stroke(colors[i]);
            // draw the line:
            line(xPos, rowHeight * i, xPos, rowHeight * i + inByte);
         
         }

 
 
 // at the edge of the screen, go back to the beginning:
     if (xPos >= width) {
     xPos = 0;
     background(0); 
     } else {
     // increment the horizontal position:
     xPos++;
     }
    }
 }
 

