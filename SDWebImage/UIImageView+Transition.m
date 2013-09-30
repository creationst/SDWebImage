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
    if (!inAnimation)
    {
        [self setImage:inNewImage];
    }
    else
    {
        [UIView transitionWithView:self
                          duration:0.5f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            self.image = inNewImage;
                        } completion:nil];
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
        [self setContentMode:UIViewContentModeScaleAspectFit];
        
        CATransition *transition = [CATransition animation];
        transition.duration = 0.5f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        
        [self.layer addAnimation:transition forKey:nil];
    }
}

@end
