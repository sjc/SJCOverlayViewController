/*
 The MIT License (MIT)
 
 Copyright (c) 2013 Stuart Crook
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 the Software, and to permit persons to whom the Software is furnished to do so,
 subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

// A view controller which impliments a custom transition to present itself
// cross-faded full screen

#import <UIKit/UIKit.h>

#pragma mark - SJCAnimatedTransitioning

//
// This is the external interface to the class which adopts the animated transitioning
// protocol and manges the actual presentation and dismissal of the view controller. It
// impliments a simple fade in / fade out animation. Subclasses can be written to
// provide more complicated animations. Subclasses of the overlay view controller can
// make use of these by overriding the -animatedTransitioningClass method to return a
// different class.
//
// An example subclass which impliments a background blur (SJCBlurAnimatedTransitioning)
// is included.
//

@interface SJCAnimatedTransitioning : NSObject <UIViewControllerAnimatedTransitioning>
@property (nonatomic, getter = isAppearing) BOOL appearing;
@end


#pragma mark - SJCOverlayViewController

//
// A UIViewController subclass which encapsulates full screen transparent transitions.
// To use, simply subclass.
//

@interface SJCOverlayViewController : UIViewController

// subclasses can override this to use an animation other than the basic fade in / fade out
- (Class)animatedTransitioningClass;

@end
