import java.util.*;
private final float scale = 0.65;
private final float XSHIFT = 57*scale;
private final float ZSHIFT = 21*scale;
private final float YSHIFT = 73*scale;
private final int GRID_SIZE = 6;

private ArrayList<PVector> board = new ArrayList<PVector>();
private int[][][] level;
private int levelNo = -1;
private int boardMax = 6;
private int boardMin = 6;
private int screen = 0;
private int diff = 0;
private boolean isFinished = false;

private float LVL_MIDDLE;
private float LVL_LEFT;
private float LVL_RIGHT;
private float LVL_R1;
private float LVL_R2;
private float LVL_R3;
private float NAV_HEIGHT;

// fonts
PFont title, menu, game;

// HELPER METHODS ==========================================

/** Return determinant of 2 vectors */
float det(PVector p1, PVector p2) {
  return p1.x*p2.y-p2.x*p1.y;
}

/** Checks if mouse coord is inside a top side of cube
* @param top Vertex on top (Acts as new origin)
* @param point Mouse coordinates
*/
boolean isOnTop(PVector top, PVector point) {
  PVector pq = new PVector(-XSHIFT, ZSHIFT);
  PVector pr = new PVector(XSHIFT, ZSHIFT);
  PVector pa = new PVector(point.x-top.x, point.y-top.y);
  float d = det(pq,pr);
  float n = -det(pa,pq)/d;
  float m = det(pa,pr)/d;
  return m>0 && m<1 && n>0 && n<1;
}

/** Checks if mouse coord is inside a left side of box
* @param left Top left vertex (Acts as new origin)
* @param point Mouse coordinates
*/
boolean isOnLeft(PVector left, PVector point) {
  PVector pq = new PVector(XSHIFT, ZSHIFT);
  PVector pr = new PVector(0, YSHIFT);
  PVector pa = new PVector(point.x-left.x, point.y-left.y);
  float d = det(pq,pr);
  float n = -det(pa,pq)/d;
  float m = det(pa,pr)/d;
  return m>0 && m<1 && n>0 && n<1;
}

/** Checks if mouse coord is inside a top side of box
* @param mid Middle top vertex (Acts as new origin)
* @param point Mouse coordinates
*/
boolean isOnRight(PVector mid, PVector point) {
  PVector pq = new PVector(XSHIFT, -ZSHIFT);
  PVector pr = new PVector(0, YSHIFT);
  PVector pa = new PVector(point.x-mid.x, point.y-mid.y);
  float d = det(pq,pr);
  float n = -det(pa,pq)/d;
  float m = det(pa,pr)/d;
  return m>0 && m<1 && n>0 && n<1;
}

/** @param n how many steps in x-direction (right) to move on board */
void translateX(int n) {
  translate(XSHIFT*n, ZSHIFT*n);
}

/** @param n how many steps in y-direction (up) to move on board */
void translateY(int n) {
  translate(0, -YSHIFT*n);
}

/** @param n how many steps in z-direction (left) to move on board */
void translateZ(int n) {
  translate(-XSHIFT*n, ZSHIFT*n);
}

/** Draw arbitrary parallelogram
* @param o first vertex, where side vectors originate
* @param a vector of side 1
* @param b vector of side 2
*/
void drawPgram(PVector o, PVector a, PVector b) {
  beginShape();
  vertex(o.x, o.y);
  vertex(o.x+b.x,o.y+b.y);
  vertex(o.x+b.x+a.x,o.y+b.y+a.y);
  vertex(o.x+a.x,o.y+a.y);
  endShape(CLOSE);
}

void setup() {
  size(1300,1000); // minimum 1000x900
  strokeWeight(0.1);
  rectMode(CENTER);
  textAlign(CENTER, CENTER);
  title = createFont("thin.ttf",120);
  menu = createFont("light.ttf",84); 
  game = createFont("light.ttf",48); 
  
  LVL_MIDDLE = width*3/4;
  LVL_LEFT = LVL_MIDDLE-120;
  LVL_RIGHT = LVL_MIDDLE+120;
  LVL_R1 = height/2-50;
  LVL_R2 = LVL_R1+125;
  LVL_R3 = LVL_R2+125;
  NAV_HEIGHT = height/9;
}

