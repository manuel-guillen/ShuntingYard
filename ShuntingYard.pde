import java.util.LinkedList;
import java.util.Stack;

// Test Data:
// INPUT:  3 + 4 * 2 / ( 1 - 5 ) ^ 2 ^ 3
// OUTPUT: 3 4 2 * 1 5 − 2 3 ^ ^ / +

static final float goldenRatio = (1+sqrt(5))/2;

PFont calibri, calibriBold;
boolean startAnimation;
String input,output;

LinkedList<TokenGraphics> inTokens, outTokens;
Stack<TokenGraphics> operStack;

void setup() {
  size(1120,600);
  calibri = loadFont("Calibri-48.vlw");
  calibriBold = loadFont("Calibri-Bold-48.vlw");
  startAnimation = false;
  input = "";
  output = "";
  
  inTokens = new LinkedList<TokenGraphics>();
  outTokens = new LinkedList<TokenGraphics>();
  operStack = new Stack<TokenGraphics>();
  
  textAlign(LEFT,TOP);
}

void draw() {
  background(0);
  drawShuntingYard();
  showInput();  
  
  if (startAnimation) showTokens();
}

void showTokens() {
  for (TokenGraphics tg : inTokens)  drawToken(tg);
  for (TokenGraphics tg : operStack) drawToken(tg);
  for (TokenGraphics tg : outTokens) drawToken(tg);
}

void drawShuntingYard() {
  stroke(255);
  strokeWeight(2);
  line(505,600, 505,320);
  line(645,600, 645,320);
  
  line(0,250, width,250);
  
  noFill();
  ellipseMode(RADIUS);
  arc(435,320,70,70,-HALF_PI,0);
  arc(715,320,70,70,-PI,-HALF_PI);
}

void showInput() {
  textFont(calibriBold);  
  textSize(24);
  text("INPUT:",0,5);
  text("OUTPUT:",0,32);
    
  textFont(calibri);  
  textSize(24);
  text(input,80,5);
  text(output,95,32);
}

void drawToken(TokenGraphics tg1) {
  tg1.update();
  image(tg1.getGraphics(),tg1.getX(),tg1.getY());
}

TokenGraphics current;
void keyPressed() {
  if (key == '=') frameRate(frameRate*goldenRatio);
  else if (key == '-') frameRate(frameRate/goldenRatio);
  if (frameRate < 1) frameRate(1);
  
  if (!startAnimation) {   
    if (Character.isLetterOrDigit(key) || isOperator(key)) input += key;
    else if (keyCode == BACKSPACE && !input.isEmpty()) input = input.substring(0,input.length()-1);
    else if (keyCode == ENTER) {
        parseInput(input);
        startAnimation = true;
    }
  
  } else if (canContinue() && keyCode == ENTER) {
    if (!inTokens.isEmpty()) {
      if (current == null) current = inTokens.getFirst();
      
      if (current.isOperator()) {
        
        TokenGraphics o2 = null;
        if (!operStack.isEmpty()) o2 = operStack.peek();
          
         if (o2 != null && ((current.isLeftAssociative() && current.precedence() <= o2.precedence()) || current.precedence() < o2.precedence())) {
            TokenGraphics p = operStack.pop();
            for (TokenGraphics tg : outTokens) tg.shiftLeft();
            for (TokenGraphics tg : operStack) tg.shiftUp();
            p.popOntoQueue();
            outTokens.push(p);
            output += p + " ";
            
         } else {
            current = inTokens.removeFirst();
            for (TokenGraphics tg : inTokens) tg.shiftLeft();
            for (TokenGraphics tg : operStack) tg.shiftDown();
            current.pushToStack();
            operStack.push(current);
            current = null;
        }
        
      } else if (current.isLeftParenthesis()) {
        current = inTokens.removeFirst();
        for (TokenGraphics tg : inTokens) tg.shiftLeft();
        for (TokenGraphics tg : operStack) tg.shiftDown();
        current.pushToStack();
        operStack.push(current);
        current = null;
        
      } else if (current.isRightParenthesis()) {
        
          if (operStack.peek().isLeftParenthesis()) {
            
            current = inTokens.removeFirst();
            for (TokenGraphics tg : inTokens) tg.shiftLeft();
            
            operStack.pop();
            for (TokenGraphics tg : operStack) tg.shiftUp();
            current = null;
          
          } else {
          
            TokenGraphics p = operStack.pop();
            for (TokenGraphics tg : outTokens) tg.shiftLeft();
            for (TokenGraphics tg : operStack) tg.shiftUp();
            p.popOntoQueue();
            outTokens.push(p);
            output += p + " ";
          
          }
      } else {
          current = inTokens.removeFirst();
          for (TokenGraphics tg : inTokens) tg.shiftLeft();
          for (TokenGraphics tg : outTokens) tg.shiftLeft();
          current.pushToQueue();
          outTokens.push(current);
          output += current + " ";
          current = null;
      }
    } else if (!operStack.isEmpty()) {
      
      TokenGraphics p = operStack.pop();
      for (TokenGraphics tg : outTokens) tg.shiftLeft();
      for (TokenGraphics tg : operStack) tg.shiftUp();
      p.popOntoQueue();
      outTokens.push(p);
      output += p + " ";
      
    }
    
  }
  
}

boolean isOperator(char c) {
  return c == '+' || c == '-' || c == '*' || c == '/' || 
         c == '%' || c == '^' || c == '(' || c == ')';
}

void parseInput (String in) {
  int x = 700;
  int y = 110;
  
  inTokens = new LinkedList<TokenGraphics>();
  String s = "";
  
  for (int i = 0; i < in.length(); i++) {
    char c = in.charAt(i);
    
    if (Character.isLetterOrDigit(c)) 
      s += c;
    else {
      if (!s.isEmpty()) {
        inTokens.add(new TokenGraphics(s,x,y));
        x += 140;
      }
      inTokens.add(new TokenGraphics(""+c,x,y));
      s = "";
      x += 140;
    }
  }
  
  if (!s.isEmpty()) inTokens.add(new TokenGraphics(s,x,y));
}

boolean canContinue() {
  for (TokenGraphics p : inTokens)
    if (p.animating()) return false;
  
  for (TokenGraphics p : operStack)
    if (p.animating()) return false;
    
  for (TokenGraphics p : outTokens)
    if (p.animating()) return false;
  
  return true;
}
