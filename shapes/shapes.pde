import processing.pdf.*;

int xPane = 100, yPane = 100;
int screen_h = 1000;
int screen_w = 1000;


void setup() {
    size(screen_w, screen_h);
    background(255);

    beginRecord(PDF, "filename.pdf"); 
}

int y_grid = 10;
int x_grid = 10;

int step = 10;

void draw() { 

    while(y < screen_h) {
        Node n = new Node();
        while(x < screen_w) {
            draw_box(x, y, 10);
            x += step;
    }
    x = 0;
    y += step;
  }
  
 
  endRecord();
}

void draw_box(int origin_x, int origin_y, int side_s) {
  fill(random(0, 255));
  rect(origin_x, origin_y, origin_x + side_s, origin_y + side_s);
} 
class Node {//{{{

    public int x, y;
    public int size;
    public boolean isOn;

  //public Node getLeft() {}
  //public Node getRight() {}
  //public Node getAbove() {}
  
  public draw() {
      if(this.isOn) {
        fill(0);
      } else {
         fill(255); 
      }
      rect(origin_x, origin_y, origin_x + side_s, origin_y + side_s);
  }

}

  
}//}}}
class Pane {//{{{
    
    private Node[][] nPane;

    Pane() {
        Node[][] nPane = new Node[xPane][yPane]; 
        this.nPane = nPane;
    }

    public Node get(int x, int y) {
        return this.nPane = nPane[x][y];
    } 

    public Node[][] get_nPane() {
        return nPane; 
    }
    
}//}}}
