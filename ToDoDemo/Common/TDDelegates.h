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

@protocol TDCreatingCellDelegate<NSObject>
-(void)addNewRowInDBAtIndexPath:(NSIndexPath *)indexpath;
-(void)rollBackInDBAndDeleteAtIndexPath:(NSIndexPath *)indexPath;
@end

@protocol TDEditingCellDelegate<NSObject>
- (void)disableGesturesOnTable:(BOOL)disableFlag;
@end
@protocol TDUpdateDbDelegate<NSObject>
- (void)updateCurrentRowAtIndexpath: (NSIndexPath *)indexpath;

@end

@protocol TDDeleteFromDbDelegate<NSObject>
- (void)deleteCurrentRowAtIndexpath: (NSIndexPath *)indexpath;
@end

@protocol TDExtraPullDelegate<NSObject>
- (NSString *)getParentName;
- (NSString *)getChildName;
@end

@protocol TDPullUpToMoveDownDelegate<NSObject>
- (void)addChildView;
- (BOOL)lastVisitedListIsNotNil;
@end