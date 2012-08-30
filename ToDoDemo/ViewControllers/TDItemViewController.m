//
//  TDItemViewController.m
//  ToDoDemo
//
//  Created by Megha Wadhwa on 27/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TDItemViewController.h"

@interface TDItemViewController ()
- (void)updateArraysAfterDoneFromIndexpath:(NSIndexPath *)indexPath;
- (void)updateRowsAfterMovingFromIndexpath:(NSIndexPath *)indexPath ToIndexpath:(NSIndexPath*)toIndexPath;
@end

@implementation TDItemViewController
@synthesize parentList;
@synthesize checkedArray,uncheckedArray;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)initialSettings
{
    [TDCommon setTheme:THEME_HEAT_MAP];
    NSSortDescriptor *prioritySort = [[NSSortDescriptor alloc] initWithKey:@"priority" ascending:YES];
    NSArray *descriptors = [NSArray arrayWithObject:prioritySort];
    NSArray *sortedItems = [parentList.items sortedArrayUsingDescriptors:descriptors];
    NSLog(@"sorted array %@",sortedItems);
    self.rows = [NSMutableArray arrayWithArray:sortedItems];
    self.checkedArray = [[NSMutableArray alloc] init];
    self.uncheckedArray = [[NSMutableArray alloc] init];
    for (ToDoItem *item in self.rows) {
        if ([item.doneStatus isEqualToNumber:[NSNumber numberWithBool:FALSE]]) {
            [self.uncheckedArray addObject:item];
        }
        else {
            [self.checkedArray addObject:item];
        }
    }
    [self updateMainArray];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self placeParentImageViews];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)setStrikedLabel
{
    int checkedRowCount = [self.checkedArray count];
    if (checkedRowCount == 0) {
        return;
    }
    int totalCount = [self.rows count];
    for (int i = totalCount-1; i >=(totalCount - checkedRowCount); i--) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        TransformableTableViewCell *cell = (id)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell makeStrikedLabel];
        [cell.contentView addSubview:cell.strikedLabel];
        cell.strikedLabel.userInteractionEnabled = NO;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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

-(void)addNewRowInDBAtIndexPath:(NSIndexPath *)indexpath
{
    [self addNewRowInDBAtIndexPath:indexpath withModelType:TDModelItem];
}

- (void)updateCurrentRowsDoneStatusAtIndexpath: (NSIndexPath *)indexpath
{ 
    ToDoItem * item = [self.rows objectAtIndex:indexpath.row];
    if ([item.doneStatus isEqual:[NSNumber numberWithBool:FALSE]]) {
        //TODO :animation
        [TDCommon playSound:self.checkSound];
        item.doneStatus = [NSNumber numberWithBool:TRUE];
    }
    else {
        [TDCommon playSound:self.uncheckSound];
        item.doneStatus = [NSNumber numberWithBool:FALSE];
    }
    
}

- (void)updateCurrentRowAtIndexpath: (NSIndexPath *)indexpath
{
    [self updateCurrentRowAtIndexpath:indexpath withModelType:TDModelItem];
//    ToDoItem *currentItem = [self.rows objectAtIndex:indexpath.row];
//    TransformableTableViewCell *cell = (TransformableTableViewCell*)[self.tableView cellForRowAtIndexPath:indexpath];
//    currentItem.itemName = cell.textLabel.text;
//    NSLog(@"done status %d",[currentItem.doneStatus boolValue]);
//    NSError *error = nil;
//    if (![self.managedObjectContext save:&error]) {
//        NSLog(@"Error in updating a item text%@, %@", error, [error userInfo]);
//        abort();
//    }
//    [self updateNewItem:currentItem atIndexPath:indexpath];
   // [self reloadFromUpdatedDB];
}

//- (void)updateRowsAfterDeletionFromIndexPath:(NSIndexPath *)indexPath
//{
//    int count = [self.rows count];
//    for (int i = indexPath.row; i< count ; i++) {
//        ToDoItem *item = [self.rows objectAtIndex:i];
//        int newPriority = [item.priority intValue] - 1;
//        item.priority = [NSNumber numberWithInt:newPriority];
//    }
//}

