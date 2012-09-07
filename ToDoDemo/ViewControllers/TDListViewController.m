//
//  TDListViewController.m
//  ToDoDemo
//
//  Created by Megha Wadhwa on 26/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TDListViewController.h"
#import "TDItemViewController.h"

@interface TDListViewController ()

@end

@implementation TDListViewController
@synthesize rowIndexToBeUpdated,rowIndexToBeDeleted;
@synthesize lastVisitedList;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.lastVisitedList = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchObjectsFromDb];
    [TDCommon setTheme:THEME_BLUE];
    self.tableViewRecognizer.pullUpToMoveDownDelegate = self;
    [self placeParentImageViews];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark-
#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSObject *object;
    ToDoList *list;
    if ([[self.rows objectAtIndex:indexPath.row]isEqual:DUMMY_CELL]) {
        object = [self.rows objectAtIndex:indexPath.row];
    }
    else {
        list = [self.rows objectAtIndex:indexPath.row];
        object = list.listName;
    }
    UIColor *backgroundColor = [TDCommon getColorByPriority:indexPath.row];
    if ([object isEqual:ADDING_CELL]) {
        NSString *cellIdentifier = nil;
        TransformableTableViewCell *cell = nil;
        
        // IndexPath.row == 0 is the case we wanted to pick the pullDown style
        if (indexPath.row == 0) {
            cellIdentifier = @"PullDownTableViewCell";
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if (cell == nil) {
                cell = [TransformableTableViewCell transformableTableViewCellWithStyle:TransformableTableViewCellStylePullDown
                                                                       reuseIdentifier:cellIdentifier];
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
                cell.textLabel.textColor = [UIColor whiteColor];
                cell.textLabel.textAlignment = UITextAlignmentCenter;
            }
            
            cell.finishedHeight = COMMITING_CREATE_CELL_HEIGHT;
            if (cell.frame.size.height > COMMITING_CREATE_CELL_HEIGHT * 3) {
                cell.imageView.image = [UIImage imageNamed:@"arrow-up.png"];
                cell.tintColor = [UIColor blackColor];
                cell.textLabel.text = [NSString stringWithFormat:@"Return to %@",self.parentName];
                cell.nameTextField.text = cell.textLabel.text;
            } else if (cell.frame.size.height > COMMITING_CREATE_CELL_HEIGHT) {
                cell.imageView.image = nil;
                // Setup tint color
                cell.tintColor = backgroundColor;
                cell.textLabel.text = @"Release to insert new list";
                cell.nameTextField.text = cell.textLabel.text;
            } else {
                cell.textLabel.text = @"Pull Down To Create new list";
                cell.imageView.image = nil;
                // Setup tint color
                cell.tintColor = backgroundColor;
            }
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.detailTextLabel.text = @" ";
            return cell;
            
        } else {
            // Otherwise is the case we wanted to pick the pullDown style
            cellIdentifier = @"UnfoldingTableViewCell";
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if (cell == nil) {
                cell = [TransformableTableViewCell transformableTableViewCellWithStyle:TransformableTableViewCellStyleUnfolding
                                                                       reuseIdentifier:cellIdentifier];
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
                cell.textLabel.textColor = [UIColor whiteColor];
                cell.textLabel.textAlignment = UITextAlignmentCenter;
            }
            
            // Setup tint color
            cell.tintColor = backgroundColor;
            
            cell.finishedHeight = COMMITING_CREATE_CELL_HEIGHT;
            if (cell.frame.size.height > COMMITING_CREATE_CELL_HEIGHT) {
                cell.textLabel.text = @"Release to create cell...";
            } else {
                cell.textLabel.text = @"Continue Pinching...";
            }
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.detailTextLabel.text = @" ";
            return cell;
        }
        
    } else {
        
        static NSString *cellIdentifier = @"DefaultTableViewCell";
        TransformableTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [TransformableTableViewCell transformableTableViewCellWithStyle:TransformableTableViewCellStyleDefaultWithCount reuseIdentifier:cellIdentifier];
            cell.textLabel.adjustsFontSizeToFitWidth = NO;
            CGRect frame = cell.textLabel.frame;
            CGSize textSize = [cell.textLabel.text sizeWithFont:[cell.textLabel font]];
            frame.size.width = textSize.width + 5;
            frame.size.height = textSize.height + 5;
            cell.textLabel.frame = frame;
            //[cell.contentView bringSubviewToFront:cell.detailTextLabel];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.updateDelegate = self;
            cell.deleteDelegate = self;
            cell.createDelegate = self;
        }
       
        if (![object isEqual:DUMMY_CELL]) {
            cell.countLabel.backgroundColor = [TDCommon getColorByPriority:(2+indexPath.row)];
            cell.countLabel.text = [NSString stringWithFormat:@"%d",[self getUncheckedItemsFromList:list]];
            cell.textLabel.text = [NSString stringWithFormat:@"%@", (NSString *)object];
            cell.detailTextLabel.text = @" ";
        }
        
        if ([cell.countLabel.text isEqualToString:@"0"] && ![object isEqual:DUMMY_CELL]) {
            cell.textLabel.hidden = NO;
            cell.textLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
            cell.countLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
            cell.contentView.backgroundColor = backgroundColor;
        } else if ([object isEqual:DUMMY_CELL]) {
            cell.textLabel.text = @"";
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.countLabel.backgroundColor = [UIColor clearColor];
            cell.countLabel.text = @"";
        } else {
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.countLabel.textColor = [ UIColor whiteColor];
            cell.contentView.backgroundColor = backgroundColor;
        }
        cell.editingDelegate = self;
        return cell;
    }
    
}
// this method is called after editing a list name ,to readjust its width
- (void)readjustCellFrameAtIndexpath: (NSIndexPath*) indexpath{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexpath];
    CGRect frame = cell.textLabel.frame;
    CGSize textSize = [cell.textLabel.text sizeWithFont:[cell.textLabel font]];
    frame.size.width = ((textSize.width + 5 ) > 260.0) ? 260.0 :(textSize.width + 5 );
    frame.size.height = textSize.height + 5;
    cell.textLabel.frame = frame;
}

