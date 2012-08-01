//
//  TDDelegates.h
//  ToDoDemo
//
//  Created by Megha Wadhwa on 01/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TDDelegates <NSObject>

@end

@protocol TDUpdateDbDelegate <NSObject>

- (void)updateCurrentRowAtIndexpath:(NSIndexpath *) indexpath;

@end