void draw() {
  if (diff == 0) background(240);
  else if (diff == 1) background(230);
  else if (diff == 2) background(220);
  switch (screen) {
    case 0:
      drawMenu();
      break;
    case 1:
      drawBoard();
      break;
    default:
      throw new RuntimeException("Screen number doesn't exist");
  }
}

void drawMenu() {
  levelNo = -1;
  noStroke();
  
  // draw top ====================
  float topOffset = 100;
  
  // draw logo
  fill(140);
  textFont(title);
  text("Silhouette.", width/2, topOffset);
  
  
  // draw left ===================
  if (diff == 0) fill(230);
  else if (diff == 1) fill(200);
  else if (diff == 2) fill(170);
  beginShape();
    vertex(0,topOffset);
    vertex(width/2, topOffset+height/3);
    vertex(width/2, height);
    vertex(0, height);
  endShape(CLOSE);
  
  // draw difficulty selector, darken currently selected
  textFont(menu);
  if (diff == 0) fill(20);
  else fill(100);
  text("Easy", width/4, height/2);
  if (diff == 1) fill(20);
  else fill(100);
  text("Medium", width/4, height/2+150);
  if (diff == 2) fill(20);
  else fill(100);
  text("Hard", width/4, height/2+300);
  
  
  // draw right ==================
  if (diff == 0) fill(220);
  else if (diff == 1) fill(180);
  else if (diff == 2) fill(150);
  beginShape();
    vertex(width,topOffset);
    vertex(width/2, topOffset+height/3);
    vertex(width/2, height);
    vertex(width, height);
  endShape(CLOSE);
  
  // draw level numbers
  fill(80);
  textFont(menu);
  text("1", LVL_LEFT, LVL_R1);
  text("2", LVL_MIDDLE, LVL_R1);
  text("3", LVL_RIGHT, LVL_R1);
  text("4", LVL_LEFT, LVL_R2);
  text("5", LVL_MIDDLE, LVL_R2);
  text("6", LVL_RIGHT, LVL_R2);
  text("7", LVL_LEFT, LVL_R3);
  text("8", LVL_MIDDLE, LVL_R3);
  text("9", LVL_RIGHT, LVL_R3);
  text("10", LVL_MIDDLE, LVL_R3+125);
}