//this method gets the unchecked items from list set of items while table is populated
-(int)getUncheckedItemsFromList:(ToDoList *)list
{
    int count = 0;
    for (ToDoItem *item in list.items) {
        if ([item.doneStatus isEqualToNumber:[NSNumber numberWithBool:FALSE]]) {
            count ++;
        }
    }
    return count;
}

//this is to get the item count for a single indexpath while refreshing a single row after coming back
- (int)getItemCountForIndexpath:(NSIndexPath *)indexPath
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity: [NSEntityDescription entityForName:@"ToDoItem" inManagedObjectContext: self.managedObjectContext]];
    ToDoList *list = [self.rows objectAtIndex:indexPath.row];
    NSError *error = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"doneStatus == %@ AND list == %@",[NSNumber numberWithInt:0],list];
    [request setPredicate:predicate];
    NSUInteger count = [self.managedObjectContext countForFetchRequest:request error: &error];
    NSLog(@"count %d",count);  
    if (count >0 && [list.doneStatus isEqual:[NSNumber numberWithBool:TRUE]]) {
        [self refreshCurrentRowsDoneStatusAtIndexpath:indexPath];   
    }
    return count;
}

//this is change the done status of the to-do list
- (void)refreshCurrentRowsDoneStatusAtIndexpath: (NSIndexPath *)indexPath
{
    ToDoList *list = [self.rows objectAtIndex:indexPath.row];
    list.doneStatus = [NSNumber numberWithBool:FALSE];
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error in refreshing done status of items within the list %@, %@", error, [error userInfo]);
        abort();
    } 
      // do we need to fetch lists again? 
}

#pragma mark-
//this is fetch from db when view is loaded 
- (void)fetchObjectsFromDb
{
    // Test listing all ToDoList from the store
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ToDoList"
                                              inManagedObjectContext:self.managedObjectContext];
   
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"priority" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    self.rows = [NSMutableArray arrayWithArray:fetchedObjects];
    for (ToDoList *lists in fetchedObjects) {
        NSLog(@"Name: %@ Priority %d", lists.listName,[lists.priority intValue]);
    }  
}

