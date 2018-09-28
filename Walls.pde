class Track {
  ArrayList<float[]> points;
  ArrayList<Segment> segments;  
  ArrayList<Corner> corners;  
  ArrayList<Checkpoint> checkpoints;  
  float size, wall_thickness;
  Segment display_segment_a, display_segment_b, display_segment_c;
  Corner display_corner_a, display_corner_b, start_cap, end_cap;
  Boolean building = true;
  Boolean restrict_width = true;

  Track(String name) {
    String[] records = loadStrings(name + ".csv");
    String[] data = split(records[0], ",");
    size = float(data[0]);
    wall_thickness = float(data[1]);
    points = new ArrayList<float[]>();
    segments = new ArrayList<Segment>();
    corners = new ArrayList<Corner>();
    checkpoints = new ArrayList<Checkpoint>();
    for (int i = 1; i < records.length; i++) {
      data = split(records[i], ",");
      float[] pos = {float(data[0]), float(data[1])};
      create(pos);
    }
    data = split(records[1], ",");
    float[] pos = {float(data[0]), float(data[1])};
    create(pos);
  }

  Track(float s) {
    size = s;
    wall_thickness = 2;
    points = new ArrayList<float[]>();
    segments = new ArrayList<Segment>();
    corners = new ArrayList<Corner>();
    checkpoints = new ArrayList<Checkpoint>();
  }

  Track(float s, int n, float a, float r) {
    size = s;
    wall_thickness = 2;
    points = new ArrayList<float[]>();
    segments = new ArrayList<Segment>();
    corners = new ArrayList<Corner>();
    checkpoints = new ArrayList<Checkpoint>();
    restrict_width = false;
    float root = 0;
    float max = 0;
    while (points.size() <= n) {
      if (points.size() > max) {
        root = max;
      }
      Boolean generated = generate(a, r);
      if (!generated) {
        root = max(root-1, 0);
        while (points.size() > root) {
          delete();
        }
      }
    }
    corners.add(new Corner(segments.get(n-1), false));
    building = false;
  }

  void create(float[] pos) {
    generate_display_ojects(pos);
    if (valid_point(pos) && building) {
      if (start_selected(pos)) {
        segments.add(new Segment(points.get(points.size()-1), points.get(0), size, wall_thickness, segments.get(segments.size()-1), segments.get(0)));
        corners.add(new Corner(segments.get(segments.size()-2), segments.get(segments.size()-1), points.get(points.size()-1)));
        corners.add(new Corner(segments.get(segments.size()-1), segments.get(0), points.get(0)));
        checkpoints.add(new Checkpoint(segments.get(segments.size()-2), segments.get(segments.size()-1), points.get(points.size()-1)));
        checkpoints.add(new Checkpoint(segments.get(segments.size()-1), segments.get(0), points.get(0)));
        building = false;
      }
      else {
        points.add(pos);
        if (points.size() > 1) {
          if (segments.size() > 0){
            segments.add(new Segment(points.get(points.size()-2), points.get(points.size()-1), size, wall_thickness, segments.get(segments.size()-1)));
            corners.add(new Corner(segments.get(segments.size()-2), segments.get(segments.size()-1), points.get(points.size()-2)));
            checkpoints.add(new Checkpoint(segments.get(segments.size()-2), segments.get(segments.size()-1), points.get(points.size()-2)));
          }
          else{
            segments.add(new Segment(points.get(points.size()-2), points.get(points.size()-1), size, wall_thickness, null));
          }
        }
      }
    }
  }

  Boolean generate(float max_angle, float max_range) {
    float[] pos;
    float[] prev;
    float prev_angle;
    
    if (points.size() > 1) {
      prev = points.get(points.size()-1);
      float[] prev_prev = points.get(points.size()-2);
      prev_angle = atan2(prev[1] - prev_prev[1], prev[0] - prev_prev[0]);
    }
    else if (points.size() > 0) {
      prev = points.get(points.size()-1);
      prev_angle = 0;
    }
    else {
      prev = new float[] {width*0.25 + random(width*0.5), height*0.25 + random(height*0.5)};
      prev_angle = 0;
    }
    float angle = prev_angle + random(-max_angle, max_angle);
    float range = random(-max_range, max_range);
    pos = new float[] {prev[0] + cos(angle)*range, prev[1] + sin(angle)*range};
    generate_display_ojects(pos);
    float count = 0;
    while ((!valid_point(pos) || start_selected(pos)) && count < 10) {
      angle = prev_angle + random(-max_angle, max_angle);
      range = random(-max_range, max_range);
      pos = new float[] {prev[0] + cos(angle)*range, prev[1] + sin(angle)*range};
      generate_display_ojects(pos);
      count += 1;
    }
    if (valid_point(pos)) {
      create(pos);
      if (points.size() == 2) {corners.add(new Corner(segments.get(0), true));}
      return true;
    }
    return false;
  }

  void delete() {
    if (building) {
      if (points.size() > 0) {points.remove(points.size()-1);}
      if (segments.size() > 0) {segments.remove(segments.size()-1);}
      if (corners.size() > 0) {corners.remove(corners.size()-1);}
      if (checkpoints.size() > 0) {checkpoints.remove(checkpoints.size()-1);}
    }
  }

  void store(String file_name) {
    if (!building) {
      PrintWriter file = createWriter(file_name + ".csv");
      file.print(str(size) + "," + str(wall_thickness));
      for (float[] point : points) {
        file.print("\n" + str(point[0]) + "," + str(point[1]));
      }
      file.flush();
      file.close();
    }
  }

  void display() {
    float[] display_point = {mouseX, mouseY};
    if (!building) {
      for (Segment segment : segments) {
        segment.display();
      }
      for (Corner corner : corners) {
        corner.display();
      }
    }
    
    else {
      for (int i = 0; i < segments.size()-1; i++) {
        if (!(i == 0 && start_selected(display_point))) {
          segments.get(i).display();
        }
      }
      for (Corner corner : corners) {
        corner.display();
      }
      generate_display_ojects(display_point);
      Boolean valid_point = valid_point(display_point);
      Boolean display_caps = true;
      
      if (points.size() > 1) {
        if(point_moved(display_point)) {
          if (start_selected(display_point)) {
            display_segment_c.display();
            display_corner_b.display();
            display_caps = false;
          }
          if (valid_point) {display_segment_a.display();}
          else {display_segment_a.display(INVALID_COL);}
          display_corner_a.display();
        }
        display_segment_b.display();
      }
      else if (points.size() == 1) {
        if (point_moved(display_point)) {
          if (valid_point) {display_segment_a.display();}
          else {display_segment_a.display(INVALID_COL);}
        }
      }
      if (display_caps) {
        start_cap.display();
        if (points.size() > 0) {
          if (!point_moved(display_point)) {
            end_cap.display();
          }
          else {
            if (valid_point) {end_cap.display();}
            else {end_cap.display(INVALID_COL);}
          }
        }
        else {
          if (valid_point) {end_cap.display();}
          else {end_cap.display(INVALID_COL);}
        }
      }
    }
  }
  
  void generate_display_ojects(float[] pos) {
    if (points.size() == 0) {
      start_cap = new Corner(pos, size*0.5, wall_thickness);
      end_cap = new Corner(pos, size*0.5, wall_thickness);
    }
    else if (points.size() == 1) {
      if (point_moved(pos)) {
        display_segment_a = new Segment(points.get(points.size()-1), pos, size, wall_thickness, null);
        start_cap = new Corner(display_segment_a, true);
        end_cap = new Corner(display_segment_a, false);
      }
      else {
        start_cap = new Corner(pos, size*0.5, wall_thickness);
        end_cap = new Corner(pos, size*0.5, wall_thickness);
      }
    }
    else {
      start_cap = new Corner(segments.get(0), true);
      if (segments.size() > 1) {
        Segment duplicate_segment_b = new Segment(points.get(points.size()-3), points.get(points.size()-2), size, wall_thickness, null);
        display_segment_b = new Segment(points.get(points.size()-2), points.get(points.size()-1), size, wall_thickness, duplicate_segment_b);
        if (start_selected(pos)) {
          Segment duplicate_segment_c = new Segment(points.get(1), points.get(2), size, wall_thickness, null);
          display_segment_c = new Segment(points.get(0), points.get(1), size, wall_thickness, null, duplicate_segment_c);
        }
      }
      else {
        display_segment_b = new Segment(points.get(points.size()-2), points.get(points.size()-1), size, wall_thickness, null);
        if (start_selected(pos)) {
          display_segment_c = new Segment(points.get(0), points.get(1), size, wall_thickness, null);
        }
      }
      if (point_moved(pos)) {
        if (start_selected(pos)) {
          display_segment_a = new Segment(points.get(points.size()-1), points.get(0), size, wall_thickness, display_segment_b, display_segment_c);
          display_corner_b = new Corner(display_segment_a, display_segment_c, points.get(0));
        }
        else {
          display_segment_a = new Segment(points.get(points.size()-1), pos, size, wall_thickness, display_segment_b);
        }
        display_corner_a = new Corner(display_segment_b, display_segment_a, points.get(points.size()-1));
        end_cap = new Corner(display_segment_a, false);
      }
      else {
        end_cap = new Corner(segments.get(segments.size()-1), false);
      }
    }
  }
    
  Boolean valid_point(float[] point) {
    if (start_selected(point)) {
      if (display_segment_a.invalid) {return false;}
      for (int i = 1; i < segments.size()-1; i++) {
        if (display_segment_a.intersects(segments.get(i))) {return false;}
      }
      for (Corner corner : corners) {
        if (display_segment_a.intersects(corner)) {return false;}
      }
      return true;
    }
    
    if (restrict_width) {
      if (point[0]-size*0.5 < 0 || point[0]+size*0.5 > width) {return false;}
      if (point[1]-size*0.5 < 0 || point[1]+size*0.5 > height) {return false;}
    }
    
    if (!point_moved(point)) {return false;}
    if (start_cap.intersects(end_cap)) {return false;}

    if (points.size() > 0) {
      if (display_segment_a.invalid) {return false;}
      if (display_segment_a.intersects(start_cap) && points.size() > 1) {return false;}
      for (int i = 0; i < segments.size()-1; i++) {
        if (display_segment_a.intersects(segments.get(i))) {return false;}
      }
      for (Corner corner : corners) {
        if (display_segment_a.intersects(corner)) {return false;}
      }
    }
    
    for (int i = 0; i < segments.size(); i++) {
      if (i != 0) {
        if (start_cap.intersects(segments.get(i))) {return false;}
      }
      if (i != segments.size()-1) {
        if (end_cap.intersects(segments.get(i))) {return false;}
      }
    }
    
    for (Corner corner : corners) {
      if (start_cap.intersects(corner)) {return false;}
      if (end_cap.intersects(corner)) {return false;}
    }
    return true;
  }
  
  Boolean point_moved(float[] pos) {
    if (points.size() > 0) {
      if (points.get(points.size()-1)[0] == pos[0] && points.get(points.size()-1)[1] == pos[1]) {  
        return false;
      }
    }
    return true;
  }

  Boolean start_selected(float[] pos) {
    if (points.size() > 1) {
      if (pow(points.get(0)[0]-pos[0], 2) + pow(points.get(0)[1]-pos[1], 2) < pow(size/2.0, 2)) {
        return true;
      }
    }
    return false;
  }
}



