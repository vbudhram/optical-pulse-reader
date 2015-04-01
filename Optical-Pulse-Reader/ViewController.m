//
//  ViewController.m
//  Instant Blood Pressure
//
//  Created by Vijay Budhram on 3/22/15.
//  Copyright (c) 2015 Baby Carrot Productions. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MonitorController.h"

#import <GPUImage/GPUImage.h>

@interface ViewController ()
{
    GPUImageVideoCamera *videoCamera;
    GPUImageOutput<GPUImageInput> *filter;
    MonitorController *monitorController;
    IBOutlet UILabel *heartRate;
    IBOutlet GPUImageView *heartView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peaked:) name:@"peaked" object:nil];
    
    // Setup controllers
    monitorController = [MonitorController getInstance];
    
    // Turn flash light on
    [self turnTorchOn:YES];
    
    // Setup video camera
    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    videoCamera.horizontallyMirrorFrontFacingCamera = NO;
    videoCamera.horizontallyMirrorRearFacingCamera = NO;
    
    // Setup average color filter
    GPUImageAverageColor *averageColor = [[GPUImageAverageColor alloc] init];
    [averageColor setColorAverageProcessingFinishedBlock:^(CGFloat redComponent, CGFloat greenComponent, CGFloat blueComponent, CGFloat alphaComponent, CMTime frameTime){
        [monitorController update:redComponent greenComponent:greenComponent blueComponent:blueComponent];
    }];
    
    // Setup exposure filter, using max value to reduce noise
    GPUImageExposureFilter *exposureFilter = [[GPUImageExposureFilter alloc] init];
    [exposureFilter setExposure:8.0];
    
    // Apply average color filter to exposure filter
    [exposureFilter addTarget:averageColor];
    
    filter = exposureFilter;
    
    [videoCamera addTarget:filter];
    
    GPUImageView *filterView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    [heartView addSubview:filterView];

    [filter addTarget:filterView];
    
    [videoCamera startCameraCapture];
}

- (void) viewDidDisappear:(BOOL)animated{
    [self turnTorchOn:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) turnTorchOn: (bool) on {
    
    // check if flashlight available
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (on) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                //torchIsOn = YES; //define as a variable/property if you need to know status
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                //torchIsOn = NO;
            }
            [device unlockForConfiguration];
        }
    }
}

#pragma mark Notifiations
-(void) peaked: (NSNotification *) notif
{
    NSNumber *rate = (NSNumber *)notif.object;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        heartRate.text = [[NSString alloc] initWithFormat:@"%.2f", [rate doubleValue]];
    }];
}

@end
