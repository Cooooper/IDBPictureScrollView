//
//  NSTimer+Addition.h
//  AutoSlideScrollViewDemo
//
//  Created by Han Yahui on 15/12/23.
//  Copyright © 2015年 Han Yahui. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface NSTimer (Addition)

- (void)pauseTimer;
- (void)resumeTimer;
- (void)resumeTimerAfterTimeInterval:(NSTimeInterval)interval;
@end