class Segment {
  float[][][] walls; 
  float[][][] edges; 
  float x1, y1, x2, y2, diameter, thickness;
  Segment prev, next;
  boolean invalid = false;

  Segment(float[] a, float[] b, float d, float t, Segment p) {
    x1 = a[0];
    y1 = a[1];
    x2 = b[0];
    y2 = b[1];
    diameter = d;
    thickness = t;
    prev = p;
    next = null;
    if (prev != null) {prev.next = this;}
    generate_walls();
    generate_edges();
  }

  Segment(float[] a, float[] b, float d, float t, Segment p, Segment n) {
    x1 = a[0];
    y1 = a[1];
    x2 = b[0];
    y2 = b[1];
    diameter = d;
    thickness = t;
    prev = p;
    next = n;
    if (prev != null) {prev.next = this;}
    if (next != null) {next.prev = this;}
    generate_walls();
    generate_edges();
  }
  
  void display() {
    stroke(WALL_COL);
    strokeWeight(thickness);
    line(walls[0][0][0], walls[0][0][1], walls[0][1][0], walls[0][1][1]);
    line(walls[1][0][0], walls[1][0][1], walls[1][1][0], walls[1][1][1]);
  }

  void display(color col) {
    noFill();
    stroke(col);
    strokeWeight(thickness);
    line(walls[0][0][0], walls[0][0][1], walls[0][1][0], walls[0][1][1]);
    line(walls[1][0][0], walls[1][0][1], walls[1][1][0], walls[1][1][1]);
  }
  
