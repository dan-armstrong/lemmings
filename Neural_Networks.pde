class Network {
  Matrix[] neurons;
  Matrix[] weights;
  Matrix[] biases;
  
  Network(String name) {
    String[] records = loadStrings(name + ".csv");
    String[] neuron_data = split(records[0], ",");
    neurons = new Matrix[neuron_data.length];
    for (int layer = 0; layer < neurons.length; layer++) {
      neurons[layer] = new Matrix(int(neuron_data[layer]), 1);
    }
    String[] biases_data = split(records[1], ",");
    int record_count = 2;
    biases = new Matrix[biases_data.length];
    for (int layer = 0; layer < biases.length; layer++) {
      biases[layer] = new Matrix(int(biases_data[layer]), 1);
      String[] record_data = split(records[record_count], ",");
      for (int row = 0; row < biases[layer].rows; row++) {
        biases[layer].set_value(row, 0, float(record_data[row]));
      }
      record_count += 1;
    } 
    String[] weights_data = split(records[record_count], ",");
    record_count += 1;
    weights = new Matrix[weights_data.length/2];
    for (int layer = 0; layer < weights.length; layer++) {
      weights[layer] = new Matrix(int(weights_data[layer*2]), int(weights_data[layer*2+1]));
      for (int row = 0; row < weights[layer].rows; row++) {
        String[] record_data = split(records[record_count], ",");
        for (int column = 0; column < weights[layer].columns; column++) {
          weights[layer].set_value(row, column, float(record_data[column]));
        }
        record_count += 1;
      }
    } 
  }
  
  Network(int[] dimensions){
    neurons = new Matrix[dimensions.length];
    for (int i = 0; i < neurons.length; i++) {
      neurons[i] = new Matrix(dimensions[i], 1);
    }
   
    weights = new Matrix[dimensions.length-1];
    for (int i = 0; i < weights.length; i++) {
      weights[i] = new Matrix(dimensions[i+1], dimensions[i]);
    }
    
    biases = new Matrix[dimensions.length-1];
    for (int i = 0; i < biases.length; i++) {
      biases[i] = new Matrix(dimensions[i+1], 1);
    }
  }

  Network(Network prev) {
    neurons = new Matrix[prev.neurons.length];
    weights = new Matrix[prev.weights.length];
    biases = new Matrix[prev.biases.length];
    for (int i = 0; i < neurons.length; i++) {
      neurons[i] = new Matrix(prev.neurons[i]);
    }
    for (int i = 0; i < weights.length; i++) {
      weights[i] = new Matrix(prev.weights[i]);
    }
    for (int i = 0; i < biases.length; i++) {
      biases[i] = new Matrix(prev.biases[i]);
    }
  }
  
  Network(Network prev, float mutate_percent, float weight_range, float bias_range) {
    neurons = new Matrix[prev.neurons.length];
    weights = new Matrix[prev.weights.length];
    biases = new Matrix[prev.biases.length];
    for (int i = 0; i < neurons.length; i++) {
      neurons[i] = new Matrix(prev.neurons[i]);
    }
    for (int i = 0; i < weights.length; i++) {
      weights[i] = new Matrix(prev.weights[i]);
    }
    for (int i = 0; i < biases.length; i++) {
      biases[i] = new Matrix(prev.biases[i]);
    }
    for (Matrix matrix : weights) {
      for (int r = 0; r < matrix.rows; r++) {
        for (int c = 0; c < matrix.columns; c++) {
          if (random(1) < mutate_percent){
            matrix.set_value(r, c, matrix.value(r, c) + randomGaussian() * weight_range);
          }
        }
      }
    }
    for (Matrix matrix : biases) {
      for (int r = 0; r < matrix.rows; r++) {
        if (random(1) < mutate_percent){
          matrix.set_value(r, 0, matrix.value(r, 0) + randomGaussian() * bias_range);
        }
      }
    }
  }
    
  Network(Network a, Network b) {
    neurons = new Matrix[a.neurons.length];
    weights = new Matrix[a.weights.length];
    biases = new Matrix[a.biases.length];
    for (int i = 0; i < neurons.length; i++) {
      neurons[i] = new Matrix(a.neurons[i]);
    }
    for (int i = 0; i < weights.length; i++) {
      weights[i] = new Matrix(a.weights[i]);
    }
    for (int i = 0; i < biases.length; i++) {
      biases[i] = new Matrix(a.biases[i]);
    }
    for (int layer = 0; layer < weights.length; layer++) {
      for (int r = 0; r < weights[layer].rows; r++) {
        for (int c = 0; c < weights[layer].columns; c++) {
          if (random(1) > 0.5) {weights[layer].set_value(r, c, b.weights[layer].value(r, c));}
        }
      }
    }
    for (int layer = 0; layer < biases.length; layer++) {
      for (int r = 0; r < biases[layer].rows; r++) {
        if (random(1) > 0.5) {biases[layer].set_value(r, 0, b.biases[layer].value(r, 0));}
      }
    }
  }

  void set_weights(int layer, Matrix values) {
    weights[layer] = values;
  }
  
  void random_weights(float range) {
    for (Matrix matrix : weights) {
      for (int r = 0; r < matrix.rows; r++) {
        for (int c = 0; c < matrix.columns; c++) {
          matrix.set_value(r, c, randomGaussian() * range);
        }
      }
    }
  }

  void random_biases(float range) {
    for (Matrix matrix : biases) {
      for (int r = 0; r < matrix.rows; r++) {
        matrix.set_value(r, 0, randomGaussian() * range);
      }
    }
  }
  
  Matrix output(float[] input) {
    for (int i = 0; i < input.length; i++) {
      neurons[0].set_value(i, 0, input[i]);
    }
    return output(neurons.length-1);
  }
   
  Matrix output(int layer) {//RECURSE BACK THROUGH LAYERS
    if (layer == 0) {
      return neurons[0];
    }
    Matrix product = matrix_product(weights[layer-1], output(layer-1));//FIND WEIGHTS X NODES IN PREVIOUS LAYER
    Matrix biased = new Matrix(product.rows, 1);  //ADD BIASES
    for (int r = 0; r < biased.rows; r++) {
      biased.set_value(r, 0, product.value(r, 0) + biases[layer-1].value(r, 0));
    }
    Matrix activated = new Matrix(biased.rows, 1);//ACTIVATE BETWEEN -1 AND 1
    for (int r = 0; r < biased.rows; r++) {
      activated.set_value(r, 0, tanh(biased.value(r, 0)));
    }
    neurons[layer] = activated;
    return neurons[layer];
  }
  
  void display() {
    noFill();
    strokeWeight(2);
    int[] dims = {400, 400};
    int[] pos = {0, 0};
    float neuron_size = 5;
    float layer_width = dims[0] / neurons.length;
    for (int layer = 0; layer < neurons.length; layer++) {
      float neuron_height = dims[1] / neurons[layer].rows;
      for (int neuron = 0; neuron < neurons[layer].rows; neuron++) {
        float value = neurons[layer].value(neuron, 0);
        stroke(255*max(-value, 0), 255*max(value, 0), 0);
        ellipse(pos[0] + layer_width*(layer+0.5), pos[0] + neuron_height*(neuron+0.5), neuron_size, neuron_size);
      }
    }
  }

  void store(String file_name) {
    PrintWriter file = createWriter(file_name + ".csv");
    for (int layer = 0; layer < neurons.length; layer++) {
      if (layer > 0) {file.print(',');}
      file.print(neurons[layer].rows);
    }
    file.print('\n');
    for (int layer = 0; layer < biases.length; layer++) {
      if (layer > 0) {file.print(',');}
      file.print(biases[layer].rows);
    }
    for (Matrix matrix : biases) {
      file.print('\n');
      for (int row = 0; row < matrix.rows; row++) {
        if (row > 0) {file.print(',');}
        file.print(matrix.value(row, 0));
      }
    }
    file.print('\n');
    for (int layer = 0; layer < weights.length; layer++) {
      if (layer > 0) {file.print(',');}
      file.print(str(weights[layer].rows) + ',' + str(weights[layer].columns));
    }
    for (Matrix matrix : weights) {
      file.print('\n');
      for (int row = 0; row < matrix.rows; row++) {
        if (row > 0) {file.print('\n');}
        for (int column = 0; column < matrix.columns; column++) {
          if (column > 0) {file.print(',');}
          file.print(matrix.value(row, column));
        }
      }
    }
    file.flush();
    file.close();
  }
}



