import processing.pdf.*;

int xPane = 100, yPane = 100;
int screen_h = 1000;
int screen_w = 1000;
int nSize = screen_w/xPane; 

ArrayList ruleList = new ArrayList<Rule>;


Pane pane; 

void setup() {
    
    noLoop();

    size(screen_w, screen_h);
    background(255);

    // declare new pane
    pane = new Pane(xPane, yPane, nSize);

    // initialize with empty 
    Node n;
    for(int i = 0; i < xPane; i++) {
        for(int j = 0; j < yPane; j++) {
            n = new Node(i, j, nSize);
            pane.set(i, j, n);
        }
    }

    // set rules
    r = new Rule(true, false, false);
    ruleList.add(r);
    r = new Rule(true, true, false);
    ruleList.add(r);

    //beginRecord(PDF, "filename.pdf"); 
}

void draw() { 

    Node n, m;

    n = pane.get(0, 0);
    n.setOn();
    n = pane.get(1, 5);
    n.setOn();
    n = pane.get(2, 50);
    n.setOn();

    for(int i = 0; i < xPane; i++) {
        for(int j = 0; j < yPane; j++) {
            n = pane.get(i, j);
            ruleCheck(n);
            n.draw();
        }
    }

}

void ruleCheck(Node n) {
    Node u,i,o;

    u = pane.get(i - 1, j - 1);
    i = pane.get(i - 1, j);
    o = pane.get(i - 1, j + 1);

    for(Rule r: ruleList) {
        

    }
    
    if(m != null && m.isOn) {
        n.setOn(); 
    }
}

class Rule {
   
    public boolean a, b, c  

    Rule(boolean a, boolean b, boolean c) {
        this.a = a;
        this.b = b;
        this.c = c;
    }


}


class Pane {//{{{
    
    private Node[][] nPane;

    Pane(int xPane, int yPane, int nSize) {
        Node[][] nPane = new Node[xPane][yPane]; 
        this.nPane = nPane;
    }

    public Node get(int x, int y) {
        Node n;
        try {
            n = nPane[x][y]; 
        } catch(Exception e) {
            n = null;
        }
        return n;
    } 

    public void set(int x, int y, Node n) {
        nPane[x][y] = n; 
    }

    
}//}}}

class Node {//{{{

    public int x, y, xOrigin, yOrigin;
    public int nSize;
    public boolean isOn;

    Node(int x, int y, int nSize) {

        this.x = x;
        this.y = y;
        xOrigin = x*nSize; 
        yOrigin = y*nSize; 
        this.nSize = nSize;
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
//        println(xOrigin + " " + yOrigin + " " + nSize);

        rect(xOrigin, yOrigin, xOrigin + nSize, yOrigin + nSize);
  }

}//}}}


