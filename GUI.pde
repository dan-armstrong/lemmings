class Menu {
  PFont font;
  int page;
  
  Menu() {
    font = createFont("Avenir Next", 16);
    page = 1;
  }
  
  void display() {
    if (page > 0) {
      rectMode(CENTER);
      fill(255);
      noStroke();
      rect(width*0.5, height*0.5, width*0.6, 155, 7);                          
      textAlign(CENTER, CENTER);
      fill(255);
      textAlign(CENTER, CENTER);
      fill(35);
    }
    
    if (page == 1) {
      textFont(font, 40);
      text("HELP", width*0.5, height*0.5 - 60);
      textFont(font, 20);
      text("THIS IS AN AI RACING EXPERIMENT", width*0.5, height*0.5 - 23);
      text("EACH CAR LEARNS HOW TO RACE THE TRACK", width*0.5, height*0.5 + 1);
      text("THEY DO THIS VIA EVOLUTIONARY NEURAL NETWORKS", width*0.5, height*0.5 + 25);
      text("PRESS [H] TO TOGGLE HELP", width*0.5, height*0.5 + 49);
    }
    
    else if (page == 2) {
      textFont(font, 40);
      text("HELP", width*0.5, height*0.5 - 60);
      textFont(font, 20);
      text("USE THE MOUSE TO DRAW A TRACK", width*0.5, height*0.5 - 23);
      text("CLICK (NOT DRAG) TO DRAW CORNERS OF TRACK", width*0.5, height*0.5 + 1);
      text("TRACK MUST BE A LOOP TO START BOTS", width*0.5, height*0.5 + 25);
      text("PRESS [R] TO RESET TRACK & LEARNING", width*0.5, height*0.5 + 49);
    }
  }
  
  void change_page() {
    page++;
    if (page > 2) {page = 0;}
  }
}