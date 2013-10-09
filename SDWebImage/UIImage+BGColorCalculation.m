//
//  UIImage+BGColorCalculation.m
//  SDWebImage
//
//  Created by Michael Rimestad on 5/1/13.
//  Copyright (c) 2013 Dailymotion. All rights reserved.
//

#import "UIImage+BGColorCalculation.h"

#define randomColorThreshold 2

@interface UIColor (DarkAddition)

- (BOOL)pc_isDarkColor;
- (BOOL)pc_isDistinct:(UIColor*)compareColor;
- (UIColor*)pc_colorWithMinimumSaturation:(CGFloat)saturation;
- (BOOL)pc_isBlackOrWhite;
- (BOOL)pc_isContrastingColor:(UIColor*)color;

@end

@interface CountedColor : NSObject

@property (assign) NSUInteger count;
@property (strong) UIColor *color;

- (id)initWithColor:(UIColor*)color count:(NSUInteger)count;

@end

@implementation UIImage (BGColorCalculation)

-(UIColor *)calcEdgeColor{
    
    UIColor *backgroundColor = [self _findEdgeColor];
    
    // If the random color threshold is too high and the image size too small,
    // we could miss detecting the background color and crash.
    if ( backgroundColor == nil )
    {
        backgroundColor = [UIColor whiteColor];
    }
    
    return backgroundColor;
}

typedef struct RGBAPixel
{
    Byte red;
    Byte green;
    Byte blue;
    Byte alpha;
    
} RGBAPixel;


