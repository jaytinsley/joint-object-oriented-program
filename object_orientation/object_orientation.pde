//----------------------------------------------------Necessary global variables--------------------------------------------------------------

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
  joints.add(new joint(((width/4)*3), (height/4)*3, Integer.toString(0)));
  joints.add(new joint(width/4, (height/4)*3, Integer.toString(1)));

  //each Joints connections array is appended with the index of the other joint
  joints.get(joints.size()-2).connections.append(joints.size()-1);
  joints.get(joints.size()-1).connections.append(joints.size()-2);
  //In this example (joints.size()-2) is the index/location of joint in the array of the first joint.

  //joints.get(joints.size()-2).connections.append(joints.size()-3);

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
//
int[] arrayofJointsIndexsThatMakeUpBeamMouseIsNear() {

  int[] arrayofJointIndex = {-1, -1};
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
          || firstJoint.getAngle(secondJoint) == 0 || firstJoint.getAngle(secondJoint) == 90) {

          smallestDistance = distanceToBeam;
          firstJointIndex = i;
          secondJointIndex = k;
        }
      }
    }
  }

  if (smallestDistance <  20) {
    arrayofJointIndex[0] = firstJointIndex;
    arrayofJointIndex[1] = secondJointIndex;
  } 

  return(arrayofJointIndex);
}

int nearJoint() {

  for (int i = 0; i<joints.size(); i++) {
    joint firstJoint = joints.get(i);

    if (mouseX > firstJoint.X-50 && mouseY > firstJoint.Y-50
      && mouseX < firstJoint.X+50 && mouseY < firstJoint.Y+50) {
      return(i);
    }
  }
  return(-1);
}
void drawAllJoints() {
  for (int i = 0; i<joints.size(); i++) {
    joints.get(i).drawing();
  }
}

void mousePressed() {

  if (nearJoint() != -1) {
    //this returns the index of the joint it will be near
    //since it isnt returning -1 it is near a joint

    for (int i = 0; i<joints.size(); i++) {
      //makes all the joints not the current one.
      if (joints.get(i).isCurrentJoint == true) {
        joints.get(i).connections.append(nearJoint());
        joints.get(nearJoint()).connections.append(i);

        joints.get(i).isCurrentJoint = false;
      }
    }
    //makes the joint near the mouse the current joint.
    joints.get(nearJoint()).isCurrentJoint = true;
  } else {
    //creating a new Joint
    if (arrayofJointsIndexsThatMakeUpBeamMouseIsNear()[0]!= -1) {

      joint firstJoint = joints.get(arrayofJointsIndexsThatMakeUpBeamMouseIsNear()[0]);
      joint secondJoint = joints.get(firstJoint.connections.get(arrayofJointsIndexsThatMakeUpBeamMouseIsNear()[1]));

      int xHolder = findXpointOnLine(firstJoint, secondJoint);
      int yHolder = findYpointOnLine(firstJoint, secondJoint);


      if (firstJoint.getAngle(secondJoint) == 0) {
        //mouse is on a beam horizontal
        joints.add(new joint(mouseX, yHolder, Integer.toString(joints.size())));
      } else if (firstJoint.getAngle(secondJoint) == 90) {
        //mouse is on a beam vertical
        joints.add(new joint(xHolder, mouseY, Integer.toString(joints.size())));
      } else {
        //mouse is near a beam on an angle
        joints.add(new joint((xHolder+mouseX)/2, (yHolder+mouseY)/2, Integer.toString(joints.size())));
      }
    } else {
      //mouse isn't near a joint nor a beam
      joints.add(new joint(mouseX, mouseY, Integer.toString(joints.size())));
    }




    for (int i = 0; i<joints.size(); i++) {

      //loops throught the joints to find the current joint
      if (joints.get(i).isCurrentJoint == true) {

        // ↓ takes the current Joint and adds the newest joint to its list of connections
        joints.get(i).connections.append(joints.size()-1);

        // ↓ takes the latestJoint and adds the current joint to its list of connections
        joints.get(joints.size()-1).connections.append(i);

        joints.get(i).isCurrentJoint = false;
      }
    }
    joints.get(joints.size()-1).isCurrentJoint = true;
  }

  /*
      i need to take the the two joints returned by the close to beam program and use it to treat the beam as two seperate parts
   */
  int firstJointIndex = arrayofJointsIndexsThatMakeUpBeamMouseIsNear()[0];
  int secondJointIndex = arrayofJointsIndexsThatMakeUpBeamMouseIsNear()[1];

  // this gets the second joint in such a strange way
  //removes the first of the two joints the function returned from the second one
  joints.get(joints.get(firstJointIndex).connections.get(secondJointIndex)).connections.remove(firstJointIndex);

  //removes the second of the two joints the function returned from the first one

  joints.get(firstJointIndex).connections.remove(secondJointIndex);

  drawAllJoints();
  println("there are: "+countBeams()+" beams.");
}

int countBeams() {
  int counter = 0;
  for (int i=0; i<joints.size(); i++) {
    joint firstJoint = joints.get(i);
    for (int k=0; k<firstJoint.connections.size(); k++) {
      //joint secondJoint = joints.get(firstJoint.connections.get(k));

      //println(firstJoint.label + " --> "+ secondJoint.label + ":  " + distanceOfMouseToBeamFunc(firstJoint, secondJoint));

      //println("angle between " + firstJoint.label +" and " + secondJoint.label + " is " + firstJoint.getAngle(secondJoint));
      counter++;
    }
  }
  return(counter);
}
void draw() {

  //for (int i=0; i<joints.size(); i++) {
  //  joint firstJoint = joints.get(i);
  //  for (int k=0; k<joints.get(i).connections.size(); k++) {
  //    joint secondJoint = joints.get(firstJoint.connections.get(k));
  //    println(firstJoint.label + " --> "+ secondJoint.label + ":  " + distanceOfMouseToBeamFunc(firstJoint, secondJoint));
  //    println("angle between " + firstJoint.label +" and " + secondJoint.label + " is " + firstJoint.getAngle(secondJoint));
  //  }
  //}

  //println("there are : " +joints.size());

  for (int i = 0; i<joints.size(); i++) {
    //println(i);
    joint firstJoint = joints.get(i);
    if (mouseX > firstJoint.X && mouseY > firstJoint.Y
      && mouseX < firstJoint.X && mouseY < firstJoint.Y) {
      println(joints.get(i).label);
    }
  }
}
