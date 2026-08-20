
import processing.serial.*;

Serial myPort;  // Create object from Serial class
String myString = null;
int datadimension = 6; // e.g., there are 10 channels for the color sensor
PrintWriter output; // write data into files
long starttime =0;
int timeduration = 30; //time duration of the recording in seconds

void setup() {
  size(640, 360);
  background(color(255,255,255));
  printArray(Serial.list());
  String portName = Serial.list()[4];// change to your port 
  myPort = new Serial(this, portName, 9600);// 
  output = createWriter("IMUData_"+year()+"_"+month()+"_"+day()+"_"+hour()+"_"+minute()+"_"+second()+".csv");// Use thte time and date to name the file
}
void draw() {
  //background(red, green, blue);
  while(myPort.available() > 0){
    if(starttime ==0) starttime = millis();// record the starting time of the recording in milliseconds
    myString = myPort.readStringUntil('\n');    // '\n'(ASCII=10) every number end flag
    if(myString!= null){
      String[] list = split(myString.substring(0, myString.length()-2), ',');// remove the newline symbol 
      if(list.length == datadimension){
        output.print(myString);// Output the line (string) to the local file
        println(myString);
    } 
    
    //If the recording time is longer than the timeduration, close the file and stop the program
    if(millis()-starttime > timeduration*1000){
      output.flush(); // Push the data from buffer to the file
      output.close();
      exit();
    }
  }
}
}
