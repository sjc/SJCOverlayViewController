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

#import "SJCOverlayViewController.h"

// interface declaration for the trasitioning delegate used by the view controller
// implimentation below
@interface SJCOverlayViewControllerTransitioningDelegate : NSObject <UIViewControllerTransitioningDelegate>
@end


#pragma mark - TOYOverlayViewController

@interface SJCOverlayViewController () {
    SJCOverlayViewControllerTransitioningDelegate *_td; // because AAARGH!!!
}
@end

@implementation SJCOverlayViewController

- (id)init {
    if((self = [super init])) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = _td = [SJCOverlayViewControllerTransitioningDelegate new];
    }
    return self;
}

- (void)dealloc {
    // necessary to stop the delegate leaking -- it appears that this property is strong rather than assign...
    self.transitioningDelegate = nil;
}

// subclasses can override this method to return the class of another SJCAnimatedTransitioning subclass to use a different transition animation
- (Class)animatedTransitioningClass {
    return [SJCAnimatedTransitioning class];
}

@end


#pragma mark - UIViewControllerTransitioningDelegate

//
// This is the standard transitioning delegate, which vends an instance of SJCAnimatedTransitioning (or one of
// its subclasses) which manages the actual transition animations. There should be no need to subclass or
// otherwise alter this class. To change the animation used when the view controller is appearing or disappearing
// the view controller subclass should override -animatedTransitioningClass to return a different clas
//

@implementation SJCOverlayViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    SJCAnimatedTransitioning *anim = [[(SJCOverlayViewController *)presented animatedTransitioningClass] new];
    anim.appearing = YES;
    return anim;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    SJCAnimatedTransitioning *anim = [[(SJCOverlayViewController *)dismissed animatedTransitioningClass] new];
    anim.appearing = NO;
    return anim;
}

@end


#pragma mark - SJCAnimatedTransitioning

//
// This is a basic transition animation controller which simply fades in or our the view of the view controller
// which is being displayed
//

@implementation SJCAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.25f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *container = [transitionContext containerView];
    UIViewController *vc = [transitionContext viewControllerForKey: (_appearing ? UITransitionContextToViewControllerKey : UITransitionContextFromViewControllerKey)];
    UIView *view = vc.view;
    
    if(_appearing) {
        view.alpha = _appearing ? 0.0f : 1.0f;
        view.frame = container.bounds;
        [container addSubview: view];
    }
    
    [UIView animateWithDuration: [self transitionDuration: transitionContext]
                     animations: ^{
                         view.alpha = _appearing ? 1.0f : 0.0f;
                     }
                     completion: ^(BOOL finished) {
                         [transitionContext completeTransition:YES];
                         if(!_appearing) {
                             [view removeFromSuperview];
                         }
                     }];
}

@end


