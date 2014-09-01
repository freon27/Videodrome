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

import processing.video.*;
Movie eyeMovie;

 
String[] movieFiles;
String[] imageFiles;
ArrayList<Movie> movies;
ArrayList<PImage> imageScreens;

int w=960;
int h=540;
PImage tvscreen;
PImage TVOverlay;
PImage tvnoise;
PImage eyeFrame;
PImage vd_logo;

int barY1=10;
int barY2=30;

int currentImage = 0;
int currentMovie = 0;
 
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
 
void setup()
{
  
  imageFiles = loadStrings("imageFiles.txt");
  movieFiles = loadStrings("movieFiles.txt");
  
  imageScreens = new ArrayList<PImage>();
  movies = new ArrayList<Movie>();
  
  for (int i = 0; i < imageFiles.length; i++) {
    println(imageFiles[i]);
    imageScreens.add(loadImage(imageFiles[i]));
  }
  
  for (int j = 0; j < movieFiles.length; j++) {
    println(movieFiles[j]);
    movies.add(new Movie(this, movieFiles[j]));
  }

  movies.get(0).loop();  
  //eyeMovie = new Movie(this, "clouds.mp4");
  //eyeMovie.loop();

  size(960, 540, P2D);
  tvscreen = imageScreens.get(0);
  TVOverlay = loadImage("tv.png");
  vd_logo=loadImage("videodrome_logo.png");
  
  // precalculate tv noise
  tvnoise = createImage(w,h,RGB);
 
  tvnoise.loadPixels();
  ppx = new int[tvnoise.pixels.length];
  for (int y = 0; y < ppx.length;)
    ppx[y++] = int(random(-32,32));
  loadPixels();
 
 
  tvwidth = w;
  tvheight = h;
 
  timeIndexInfo = millis();
  firstCountInfo = millis();
 
  noSmooth();
 
}
 
void draw() {
  background(0);
  renderDistort();
  image(TVOverlay, 0, 0);
}
 
int powerUpCounter = 256;
 
void scaleIt(float amountA, float amountB, int valueA, int valueB, int valueC, int valueD){
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
      lerpShrink += .09;
 
       
       
    }
  }
  
  float md = movies.get(currentMovie).duration();
  float mt = movies.get(currentMovie).time();
  if (md - mt<0.1){
    currentMovie = int(random(movies.size()));
    currentImage = int(random(imageScreens.size()));
    tvscreen = imageScreens.get(currentImage);
    movies.get(currentMovie).play();
  }
}
 
// RGB Distort
void renderDistort() {
 /*
  // precalculate tv noise
  tvnoise = createImage(w,h,RGB);
 
  tvnoise.loadPixels();
  ppx = new int[tvnoise.pixels.length];
  for (int y = 0; y < ppx.length;)
    ppx[y++] = int(random(-32,32));
  l  oadPixels();
 */
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
    scaleIt(0.02,0.2,156,0,2,tvscreen.height);  // turning on
  else
    scaleIt(0.1,0.2,0,-400,tvscreen.height,1);   // turning off
 
  // dark vs light flicker + gradual fade in
  int flicker = (offBlue*8)+powerUpCounter;
 
  for ( int y = 1; y < h; y++ ) {
 
    // vertically moving horizonal strip + flicker
    int colDiv = ( y < barY2 && y > barY1 ) ? 20+flicker : flicker;
 
    // horizontal scanlines
    int strips=(y&1)*64 +colDiv;
 
    // grab a random line of precalculated TV noise
    int noiseLine = int(random(0,height)) * width;
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
  image(movies.get(currentMovie), 0, 0, 960, 540);
 
 

  image(tvnoise,(tvscreen.width-tvwidth/2)-tvscreen.width/2,(tvscreen.height-tvheight/2)-tvscreen.height/2,tvwidth,tvheight);
  image(vd_logo, 0, 0);
  
  noTint();
}
 
void mousePressed(){
  lerpAmount = 0;
  lerpScale = 0;
  lerpShrink = 0;
  tvstate = !tvstate;
  //tvheight=280;
  tvwidth=width; 
  println(" tvheight: " + tvheight + " tvscreen.height: " + tvscreen.height );
}

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
  //tvscreen = m.get();
}
