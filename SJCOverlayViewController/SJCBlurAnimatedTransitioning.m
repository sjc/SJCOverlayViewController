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

@import Accelerate;
#import <float.h>

#pragma mark - SJCBlurAnimatedTransitioning

@interface SJCBlurAnimatedTransitioning ()
- (void)blurCurrentContext:(CGSize)size;
@end

@implementation SJCBlurAnimatedTransitioning

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {

    // before appearing, capture the views currently on screen, blur them, and
    // insert them as an image into the root of the appearing view controller
    
    if(self.isAppearing) {
        
        UIViewController *vc = [transitionContext viewControllerForKey: UITransitionContextToViewControllerKey];
        UIView *view = vc.view;
        UIWindow *window = [transitionContext containerView].window;
        UIView *root = window.rootViewController.view;
        
        // Using a scale factor of 1.0 instead of window.screen.scale (which will be 2.0 for
        // retina displays) speeds up rendering the blurred image without any obvious loss of
        // quality. If, however, you'd like to go back to using window.screen.scale, be sure
        // to do the same for the context created at line #104 in -blurCurrentContext: below
        UIGraphicsBeginImageContextWithOptions(root.bounds.size, NO, 1.0f /*window.screen.scale*/);
        
        // render everything on screen into the graphics context and then apply the blurring effect
        [root drawViewHierarchyInRect: root.bounds afterScreenUpdates: NO];
        [self blurCurrentContext: root.bounds.size];
        
        // create and insert an imageview holding the blurred image as the bottom view in the view controller
        UIImageView *imageView = [[UIImageView alloc] initWithImage: UIGraphicsGetImageFromCurrentImageContext()];
        imageView.frame = view.bounds;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        [view insertSubview: imageView atIndex: 0];
        
        UIGraphicsEndImageContext();
    }
    
    [super animateTransition: transitionContext];
}

//
// This code is based on Apple's UIImage+ImageEffects.h category. I've inlined it here
// to avoid requiring Apple's category, and in a (mostly failed) attempt to speed it up
// by removing some of the code which re-rendered the base image between contexts
//
- (void)blurCurrentContext:(CGSize)size {

    // these were previously passed as parameters to Apple's method
    // -applyBlurWithRadius:tintColor:saturationDeltaFactor:maskImage:
    CGFloat blurRadius = 30;
    UIColor *tintColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    CGFloat saturationDeltaFactor = 1.8;
    
    CGRect imageRect = { CGPointZero, size };
    CGContextRef effectInContext = UIGraphicsGetCurrentContext();
    
    BOOL hasBlur = blurRadius > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;

    if (hasBlur || hasSaturationChange) {
        
        vImage_Buffer effectInBuffer;
        effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
        effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
        effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
        effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
        
        // scale factor here should match the scale factor of the context created above
        UIGraphicsBeginImageContextWithOptions(size, NO, 1.0f /*[[UIScreen mainScreen] scale]*/);

        CGContextScaleCTM(effectInContext, 1.0, -1.0);
        CGContextTranslateCTM(effectInContext, 0, -size.height);
        
        CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
        vImage_Buffer effectOutBuffer;
        effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
        effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
        effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
        effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
        
        if (hasBlur) {
            // A description of how to compute the box kernel width from the Gaussian
            // radius (aka standard deviation) appears in the SVG spec:
            // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
            //
            // For larger values of 's' (s >= 2.0), an approximation can be used: Three
            // successive box-blurs build a piece-wise quadratic convolution kernel, which
            // approximates the Gaussian kernel to within roughly 3%.
            //
            // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
            //
            // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
            //
            CGFloat inputRadius = blurRadius * [[UIScreen mainScreen] scale];
            NSUInteger radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
            if (radius % 2 != 1) {
                radius += 1; // force radius to be odd so that the three box-blur methodology works.
            }
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
        }

        if (hasSaturationChange) {
            CGFloat s = saturationDeltaFactor;
            CGFloat floatingPointSaturationMatrix[] = {
                0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                0,                    0,                    0,  1,
            };
            const int32_t divisor = 256;
            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            for (NSUInteger i = 0; i < matrixSize; ++i) {
                saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
            }
            vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
        }
        
        UIGraphicsEndImageContext();
    }
    
    // Add in color tint.
    if (tintColor) {
        CGContextSaveGState(effectInContext);
        CGContextSetFillColorWithColor(effectInContext, tintColor.CGColor);
        CGContextFillRect(effectInContext, imageRect);
        CGContextRestoreGState(effectInContext);
    }
}

@end
