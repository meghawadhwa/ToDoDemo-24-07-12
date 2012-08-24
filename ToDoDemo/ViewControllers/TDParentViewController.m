//
//  TDParentViewController.m
//  ToDoDemo
//
//  Created by Megha Wadhwa on 24/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "TDParentViewController.h"

#import "TDDetailViewController.h"


@interface TDParentViewController ()
//- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation TDParentViewController

@synthesize managedObjectContext = __managedObjectContext;

@synthesize rows;
@synthesize tableViewRecognizer;
@synthesize grabbedObject;
//@synthesize doneOverlayView;
@synthesize goingDownByPullUp;
@synthesize parentName,childName;
@synthesize backgroundLabel;
@synthesize editingFlag;
@synthesize checkSound,deleteSound,deleteAlertSound,checkAlertSound,pullDownToCreateSound,pullDownToMoveUpSound,pullUpToMoveDownSound,pinchInSound,pinchOutSound,longPressSound,uncheckSound,navigateSound,pullUpToClearSound;
@synthesize topImage,bottomImage,parentTopImageView,parentBottomImageView;
@synthesize navigateFlag;
@synthesize backgroundView;
@synthesize playedPinchInSoundOnce;
- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    editingFlag = NO;
    // In this example, we setup self.rows as datasource
    self.rows = [NSMutableArray arrayWithObjects:
//                 @"Swipe to the right to complete",
//                 @"Swipe to left to delete",
//                 @"Drag down to create a new cell",
//                 @"Pinch two rows apart to create cell",
//                 @"Long hold to start reorder cell",
                 nil];
    
    [self setBackgroundWhenNoRows];
    [self setBackgroundForPinch];

    // Setup your tableView.delegate and tableView.datasource,
    // then enable gesture recognition in one line.
    self.tableViewRecognizer = [self.tableView enableGestureTableViewWithDelegate:self];
    self.tableViewRecognizer.extraPullDelegate = self;
    self.tableViewRecognizer.pinchDelegate = self;
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight       = NORMAL_CELL_FINISHING_HEIGHT;
    [self createSoundIdsForAllSounds];
}

- (void)setBackgroundForPinch{
    self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    self.backgroundView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.backgroundView];
}
- (void)setBackgroundWhenNoRows{
    self.backgroundLabel = [[UILabel alloc] initWithFrame:self.view.frame];
    self.backgroundLabel.backgroundColor = [UIColor clearColor];
    self.backgroundLabel.text = @"Pull Down To Get Started !!";
    self.backgroundLabel.textAlignment = UITextAlignmentCenter;
    self.backgroundLabel.textColor = [UIColor grayColor];
    self.backgroundLabel.hidden = YES;
    [self.view addSubview:self.backgroundLabel];
}

- (void)createSoundIdsForAllSounds{
    self.checkSound = [TDCommon createSoundID:kCheckSound];
    self.uncheckSound = [TDCommon createSoundID:kUncheckSound];
    self.deleteSound = [TDCommon createSoundID:kDeleteSound];
    self.pullDownToMoveUpSound = [TDCommon createSoundID:kPullDownToMoveUpSound];
    self.pullUpToMoveDownSound = [TDCommon createSoundID:kPullUpToMoveDownSound];
    self.pullDownToCreateSound = [TDCommon createSoundID:kPullDownToCreateSound];
    self.pinchInSound = [TDCommon createSoundID:kPinchInSound];
    self.pinchOutSound = [TDCommon createSoundID:kPinchOutSound];
    self.navigateSound = [TDCommon createSoundID:kNavigateSound];
    self.checkAlertSound = [TDCommon createSoundID:kCheckAlertSound];
    self.deleteAlertSound = [TDCommon createSoundID:kDeleteAlertSound];
    self.longPressSound = [TDCommon createSoundID:kLongPressSound];
    self.pullUpToClearSound = [TDCommon createSoundID:kPullUpToClearSound];
}

- (void)reloadTableData
{
    [self.tableView reloadData];
}

- (void)hideBackgroundView:(BOOL)hide{

    if (hide) {
        self.backgroundView.hidden = YES;
    }
    else {
        self.backgroundView.hidden = NO;
    }
}

#pragma mark UITableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
//    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.rows count] == 0) {
        self.backgroundLabel.hidden = NO;
    }
    else {
        self.backgroundLabel.hidden = YES;
    }
    return [self.rows count];
}


#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NORMAL_CELL_FINISHING_HEIGHT + 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.editingFlag == FALSE) 
    NSLog(@"tableView:didSelectRowAtIndexPath: %@", indexPath);
}

#pragma mark -
#pragma mark JTTableViewGestureAddingRowDelegate

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsDiscardRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.managedObjectContext rollback];
    [self.rows removeObjectAtIndex:indexPath.row];
}

// Uncomment to following code to disable pinch in to create cell gesture
//- (NSIndexPath *)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer willCreateCellAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == 0 && indexPath.row == 0) {
//        return indexPath;
//    }
//    return nil;
//}


-(void)updateRowDoneAtIndexpath :(NSIndexPath *)indexPath
{
         
}
#pragma mark JTTableViewGestureMoveRowDelegate