//this method checks all items in a list
- (void)checkAllItemsForSelectedList
{
    ToDoList *list = [self.rows objectAtIndex:self.rowIndexToBeUpdated];
    for (ToDoItem *item in list.items) {
        if ([ item.doneStatus isEqual:[NSNumber numberWithBool:FALSE]]) {
            item.doneStatus = [NSNumber numberWithBool:TRUE];
        }
    }
    //OR
    //[list.items makeObjectsPerformSelector:@selector(setDoneStatus:) withObject:[NSNumber numberWithBool:TRUE]];
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error in saving done status of items within the list %@, %@", error, [error userInfo]);
        abort();
    } 
    
}
// this method add a new row in db
-(void)addNewRowInDBAtIndexPath:(NSIndexPath *)indexpath
 {
     [self addNewRowInDBAtIndexPath:indexpath withModelType:TDModelList];
}

// update the rows to checked if it is swiped to left
- (void)updateCurrentRowsDoneStatusAtIndexpath: (NSIndexPath *)indexpath
{
     NSError *error = nil;
    ToDoList * list = [self.rows objectAtIndex:indexpath.row];
    if ([list.doneStatus isEqual:[NSNumber numberWithBool:FALSE]]) {
        TransformableTableViewCell *cell = (TransformableTableViewCell*)[self.tableView cellForRowAtIndexPath:indexpath];
        if (![cell.countLabel.text isEqualToString:@"0"])
        {
            self.rowIndexToBeUpdated = indexpath.row;
            self.rowIndexToBeDeleted = -1;
            [TDCommon playSound:self.checkAlertSound];
            [self createActionSheetWithTitle:@"Are you sure you want to complete all items within this list?" andDestructiveButtonTitle:@"Complete"];
        }
        else {
//            [TDCommon playSound:self.checkSound];
            list.doneStatus = [NSNumber numberWithBool:TRUE];
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"Error in updating a list %@, %@", error, [error userInfo]);
                abort();
            }
        }
    }
    else {
        list.doneStatus = [NSNumber numberWithBool:FALSE];
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Error in updating a list %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)updateCurrentRowAtIndexpath: (NSIndexPath *)indexpath
{
    [self updateCurrentRowAtIndexpath:indexpath withModelType:TDModelList];
}

// This when we edit the list name to empty,it deletes the list but presents an alert if a list to be deleted already has items
- (void)deleteCurrentRowAtIndexpath: (NSIndexPath *)indexpath
{
    [self deleteCurrentRowAfterSwipeAtIndexpath:indexpath];
   
    TransformableTableViewCell *cell = (TransformableTableViewCell*)[self.tableView cellForRowAtIndexPath:indexpath];
    if (self.rowIndexToBeDeleted >=0  && ![cell.countLabel.text isEqualToString:@"0"]) {
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationRight];
    }else {
    }
}

//This deletes the current row after swipe left,presents an alert if it has unchecked items to do 
- (void)deleteCurrentRowAfterSwipeAtIndexpath: (NSIndexPath *)indexpath
{
    TransformableTableViewCell *cell = (TransformableTableViewCell*)[self.tableView cellForRowAtIndexPath:indexpath];
    if (![cell.countLabel.text isEqualToString:@"0"])
    {
        self.rowIndexToBeUpdated = -1;
        self.rowIndexToBeDeleted = indexpath.row;
        [TDCommon playSound:self.deleteAlertSound];
        [self createActionSheetWithTitle:@"Are you sure you want to delete all items within this list?" andDestructiveButtonTitle:@"Delete"];
    }
    else {
        [self deleteCurrentRowAtIndexpath:indexpath withModelType:TDModelList];
        [self updateRowsFromIndexPath:indexpath withModelType:TDModelList withCreationFlag:NO];
    }
}

