//
//  TDMenuViewController.m
//  ToDoDemo
//
//  Created by Megha Wadhwa on 27/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TDMenuViewController.h"
#import "TDAppDelegate.h"
#import "TDListViewController.h"

@interface TDMenuViewController ()

@end

@implementation TDMenuViewController
@synthesize menuContentsArray,managedObjectContext;
@synthesize goingDownByPullUp;

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
    TDAppDelegate *appDelegate = (TDAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    [TDCommon setTheme:THEME_MAIN_GRAY];
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.menuContentsArray = [NSArray arrayWithObjects:@"My Lists",
                              @"Themes",
                              @"Tips & Tricks",
                              @"Settings", nil];

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [TDCommon setTheme:THEME_MAIN_GRAY];
    [self.tableView setHidden:YES];
}
- (void)viewDidAppear:(BOOL)animated
{
    [self.tableView reloadData];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.menuContentsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellName = [self.menuContentsArray objectAtIndex:indexPath.row];
    UIColor *backgroundColor = [TDCommon getColorByPriority:indexPath.row];
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = nil;
    if (indexPath.row == 0) {
        NSString *listCellIdentifier = @"ListCell";
        cell = [tableView dequeueReusableCellWithIdentifier:listCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:listCellIdentifier];
            UILabel *backgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(260, 0, 60, 60)];
            backgroundLabel.backgroundColor = [TDCommon getColorByPriority:-3];
            cell.detailTextLabel.textColor = [UIColor whiteColor];
            [cell.contentView addSubview:backgroundLabel];
            [cell.contentView bringSubviewToFront:cell.detailTextLabel];
            cell.detailTextLabel.backgroundColor = [UIColor clearColor];
            CGPoint center = backgroundLabel.center;
            CGRect myFrame = cell.detailTextLabel.frame;
            myFrame.origin.y = center.y;
            myFrame.origin.x = center.x - 20;
            cell.detailTextLabel.frame = myFrame;
        }
    }   
    else {
        if (cell == nil) {
             cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
    }
     if (indexPath.row == 0) {
         cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",[self getListCount]];
     }
    cell.textLabel.text = cellName;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = backgroundColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (int)getListCount
{
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity: [NSEntityDescription entityForName:@"ToDoList" inManagedObjectContext: self.managedObjectContext]];
    
    NSError *error = nil;
    NSUInteger count = [self.managedObjectContext countForFetchRequest:request error: &error];
    NSLog(@"count %d",count);    
    return count;
}
#pragma mark - Utility methods

- (float)getLastRowHeight
{
    float lastRowheight = 480;
    lastRowheight = [self.menuContentsArray count] * NORMAL_CELL_FINISHING_HEIGHT; 
    
    return lastRowheight;
}

#pragma mark - view methods


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TDMenuViewController *src = (TDMenuViewController *) self;
    TDListViewController *destination = [self.storyboard instantiateViewControllerWithIdentifier:@"ListViewController"];
    destination.parentName = @"Menu";
    destination.goingDownByPullUp = NO;
//    src.childName = @"Lists";
//    src.parentName = @"";
    src.goingDownByPullUp = NO;
    destination.managedObjectContext = self.managedObjectContext;
    [src.navigationController pushViewController:destination animated:YES];
}

@end