  void generate_walls() {
    float[] direction = {x2-x1, y2-y1};                                                                  //DIRECTION OF SEGMENT
    float scalar = diameter*0.5 / sqrt(pow(direction[0], 2) + pow(direction[1], 2));                     //NORMALISE AND THEN SCALE TO DIAMETER
    float[] shift = {direction[1]*scalar, -direction[0]*scalar};                                         //SHIFT EACH EDGE PERPENDICULAR TO SEGMENT
    float[][] positive = new float[][] {new float[] {x1+shift[0], y1+shift[1]}, new float[] {x2+shift[0], y2+shift[1]}};
    float[][] negative = new float[][] {new float[] {x1-shift[0], y1-shift[1]}, new float[] {x2-shift[0], y2-shift[1]}};
    walls = new float[][][] {positive, negative};
    
    if (prev != null) {//SHORTEN WALLS IF CURRENT/PREV INTERSECT
      float[] positive_intersect = seg_seg_intersect(walls[0][0], walls[0][1], prev.walls[0][0], prev.walls[0][1]);
      float[] negative_intersect = seg_seg_intersect(walls[1][0], walls[1][1], prev.walls[1][0], prev.walls[1][1]);
      if (positive_intersect != null) {
        walls[0][0] = positive_intersect;
        prev.walls[0][1] = positive_intersect;
      }
      else if (negative_intersect != null) {
        walls[1][0] = negative_intersect;
        prev.walls[1][1] = negative_intersect;
      }
      if (!(walls[0][0][0] == prev.walls[0][1][0] && walls[0][0][1] == prev.walls[0][1][1]) && !(walls[1][0][0] == prev.walls[1][1][0] && walls[1][0][1] == prev.walls[1][1][1])) {
        invalid = true;
      }
    }

    if (next != null) {//SHORTEN WALLS IF CURRENT/NEXT INTERSECT
      float[] positive_intersect = seg_seg_intersect(walls[0][0], walls[0][1], next.walls[0][0], next.walls[0][1]);
      float[] negative_intersect = seg_seg_intersect(walls[1][0], walls[1][1], next.walls[1][0], next.walls[1][1]);
      if (positive_intersect != null) {
        walls[0][1] = positive_intersect;
        next.walls[0][0] = positive_intersect;
      }
      else if (negative_intersect != null) {
        walls[1][1] = negative_intersect;
        next.walls[1][0] = negative_intersect;
      }
      if (!(walls[0][1][0] == next.walls[0][0][0] && walls[0][1][1] == next.walls[0][0][1]) && !(walls[1][1][0] == next.walls[1][0][0] && walls[1][1][1] == next.walls[1][0][1])) {
        invalid = true;
      }
    }
  }