#pragma mark - action sheet delegates
- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSIndexPath *indexPath;
    if (buttonIndex == 0) {
        // To be updated
        if (self.rowIndexToBeUpdated >= 0) {
            [TDCommon playSound:self.checkSound];
        ToDoList *list = [self.rows objectAtIndex:self.rowIndexToBeUpdated];
        list.doneStatus = [NSNumber numberWithBool:TRUE];
        [self checkAllItemsForSelectedList];
            indexPath = [NSIndexPath indexPathForRow:self.rowIndexToBeUpdated inSection:0]; 
            [self refreshCountForRowWithIndexPath:indexPath];
        }
        else if(self.rowIndexToBeDeleted >= 0){ 
            indexPath = [NSIndexPath indexPathForRow:self.rowIndexToBeDeleted inSection:0]; 
            [self deleteCurrentRowAtIndexpath:indexPath withModelType:TDModelList];
            [self updateRowsFromIndexPath:indexPath withModelType:TDModelList withCreationFlag:NO];
        }
    }
}

#pragma mark- Delegates
#pragma mark JTTableViewGestureEditingRowDelegate

// This is needed to be implemented to work after panning gesture completion

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer commitEditingState:(JTTableViewCellEditingState)state forRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableView *tableView = gestureRecognizer.tableView;
    if (state == JTTableViewCellEditingStateLeft) {
    }
    [tableView beginUpdates];
    if (state == JTTableViewCellEditingStateLeft) {
        // An example to discard the cell at JTTableViewCellEditingStateLeft
        [self deleteCurrentRowAfterSwipeAtIndexpath:indexPath];
        TransformableTableViewCell *cell = (TransformableTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        
        if (self.rowIndexToBeDeleted >=0  && ![cell.countLabel.text isEqualToString:@"0"]) {
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
        }

    } else if (state == JTTableViewCellEditingStateRight) {
        // An example to retain the cell at commiting at JTTableViewCellEditingStateRight
        [self updateCurrentRowsDoneStatusAtIndexpath:indexPath]; 
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    } else {
        // JTTableViewCellEditingStateMiddle shouldn't really happen in
        // - [JTTableViewGestureDelegate gestureRecognizer:commitEditingState:forRowAtIndexPath:]
    }
    [tableView endUpdates];
    
    // Row color needs update after datasource changes, reload it.
    [tableView performSelector:@selector(reloadVisibleRowsExceptIndexPath:) withObject:indexPath afterDelay:JTTableViewRowAnimationDuration];
    if (state == JTTableViewCellEditingStateRight) 
    {
        [self performSelector:@selector(updateRowDoneAtIndexpath:) withObject:indexPath afterDelay:0.5];
    }
    else if (state == JTTableViewCellEditingStateRight) {
        [self performSelector:@selector(reloadTableData) withObject:nil afterDelay:0.1];

    }
}

// when starts panning,changes the color
- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer didEnterEditingState:(JTTableViewCellEditingState)state forRowAtIndexPath:(NSIndexPath *)indexPath {
UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//BOOL checked = [self getCheckedStatusForRowAtIndex:indexPath];
UIColor *backgroundColor = nil;
switch (state) {
    case JTTableViewCellEditingStateMiddle:
            backgroundColor = [TDCommon getColorByPriority:indexPath.row];
        break;
    case JTTableViewCellEditingStateRight:
        backgroundColor = [UIColor greenColor];
        break;
    default:
            backgroundColor = [TDCommon getColorByPriority:indexPath.row];
        break;
}
cell.contentView.backgroundColor = backgroundColor;
if ([cell isKindOfClass:[TransformableTableViewCell class]]) {
    ((TransformableTableViewCell *)cell).tintColor = backgroundColor;
}
}


#pragma mark -
#pragma mark JTTableViewGestureAddingRowDelegate
// adds a model object to table array
- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsAddRowAtIndexPath:(NSIndexPath *)indexPath {
    ToDoList *newList = (ToDoList *)[NSEntityDescription insertNewObjectForEntityForName:@"ToDoList"
                                                                  inManagedObjectContext:self.managedObjectContext];
    newList.listName = ADDING_CELL;
    
    newList.priority = [NSNumber numberWithInt:indexPath.row];
    newList.doneStatus = [NSNumber numberWithBool:FALSE];
    [self.rows insertObject:newList atIndex:indexPath.row];
}

