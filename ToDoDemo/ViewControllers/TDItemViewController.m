//
//  TDItemViewController.m
//  ToDoDemo
//
//  Created by Megha Wadhwa on 27/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TDItemViewController.h"

@interface TDItemViewController ()

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [TDCommon setTheme:THEME_HEAT_MAP];
    self.rows = [NSMutableArray arrayWithArray:[parentList.items allObjects]];
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
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
#pragma mark - calculate priority

- (float)getPriorityForIndexPath:(NSIndexPath *)indexPath
{
    float priority = 100.0;
    
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
    
    // u can change the list if u want
    //ToDoList *newList = [self.rows objectAtIndex:indexpath.row];
    
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error in adding a new item %@, %@", error, [error userInfo]);
        abort();
    } 
    
}

- (void)updateCurrentRowsDoneStatusAtIndexpath: (NSIndexPath *)indexpath
{ 
    ToDoItem * item = [self.rows objectAtIndex:indexpath.row];
    if ([item.doneStatus isEqual:[NSNumber numberWithBool:FALSE]]) {
        //TODO :animation
//        if ([[self.checkedArray objectAtIndex:indexpath.row] isEqual:item]) {
//            [self.checkedArray removeObjectAtIndex:indexpath.row];
//        }
//        // animate To go Down
        item.doneStatus = [NSNumber numberWithBool:TRUE];
    }
    else {
        item.doneStatus = [NSNumber numberWithBool:FALSE];
    }
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error in updating a item's done status%@, %@", error, [error userInfo]);
        abort();
    }
    [self reloadFromUpdatedDB];
}

- (void)updateCurrentRowAtIndexpath: (NSIndexPath *)indexpath
{
    ToDoItem *currentItem = [self.rows objectAtIndex:indexpath.row];
    TransformableTableViewCell *cell = (TransformableTableViewCell*)[self.tableView cellForRowAtIndexPath:indexpath];
    currentItem.itemName = cell.textLabel.text;
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error in updating a item text%@, %@", error, [error userInfo]);
        abort();
    }
    [self reloadFromUpdatedDB];
}

- (void)deleteCurrentRowAtIndexpath: (NSIndexPath *)indexpath
{
    ToDoItem *currentItem = [self.rows objectAtIndex:indexpath.row];
    [self.managedObjectContext deleteObject:currentItem];
    [self.rows removeObjectAtIndex:indexpath.row];
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error in deleting item %@, %@", error, [error userInfo]);
        abort();
    }
    [self fetchObjectsFromDb];
    [self.tableView beginUpdates];
    [UIView animateWithDuration:2 animations:^{
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationLeft];
    }];
    [self.tableView endUpdates];
    
    [self.tableView reloadData];
}

- (void)deleteCurrentRowAfterSwipeAtIndexpath: (NSIndexPath *)indexpath
{
    ToDoItem *currentList = [self.rows objectAtIndex:indexpath.row];
    [self.managedObjectContext deleteObject:currentList];
    [self.rows removeObjectAtIndex:indexpath.row];
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error in deleting item %@, %@", error, [error userInfo]);
        abort();
    }    
}

#pragma mark - animation

- (void)moveRowDown
{
    //NSMutableArray * requiredArray = uncheckedArray;
}
- (void)animateRowsAfterDeletionAtIndex:(int)index FromArray:(NSMutableArray *) requiredArray withDeletionFlag:(BOOL)flag
    {
//        
//        if (requiredArray != self.checkedArray) {
//            if (flag) {
//                int lastCheckedObjectIndex = [self.checkedViewsArray count]-1;  //First Move ALL Checked Rows Up-Frm ChckdViewarray
//                TDListCustomRow * lastCheckedRow = [self.checkedViewsArray lastObject];
//                TDListCustomRow *lastCustomRow = [self.customViewsArray lastObject];
//                [self moveCheckedRowsUptoIndex:lastCheckedObjectIndex WithDeletionFlag:flag];
//                [UIView animateWithDuration:ROWS_SHIFTING_DURATION delay:DELETION_DELAY options:UIViewAnimationOptionCurveEaseInOut animations:^{
//                    lastCheckedRow.frame = CGRectMake(0, lastCustomRow.frame.origin.y, lastCustomRow.frame.size.width, lastCustomRow.frame.size.height);} completion:nil]; 
//            }
//            //Then Move Custom Unchecked Rows Up till the required Index
//            [self shiftRowsBackFromIndex:index withDeletionFlag:flag];
//            
//        }    
//        else [self moveCheckedRowsUptoIndex:index WithDeletionFlag:flag];
//    }
}
#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ToDoItem *item = [self.rows objectAtIndex:indexPath.row];
    NSObject *object = item.itemName;
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
            cell = [TransformableTableViewCell transformableTableViewCellWithStyle:TransformableTableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.textLabel.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.updateDelegate = self;
            cell.deleteDelegate = self;
        }
        //tobe commented
        cell.textLabel.text = [NSString stringWithFormat:@"%@", (NSString *)object];
        cell.detailTextLabel.text = @" ";
        if ([item.doneStatus isEqual:[NSNumber numberWithBool:TRUE]]) {
            cell.textLabel.hidden = NO;
            cell.textLabel.textColor = [UIColor grayColor];
            cell.contentView.backgroundColor = [UIColor darkGrayColor];
        } else if ([object isEqual:DUMMY_CELL]) {
            cell.textLabel.text = @"";
            cell.contentView.backgroundColor = [UIColor clearColor];
        } else {
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.contentView.backgroundColor = backgroundColor;
        }
        return cell;
    }
    
}

#pragma mark - Delegates
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

- (BOOL)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark -
#pragma mark JTTableViewGestureAddingRowDelegate

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsAddRowAtIndexPath:(NSIndexPath *)indexPath {
    ToDoItem *newItem = (ToDoItem *)[NSEntityDescription insertNewObjectForEntityForName:@"ToDoItem"
                                                                  inManagedObjectContext:self.managedObjectContext];
    newItem.itemName = ADDING_CELL;
    newItem.priority = [NSNumber numberWithInt:[self getPriorityForIndexPath:indexPath]];
    newItem.doneStatus = [NSNumber numberWithBool:FALSE];
    newItem.list = self.parentList;
    [self.rows insertObject:newItem atIndex:indexPath.row];
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsCommitRowAtIndexPath:(NSIndexPath *)indexPath {
    ToDoItem *item = [self.rows objectAtIndex:indexPath.row];
    item.itemName = @"New To Do"; 
    TransformableTableViewCell *cell = (id)[gestureRecognizer.tableView cellForRowAtIndexPath:indexPath];
    if (cell.frame.size.height > COMMITING_CREATE_CELL_HEIGHT * 2  && indexPath.row == 0) {
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
        //[cell labelTapped];
        //cell.nameTextField.text = @"";
        [self addNewRowInDBAtIndexPath:indexPath];
        
        //insert in db here
    }
}

- (void)removeCurrentView
{
    [UIView animateWithDuration:BACK_ANIMATION delay:BACK_ANIMATION_DELAY options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect myFrame = self.view.frame;
        myFrame.origin.y = 480;
        self.view.frame = myFrame; 
    } completion:^ (BOOL finished) {
        if (finished) {
            [self.tableView setHidden:YES];
            [self.navigationController popViewControllerAnimated:NO]; 
        }
    }];
    
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
        float originY = [self getLastRowHeight];
        [UIView animateWithDuration:0.0 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{  
            CGRect myFrame = self.view.frame;
            myFrame.origin.y = -originY;
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
    }
}

@end