- (void)deleteCurrentRowAtIndexpath: (NSIndexPath *)indexpath
{
    [self deleteCurrentRowAtIndexpath:indexpath withModelType:TDModelItem];
    [self updateRowsFromIndexPath:indexpath withModelType:TDModelItem withCreationFlag:NO];
    [self updateArraysAfterDeletionOrInsertionFromIndexpath:indexpath toIndexPath:nil];
//    ToDoItem *currentItem = [self.rows objectAtIndex:indexpath.row];
//    [self deleteItemFromIndexPath:indexpath];
//    [self.managedObjectContext deleteObject:currentItem];
//    [self.rows removeObjectAtIndex:indexpath.row];
//    NSError *error = nil;
//    if (![self.managedObjectContext save:&error]) {
//        NSLog(@"Error in deleting item %@, %@", error, [error userInfo]);
//        abort();
//    }
//    [TDCommon playSound:self.deleteSound];
//    [self.tableView beginUpdates];
//    [UIView animateWithDuration:2 animations:^{
//        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationLeft];
//    }];
//    [self.tableView endUpdates];
//    [self reloadTableData];
}

- (void)deleteCurrentRowAfterSwipeAtIndexpath: (NSIndexPath *)indexpath
{
    [self deleteCurrentRowAtIndexpath:indexpath withModelType:TDModelItem];
    [self updateRowsFromIndexPath:indexpath withModelType:TDModelItem withCreationFlag:NO];
    [self updateArraysAfterDeletionOrInsertionFromIndexpath:indexpath toIndexPath:nil];
//    [TDCommon playSound:self.deleteSound];
//    ToDoItem *currentItem = [self.rows objectAtIndex:indexpath.row];
//    [self deleteItemFromIndexPath:indexpath];
//    [self.rows removeObjectAtIndex:indexpath.row];
//    [self.managedObjectContext deleteObject:currentItem];
//    [self updateRowsAfterDeletionFromIndexPath:indexpath];
//    NSError *error = nil;
//    if (![self.managedObjectContext save:&error]) {
//        NSLog(@"Error in deleting item %@, %@", error, [error userInfo]);
//        abort();
//    }    
}

#pragma mark - animation

- (NSIndexPath *)moveRowDownFromIndexPath:(NSIndexPath *)indexPath
{
    ToDoItem * item = [self.rows objectAtIndex:indexPath.row];
    NSIndexPath * NewIndexPath;
    if ([item.doneStatus isEqualToNumber:[NSNumber numberWithBool:TRUE]]) {
    int newCount = 0;
    if ([self.uncheckedArray count] > 0) {
        newCount = [self.uncheckedArray count] - 1;
    }
        NewIndexPath = [NSIndexPath indexPathForRow:newCount inSection:0];
        NSLog(@"indexpath %@ indexPath %@",indexPath,NewIndexPath);
}
    else {
        int newCount = 0;
        if ([self.uncheckedArray count] > 0) {
            newCount = [self.uncheckedArray count];
        }
        NewIndexPath = [NSIndexPath indexPathForRow:newCount inSection:0];
        NSLog(@"indexpath %@ indexPath %@",indexPath,NewIndexPath);
    }
    [self.tableView beginUpdates];
    [self.tableView moveRowAtIndexPath:indexPath toIndexPath:NewIndexPath];
    [self.tableView endUpdates];
    return NewIndexPath;
}

#pragma mark -  UPDATE AFTER DONE

-(void)updateRowDoneAtIndexpath :(NSIndexPath *)indexPath
{
    NSIndexPath *toIndexPath =[self moveRowDownFromIndexPath:indexPath];
    [self updateArraysAfterDoneFromIndexpath:indexPath];
    [self updateMainArray];
    [self updateRowsAfterMovingFromIndexpath:indexPath ToIndexpath:toIndexPath];
    [self updateArraysAfterDeletionOrInsertionFromIndexpath:indexPath toIndexPath:toIndexPath];
}

- (void)updateArraysAfterDoneFromIndexpath:(NSIndexPath *)indexPath{
    ToDoItem * item = [self.rows objectAtIndex:indexPath.row];
    // This item is done now ,updated in core data, just need to change in arrays
    if ([item.doneStatus isEqual:[NSNumber numberWithBool:TRUE]]) {
        if (indexPath.row <[self.uncheckedArray count]) {
            if ([[self.uncheckedArray objectAtIndex:indexPath.row] isEqual:item]) {
                [self.uncheckedArray removeObjectAtIndex:indexPath.row];
                [self.checkedArray insertObject:item atIndex:0];
            }
        }
        else {// do nothing
        }
        //TODO :animation
        NSLog(@"checked : %@ uncheckedArray %@",self.checkedArray,self.uncheckedArray);
    }
    else {
        if ([self.uncheckedArray count] == 0) {
            if ([[self.checkedArray objectAtIndex:indexPath.row] isEqual:item]) {
                [self.checkedArray removeObjectAtIndex:indexPath.row];
                [self.uncheckedArray addObject:item];
            }
        }
        else {
            if (indexPath.row <[self.uncheckedArray count]) { // do no change
            }
            else {
                if ([[self.checkedArray objectAtIndex:indexPath.row - [self.uncheckedArray count]] isEqual:item]) {
                    [self.checkedArray removeObjectAtIndex:indexPath.row - [self.uncheckedArray count]];
                    [self.uncheckedArray addObject:item];
                }
            }
        }
    }
}

