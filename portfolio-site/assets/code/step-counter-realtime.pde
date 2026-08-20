
import uk.me.berndporr.iirj.*;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import org.apache.commons.math3.stat.descriptive.SummaryStatistics;
import processing.serial.*;
import grafica.*;
import java.awt.*;
import com.github.psambit9791.jdsp.filter.Butterworth;
import com.github.psambit9791.jdsp.filter.*;
import com.github.psambit9791.jdsp.signal.peaks.*;
Serial myPort;  
String myString = null;
float Threshold = 1.0;
PrintWriter output; 
int numAxis = 6; 
ArrayList rawData[] = new ArrayList[numAxis]; 
int winSize = 3; 
int heightThrethold= 1;
ArrayList slidingWindow = new ArrayList();
ArrayList myPeaks = new ArrayList();
int totalSteps =0;
int currentPos =0;
int sizeOfSlidingWin = 70; 
int stepCounter =0;
int samplerate = 70; 
int cutoff = 7; 
ArrayList[] windowData = new ArrayList[numAxis];
long starttime =0;
int timeduration = 30; 
int peakThrethold = 13;
float overlap = 0.5;
int stepLength = (int) ((float)sizeOfSlidingWin * (1.0f-overlap)); 
void setup() {
  size(1500, 900);
  background(255);
  printArray(Serial.list());
  String portName = Serial.list()[4];
  myPort = new Serial(this, portName, 9600);
  output = createWriter("IMUData_"+month()+"_"+day()+"_"+hour()+"_"+minute()+"_"+second()+".csv");

  for (int axisIndex = 0; axisIndex < numAxis; axisIndex++) {
  rawData[axisIndex] = new ArrayList();
  windowData[axisIndex] = new ArrayList();
}
}

void draw() {  
  while(myPort.available() > 0){
    if(starttime ==0) starttime = millis();
    myString = myPort.readStringUntil('\n');   
    if(myString!= null){
      String[] list = split(myString.substring(0, myString.length()-2), ',');
      if(list.length == numAxis){
        output.print(myString);
        float[] currentline = new float[numAxis];
        for( int i =0 ; i<list.length;++i){
            currentline[i] = Float.parseFloat(list[i]);
        }
        add2SlidingWindow(currentline);
      } 
    }
  }
  noStroke();
  fill(255);  // white
  rect(width/2 - 200, height/2 - 60, 400, 120); 
  fill(0);
  textSize(58);
  textAlign(CENTER, CENTER);
  text("Total Steps:", width/2, height/2 - 30);
  fill(0, 0, 255);
  textSize(58);
  textAlign(CENTER, CENTER);
  text(totalSteps, width/2, height/2 + 30);
  
}
void add2SlidingWindow(float[] newData){  
  for (int i=0; i< numAxis; i++) {
    windowData[i].add(newData[i]);
    
    if (windowData[i].size() > sizeOfSlidingWin) {
      windowData[i].remove(0); 
    }
  }
  
  currentPos++;
  
  if (currentPos >= stepLength) {
    int newSteps = countSteps(windowData);
    totalSteps += newSteps;
    
    println("New steps: " + newSteps + "   Accumulated Total Steps: " + totalSteps);
    currentPos = 0;
  }


}

int countSteps(ArrayList[] signals){  
  ArrayList magArray = magnitudeAccl(signals);
  
  ArrayList lowpassArray= lowPassFilter(magArray, samplerate, cutoff);
  
  ArrayList peaks = jDSPfindPeaks(lowpassArray); 
  ArrayList troughs = jDSPfindTroughs(lowpassArray);
  
  ArrayList newpeaks = ProminenceAnalysis(lowpassArray, peaks, troughs);
  
  ArrayList adjustedPeaks = removeDuplicatePeaks(lowpassArray, newpeaks);

  return adjustedPeaks.size();
}