void drawBoard() {
  
  // draw current objectives/board info ======
  String cubes = "cubes   "+board.size();
  String min = "min   "+boardMin;
  String max = "max   "+boardMax;
  textFont(game);
  float textY = height/5+20;
  
  if (isFinished) fill(0); // if objective met, darken
  else fill(150);
  text(cubes, width/4, textY);
  
  if (isFinished && board.size() == boardMin) fill(0);
  else fill(150);
  text(min, width/2, textY);
  
  if (isFinished && board.size() == boardMax) fill(0);
  else fill(150);
  text(max, width*3/4, textY);
  
  
  // draw navigation bar ====================
  noFill();
  strokeWeight(2);
  stroke(100);
  translate(width/2-XSHIFT*12, NAV_HEIGHT);
  if (diff != 0 || levelNo != 0) { // draw left button if not the very 1st level
    line(0,0,20,-20);
    line(0,0,20,20);
    line(0,0,50,0);
  }
  if (isFinished) { // draw next button if done
    translate(XSHIFT*24,0);
    line(0,0,-50,0);
    line(0,0,-20,-20);
    line(0,0,-20, 20);
  }
  resetMatrix();
  // draw menu button
  rect(width/2,NAV_HEIGHT,50,50);
  line(width/2,NAV_HEIGHT-5,width/2-25,NAV_HEIGHT-25);
  line(width/2,NAV_HEIGHT-5,width/2+25,NAV_HEIGHT-25);
  line(width/2,NAV_HEIGHT-5,width/2,NAV_HEIGHT+25);
  
  // draw current board =====================
  translate(width/2-XSHIFT, height*2/3); // "origin" to pop back to
  
  // draw two answer boards
  pushMatrix();
  isFinished = drawAnswers();
  popMatrix();
  
  // draw stage
  pushMatrix();
  translate(-XSHIFT*5, YSHIFT);
  drawBox(true);
  popMatrix();
  
  // draw grid
  pushMatrix();
  stroke(50);
  translate(XSHIFT,YSHIFT);
  for (int i=1; i<GRID_SIZE; i++) {
    line(-XSHIFT*i, ZSHIFT*i, XSHIFT*(6-i), ZSHIFT*(i+6));
    line(XSHIFT*i, ZSHIFT*i, -XSHIFT*(6-i), ZSHIFT*(i+6));
  }
  popMatrix();
  
  // draw boxes in list
  pushMatrix();
  board.sort(new BoxSort());
  PVector currentPos = new PVector(0,0,0);
  for(PVector p:board) {
    // move to match new position accordingly
    translateX((int)(p.x-currentPos.x));
    translateY((int)(p.y-currentPos.y));
    translateZ((int)(p.z-currentPos.z));
    drawBox(false);
    currentPos = p;
  }
  popMatrix();
  
  // draw rotate buttons
  pushMatrix();
  translateZ(5);
  translateY(-3);
  noFill();
  strokeWeight(3);
  stroke(150);
  line(0, 0, -8, 10);
  line(0, 0, 10, 8);
  arc(30, 0, 60, 60, HALF_PI, PI);
  
  translateZ(-6);
  translateX(6);
  noFill();
  strokeWeight(3);
  stroke(150);
  line(0, 0, -10, 8);
  line(0, 0, 8, 10);
  arc(-30, 0, 60, 60, 0, HALF_PI);
  popMatrix();
}

void drawBox(boolean isPlatform) {
  stroke(50);
  float xScaled = XSHIFT;
  float yScaled = YSHIFT+ZSHIFT;
  float zScaled = ZSHIFT;
  if (isPlatform) {
    stroke(1);
    xScaled = xScaled * 6;
    zScaled = zScaled * 6;
  } else {
    stroke(0.1);
  }
  
  // TOP
  fill(240);
  drawPgram(new PVector(xScaled,0), new PVector(-xScaled, zScaled), new PVector(xScaled, zScaled));
  
  // LEFT
  fill(180);
  if (isPlatform) {
    translate(0,32*scale);
    fill(219);
  }
  drawPgram(new PVector(0,zScaled), new PVector(xScaled, zScaled), new PVector(0, yScaled-zScaled));
  
  // RIGHT
  fill(140);
  if (isPlatform) fill(160);
  drawPgram(new PVector(xScaled,zScaled*2), new PVector(xScaled, -zScaled), new PVector(0, yScaled-zScaled));
}

