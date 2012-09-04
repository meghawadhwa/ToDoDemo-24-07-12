//
//  TDDelegates.h
//  ToDoDemo
//
//  Created by Megha Wadhwa on 01/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TDCommon.h"

@protocol TDDelegates <NSObject>

@end

@protocol TDCreatingCellDelegate<NSObject>
-(void)addNewRowInDBAtIndexPath:(NSIndexPath *)indexpath ;
-(void)rollBackInDBAndDeleteAtIndexPath:(NSIndexPath *)indexPath;
@end

@protocol TDEditingCellDelegate<NSObject>
- (void)disableGesturesOnTable:(BOOL)disableFlag;
@end
@protocol TDUpdateDbDelegate<NSObject>
- (void)updateCurrentRowAtIndexpath: (NSIndexPath *)indexpath;
- (void)readjustCellFrameAtIndexpath: (NSIndexPath *)indexpath;
@end

@protocol TDDeleteFromDbDelegate<NSObject>
- (void)deleteCurrentRowAtIndexpath: (NSIndexPath *)indexpath;
@end

@protocol TDExtraPullDelegate<NSObject>
- (NSString *)getParentName;
- (NSString *)getChildName;
- (BOOL) checkedRowsExist;
- (int) getRowCount;
- (void) playSound;
- (void) deleteCheckedRows;
@end

@protocol TDPullUpToMoveDownDelegate<NSObject>
- (void)addChildView;
- (BOOL)lastVisitedListIsNotNil;
@end

@protocol TDPinchInToClose <NSObject>
- (BOOL)animateImageViewsbydistance:(float)y; 
- (void)addSnapshotImageView:(UIImageView *)imageView;
- (void)changeBackgroundViewColor:(UIColor*)color;
- (void)animateOuterImageViewsAfterCompleteInTime:(float)timeInterval;
- (void)hideBackgroundView:(BOOL)hide;
- (void)resetParentViews;
- (float)getTopViewOrigin;
@end
