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
    [TDCommon setTheme:THEME_BLUE];
    self.tableViewRecognizer.pullUpToMoveDownDelegate = self;
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

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ToDoList *list = [self.rows objectAtIndex:indexPath.row];
    NSObject *object = list.listName;
    UIColor *backgroundColor = [TDCommon getColorByPriority:indexPath.row];
    //[[UIColor redColor] colorWithHueOffset:0.12 * indexPath.row / [self tableView:tableView numberOfRowsInSection:indexPath.section]];
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
            if (cell.frame.size.height > COMMITING_CREATE_CELL_HEIGHT * 2) {
                cell.imageView.image = [UIImage imageNamed:@"arrow-up.png"];
                cell.tintColor = [UIColor blackColor];
                cell.textLabel.text = [NSString stringWithFormat:@"Return to %@",self.parentName];
                cell.nameTextField.text = cell.textLabel.text;
            } else if (cell.frame.size.height > COMMITING_CREATE_CELL_HEIGHT) {
                cell.imageView.image = nil;
                // Setup tint color
                cell.tintColor = backgroundColor;
                cell.textLabel.text = @"Release to create cell...";
                cell.nameTextField.text = cell.textLabel.text;
            } else {
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
        }
        cell.countLabel.text = [NSString stringWithFormat:@"%d",[self getUncheckedItemsFromList:list]];
        cell.textLabel.text = [NSString stringWithFormat:@"%@", (NSString *)object];
        cell.detailTextLabel.text = @" ";
        if ([cell.countLabel.text isEqualToString:@"0"]) {
            cell.textLabel.hidden = NO;
            cell.textLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
            cell.countLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
            cell.contentView.backgroundColor = [TDCommon getColorByPriority:indexPath.row];
        } else if ([object isEqual:DUMMY_CELL]) {
            cell.textLabel.text = @"";
            cell.contentView.backgroundColor = [UIColor clearColor];
        } else {
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.countLabel.textColor = [ UIColor whiteColor];
            cell.contentView.backgroundColor = backgroundColor;
        }
        cell.editingDelegate = self;
        return cell;
    }
    
}

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
        NSLog(@"Name: %@", lists.listName);
    }  
}

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
    [self reloadFromUpdatedDB];
}

-(void)addNewRowInDBAtIndexPath:(NSIndexPath *)indexpath
 {
    
     // u can change the list if u want
     //ToDoList *newList = [self.rows objectAtIndex:indexpath.row];
     
       
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error in saving list %@, %@", error, [error userInfo]);
        abort();
    } 
    
}

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
            [self reloadFromUpdatedDB];
        }
    }
    else {
        list.doneStatus = [NSNumber numberWithBool:FALSE];
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Error in updating a list %@, %@", error, [error userInfo]);
            abort();
        }
        [self reloadFromUpdatedDB];
    }
}

- (void)updateCurrentRowAtIndexpath: (NSIndexPath *)indexpath
{
     ToDoList *currentList = [self.rows objectAtIndex:indexpath.row];
    TransformableTableViewCell *cell = (TransformableTableViewCell*)[self.tableView cellForRowAtIndexPath:indexpath];
    currentList.listName = cell.textLabel.text;
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error in updating a list %@, %@", error, [error userInfo]);
        abort();
    }
    [self reloadFromUpdatedDB];
}

- (void)deleteCurrentRowAtIndexpath: (NSIndexPath *)indexpath
{
    [self deleteCurrentRowAfterSwipeAtIndexpath:indexpath];
//    ToDoList *currentList = [self.rows objectAtIndex:indexpath.row];
//    [self.managedObjectContext deleteObject:currentList];
//    [self.rows removeObjectAtIndex:indexpath.row];
//    NSError *error = nil;
//    if (![self.managedObjectContext save:&error]) {
//        NSLog(@"Error in deleting list %@, %@", error, [error userInfo]);
//        abort();
//    }
//    [self fetchObjectsFromDb];
//    [self.tableView beginUpdates];
//    [UIView animateWithDuration:2 animations:^{
//    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationLeft];
//    }];
//    [self.tableView endUpdates];
//    
    TransformableTableViewCell *cell = (TransformableTableViewCell*)[self.tableView cellForRowAtIndexPath:indexpath];
    if (self.rowIndexToBeDeleted >=0  && ![cell.countLabel.text isEqualToString:@"0"]) {
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationRight];
    }else {
        [TDCommon playSound:self.deleteSound];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationLeft];
    }

}

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
        ToDoList *currentList = [self.rows objectAtIndex:indexpath.row];
        [self.managedObjectContext deleteObject:currentList];
        [self.rows removeObjectAtIndex:indexpath.row];
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Error in deleting list %@, %@", error, [error userInfo]);
            abort();
        }   
        [self fetchObjectsFromDb];
    }
}

