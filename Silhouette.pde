import java.util.*;
private final float scale = 0.65;
private final float XSHIFT = 57*scale;
private final float ZSHIFT = 21*scale;
private final float YSHIFT = 73*scale;
private final int GRID_SIZE = 6;

private ArrayList<PVector> board = new ArrayList<PVector>();     // ordered based on viewing z-position
private ArrayList<BoxRecord> stack = new ArrayList<BoxRecord>(); // ordered based on creation
private int[][][] level;    // answer board
private int levelNo = -1;
private int boardMax = 6;
private int boardMin = 6;
private int screen = 0;     // 0 for menu, 1 for game    
private int diff = 0;       // 0 for easy, 1 medium, 2 hard
private float hue = 165;
private boolean isFinished = false;

// constants that determine where buttons are placed
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

void setBackground(int val) {
  background(hue, 160-(val/2), 140+(val/2));
}

void setFill(int val) {
  fill(hue, 160-(val/2), 140+(val/2));
}

void setStroke(int val) {
  stroke(hue, 160-(val/2), 140+(val/2));
}

void setup() {
  size(1300,1000); // minimum 1000x900
  strokeWeight(0.1);
  rectMode(CENTER);
  colorMode(HSB);
  textAlign(CENTER, CENTER);
  title = createFont("thin.ttf",120);
  menu = createFont("light.ttf",84); 
  game = createFont("light.ttf",48); 
  
  // set constants after width/height determined
  LVL_MIDDLE = width*3/4;
  LVL_LEFT = LVL_MIDDLE-120;
  LVL_RIGHT = LVL_MIDDLE+120;
  LVL_R1 = height/2-50;
  LVL_R2 = LVL_R1+125;
  LVL_R3 = LVL_R2+125;
  NAV_HEIGHT = height/9;
}

void draw() {
  if (diff == 0) setBackground(255);
  else if (diff == 1) setBackground(245);
  else if (diff == 2) setBackground(235);
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
  setFill(140);
  textFont(title);
  text("Silhouette.", width/2, topOffset);
  
  
  // draw left ===================
  if (diff == 0) setFill(230);
  else if (diff == 1) setFill(200);
  else if (diff == 2) setFill(170);
  beginShape();
    vertex(0,topOffset);
    vertex(width/2, topOffset+height/3);
    vertex(width/2, height);
    vertex(0, height);
  endShape(CLOSE);
  
  // draw difficulty selector, darken currently selected
  textFont(menu);
  if (diff == 0) setFill(20);
  else setFill(100);
  text("Easy", width/4, height/2);
  if (diff == 1) setFill(20);
  else setFill(100);
  text("Medium", width/4, height/2+150);
  if (diff == 2) setFill(20);
  else setFill(100);
  text("Hard", width/4, height/2+300);
  
  
  // draw right ==================
  if (diff == 0) setFill(220);
  else if (diff == 1) setFill(180);
  else if (diff == 2) setFill(150);
  beginShape();
    vertex(width,topOffset);
    vertex(width/2, topOffset+height/3);
    vertex(width/2, height);
    vertex(width, height);
  endShape(CLOSE);
  
  // draw level numbers
  setFill(80);
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
  
  if (isFinished) setFill(0); // if objective met, darken
  else setFill(150);
  text(cubes, width/4, textY);
  
  if (isFinished && board.size() == boardMin) setFill(0);
  else setFill(150);
  text(min, width/2, textY);
  
  if (isFinished && board.size() == boardMax) setFill(0);
  else setFill(150);
  text(max, width*3/4, textY);
  
  
  // draw navigation bar ====================
  noFill();
  strokeWeight(2);
  setStroke(100);
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
    translate(-XSHIFT*24,0);
  }
  
  // draw menu button
  translate(XSHIFT*12,0);
  rect(0,0,50,50);
  line(0,-5,-25,-25);
  line(0,-5,25,-25);
  line(0,-5,0,25);
  
  // draw clear button
  translate(-85,0);
  line(-15,-15,15,15);
  line(-15,15,15,-15);
  
  // draw undo button
  translate(160, 0); 
  line(8, -20, 0, -15);
  line(0, -15, 5, -5);
  arc(0, 0, 35, 30, 3*HALF_PI, 5*HALF_PI);
  resetMatrix();
  
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
  setStroke(50);
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
  strokeWeight(2);
  setStroke(150);
  line(0, 0, -8, 10);
  line(0, 0, 10, 8);
  arc(30, 0, 60, 60, HALF_PI, PI);
  
  translateZ(-6);
  translateX(6);
  line(0, 0, -10, 8);
  line(0, 0, 8, 10);
  arc(-30, 0, 60, 60, 0, HALF_PI);
  popMatrix();
}