#pragma mark-
- (void)updateMainArray
{
    self.rows = [NSMutableArray arrayWithArray:self.uncheckedArray];
    [self.rows addObjectsFromArray:self.checkedArray];
}

# pragma mar- MOVE After LONG PRESS
// Called after moving rows after long press
- (void)updateAfterMovingToIndexpath:(NSIndexPath*)toIndexPath{
    
 //   ToDoItem *item = self.grabbedObject;
//    int priorityIndex = [item.priority intValue];
    //    NSIndexPath *fromIndexpath = [NSIndexPath indexPathForRow:priorityIndex inSection:0];    
    [self updateDoneStatusOfRowAtIndexPath:toIndexPath];
    [self updateRowsAfterMovingFromIndexpath:self.grabbedIndex ToIndexpath:toIndexPath];
    [self updateArraysAfterDoneFromIndexpath:self.grabbedIndex ToIndexPath:toIndexPath];
}

- (void)updateDoneStatusOfRowAtIndexPath:(NSIndexPath * )toIndexPath
{
    int toIndex = toIndexPath.row;
    ToDoItem *currentItem = [self.rows objectAtIndex:toIndex];
    
    if ([self.rows count] == 1) {
        return;
    }
    else if (toIndex == 0) {
        ToDoItem *nextItem = [self.rows objectAtIndex:1];
        currentItem.doneStatus = nextItem.doneStatus;
        return;
    }
    ToDoItem *previousItem = [self.rows objectAtIndex:toIndex-1];
    currentItem.doneStatus = previousItem.doneStatus;
    
}

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
    ToDoItem *item = [self.rows objectAtIndex:index];
        item.priority = [NSNumber numberWithInt:index];
        NSLog(@"updating priority %@ %i",item.itemName,[item.priority intValue]);
    }
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error in updating a item's done status%@, %@", error, [error userInfo]);
        abort();
    }
}

- (void)updateArraysAfterDoneFromIndexpath:(NSIndexPath *)indexPath ToIndexPath:(NSIndexPath *)toIndexPath{
    ToDoItem * item = [self.rows objectAtIndex:toIndexPath.row];
    int toIndex;
    // This item is done now ,updated in core data, moved to new index,just need to change in arrays
    if ([item.doneStatus isEqualToNumber:[NSNumber numberWithBool:TRUE]]) { // item is checked now
        if (indexPath.row <[self.uncheckedArray count]) {
            toIndex = toIndexPath.row  + 1 - [self.uncheckedArray count];
            if ([[self.uncheckedArray objectAtIndex:indexPath.row] isEqual:item]) {
                [self.uncheckedArray removeObjectAtIndex:indexPath.row];
                [self.checkedArray insertObject:item atIndex:toIndex];
            }
        }
        else {
            toIndex = toIndexPath.row - [self.uncheckedArray count];
            if (toIndex<0) {
                toIndex = 0;
            }
            if ([[self.checkedArray objectAtIndex:indexPath.row - [self.uncheckedArray count]] isEqual:item]) {
                [self.checkedArray removeObjectAtIndex:indexPath.row - [self.uncheckedArray count]];
                [self.checkedArray insertObject:item atIndex:toIndex];
            }
            NSLog(@"Unchecked array count  : %d toIndex  %d",[self.uncheckedArray count],toIndexPath.row);
        }
    }
    else {// item is unchecked now
        toIndex = toIndexPath.row;
                                 // unchecked row moved from unchecked region
            if (indexPath.row < [uncheckedArray count]) { // row to be moved from unchecked section
                [self.uncheckedArray removeObjectAtIndex:indexPath.row];
                [self.uncheckedArray insertObject:item atIndex:toIndex];
            }
            else {
                if ([[self.checkedArray objectAtIndex:indexPath.row - [self.uncheckedArray count]] isEqual:item]) {
                    [self.checkedArray removeObjectAtIndex:indexPath.row - [self.uncheckedArray count]];
                    [self.uncheckedArray insertObject:item atIndex:toIndex];
                }
            }
    }
    NSLog(@"From  : %d to %d",indexPath.row,toIndex);
}

