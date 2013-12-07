//
//  ViewController.m
//  OverlayViewControllerExample
//
//  Created by Stuart Crook on 07/12/2013.
//  Copyright (c) 2013 Stuart Crook. All rights reserved.
//

#import "ViewController.h"
#import "OverlayViewController.h"
#import "BlurredOverlayViewController.h"

@interface ViewController ()
@end

@implementation ViewController

- (IBAction)displayBasicOverlayTapped:(id)sender {
    [self presentViewController: [OverlayViewController new] animated: YES completion: nil];
}

- (IBAction)displayBlurredOverlayTapped:(id)sender {
    [self presentViewController: [BlurredOverlayViewController new] animated: YES completion: nil];
}

@end
