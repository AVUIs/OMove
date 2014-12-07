import codeanticode.syphon.*;
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

SyphonClient client;

ArrayList<SyphonParticle> particles;

int NUM_PARTICLES = constrain(1,10,20 );

PImage tem;

void setup() {
  size(1280, 720, OPENGL);
  client = new SyphonClient(this);

  particles = new ArrayList<SyphonParticle>();

  // initial all particles
  for (int i = 0; i< NUM_PARTICLES; i++) {
    SyphonParticle p = new SyphonParticle();
    p.setPos(random(width), random(height));
    p.setSize(10.0);
    particles.add(p);
  }

  // start oscP5, telling it to listen for incoming messages at port 5001 */
  oscP5 = new OscP5(this, 3333);

  // set the remote location to be the localhost on port 12345
  myRemoteLocation = new NetAddress("127.0.0.1", 12345);
}

public void draw() {
  background(0);

  for (int i = 0;i<particles.size();i++) {

    if (mousePressed) {
      particles.get(i).setVel(new PVector(0, 0));
    } 

    particles.get(i).move(new PVector(mouseX, mouseY));

    //c[i].render();
    particles.get(i).setMaxVel(10.0);


    particles.get(i).render();

    //send each particel's pos to Puredata via osc , port is 12345, you recive in PD, and then make sound
    OscMessage myMessage = new OscMessage("/PD");
    long metronomo = millis()%250;
    
    if (metronomo == 0){ 
    
    myMessage.add(particles.get(i).loc.x);
    myMessage.add(particles.get(i).loc.y);
    oscP5.send(myMessage, myRemoteLocation);
    }
  }
}

void keyTyped() {
  if (key=='s') {
    tem = client.getImage(tem);
    for (int i = 0;i<particles.size();i++) {
      particles.get(i).getVis(tem);
    }
  }
}
class SyphonParticle {
  PImage img;
  float scale;

  PVector loc;
  PVector vel;
  PVector acc;
  float maxVel;

  SyphonParticle() {
    loc = new PVector();
    vel = new PVector();
    acc = new PVector();
    maxVel = 8;
  }

  void setMaxVel(float mv) {
    maxVel = mv;
  }
  void setPos(float x, float y) {
    loc.set(x, y);
  }


  //set scale of syphon image
  void setSize(float n) {
    scale = n;
  }
  void render() {  
    if (img!=null) {
      image(img, loc.x, loc.y, img.width/scale, img.height/scale);
    }
  }

  void getVis(PImage im) {
    img = im;
  }


  void move(PVector target) {
    PVector diff = PVector.sub(target, getLoc());
    diff.normalize();
    diff.div(5.7);
    acc=diff;
    vel.add(acc);
    loc.add(vel);
    if (vel.mag() > maxVel) {
      vel.normalize();
      vel.mult(maxVel);
    }
  }

  void border() {
    if ((loc.y > height+100) || (loc.y < -100)) {
      vel.y *= -0.5;
    }
    if ((loc.x < -100) || (loc.x > width+100)) {
      vel.x *= -0.5;
    }
  }
  //geters e seters
  PVector getVel() {
    return vel.get();
  }

  PVector getLoc() {
    return loc.get();
  }

  PVector getAcc() {
    return acc.get();
  }

  float getMaxVel() {
    return maxVel;
  }



  void setVel(PVector v) {
    vel = v.get();
  }

  void setLoc(PVector v) {
    loc = v.get();
  }

  void setAcc(PVector v) {
    acc = v;
  }
}

//finished! Run these code, open a syphon out put app, within processing app, press key s//
//Osc port is 12345//