# pragma mark - CHECKED ARRAY METHODS
- (void)createNewItem:(ToDoItem *)newItem atIndexPath:(NSIndexPath *)indexPath
{
    if ([newItem.doneStatus isEqualToNumber:[NSNumber numberWithBool:FALSE]]) {
        [uncheckedArray insertObject:newItem atIndex:indexPath.row];
    }
    else {
        [checkedArray insertObject:newItem atIndex:indexPath.row];
    }
   // NSLog(@"checked : %@ uncheckedArray %@",self.checkedArray,self.uncheckedArray);

}

- (void)updateNewItem:(ToDoItem *)newItem atIndexPath:(NSIndexPath *)indexPath
{
    if ([newItem.doneStatus isEqualToNumber:[NSNumber numberWithBool:FALSE]]) {
        [self.uncheckedArray replaceObjectAtIndex:indexPath.row withObject:newItem];
        NSLog(@"UPDATE PRIORITYunchecked  item priority: %d index %i",[newItem.priority intValue], indexPath.row);

    }
    else {
         int unchecked = [self.uncheckedArray count];
        int checkedIndex = indexPath.row - unchecked;
        [checkedArray replaceObjectAtIndex:checkedIndex  withObject:newItem];
        NSLog(@"UPDATE PRIORITY checked  item priority: %d index %i",[newItem.priority intValue], indexPath.row);
    }

}

- (void)deleteItemFromIndexPath:(NSIndexPath *)indexPath
{
    ToDoItem *item = [self.rows objectAtIndex:indexPath.row];
    NSLog(@"item done status %@",item.doneStatus);
    if ([item.doneStatus isEqualToNumber:[NSNumber numberWithBool:FALSE]]) {
        [uncheckedArray removeObjectAtIndex:indexPath.row];
    }
    else {
        //check if index is correct here
        if ([uncheckedArray count] > 0) {
            [checkedArray removeObjectAtIndex:indexPath.row - [uncheckedArray count]];
        }
        else {
            [checkedArray removeObjectAtIndex:indexPath.row];
        }
    }
    //NSLog(@"checked : %@ uncheckedArray %@",self.checkedArray,self.uncheckedArray);

}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSObject *object;
    ToDoItem *item;
    if ([[self.rows objectAtIndex:indexPath.row]isEqual:DUMMY_CELL]) {
        object = [self.rows objectAtIndex:indexPath.row];
    }
    else {
        item = [self.rows objectAtIndex:indexPath.row];
        object = item.itemName;
    }
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
                cell.nameTextField.adjustsFontSizeToFitWidth = YES;
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
                cell.textLabel.text = @"Release to insert new item";
                cell.nameTextField.text = cell.textLabel.text;
            } else {
                cell.textLabel.text = @"Pull Down to create new item";
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
        //NSLog(@"donestatus:%@",item.doneStatus);
        static NSString *cellIdentifier = @"DefaultTableViewCell";
        TransformableTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [TransformableTableViewCell transformableTableViewCellWithStyle:TransformableTableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.textLabel.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.updateDelegate = self;
            cell.deleteDelegate = self;
            cell.createDelegate = self;
        }
        //tobe commented
        cell.textLabel.text = [NSString stringWithFormat:@"%@", (NSString *)object];
        cell.detailTextLabel.text = @" ";
        if ([item.doneStatus isEqualToNumber:[NSNumber numberWithBool:TRUE]]) {
            cell.textLabel.userInteractionEnabled = NO;
            cell.textLabel.hidden = NO;
            cell.textLabel.textColor = [UIColor grayColor];
            cell.contentView.backgroundColor = [UIColor darkGrayColor];
            [cell makeStrikedLabel];       
            [cell.contentView addSubview:cell.strikedLabel];
            [cell.contentView bringSubviewToFront:cell.strikedLabel];
            cell.strikedLabel.hidden = NO;
          //  NSLog(@"added strike label");
            cell.strikedLabel.userInteractionEnabled = NO;
        } else if ([object isEqual:DUMMY_CELL]) {
            cell.textLabel.text = @"";
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.strikedLabel.hidden = YES;
        } else {
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.contentView.backgroundColor = backgroundColor;
            cell.textLabel.userInteractionEnabled = YES;
            if (cell.strikedLabel != nil) {
                [cell.strikedLabel removeFromSuperview];
                cell.strikedLabel = nil;
          //      NSLog(@"removd strike label");
            }
        }
        cell.editingDelegate = self;
        return cell;
    }
    
}

