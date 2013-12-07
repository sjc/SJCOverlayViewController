//
//  BlurredOverlayViewController.h
//  OverlayViewControllerExample
//
//  Created by Stuart Crook on 07/12/2013.
//  Copyright (c) 2013 Stuart Crook. All rights reserved.
//

//
// An example overlay view controller which uses the SJCBlurAnimatedTransitioning
// to provide an iOS-like bluring of the views behind the controller. See the
// implimentation of -animatedTransitioningClass in the .m for how this was achieved
//

#import "SJCOverlayViewController.h"

@interface BlurredOverlayViewController : SJCOverlayViewController

- (IBAction)dismissTapped:(id)sender;

@end
