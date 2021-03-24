class Root {
  
  float x,y;
  float w;
  
  Root mother = null;
  ArrayList<Root> children = new ArrayList<Root>();
  
  float vx, vy;
  
  Root down = null;
  Root up = null;
  
  boolean alive = true;
  
  int hormCnt;
  float hormX, hormY;
  
  Root(float _x, float _y, float _w, Root _mother) {
    x = _x;
    y = _y;
    w = _w;
    
    mother = _mother;
    
    vx = 0;
    vy = 0;
    
    // hormone receiving
    hormCnt = 0;
    hormX = 0;
    hormY = 0;
    
  }
  
  void receiveHormone(float _x, float _y) {
    if (alive) {
      // receive hormone from a hormone source
      hormCnt++;
      hormX+=_x;
      hormY+=_y;
    }
  }
  
  void render() {
    noStroke();
    fill(255,64);
    ellipse(x,y,w,w);
    
    if (mother!=null) {
      // calculate distance to mother
      float dm = dist(x,y,mother.x,mother.y);
      //float smallw = dm + (w-mother.w)/2;
      //float smallw = mother.w-w;
      //float smallw = dm/2;
      float smallw = unit/2;
      fill(255,92);
      ellipse(x,y,smallw,smallw);
    }
  }
  
  void renderMotherline() {
    if (mother!=null) {
      stroke(255,192);
      line(x,y,mother.x,mother.y);
    }
  }
  
  Root grow() {
    if (alive && hormCnt>0) {
      // grow towards hormone source
      float fuz = unit*.1;
      float d = w*.618;
      float avgX = (random(-fuz,fuz)+hormX)/hormCnt;
      float avgY = (random(-fuz,fuz)+hormY)/hormCnt;
      
      float theta = atan2(avgY-y,avgX-x);
      float nx = x + d*cos(theta);
      float ny = y + d*sin(theta);
      
      if (dist(x,y,avgX,avgY)<d) {
        // nearly there, take fractional step to get exactly there
        nx = avgX;
        ny = avgY;
      }
      
      Root r = new Root(nx,ny,unit,this);
      return r;
    }
    return null;
    
  }
  
  void resetHormones() {
    hormCnt = 0;
    hormX = 0;
    hormY = 0;
  }

  void pump(float h) {
      // hormone received, grow larger
      float actualh = h;
      if (children.size()>0) actualh = actualh/children.size();
      w+=actualh;
      if (w<1) w = 1;
      
      if (mother!=null) { 
        mother.pump(h*pumpDecay);
      }
  }
  
  void send(float h) {
    // opposite of pumping
    w+=h;
    if (w<1) w = 1;
    
    
    //float actualh = h;
    //if (children.size()>0) actualh = actualh/children.size();
    
    float actualh = h;
    for (int i=0;i<children.size()+1;i++) {
      actualh*=sendDecay;
    }
      
    
    for (Root cr:children) {
      cr.send(actualh);
    }
  }
    
  
  void addRootChild(Root r) {
    children.add(r); 
    println("added child:"+r);
  }
    
    
  
}
