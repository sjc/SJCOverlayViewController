//
//  BlurredOverlayViewController.m
//  OverlayViewControllerExample
//
//  Created by Stuart Crook on 07/12/2013.
//  Copyright (c) 2013 Stuart Crook. All rights reserved.
//

#import "BlurredOverlayViewController.h"
#import "SJCBlurAnimatedTransitioning.h"

@interface BlurredOverlayViewController ()
@end

@implementation BlurredOverlayViewController

- (IBAction)dismissTapped:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated: YES completion: nil];
}

// use the blurred transition effect
- (Class)animatedTransitioningClass {
    return [SJCBlurAnimatedTransitioning class];
}

@end
