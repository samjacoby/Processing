import processing.pdf.*;
import java.util.BitSet;

int xPane = 100, yPane = 100;
int screen_h = 1000;
int screen_w = 1000;
int nSize = screen_h/yPane; 

ArrayList<Rule> ruleList = new ArrayList<Rule>();

Pane pane; 

void setup() {//{{{
    
    noLoop();
    noStroke();

    // set rules
    Rule r = new Rule((byte)3);
    ruleList.add(r);
    r = new Rule((byte)5);
    ruleList.add(r);
    r = new Rule((byte)6);
    ruleList.add(r);
    r = new Rule((byte)2);
    ruleList.add(r);
    r = new Rule((byte)4);
    ruleList.add(r);

    size(screen_w, screen_h);
    background(255);

    // declare new pane
    pane = new Pane(xPane, yPane, nSize);

    // initialize with empty 
    Node n;
    for(int i = 0; i < yPane; i++) {
        for(int j = 0; j < xPane; j++) {
            n = new Node(j, i, nSize);
            pane.set(j, i, n);
        }
    }


    //beginRecord(PDF, "filename.pdf"); 
}//}}}
void draw() { //{{{

    Node n, m;

    n = pane.get(99, 0);
    n.setOn();

    for(int i = 0; i < yPane; i++) {
        for(int j = 0; j < xPane; j++) {
            n = pane.get(j, i);
            ruleCheck(n);
            n.draw();
        }
    }

}//}}}
public void ruleCheck(Node n) {//{{{

    byte neighbors = pane.getNeighbors(n);
    for(Rule r: ruleList) {
        if(r.rule == neighbors) {
            //println(r.rule);
            //println(n.x + " " + n.y);
            n.setOn();
            break;
        }
         
    }
}//}}}
class Rule {//{{{
   
    public byte rule;

    Rule(byte b) {
        this.rule = b;
    }

}//}}}
class Pane {//{{{
    
    private Node[][] nPane;

    Pane(int xPane, int yPane, int nSize) {
        Node[][] nPane = new Node[xPane][yPane]; 
        this.nPane = nPane;
    }

    public byte getNeighbors(Node n) {
        Node m; 
        byte b = 0;
        int[] table = {-1,0,1};
        for(int i = 0; i < 3; i++) {
            m = this.get(n.x + table[i], n.y - 1);
            if(m != null && m.isOn) {
                //println("found rule matching -- x: " + m.x + ", " + m.y);
                //println("origin square -- x: " + n.x + ", " + n.y);
                b |= 1 << i;
            }
        }
        return b;
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

        rect(xOrigin, yOrigin, xOrigin + nSize, yOrigin + nSize);
  }

}//}}}


