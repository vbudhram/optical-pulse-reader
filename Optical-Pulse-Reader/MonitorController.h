//
//  MonitorController.h
//  Instant Blood Pressure
//
//  Created by Vijay Budhram on 3/26/15.
//  Copyright (c) 2015 Baby Carrot Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kIncreasing,
    kDecreasing
} State;

@interface MonitorController : NSObject

@property (strong, nonatomic) NSDate *lastPeakDate;
@property (nonatomic) double lastPeakValue;
@property (strong, nonatomic) NSDate *lastDate;
@property (nonatomic) double lastValue;
@property (nonatomic) double maxDiff;
@property (nonatomic) double minDiff;
@property (nonatomic) double previousDiff;
@property (strong, nonatomic) NSMutableArray *data;
@property (nonatomic) State state;
@property (nonatomic) State diffState;
@property (strong, nonatomic) NSNumber *estimatedRate;
@property (nonatomic) int incrementCnt;
@property (nonatomic) int decrementCnt;

@property (nonatomic, strong) NSMutableArray *lastSamples;

+(id) getInstance;
-(double) update: (double) redComponent greenComponent: (double) greenComponent blueComponent: (double) blueComponent;

@end
