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
@end

@implementation TDParentViewController

@synthesize managedObjectContext = __managedObjectContext;

@synthesize rows;
@synthesize tableViewRecognizer;
@synthesize grabbedObject;
@synthesize goingDownByPullUp;
@synthesize parentName,childName;
@synthesize backgroundLabel;
@synthesize editingFlag;
@synthesize checkSound,deleteSound,deleteAlertSound,checkAlertSound,pullDownToCreateSound,pullDownToMoveUpSound,pullUpToMoveDownSound,pinchInSound,pinchOutSound,longPressSound,uncheckSound,navigateSound,pullUpToClearSound;
@synthesize topImage,bottomImage,parentTopImageView,parentBottomImageView;
@synthesize navigateFlag;
@synthesize backgroundView;
@synthesize playedPinchInSoundOnce;
@synthesize parentOverTopImageView;
@synthesize overTopImage;

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
    self.rows = [NSMutableArray arrayWithObjects:nil];
    
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
# pragma  mark - Parent Image Views

- (void)placeParentImageViews
{
    self.parentTopImageView =[[UIImageView alloc] initWithImage:self.topImage];
    self.parentBottomImageView =[[UIImageView alloc] initWithImage:self.bottomImage];
    if (self.overTopImage !=nil) {
        self.parentOverTopImageView = [[UIImageView alloc] initWithImage:self.overTopImage];
    }
    [self setInitialFramesForParentImages];
    [self.backgroundView addSubview:self.parentTopImageView];
    [self.backgroundView addSubview:self.parentBottomImageView];
    
    self.tableView.userInteractionEnabled = NO;
    [self.backgroundView bringSubviewToFront:self.parentTopImageView];
    [self.backgroundView bringSubviewToFront:self.parentBottomImageView];
    
    if (self.parentOverTopImageView !=nil) {
        [self.backgroundView addSubview:self.parentOverTopImageView];
        [self.backgroundView bringSubviewToFront:self.parentOverTopImageView];
    }
}

- (void)setInitialFramesForParentImages
{
    if (self.parentOverTopImageView == nil) {
        self.parentTopImageView.frame = CGRectMake(0, 0, self.parentTopImageView.frame.size.width, self.parentTopImageView.frame.size.height);
        self.parentBottomImageView.frame = CGRectMake(0, 60, self.parentBottomImageView.frame.size.width, self.parentBottomImageView.frame.size.height);
        self.parentOverTopImageView = nil;
    }
    else {
        self.parentOverTopImageView.frame = CGRectMake(0, 0, self.parentOverTopImageView.frame.size.width, self.parentOverTopImageView.frame.size.height);
        self.parentTopImageView.frame = CGRectMake(0, CGRectGetMaxY(self.parentOverTopImageView.frame), self.parentTopImageView.frame.size.width, self.parentTopImageView.frame.size.height);
        self.parentBottomImageView.frame = CGRectMake(0, CGRectGetMaxY(self.parentTopImageView.frame), self.parentBottomImageView.frame.size.width, self.parentBottomImageView.frame.size.height);
    }
}
- (void)animateParentViews{
    
    [self setInitialFramesForParentImages];
    NSLog(@"########top %@ frame %@",self.parentTopImageView.image,self.parentTopImageView);
    
    [UIView animateWithDuration:0.4 animations:^{
        if (self.parentOverTopImageView !=nil) {
            CGRect overFrame = self.parentOverTopImageView.frame;
            overFrame.origin.y = -overFrame.size.height - self.parentTopImageView.frame.size.height;
            self.parentOverTopImageView.frame = overFrame;
        }
        CGRect bottomFrame = self.parentBottomImageView.frame;
        bottomFrame.origin.y = 480;
        self.parentBottomImageView.frame = bottomFrame;
        self.parentTopImageView.alpha = 0.0;
    }completion:^ (BOOL finished) {
        if (finished) {
            self.backgroundView.hidden = YES;
            self.parentBottomImageView.hidden = YES;
            self.parentTopImageView.hidden = YES;
            if(self.parentOverTopImageView !=nil)self.parentOverTopImageView.hidden = YES;
            self.parentTopImageView.alpha = 1.0;
            CGRect topFrame = self.parentTopImageView.frame;
            topFrame.origin.y = -60;
            self.parentTopImageView.frame = topFrame;}}];
    self.tableView.userInteractionEnabled = YES;
    NSLog(@"$$$$$$top %@ frame %@",self.parentTopImageView.image,self.parentTopImageView);
    
}

