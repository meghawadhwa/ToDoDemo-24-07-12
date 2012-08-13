//
//  TDStrikedLabel.m
//  TD
//
//  Created by Megha Wadhwa on 09/03/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "TDStrikedLabel.h"

@implementation TDStrikedLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect{
    [super drawTextInRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context,CGRectMake(0,rect.size.height/2,rect.size.width,1));
}



@end
