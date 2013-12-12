//
//  UIImageView+Transition.h
//  CreationCommonLibrary
//
//  Created by Michael Rimestad on 5/8/13.
//  Copyright (c) 2013 Marcos Álvarez Mesa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImageView (Transition)

/**
 * Set the imageView `image` using a Transition.
 *
 * @param inNewImage The new image to animate to.
 * @param inAnimation If it should perform the transition as a animaion on just set the image.
 */
-(void)setImage:(UIImage *)inNewImage withTransitionAnimation:(BOOL)inAnimation;

-(void)setImage:(UIImage *)inNewImage withBackGroundColor:(UIColor *)bgColor withTransitionAnimation:(BOOL)inAnimation;

-(void)showWithAnimation:(BOOL)animation;
-(void)hideWithAnimation:(BOOL)animation;

@end
