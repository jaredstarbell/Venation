class HormoneSource {
  
  float x,y;
  float w;
  
  float vx, vy;
  
  HormoneSource(float _x, float _y, float _w) {
    x = _x;
    y = _y;
    w = _w;
    
    vx = 0;
    vy = 0;
  }
  
  void send() {
    // send hormone to closest root
    Root r = findClosestRoot();
    r.receiveHormone(x,y);
  }
  
  void render() {
    noStroke();
    fill(255);
    ellipse(x,y,w*.22,w*.22);
    
    // render line to closest root
    Root r = findClosestRoot();
    if (r!=null) {
      stroke(255,0,0,94);
      line(x,y,r.x,r.y);
    }
  }
  
  Root findClosestRoot() {
    float mind = width*height;
    Root near = null;
    for (Root r:roots) {
      float d = dist(x,y,r.x,r.y);
      if (d<mind) {
        mind = d;
        near = r;
      }
    }
    
    // return the closest root (might be null)
    //if (near!=null) near.pump(.08);
    return near;
  }
  
  boolean hasRoot() {
    for (Root r:roots) {
      float d = dist(x,y,r.x,r.y);
      if (d<w*.2) return true;
    }
    return false;
  }    
  
}
