//----------------------------------------------------Necessary global variables--------------------------------------------------------------
//int currentJoint = -1;
ArrayList <joint> joints = new ArrayList <joint>();

//-----------------------------------------------------Testing global variables--------------------------------------------------------------


//---------------------------------------------------------Math Functions--------------------------------------------------------------
int distanceOfMouseToBeamFunc(joint firstJoint, joint secondJoint) {
  float X1 = firstJoint.X;
  float Y1 = firstJoint.Y;

  float Y2 = secondJoint.Y;
  float X2 = secondJoint.X;

  float num = ((X2 - X1)*(mouseY - Y1) - (Y2 - Y1)*(mouseX - X1))/800;

  return(int(abs(num)));
}

int findXpointOnLine(joint firstJoint, joint secondJoint) {
  //find the closest X point on a line to the mouse

  float X1 = firstJoint.X;
  float Y1 = firstJoint.Y;

  float Y2 = secondJoint.Y;
  float X2 = secondJoint.X;
  int posX = int(((X2 - X1)*(mouseY-Y1)/(Y2-Y1))+X1);
  return(posX);
}

int findYpointOnLine(joint firstJoint, joint secondJoint) {
  //find the closest Y point on a line to the mouse

  float X1 = firstJoint.X;
  float Y1 = firstJoint.Y;

  float Y2 = secondJoint.Y;
  float X2 = secondJoint.X;
  int posY = int(((Y2 - Y1)*(mouseX-X1)/(X2-X1))+Y1);
  return(posY);
}

void test() {
  println("test");
}


void setup() {
  size(800, 800);

  //Adds the two starting joints to the array and ensures they are connected 
  joints.add(new joint(((width/4)), (height/4), Integer.toString(0)));
  joints.add(new joint(width/4, (height/4)*3, Integer.toString(1)));

  joints.add(new joint(width/2, (height/2), Integer.toString(2)));



  //each Joints connections array is appended with the index of the other joint
  joints.get(joints.size()-2).connections.append(joints.size()-1);
  joints.get(joints.size()-1).connections.append(joints.size()-2);
  //In this example (joints.size()-2) is the index/location of joint in the array of the first joint.

  joints.get(joints.size()-2).connections.append(joints.size()-3);

  joints.get(joints.size()-1).isCurrentJoint = true;

  //drawing joints
  for (int i=0; i<joints.size(); i++) {
    joints.get(i).drawing();
  }
}

class joint { 
  int X, Y;
  String label;
  boolean isCurrentJoint;
  // list of the postion of whatever in their array
  IntList connections = new IntList();

  joint(int inX, int inY, String label) {
    //X = snapX(inX);
    X = inX;
    //Y = snapY(inY);
    Y = inY;
    this.label = label;
  }

  void drawJoint() {
    if (isCurrentJoint) {
      fill(0, 255, 0);
    }

    circle(X, Y, 10);
    fill(0);
    text(label, X+10, Y-10);
  }
  void drawConnections() {
    for (int i=0; i<connections.size(); i++) {
      // gets the other joint its connected to. 
      //    gets the joint >↓           ↓< gets the index of the joint it needs
      joint otherJoint = joints.get(connections.get(i));

      line(X, Y, otherJoint.X, otherJoint.Y);
    }
  }

  void drawing() {
    drawJoint();
    drawConnections();
  }

  float getAngle(joint otherJoint) {
    float Xdiff = otherJoint.X - X;
    float Ydiff = (otherJoint.Y - Y)*-1;
    //return(atan(Ydiff, X)*180/PI);
    //return(atan((Ydiff/Xdiff)*180/PI));
    return(atan((Ydiff/Xdiff))*180/PI);
  }
}

joint findPlaceForJoint() {
  int smallestDistance = width*height;
  int firstJointIndex = -1;
  int secondJointIndex = -1;
  for (int i=0; i<joints.size(); i++) {
    joint firstJoint = joints.get(i);
    for (int k=0; k<joints.get(i).connections.size(); k++) {
      joint secondJoint = joints.get(firstJoint.connections.get(k));
      int distanceToBeam = distanceOfMouseToBeamFunc(firstJoint, secondJoint);
      if (distanceToBeam<smallestDistance ) {

        if (mouseX > Math.min(firstJoint.X, secondJoint.X) && mouseY > Math.min(firstJoint.Y, secondJoint.Y)
          && mouseX < Math.max(firstJoint.X, secondJoint.X) && mouseY < Math.max(firstJoint.Y, secondJoint.Y) 
          || firstJoint.getAngle(secondJoint) == 0) {
          smallestDistance = distanceToBeam;
          firstJointIndex = i;
          secondJointIndex = k;
        }
      }
    }
  }

  if (smallestDistance <  20) {
    //println("rest");

    joint firstJoint = joints.get(firstJointIndex);
    joint secondJoint = joints.get(firstJoint.connections.get(secondJointIndex));

    int xHolder = findXpointOnLine(firstJoint, secondJoint);
    println(xHolder);
    int yHolder = findYpointOnLine(firstJoint, secondJoint);
    println(yHolder);

    if (firstJoint.getAngle(secondJoint) == 0) {
      //test();
      return(new joint(mouseX, yHolder, Integer.toString(joints.size())));
      
    }
    
    if (firstJoint.getAngle(secondJoint) == 90) {
      test();
      return(new joint(xHolder, mouseY, Integer.toString(joints.size())));
    }    
    return(new joint((xHolder+mouseX)/2, (yHolder+mouseY)/2, Integer.toString(joints.size())));
  }

  return(new joint(mouseX, mouseY, Integer.toString(joints.size())));
}
void mousePressed() {
  
  joints.add(findPlaceForJoint());
  for (int i = 0; i<joints.size(); i++) {
    joints.get(i).drawing();
  }
}

void draw() {

  for (int i=0; i<joints.size(); i++) {
    joint firstJoint = joints.get(i);
    for (int k=0; k<joints.get(i).connections.size(); k++) {
      joint secondJoint = joints.get(firstJoint.connections.get(k));
      println(firstJoint.label + " --> "+ secondJoint.label + ":  " + distanceOfMouseToBeamFunc(firstJoint, secondJoint));
      println("angle between " + firstJoint.label +" and " + secondJoint.label + " is " + firstJoint.getAngle(secondJoint));
    }
  }

  //println("there are : " +joints.size());
}
