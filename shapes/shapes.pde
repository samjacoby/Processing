import processing.pdf.*;

int xPane = 100, yPane = 100;
int screen_h = 1000;
int screen_w = 1000;
int size = screen_w/xPane;

Pane pane; 

void setup() {
    
    noLoop();

    size(screen_w, screen_h);
    background(255);

    // declare new pane
    pane = new Pane(xPane, yPane, size);

    // initialize with empty 
    for(int i = 0; i < xPane; i++) {
        for(int j = 0; j < yPane; j++) {
            pane.set(i, j, size);
            
        }
    }

    //beginRecord(PDF, "filename.pdf"); 
}

void draw() { 

    Node n;

    n = pane.get(0, 20);
    n.setOn();
    n = pane.get(0, 21);
    n.setOn();
    n = pane.get(0, 25);
    n.setOn();

    for(int i = 0; i < xPane; i++) {
        for(int j = 0; j < yPane; j++) {
            n = pane.get(i, j);
            n.draw();
        }
    }

}


class Pane {//{{{
    
    private Node[][] nPane;

    Pane(int xPane, int yPane, int size) {
        Node[][] nPane = new Node[xPane][yPane]; 
        this.nPane = nPane;
    }

    public Node get(int x, int y) {
        return nPane[x][y];
    } 

    public void set(int x, int y, int size) {
        nPane[x][y] = new Node(x, y, size); 
    }

    
}//}}}

class Node {//{{{

    public int xOrigin, yOrigin;
    public int size;
    public boolean isOn;

    Node(int x, int y, int size) {

        xOrigin = x*size; 
        yOrigin = y*size; 
        size = size;
        isOn = false;
    
    }
    
    public void setOn() {
        this.isOn = true; 
    }

    public void setOff() {
        this.isOn = false; 
    }
      
    public void draw() {
        if(this.isOn) {
            fill(0);
        } else {
            fill(255); 
        }
        rect(xOrigin, yOrigin, xOrigin + size, yOrigin + size);
  }

}//}}}


