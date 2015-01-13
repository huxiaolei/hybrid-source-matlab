# Readme

This project is to create a GUI and Simulink model by using MPC (Model Predictive Control) for a hybrid energy storage system consisting Battery and Ultra-capacitor. THe work is published with the title of "Optimization of battery energy storage system with super-capacitor for renewable energy applications" on 2011 IEEE 8th International Conference on Power Electronics and ECCE Asia (ICPE & ECCE). The paper is accessible through IEEE Xplore Digital Library, please click [here](http://ieeexplore.ieee.org/xpl/articleDetails.jsp?tp=&arnumber=5944515&queryText%3DOptimization+of+battery+energy+storage+system+with+super-capacitor+for+renewable+energy+applications).

## How to run the main GUI

1. Launch Matlab, this program is only tested on Matlab 2012a, other versions maybe able to run but not tested
2. Open the folder by using the file explorer of the matlab which is on the left side of the main window.
3. Add ./lib and ./utils to PATH
4. type `simBB` in the command line to launch the GUI

## How to use the GUI

The GUI contains 3 main parts.

* Parameter Editor
	* Change the parameters according to your requirements.
	* By clicking buttons on the right side of the panel will launch parameters management tool.
		* Save changes will save the current changes, a comparison against default will show to the user.
		* Save As Default will save the current settings as the default setting.
		* Load Default will change the current settings to the default values.
		* Load will load a pre-saved settings.
		* delete will delete pre-saved settings.
	* "Set Param 2 mdl" will set the current settings to the simulink model.
	* by clicking the simulate button will invoke simulink to run the model based on current settings.

* Disturbance Setting
	* In this section, three types of disturbance are possible to set.
	* Click "add" on the bottom will add a disturbance to the list on the right
	* Click "Delete" will delete a item on the right list.
	* "Save List" list button will save the current list and can be loaded afterwards, say next time you want to do the same simulation.
	* "Load List" will load a pre-saved List.
	* "Start Sim Q" will invoke simulation based on the List one by one and save the results automatically for further use. Basically, you may left your computer to do the its job after you set up all the needed simulation.

* Plot
	* Plot section will plot the simulation results.
	* Five selectable items are on the right hand side. You may plot them simultaneously by click once. Say if you want to plot "DC Voltage" and "Battery Current" on the same page, simply click "DC voltage" and "Battery Current" will choose those two items. Then click "Plot" button will show the plot.
	* "save" can save a plot while "load" button may load a pre-saved Plot.
	* remove will remove the selected item from the plot list which is not recoverable.
 
```bash
tree

.
├── config
│   └── StepAndPluseSimT10s.txt
├── lib
│   ├── actxlicense.m
│   ├── AtriPair.m
│   ├── InvPICal.m
│   ├── ParamMg.m
│   ├── ParamStore.m
│   ├── PECommon.mdl
│   ├── pic
│   │   ├── Battery_Service.jpg
│   │   ├── BiBuckBoost.jpg
│   │   ├── Capacitor.png
│   │   ├── ctrl.gif
│   │   ├── ctrl.jpg
│   │   ├── HP.jpg
│   │   ├── IGBT.jpg
│   │   ├── Load_Motor.jpg
│   │   ├── SuperCapacitor.jpg
│   │   ├── ZSource.png
│   │   └── ZSource_impedence.png
│   ├── PiConCal.m
│   ├── PiConCalV2.m
│   ├── polesPlacement.asv
│   ├── polesPlacement.m
│   ├── polesPlacementv2.m
│   ├── polesPlacementv3.m
│   ├── slblocks.m
│   ├── test.m
│   ├── test.xml
│   ├── untitled.mdl
│   └── xml2struct.m
├── Mdl_Param.xml
├── modaldlg.fig
├── modaldlg.m
├── PowerController.mdl
├── README.md
├── Savedlg.fig
├── Savedlg.m
├── simBB.fig
├── simBB.m
├── Simdlg.fig
├── Simdlg.m
├── SimRs
│   └── This-folder-shoud-be-empty.txt
├── SUMMARY.md
└── utils
    ├── FFTCal.m
    ├── FFTCalMain.asv
    ├── FFTCalMain.fig
    ├── FFTCalMain.m
    ├── FFTPlot.m
    ├── lb.fig
    └── lb.m

5 directories, 49 files


```
