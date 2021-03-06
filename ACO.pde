/* 
Created by Emanuel Wiens 
Created in Oct 27, 2021 
Purpose: This is a simple ant colony optimization implementation based on Ant Colony Optimization by Budi Santosa at https://bsantosa.files.wordpress.com/2015/03/aco-tutorial-english2.pdf. 
  The ants will make probabilistic about what the shortest path is and the result will be a probabilistic solution.  
  Note, you can change some of the final variables at the top. 
*/ 

final int numCities = 32; // numer of random cities to generate 
final float rho = 0.5; // evaporation constant 
final int numAnts = 16; // number of ants to randomly place 
final float alpha = 1; // importance of pheromone trail 
final float beta = 2; // importance of distance 
final int epochs = 100; // number of iterations 

City[] cities; 
Ant[] ants; 
float d[][]; // distance matrix 
float etaInit[][]; // visibility matrix 
float tau[][]; // initial pheromone matrix 
Ant globalBestAnt; 
boolean globalBestFound; 
float averageDist; 
float highestTau, lowestTau; 
int epochCounter = 0; 
float startTime, totalTime; 

void setup() {
  size(500, 500); 
  globalBestFound = false; 
  randomSeed(2); // set a seed for testing
  averageDist = 0; 
  
  cities = new City[numCities]; 
  initCities(); 
  
  // init distances and visibility 
  d = new float[numCities][numCities];
  etaInit = new float[numCities][numCities]; 
  initDistances(); 
  
  // init the pheromone 
  tau = new float[numCities][numCities];
  initTau(); 
  
  startTime = millis(); 
  totalTime = -1; 
} 

void runACO(int epoch) {
  // init the ants based on cities and visibility (1/distance) 
  ants = new Ant[numAnts]; 
  initAnts(-1); 
  
  // run all possible paths  
  for (int i = 0; i < numAnts; i++) {
    ants[i].update(); 
  } 
  
  // update the pheromone trails 
  updateTau(); 
  evap(); 
  findHighestAndLowest(); 
  println("Epoch: " + epoch + " highest and lowest tau: " + highestTau + ", " + lowestTau); 
  
  int best = getGlobalBest(); 
  if (best != -1) 
    globalBestAnt = ants[best]; 
  
  print("Global best ant " + globalBestAnt.id + " with dist " + globalBestAnt.totalDist + " and chosen path: "); 
  printV(globalBestAnt.visited); 
  println(); 
  
  fill(0); 
  stroke(0); 
  text("Epoch: " + epoch, 1, height - textDescent()); 
}

void draw() {
  background(200); 
  
  if (epochCounter < epochs) {
    runACO(epochCounter++); 
  } else {
    globalBestFound = true; 
  }
  
  // draw the cities 
  for (int i = 0; i < cities.length; i++) {
    cities[i].draw(); 
  } 
  
  // draw pheromone 
  float normalizedTau = 0; 
  for (int i = 0; i < cities.length; i++) { 
    for (int j = 0; j < cities.length; j++) { 
      normalizedTau = (tau[i][j] - lowestTau) / (highestTau - lowestTau); 
      stroke(0, normalizedTau * 255f); 
      line(cities[i].pos.x, cities[i].pos.y, cities[j].pos.x, cities[j].pos.y); 
    } 
  } 
  
  // Draw best path
  if (globalBestFound) {
    if (totalTime == -1)
      totalTime = millis() - startTime;  
    else { 
      fill(0); 
      stroke(0); 
      text((totalTime / 1000f) + " seconds with dist " + globalBestAnt.totalDist, 1, height - textDescent()); 
    }
    
    stroke(0, 255, 0); 
    int firstCity, secondCity; 
    for (int i = 0; i < globalBestAnt.visited.length - 1; i++) {
      firstCity = globalBestAnt.visited[i]; 
      secondCity = globalBestAnt.visited[i + 1];
        
      line(cities[firstCity].pos.x, cities[firstCity].pos.y, cities[secondCity].pos.x, cities[secondCity].pos.y); 
    }
  }
} 

void updateTau() {
  // update pheromone trail for path taken 
  int firstCity, secondCity; 
  for (int ant = 0; ant < ants.length; ant++) { 
    for (int i = 0; i < ants[ant].visited.length - 1; i++) { 
      firstCity = ants[ant].visited[i]; 
      secondCity = ants[ant].visited[i + 1]; 
      
      tau[firstCity][secondCity] = (tau[firstCity][secondCity] + 1f / ants[ant].totalDist); 
    } 
  } 
} 

int getGlobalBest() {
  int best = -1; 
  
  if (globalBestAnt == null) { 
    globalBestAnt = ants[0];
    best = 0; 
  }
  
  for (int i = 0; i < ants.length; i++) {
    averageDist += ants[i].totalDist; 
    
    if (ants[i].totalDist < globalBestAnt.totalDist)
      globalBestAnt = ants[i]; 
  }
  
  return best; 
}

void findHighestAndLowest() { 
  highestTau = 0; 
  lowestTau = 1; 
  
  for (int i = 0; i < cities.length; i++) {
    for (int j = 0; j < cities.length; j++) {      
      if (tau[i][j] > highestTau)
        highestTau = tau[i][j]; 
      
      if (tau[i][j] < lowestTau) 
        lowestTau = tau[i][j]; 
    }
  } 
}

void evap() {
  for (int i = 0; i < cities.length; i++) {
    for (int j = 0; j < cities.length; j++) {
      tau[i][j] = tau[i][j] * (1f - rho); 
    }
  } 
}

void initAnts(int initCity) {
  for (int i = 0; i < ants.length; i++) {
    if (initCity != -1)
      ants[i] = new Ant(i, cities[initCity], copyArray(etaInit)); 
    else 
      ants[i] = new Ant(i, cities[(int)random(numCities)], copyArray(etaInit)); 
  }
}

void printM(float[][] mat) { 
  for (int i = 0; i < cities.length; i++) {
    for (int j = 0; j < cities.length; j++) {
      print(mat[i][j] + " "); 
    }
    println(); 
  }
} 

void printV(float[] vec) {
  for (int i = 0; i < vec.length; i++) {
    println(i + ": " + vec[i]); 
  }
  println(); 
}

void printV(int[] vec) {
  for (int i = 0; i < vec.length; i++) {
    print(" " + vec[i]); 
  } 
  println(); 
}

public void initTau() {
  for (int i = 0; i < cities.length; i++) {
    for (int j = 0; j < cities.length; j++) {
      tau[i][j] = 1.0f; 
    }
  }
}

void initDistances() {
  for (int i = 0; i < cities.length; i++) {
    for (int j = 0; j < cities.length; j++) {
      d[i][j] = cities[i].pos.dist(cities[j].pos); 
      
      if (d[i][j] > 0) 
        etaInit[i][j] = 1.0f / d[i][j]; 
      else 
        etaInit[i][j] = 0; 
    }
  } 
} 

public City getCity(int id) {
  return cities[id]; 
}

public float[][] copyArray(float[][] src) {
  float copy[][] = new float[src.length][src[0].length]; 
  
  for (int i = 0; i < src.length; i++) {
    for (int j = 0; j < src[0].length; j++) {
      copy[i][j] = src[i][j]; 
    }
  }
  
  return copy; 
}

void initCities() {
  for (int i = 0; i < cities.length; i++) {
    cities[i] = new City(i, new PVector(random(width), random(height))); 
  }
}
