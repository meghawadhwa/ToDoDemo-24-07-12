//
//  TDCommon.m
//  TD
//
//  Created by Megha Wadhwa on 13/03/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "TDCommon.h"

@implementation TDCommon

NSString *currentViewTheme = nil;
NSIndexPath *lastIndexPath = nil;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

//this method fetches the color based on the theme of the view selected
+(UIColor *)getColorByPriority:(int)prioirity
{
    UIColor *color;
    
    if ([currentViewTheme isEqualToString:THEME_BLUE]) {
    color = [TDCommon getBlueColorByPriority:prioirity];
    }
    else if ([currentViewTheme isEqualToString:THEME_HEAT_MAP])
    {
     color = [TDCommon getRedColorByPriority:prioirity];
    }
    else if ([currentViewTheme isEqualToString:THEME_MAIN_GRAY]) {
        color = [TDCommon getGrayColorByPriority:prioirity];
    }
   
    return color;
}

//this method provides grayColor varied by gradient based on its index/priority 
+(UIColor *)getGrayColorByPriority:(int)prioirity
{
    float red =  0.250; 
    float green = 0.250; 
    float blue = 0.250;  
    
    red -= 0.026 *prioirity/2;
    green -=0.026 *prioirity/2;
    blue -= 0.026 *prioirity/2;
    
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1];
    return color;
}

//this method provides blueColor varied by gradient based on its index/priority 
+(UIColor *)getBlueColorByPriority:(int)prioirity
{
    float red = 0.067;
    float green = 0.494;
    float blue = 0.980;

    red -=((prioirity == 1)? 0.004:0.008)*prioirity/2;
    green +=(0.028 +0.01 *prioirity)*prioirity/2;
    blue +=((prioirity %2 == 0)? 0 :0.004)*prioirity/2;
    
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1];
    return color;
}

//this method provides redColor varied by gradient based on its index/priority 
+(UIColor *)getRedColorByPriority:(int)prioirity
{
    float red =  0.851; 
    float green = 0.0; 
    float blue = 0.086;  
    
    red += 0.012 *prioirity/2;
    green +=0.113 *prioirity/2;
    blue += 0.004 *prioirity/2;
    
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1];
    return color;
}

#pragma mark -Utility methods
//calculates the distance between two points ,not used
+ (float)calculateDistanceBetweenTwoPoints:(CGPoint)firstPoint :(CGPoint)secondPoint
{
	CGFloat deltaX = secondPoint.x - firstPoint.x;
	CGFloat deltaY = secondPoint.y - firstPoint.y;
	return sqrt((deltaX*deltaX) + (deltaY*deltaY));
};

//this method is create a system sound
+ (SystemSoundID) createSoundID: (NSString*)name
{    
    //Get a URL for the sound file
    NSString *path = [NSString stringWithFormat: @"%@/%@",
                      [[NSBundle mainBundle] resourcePath], name];
    
    //Get the filename of the sound file:
    NSURL* filePath = [NSURL fileURLWithPath: path isDirectory: NO];
    //declare a system sound
    SystemSoundID soundID;
    //Use audio sevices to create the sound
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundID);
    return soundID;
} 

// this method plays the sound
+ (void)playSound:(SystemSoundID)soundId
{
    AudioServicesPlaySystemSound(soundId);
}

// this method returns the selected theme for the view
+ (NSString *)getTheme
{
    return currentViewTheme;
}

// this method sets the theme for the view
+ (void)setTheme: (NSString *)myTheme
{
    currentViewTheme = myTheme;
}

// this method sets last row indexpath
+ (void)setLastIndexPath:(NSIndexPath *)indexPath
{
    lastIndexPath = indexPath;
}

// this method returns last row indexpath
+(NSIndexPath *)getLastIndexPath{
    return lastIndexPath;
}

@end