boolean drawAnswers() {
  boolean isCorrect = true;
  
  // draw left board and grid
  fill(210);
  translate(XSHIFT, YSHIFT+ZSHIFT*1.5);
  translateX(-GRID_SIZE);
  stroke(50);
  strokeWeight(1);
  drawPgram(new PVector(0,0), new PVector(-XSHIFT*GRID_SIZE,ZSHIFT*GRID_SIZE), new PVector(0, -GRID_SIZE*YSHIFT));
  strokeWeight(0.1);
  for (int i=1; i<GRID_SIZE; i++) {
    line(-XSHIFT*i, ZSHIFT*i-YSHIFT*GRID_SIZE, -XSHIFT*i, ZSHIFT*i);
    line(-XSHIFT*GRID_SIZE, YSHIFT*(i-GRID_SIZE)+ZSHIFT*GRID_SIZE, 0, YSHIFT*(i-GRID_SIZE));
  }
  
  // draw answers of left board
  pushMatrix();
  for (int y=0; y<GRID_SIZE; y++) {
    for (int z=0; z<GRID_SIZE; z++) {
      // find if box occludes
      boolean found = false;
      for (int x=0; x<GRID_SIZE; x++) {
        if (board.contains(new PVector(x,y,z))) {
          fill(140);
          found = true;
          break;
        }
        else {
          fill(170);
        }
      }
      // if it's an answer
      if (level[0][y][z] == 1) {
        if (!found) isCorrect=false;
        drawPgram(new PVector(0,0), new PVector(-XSHIFT, ZSHIFT), new PVector(0, -YSHIFT));
      } else if (found) { // if there's a block where we don't want one
        isCorrect=false;
        strokeWeight(1);
        line(0, 0, -XSHIFT, ZSHIFT-YSHIFT);
        line(0, -YSHIFT, -XSHIFT, ZSHIFT);
        strokeWeight(0.1);
      }
      translateZ(1);
    }
    translateZ(-GRID_SIZE);
    translateY(1);
  }
  popMatrix();
  
  // draw right board and grid
  fill(210);
  translateZ(-GRID_SIZE);
  translateX(GRID_SIZE);
  strokeWeight(1);
  drawPgram(new PVector(0,0), new PVector(XSHIFT*GRID_SIZE,ZSHIFT*GRID_SIZE), new PVector(0, -GRID_SIZE*YSHIFT));
  strokeWeight(0.1);
  for (int i=1; i<GRID_SIZE; i++) {
    line(XSHIFT*i, ZSHIFT*i-YSHIFT*GRID_SIZE, XSHIFT*i, ZSHIFT*i);
    line(XSHIFT*GRID_SIZE, YSHIFT*(i-GRID_SIZE)+ZSHIFT*GRID_SIZE, 0, YSHIFT*(i-GRID_SIZE));
  }
  
  // draw answers on right board
  for (int y=0; y<GRID_SIZE; y++) {
    for (int x=0; x<GRID_SIZE; x++) {
      // find if box occludes
      boolean found = false;
      for (int z=0; z<GRID_SIZE; z++) {
        if (board.contains(new PVector(x,y,z))) {
          fill(140);
          found = true;
          break;
        } else {
          fill(170);
        }
      }
      // if it's an answer
      if (level[1][y][x] == 1) {
        if (!found) isCorrect=false;
          drawPgram(new PVector(0,0), new PVector(XSHIFT, ZSHIFT), new PVector(0, -YSHIFT));
        } else if (found) {
          isCorrect=false;
          strokeWeight(1);
          line(0, 0, XSHIFT, ZSHIFT-YSHIFT);
          line(0, -YSHIFT, XSHIFT, ZSHIFT);
          strokeWeight(0.1);
        }
        translateX(1);
    }
    translateX(-GRID_SIZE);
    translateY(1);
  }
  
  return isCorrect;
}