#pragma mark - Delegates
#pragma mark JTTableViewGestureEditingRowDelegate

// This is needed to be implemented to let our delegate choose whether the panning gesture should work

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer commitEditingState:(JTTableViewCellEditingState)state forRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableView *tableView = gestureRecognizer.tableView;
    [tableView beginUpdates];
    if (state == JTTableViewCellEditingStateLeft) {
        // An example to discard the cell at JTTableViewCellEditingStateLeft
        //[self.rows removeObjectAtIndex:indexPath.row];
        [self deleteCurrentRowAfterSwipeAtIndexpath:indexPath];
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
    BOOL checked = [self getCheckedStatusForRowAtIndex:indexPath];
    UIColor *backgroundColor = nil;
    switch (state) {
        case JTTableViewCellEditingStateMiddle:
            if (checked) {
                backgroundColor = [UIColor darkGrayColor];
            }
            else {
                backgroundColor = [TDCommon getColorByPriority:indexPath.row];
            }
            break;
        case JTTableViewCellEditingStateRight:
            backgroundColor = [UIColor greenColor];
            break;
        default:
            if (checked) {
                backgroundColor = [TDCommon getColorByPriority:indexPath.row];
            }
            else {
                backgroundColor = [UIColor darkGrayColor];
            }
            break;
    }
    cell.contentView.backgroundColor = backgroundColor;
    if ([cell isKindOfClass:[TransformableTableViewCell class]]) {
        ((TransformableTableViewCell *)cell).tintColor = backgroundColor;
    }
}

- (NSString *)returnStrikedOutTextFromString:(NSString *)mString
{
    NSString * mNewString = @"";
    
    for(int i = 0; i<[mString length]; i++)
    {
        mNewString = [NSString stringWithFormat:@"%@%@",mNewString, 
                      NSLocalizedString([[mString substringToIndex:i+1] substringFromIndex:i],nil)];
    }
    
    return mNewString;
}

#pragma mark -
#pragma mark JTTableViewGestureAddingRowDelegate

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsAddRowAtIndexPath:(NSIndexPath *)indexPath {
    ToDoItem *newItem = (ToDoItem *)[NSEntityDescription insertNewObjectForEntityForName:@"ToDoItem"
                                                                  inManagedObjectContext:self.managedObjectContext];
    newItem.itemName = ADDING_CELL;
    newItem.priority = [NSNumber numberWithInt:indexPath.row];
    newItem.doneStatus = [NSNumber numberWithBool:FALSE];
    newItem.list = self.parentList;
    [self.rows insertObject:newItem atIndex:indexPath.row];
    //Also Unchecked Array
   // NSLog(@"item %@",[self.rows objectAtIndex:indexPath.row]);

    [self createNewItem:newItem atIndexPath:indexPath];
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsCommitRowAtIndexPath:(NSIndexPath *)indexPath {
    [self gestureRecognizer:gestureRecognizer needsCommitRowAtIndexPath:indexPath withModelType:TDModelItem];
}

#pragma mark - 
- (BOOL)getCheckedStatusForRowAtIndex:(NSIndexPath *)indexPath
{
    ToDoItem *currentItem = [self.rows objectAtIndex:indexPath.row];
    return [currentItem.doneStatus boolValue];
}

- (void)viewWillAppear:(BOOL)animated
{
    [TDCommon setTheme:THEME_HEAT_MAP];   
    [self.tableView setHidden:YES];
    [self initialSettings];
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
                [self setStrikedLabel];
            } 
                             completion: nil];
        }];
        self.goingDownByPullUp = NO;
        self.tableView.hidden = NO;
        self.tableView.userInteractionEnabled = YES;
    }
    else if (self.navigateFlag == TRUE) {
        self.tableView.hidden = NO;
        self.tableView.userInteractionEnabled = YES;
        [self animateParentViews];
        self.navigateFlag = NO;
    }
    else {
//        float originY = [self getLastRowHeight];
//        [UIView animateWithDuration:0.0 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{  
//            CGRect myFrame = self.view.frame;
//            myFrame.origin.y = -originY;
//            self.view.frame = myFrame;
//        } completion:^(BOOL fin){
//            [UIView animateWithDuration:0.6 delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [self.tableView setHidden:NO];
//                CGRect myFrame = self.view.frame;
//                myFrame.origin.y = 0.0;
//                self.view.frame = myFrame;
//                [self setStrikedLabel];
//            } 
//                             completion: nil];
//        }];
    }

}

@end
