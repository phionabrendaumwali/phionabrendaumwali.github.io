import java.util.ArrayList;
import processing.serial.*;
import grafica.*;
import java.awt.*;
import uk.me.berndporr.iirj.*;
import com.github.psambit9791.jdsp.filter.Butterworth;
import com.github.psambit9791.jdsp.filter.*;
import com.github.psambit9791.jdsp.signal.peaks.*;
import org.apache.commons.math3.stat.descriptive.SummaryStatistics;


String myString = null;
int numAxis = 6; 
BufferedReader reader;
String line= "";
int linecounter =0;
int locationPlotIMU_X = 20;// The position of the plot in the window
int locationPlotIMU_Y = 20;
int widthPlotIMU = 1300;// size of the plot 
int heightPlotIMU = 800;
int YLim = 40;
int samplingrate = 70; 
int cutoff = 3;


ArrayList rawData[] = new ArrayList[numAxis];// each arraylist saves the data for one axis in IMU

void setup() {
  size(1500, 900);// dimension of the window
  background(color(255,255,255));
  
  String datafile = "IMUData_hand20slow30fast.csv";
  //Load data from the datafile to rawData[];
  loadData(datafile);
  
  ArrayList signal = rawData[1];
  drawdata(signal, color(0,255,0));// Visualize Acclerometer X-axis  
  //drawdata(rawData[1], color(255,0,0));// Visualize Acclerometer Y-axis 
  //drawdata(rawData[2], color(0,0,255));// Visualize Acclerometer Z-axis 
  
  ArrayList lowpassArray= lowPassFilter(signal, samplingrate, cutoff);// 
  drawdata(lowpassArray, color(0,0,255));// Visualize Acclerometer X-axis  
  
  //ArrayList magArray = magnitudeAccl(rawData); //calculate the magnitude/energy of the acclerometer 
  //ArrayList avgArray =  movingAverage(diffArray,10); // apply moving average filter on the data 

  ArrayList peaks =  jDSPfindPeaks(lowpassArray);
  ArrayList troughs = jDSPfindTroughs(lowpassArray);
  drawPeaks(lowpassArray,peaks,color(255,0,0));//red dots for peaks
  drawPeaks(lowpassArray,troughs,color(0,0,255));//blue dots for peaks

}
void draw() {
}

//Load data from the file into arraylists
void loadData(String filepath){
//Initialize the arraylists for saving the raw IMU data   
   for(int i=0; i<numAxis;i++) {
      rawData[i]= new ArrayList();
   }
   reader = createReader(filepath);// reader is an instance of BufferedReader
   
   //read Data from the files until the end of the file
   while(line!=null){
     try {
      line = reader.readLine();
      if(line==null) break;      
      String[] list = split(line.substring(0, line.length()-2), ',');
      
      //Save data into arrayList
      if(list.length == numAxis){
        float[] imuValue = new float[numAxis]; // imuValue 0-6 : acclx, y, z, gyro x, y, z;
        for(int i = 0; i<numAxis; i++){
          imuValue[i] = Float.parseFloat(list[i]);
          rawData[i].add(imuValue[i]);
        }
        linecounter++;
      }
      println(linecounter+","+line);
     } catch (IOException e) {
      e.printStackTrace();
      line = null;
     } 
   }
}
//Draw data in line with the specified color
void drawdata(ArrayList data, color linecolor){
  
   GPointsArray gpoints = new GPointsArray();
   for(int i=0; i<data.size();++i){
     gpoints.add(i, (float)data.get(i));
   }
    
    GPlot plotIMU= new GPlot(this);
    plotIMU.setPos(locationPlotIMU_X, locationPlotIMU_Y);
    plotIMU.setDim(widthPlotIMU, heightPlotIMU);
    plotIMU.setPoints(gpoints);
    plotIMU.setYLim(-YLim,YLim);
    plotIMU.setXLim(0, linecounter-2);

    
    plotIMU.setTitleText("IMU Data");
    plotIMU.getXAxis().setAxisLabelText("Time (t)");
    plotIMU.getYAxis().setAxisLabelText("y axis");
 
    // plot background and axis 
    //println("draw");
    plotIMU.beginDraw();
    //plotIMU.drawBackground();
    plotIMU.drawXAxis();
    plotIMU.drawYAxis();
    plotIMU.drawTitle();
    plotIMU.setLineColor(linecolor);
    plotIMU.drawLines();
    plotIMU.endDraw();
  
}