class Bot {
  Network brain;
  Car machine;
  float score = 0;
  float speed_weight = 50;
  float distance_weight = 0.001;
  float completed_weight;

  Bot(int inputs, int[] hidden_dimensions, Track track, color col) {
    int[] dimensions = concat(concat(new int[] {inputs+3}, hidden_dimensions), new int[] {2});
    brain = new Network(dimensions);
    brain.random_weights(10);
    brain.random_biases(10);
    machine = new Car(4, TWO_PI, 150, inputs, track, col);
  }

  Bot(String name, Track track, color col) {
    brain = new Network(name);
    machine = new Car(4, TWO_PI, 150, brain.neurons[0].rows-3, track, col);
  }

  Bot(Bot prev, Track track) {
    brain = new Network(prev.brain);
    machine = new Car(prev.machine, track);
  }
  
  Bot(Bot prev, float mutate_percent, float weight_range, float bias_range, Track track) {
    brain = new Network(prev.brain, mutate_percent, weight_range, bias_range);
    machine = new Car(prev.machine, track);
  }
  
  Bot(Bot a, Bot b, Track track) {
    brain = new Network(a.brain, b.brain);
    machine = new Car(a.machine, track);
  }
  
  void step() {
    float[] inputs = new float[machine.rays.length+3];
    float[] relative_checkpoint = {machine.track.checkpoints.get(machine.checkpoint).x - machine.x, machine.track.checkpoints.get(machine.checkpoint).y - machine.y};
    inputs[0] = machine.speed / machine.max_speed;
    inputs[0] = normalise_angle(machine.direction - atan2(relative_checkpoint[1], relative_checkpoint[0])) / PI - 1;
    inputs[2] = min(sqrt(pow(relative_checkpoint[0], 2) + pow(relative_checkpoint[1], 2)), machine.view_depth) / machine.view_depth;
    float[] distances = machine.get_ray_distances();
    for (int i = 0; i < distances.length; i++) {
      inputs[i+3] = 2 * distances[i] / machine.view_depth - 1;
    }
    
    Matrix outputs = brain.output(inputs);
    float acceleration = outputs.value(0,0);
    float steering = outputs.value(1,0);
    machine.drive(acceleration, steering);
  }
  
