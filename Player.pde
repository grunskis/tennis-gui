class Player { 
  
  String name;
  int points;
  
  Player() {
    points = 0;
    name = "";
  }
  
  int getPoints() {
    return points;
  }
  
  void score(int amount) {
    points += amount;
    
    if (points < 0) {
      points = 0;
    }
  }
  
  void resetPoints() {
    points = 0;
  }
  
  String getName() {
    return name;
  }
  
  void setName(String name) {
    this.name = name;
  }
}
