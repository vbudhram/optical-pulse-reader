<img src="https://raw.githubusercontent.com/vbudhram/optical-pulse-reader/master/Optical-Pulse-Reader/Images.xcassets/pulse-resized-600.imageset/pulse-resized-600.png" alt="optical-pulse-reader" width="100px"/>

# optical-pulse-reader
iOS application that uses the camera to detect your heart rate

## Description

This application utilizes the iPhone's camera to estimate your pulse. Using [GPUImage](https://github.com/BradLarson/GPUImage), an average color filter and exposure filter are applied to the camera's image. By keeping track of the time difference between the green component of the filtered image, a pulse is estimated.