- (UIColor*)_findEdgeColor //:(UIImage*)image imageColors:(NSCountedSet**)colors
{
	CGImageRef imageRep = self.CGImage;
    
    //	if ( ![imageRep isKindOfClass:[NSBitmapImageRep class]] ) // sanity check
    //		return nil;
    //NSInteger width = CGImageGetWidth(imageRep);// [imageRep pixelsWide];
//	NSInteger height = CGImageGetHeight(imageRep); //[imageRep pixelsHigh];
//    height ++;
//
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
    
    unsigned char *rawData = (unsigned char*) calloc(self.size.height * 1 * 4, sizeof(unsigned char));
    
    CGContextRef bmContext = CGBitmapContextCreate(rawData, 1, self.size.height, 8, 4 * 1, cs, (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(bmContext, (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = 1, .size.height = self.size.height}, imageRep);
    CGColorSpaceRelease(cs);
    NSCountedSet* edgeColors = [[NSCountedSet alloc] initWithCapacity:self.size.height];
    const RGBAPixel* pixels = (const RGBAPixel*)rawData;
    for (NSUInteger y = 0; y < self.size.height; y++)
    {
        RGBAPixel pixel = pixels[y];
        UIColor* color = [[UIColor alloc] initWithRed:((CGFloat)pixel.red / 255.0f) green:((CGFloat)pixel.green / 255.0f) blue:((CGFloat)pixel.blue / 255.0f) alpha:1.0f];
        [edgeColors addObject:color];
    }
    
    CGContextRelease(bmContext);
    free(rawData);
    //CGImageRelease(imageRep);
    
	NSEnumerator *enumerator = [edgeColors objectEnumerator];
	UIColor *curColor = nil;
	NSMutableArray *sortedColors = [NSMutableArray arrayWithCapacity:[edgeColors count]];
    
	while ( (curColor = [enumerator nextObject]) != nil )
	{
		NSUInteger colorCount = [edgeColors countForObject:curColor];
        
		if ( colorCount <= randomColorThreshold ) // prevent using random colors, threshold should be based on input image size
			continue;
        
		CountedColor *container = [[CountedColor alloc] initWithColor:curColor count:colorCount];
        
		[sortedColors addObject:container];
	}
    
	[sortedColors sortUsingSelector:@selector(compare:)];
    
    
	CountedColor *proposedEdgeColor = nil;
    
	if ( [sortedColors count] > 0 )
	{
		proposedEdgeColor = [sortedColors objectAtIndex:0];
        
		if ( [proposedEdgeColor.color pc_isBlackOrWhite] ) // want to choose color over black/white so we keep looking
		{
			for ( NSUInteger i = 1; i < [sortedColors count]; i++ )
			{
				CountedColor *nextProposedColor = [sortedColors objectAtIndex:i];
                
				if (((double)nextProposedColor.count / (double)proposedEdgeColor.count) > .4 ) // make sure the second choice color is 40% as common as the first choice
				{
					if ( ![nextProposedColor.color pc_isBlackOrWhite] )
					{
						proposedEdgeColor = nextProposedColor;
						break;
					}
				}
				else
				{
					// reached color threshold less than 40% of the original proposed edge color so bail
					break;
				}
			}
		}
	}
    
	return proposedEdgeColor.color;
}

@end

@implementation UIColor (DarkAddition)

- (BOOL)pc_isDarkColor
{
	UIColor *convertedColor = self;//[self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    
	CGFloat r, g, b, a;
    
	[convertedColor getRed:&r green:&g blue:&b alpha:&a];
    
	CGFloat lum = 0.2126 * r + 0.7152 * g + 0.0722 * b;
    
	if ( lum < .5 )
	{
		return YES;
	}
    
	return NO;
}


- (BOOL)pc_isDistinct:(UIColor*)compareColor
{
	UIColor *convertedColor = self;//[self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	UIColor *convertedCompareColor = compareColor;//[compareColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	CGFloat r, g, b, a;
	CGFloat r1, g1, b1, a1;
    
	[convertedColor getRed:&r green:&g blue:&b alpha:&a];
	[convertedCompareColor getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    
	CGFloat threshold = .25; //.15
    
	if ( fabs(r - r1) > threshold ||
		fabs(g - g1) > threshold ||
		fabs(b - b1) > threshold ||
		fabs(a - a1) > threshold )
    {
        // check for grays, prevent multiple gray colors
        
        if ( fabs(r - g) < .03 && fabs(r - b) < .03 )
        {
            if ( fabs(r1 - g1) < .03 && fabs(r1 - b1) < .03 )
                return NO;
        }
        
        return YES;
    }
    
	return NO;
}


- (UIColor*)pc_colorWithMinimumSaturation:(CGFloat)minSaturation
{
	UIColor *tempColor = self;//[self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    
	if ( tempColor != nil )
	{
		CGFloat hue = 0.0;
		CGFloat saturation = 0.0;
		CGFloat brightness = 0.0;
		CGFloat alpha = 0.0;
        
		[tempColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
        
		if ( saturation < minSaturation )
		{
			return [UIColor colorWithHue:hue saturation:minSaturation brightness:brightness alpha:alpha];
		}
	}
    
	return self;
}


- (BOOL)pc_isBlackOrWhite
{
	UIColor *tempColor = self;//[self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    
	if ( tempColor != nil )
	{
		CGFloat r, g, b, a;
        
		[tempColor getRed:&r green:&g blue:&b alpha:&a];
        
		if ( r > .91 && g > .91 && b > .91 )
			return YES; // white
        
		if ( r < .09 && g < .09 && b < .09 )
			return YES; // black
	}
    
	return NO;
}


- (BOOL)pc_isContrastingColor:(UIColor*)color
{
	UIColor *backgroundColor = self;//[self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	UIColor *foregroundColor = color;//[color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    
	if ( backgroundColor != nil && foregroundColor != nil )
	{
		CGFloat br, bg, bb, ba;
		CGFloat fr, fg, fb, fa;
        
		[backgroundColor getRed:&br green:&bg blue:&bb alpha:&ba];
		[foregroundColor getRed:&fr green:&fg blue:&fb alpha:&fa];
        
		CGFloat bLum = 0.2126 * br + 0.7152 * bg + 0.0722 * bb;
		CGFloat fLum = 0.2126 * fr + 0.7152 * fg + 0.0722 * fb;
        
		CGFloat contrast = 0.;
        
		if ( bLum > fLum )
			contrast = (bLum + 0.05) / (fLum + 0.05);
		else
			contrast = (fLum + 0.05) / (bLum + 0.05);
        
		//return contrast > 3.0; //3-4.5
		return contrast > 1.6;
	}
    
	return YES;
}


@end

@implementation CountedColor

- (id)initWithColor:(UIColor*)color count:(NSUInteger)count
{
	self = [super init];
    
	if ( self )
	{
		self.color = color;
		self.count = count;
	}
    
	return self;
}

- (NSComparisonResult)compare:(CountedColor*)object
{
	if ( [object isKindOfClass:[CountedColor class]] )
	{
		if ( self.count < object.count )
		{
			return NSOrderedDescending;
		}
		else if ( self.count == object.count )
		{
			return NSOrderedSame;
		}
	}
    
	return NSOrderedAscending;
}


@end
