Pen pen;
Camera camera;
color BG_COL = color(30);
color WALL_COL = color(255);
color INVALID_COL = color(204,51,63);
color[] CAR_COLS = {color(255,0,255), color(0,255,0), color(0,0,255), color(255,0,255), color(255,255,0), color(0,255,255)};
boolean LOAD = false;
Generation squad;
Track track;
Menu menu;

void setup() {
  size(900,600);
  frameRate(30);
  pixelDensity(displayDensity());
  background(BG_COL);
  ellipseMode(RADIUS);
  pen = new Pen(2);
  camera = new Camera();
  track = new Track(50.0);
  menu = new Menu();
}


void draw() {
  background(BG_COL);
  track.display();
  if (squad != null) {
    squad.step();
    if (squad.finished()) {
      squad = new Generation(squad, 0.15, 0.4, 0.2, track);
    }
  }
  else if (!track.building) {
    squad = new Generation(75, 10, new int[] {6}, track, color(#FF0066));
  }
  menu.display();
}


void mousePressed() {
  track.create(new float[] {mouseX, mouseY});
  pen.set_prev();
}

void keyPressed() {
  if (keyCode == BACKSPACE || keyCode == RETURN) {track.delete();}
  if (key == 'h' || key == 'H') {menu.change_page();}
  if (key == 'r' || key == 'R') {
    menu.page = 1;
    track = new Track(50.0);
    squad = null;
  }
}