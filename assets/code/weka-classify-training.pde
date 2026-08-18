
import processing.serial.*;
import grafica.*;
import weka.classifiers.Classifier;
import weka.core.Attribute;
import weka.core.DenseInstance;
import weka.core.FastVector;
import weka.core.Instances;
import weka.core.converters.ArffSaver;
import weka.core.converters.Saver;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.BufferedWriter;
import java.io.FileWriter;
import weka.classifiers.lazy.IBk;
import weka.classifiers.functions.SMO;
//import weka.core.converters.ConverterUtils.DataSource;

Serial myPort;  // Create object from Serial class

//Visluzation Related Variables
int numAxis = 6; 
int winSize = 70;// The length of window is 2 seconds.  140 data points , assuming sample rate of 70Hz
int overlap = 35; // overlap 50% 

String myString = null;
long lastTimeTriggered = 0;

//Weka ML related Variables
static public FastVector atts;
public static FastVector attsResult;
public Classifier myclassifier ;
BufferedWriter trainingfileWriter = null;
static Instances mInstances;  // Save the training instances
String[] classLabels= {"punching", "kicking", "jumpingjacks", "clapping", "armcircles"}; // The names of the class 
int numfeatures = 36;
double[] featurelist = new double[numfeatures+1];// The last one is for the lables
int numofTrainingSamples =5;
int samplecounter = 0;
// Where the ARFF file is saved 
String traingineFile = "/Users/brendaumwali/Documents/Processing/Weka_TrainingFileGenerator/2025_04_29_18_43_47_Training.arff";
float threthold = 15;
int slidingCounter = 0;
int activitySeperationTime = 4000;
int datadimension = 6; // e.g., there are 10 channels for the color sensor
String detectedActivity = "None";



//Save the data of the current window in multiple axis
ArrayList rawData[] = new ArrayList[numAxis];// each arraylist saves the data for one axis in IMU


void setup() {
  size(1200, 900);
  background(255);
  printArray(Serial.list());
  String portName = Serial.list()[4];
  myPort = new Serial(this, portName, 9600);// 
  
  for(int i=0; i<numAxis; ++i){
   rawData[i] = new ArrayList(); 
  }
  setupARFF(traingineFile,classLabels);
}

void draw() {
  //background(red, green, blue);
  background(color(255,255,255));
  textSize(80);
  fill(color(0,0,0));
  textAlign(CENTER,CENTER);
  text("Detected Activity:", width/2 , height/2 - 100);
  
  textSize(100);
  text(detectedActivity, width/2, height/2);
  while(myPort.available() > 0){
    myString = myPort.readStringUntil('\n');     // '\n'(ASCII=10) every number end flag
    if(myString!=null){
      //print(myString);
      analysisData(myString);
      
    }
  }
}


// Aanlyze the data including maintaining the sliding window, detect whether an event happens, and then classify the event
void analysisData(String myString){
  String[] list = split(myString.substring(0, myString.length()-2), ',');
  if(list.length == datadimension){
    float[] imuValue = new float[numAxis]; // imuValue 0-6 : acclx, y, z, gyro x, y, z;
    for(int i = 0; i<numAxis; i++){
      imuValue[i] = Float.parseFloat(list[i]);
    }
    
    // If the size is more than the windowsize, remove a data before adding new values in
    while(rawData[0].size() >= winSize ){
       for (int i= 0; i < numAxis; ++i){
        // Maintain the lenght of the array, If the size of array is larger than winSize, remove the oldest data.
         rawData[i].remove(0);
        }
    }
    
    // Add data into dataArray and PlotPoints at the same time
    for (int i= 0; i < numAxis; ++i){
     //System.out.println(IMUDataArray.get(0).size());
     rawData[i].add(imuValue[i]);
    }
    
    // Running gesture recognition only when the system has moved more than a step (overlap size). Only if overlap number of new data is in the current window
    slidingCounter++; 
    if(slidingCounter>=overlap && (rawData[0].size()==winSize) ){
        gestureRecognition(rawData);
        slidingCounter=0;
    }
        
  }
}

void gestureRecognition(ArrayList[] data){
  
  // Write your data processing algorithm here , miminum 1000 ms between two gestures
    long currenttime = millis();
    ArrayList magArray = magnitudeAccl(data);
    float maxMag = getMax(magArray);
    System.out.println("The Max of Magnitude on Acclerometer Readings: "+maxMag);
   
    // Activity detection/segmentation, detect when an activity is happening. The two activities have to be seperated by certain amount of time 
    // Using the maximum value of Magnitude of Accelerometer to determine whether an activity is happening. Threthold is emprically determined and can be adjusted.
    if((maxMag > threthold) && (currenttime-lastTimeTriggered)>activitySeperationTime){
      lastTimeTriggered = currenttime;
      // Calculate three features including the maximum value of Accelrometer X, Y, Z in the current window of data respectively. 
          featurelist = new double[numfeatures+1];
    int i = 0;
    for (int axis = 0; axis < 6; axis++) {
      featurelist[i++] = getMax(data[axis]);
      featurelist[i++] = getMin(data[axis]);
      featurelist[i++] = getMean(data[axis]);
      featurelist[i++] = getVariance(data[axis]);
      featurelist[i++] = getStd(data[axis]);
      featurelist[i++] = getZeroCrossingRate(data[axis]);
    }
   featurelist[36] = 0.0;
     // featurelist = new double[numfeatures+1];
      //featurelist[0] = getMax(data[0]);  
      //featurelist[1] = getMax(data[1]);  
      //featurelist[2] = getMax(data[2]);  
      //featurelist[3] = 0.0;  // assigned a random class label

     //Convert the features into the data strucutre for Weka (DenseInstance). Then Weka trained model will classify the results 
     try {
        DenseInstance addinstance = new DenseInstance(1.0, featurelist);
        addinstance.setDataset(mInstances); // Specify the instance family this instance belongs to
        int resultindex = (int)myclassifier.classifyInstance(addinstance);// Output the index of the recognition results. 
        detectedActivity = classLabels[resultindex];
        System.out.println("Gesture Detected: "+classLabels[resultindex]);
     } catch (Exception e) {
      // TODO Auto-generated catch block
      e.printStackTrace();
     }
    }
}


