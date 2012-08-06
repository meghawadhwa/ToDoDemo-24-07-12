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
    [TDCommon setTheme:THEME_BLUE];

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
                cell.imageView.image = [UIImage imageNamed:@"reload.png"];
                cell.tintColor = [UIColor blackColor];
                cell.textLabel.text = @"Return to list...";
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
        //tobe commented
        cell.countLabel.text = [NSString stringWithFormat:@"%d",[list.items count]];
        cell.textLabel.text = [NSString stringWithFormat:@"%@", (NSString *)object];
        cell.detailTextLabel.text = @" ";
        if ([list.doneStatus isEqual:[NSNumber numberWithBool:TRUE]]) {
            cell.textLabel.hidden = NO;
            cell.textLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
            cell.contentView.backgroundColor = [TDCommon getColorByPriority:indexPath.row];
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

- (int)getItemCount
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity: [NSEntityDescription entityForName:@"ToDoItem" inManagedObjectContext: self.managedObjectContext]];
    
    NSError *error = nil;
    NSUInteger count = [self.managedObjectContext countForFetchRequest: request error: &error];
    NSLog(@"count %d",count);    
    return count;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark-
- (void)fetchObjectsFromDb
{
    // Test listing all ToDoList from the store
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ToDoList"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    self.rows = [NSMutableArray arrayWithArray:fetchedObjects];
    for (ToDoList *lists in fetchedObjects) {
        NSLog(@"Name: %@", lists.listName);
    }   
}

-(void)addNewRowInDBAtIndexPath:(NSIndexPath *)indexpath
 {
    
     // u can change the list if u want
     //ToDoList *newList = [self.rows objectAtIndex:indexpath.row];
     
       
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error in adding a new list %@, %@", error, [error userInfo]);
        abort();
    } 
    
}

- (void)updateCurrentRowsDoneStatusAtIndexpath: (NSIndexPath *)indexpath
{
    ToDoList * list = [self.rows objectAtIndex:indexpath.row];
    if ([list.doneStatus isEqual:[NSNumber numberWithBool:FALSE]]) {
        list.doneStatus = [NSNumber numberWithBool:TRUE];
    }
    else {
        list.doneStatus = [NSNumber numberWithBool:FALSE];
    }
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error in updating a list %@, %@", error, [error userInfo]);
        abort();
    }
    [self reloadFromUpdatedDB];
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
    ToDoList *currentList = [self.rows objectAtIndex:indexpath.row];
    [self.managedObjectContext deleteObject:currentList];
    [self.rows removeObjectAtIndex:indexpath.row];
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error in deleting list %@, %@", error, [error userInfo]);
        abort();
    }
    [self fetchObjectsFromDb];
    [self.tableView beginUpdates];
    [UIView animateWithDuration:2 animations:^{
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationLeft];
    }];
    [self.tableView endUpdates];
    

}

- (void)deleteCurrentRowAfterSwipeAtIndexpath: (NSIndexPath *)indexpath
{
    ToDoList *currentList = [self.rows objectAtIndex:indexpath.row];
    [self.managedObjectContext deleteObject:currentList];
    [self.rows removeObjectAtIndex:indexpath.row];
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error in deleting list %@, %@", error, [error userInfo]);
        abort();
    }    
}



#pragma mark- Delegates

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
    return YES;
}

#pragma mark -
#pragma mark JTTableViewGestureAddingRowDelegate

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsAddRowAtIndexPath:(NSIndexPath *)indexPath {
    ToDoList *newList = (ToDoList *)[NSEntityDescription insertNewObjectForEntityForName:@"ToDoList"
                                                                  inManagedObjectContext:self.managedObjectContext];
    newList.listName = ADDING_CELL;
    newList.priority = [NSNumber numberWithInt:indexPath.row];
    newList.doneStatus = [NSNumber numberWithBool:FALSE];
    [self.rows insertObject:newList atIndex:indexPath.row];
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsCommitRowAtIndexPath:(NSIndexPath *)indexPath {
    ToDoList * list = [self.rows objectAtIndex:indexPath.row];
    list.listName = @"Newly Added"; 
    TransformableTableViewCell *cell = (id)[gestureRecognizer.tableView cellForRowAtIndexPath:indexPath];
    if (cell.frame.size.height > COMMITING_CREATE_CELL_HEIGHT * 2) {
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

#pragma mark - 
- (BOOL)getCheckedStatusForRowAtIndex:(NSIndexPath *)indexPath
{
 ToDoList *currentList = [self.rows objectAtIndex:indexPath.row];
    return [currentList.doneStatus boolValue];
}

#pragma mark - Table view delegate

- (void)addChildView
{
    TDListViewController *src = (TDListViewController *) self;
    TDItemViewController *destination = [self.storyboard instantiateViewControllerWithIdentifier:@"ItemViewController"];
//    destination.parentName = @"Lists";
//    destination.childName = nil;
//    destination.goingDownByPullUp = YES;
    //destination.parentDelegate = self;
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
    TDListViewController *src = (TDListViewController *) self;
    TDItemViewController *destination = [self.storyboard instantiateViewControllerWithIdentifier:@"ItemViewController"];
    ToDoList *list = [self.rows objectAtIndex:indexPath.row];
    destination.parentList = list;
    //destination.parentName = @"Menu";
    destination.goingDownByPullUp = NO;
    src.goingDownByPullUp = NO;
    destination.managedObjectContext = self.managedObjectContext;
    [src.navigationController pushViewController:destination animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [TDCommon setTheme:THEME_BLUE];   
    self.tableView.hidden = YES;
    [self fetchObjectsFromDb];
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
                //[self toggleSubViews:NO];
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
