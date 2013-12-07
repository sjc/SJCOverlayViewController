//
//  SJCBlurAnimatedTransitioning.m
//  OverlayViewControllerExample
//
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

#import "SJCBlurAnimatedTransitioning.h"
#import "UIImage+ImageEffects.h"


#pragma mark - SJCBlurAnimatedTransitioning

@implementation SJCBlurAnimatedTransitioning

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {

    // before appearing, capture the views currently on screen, blur them, and
    // insert them as an image into the root of the appearing view controller
    
    if(self.isAppearing) {
        
        UIViewController *vc = [transitionContext viewControllerForKey: UITransitionContextToViewControllerKey];
        UIView *view = vc.view;
        UIWindow *window = [transitionContext containerView].window;
        UIView *root = window.rootViewController.view;
        
        UIGraphicsBeginImageContextWithOptions(root.bounds.size, NO, window.screen.scale);
        
        // render everything on screen into the graphics context and then apply the blurring effect
        [root drawViewHierarchyInRect: root.bounds afterScreenUpdates: NO];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIImage *blurredImage = [image applyLightEffect];
        
        // create and insert an imageview holding the blurred image as the bottom view in the view controller
        UIImageView *imageView = [[UIImageView alloc] initWithImage: blurredImage];
        imageView.frame = view.bounds;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        [view insertSubview: imageView atIndex: 0];
        
        UIGraphicsEndImageContext();
    }
    
    [super animateTransition: transitionContext];
}

@end