  void generate_score() {
    completed_weight = machine.track.segments.size() * distance_weight;
    if (machine.completed) {
      score += completed_weight + machine.speed() * speed_weight;
    }
    else {
      score += machine.distance() * distance_weight;
    }
  }
  
  void reset(Track track) {
    boolean best = machine.best;
    machine = new Car(machine, track);
    machine.best = best;
  }
}



class Generation {
  Bot[] bots;
  int alive;
  
  Generation(int n, int inputs, int[] hidden_dimensions, Track track, color col) {
    bots = new Bot[n];
    alive = n;
    for (int i = 0; i < bots.length; i++) {
      bots[i] = new Bot(inputs, hidden_dimensions, track, col);
    }
  }

  Generation(Generation old_generation, float perfect_percent, float range, Track track) {
    bots = new Bot[old_generation.bots.length];
    alive = bots.length;
    int perfect_amount = min(round(bots.length * perfect_percent), bots.length);
    Bot[] sorted = sort_bots(old_generation.bots);

    float total_score = 0;
    for (Bot bot : sorted) {total_score += bot.score;}
    
    for (int i = 0; i < perfect_amount; i++) {
      bots[i] = new Bot(sorted[i], track);
      bots[i].machine.best = true;
    }

    for (int i = perfect_amount; i < bots.length; i++) {
      Bot random_bot = random_bot(sorted, total_score);
      float relative_range = range * pow((i-perfect_amount) / float(bots.length-perfect_amount), 2);
      bots[i] = new Bot(random_bot, 1, relative_range, relative_range, track);
    }
  }


  Generation(Generation old_generation, float perfect_percent, float best_percent, float mutate_percent, Track track) {
    bots = new Bot[old_generation.bots.length];
    alive = bots.length;
    int perfect_amount = min(round(bots.length * perfect_percent), bots.length);
    int best_amount = min(round(bots.length * best_percent), bots.length);
    int mutate_amount = min(round(bots.length * mutate_percent), bots.length-perfect_amount-best_amount);
    Bot[] sorted = sort_bots(old_generation.bots);

    float total_score = 0;
    for (Bot bot : sorted) {total_score += bot.score;}
    
    for (int i = 0; i < perfect_amount; i++) {
      bots[i] = new Bot(sorted[i], track);
      bots[i].machine.best = true;
    }

    for (int i = perfect_amount; i < perfect_amount+best_amount; i++) {
      int random_index = floor(random(perfect_amount));
      bots[i] = new Bot(sorted[random_index], 0.8, 1, 1, track);
    }

    for (int i = perfect_amount+best_amount; i < perfect_amount+best_amount+mutate_amount; i++) {
      Bot random_bot = random_bot(sorted, total_score);
      bots[i] = new Bot(random_bot, 1, 4, 4, track);
    }

    for (int i = perfect_amount+best_amount+mutate_amount; i < bots.length; i++) {//RANDOM FOR REST
      Bot random_bot_a = random_bot(sorted, total_score);
      Bot random_bot_b = random_bot(sorted, total_score);
      bots[i] = new Bot(random_bot_a, random_bot_b, track);//BREED
      bots[i] = new Bot(bots[i], 1, 6, 6, track);//MUTATE
    }
  }
   