ArrayList ProminenceAnalysis(ArrayList rawsignal, ArrayList peaks, ArrayList troughs) {
  ArrayList revisedPeaks = new ArrayList();
  float thresholdValue = 1.0;  //Threshold

  for (int i=0; i<peaks.size(); i++) {
    int peakIndex = (int)peaks.get(i);               
    float curPeakVal = (float)rawsignal.get(peakIndex);   
    float leftMin = curPeakVal;
    float rightMin = curPeakVal;
    
    for (int j=troughs.size()-1; j>=0; j--) {
      int troughIndex = (int)troughs.get(j);
      if (troughIndex < peakIndex) {
        leftMin = (float)rawsignal.get(troughIndex);
        break;  
      }
    }
    
    for (int j=0; j<troughs.size(); j++) {
      int troughIndex = (int)troughs.get(j);
      if (troughIndex > peakIndex) {
        rightMin = (float)rawsignal.get(troughIndex);
        break;  
      }
    }
    
    float leftDiff = curPeakVal - leftMin;
    float rightDiff = curPeakVal - rightMin;
    
    if (leftDiff >= thresholdValue && rightDiff >= thresholdValue) {
      revisedPeaks.add(peakIndex);  
    }
  }
  
  return revisedPeaks;
}

ArrayList removeDuplicatePeaks(ArrayList rawsignal,ArrayList peaks){
  
    ArrayList revisedPeaks = new ArrayList();
   
     for (int i = 0; i < peaks.size(); i++) {
    int idx = (int) peaks.get(i);
    if (idx >= stepLength) {
      revisedPeaks.add(idx - stepLength);
    }
  }
    
    return revisedPeaks;
}


ArrayList removePeaksbyHeight(ArrayList rawsignal,ArrayList peaks, float threthold){
  
    ArrayList revisedPeaks = new ArrayList();
    
    return revisedPeaks;
}

ArrayList magnitudeAccl(ArrayList[] data){
  
  ArrayList magnitudeArray = new ArrayList();
  
    for (int i = 0; i < data[0].size(); i++) {
    float x = (float)data[0].get(i);
    float y = (float)data[1].get(i);
    float z = (float)data[2].get(i);
    float mag = (float) Math.sqrt(x * x + y * y + z * z);
    magnitudeArray.add(mag);
    
    }

  return magnitudeArray;
}


ArrayList movingAverage(ArrayList data, int winsize){
  ArrayList avgArray = new ArrayList();
 

  return avgArray;
}


ArrayList findPeaks(ArrayList rawsignal){
  ArrayList peaksArray = new ArrayList();
  
  return peaksArray;
  
}

ArrayList findTroughs(ArrayList rawsignal){
  ArrayList troughsArray = new ArrayList();
  
  return troughsArray;
  
}

ArrayList jDSPfindPeaks(ArrayList rawsignal){
  double[] signal = new double[rawsignal.size()];
  for(int i=0; i<rawsignal.size(); ++i){
    signal[i]= ((float)rawsignal.get(i));
  }
  
  FindPeak fp = new FindPeak(signal);
  Peak out = fp.detectPeaks();
  int[] peaks = out.getPeaks();
  
  ArrayList peaksArray = new ArrayList();
  for(int i=0; i<peaks.length; ++i){
    peaksArray.add(peaks[i]);
  }
  return peaksArray;
}



ArrayList  jDSPfindTroughs(ArrayList rawsignal){
  double[] signal = new double[rawsignal.size()];
  for(int i=0; i<rawsignal.size(); ++i){
    signal[i]= ((float)rawsignal.get(i));
  }  
  FindPeak fp = new FindPeak(signal);
  Peak out = fp.detectTroughs();
  int[] peaks = out.getPeaks();
  ArrayList troughsArray = new ArrayList();
  for(int i=0; i<peaks.length; ++i){
    troughsArray.add(peaks[i]);
  }
  return troughsArray;
}
ArrayList lowPassFilter(ArrayList rawsignal, int samplingrate, int cutoff ){
  int Fs = samplingrate; 
  int order = 10;
  int cutOff = cutoff;
  double[] signal = new double[rawsignal.size()];
  
  for(int i=0; i<rawsignal.size(); ++i){
    signal[i]= ((float)rawsignal.get(i));
  }
  Butterworth flt = new Butterworth(signal, Fs); 
 
  double[] result = flt.lowPassFilter(order, cutOff); 
  ArrayList filteredsignal = new ArrayList();
  for(int i=0; i<result.length; ++i){
    filteredsignal.add( (float)result[i]);
  }
  return filteredsignal;
}
