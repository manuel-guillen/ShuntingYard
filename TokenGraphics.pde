class TokenGraphics {
  
  private static final int SHIFT_LEFT = 1;
  private static final int SHIFT_DOWN = 2;
  private static final int SHIFT_UP = 3;
  private static final int POP_TO_QUEUE = 4;
  private static final int PUSH_TO_STACK = 5;
  private static final int PUSH_TO_QUEUE = 6;
  
  private String token;  
  private PGraphics img;
  private int x,y;
  
  private int animatingState;
  private int animatingCount;
  
  TokenGraphics(String s, int x1, int y1) {
    token = s;
    x = x1;
    y = y1;
    animatingState = 0;
    animatingCount = 0;
    
    img = createGraphics(140,140);
    img.beginDraw();
    img.background(0);
    img.stroke(255);
    img.noFill();
    img.rect(0,0,139,139,6);
    img.textAlign(CENTER,CENTER);
    
    int size = 70;
    if (s.length() > 3) size = 210/s.length();
    if (size == 0) size = 1;
    
    img.textSize(size);
    img.text(s,70,62);
    
    img.endDraw();
  }
  
  PGraphics getGraphics() {
    return img;
  }
  
  String toString() {
    return token;
  }
  
  int getX() {
    return x;
  }
  
  int getY() {
    return y;
  }
  
  boolean isOperator() {
    return token.equals("^") ||
           token.equals("*") ||
           token.equals("/") ||
           token.equals("%") ||
           token.equals("+") ||
           token.equals("-");
  }
  
  boolean isLeftParenthesis() {
    return token.equals("(");
  }
  
  boolean isRightParenthesis() {
    return token.equals(")");
  }
  
  boolean isRightAssociative() {
    return token.equals("^");
  }
  
  boolean isLeftAssociative() {
    return isOperator() && !isRightAssociative();
  }
  
  int precedence() {
    if (token.equals("^")) return 3;
    if (token.equals("*")) return 2;
    if (token.equals("/")) return 2;
    if (token.equals("%")) return 2;
    if (token.equals("+")) return 1;
    if (token.equals("-")) return 1;
    
    return 0;
  }
  
  boolean animating() {
    return animatingState != 0;
  }
  
  private int x0;
  private int y0;
  
  void update() {
    switch(animatingState) {
      case SHIFT_LEFT:
        if (animatingCount < 140) {
          x--;
          animatingCount++;
        } else {
          animatingState = 0;
          animatingCount = 0;
        }
        break;
      case SHIFT_UP:
        if (animatingCount < 140) {
          y--;
          animatingCount++;
        } else {
          animatingState = 0;
          animatingCount = 0;
        }
        break;
      case SHIFT_DOWN:
        if (animatingCount < 140) {
          y++;
          animatingCount++;
        } else {
          animatingState = 0;
          animatingCount = 0;
        }
        break;
      case POP_TO_QUEUE:
        if (animatingCount < 195) {
          x = (x0-225) + (int)(225*cos(animatingCount/194.0*HALF_PI));
          y = y0 - (int)(195*sin(animatingCount/194.0*HALF_PI));
          animatingCount++;
        } else {
          animatingState = 0;
          animatingCount = 0;
          x0 = 0;
          y0 = 0;
        }
        break;
      case PUSH_TO_STACK:
        if (animatingCount < 195) {
          x = x0 - (int)(195*sin(animatingCount/194.0 * HALF_PI));
          y = (y0+195) - (int)(195*cos(animatingCount/194.0 * HALF_PI));
          animatingCount++;
        } else {
          animatingState = 0;
          animatingCount = 0;
          x0 = 0;
          y0 = 0;
        }
        break;
      case PUSH_TO_QUEUE:
        if (animatingCount < 420) {
          x--;
          animatingCount++;
        } else {
          animatingState = 0;
          animatingCount = 0;
        }
        break;
    }
  }
  
  void shiftLeft() {
    animatingState = SHIFT_LEFT;
    animatingCount = 0;
  }
  
  void shiftUp() {
    animatingState = SHIFT_UP;
    animatingCount = 0;
  }
  
  void shiftDown() {
    animatingState = SHIFT_DOWN;
    animatingCount = 0;
  }
  
  void popOntoQueue() {
    animatingState = POP_TO_QUEUE;
    animatingCount = 0;
    x0 = x;
    y0 = y;
  }
  
  void pushToStack() {
    animatingState = PUSH_TO_STACK;
    animatingCount = 0;
    x0 = x;
    y0 = y;
  }
  
  void pushToQueue() {
    animatingState = PUSH_TO_QUEUE;
    animatingCount = 0;
  }
  
}
