//
//  UIImageView+Transition.m
//  CreationCommonLibrary
//
//  Created by Michael Rimestad on 5/8/13.
//  Copyright (c) 2013 Marcos Álvarez Mesa. All rights reserved.
//

#import "UIImageView+Transition.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIImageView (Transition)

-(void)setImage:(UIImage *)inNewImage withTransitionAnimation:(BOOL)inAnimation
{
    if (![[NSThread currentThread] isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setImage:inNewImage withTransitionAnimation:inAnimation];
        });
    }else
    {
        if (!inAnimation)
        {
            [self setImage:inNewImage];
        }
        else
        {
//        [UIView transitionWithView:self
//                          duration:0.5f
//                           options:UIViewAnimationOptionTransitionCrossDissolve
//                        animations:^{
//                            self.image = inNewImage;
//                        } completion:nil];

//        self.image = inNewImage;
//        CATransition *transition = [CATransition animation];
//        transition.duration = 0.5f;
//        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
//        transition.type = kCATransitionFade;
//        
//        [self.layer addAnimation:transition forKey:nil];

            //We are doing a different animation when self.image is nil to avoid a old image, that has not yet been rendered out, to appeare.
            if(self.image == nil || self.alpha == 0)
            {
                self.image = inNewImage;
                self.alpha = 0;
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.3f];
                self.alpha = 1;
                [UIView commitAnimations];
            }
            else{
                self.image = inNewImage;
                CATransition *transition = [CATransition animation];
                transition.duration = 0.3f;
                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
                transition.type = kCATransitionFade;
                [self.layer removeAnimationForKey:@"fade"];
                [self.layer addAnimation:transition forKey:@"fade"];
            }
        }
    }
}

-(void)setImage:(UIImage *)inNewImage withBackGroundColor:(UIColor *)bgColor withTransitionAnimation:(BOOL)inAnimation{
    if (!inAnimation)
    {
        [self setImage:inNewImage];
        self.backgroundColor = bgColor;
    }
    else
    {

//        [UIView transitionWithView:self
//                          duration:0.5f
//                           options:UIViewAnimationOptionTransitionCrossDissolve
//                        animations:^{
//                            self.image = inNewImage;
//                            self.backgroundColor = bgColor;
//                        } completion:nil];
        //The above is not able to do transition over background color and image change. Has been replased the the following:
        
        self.backgroundColor = bgColor;
        
        self.image = inNewImage;
        //[self setContentMode:UIViewContentModeScaleAspectFit];
        
        CATransition *transition = [CATransition animation];
        transition.duration = 0.5f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        [self.layer removeAnimationForKey:@"fade"];
        [self.layer addAnimation:transition forKey:@"fade"];
    }
}

-(void)showWithAnimation:(BOOL)animation{
    if (self.alpha != 1) {
        if (animation) {
            [UIView animateWithDuration:0.5 animations:^{
                [self setAlpha:1];
            }];
        }
        else
        {
            [self setAlpha:1];
        }
    }
    
}

-(void)hideWithAnimation:(BOOL)animation{
    if (self.alpha != 0) {
        if (animation) {
            [UIView animateWithDuration:0.5 animations:^{
                [self setAlpha:0];
            }];
        }
        else
        {
            [self setAlpha:0];
        }
    }
}

@end
