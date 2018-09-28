class Matrix {
  float[][] array;
  int rows, columns;

  Matrix(Matrix copy) {
    array = new float[copy.rows][copy.columns];
    rows = array.length;
    columns = array[0].length;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        array[r][c] = copy.array[r][c];
      }
    }
  }

  Matrix(float[][] a) {
    array = a;
    rows = array.length;
    columns = array[0].length;
  }

  Matrix(int r, int c) {
    rows = r;
    columns = c;
    array = new float[rows][columns];
  }

  void set_value(int r, int c, float v) {
    array[r][c] = v;
  }

  void set_row(int r, float[] items) {
    array[r] = items;
  }

  void set_column(int c, float[] items) {
    for (int r = 0; r < rows; r++) {
      array[r][c] = items[r];
    }
  }
  
  float value(int r, int c) {
    return array[r][c];
  }
  
  float[] row(int r) {
    return array[r];
  }

  float[] column(int c) {
    float[] col = new float[rows];
    for (int r = 0; r < rows; r++) {
      col[r] = array[r][c];
    }
    return col;
  }
    
  Matrix duplicate() {
    return new Matrix(this);
  }
}



Matrix matrix_product(Matrix a, Matrix b) {
  Matrix product = new Matrix(a.rows, b.columns);
  for (int r = 0; r < product.rows; r++) {
    for (int c = 0; c < product.columns; c++) {
      product.set_value(r, c, dot_product(a.row(r), b.column(c)));
    }
  }
  return product;
}



float dot_product(float[] a, float[] b) {//DOT PRODUCT OF TWO VECTORS
  float sum = 0;
  for (int i = 0; i < a.length; i++) {
    sum += a[i] * b[i];
  }
  return sum;
}


float tanh(float x) {//MAPS X BETWEEN -1 and 1
  if (x > 10) {return 1;}//AVOIDS INFINITY/NAN WITH EXP
  if (x < -10) {return -1;}
  return (exp(x) - exp(-x)) / (exp(x) + exp(-x));
}



float sigmoid(float x) {//MAPS X BETWEEN 0 AND 1
  return exp(x) / (exp(x) + 1);
}



float point_line_relative_distance(float[] a1, float[] b1, float[] b2) {
  float[] p = {b2[1]-b1[1], b1[0]-b2[0]};                                                              //DIRECTION OF PERPENDICULAR
  float[] intersect = line_line_intersect(a1, new float[] {a1[0]+p[0], a1[1]+p[1]}, b1, b2);
  if (intersect == null) {intersect = a1;}
  return (intersect[0] - b1[0]) / (b2[0] - b1[0]);
}



float[] line_line_intersect(float[] a1, float[] a2, float[] b1, float[] b2) {//A LINE BETWEEN A1/A2 AND B SEGMENT BETWEEN B1/B2
  float determinant = (a2[0]-a1[0])*(b1[1]-b2[1]) - (b1[0]-b2[0])*(a2[1]-a1[1]);
  if (determinant != 0) {                                                  //LINES INTERSECT
    float a_scalar = ((b1[1]-b2[1])*(b1[0]-a1[0]) + (b2[0]-b1[0])*(b1[1]-a1[1])) / determinant;
    return new float[] {a1[0] + a_scalar*(a2[0]-a1[0]), a1[1] + a_scalar*(a2[1]-a1[1])};
  }
  return null;
}



float[] seg_seg_intersect(float[] a1, float[] a2, float[] b1, float[] b2) {//A SEGMENT BETWEEN A1/A2 AND B SEGMENT BETWEEN B1/B2
  float determinant = (a2[0]-a1[0])*(b1[1]-b2[1]) - (b1[0]-b2[0])*(a2[1]-a1[1]);
  if (determinant != 0) {                                                  //LINES INTERSECT
    float a_scalar = ((b1[1]-b2[1])*(b1[0]-a1[0]) + (b2[0]-b1[0])*(b1[1]-a1[1])) / determinant;
    float b_scalar = ((a1[1]-a2[1])*(b1[0]-a1[0]) + (a2[0]-a1[0])*(b1[1]-a1[1])) / determinant;
    if (a_scalar >= 0 && a_scalar <= 1 && b_scalar >= 0 && b_scalar <= 1) {//LINES INTERSECT WITHIN SEGMENT
      return new float[] {a1[0] + a_scalar*(a2[0]-a1[0]), a1[1] + a_scalar*(a2[1]-a1[1])};
    }
  }
  return null;
}



