import processing.serial.*; // Imports library for serial communication

Serial myPort; // Defines Serial port object

// Variables for radar data
String angle = "";
String distance = "";
String data = "";
float pixsDistance = 0;
int iAngle = 0, iDistance = 0;
boolean dataReceived = false;

// Radar sweeping line variables
int sweepingAngle = 15; // Start angle for radar sweeping
boolean increasing = true; // Direction of sweeping

void setup() {
  fullScreen(); // Set the window to full-screen mode
  smooth();

  // Initialize Serial Port (Replace "COM10" with your actual port)
  String portName = Serial.list()[0]; // Automatically select the first available port
  for (int i = 0; i < Serial.list().length; i++) {
    if (Serial.list()[i].indexOf("COM10") != -1) { // Adjust "COM10" as needed
      portName = Serial.list()[i];
      break;
    }
  }

  myPort = new Serial(this, portName, 9600); // Starts the serial communication
  myPort.bufferUntil('.'); // Reads data up to the character '.'
}

void draw() {
  // Simulating motion blur and slow fade of the moving line
  noStroke();
  fill(0, 4);
  rect(0, 0, width, height - height * 0.065);

  // Draw radar components
  drawRadar();
  if (dataReceived) {
    drawObject(); // Only draw detected object if valid data is received
  }
  drawSweepingLine();
  drawText();

  // Update sweeping line angle
  if (increasing) {
    sweepingAngle++;
    if (sweepingAngle >= 165) increasing = false; // Reverse direction at max
  } else {
    sweepingAngle--;
    if (sweepingAngle <= 15) increasing = true; // Reverse direction at min
  }
}

void serialEvent(Serial myPort) {
  // Read data from Serial Port up to '.'
  data = myPort.readStringUntil('.');
  if (data != null) {
    data = trim(data); // Remove any trailing whitespace or newline characters
    if (data.length() > 0) {
      int index1 = data.indexOf(","); // Find the comma separator
      if (index1 != -1) {
        angle = data.substring(0, index1); // Extract angle
        distance = data.substring(index1 + 1); // Extract distance

        // Convert String to Integer
        try {
          iAngle = int(angle);
          iDistance = int(distance);
          dataReceived = true; // Mark as valid data
        } catch (NumberFormatException e) {
          println("Error parsing data: " + data);
          dataReceived = false;
        }
      }
    }
  }
}

void drawRadar() {
  pushMatrix();
  translate(width / 2, height - height * 0.074); // Radar center

  noFill();
  strokeWeight(4); // Thicker lines for better visibility
  stroke(98, 245, 31); // Green color for radar

  // Draw concentric arcs
  float maxRadius = min(width, height) * 0.45; // Adjusted maximum radius for full screen, reduce outer circle
  for (float r = maxRadius; r > maxRadius * 0.05; r -= maxRadius * 0.1) { // Reduced outermost circle
    arc(0, 0, r * 2, r * 2, PI, TWO_PI); // Adjusted arc size
  }

  // Draw angle lines every 30 degrees
  for (int a = 0; a <= 180; a += 30) {
    float x = (maxRadius * 0.9) * cos(radians(a));
    float y = (maxRadius * 0.9) * sin(radians(a));
    line(0, 0, x, -y);

    // Label the angles
    pushMatrix();
    translate(x, -y);
    rotate(-radians(a));
    fill(98, 245, 31);
    textSize(30); // Smaller text size for better visibility on full screen
    textAlign(CENTER, CENTER);
    text(a + "°", 0, 40);
    popMatrix();
  }
  popMatrix();
}

void drawObject() {
  if (iDistance <= 0 || iDistance > 40) return; // Ignore out-of-range or invalid distances

  pushMatrix();
  translate(width / 2, height - height * 0.074); // Radar center

  strokeWeight(12); // Larger dots for detected objects
  stroke(255, 10, 10); // Red color for detected objects

  // Convert distance to pixels (assuming max distance is 40 cm)
  float maxRadius = min(width, height) * 0.45; // Adjusted max radius for full screen
  pixsDistance = map(iDistance, 0, 40, 0, maxRadius * 0.9);

  // Calculate object position based on angle and distance
  float x = pixsDistance * cos(radians(iAngle));
  float y = pixsDistance * sin(radians(iAngle));

  point(x, -y); // Plot the detected object
  popMatrix();
}

void drawSweepingLine() {
  pushMatrix();
  translate(width / 2, height - height * 0.074); // Radar center

  strokeWeight(3);
  stroke(30, 250, 60); // Green color for radar sweep

  // Calculate sweeping line position based on current angle
  float maxRadius = min(width, height) * 0.45 * 0.9; // Sweep line length adjusted for full screen
  float x = maxRadius * cos(radians(sweepingAngle));
  float y = maxRadius * sin(radians(sweepingAngle));

  line(0, 0, x, -y); // Draw the sweeping line
  popMatrix();
}

void drawText() {
  pushMatrix();

  // Background for text
  fill(0, 0, 0);
  noStroke();
  rect(0, height - height * 0.0648, width, height * 0.065);

  // Text settings
  fill(98, 245, 31);
  textSize(30); // Smaller text size for better visibility on full screen
  textAlign(LEFT, CENTER);

  // Display radar information
  textSize(50); // Larger title
  text("Team Automatic ADS", width - width * 0.85, height - height * 0.03);
  text("Angle: " + sweepingAngle + "°", width - width * 0.48, height - height * 0.03);

  // Adjust the spacing between the label and the value for distance
  text("Distance: ", width - width * 0.26, height - height * 0.03); // Distance label
  if (iDistance <= 40) {
    // Increase the horizontal offset for the value to avoid overlap
    text("        " + iDistance + " cm", width - width * 0.15, height - height * 0.03); // Distance value
  }

  popMatrix();
}
