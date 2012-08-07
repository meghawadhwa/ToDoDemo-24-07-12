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

@interface TDParentViewController : UITableViewController <JTTableViewGestureEditingRowDelegate, JTTableViewGestureAddingRowDelegate, JTTableViewGestureMoveRowDelegate,TDUpdateDbDelegate,TDDeleteFromDbDelegate>
@property (nonatomic, strong) NSMutableArray *rows;
@property (nonatomic, strong) JTTableViewGestureRecognizer *tableViewRecognizer;
@property (nonatomic, strong) id grabbedObject;


//@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property(nonatomic,assign) BOOL goingDownByPullUp;
@property(nonatomic,retain) NSString *parentName;
@property(nonatomic,retain) NSString *childName;

-(void)addNewRowInDBAtIndexPath:(NSIndexPath *)indexpath;
- (void)fetchObjectsFromDb;
- (void)deleteCurrentRowAfterSwipeAtIndexpath: (NSIndexPath *)indexpath;
- (void)updateCurrentRowsDoneStatusAtIndexpath: (NSIndexPath *)indexpath;
- (BOOL)getCheckedStatusForRowAtIndex:(NSIndexPath *)indexPath;
- (void)reloadFromUpdatedDB;
- (void)toggleSubViews:(BOOL)hide;
- (float)getLastRowHeight;

@end