#pragma mark - action sheet delegates
- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        // To be updated
        if (self.rowIndexToBeUpdated >= 0) {
            [TDCommon playSound:self.checkSound];
        ToDoList *list = [self.rows objectAtIndex:self.rowIndexToBeUpdated];
        list.doneStatus = [NSNumber numberWithBool:TRUE];
        [self checkAllItemsForSelectedList];
            [self refreshCount];
        }
        else if(self.rowIndexToBeDeleted >= 0){ // To be Deleted
            ToDoList *currentList = [self.rows objectAtIndex:self.rowIndexToBeDeleted];
            [self.managedObjectContext deleteObject:currentList];
            [self.rows removeObjectAtIndex:self.rowIndexToBeDeleted];
            NSError *error = nil;
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"Error in deleting list %@, %@", error, [error userInfo]);
                abort();
            }
            [self fetchObjectsFromDb];
            [TDCommon playSound:self.deleteSound];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.rowIndexToBeDeleted inSection:0]; 
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            [self.tableView endUpdates];
        }
    }
}

#pragma mark- Delegates
#pragma mark JTTableViewGestureEditingRowDelegate

// This is needed to be implemented to let our delegate choose whether the panning gesture should work

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
        }else {
            [TDCommon playSound:self.deleteSound];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
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
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer didEnterEditingState:(JTTableViewCellEditingState)state forRowAtIndexPath:(NSIndexPath *)indexPath {
UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//BOOL checked = [self getCheckedStatusForRowAtIndex:indexPath];
UIColor *backgroundColor = nil;
switch (state) {
    case JTTableViewCellEditingStateMiddle:
//        if (checked) {
//            backgroundColor = [[TDCommon getColorByPriority:indexPath.row] colorWithAlphaComponent:0.8];
//        }
//        else {
            backgroundColor = [TDCommon getColorByPriority:indexPath.row];
//        }
        break;
    case JTTableViewCellEditingStateRight:
        backgroundColor = [UIColor greenColor];
        break;
    default:
//        if (checked) {
            backgroundColor = [TDCommon getColorByPriority:indexPath.row];
//        }
//        else {
//            backgroundColor = [[TDCommon getColorByPriority:indexPath.row] colorWithAlphaComponent:0.8];        }
        break;
}
cell.contentView.backgroundColor = backgroundColor;
if ([cell isKindOfClass:[TransformableTableViewCell class]]) {
    ((TransformableTableViewCell *)cell).tintColor = backgroundColor;
}
}

- (BOOL)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    BOOL checked = [self getCheckedStatusForRowAtIndex:indexPath];
//    return (!checked);
    if (self.editingFlag == TRUE) {
        return NO;
    }
    return YES;
}