// Draw the peaks as points using the specficied color
void drawPeaks(ArrayList data, ArrayList peaks, color mycolor){
  
   GPointsArray gpoints = new GPointsArray();
   for(int i=0; i<peaks.size();++i){
     int peakindex = (int)peaks.get(i);
     gpoints.add(peakindex, (float)data.get(peakindex));
     //println("Peak position and values:"+peakindex+","+(float)data.get(peakindex));
   }
   
    GPlot plotIMU= new GPlot(this);
    plotIMU.setPos(locationPlotIMU_X, locationPlotIMU_Y);
    plotIMU.setDim(widthPlotIMU, heightPlotIMU);
    plotIMU.setPoints(gpoints);
    plotIMU.setYLim(-YLim,YLim);
    plotIMU.setXLim(0, linecounter-2);

    
 
    // plot background and axis 
    //println("draw");
    plotIMU.beginDraw();
    //plotIMU.drawBackground();
    plotIMU.drawXAxis();
    plotIMU.drawYAxis();
    plotIMU.drawTitle();
    plotIMU.setPointColor(mycolor);
    plotIMU.drawPoints();
    plotIMU.endDraw();
  
}

//Calculate the magnitude of Accelerometer = X^2+y^2+z^2, return as an arraylist
ArrayList magnitudeAccl(ArrayList[] data){
  
  ArrayList magnitudeArray = new ArrayList();
  //Implement your function  


  return magnitudeArray;
}


//Applying the moving average filter on the data 
ArrayList movingAverage(ArrayList data, int winsize){
  ArrayList avgArray = new ArrayList();
  //Implement your function  

  return avgArray;
}


//return the index of peaks in the original raw signal 
ArrayList findPeaks(ArrayList rawsignal){
  ArrayList peaksArray = new ArrayList();
  
  //println("total number of peaks: "+peaksArray.size());
  return peaksArray;
  
}

//return the index of troughs in the original raw signal 
ArrayList findTroughs(ArrayList rawsignal){
  ArrayList troughsArray = new ArrayList();
  
  //println("total number of peaks: "+peaksArray.size());
  return troughsArray;
  
}

//Remove the false peaks by analyzing the prominence between peaks and troughs
ArrayList ProminenceAnalysis(ArrayList rawsignal, ArrayList peaks, ArrayList troughs){
  ArrayList revisedPeaks = new ArrayList();
  
  return revisedPeaks;
  
}


// find peaks in the input arraylist. The return arraylist includes the index of peaks (positions) in the orignial arraylist.
ArrayList jDSPfindPeaks(ArrayList rawsignal){
  //convert data from arraylist to array[]; 
  double[] signal = new double[rawsignal.size()];
  for(int i=0; i<rawsignal.size(); ++i){
    signal[i]= ((float)rawsignal.get(i));
  }
  
  //calling findpeak function to detect peaks
  FindPeak fp = new FindPeak(signal);
  Peak out = fp.detectPeaks();
  int[] peaks = out.getPeaks();
  
  //create an arraylist to save the index of peaks in rawsignal
  ArrayList peaksArray = new ArrayList();
  for(int i=0; i<peaks.length; ++i){
    peaksArray.add(peaks[i]);
    //println("Peak:" + peaks[i]);
  }
  println("total number of Peaks"+peaksArray.size());
  return peaksArray;
}

// find troughs in the input arraylist. The return arraylist includes the index of troughs (positions) in the orignial arraylist.
ArrayList  jDSPfindTroughs(ArrayList rawsignal){
  //convert data from arraylist to array[]; 
  double[] signal = new double[rawsignal.size()];
  for(int i=0; i<rawsignal.size(); ++i){
    signal[i]= ((float)rawsignal.get(i));
  }
  
  FindPeak fp = new FindPeak(signal);
  Peak out = fp.detectTroughs();
  int[] peaks = out.getPeaks();
  //create an arraylist to save the index of troughs in rawsignal
  ArrayList troughsArray = new ArrayList();
  for(int i=0; i<peaks.length; ++i){
    troughsArray.add(peaks[i]);
    //println("Peak:" + peaks[i]);
  }
  println("total number of Troughs"+troughsArray.size());
  return troughsArray;
}

//Apply lowPassfilter to the rawsigan with requested sampling rate and cutoff frequency
ArrayList lowPassFilter(ArrayList rawsignal, int samplingrate, int cutoff ){
  int Fs = samplingrate; //Sampling rate in Hz
  int order = 10; //order of the filter
  int cutOff = cutoff; //Cut-off Frequency
  double[] signal = new double[rawsignal.size()];
  
  for(int i=0; i<rawsignal.size(); ++i){
    signal[i]= ((float)rawsignal.get(i));
  }
  //Butterworth is one type of filter
  Butterworth flt = new Butterworth(signal, Fs); //signal is of type double[]
  
  //Chebyshev flt = new Chebyshev(signal, Fs, 1, 1);
  double[] result = flt.lowPassFilter(order, cutOff); //get the result after filtering
  ArrayList filteredsignal = new ArrayList();
  for(int i=0; i<result.length; ++i){
    filteredsignal.add( (float)result[i]);
  }
  return filteredsignal;
}
