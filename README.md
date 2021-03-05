# LabFishFinder
Very basic tracking program for fish in an aquarium using Matlab. 

This code was designed to be used to track a single fish in a laboratory aquarium where the scene does not change except for the moving fish. The tracking method is purely background substraction. Each frame of the video section selected is averaged to get a background. Each frame is then analysed and the pixels that are different from the average background are identified. Some movement due to water reflections can be tolerated.

To improve accuracy of what is tracked, the n_threshold and fish_area can be adjusted.
To speed up processing, some frames can be skipped when averaging (back_frame_step).

**Directions for code use:**
1. Change the fishID and trialID if required.
2. Run program
3. An input box will open. Select the video file to be analysed.
4. A second input box will open. To analyse a section of the video where the background does not move, set the section end and start time.
5. A dialogue box will open. Set the frame rate for tracking. This can be done at the full frame rate of your video, or reduced to speed up processing time.
6. The first frame of the video section will appear and the user can select the area of the scene to analyse. It is suggested to select the area within the tank and to exclude areas outside the tank that may have additional movement.
7. The user can then click two points which will divide up the scene for the purposes of analysis. A percent of time the fish spends on either side of the line will be calculated. If only the position of the fish is needed, the code can be easily altered to do so.
8. Analysis will then commence. The video section being analysed and a black and white image will appear as a figure. It is suggested that the user watches this to ensure the fish is being tracked accurately.
9. The data collected in each frame is the centroid of the object being tracked. A blue dot will appear in the center of the object in the black and white video from the figure. The code could be altered to change from the centroid to some other area (e.g. fish front or back). 
10. Once analysis is complete, a Percent of the time the fish was found on one side will be displayed in the Matlab Command Window. A plot of the trajectory of the fish will allow appear. 
11. A text or .mat file can be created that allows the user to export the data for further analysis. 
