int[] rules = {0,1,1,0,1,0,1,1};
void setup(){
  size(screenWidth,screenHeight);
  background(255); 
  loadPixels();
  pixels[width/2] = color(0);
  reset();
}
void draw(){
  for(int y = 1;y<height;y++){
    for(int i = 1;i< width-1;i++){
      pixels[y*width+i] = color(255*rules[((((0xff&pixels[(y-1)*width+i-1])/255<<1)+(0xff&pixels[(y-1)*width+i])/255)<<1)+(0xff&pixels[(y-1)*width+i+1])/255]);
    }
  }
  updatePixels();
  noLoop();
}
void reset(){
  for(int i = 0;i<rules.length;i++){
    rules[i] = round(random(1)); 
  }
}
void mouseReleased(){
  loop();
  reset();
}