//commits after creating a new cell
- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsCommitRowAtIndexPath:(NSIndexPath *)indexPath {
    [self gestureRecognizer:gestureRecognizer needsCommitRowAtIndexPath:indexPath withModelType:TDModelList];
}

// tells if the list is completed or not
- (BOOL)getCheckedStatusForRowAtIndex:(NSIndexPath *)indexPath
{
 ToDoList *currentList = [self.rows objectAtIndex:indexPath.row];
    return [currentList.doneStatus boolValue];
}

#pragma mark- move Rows, changing priority
- (void)updateAfterMovingToIndexpath:(NSIndexPath*)toIndexPath{
    [self updateRowsAfterMovingFromIndexpath:self.grabbedIndex ToIndexpath:toIndexPath];
}
//this upates the rows after moving it to a new location 
- (void)updateRowsAfterMovingFromIndexpath:(NSIndexPath *)indexPath ToIndexpath:(NSIndexPath*)toIndexPath
{
    int fromIndex,toIndex;
    if (indexPath.row > toIndexPath.row) {
        fromIndex = toIndexPath.row;
        toIndex = indexPath.row;
    }
    else {
        fromIndex = indexPath.row;
        toIndex = toIndexPath.row;
    }
    for (int index = fromIndex; index<= toIndex; index++) {
        if (fromIndex == toIndex) break;
        ToDoList *list = [self.rows objectAtIndex:index];
        list.priority = [NSNumber numberWithInt:index];
        NSLog(@"updating priority %@ %i",list.listName,[list.priority intValue]);
    }
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error in updating a item's done status%@, %@", error, [error userInfo]);
        abort();
    }
}

#pragma mark - Table view delegate
//this method is to decide wheather to show the pull up view to move down
- (BOOL)lastVisitedListIsNotNil
{
    return (self.lastVisitedList !=nil);
}

//this mothod is to push the next view onvce pull up to move down is detected
- (void)addChildView
{
    if (!lastVisitedList) {
        return;
    }
    [TDCommon playSound:self.pullUpToMoveDownSound];
    TDListViewController *src = (TDListViewController *) self;
    TDItemViewController *destination = [self.storyboard instantiateViewControllerWithIdentifier:@"ItemViewController"];
    destination.parentName = @"Lists";
    destination.parentList = lastVisitedList;
    destination.childName = nil;
    destination.goingDownByPullUp = YES;
    destination.managedObjectContext = self.managedObjectContext;
    [UIView animateWithDuration:BACK_ANIMATION delay:BACK_ANIMATION_DELAY options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect myFrame = self.view.frame;
        myFrame.origin.y = -480;
        self.view.frame = myFrame; 
    } completion:^ (BOOL finished) {
        [src.navigationController pushViewController:destination animated:NO];
        CGRect myFrame = self.view.frame;
        myFrame.origin.y = 0;
        self.view.frame = myFrame; 
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editingFlag == FALSE && [[self.rows objectAtIndex:indexPath.row] isKindOfClass:[ToDoList class]]) {
        [TDCommon playSound:self.navigateSound];
    TDListViewController *src = (TDListViewController *) self;
    TDItemViewController *destination = [self.storyboard instantiateViewControllerWithIdentifier:@"ItemViewController"];
    ToDoList *list = [self.rows objectAtIndex:indexPath.row];
    src.childName = list.listName;
    destination.childName = nil;
    src.lastVisitedList = list;
    [TDCommon setLastIndexPath:indexPath];
    destination.parentList = list;
    destination.parentName = @"Lists";
    destination.topImage = [self createSnapShotOfCellAtIndexPath:indexPath];
    destination.bottomImage = [self createSnapShotOfViewAfterCellAtIndexPath:indexPath];
    if (indexPath.row !=0) {
        destination.overTopImage = [self createSnapShotOfViewBeforeCellAtIndexPath:indexPath];
    }
    else {
        destination.overTopImage = nil;
    }
        destination.navigateFlag = YES;
    destination.goingDownByPullUp = NO;
    src.goingDownByPullUp = NO;
    destination.managedObjectContext = self.managedObjectContext;
    [src.navigationController pushViewController:destination animated:NO];
    }
}