/** Rotates construction and answer board */
void rotateBoard(boolean anti) {
  // rotate blocks on platform
  int n = GRID_SIZE-1;
  ArrayList<PVector> tempBoard = new ArrayList<PVector>();
  for (int x=0; x<GRID_SIZE/2; x++) {
    for (int z=x; z<n-x; z++) {
      for (int y=0; y<GRID_SIZE; y++) {
        PVector a = new PVector(x,y,z);
        PVector b = new PVector(z,y,n-x);
        PVector c = new PVector(n-x,y,n-z);
        PVector d = new PVector(n-z,y,x);
        if (board.contains(a)) {
          board.remove(a);
          if (anti) tempBoard.add(b);
          else tempBoard.add(d);
        }
        if (board.contains(b)) {
          board.remove(b);
          if (anti) tempBoard.add(c);
          else tempBoard.add(a);
        }
        if (board.contains(c)) {
          board.remove(c);
          if (anti) tempBoard.add(d);
          else tempBoard.add(b);
        }
        if (board.contains(d)) {
          board.remove(d);
          if (anti) tempBoard.add(a);
          else tempBoard.add(c);
        }
      }
    }
  }
  board = tempBoard;
  
  // rotate answer board
  int[][][] tempAB = new int[2][GRID_SIZE][GRID_SIZE];
  if (anti) {
    // do right by copying left
    for (int i=0; i<GRID_SIZE; i++) {
      tempAB[1][i] = Arrays.copyOf(level[0][i], GRID_SIZE);
    }
    // do left by flipping right
    for (int i=0; i<GRID_SIZE; i++) {
      for (int j=0; j<GRID_SIZE; j++) {
        tempAB[0][i][j] = level[1][i][GRID_SIZE-1-j];
      }
    }
  } else {
    // do left by copying right
    for (int i=0; i<GRID_SIZE; i++) {
      tempAB[0][i] = Arrays.copyOf(level[1][i], GRID_SIZE);
    }
    // do right by flipping left
    for (int i=0; i<GRID_SIZE; i++) {
      for (int j=0; j<GRID_SIZE; j++) {
        tempAB[1][i][j] = level[0][i][GRID_SIZE-1-j];
      }
    }
  }
  
  // deep copy tempAB
  for (int b=0; b<2; b++) {
    for (int i=0; i<GRID_SIZE; i++) {
      level[b][i] = Arrays.copyOf(tempAB[b][i], GRID_SIZE);
    }
  }
}

void loadLevel() {
  Levels loader = new Levels();
  if (diff == 0) {
    level = loader.getEasyBoard(levelNo);
    boardMin = loader.getEasyInfo(levelNo)[0];
    boardMax = loader.getEasyInfo(levelNo)[1];
  } else if (diff == 1) {
    level = loader.getMediumBoard(levelNo);
    boardMin = loader.getMediumInfo(levelNo)[0];
    boardMax = loader.getMediumInfo(levelNo)[1];
  } else if (diff == 2) {
    level = loader.getHardBoard(levelNo);
    boardMin = loader.getHardInfo(levelNo)[0];
    boardMax = loader.getHardInfo(levelNo)[1];
  }
}

void goMenu() {
  screen = 0;
  board.clear();
  level = null;
  levelNo = -1;
  boardMax = 0;
  boardMin = 0;
}