float[] seg_circ_intersect(float[] a1, float[] a2, float[] center, float radius) {//A SEGMENT BETWEEN A1/A2
  float a = pow(a2[0]-a1[0], 2) + pow(a2[1]-a1[1], 2);//QUADRATIC FORUMULA TO FIND SCALAR
  float b = 2*(a1[0]-center[0])*(a2[0]-a1[0]) + 2*(a1[1]-center[1])*(a2[1]-a1[1]);
  float c = pow(a1[0]-center[0], 2) + pow(a1[1]-center[1], 2) - pow(radius, 2);
  float discriminant = pow(b, 2) - 4*a*c;
  if (discriminant >= 0) {
    float scalar_one = (-b + sqrt(discriminant)) / (2*a);//QUADRATIC SO TWO SLNS
    float scalar_two = (-b - sqrt(discriminant)) / (2*a);
    float[] intersect_one = {a1[0] + scalar_one*(a2[0]-a1[0]), a1[1] + scalar_one*(a2[1]-a1[1])};
    float[] intersect_two = {a1[0] + scalar_two*(a2[0]-a1[0]), a1[1] + scalar_two*(a2[1]-a1[1])};
    Boolean valid_one = false;
    Boolean valid_two = false;
    if (scalar_one >= 0 && scalar_one <= 1) {valid_one = true;}
    if (scalar_two >= 0 && scalar_two <= 1) {valid_two = true;}
    if (valid_one && valid_two) {
      if (scalar_one < scalar_two) {return intersect_one;}
      else {return intersect_two;}
    }
    if (valid_one) {return intersect_one;}
    if (valid_two) {return intersect_two;}
  }
  return null;
}



float[] seg_arc_intersect(float[] a1, float[] a2, float[] center, float radius, float start, float end) {//A SEGMENT BETWEEN A1/A2
  float a = pow(a2[0]-a1[0], 2) + pow(a2[1]-a1[1], 2);//QUADRATIC FORUMULA TO FIND SCALAR
  float b = 2*(a1[0]-center[0])*(a2[0]-a1[0]) + 2*(a1[1]-center[1])*(a2[1]-a1[1]);
  float c = pow(a1[0]-center[0], 2) + pow(a1[1]-center[1], 2) - pow(radius, 2);
  float discriminant = pow(b, 2) - 4*a*c;
  if (discriminant >= 0) {
    float scalar_one = (-b + sqrt(discriminant)) / (2*a);//QUADRATIC SO TWO SLNS
    float scalar_two = (-b - sqrt(discriminant)) / (2*a);
    float[] intersect_one = {a1[0] + scalar_one*(a2[0]-a1[0]), a1[1] + scalar_one*(a2[1]-a1[1])};
    float[] intersect_two = {a1[0] + scalar_two*(a2[0]-a1[0]), a1[1] + scalar_two*(a2[1]-a1[1])};
    float angle_one = normalise_angle(atan2(intersect_one[1]-center[1], intersect_one[0]-center[0]));
    float angle_two = normalise_angle(atan2(intersect_two[1]-center[1], intersect_two[0]-center[0]));
    while (angle_one < start) {angle_one += TWO_PI;}
    while (angle_two < start) {angle_two += TWO_PI;}
    while (angle_one > end) {angle_one -= TWO_PI;}
    while (angle_two > end) {angle_two -= TWO_PI;}
    Boolean valid_one = false;
    Boolean valid_two = false;
    if (scalar_one >= 0 && scalar_one <= 1 && start <= angle_one && end >= angle_one) {valid_one = true;}
    if (scalar_two >= 0 && scalar_two <= 1 && start <= angle_two && end >= angle_two) {valid_two = true;}
    if (valid_one && valid_two) {
      if (scalar_one < scalar_two) {return intersect_one;}
      else {return intersect_two;}
    }
    if (valid_one) {return intersect_one;}
    if (valid_two) {return intersect_two;}
  }
  return null;
}



