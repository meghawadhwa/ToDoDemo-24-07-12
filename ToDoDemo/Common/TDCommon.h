//
//  TDCommon.h
//  TD
//
//  Created by Megha Wadhwa on 13/03/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TDConstants.h"

@interface TDCommon : NSObject
+(UIColor *)getColorByPriority:(int)prioirity;
+(UIColor *)getBlueColorByPriority:(int)prioirity;
+(UIColor *)getRedColorByPriority:(int)prioirity;
+ (NSString *)getTheme;
+ (void)setTheme: (NSString *)myTheme;
+ (int)calculateLastIndexForArray:(NSMutableArray *)anyArray;
//+ (void)setDoneStatus:(TDListCustomRow *)RowSwiped;
+ (float)calculateDistanceBetweenTwoPoints:(CGPoint)firstPoint :(CGPoint)secondPoint;
//+ (float)getLastRowMaxYFromArray:(NSMutableArray *)AllViewsArray;

@end
