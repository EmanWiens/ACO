public class Ant {
  private City city; 
  private float eta[][]; // visibility matrix 
  private float prob[]; // the probability of visiting a given city 
  private int[] visited; // nodes visited during trip 
  private int trip; 
  private float totalDist; 
  private int id; 
  
  public Ant(int id, City city, float eta[][]) { 
    this.city = city; 
    this.eta = eta; 
    this.id = id; 
    updateVisibility(city.getId()); 
    prob = new float[numCities]; 
    
    trip = 0; 
    visited = new int[numCities]; 
    visited[trip++] = city.getId(); 
    totalDist = 0; 
  } 
  
  public void update() { 
    for (int currCity = 0; currCity < numCities - 1; currCity++) {
      // Calculate the probabilities 
      for (int i = 0; i < numCities; i++) {
        prob[i] = prob(city.getId(), i); 
      } 
      
      // calc cumulative probabilities and choose next city 
      float cumulativeProb[] = new float[numCities]; 
      float currProb = 0; 
      float choice = random(1); 
      int chosenCity = -1; 
      
      for (int i = 0; i < numCities; i++) {
        currProb += prob[i]; 
        cumulativeProb[i] = currProb; 
        
        if (currProb > choice) {
          chosenCity = i; 
          break; 
        }
      } 
      
      if (chosenCity == -1) 
        chosenCity = numCities - 1; 
      totalDist += d[city.getId()][chosenCity]; 
      city = getCity(chosenCity); 
      visited[trip++] = city.getId(); 
      updateVisibility(city.getId()); 
    }
  } 
  
  public float prob(int r, int s) { // from city r to city s 
    float toReturn = 0; 
    toReturn = pow(tau[r][s], alpha) * pow(eta[r][s], beta); 
    float sumM = 0;
    
    for (int u = 0; u < cities.length; u++) {
      sumM += pow(tau[r][u], alpha) * pow(eta[r][u], beta); 
    } 
    
    if (sumM > 0)
      toReturn = toReturn / sumM; 
    else 
      toReturn = 0; 
    
    return toReturn; 
  } 
  
  public void updateVisibility(int city) {
    for (int i = 0; i < cities.length; i++) {
      for (int j = 0; j < cities.length; j++) {
        if (j == city) 
          eta[i][j] = 0; 
      } 
    } 
  } 
} 