float[] circ_circ_intersects(float[] center_a, float radius_a, float[] center_b, float radius_b) {//A CIRCLE AND B CIRCLE
  float d = sqrt(pow(center_a[0]-center_b[0], 2) + pow(center_a[1]-center_b[1], 2));
  if (d < radius_a + radius_b && d > abs(radius_a - radius_b) && d > 0) {
    float a = (pow(radius_a,2) - pow(radius_b,2) + pow(d,2)) / (2*d);
    float h = sqrt(pow(radius_a,2) - pow(a,2));
    float mid_x = center_a[0] + a*(center_b[0]-center_a[0])/d;
    float mid_y = center_a[1] + a*(center_b[1]-center_a[1])/d;
    float[] intersect_one = {mid_x + h*(center_b[1]-center_a[1])/d, mid_y - h*(center_b[0]-center_a[0])/d};
    float[] intersect_two = {mid_x - h*(center_b[1]-center_a[1])/d, mid_y + h*(center_b[0]-center_a[0])/d};
    return new float[] {intersect_one[0], intersect_one[1], intersect_two[0], intersect_two[1]};
  }
  return null;
}


float[] arc_circ_intersects(float[] center_a, float radius_a, float start_a, float end_a, float[] center_b, float radius_b) {
  float[] intersects = circ_circ_intersects(center_a, radius_a, center_b, radius_b);
  if (intersects != null) {
    float[] intersect_one = {intersects[0], intersects[1]};
    float[] intersect_two = {intersects[2], intersects[3]};
    float angle_one = normalise_angle(atan2(intersect_one[1]-center_a[1], intersect_one[0]-center_a[0]));
    float angle_two = normalise_angle(atan2(intersect_two[1]-center_a[1], intersect_two[0]-center_a[0]));
    while (angle_one < start_a) {angle_one += TWO_PI;}
    while (angle_two < start_a) {angle_two += TWO_PI;}
    while (angle_one > end_a) {angle_one -= TWO_PI;}
    while (angle_two > end_a) {angle_two -= TWO_PI;}
    Boolean valid_one = false;
    Boolean valid_two = false;
    if (start_a <= angle_one && end_a >= angle_one) {valid_one = true;}
    if (start_a <= angle_two && end_a >= angle_two) {valid_two = true;}
    if (valid_one && valid_two) {
      return new float[] {intersect_one[0], intersect_one[1], intersect_two[0], intersect_two[1]};
    }
    if (valid_one) {return intersect_one;}
    if (valid_two) {return intersect_two;}
  }
  return null;
}


float[] arc_arc_intersects(float[] center_a, float radius_a, float start_a, float end_a, float[] center_b, float radius_b, float start_b, float end_b) {
  float[] intersects = circ_circ_intersects(center_a, radius_a, center_b, radius_b);
  if (intersects != null) {
    float[] intersect_one = {intersects[0], intersects[1]};
    float[] intersect_two = {intersects[2], intersects[3]};
    float angle_a_one = normalise_angle(atan2(intersect_one[1]-center_a[1], intersect_one[0]-center_a[0]));
    float angle_a_two = normalise_angle(atan2(intersect_two[1]-center_a[1], intersect_two[0]-center_a[0]));
    float angle_b_one = normalise_angle(atan2(intersect_one[1]-center_b[1], intersect_one[0]-center_b[0]));
    float angle_b_two = normalise_angle(atan2(intersect_two[1]-center_b[1], intersect_two[0]-center_b[0]));
    while (angle_a_one < start_a) {angle_a_one += TWO_PI;}
    while (angle_a_two < start_a) {angle_a_two += TWO_PI;}
    while (angle_b_one < start_b) {angle_b_one += TWO_PI;}
    while (angle_b_two < start_b) {angle_b_two += TWO_PI;}
    while (angle_a_one > end_a) {angle_a_one -= TWO_PI;}
    while (angle_a_two > end_a) {angle_a_two -= TWO_PI;}
    while (angle_b_one > end_b) {angle_b_one -= TWO_PI;}
    while (angle_b_two > end_b) {angle_b_two -= TWO_PI;}
    Boolean valid_one = false;
    Boolean valid_two = false;
    if (start_a <= angle_a_one && end_a >= angle_a_one && start_b <= angle_b_one && end_b >= angle_b_one) {valid_one = true;}
    if (start_a <= angle_a_two && end_a >= angle_a_two && start_b <= angle_b_two && end_b >= angle_b_two) {valid_two = true;}
    if (valid_one && valid_two) {
      return new float[] {intersect_one[0], intersect_one[1], intersect_two[0], intersect_two[1]};
    }
    if (valid_one) {return intersect_one;}
    if (valid_two) {return intersect_two;}
  }
  return null;
}



float normalise_angle(float angle) {
  while (angle < 0) {angle += TWO_PI;}
  while (angle > TWO_PI) {angle -= TWO_PI;}
  return angle;
}