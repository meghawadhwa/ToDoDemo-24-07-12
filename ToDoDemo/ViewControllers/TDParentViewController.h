//
//  TDParentViewController.h
//  ToDoDemo
//
//  Created by Megha Wadhwa on 24/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ToDoList.h"
#import "ToDoItem.h"
#import "TransformableTableViewCell.h"
#import "JTTableViewGestureRecognizer.h"
#import "UIColor+JTGestureBasedTableViewHelper.h"
#import <CoreData/CoreData.h>
#import "TDDelegates.h"
#import "TDConstants.h"
#import "TDCommon.h"
#import <QuartzCore/QuartzCore.h>

@interface TDParentViewController : UITableViewController <JTTableViewGestureEditingRowDelegate, JTTableViewGestureAddingRowDelegate,TDUpdateDbDelegate,TDDeleteFromDbDelegate,TDExtraPullDelegate,TDEditingCellDelegate,TDCreatingCellDelegate,JTTableViewGestureMoveRowDelegate,TDPinchInToClose>
@property (nonatomic, strong) NSMutableArray *rows;
@property (nonatomic, strong) JTTableViewGestureRecognizer *tableViewRecognizer;
@property (nonatomic, strong) id grabbedObject;


@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property(nonatomic,assign) BOOL goingDownByPullUp;
@property(nonatomic,assign) BOOL editingFlag;
@property(nonatomic,retain) NSString *parentName;
@property(nonatomic,retain) NSString *childName;
@property(nonatomic,retain) UILabel *backgroundLabel;
@property(nonatomic,assign) SystemSoundID checkSound;
@property(nonatomic,assign) SystemSoundID uncheckSound;
@property(nonatomic,assign) SystemSoundID deleteSound;
@property(nonatomic,assign) SystemSoundID pullUpToClearSound;
@property(nonatomic,assign) SystemSoundID pullUpToMoveDownSound;
@property(nonatomic,assign) SystemSoundID pullDownToMoveUpSound;
@property(nonatomic,assign) SystemSoundID navigateSound;
@property(nonatomic,assign) SystemSoundID deleteAlertSound;
@property(nonatomic,assign) SystemSoundID checkAlertSound;
@property(nonatomic,assign) SystemSoundID pullDownToCreateSound;
@property(nonatomic,assign) SystemSoundID pinchOutSound;
@property(nonatomic,assign) SystemSoundID pinchInSound;
@property(nonatomic,assign) SystemSoundID longPressSound;
@property(nonatomic,retain) UIImageView *parentOverTopImageView;

@property(nonatomic,retain) UIImage *topImage;
@property(nonatomic,retain) UIImage *bottomImage;
@property(nonatomic,retain) UIImageView *parentTopImageView;
@property(nonatomic,retain) UIImageView *parentBottomImageView;
@property(nonatomic,assign) BOOL navigateFlag;
@property(nonatomic,retain) UIView *backgroundView;
@property(nonatomic,assign) BOOL playedPinchInSoundOnce;
@property(nonatomic,retain) UIImage *overTopImage;
@property(nonatomic,retain) NSIndexPath * grabbedIndex;
-(void)addNewRowInDBAtIndexPath:(NSIndexPath *)indexpath withModelType:(TDModelType )modelType;
- (void)updateCurrentRowAtIndexpath: (NSIndexPath *)indexpath withModelType:(TDModelType )modelType;
- (void)deleteCurrentRowAtIndexpath: (NSIndexPath *)indexpath withModelType:(TDModelType )modelType;
- (void)updateRowsFromIndexPath:(NSIndexPath *)indexPath withModelType:(TDModelType )modelType withCreationFlag:(BOOL)creationFlag;

- (void)deleteCurrentRowAfterSwipeAtIndexpath: (NSIndexPath *)indexpath;
- (void)updateCurrentRowsDoneStatusAtIndexpath: (NSIndexPath *)indexpath;
- (BOOL)getCheckedStatusForRowAtIndex:(NSIndexPath *)indexPath;
- (void)reloadTableData;
- (float)getLastRowHeight;
- (void)updateRowDoneAtIndexpath :(NSIndexPath *)indexPath;
- (void)deleteNewRowAtIndexpath: (NSIndexPath *)indexpath;
- (void)updateRowsAfterMovingFromIndexpath:(NSIndexPath *)indexPath ToIndexpath:(NSIndexPath*)toIndexPath;
- (void)updateAfterMovingToIndexpath:(NSIndexPath*)toIndexPath;

- (void) removeCurrentView;

//adding 

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsCommitRowAtIndexPath:(NSIndexPath *)indexPath withModelType:(TDModelType )modelType;
- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsDiscardRowAtIndexPath:(NSIndexPath *)indexPath withModelType:(TDModelType )modelType;

// parent views
- (void)placeParentImageViews;
- (void)animateParentViews;
- (void)setInitialFramesForParentImages;
@end

@interface TDParentViewController (TDItem)
- (void)createNewItem:(ToDoItem *)newItem atIndexPath:(NSIndexPath *)indexPath;
- (void)updateNewItem:(ToDoItem *)newItem atIndex:(int)index;
- (void)deleteItemFromIndexPath:(NSIndexPath *)indexPath;
- (void)updateArraysAfterDeletionOrInsertionFromIndexpath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath*) toIndexPath;
@end
