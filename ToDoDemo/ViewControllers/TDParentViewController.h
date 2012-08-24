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


//@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
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

@property(nonatomic,retain) UIImage *topImage;
@property(nonatomic,retain) UIImage *bottomImage;
@property(nonatomic,retain) UIImageView *parentTopImageView;
@property(nonatomic,retain) UIImageView *parentBottomImageView;
@property(nonatomic,assign) BOOL navigateFlag;
@property(nonatomic,retain) UIView *backgroundView;
@property(nonatomic,assign) BOOL playedPinchInSoundOnce;
-(void)addNewRowInDBAtIndexPath:(NSIndexPath *)indexpath;
- (void)fetchObjectsFromDb;
- (void)deleteCurrentRowAfterSwipeAtIndexpath: (NSIndexPath *)indexpath;
- (void)updateCurrentRowsDoneStatusAtIndexpath: (NSIndexPath *)indexpath;
- (BOOL)getCheckedStatusForRowAtIndex:(NSIndexPath *)indexPath;
- (void)reloadFromUpdatedDB;
- (float)getLastRowHeight;
- (void)updateRowDoneAtIndexpath :(NSIndexPath *)indexPath;
- (void)deleteNewRowAtIndexpath: (NSIndexPath *)indexpath;
- (void)updateRowsAfterMovingFromIndexpath:(NSIndexPath *)indexPath ToIndexpath:(NSIndexPath*)toIndexPath;
- (void)updateAfterMovingToIndexpath:(NSIndexPath*)toIndexPath;

@end