  void step() {
    for (Bot bot : bots) {
      if (!bot.machine.dead) {
        bot.step();
        if (bot.machine.dead) {
          bot.generate_score();
          alive -= 1;
        }
      }
    }
  }
  
  void reset(Track track) {
    alive = bots.length;
    for (Bot bot : bots) {
      bot.reset(track);
    }
  }
  
  Boolean finished() {
    for (Bot bot : bots) {
      if (!bot.machine.dead) {return false;}
    }
    return true;
  }
  
  Bot lead() {
    Bot best = bots[0];
    for (Bot bot : bots) {
      if (bot.machine.distance() > best.machine.distance() && !bot.machine.dead) {
        best = bot;
      }
    }
    return best;
  }
  
  Bot random_bot(Bot[] bots, float total) {
    float threshold = random(total);
    int index = 0;
    while (threshold > 0) {
      threshold -= bots[index].score;
      index += 1;
    }
    return bots[max(index-1,0)];
  }
  
  Bot[] sort_bots(Bot[] unsorted) {
    if (unsorted.length > 1) {
      int m = unsorted.length/2;
      Bot[] a = (Bot[]) subset(unsorted,0,m);
      Bot[] b = (Bot[]) subset(unsorted,m,unsorted.length-m);
      return merge_bots(sort_bots(a), sort_bots(b));
    }
    return unsorted;
  }
  
  Bot[] merge_bots(Bot[] a, Bot[] b) {
    Bot[] c = new Bot[a.length+b.length];
    int pa = 0;
    int pb = 0;
    int pc = 0;
    while (pa < a.length && pb < b.length) {
      if (a[pa].score > b[pb].score) {
        c[pc] = a[pa];
        pa++;
      }
      else {
        c[pc] = b[pb];
        pb++;
      }
      pc++;
    }
    while(pa < a.length) {
      c[pc] = a[pa];
      pa++;
      pc++;
    }
    while(pb < b.length) {
      c[pc] = b[pb];
      pb++;
      pc++;
    }
    return c;
  }
}


class Multi_Generation {
  Generation[] generations;
  Track track;
  int generation_count = 1;
  int track_count = 1;
  int max_track;
  int alive;
  
  Multi_Generation() {
    generations = new Generation[1];
    track = new Track(60, 50, 0.7, 200);
    max_track = 1;
    alive = generations.length;
    generations[0] = new Generation(1, 10, new int[] {6}, track, CAR_COLS[0]);
    generations[0].bots[0].brain = new Network("test");
  }
  
  Multi_Generation(int n, int population, int t) {
    generations = new Generation[n];
    track = new Track(60, 50, 0.7, 200);
    max_track = t;
    alive = generations.length;
    for (int i = 0; i < generations.length; i++) {
      generations[i] = new Generation(population, 10, new int[] {6}, track, CAR_COLS[i % CAR_COLS.length]);
    }
  }
  
  Multi_Generation(Multi_Generation prev) {
    generations = new Generation[prev.generations.length];
    generation_count = prev.generation_count + 1;
    track = new Track(60, 50, 0.7, 200);
    max_track = prev.max_track;
    alive = generations.length;
    for (int i = 0; i < generations.length; i++) {
      generations[i] = new Generation(prev.generations[i], 0.15, 0.4, 0.2, track);
    }
  }
  
  void step() {
    track.display();
    for (Generation generation : generations) {
      if (!generation.finished()) {
        generation.step();
        if (generation.finished()) {
          alive -= 1;
        }
      }
    }
    if (alive == 0) {
      generate_track();
    }
  }
  
  void generate_track() {
    if (track_count < max_track && generation_count >= 50) {
      track = new Track(60, 50, 0.7, 200);
      for (Generation generation : generations) {
        generation.reset(track);
      }
      camera.set_pos(generations[0].bots[0]);
      alive = generations.length;
    }
    track_count += 1;
  }
  
  boolean finished() {
    if (alive == 0 && (generation_count < 25 || track_count >= max_track)) {
      return true;
    }
    return false;
  }
  
  Bot lead() {
    Bot global_lead = generations[0].lead();
    for (Generation generation : generations) {
      Bot local_lead = generation.lead();
      if (local_lead.machine.distance() > global_lead.machine.distance()) {
        global_lead = local_lead;
      }
    }
    return global_lead;
  }
}