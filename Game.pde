import de.bezier.data.sql.SQLite;

class Game {
  
  int[] score = new int[2];
  
  Player[] players = new Player[2];
  
  int serve = 0; // left player allways serves first

  SQLite db;
  
  long id; // game id in database
  
  String started; // date & time when the game started
  
  Game(Player a, Player b, PApplet klass) {
    score[A] = 0;
    score[B] = 0;
    
    players[A] = a;
    players[B] = b;
    
    id = -1;
    connectToDatabase(klass);
    
    started = getCurrentDateTime(); // TODO set this when first point scored?
  }
  
  void reset() {
    id = -1;
    
    A = 0;
    B = 1;
    
    score[A] = score[B] = 0;
    
    players[A].resetPoints();
    players[B].resetPoints();
    
    serve = A;
    
    started = getCurrentDateTime();
  }
  
  void score(char player) {
    score(player, 1);
  }
  
  void changeSides() {
    if (A == 0) {
        A = 1;
        B = 0;
      } else {
        A = 0;
        B = 1;
      }
  }
  
  void score(char player, int amount) {
    switch (player) {
      case 'a':
        players[A].score(amount);
        break;
      case 'b':
        players[B].score(amount);
        break;
    }
    
    if (setOver()) {
      int winner = (players[A].getPoints() > players[B].getPoints() ? A : B);
      
      score[winner]++;
      
      if (gameOver()) {
        // reset game?
      }
      
      beep(); // set over
      
      saveGame();
      
      players[A].resetPoints();
      players[B].resetPoints();
      
      changeSides();
    }
    
    changeServe();
  }
  
  void changeServe() {
    int a = players[A].getPoints();
    int b = players[B].getPoints();
    
    if (a >= 21 || b >= 21) {
      serve = (serve == A) ? B : A;
      beep(); // serve change
    } else {
      int remainder = (a + b) / 5;
      
      if (remainder % 2 == 0) {
        if (serve == B) {
          serve = A;
          beep(); // serve change
        }
      } else {
        if (serve == A) {
          serve = B;
          beep(); // serve change
        }
      }
    }
  }
  
  int getServe() {
    return serve;
  }
  
  int[] getScore() {
    return score;
  }
  
  int getScore(int player) {
    return score[player];
  }
  
  boolean gameOver() {
    return score[A] == 3 || score[B] == 3;
  }
  
  int getPoints(int player) {
    return players[player].getPoints();
  }
  
  String getName(int player) {
    return players[player].getName();
  }
  
  boolean setOver() {
    int a = players[A].getPoints();
    int b = players[B].getPoints();
    
    return (a >= 21 || b >= 21) && (abs(a - b) > 1);      
  }
  
  void connectToDatabase(PApplet klass) {
    db = new SQLite(klass, "games.db");
    db.connect();
    db.execute("CREATE TABLE IF NOT EXISTS games (" + 
      "id INTEGER PRIMARY KEY AUTOINCREMENT, " + 
      "aname TEXT, bname TEXT, " + 
      "a INTEGER, b INTEGER, " + 
      "started TEXT, finished TEXT);");
  }
  
  void saveGame() {
    Player a = players[0];
    Player b = players[1];
    
    if (a.getName() == "" || b.getName() == "") {
      println("Score not saved! Please enter all player names.");
      return; // don't save if we don't know who's playing
    }
    
    if (id < 0) {
      String sql = "INSERT INTO games (aname, bname, a, b, started, finished) VALUES ('" + a.getName() + "', '" + b.getName() + "', " + score[0] + ", " + score[1] + ", '" + started + "', '" + getCurrentDateTime() + "');";
      db.execute(sql);
      
      sql = "SELECT MAX(id) AS id FROM games";
      db.query(sql);
      
      if (db.next()) {
        id = db.getLong("id");
      }
    } else {
      String sql = "UPDATE games SET a = " + score[0] + ", b = " + score[1] + ", finished = datetime('now') WHERE id = " + id;
      db.execute(sql);
    }
  }
}