  void generate_edges() {
    float[] direction = {x2-x1, y2-y1};                                                                  //DIRECTION OF SEGMENT
    float scalar = (diameter*0.5-thickness*0.5) / sqrt(pow(direction[0], 2) + pow(direction[1], 2));     //NORMALISE AND THEN SCALE TO DIAMETER - THICKNESS
    float[] shift = {direction[1]*scalar, -direction[0]*scalar};                                         //SHIFT EACH EDGE PERPENDICULAR TO SEGMENT
    float[][] positive = new float[][] {new float[] {x1+shift[0], y1+shift[1]}, new float[] {x2+shift[0], y2+shift[1]}};
    float[][] negative = new float[][] {new float[] {x1-shift[0], y1-shift[1]}, new float[] {x2-shift[0], y2-shift[1]}};
    edges = new float[][][] {positive, negative};

    if (prev != null) {//SHORTEN EDGES IF CURRENT/PREV INTERSECT
      float[] positive_intersect = seg_seg_intersect(edges[0][0], edges[0][1], prev.edges[0][0], prev.edges[0][1]);
      float[] negative_intersect = seg_seg_intersect(edges[1][0], edges[1][1], prev.edges[1][0], prev.edges[1][1]);
      if (positive_intersect != null) {
        edges[0][0] = positive_intersect;
        prev.edges[0][1] = positive_intersect;
      }
      else if (negative_intersect != null) {
        edges[1][0] = negative_intersect;
        prev.edges[1][1] = negative_intersect;
      }
    }

    if (next != null) {//SHORTEN EDGES IF CURRENT/NEXT INTERSECT
      float[] positive_intersect = seg_seg_intersect(edges[0][0], edges[0][1], next.edges[0][0], next.edges[0][1]);
      float[] negative_intersect = seg_seg_intersect(edges[1][0], edges[1][1], next.edges[1][0], next.edges[1][1]);
      if (positive_intersect != null) {
        edges[0][1] = positive_intersect;
        next.edges[0][0] = positive_intersect;
      }
      else if (negative_intersect != null) {
        edges[1][1] = negative_intersect;
        next.edges[1][0] = negative_intersect;
      }
    }
  }