void drawBox(boolean isPlatform) {
  setStroke(50);
  float xScaled = XSHIFT;
  float yScaled = YSHIFT+ZSHIFT;
  float zScaled = ZSHIFT;
  if (isPlatform) {
    xScaled = xScaled * 6;
    zScaled = zScaled * 6;
  }
  
  // TOP
  setFill(240);
  drawPgram(new PVector(xScaled,0), new PVector(-xScaled, zScaled), new PVector(xScaled, zScaled));
  
  // LEFT
  setFill(200);
  if (isPlatform) {
    translate(0,32*scale);
  }
  drawPgram(new PVector(0,zScaled), new PVector(xScaled, zScaled), new PVector(0, yScaled-zScaled));
  
  // RIGHT
  setFill(160);
  drawPgram(new PVector(xScaled,zScaled*2), new PVector(xScaled, -zScaled), new PVector(0, yScaled-zScaled));
}

/**
* Draws two answer boards to the side of the platform
* @return if the answer board silhouette has been constructed
*/
boolean drawAnswers() {
  boolean isCorrect = true;
  
  // draw left board and grid
  setFill(230);
  translate(XSHIFT, YSHIFT+ZSHIFT*1.5);
  translateX(-GRID_SIZE);
  setStroke(50);
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
      // find if box occludes, set the fill beforehand
      boolean found = false;
      for (int x=0; x<GRID_SIZE; x++) {
        if (board.contains(new PVector(x,y,z))) {
          setFill(170);
          found = true;
          break;
        }
        else {
          setFill(190);
        }
      }
      
      // if it's an answer, draw with corresponding fill
      if (level[0][y][z] == 1) {
        if (!found) isCorrect=false;
        drawPgram(new PVector(0,0), new PVector(-XSHIFT, ZSHIFT), new PVector(0, -YSHIFT));
      } else if (found) { // if there's a block where we don't want one, draw X
        isCorrect = false;
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
  setFill(230);
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
          setFill(170);
          found = true;
          break;
        } else {
          setFill(190);
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

/**
* Do one swap of PVector oldPos to newPos, putting it inside a temporary board List
* e.g. ..y. x -> y clockwise
*      x..b a -> b anticlockwise
*      .ji. i -> j clockwise
*      ..a.
*/
void singleRotate(PVector oldPos, PVector newPos, ArrayList<PVector> temp) {
  int i = stack.indexOf(new BoxRecord(oldPos, true));
  if (i<0) i = stack.indexOf(new BoxRecord(oldPos, false));
  board.remove(oldPos);
  temp.add(newPos);
  stack.set(i, new BoxRecord(newPos, stack.get(i).isRemoval()));
}

/** Rotates construction and answer board */
void rotateBoard(boolean anti) {
  // rotate blocks on platform
  int n = GRID_SIZE-1;
  ArrayList<PVector> tempBoard = new ArrayList<PVector>();
  for (int x=0; x<GRID_SIZE/2; x++) {
    for (int z=x; z<n-x; z++) {
      for (int y=0; y<GRID_SIZE; y++) { // for each layer, do the x<->z rotation
        PVector a = new PVector(x,y,z);
        PVector b = new PVector(z,y,n-x);
        PVector c = new PVector(n-x,y,n-z);
        PVector d = new PVector(n-z,y,x);
        if (board.contains(a)) {
          if (anti) singleRotate(a,b,tempBoard);
          else singleRotate(a,d,tempBoard);
        }
        if (board.contains(b)) {
          if (anti) singleRotate(b,c,tempBoard);
          else singleRotate(b,a,tempBoard);
        }
        if (board.contains(c)) {
          if (anti) singleRotate(c,d,tempBoard);
          else singleRotate(c,b,tempBoard);
        }
        if (board.contains(d)) {
          if (anti) singleRotate(d,a,tempBoard);
          else singleRotate(d,c,tempBoard);
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

/**
* Load level based on the currently stored levelNo
*/
void loadLevel() {
  if (diff == 0) {
    level = Levels.getEasyBoard(levelNo);
    boardMin = Levels.getEasyInfo(levelNo)[0];
    boardMax = Levels.getEasyInfo(levelNo)[1];
  } else if (diff == 1) {
    level = Levels.getMediumBoard(levelNo);
    boardMin = Levels.getMediumInfo(levelNo)[0];
    boardMax = Levels.getMediumInfo(levelNo)[1];
  } else if (diff == 2) {
    level = Levels.getHardBoard(levelNo);
    boardMin = Levels.getHardInfo(levelNo)[0];
    boardMax = Levels.getHardInfo(levelNo)[1];
  }
}

/**
* Reset game board and show menu
*/
void goMenu() {
  if (screen == 0) throw new RuntimeException("Screen already at menu.");
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
    // clicked the clear button
    } else if (abs(mouseX-(width/2-85)) < 15 && abs(mouseY-NAV_HEIGHT) < 15) { 
      board.clear();
      stack.clear();
    // clicked the menu button
    } else if (abs(mouseX-width/2) < 35 && abs(mouseY-NAV_HEIGHT) < 35) { 
      goMenu();
    // clicked the undo button
    } else if (abs(mouseX-(width/2+93)) < 15 && abs(mouseY-NAV_HEIGHT) < 20) { 
      if (!stack.isEmpty()) {
        BoxRecord todo = stack.remove(stack.size()-1);
        PVector pos = todo.getPosition();
        if (todo.isRemoval()) {
          board.add(pos);
        } else {
          board.remove(pos);
        }
      }
    // clicked the next button
    } else if (isFinished && abs(mouseX-(width/2+XSHIFT*12-25)) < 25 && abs(mouseY-NAV_HEIGHT) < 20) { 
      if (diff == 2 && levelNo == 9) { // reached end of prepared levels
        goMenu();
      } else {
        levelNo++;
        if (levelNo > 9) { // boundary check if too high
          levelNo = 0;
          diff++;
        }
        board.clear();
        loadLevel();
      }
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
              stack.add(new BoxRecord(boxPos, true));
              return;
            }
            PVector newBoxPos = new PVector(i,j,k+1);
            if (!board.contains(newBoxPos) && mouseButton == LEFT) { // if box isn't already there and user wants to add
              if ((board.contains(boxPos)) && (i<GRID_SIZE && j<GRID_SIZE && k<GRID_SIZE-1)) { 
                  // if we're able to stack the box on something and within bounds
                  board.add(newBoxPos);
                  stack.add(new BoxRecord(newBoxPos, false));
                  return;
              }
            }
          }
          
          if (isOnRight(middle, point)) { // check if user clicked a right side
            if (board.contains(boxPos) && mouseButton == RIGHT) { // if the box exists and user wants to delete
              board.remove(boxPos);
              stack.add(new BoxRecord(boxPos, true));
              return;
            }
            PVector newBoxPos = new PVector(i+1,j,k);
            if (!board.contains(newBoxPos) && mouseButton == LEFT) { // if box isn't already there and user wants to add
              if (board.contains(boxPos) && (i<GRID_SIZE-1 && j<GRID_SIZE && k<GRID_SIZE)) { 
                  // if we're able to stack the box on something and within bounds\
                  board.add(newBoxPos);
                  stack.add(new BoxRecord(newBoxPos, false));
                  return;
              }
            }
          }
          
          if (isOnTop(top, point)) { // check if user clicked a top
            PVector oldBoxPos = new PVector(i,j-1,k);
            if (board.contains(oldBoxPos) && mouseButton == RIGHT) { // if the box exists and user wants to delete
              board.remove(oldBoxPos);
              stack.add(new BoxRecord(oldBoxPos, true));
              return;
            } else if (!board.contains(boxPos) && mouseButton == LEFT) { // if box isn't already there and user wants to add
              if ((j==0 || board.contains(oldBoxPos)) && (i<GRID_SIZE && j<GRID_SIZE && k<GRID_SIZE)) { 
                // if we're able to stack the box on something and within bounds
                board.add(boxPos);
                stack.add(new BoxRecord(boxPos, false));
                return;
              }
            }
          }
        }
      }
    }
  }
}