#pragma mark -
#pragma mark JTTableViewGestureAddingRowDelegate

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsAddRowAtIndexPath:(NSIndexPath *)indexPath {
    ToDoList *newList = (ToDoList *)[NSEntityDescription insertNewObjectForEntityForName:@"ToDoList"
                                                                  inManagedObjectContext:self.managedObjectContext];
    newList.listName = ADDING_CELL;
    
    newList.priority = [NSNumber numberWithInt:[self getPriorityForIndexPath:indexPath]];
    newList.doneStatus = [NSNumber numberWithBool:FALSE];
    [self.rows insertObject:newList atIndex:indexPath.row];
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsCommitRowAtIndexPath:(NSIndexPath *)indexPath {
    ToDoList * list = [self.rows objectAtIndex:indexPath.row];
    list.listName = @"Newly Added"; 
    TransformableTableViewCell *cell = (id)[gestureRecognizer.tableView cellForRowAtIndexPath:indexPath];
    if (cell.frame.size.height > COMMITING_CREATE_CELL_HEIGHT * 2 && indexPath.row == 0) {
        [self.managedObjectContext rollback];
        [self.rows removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        // Return to list
        [self removeCurrentView];
    }
    else {
        cell.finishedHeight = NORMAL_CELL_FINISHING_HEIGHT;
        cell.imageView.image = nil;
        cell.textLabel.text = @"Just Added!";
        [TDCommon playSound:self.pullDownToCreateSound];
        //[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
       // [self.tableView reloadData];
        [self addNewRowInDBAtIndexPath:indexPath];
        //insert in db here
    }
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsDiscardRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.managedObjectContext rollback];
    [self.rows removeObjectAtIndex:indexPath.row];
}

#pragma mark - calculate priority

- (float)getPriorityForIndexPath:(NSIndexPath *)indexPath
{
    float priority = 20000.0;
    
    if ([self.rows count] == 0) {
        return priority;
    }
    
    if (indexPath.row == 0) {
        ToDoList *list = [self.rows objectAtIndex:0];
        float listPriority = [list.priority floatValue];
        priority = listPriority - 1.0;
    }
    else if(indexPath.row == [self.rows count])
    {
        ToDoList *list = [self.rows objectAtIndex:[self.rows count]-1];
        float listPriority = [list.priority floatValue];
        priority = listPriority + 1.0 ;
        
    }
    else {
        ToDoList *firstList = [self.rows objectAtIndex:indexPath.row];
        float firstListPriority = [firstList.priority floatValue];
        ToDoList *secondList = [self.rows objectAtIndex:indexPath.row -1];
        float secondListPriority = [secondList.priority floatValue];
        priority = (firstListPriority +secondListPriority)/2.0;
    }
    return priority;
}

- (BOOL)getCheckedStatusForRowAtIndex:(NSIndexPath *)indexPath
{
 ToDoList *currentList = [self.rows objectAtIndex:indexPath.row];
    return [currentList.doneStatus boolValue];
}

#pragma mark - Table view delegate

- (BOOL)lastVisitedListIsNotNil
{
    return (self.lastVisitedList !=nil);
}

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

- (void)removeCurrentView
{
    [TDCommon playSound:self.pullDownToMoveUpSound];
        [UIView animateWithDuration:BACK_ANIMATION delay:BACK_ANIMATION_DELAY options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect myFrame = self.view.frame;
        myFrame.origin.y = 480;
        self.view.frame = myFrame; 
    } completion:^ (BOOL finished) {
        [self.tableView setHidden:YES];
        [self.navigationController popViewControllerAnimated:NO]; 
    }];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editingFlag == FALSE) {
        [TDCommon playSound:self.navigateSound];
    TDListViewController *src = (TDListViewController *) self;
    TDItemViewController *destination = [self.storyboard instantiateViewControllerWithIdentifier:@"ItemViewController"];
    ToDoList *list = [self.rows objectAtIndex:indexPath.row];
    src.childName = list.listName;
    destination.childName = nil;
    src.lastVisitedList = list;
    destination.parentList = list;
    destination.parentName = @"Lists";
    destination.goingDownByPullUp = NO;
    src.goingDownByPullUp = NO;
    destination.managedObjectContext = self.managedObjectContext;
    [src.navigationController pushViewController:destination animated:YES];
    }
}

#pragma mark- view related

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
    [self fetchObjectsFromDb];
    self.rowIndexToBeUpdated = -1;
    self.rowIndexToBeDeleted = -1;
}

- (void)refreshCount
{
    int count = [self.rows count];
    for (int i = 0; i <count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
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
    else {
        [self.tableView reloadData];
        float originY = [self getLastRowHeight];
        [UIView animateWithDuration:0.0 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{  
            CGRect myFrame = self.view.frame;
            myFrame.origin.y = -originY;
            self.view.frame = myFrame;
        } completion:^(BOOL fin){
            [UIView animateWithDuration:0.6 delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                //[self toggleSubViews:NO];
                [self.tableView setHidden:NO];
                CGRect myFrame = self.view.frame;
                myFrame.origin.y = 0.0;
                self.view.frame = myFrame;
            } 
                             completion: nil];
        }];
    }
    [self refreshCount];
}

@end