  float distance() {
    return sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
  }

  float distance(float[] pos) {
    float scalar = point_line_relative_distance(pos, new float[] {x1, y1}, new float[] {x2, y2});
    return scalar * distance();
  }
  
  float[] get_intersect(Ray ray) {
    float[] intersect_a = seg_seg_intersect(ray.position(), new float[] {ray.master.x, ray.master.y}, walls[0][0], walls[0][1]);
    float[] intersect_b = seg_seg_intersect(ray.position(), new float[] {ray.master.x, ray.master.y}, walls[1][0], walls[1][1]);    
    if (intersect_a == null && intersect_b == null) {
      return null;
    }
    else if (intersect_a == null) {
      return intersect_b;
    }
    else if (intersect_b == null) {
      return intersect_a;
    }
    float distance_a = pow(intersect_a[0]-ray.master.x, 2)+pow(intersect_a[1]-ray.master.y, 2);
    float distance_b = pow(intersect_b[0]-ray.master.x, 2)+pow(intersect_b[1]-ray.master.y, 2);
    if (distance_a < distance_b) {
      return intersect_a;
    }
    return intersect_b;
  }
  
  Boolean within_range(Car car) {
    float distance_a = pow(walls[0][0][0]-car.x, 2) + pow(walls[0][0][1]-car.y, 2);
    float distance_b = pow(walls[0][1][0]-car.x, 2) + pow(walls[0][1][1]-car.y, 2);
    float distance_c = pow(walls[1][0][0]-car.x, 2) + pow(walls[1][0][1]-car.y, 2);
    float distance_d = pow(walls[1][1][0]-car.x, 2) + pow(walls[1][1][1]-car.y, 2);
    float[] intersect_a = seg_circ_intersect(walls[0][0], walls[0][1], new float[] {car.x, car.y}, car.view_depth);
    float[] intersect_b = seg_circ_intersect(walls[1][0], walls[1][1], new float[] {car.x, car.y}, car.view_depth);
    float[] distances = {distance_a, distance_b, distance_c, distance_d};

    if (sqrt(min(distances)) > car.view_depth && intersect_a == null && intersect_b == null) {
      return false;
    }
    return true;
  }
  