/**
   * Set up Arff files for later retrieving data out from here
   * 
   * @param folder
   */
  private void setupARFF(String folder, String[] mylabels) {
    atts = new FastVector(); // Save the feature namse
    attsResult = new FastVector(); // Save the label names
    
    //Set up the folder , in case the folder dose not exist
    File writeFolder = new File(folder);
      if (!writeFolder.exists()) {
        writeFolder.mkdirs();
      }
    
    for (int i=0; i<mylabels.length;++i) {
      attsResult.addElement(mylabels[i]);
    }
     String[] axes = {"AcclX", "AcclY", "AcclZ", "GyroX", "GyroY", "GyroZ"};
  String[] feats = {"Max", "Min", "Mean", "Var", "Std", "ZCR"};
  for (String axis : axes) {
    for (String feat : feats) {
      atts.add(new Attribute(feat + "_" + axis));
    }
  }

  atts.add(new Attribute("result", attsResult));
  mInstances = new Instances("Gestures", atts, 0);
    
   //Add the name of the features
     //Add the name of the features
    //atts.add(new Attribute("Max_AcclX"));
    //atts.add(new Attribute("Max_AcclY"));
    //atts.add(new Attribute("Max_AcclZ"));
    //atts.add(new Attribute("result", attsResult));
    //mInstances = new Instances("Gestures", atts, 0);

    try {
      //Load training file and train classifier     
      BufferedReader reader = new BufferedReader(new FileReader(traingineFile)); //<>//
      mInstances  = new Instances(reader);
      reader.close();
      mInstances.setClassIndex(mInstances.numAttributes() - 1); //<>//
      // Use KNN with a K = 3 
      //myclassifier = new J48();
      //myclassifier = new SMO();
      //Use Support vector machine (SVM) , SMO
      myclassifier = new IBk(5);
      myclassifier.buildClassifier(mInstances);
      
    } catch (Exception e) {
      // TODO Auto-generated catch block
      e.printStackTrace();
    }
  }
  

float getMax(ArrayList data){
  float max = (float)data.get(0);
  for(int i=1;i<data.size(); ++i){
    if(max< (float)data.get(i)) max = (float)data.get(i);
  }
  return max; 
}

float getMin(ArrayList data){
  float min = (float)data.get(0);
  for(int i=1;i<data.size(); ++i){
    if(min > (float)data.get(i)) min = (float)data.get(i);
  }
  return min; 
}

//Calculate the magnitude of Accelerometer = X^2+y^2+z^2
ArrayList magnitudeAccl(ArrayList[] data){
  ArrayList magnitudeArray = new ArrayList();
  for(int i=0; i<data[0].size();++i){
    float magnitude = sqrt( pow(((float)data[0].get(i)),2) + pow((float)data[1].get(i),2) + pow((float)data[2].get(i),2) );
    magnitudeArray.add(magnitude);
    //println(magnitude);
  }
   return magnitudeArray;
}

float getMean(ArrayList data){
  float sum = 0;
  for(int i=0;i<data.size(); ++i){
    sum += (float)data.get(i);
  }
  return sum / data.size();
}

float getVariance(ArrayList data){
  float mean = getMean(data);
  float sum = 0;
  for(int i=0;i<data.size(); ++i){
    float diff = (float)data.get(i) - mean;
    sum += diff * diff;
  }
  return sum / data.size();
}

float getStd(ArrayList data){
  return sqrt(getVariance(data));
}

float getZeroCrossingRate(ArrayList data){
  int count = 0;
  for (int i=1; i<data.size(); ++i){
    if (((float)data.get(i-1) >= 0 && (float)data.get(i) < 0) || ((float)data.get(i-1) < 0 && (float)data.get(i) >= 0)) {
      count++;
    }
  }
  return (float)count / (data.size() - 1);
}


// Output the current date in String
String getCurrentTime() {
 
    //add year month day to the file name
    String fname= "";
    fname = fname + year() + "_";
    if (month() < 10) fname=fname+"0";
    fname = fname + month() + "_";
    if (day() < 10) fname = fname + "0";
    fname = fname + day();
    //add hour minute sec to the file name
    fname = fname + "_";
    if (hour() < 10) fname = fname + "0";
    fname = fname + hour() + "_";
    if (minute() < 10) fname = fname + "0";
    fname = fname + minute() + "_";
    if (second() < 10) fname = fname + "0";
    fname = fname + second();

    return fname;
}