- (BOOL)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.editingFlag == TRUE) {
        return NO;
    }
    return YES;
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsCreatePlaceholderForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.grabbedObject = [self.rows objectAtIndex:indexPath.row];
    [self.rows replaceObjectAtIndex:indexPath.row withObject:DUMMY_CELL];
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsMoveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    id object = [self.rows objectAtIndex:sourceIndexPath.row];
    [self.rows removeObjectAtIndex:sourceIndexPath.row];
    [self.rows insertObject:object atIndex:destinationIndexPath.row];
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsReplacePlaceholderForRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.rows replaceObjectAtIndex:indexPath.row withObject:self.grabbedObject];
    [self updateAfterMovingToIndexpath:indexPath];
    self.grabbedObject = nil;
}

#pragma mark - Delegate methods
- (BOOL)animateImageViewsbydistance:(float)y
{
    return NO;
}

- (void)animateOuterImageViewsAfterCompleteInTime:(float)timeInterval
{
    
}
- (void)addSnapshotImageView:(UIImageView *)imageView
{
    [self.backgroundView addSubview:imageView];
}

- (void)changeBackgroundViewColor:(UIColor*)color
{
    self.backgroundView.backgroundColor = color;
}

- (void)updateAfterMovingToIndexpath:(NSIndexPath*)toIndexPath{
    
}

- (void)updateRowsAfterMovingFromIndexpath:(NSIndexPath *)indexPath ToIndexpath:(NSIndexPath*)toIndexPath{
    
}

- (float)getLastRowHeight
{
    float lastRowheight = 480;
    //    if ([self.checkedViewsArray lastObject]) {
    //        lastRowheight = [TDCommon getLastRowMaxYFromArray:self.checkedViewsArray];
    //    }
    //    else if([self.customViewsArray lastObject]){
    //        lastRowheight = [TDCommon getLastRowMaxYFromArray:self.customViewsArray];
    //    }
    lastRowheight = [self.rows count] * NORMAL_CELL_FINISHING_HEIGHT; 
    
    return lastRowheight;
}

#pragma mark - Extra pull Delegates

- (NSString *)getParentName
{
    return self.parentName;
}

- (NSString *)getChildName
{
    return self.childName;
}
#pragma mark - 
- (void)disableGesturesOnTable:(BOOL)disableFlag
{
    self.editingFlag = disableFlag;
}

#pragma mark-
- (void)fetchObjectsFromDb{
    
}
         
- (void)updateCurrentRowsDoneStatusAtIndexpath: (NSIndexPath *)indexpath{
             
}

- (BOOL)getCheckedStatusForRowAtIndex:(NSIndexPath *)indexPath{
    return NO;
}

-(void)rollBackInDBAndDeleteAtIndexPath:(NSIndexPath *)indexPath{
    [self deleteCurrentRowAtIndexpath:indexPath];
    [self.managedObjectContext rollback];
}

- (void)deleteNewRowAtIndexpath: (NSIndexPath *)indexpath{
    [self.rows removeObjectAtIndex:indexpath.row];
    [TDCommon playSound:self.deleteSound];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationLeft];
}

/*
 - (void)insertNewObject:(id)sender
 {
 NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
 NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
 NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
 
 // If appropriate, configure the new managed object.
 // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
 [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
 
 // Save the context.
 NSError *error = nil;
 if (![context save:&error]) {
 // Replace this implementation with code to handle the error appropriately.
 // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
 NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
 abort();
 }
 }
 */

#pragma mark - Table View
/*
  
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
 [self configureCell:cell atIndexPath:indexPath];
 return cell;
 }
 
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
 [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
 
 NSError *error = nil;
 if (![context save:&error]) {
 // Replace this implementation with code to handle the error appropriately.
 // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
 NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
 abort();
 }
 }   
 }
 
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // The table view should not be re-orderable.
 return NO;
 }
 
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 if ([[segue identifier] isEqualToString:@"showDetail"]) {
 NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
 NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
 [[segue destinationViewController] setDetailItem:object];
 }
 }
 */

#pragma mark - Fetched results controller


// - (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
// {
// [self.tableView beginUpdates];
// }
// 
// - (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
// atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
// {
// switch(type) {
// case NSFetchedResultsChangeInsert:
// [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
// break;
// 
// case NSFetchedResultsChangeDelete:
// [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
// break;
// }
// }
// 
// - (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
// atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
// newIndexPath:(NSIndexPath *)newIndexPath
// {
// UITableView *tableView = self.tableView;
// 
// switch(type) {
// case NSFetchedResultsChangeInsert:
// [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
// break;
// 
// case NSFetchedResultsChangeDelete:
// [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
// break;
// 
// case NSFetchedResultsChangeUpdate:
// [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
// break;
// 
// case NSFetchedResultsChangeMove:
// [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
// [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
// break;
// }
// }
 /*
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 [self.tableView endUpdates];
 }
 
*/

 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
// - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
// {
// // In the simplest, most efficient, case, reload the table view.
// [self.tableView reloadData];
// }


@end