  Boolean intersects(Segment other) {
    float[] intersect_a = seg_seg_intersect(other.walls[0][0], other.walls[0][1], walls[0][0], walls[0][1]);
    float[] intersect_b = seg_seg_intersect(other.walls[0][0], other.walls[0][1], walls[1][0], walls[1][1]);
    float[] intersect_c = seg_seg_intersect(other.walls[1][0], other.walls[1][1], walls[0][0], walls[0][1]);
    float[] intersect_d = seg_seg_intersect(other.walls[1][0], other.walls[1][1], walls[1][0], walls[1][1]);
    if (intersect_a == null && intersect_b == null && intersect_c == null && intersect_d == null) {
      return false;
    }
    return true;
  }

  Boolean intersects(Corner corner) {
    float[] intersect_a = seg_arc_intersect(walls[0][0], walls[0][1], corner.center, corner.wall_radius, corner.start, corner.end);
    float[] intersect_b = seg_arc_intersect(walls[1][0], walls[1][1], corner.center, corner.wall_radius, corner.start, corner.end);
    if (intersect_a == null && intersect_b == null) {
      return false;
    }
    return true;
  }

  Boolean intersects(Car car) {
    float[] intersect_a = seg_circ_intersect(edges[0][0], edges[0][1], new float[] {car.x, car.y}, car.size);
    float[] intersect_b = seg_circ_intersect(edges[1][0], edges[1][1], new float[] {car.x, car.y}, car.size);
    if (intersect_a != null || intersect_b != null) {return true;}
    intersect_a = seg_seg_intersect(edges[0][0], edges[0][1], new float[] {car.prev_x, car.prev_y}, new float[] {car.x, car.y});
    intersect_b = seg_seg_intersect(edges[1][0], edges[1][1], new float[] {car.prev_x, car.prev_y}, new float[] {car.x, car.y});
    if (intersect_a != null || intersect_b != null) {return true;}
    return false;
  }
}



class Corner {
  float start, end, wall_radius, edge_radius, thickness;
  float[] center;

  Corner(float[] c, float r, float t) {
    center = c;
    thickness = t;
    wall_radius = r;
    edge_radius = wall_radius - thickness*0.5;
    start = 0;
    end = TWO_PI;
  }

  Corner(Segment segment, Boolean at_beginning) {
    thickness = segment.thickness;
    wall_radius = segment.diameter*0.5;
    edge_radius = wall_radius - thickness*0.5;
    float x1, y1, x2, y2;
    if (at_beginning) {
      center = new float[] {(segment.walls[0][0][0]+segment.walls[1][0][0])*0.5, (segment.walls[0][0][1]+segment.walls[1][0][1])*0.5};
      x1 = segment.walls[1][0][0] - center[0];
      y1 = segment.walls[1][0][1] - center[1];
      x2 = segment.walls[0][0][0] - center[0];
      y2 = segment.walls[0][0][1] - center[1];
    }
    else {
      center = new float[] {(segment.walls[0][1][0]+segment.walls[1][1][0])*0.5, (segment.walls[0][1][1]+segment.walls[1][1][1])*0.5};
      x1 = segment.walls[0][1][0] - center[0];
      y1 = segment.walls[0][1][1] - center[1];
      x2 = segment.walls[1][1][0] - center[0];
      y2 = segment.walls[1][1][1] - center[1];
    }
    start = normalise_angle(atan2(y1, x1));
    end = normalise_angle(atan2(y2, x2));
    if (start > end) {end += TWO_PI;}
  }