#pragma mark- view related
//creates sanpshots of parent to pass onto the list
-(UIImage *)createSnapShotOfCellAtIndexPath:(NSIndexPath *)indexPath{    
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIGraphicsBeginImageContextWithOptions(cell.bounds.size, NO, 0);
    [cell.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *cellImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return cellImage;
}

-(UIImage *)createSnapShotOfViewAfterCellAtIndexPath:(NSIndexPath *)indexPath{ 
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
    CGRect rect = CGRectMake(0,CGRectGetMaxY(cell.frame), 320, self.tableView.contentSize.height - CGRectGetMaxY(cell.frame));
    NSLog(@"rect : %f  %fcontent size %f content offset y  %f",rect.origin.y, rect.size.height,self.tableView.contentSize.height, self.tableView.contentOffset.y);
    return [self createSnapshotOfRect:rect];
}

-(UIImage *)createSnapShotOfViewBeforeCellAtIndexPath:(NSIndexPath *)indexPath{ 
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
    CGRect rect = CGRectMake(0, 0, 320, CGRectGetMinY(cell.frame));
    NSLog(@"rect : %f %f",rect.origin.y, rect.size.height);

    return [self createSnapshotOfRect:rect];
}

- (UIImage *)createSnapshotOfRect:(CGRect)rect{
    UIGraphicsBeginImageContext(rect.size);
    [self.tableView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
       CGImageRef subImageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    CGRect smallBounds = CGRectMake(rect.origin.x, rect.origin.y, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    UIGraphicsEndImageContext();

    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImg = [UIImage imageWithCGImage:subImageRef];
    CGImageRelease(subImageRef);
    UIGraphicsEndImageContext();
    return smallImg;
}

- (void)createActionSheetWithTitle:(NSString *)title andDestructiveButtonTitle:(NSString *)destructiveButtonTitle
{
    UIActionSheet *completeListActionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:nil];
    [completeListActionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    [completeListActionSheet showInView:self.view];
}

- (void)viewWillAppear:(BOOL)animated
{
    [TDCommon setTheme:THEME_BLUE];   
    self.tableView.hidden = YES;
    self.rowIndexToBeUpdated = -1;
    self.rowIndexToBeDeleted = -1;
}

//this method is called after coming back from child view to refresh only that lists item count
- (void)refreshCountForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath != nil) {
        TransformableTableViewCell *cell = (id)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.countLabel.text = [NSString stringWithFormat:@"%d",[self getItemCountForIndexpath:indexPath]];
        if ([cell.countLabel.text isEqualToString:@"0"]) {
        cell.textLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
        cell.countLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
        }
        else {
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.countLabel.textColor = [ UIColor whiteColor];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.goingDownByPullUp) {
        [UIView animateWithDuration:0.0 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{  
            CGRect myFrame = self.view.frame;
            myFrame.origin.y = 480;
            self.view.frame = myFrame;
        } completion:^(BOOL fin){
            [UIView animateWithDuration:0.6 delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [self.tableView setHidden:NO];
                CGRect myFrame = self.view.frame;
                myFrame.origin.y = 0.0;
                self.view.frame = myFrame;
            } 
                             completion: nil];
        }];
        self.goingDownByPullUp = NO;
    }
    else if (self.navigateFlag == YES) {
        self.tableView.hidden = NO;
        [self animateParentViews];
        self.navigateFlag = NO;
    }
    else {
//        [self.tableView reloadData];
//        float originY = [self getLastRowHeight];
//        [UIView animateWithDuration:0.0 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{  
//            CGRect myFrame = self.view.frame;
//            myFrame.origin.y = -originY;
//            self.view.frame = myFrame;
//        } completion:^(BOOL fin){
//            [UIView animateWithDuration:0.6 delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
//                //[self toggleSubViews:NO];
                [self.tableView setHidden:NO];
//                CGRect myFrame = self.view.frame;
//                myFrame.origin.y = 0.0;
//                self.view.frame = myFrame;
//            } 
//                             completion: nil];
//        }];
        [self refreshCountForRowWithIndexPath:[TDCommon getLastIndexPath]];
    }
}

@end
