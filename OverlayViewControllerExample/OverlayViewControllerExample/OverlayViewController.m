//
//  OverlayViewController.m
//  OverlayViewControllerExample
//
//  Created by Stuart Crook on 07/12/2013.
//  Copyright (c) 2013 Stuart Crook. All rights reserved.
//

#import "OverlayViewController.h"

@interface OverlayViewController ()
@end

@implementation OverlayViewController

- (IBAction)dismissTapped:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated: YES completion: nil];
}

@end