  Corner(Segment a, Segment b, float[] c) {
    thickness = a.thickness;
    wall_radius = a.diameter*0.5;
    edge_radius = wall_radius - thickness*0.5;
    center = c;
    if (seg_seg_intersect(a.walls[0][0], a.walls[0][1], b.walls[0][0], b.walls[0][1]) != null) {      
      float x1 = b.walls[1][0][0] - center[0];
      float y1 = b.walls[1][0][1] - center[1];
      float x2 = a.walls[1][1][0] - center[0];
      float y2 = a.walls[1][1][1] - center[1];
      start = normalise_angle(atan2(y1, x1));
      end = normalise_angle(atan2(y2, x2));
    }
    else if (seg_seg_intersect(a.walls[1][0], a.walls[1][1], b.walls[1][0], b.walls[1][1]) != null) {
      float x1 = b.walls[0][0][0] - center[0];
      float y1 = b.walls[0][0][1] - center[1];
      float x2 = a.walls[0][1][0] - center[0];
      float y2 = a.walls[0][1][1] - center[1];
      end = normalise_angle(atan2(y1, x1));
      start = normalise_angle(atan2(y2, x2));
    }
    else {
      start = 0;
      end = 0;
    }
    if (start > end) {end += TWO_PI;}
  }
  
  void display() {
    noFill();
    stroke(WALL_COL);
    strokeWeight(thickness);
    arc(center[0], center[1], wall_radius, wall_radius, start, end);
  }

  void display(color col) {
    noFill();
    stroke(col);
    strokeWeight(thickness);
    arc(center[0], center[1], wall_radius, wall_radius, start, end);
  }
  
  float[] get_intersect(Ray ray) {
    float[] intersect = seg_arc_intersect(ray.position(), new float[] {ray.master.x, ray.master.y}, center, edge_radius, start, end);
    return intersect;
  }
  
  Boolean within_range(Car car) {
    if (sqrt(pow(center[0] - car.x, 2) + pow(center[1] - car.y, 2)) - wall_radius > car.view_depth) {
      return false;
    }
    return true;
  }
      
  Boolean intersects(Segment segment) {
    float[] intersect_a = seg_arc_intersect(segment.walls[0][0], segment.walls[0][1], center, wall_radius, start, end);
    float[] intersect_b = seg_arc_intersect(segment.walls[1][0], segment.walls[1][1], center, wall_radius, start, end);
    if (intersect_a == null && intersect_b == null) {
      return false;
    }
    return true;
  }
  
  Boolean intersects(Corner other) {
    float[] intersect_pair = arc_arc_intersects(center, wall_radius, start, end, other.center, other.wall_radius, other.start, other.end);
    if (intersect_pair == null) {
      return false;
    }
    return true;
  }
  
  Boolean intersects(Car car) {
    float[] intersect = arc_circ_intersects(center, edge_radius, start, end, new float[] {car.x, car.y}, car.size);
    if (intersect != null) {return true;}
    intersect = seg_arc_intersect(new float[] {car.prev_x, car.prev_y}, new float[] {car.x, car.y}, center, edge_radius, start, end);
    if (intersect != null) {return true;}
    return false;
  }
}



class Checkpoint {
  float x, y, x1, y1, x2, y2;
  
  Checkpoint(Segment a, Segment b, float[] center) {
    if (a.walls[0][1][0] == b.walls[0][0][0] && a.walls[0][1][1] == b.walls[0][0][1]) {      
      x1 = a.walls[0][1][0];
      y1 = a.walls[0][1][1];
    }
    else {
      x1 = a.walls[1][1][0];
      y1 = a.walls[1][1][1];
    }
    float angle = atan2(y1-center[1], x1-center[0]);
    x2 = center[0] - a.diameter*0.5*cos(angle);
    y2 = center[1] - a.diameter*0.5*sin(angle);
    x = 0.5 * (x1 + x2);
    y = 0.5 * (y1 + y2);
  }

  void display() {
    line(x1, y1, x2, y2);
  }
  
  Boolean met(Car car) {
    float[] intersect = seg_circ_intersect(new float[] {x1, y1}, new float[] {x2, y2}, new float[] {car.x, car.y}, car.size);
    if (intersect != null) {return true;}
    intersect = seg_seg_intersect(new float[] {x1, y1}, new float[] {x2, y2}, new float[] {car.prev_x, car.prev_y}, new float[] {car.x, car.y});
    if (intersect != null) {return true;}
    return false;
  }
}