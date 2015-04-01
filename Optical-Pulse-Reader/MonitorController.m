//
//  MonitorController.m
//  Instant Blood Pressure
//
//  Created by Vijay Budhram on 3/26/15.
//  Copyright (c) 2015 Baby Carrot Productions. All rights reserved.
//

#import "MonitorController.h"

@implementation MonitorController

@synthesize lastPeakDate;
@synthesize lastPeakValue;
@synthesize lastValue;
@synthesize lastDate;
@synthesize previousDiff;
@synthesize data;
@synthesize state;
@synthesize estimatedRate;
@synthesize maxDiff;
@synthesize minDiff;
@synthesize diffState;
@synthesize incrementCnt;
@synthesize decrementCnt;
@synthesize lastSamples;

#pragma mark Singleton Methods
+(id) getInstance {
    static MonitorController *shared = nil;
    @synchronized(self){
        if (shared == nil){
            shared = [[self alloc] init];
            shared.lastPeakDate = [NSDate date];
            shared.maxDiff = - 999;
            shared.minDiff = 999;
            shared.lastValue = 0;
            shared.lastSamples = [[NSMutableArray alloc] initWithCapacity:0];
        }
    }
    return shared;
}

-(double) update: (double) redComponent greenComponent: (double) greenComponent blueComponent: (double) blueComponent
{
    // Estimate heart rate from RGB components and previous values
    
    if(greenComponent < .95 && greenComponent > .05){
        
        double diff = fabs(greenComponent - lastValue);
        
        NSLog(@"Value: %f, lastValue: %f, Diff %f, Inc: %d, Dec: %d", greenComponent, lastValue, diff, incrementCnt, decrementCnt);
        
        if(diff < .00005)
        {
            
        }else if(state == kIncreasing){
            
            if(greenComponent < lastValue)
            {
                state = kDecreasing;
                
                if(decrementCnt > 2){
                    NSDate *now = [NSDate date];
                    double interval = [now timeIntervalSinceDate:lastPeakDate];
                    double calcRate = 60 / interval;
                    if(calcRate < 150 && calcRate > 40){
                        NSLog(@"------> PEAKED @ %d, HR: %f", decrementCnt, calcRate);
                        NSNumber *rate = [[NSNumber alloc] initWithDouble:calcRate];
//                        [[NSNotificationCenter defaultCenter] postNotificationName:@"peaked" object:rate];

                        // Calulate last sample average
                        int sampleCount = 6;
                        if([lastSamples count] < sampleCount){
                            [lastSamples addObject:rate];
                        }else{
                            
                            
                            NSRange range;
                            range.location = 1;
                            range.length = sampleCount-1;
                            lastSamples = [[NSMutableArray alloc] initWithArray:[lastSamples subarrayWithRange:range]];
                            [lastSamples addObject:rate];
                            
                            double sum = 0;
                            for(NSNumber *number in lastSamples){
                                sum = sum + [number doubleValue];
                            }
                            
                            NSNumber *averageRate = [[NSNumber alloc] initWithDouble:sum/sampleCount];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"peaked" object:averageRate];
                        }
                    }
                    
                    lastPeakDate = now;
                }
                
                decrementCnt = 0;
            }else{
                decrementCnt++;
            }
            
            lastValue = greenComponent;
            
        }else if(state == kDecreasing){
            
            if(greenComponent > lastValue)
            {
                state = kIncreasing;
                
                if(incrementCnt > 2){
                    //                    NSLog(@"------> BOTTOM @ %d", incrementCnt);
                }
                
                incrementCnt = 0;
            }else{
                incrementCnt++;
            }
            
            lastValue = greenComponent;
        }
    }
    return 0;
}

@end