void mousePressed() {
  if (screen == 0) {
    // selected difficulty, set diff
    if (abs(mouseX-width/4)<100 && abs(mouseY-height/2)<45) diff = 0;
    else if (abs(mouseX-width/4)<170 && abs(mouseY-height/2-150)<45) diff = 1;
    else if (abs(mouseX-width/4)<100 && abs(mouseY-height/2-300)<45) diff = 2;
    
    // selected level, set levelNo
    if (abs(mouseX-LVL_LEFT) < 50) {
      if (abs(mouseY-LVL_R1) < 33) levelNo = 0;
      else if (abs(mouseY-LVL_R2) < 33) levelNo = 3;
      else if (abs(mouseY-LVL_R3) < 33) levelNo = 6;
    } else if (abs(mouseX-LVL_MIDDLE) < 80) {
      if (abs(mouseY-LVL_R1) < 33) levelNo = 1;
      else if (abs(mouseY-LVL_R2) < 33) levelNo = 4;
      else if (abs(mouseY-LVL_R3) < 33) levelNo = 7;
      else if (abs(mouseY-LVL_R3-125) < 33) levelNo = 9;
    } else if (abs(mouseX-LVL_RIGHT) < 50) {
      if (abs(mouseY-LVL_R1) < 33) levelNo = 2;
      else if (abs(mouseY-LVL_R2) < 33) levelNo = 5;
      else if (abs(mouseY-LVL_R3) < 33) levelNo = 8;
    }
    
    if (levelNo > -1) { // if level selected, prepare game
      board.clear();
      loadLevel();
      screen = 1;
      return;
    }
  } else if (screen == 1) {
    // clicked the left rotate button
    if (abs(mouseX-(width/2-XSHIFT*6+15)) < 25 && abs(mouseY-(height*2/3+ZSHIFT*6+YSHIFT*3)) < 20) {
      rotateBoard(false);
    // clicked the right rotate button
    } else if (abs(mouseX-(width/2+XSHIFT*6-15)) < 25 && abs(mouseY-(height*2/3+ZSHIFT*6+YSHIFT*3)) < 20) {
      rotateBoard(true);
    }
    
    // clicked the previous level button
    else if (abs(mouseX-(width/2-XSHIFT*12+25)) < 25 && abs(mouseY-NAV_HEIGHT) < 20) { 
      levelNo--;
      if (levelNo < 0) { // boundary check if too low
        levelNo = 9;
        diff--;
      }
      board.clear();
      loadLevel();
    // clicked the menu button
    } else if (abs(mouseX-width/2) < 35 && abs(mouseY-NAV_HEIGHT) < 35) { 
      goMenu();
    // clicked the next button
    } else if (isFinished && abs(mouseX-(width/2+XSHIFT*12-25)) < 25 && abs(mouseY-NAV_HEIGHT) < 20) { 
      levelNo++;
      if (levelNo > 9) { // boundary check if too high
        levelNo = 0;
        diff++;
        if (diff == 3) goMenu();
      }
      board.clear();
      loadLevel();
    }
    
    PVector point = new PVector(mouseX-width/2, mouseY-(height*2/3+YSHIFT));
    for (int i=GRID_SIZE; i>=0; i--) {
      for (int j=GRID_SIZE; j>=0; j--) {
        for (int k=GRID_SIZE; k>=0; k--) {
          // init points and vectors for this iteration
          PVector top = new PVector(XSHIFT*i-XSHIFT*k, ZSHIFT*i-YSHIFT*j+ZSHIFT*k);
          PVector middle = PVector.add(top, new PVector(0, -ZSHIFT));
          PVector left = PVector.add(top, new PVector(-XSHIFT, -ZSHIFT*2));;
          PVector boxPos = new PVector(i,j,k);
          
          if (isOnLeft(left, point)) { // check if user clicked a left side
            if (board.contains(boxPos) && mouseButton == RIGHT) { // if the box exists and user wants to delete
              board.remove(boxPos);
              return;
            }
            PVector newBoxPos = new PVector(i,j,k+1);
            if (!board.contains(newBoxPos) && mouseButton == LEFT) { // if box isn't already there and user wants to add
              if ((board.contains(boxPos)) && (i<GRID_SIZE && j<GRID_SIZE && k<GRID_SIZE-1)) { 
                  // if we're able to stack the box on something and within bounds
                  board.add(newBoxPos);
                  return;
              }
            }
          }
          
          if (isOnRight(middle, point)) { // check if user clicked a right side
            if (board.contains(boxPos) && mouseButton == RIGHT) { // if the box exists and user wants to delete
              board.remove(boxPos);
              return;
            }
            PVector newBoxPos = new PVector(i+1,j,k);
            if (!board.contains(newBoxPos) && mouseButton == LEFT) { // if box isn't already there and user wants to add
              if (board.contains(boxPos) && (i<GRID_SIZE-1 && j<GRID_SIZE && k<GRID_SIZE)) { 
                  // if we're able to stack the box on something and within bounds\
                  board.add(newBoxPos);
                  return;
              }
            }
          }
          
          if (isOnTop(top, point)) { // check if user clicked a top
            PVector oldBoxPos = new PVector(i,j-1,k);
            if (board.contains(oldBoxPos) && mouseButton == RIGHT) { // if the box exists and user wants to delete
              board.remove(oldBoxPos);
              return;
            } else if (!board.contains(boxPos) && mouseButton == LEFT) { // if box isn't already there and user wants to add
              if ((j==0 || board.contains(oldBoxPos)) && (i<GRID_SIZE && j<GRID_SIZE && k<GRID_SIZE)) { 
                // if we're able to stack the box on something and within bounds
                board.add(boxPos);
                return;
              }
            }
          }
        }
      }
    }
  }
}
