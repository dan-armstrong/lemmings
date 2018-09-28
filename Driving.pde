class Car {
  Track track;
  float x, y, speed, direction;
  float prev_x, prev_y, prev_direction;
  float max_speed, max_acceleration, max_steering;
  float view_angle, view_depth;
  int birth_time, checkpoint_time, checkpoint_limit;
  Ray[] rays;
  float size;
  int checkpoint = 0;
  Boolean dead = false;
  Boolean completed = false;
  Boolean best = false;
  color colour;

  Car(Car prev, Track t) {
    track = t;
    x = track.points.get(0)[0];
    y = track.points.get(0)[1];
    direction = atan2(track.points.get(1)[1] - y, track.points.get(1)[0] - x);
    prev_x = x;
    prev_y = y;
    prev_direction = direction;
    max_speed = prev.max_speed;
    max_acceleration = prev.max_acceleration;
    max_steering = prev.max_steering;
    view_angle = prev.view_angle;
    view_depth = prev.view_depth;
    birth_time = frameCount;
    checkpoint_time = frameCount;
    checkpoint_limit = floor(frameRate * 7);
    size = prev.size;
    generate_rays(prev.rays.length);
    colour = prev.colour;
  }

  Car(float spd, float ang, float dep, int num, Track t, color col) {
    track = t;
    x = track.points.get(0)[0];
    y = track.points.get(0)[1];
    direction = atan2(track.points.get(1)[1] - y, track.points.get(1)[0] - x);
    prev_x = x;
    prev_y = y;
    prev_direction = direction;
    max_speed = spd;
    max_acceleration = 0.3;
    max_steering = 0.1;
    view_angle = ang;
    view_depth = dep;
    birth_time = frameCount;
    checkpoint_time = frameCount;
    checkpoint_limit = floor(frameRate * 7);
    size = 5;
    generate_rays(num);
    colour = col;
  }

  void display() {
    noStroke();
    fill(colour);
    if (best) {
      fill(0,0,255);
    }
    ellipse(x, y, size, size);
    //for (Ray ray : rays) {
      //ray.display();
    //}
  }
  
  void display(color col) {
    fill(col);
    ellipse(x, y, size, size);
  }
  
  void drive(float acceleration, float steering) {
    prev_x = x;
    prev_y = y;
    prev_direction = direction;
    speed += max_acceleration * acceleration;
    speed = max(min(speed, max_speed), -max_speed);
    direction += max_steering * steering;
    direction %= 2*PI;
    x += speed*cos(direction);
    y += speed*sin(direction);
    if (check_crashed()) {dead = true;}
    if (check_time()) {dead = true;}
    if (check_completed()) {
      dead = true;
      completed = true;
    }
    display();
  }

  void generate_rays(int n) {
    rays = new Ray[n];
    float min_angle = - view_angle/2.0;
    float interval = view_angle/float(rays.length-1);
    for (int i=0; i<rays.length; i++) {
      float angle = min_angle + i*interval;
      rays[i] = new Ray(angle, view_depth, this);
    }
  }
  
  float[] get_ray_distances() {
    float[] distances = new float[rays.length];
    for (int i = 0; i < rays.length; i++) {
      distances[i] = rays[i].distance();
    }
    return distances;
  }
  
  Boolean check_crashed() {
    for (Segment segment : track.segments) {
      if(segment.intersects(this)) {return true;}
    }
    for (Corner corner : track.corners) {
      if(corner.intersects(this)) {return true;}
    }
    return false;
  }
  
  Boolean check_time() {
    if (frameCount - checkpoint_time > checkpoint_limit) {
      return true;
    }
    return false;
  }

  Boolean check_completed() {
    if (checkpoint == track.checkpoints.size()) {return true;}
    while (track.checkpoints.get(checkpoint).met(this)) {
      checkpoint += 1;
      checkpoint_time = frameCount;
      if (checkpoint == track.checkpoints.size()) {return true;}
    }
    return false;
  }
  
  float distance() {
    float distance_travelled = 0;
    for (int i = 0; i < checkpoint; i++) {
      distance_travelled += track.segments.get(i).distance();
    }
    if (!completed) {
      distance_travelled += track.segments.get(checkpoint).distance(new float[] {x, y});
    }
    return distance_travelled;
  }
  
  float speed() {
    float lap_time = (frameCount - birth_time);
    return distance() / lap_time;
  }
}



class Ray {
  float angle, distance;
  Car master;
  
  Ray(float a, float d, Car car) {
    angle = a;
    distance = d;
    master = car;
  }

  void display() {
    stroke(master.colour);
    strokeWeight(master.size/2);
    float[] pos = intersect();
    point(pos[0], pos[1]);
  }

  float[] position() {
    float x = master.x + master.view_depth*cos(master.direction+angle);
    float y = master.y + master.view_depth*sin(master.direction+angle);
    return new float[] {x, y};
  }

  float[] intersect() {
    float[] min_intersect = position();
    float min_distance = pow(master.view_depth, 2);
    Boolean within_behind = true;
    Boolean within_ahead = true;
    Boolean ahead_range_segment = true;
    Boolean ahead_range_corner = true;
    Boolean behind_range_segment = true;
    Boolean behind_range_corner = true;
    int count = 0;
    while (within_behind || within_ahead) {
      int ahead = master.checkpoint + count;
      int behind = master.checkpoint - count;
      
      if (ahead < master.track.segments.size()) {
        Segment segment = master.track.segments.get(ahead);
        float[] intersect = segment.get_intersect(this);
        if (intersect != null) {
          float distance = pow(master.x-intersect[0], 2) + pow(master.y-intersect[1], 2);
          if (distance < min_distance) {
            min_intersect = intersect;
            min_distance = distance;
          }
        }
        if (!segment.within_range(master)) {ahead_range_segment = false;}
      }
      
      if (ahead < master.track.corners.size()) {
        Corner corner = master.track.corners.get(ahead);
        float[] intersect = corner.get_intersect(this);
        if (intersect != null) {
          float distance = pow(master.x-intersect[0], 2) + pow(master.y-intersect[1], 2);
          if (distance < min_distance) {
            min_intersect = intersect;
            min_distance = distance;
          }
        }
        if (!corner.within_range(master)) {ahead_range_corner = false;}
      }
      
      if (behind >= 0) {
        Segment segment = master.track.segments.get(behind);
        float[] intersect = segment.get_intersect(this);
        if (intersect != null) {
          float distance = pow(master.x-intersect[0], 2) + pow(master.y-intersect[1], 2);
          if (distance < min_distance) {
            min_intersect = intersect;
            min_distance = distance;
          }
        }
        if (!segment.within_range(master)) {behind_range_segment = false;}

        Corner corner = master.track.corners.get(behind);
        intersect = corner.get_intersect(this);
        if (intersect != null) {
          float distance = pow(master.x-intersect[0], 2) + pow(master.y-intersect[1], 2);
          if (distance < min_distance) {
            min_intersect = intersect;
            min_distance = distance;
          }
        }
        if (!corner.within_range(master)) {behind_range_corner = false;}
      }

      if (ahead >= master.track.segments.size() && ahead >= master.track.corners.size()) {within_ahead = false;}
      if (!ahead_range_segment && !ahead_range_corner) {within_ahead = false;}
      if (behind < 0) {within_behind = false;}
      if (!behind_range_segment && !behind_range_corner) {within_behind = false;}
      count++;
    }
    return min_intersect;
  }
  
  float distance() {
    float[] pos = intersect();
    return sqrt(pow(master.x-pos[0], 2) + pow(master.y-pos[1], 2));
  }
}