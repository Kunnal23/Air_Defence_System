// Includes the Servo library
#include <Servo.h>

// Defines Trigger and Echo pins of both Ultrasonic Sensors
const int trigPin1 = 8; // Radar sensor
const int echoPin1 = 9;
const int trigPin2 = 10; // Pinpoint sensor
const int echoPin2 = 11;

// Variables for the duration and distance for each sensor
long duration1, duration2;
int distance1, distance2;

// Creates two Servo objects for controlling the servo motors
Servo radarServo;   // Radar servo
Servo pinpointServo; // Pinpoint servo

// Variables to track the radar and pinpoint angles
int radarAngle = 15;
int pinpointAngle = 0;
bool increasing = true; // Direction of radar movement

void setup() {
  // Set up the pins for both ultrasonic sensors
  pinMode(trigPin1, OUTPUT);
  pinMode(echoPin1, INPUT);
  pinMode(trigPin2, OUTPUT);
  pinMode(echoPin2, INPUT);
  
  // Initialize serial communication
  Serial.begin(9600);

  // Attach the servos to pins
  radarServo.attach(5);   // Radar servo on pin 5
  pinpointServo.attach(6); // Pinpoint servo on pin 6

  // Initialize the pinpoint servo at 0 degrees
  pinpointServo.write(0);
}

void loop() {
  // Radar sweeps continuously
  radarServo.write(radarAngle);
  delay(15); // Faster radar movement

  // Calculate distance from the radar sensor
  distance1 = calculateDistance(trigPin1, echoPin1);

  // If radar detects an object, align pinpoint sensor
  if (distance1 > 0 && distance1 <= 20) {
    Serial.print("Radar detected object! Angle: ");
    Serial.print(radarAngle);
    Serial.print(", Distance: ");
    Serial.print(distance1);
    Serial.println(" cm.");

    // Move the pinpoint sensor to the radar's detected angle
    pinpointAngle = radarAngle;
    pinpointServo.write(pinpointAngle);
    delay(50);

    // Verify object presence with the pinpoint sensor
    distance2 = calculateDistance(trigPin2, echoPin2);

    if (distance2 > 0 && distance2 <= 20) {
      Serial.print("Pinpoint locked on object. Angle: ");
      Serial.print(pinpointAngle);
      Serial.print(", Distance: ");
      Serial.print(distance2);
      Serial.println(" cm.");
    } else {
      Serial.println("Pinpoint sensor lost the object.");
    }
  }

  // Update radar angle for continuous sweeping
  if (increasing) {
    radarAngle++;
    if (radarAngle >= 165) increasing = false;
  } else {
    radarAngle--;
    if (radarAngle <= 15) increasing = true;
  }
}

// Function to calculate the distance measured by the Ultrasonic sensor
int calculateDistance(int trigPin, int echoPin) {
  digitalWrite(trigPin, LOW);  // Ensure trigPin is low initially
  delayMicroseconds(5);        // Short delay for stability

  // Trigger the ultrasonic pulse
  digitalWrite(trigPin, HIGH); 
  delayMicroseconds(10);       // Send a 10-microsecond pulse
  digitalWrite(trigPin, LOW);

  // Measure the echo pulse duration
  long duration = pulseIn(echoPin, HIGH, 30000); // Timeout added for stability

  // Calculate distance in cm, using speed of sound
  int distance = (duration > 0) ? duration * 0.034 / 2 : -1;

  return distance;
} 
