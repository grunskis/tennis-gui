import fullscreen.*;
import java.awt.Toolkit;
import processing.serial.*;

int A = 0;
int B = 1;

int SMALL = 0;
int LARGE = 1;

String[] NAMES = { 
  "Sheldon",       
  "Leonard", 
  "Rajesh", 
  "Penny", 
  "Howard"
};

Serial serial;
SoftFullScreen fs;

PFont[] fonts;

Game game;
Player a, b;

int[] idx = { -1, -1 };

boolean redrawNeeded = true;

// this is charset for LARGE font. with all 
// characters in charset you will get OOM exception
char[] charset = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ':' };

void setup() {
  size(640, 480);
  noStroke();
  smooth();
  
  frameRate(10);
  
  fonts = new PFont[2];
  fonts[SMALL] = loadFont("Verdana-48.vlw");
  fonts[LARGE] = createFont("Verdana", 120.0, true, charset);
  
  a = new Player();
  b = new Player();
  
  game = new Game(a, b, this);

  //println(Serial.list());
  serial = new Serial(this, Serial.list()[0], 9600);
  
  // Create the fullscreen object
  fs = new SoftFullScreen(this); 
  
  // enter fullscreen mode
  fs.enter();
}

String getCurrentDateTime() {
  DateFormat dfm = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
  
  dfm.setTimeZone(TimeZone.getTimeZone("GMT"));

  return dfm.format(new Date());
}

void beep() {
  Toolkit.getDefaultToolkit().beep();
}

void scoreRedraw() {
  fill(color(255));
  
  textFont(fonts[LARGE]);
  
  float twA = textWidth(str(game.getPoints(A)));
  float twB = textWidth(str(game.getPoints(B)));
  
  println("widthA: " + twA + ", widthB: " + twB);
  
  text(game.getPoints(A), width/4 - twA/2, height/2 + 45);
  text(game.getPoints(B), 3*width/4 - twB/2, height/2 + 45);
  text(":", width/2 - textWidth(":")/2, height/2 + 45);
  
  println(": " + textWidth(":"));
  
  textFont(fonts[SMALL]);
  
  twA = textWidth(str(game.getScore(A)));
  twB = textWidth(str(game.getScore(B)));
  
  text(game.getScore(A), width/2 - 2*twA, height-100);
  text(game.getScore(B), width/2 + twB, height-100);
  text(":", width/2 - textWidth(":")/2, height-100);
  
  println(": " + textWidth(":"));
  
  text(game.getName(A), width/4.0 - textWidth(game.getName(A))/2, 100);
  text(game.getName(B), 3*width/4 - textWidth(game.getName(B))/2, 100);
}

void execute(char command) {
  switch (command) {
    case 'a':
      game.score('a');
      break;
      
    case 'A':
      game.score('a', -1);
      break;
      
    case 'b':
      game.score('b');
      break;
      
    case 'B':
      game.score('b', -1);
      break;
      
    case 'n':
      for (;;) {
        idx[A] = (idx[A] >= NAMES.length-1 ? 0 : idx[A] + 1);

        if (idx[A] != idx[B]) {
          break;
        }
      }
      a.setName(NAMES[idx[A]]);
      break;
      
    case 'o':
      for (;;) {
        idx[B] = (idx[B] >= NAMES.length-1 ? 0 : idx[B] + 1);

        if (idx[A] != idx[B]) {
          break;
        }
      }
      b.setName(NAMES[idx[B]]);
      break;
      
    case 'r':
    case 'R':
      game.reset();
      idx[A] = idx[B] = -1;
      a.setName("");
      b.setName("");
      break;
      
    default:
      println("Unknown command: " + command);
  }
}

void drawScreen() {
  background(0);
  
  fill(color(255, 0, 0));

  if (game.getServe() == A) {
    rect(0, 0, width/2, height);
  } else {
    rect(width/2, 0, width, height);
  }
  
  scoreRedraw();
}

void draw() {
  if (redrawNeeded) {
    redrawNeeded = false;
    
    drawScreen();
  }
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == LEFT) {
      execute('s'); execute('n'); execute('e');
    } else if (keyCode == RIGHT) {
      execute('t'); execute('f'); execute('o');
    }
  } else {
    execute(key);
  }
  
  redrawNeeded = true;
}

void serialEvent(Serial serial) {
  while (serial.available() > 0) {
    char command = serial.readChar();
    
    execute(command);
  }
  
  redrawNeeded = true;
}