#pragma mark- Pinch Delegates
- (BOOL)animateImageViewsbydistance:(float)y
{
    [self.backgroundView bringSubviewToFront:self.parentOverTopImageView];
    [self.backgroundView bringSubviewToFront:self.parentTopImageView];
    [self.backgroundView bringSubviewToFront:self.parentBottomImageView];
    if (self.backgroundView.hidden == YES) {
        self.backgroundView.hidden = NO;
        self.parentOverTopImageView.hidden = NO;
        self.parentTopImageView.hidden = NO;
        self.parentBottomImageView.hidden = NO;
        self.parentTopImageView.alpha = 0.0;
        CGRect topFrame = self.parentTopImageView.frame;
        topFrame.origin.y = 0 ;
        self.parentTopImageView.frame = topFrame;
        NSLog(@"@@@@@@@");
    }
    float topEnd = CGRectGetMaxY(self.parentTopImageView.frame);
    float bottomStart = self.parentBottomImageView.frame.origin.y;
    float topStart = self.parentTopImageView.frame.origin.y;
    
    if (self.parentTopImageView.alpha < 1.0 && y >0) {
        self.parentTopImageView.alpha = self.parentTopImageView.alpha + 0.01;
    }
    else if (self.parentTopImageView.alpha >0 && y<0) {
        self.parentTopImageView.alpha = self.parentTopImageView.alpha - 0.01;
    }
    
    if ((topEnd >= bottomStart) && (y>0) && (self.playedPinchInSoundOnce == NO)) {
        [TDCommon playSound:self.pinchInSound];
        self.playedPinchInSoundOnce = YES;
    }
    
    if (topStart <= 0 && y < 0)
    {
        return NO;
    }
    
    if (((topEnd >= bottomStart) && y >=0)) {
        if (self.parentOverTopImageView !=nil) {
            CGRect overFrame = self.parentOverTopImageView.frame;
            overFrame.origin.y = self.parentTopImageView.frame.origin.y - overFrame.size.height;
            self.parentOverTopImageView.frame = overFrame;
        }
        CGRect bottomFrame = self.parentBottomImageView.frame;
        bottomFrame.origin.y = topEnd;
        self.parentBottomImageView.frame = bottomFrame;
        self.parentTopImageView.alpha = 1;
        NSLog(@"RETURN top End : %f bottom start : %f",topEnd,bottomStart);
        return NO;
    }
    
    if ((bottomStart - topEnd < 20.0 || topEnd >267.0) && !self.playedPinchInSoundOnce && y>=0) {
        if (self.parentOverTopImageView !=nil) {
            CGRect overFrame = self.parentOverTopImageView.frame;
            overFrame.origin.y = self.parentTopImageView.frame.origin.y - overFrame.size.height;
            self.parentOverTopImageView.frame = overFrame;
        }
        CGRect bottomFrame = self.parentBottomImageView.frame;
        bottomFrame.origin.y = topEnd;
        self.parentBottomImageView.frame = bottomFrame;
        NSLog(@" IN here top End : %f bottom start : %f",topEnd,bottomStart);
        return YES;
    }
    if (y>0) {
        NSLog(@" IN BW top End : %f bottom start : %f",topEnd,bottomStart);
    }
    
    CGRect topFrame = self.parentTopImageView.frame;
    topFrame.origin.y += y ;
    self.parentTopImageView.frame = topFrame;
    
    if (self.parentOverTopImageView !=nil) {
        CGRect overFrame = self.parentOverTopImageView.frame;
        overFrame.origin.y = self.parentTopImageView.frame.origin.y - overFrame.size.height;
        self.parentOverTopImageView.frame = overFrame;
    }
    self.playedPinchInSoundOnce = NO;
    CGRect bottomFrame = self.parentBottomImageView.frame;
    bottomFrame.origin.y -= y;
    self.parentBottomImageView.frame = bottomFrame;
    //NSLog(@"top %@ frame %@",self.parentTopImageView.image,self.parentTopImageView);
    return YES;
}

- (void)animateOuterImageViewsAfterCompleteInTime:(float)timeInterval
{
    [UIView animateWithDuration:timeInterval animations:^{
        [self setInitialFramesForParentImages];
    }completion:^ (BOOL finished) {
        if (finished) {
            [self.navigationController popViewControllerAnimated:NO];   
        }}];
}

- (void)resetParentViews
{
    if (self.parentTopImageView !=nil) {
        CGRect frame = self.parentTopImageView.frame;
        frame.origin.y = 0;
        self.parentTopImageView.frame = frame;
        self.parentTopImageView.hidden = YES;
    }   
    
    if (self.parentOverTopImageView !=nil) {
        CGRect frame = self.parentOverTopImageView.frame;
        frame.origin.y = 0 - self.parentOverTopImageView.frame.size.height;
        self.parentOverTopImageView.frame = frame;
        self.parentOverTopImageView.hidden = YES;
    }
    
    if (self.parentBottomImageView !=nil) {
        CGRect frame = self.parentBottomImageView.frame;
        frame.origin.y = 480;
        self.parentBottomImageView.frame = frame;
        self.parentBottomImageView.hidden = YES;
    }
}

- (float)getTopViewOrigin{
    if (!self.parentTopImageView) {
        return self.parentBottomImageView.frame.origin.y;
    }
    return self.parentTopImageView.frame.origin.y;
}

- (void)addSnapshotImageView:(UIImageView *)imageView
{
    [self.backgroundView addSubview:imageView];
}

- (void)changeBackgroundViewColor:(UIColor*)color
{
    self.backgroundView.backgroundColor = color;
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

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsCommitRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
}
- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsAddRowAtIndexPath:(NSIndexPath *)indexPath{
    
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
#pragma mark JTTableViewGestureEditingRowDelegate

// This is needed to be implemented to let our delegate choose whether the panning gesture should work

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer commitEditingState:(JTTableViewCellEditingState)state forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer didEnterEditingState:(JTTableViewCellEditingState)state forRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (BOOL)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.editingFlag == TRUE) {
        return NO;
    }
    return YES;
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

-(void)addNewRowInDBAtIndexPath:(NSIndexPath *)indexpath
{
    
}
- (void)deleteCurrentRowAfterSwipeAtIndexpath: (NSIndexPath *)indexpath
{
    
}
 

@end
