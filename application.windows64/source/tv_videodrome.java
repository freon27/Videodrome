import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.video.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class tv_videodrome extends PApplet {

/*
 
 Retro CRT TV Distortion Effect
  
 RGB Shifting for random color bleeding
 television scanlines
 random flicker of entire image
 rolling bar
 tv noise static
 turning on fades in image from black
 turning off fades image to white while shrinking it to a horizontal line
  
 */


Movie eyeMovie;

 
int w=960;
int h=540;
PImage tvscreen;
PImage TVOverlay;
PImage tvnoise;
PImage eyeFrame;
PImage vd_logo;

int barY1=10;
int barY2=30;
 
 
//tv noise
int[] ppx;
int[] px = new int[w];
 
boolean tvstate = true;
 
 
long timeIndexInfo;
long firstCountInfo;
 
float lerpAmount = 0;
float lerpScale = 0;
float lerpShrink = 0;
 
int tvheight=0;
int tvwidth=0;
 
public void setup()
{
  
  eyeMovie = new Movie(this, "eye.mp4");
  eyeMovie.loop();
  size(960, 540, P2D);
  tvscreen=loadImage("brain.png");
  TVOverlay=loadImage("tv.png");
  vd_logo=loadImage("videodrome_logo.png");
  
  // precalculate tv noise
  tvnoise = createImage(w,h,RGB);
 
  tvnoise.loadPixels();
  ppx = new int[tvnoise.pixels.length];
  for (int y = 0; y < ppx.length;)
    ppx[y++] = PApplet.parseInt(random(-32,32));
  loadPixels();
 
 
  tvwidth = w;
  tvheight = h;
 
  timeIndexInfo = millis();
  firstCountInfo = millis();
 
  noSmooth();
 
}
 
public void draw() {
  background(0);
  renderDistort();
  image(TVOverlay, 0, 0);
}
 
int powerUpCounter = 256;
 
public void scaleIt(float amountA, float amountB, int valueA, int valueB, int valueC, int valueD){
  if (lerpAmount < 1)
  {
    lerpAmount += amountA;
    powerUpCounter = (int)lerp(valueA,valueB,lerpAmount);
  }
 
  if (lerpScale < 1)
  {
    lerpScale += amountB;
    tvheight = (int)lerp(valueC,valueD,lerpScale);
  } 
 
  // final horiontal line shrink on power off
  if (!tvstate && tvheight < 100)
  {
    if (lerpShrink < 1)
    {
      tvwidth = (int)lerp(width,1,lerpShrink);
      lerpShrink += .09f;
 
       
       
    }
  }
}
 
// RGB Distort
public void renderDistort() {
 
  // precalculate tv noise
  tvnoise = createImage(w,h,RGB);
 
  tvnoise.loadPixels();
  ppx = new int[tvnoise.pixels.length];
  for (int y = 0; y < ppx.length;)
    ppx[y++] = PApplet.parseInt(random(-32,32));
  loadPixels();
 
  int i = 0;
 
  int offRed  = (int)(Math.random() * 2) * 2;
  int offGreen= (int)(Math.random() * 2) * 2;
  int offBlue = (int)(Math.random() * 2) * 2;
 
  if (barY2 > h) {
    barY1=10 -40;
    barY2=30 -40;
  }
 
  barY1 +=2;
  barY2 +=2;
 
  if (tvstate)
    scaleIt(0.02f,0.2f,156,0,2,tvscreen.height);  // turning on
  else
    scaleIt(0.1f,0.2f,0,-400,tvscreen.height,1);   // turning off
 
  // dark vs light flicker + gradual fade in
  int flicker = (offBlue*8)+powerUpCounter;
 
  for ( int y = 1; y < h; y++ ) {
 
    // vertically moving horizonal strip + flicker
    int colDiv = ( y < barY2 && y > barY1 ) ? 20+flicker : flicker;
 
    // horizontal scanlines
    int strips=(y&1)*64 +colDiv;
 
    // grab a random line of precalculated TV noise
    int noiseLine = PApplet.parseInt(random(0,height)) * width;
    for ( int x=0; x < w; x++ ) {
      int imagePixelR = tvscreen.pixels[i+offRed] >> 16 & 0xFF ;
      int imagePixelG = tvscreen.pixels[i+offGreen] >> 8 & 0xFF ;
      int imagePixelB = tvscreen.pixels[i+offBlue] & 0xFF ;
      int processEffect = -strips-ppx[noiseLine+x];
      tvnoise.pixels[i++] =  color(imagePixelR+processEffect, imagePixelG+processEffect, imagePixelB+processEffect);     
    }
  }
  tvnoise.updatePixels();
   tint(255,255,255,100);
  //image(tvnoise,0,0,tvscreen.width,270);
  image(eyeMovie, 0, 0);
 
 

  image(tvnoise,(tvscreen.width-tvwidth/2)-tvscreen.width/2,(tvscreen.height-tvheight/2)-tvscreen.height/2,tvwidth,tvheight);
  image(vd_logo, 0, 0);
  
  noTint();
}
 
public void mousePressed(){
  lerpAmount = 0;
  lerpScale = 0;
  lerpShrink = 0;
  tvstate = !tvstate;
  //tvheight=280;
  tvwidth=width; 
  println(" tvheight: " + tvheight + " tvscreen.height: " + tvscreen.height );
}

// Called every time a new frame is available to read
public void movieEvent(Movie m) {
  m.read();
  //tvscreen = m.get();
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#000000", "--stop-color=#cccccc", "tv_videodrome" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
