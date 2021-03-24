// Venation
//   Jared S Tarbell
//   May 25, 2019
//   Levitated Toy Factory
//   Albuquerque, NM, USA

ArrayList<HormoneSource> horms = new ArrayList<HormoneSource>();
ArrayList<Root> roots = new ArrayList<Root>();
ArrayList<Root> newRoots = new ArrayList<Root>();

int time;
int maxHormones = 500;

float unit;

float pumpInit = .0100;
float pumpDecay = .998;
float sendInit = 0;      //something weird is happening 
float sendDecay = .98;  

void setup() {
  size(1400,1400);
  background(0);

  begin();
  
}

void begin() {
  background(0);
  horms.clear();
  roots.clear();
  
  // general size of the particles in the system
  unit = 3.0;
  
  //makeHormoneSourceCircle(maxHormones,width*.48);
  //makeHormoneSourceGrid(maxHormones);
  //makeHormoneSourcesBitmap(maxHormones,"leaf.png");
  
  makeHormoneSources(maxHormones);
  
  reflectHormoneSources();
  Root oner = new Root(width/2,300,unit,null);
  roots.add(oner);

  // make mother root(s)
  int stems = 0;
  for (int i=0;i<stems;i++) {
    
    float rad = width*.248;
    float theta = TWO_PI/stems;
    float sx = width/2 + rad*cos(theta*i-HALF_PI);
    float sy = height/2 + rad*sin(theta*i-HALF_PI);
    Root r = new Root(sx,sy,10,null);
    //Root r = new Root(random(width),random(height),unit,null);
    roots.add(r);
  }
  
}

void draw() {
  background(0);
  for (HormoneSource h:horms) {
    h.render(); 
  }
  for (Root r:roots) {
    r.render();
  }
  for (Root r:roots) {
    r.renderMotherline();
  }
  
  // send the hormones to the roots
  for (HormoneSource h:horms) {
    h.send();
  }
  
  growRoots();
  
  // remove hormone sorces that have been reached
  for (int i=horms.size()-1;i>=0;i--) {
    HormoneSource h = horms.get(i);
    if (h.hasRoot()) {
      // remove this hormone source
      horms.remove(i);
    }
  }
    
  //if (mousePressed) pumpEndRoot();
  //if (mousePressed) sendNearestRoot();
  
  // downstream pumping
  roots.get(0).send(sendInit);
    
  if (horms.size()>0) println(time+"  roots:"+roots.size()+"  horms:"+horms.size());    
    
  time++;
}


void mousePressed() {
  //float w = random(8.0,10.0);
  //makeHormoneSource(mouseX,mouseY,w);
}

void keyPressed() {
  if (key==' ') {
    begin();
  }
  if (key=='s') {
    saveImage();
  }
}


void saveImage() {
  String Ux = str(char(65+floor(random(26))))+str(char(65+floor(random(26))))+str(char(65+floor(random(26))));
  String filename = "Output/venation-"+Ux+"-########.png";
  print("Saving "+filename+"...");
  saveFrame(filename);
  println("done.");
}

void growRoots() {
  // grow all the roots
  newRoots.clear();
  for (int i=roots.size()-1;i>=0;i--) {
    Root r = roots.get(i);
    if (r.alive) {
      Root newRoot = r.grow();
      if (newRoot==null) {
        // no hormones found - die
        r.alive = false;
      } else {
        roots.add(newRoot);
        r.addRootChild(newRoot);
        
        r.pump(pumpInit);
        
      }
      r.resetHormones();
    }
  }
  
  roots.addAll(newRoots);
}

void makeHormoneSource(float _x, float _y, float _w) {
  HormoneSource h = new HormoneSource(_x,_y,_w);
  horms.add(h);
}

void makeHormoneSources(int max) {
  for (int i=0;i<max;i++) {
    HormoneSource h = new HormoneSource(random(width),random(height),unit);
    horms.add(h);
  }
}

void makeHormoneSourceCircle(int max, float rad) {
  if (max<1) return;
  if (rad<10) return;
  int cnt = 0;
  while (cnt<max) {
    float hx = random(width);
    float hy = random(height);
    float d = dist(width/2,height/2,hx,hy);
    if (d<=rad) {
      HormoneSource h = new HormoneSource(hx,hy,unit);
      horms.add(h);
      cnt++;
    }
  }
}

void makeHormoneSourceGrid(int max) {
  int grid = floor(sqrt(max));
  float unit = width/(grid*1.0);
  for (int i=0;i<grid;i++) {
    for (int j=0;j<grid;j++) {
      float hx = i*grid+grid/2;
      float hy = j*grid+grid/2;
      HormoneSource h = new HormoneSource(hx,hy,unit);
      horms.add(h);
    }
  }
  println("source grid total:"+grid*grid+"/"+max);
  
}

void makeHormoneSourcesBitmap(int max, String filename) {
  PImage bg = loadImage(filename);
  image(bg,0,0);
  int maxAttempts = 100;
  int found = 0;
  for (int i=0;i<max;i++) {
    int attempts = maxAttempts;
    while (attempts>0) {
      // pick a random point on the background image
      float tx = random(bg.width);
      float ty = random(bg.height);
      
      // sample this point on the bitmap
      color c = bg.get(floor(tx),floor(ty));
      if (brightness(c)<128) {
        // translate to screen dimensions
        float px = map(tx,0,bg.width,0,width);
        float py = map(ty,0,bg.height,0,height);
        HormoneSource h = new HormoneSource(px,py,unit);
        horms.add(h);
        attempts = 0;
        found++;
      }
      attempts--;
      
    }
    
  }
  
  if (found!=max) println("WARN only found "+found+" of "+max);
  
}

void reflectHormoneSources() {
  for (int i=horms.size()-1;i>=0;i--) {
    HormoneSource h = horms.get(i);
    
    HormoneSource newh = new HormoneSource(width-h.x,h.y,unit);
    horms.add(newh);
  }
}

Root getNearestEndRoot(float _x, float _y) {
  // end root is root with no children
  Root nr = null;
  float mind = width*height;
  for (Root r:roots) {
    float d = dist(r.x,r.y,_x,_y);
    if (d<mind) {
      // new minimum distance found
      mind = d;
      if (r.children.size()==0) nr = r;
    }
  }
  return nr;
}

Root getNearestRoot(float _x, float _y) {
  Root nr = null;
  float mind = width*height;
  for (Root r:roots) {
    float d = dist(r.x,r.y,_x,_y);
    if (d<mind) {
      // new minimum distance found
      mind = d;
      nr = r;
    }
  }
  return nr;
}  

void pumpEndRoot() {
  Root nr = getNearestEndRoot(mouseX,mouseY);
  if (nr!=null) {
    nr.pump(1.0);
    println("pumping "+nr);
  }
}

void sendNearestRoot() {
  Root r = getNearestRoot(mouseX,mouseY);
  if (r!=null) {
    r.send(sendInit);
  }
}
  
  

   
  
