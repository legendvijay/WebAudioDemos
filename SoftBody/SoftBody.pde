/**
 * Soft Body 
 * by Ira Greenberg.  
 * 
 * Softbody dynamics simulation using curveVertex() and curveTightness().
 */
 
// center point
float centerX = 0, centerY = 0;

float radius = 100, rotAngle = -90;
float accelX, accelY;
float springing = .01, damping = .919000;

int nodes = (int)random(7) + 5;
float nodeStartX[] = new float[nodes];
float nodeStartY[] = new float[nodes];
float[]nodeX = new float[nodes];
float[]nodeY = new float[nodes];
float[]angle = new float[nodes];
float[]frequency = new float[nodes];

ArrayList oscs = new ArrayList();
ArrayList gains = new ArrayList();
var delay;

//corner nodes
void reset(){
	nodes = (int)random(8, 20);
	nodeStartX = new float[nodes];
	nodeStartY = new float[nodes];
	nodeX = new float[nodes];
	nodeY = new float[nodes];
	angle = new float[nodes];
	frequency = new float[nodes];
	for (int i=0; i<nodes; i++){
    	frequency[i] = random(50, 100);
  	}

	// Java Script
	for (int i=0; i<oscs.size();i++){
		var osc = oscs.get(i);
		var gain = gains.get(i);
	   	osc.stop();
		osc.disconnect();
		gain.disconnect();
	}
	
	oscs = new ArrayList();
	gains = new ArrayList();


	delay = context.createDelayNode();
	delay.delayTime.value = 1000;
	var compressor = context.createDynamicsCompressor(); 
	delay.connect(compressor);
	compressor.connect(context.destination);
	
	for (int i=0; i<nodes; i++){ 
		var osc = context.createOscillator();
		var gain = context.createGainNode();
		osc.type = 1; // sine wave
		osc.connect(gain);
		gain.connect(delay); 
		osc.noteOn && osc.noteOn(0);	
		oscs.add(osc);
		gains.add(gain);
  	}

}

// soft-body dynamics
float organicConstant = 1;

void setup() {
	  size(800, 800);
	  //center shape in window
	  centerX = width/2;
	  centerY = height/2;
	  noStroke();
	  smooth();
	  frameRate(30);

	reset();
}

void draw() {
  //fade background
  fill(0, 100);
  rect(0,0,width, height);
  drawShape();
  moveShape();
}

void drawShape() {
  //  calculate node  starting locations
  for (int i=0; i<nodes; i++){
    nodeStartX[i] = centerX+cos(radians(rotAngle))*radius;
    nodeStartY[i] = centerY+sin(radians(rotAngle))*radius;
    rotAngle += 360.0/nodes;
  }

  // draw polygon
  curveTightness(organicConstant);
  stroke(255);
  beginShape();
  for (int i=0; i<nodes; i++){
    curveVertex(nodeX[i], nodeY[i]);
  }
  for (int i=0; i<nodes-1; i++){
    curveVertex(nodeX[i], nodeY[i]);
  }
  endShape(CLOSE);
}

void moveShape() {
  //move center point
  float deltaX = mouseX-centerX;
  float deltaY = mouseY-centerY;

  // create springing effect
  deltaX *= springing;
  deltaY *= springing;
  accelX += deltaX;
  accelY += deltaY;

  // move predator's center
  centerX += accelX;
  centerY += accelY;

  // slow down springing
  accelX *= damping;
  accelY *= damping;

  // change curve tightness
  organicConstant = 1-((abs(accelX)+abs(accelY))*.1);

  //move nodes
  for (int i=0; i<nodes; i++){
    nodeX[i] = nodeStartX[i]+sin(radians(angle[i]*frequency[i]))*(accelX*2);
    nodeY[i] = nodeStartY[i]+sin(radians(angle[i]*frequency[i]))*(accelY*2);
    angle[i] += frequency[i];
  }

	for (int i=0; i<nodes; i++){ 
		var osc = oscs.get(i);
		var gain = gains.get(i);
		osc.frequency.value		= log(nodeX[i] / width + 1) * 2000;
		gain.gain.value 		= nodeY[i] / height * 0.5f;
	}
	
//	delay.delayTime.value = 1000 * centerX / width;
}

void mousePressed(){
	centerX = random(0, width);
	centerY = random(0, height);
}

float getCenterX(){

}

float getCenterY(){
	return centerY; 
}