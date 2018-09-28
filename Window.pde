class Pen {
  float size;
  float[] prev;
  
  Pen(float s) {
    size = s;
    prev = new float[2];
  }
  
  void set_prev() {
    prev[0] = mouseX;
    prev[1] = mouseY;
  }
}


class Camera {
  float x, y;

  Camera() {
    x = 0;
    y = 0;
  }
  
  float[] pos(Bot lead) {
    x += 0.05 * (lead.machine.x - x);
    y += 0.05 * (lead.machine.y - y);
    return new float[] {x, y};
  }
  
  void set_pos(Bot bot) {
    x = bot.machine.x;
    y = bot.machine.y;
  }
}