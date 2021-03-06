
#import "JTTableViewGestureRecognizer.h"
#import <QuartzCore/QuartzCore.h>
#import "TransformableTableViewCell.h"
float lastUpdatedContentOffset = 0;

typedef enum {
    JTTableViewGestureRecognizerStateNone,
    JTTableViewGestureRecognizerStateDragging,
    JTTableViewGestureRecognizerStatePinching,
    JTTableViewGestureRecognizerStatePanning,
    JTTableViewGestureRecognizerStateMoving,
    JTTableViewGestureRecognizerStatePullingUp,
    JTTableViewGestureRecognizerStatePinchingIn,
} JTTableViewGestureRecognizerState;

CGFloat const JTTableViewCommitEditingRowDefaultLength = 80;
CGFloat const JTTableViewRowAnimationDuration          = 0.25;       // Rough guess is 0.25

@interface JTTableViewGestureRecognizer () <UIGestureRecognizerDelegate>
@property (nonatomic, weak) id <JTTableViewGestureAddingRowDelegate, JTTableViewGestureEditingRowDelegate, JTTableViewGestureMoveRowDelegate> delegate;
@property (nonatomic, weak) id <UITableViewDelegate>         tableViewDelegate;
@property (nonatomic, weak) UITableView                     *tableView;
@property (nonatomic, assign) CGFloat                        addingRowHeight;
@property (nonatomic, strong) NSIndexPath                   *addingIndexPath;
@property (nonatomic, assign) JTTableViewCellEditingState    addingCellState;
@property (nonatomic, assign) CGPoint                        startPinchingUpperPoint;
@property (nonatomic, strong) UIPinchGestureRecognizer      *pinchRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer        *panRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer  *longPressRecognizer;
@property (nonatomic, assign) JTTableViewGestureRecognizerState state;
@property (nonatomic, strong) UIImage                       *cellSnapshot;
@property (nonatomic, assign) CGFloat                        scrollingRate;
@property (nonatomic, strong) NSTimer                       *movingTimer;

//pinch to close
@property(nonatomic,assign) BOOL pinchToCloseCompleted;
@property(nonatomic,assign) CGPoint previousLowerPoint;
// pull up image views
@property(nonatomic,retain)  UIImageView *upArrowImageView;
@property(nonatomic,retain)  UIImageView *smileyImageView;
@property(nonatomic,retain)  UIView *switchUpView;
@property(nonatomic,retain)  UIView *pullUpView;
@property(nonatomic,retain)  UIImageView *arrowImageView;
@property(nonatomic,retain)  UIImageView *boxImageView;

- (NSString *)getSwitchLabelTextForPullDown;

- (void)updateAddingIndexPathForCurrentLocation;
- (void)commitOrDiscardCell;
- (void)createPinchOutView;
- (void)resetAfterPinchComplete:(int)imageCount;
- (void)resetAfterPinchInComplete:(int)imageCount;
- (void)resetAfterPinch:(int)imageCount;
@end


@implementation JTTableViewGestureRecognizer
@synthesize delegate, tableView, tableViewDelegate;
@synthesize addingIndexPath, startPinchingUpperPoint, addingRowHeight;
@synthesize pinchRecognizer, panRecognizer, longPressRecognizer;
@synthesize state, addingCellState;
@synthesize cellSnapshot, scrollingRate, movingTimer;
@synthesize upArrowImageView,smileyImageView,switchUpView,extraPullDelegate,pullUpToMoveDownDelegate;
@synthesize pinchDelegate;
@synthesize pinchToCloseCompleted;
@synthesize previousLowerPoint;
@synthesize  pullUpView,boxImageView,arrowImageView;
@synthesize rowEditingFlag,lastRowVisibleFlag;
- (void)scrollTable {
    // Scroll tableview while touch point is on top or bottom part

    CGPoint location        = CGPointZero;
    // Refresh the indexPath since it may change while we use a new offset
    location  = [self.longPressRecognizer locationInView:self.tableView];

    CGPoint currentOffset = self.tableView.contentOffset;
    CGPoint newOffset = CGPointMake(currentOffset.x, currentOffset.y + self.scrollingRate);
    if (newOffset.y < 0) {
        newOffset.y = 0;
    } else if (self.tableView.contentSize.height < self.tableView.frame.size.height) {
        newOffset = currentOffset;
    } else if (newOffset.y > self.tableView.contentSize.height - self.tableView.frame.size.height) {
        newOffset.y = self.tableView.contentSize.height - self.tableView.frame.size.height;
    } else {
    }
    [self.tableView setContentOffset:newOffset];
    
    if (location.y >= 0) {
        UIImageView *cellSnapshotView = (id)[self.tableView viewWithTag:CELL_SNAPSHOT_TAG];
        cellSnapshotView.center = CGPointMake(self.tableView.center.x, location.y);
    }
    
    [self updateAddingIndexPathForCurrentLocation];
}

- (void)updateAddingIndexPathForCurrentLocation {
    NSIndexPath *indexPath  = nil;
    CGPoint location        = CGPointZero;
    

    // Refresh the indexPath since it may change while we use a new offset
    location  = [self.longPressRecognizer locationInView:self.tableView];
    indexPath = [self.tableView indexPathForRowAtPoint:location];

    if (indexPath && ! [indexPath isEqual:self.addingIndexPath]) {
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.addingIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.delegate gestureRecognizer:self needsMoveRowAtIndexPath:self.addingIndexPath toIndexPath:indexPath];

        self.addingIndexPath = indexPath;

        [self.tableView endUpdates];
    }
}

#pragma mark Logic

- (void)commitOrDiscardCell {
    BOOL addedCell = NO;
    UITableViewCell *cell = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:self.addingIndexPath];
    [self.tableView beginUpdates];
    
    
    CGFloat commitingCellHeight = self.tableView.rowHeight;
    if ([self.delegate respondsToSelector:@selector(gestureRecognizer:heightForCommittingRowAtIndexPath:)]) {
        commitingCellHeight = [self.delegate gestureRecognizer:self
                                 heightForCommittingRowAtIndexPath:self.addingIndexPath];
    }
    
    if (cell.frame.size.height >= commitingCellHeight) {
        [self.delegate gestureRecognizer:self needsCommitRowAtIndexPath:self.addingIndexPath];
        addedCell = YES;
    } else {
        [self.delegate gestureRecognizer:self needsDiscardRowAtIndexPath:self.addingIndexPath];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.addingIndexPath] withRowAnimation:UITableViewRowAnimationMiddle];
    }
    
    // We would like to reload other rows as well
    [self.tableView performSelector:@selector(reloadVisibleRowsExceptIndexPath:) withObject:self.addingIndexPath afterDelay:JTTableViewRowAnimationDuration];

    [self.tableView endUpdates];
    
    // Restore contentInset while touch ends
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.25];  // Should not be less than the duration of row animation 
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [UIView commitAnimations];
    
    self.state = JTTableViewGestureRecognizerStateNone;
    NSLog(@"addedCell :%i, cell.frame.size.height %f, addingIndexPath %i",addedCell, cell.frame.size.height,self.addingIndexPath.row);
    //To make it editable
    if (addedCell && !(cell.frame.size.height > (3.0 * commitingCellHeight) && self.addingIndexPath.row ==0)) {
        float delay = 0.1;
        if (self.addingIndexPath.row >0) {
            delay = 0.25;
        }
        [self performSelector:@selector(makeNewlyAddedCellEditable) withObject:nil afterDelay:delay];
    }else {
        self.addingIndexPath = nil;
    }
}

- (void)makeNewlyAddedCellEditable
{
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.addingIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    TransformableTableViewCell *newCell = (id)[self.tableView cellForRowAtIndexPath:self.addingIndexPath];
    newCell.addingCellFlag = TRUE;
    [newCell labelTapped];
    newCell.nameTextField.text = @"";
    self.addingIndexPath = nil;
}
#pragma mark Action

- (void)pinchGestureRecognizer:(UIPinchGestureRecognizer *)recognizer {
    static int imageCount;
        NSLog(@"%d %f %f", [recognizer numberOfTouches], [recognizer velocity], [recognizer scale]);
    if (recognizer.state == UIGestureRecognizerStateEnded || [recognizer numberOfTouches] < 2 || recognizer.state == UIGestureRecognizerStateCancelled) {
        if (self.addingIndexPath && self.state == JTTableViewGestureRecognizerStatePinching) {
            [self commitOrDiscardCell];
        }
        else if (self.state == JTTableViewGestureRecognizerStatePinchingIn){
            if (self.pinchToCloseCompleted) {
                [self resetAfterPinchComplete:imageCount];
            }
            else {  [self resetAfterPinchInComplete:imageCount];
            }
        }
        return;
    }
    
    CGPoint location1 = [recognizer locationOfTouch:0 inView:self.tableView];
    CGPoint location2 = [recognizer locationOfTouch:1 inView:self.tableView];
    CGPoint upperPoint = location1.y < location2.y ? location1 : location2;
    CGPoint lowerPoint = location1.y > location2.y ? location1 : location2;
    CGRect  rect = (CGRect){location1, location2.x - location1.x, location2.y - location1.y};
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (recognizer.scale >1) {
        NSAssert(self.addingIndexPath != nil, @"self.addingIndexPath must not be nil, we should have set it in recognizerShouldBegin");

        self.state = JTTableViewGestureRecognizerStatePinching;
            self.pinchToCloseCompleted = NO;
        // Setting up properties for referencing later when touches changes
        self.startPinchingUpperPoint = upperPoint;

        // Creating contentInset to fulfill the whole screen, so our tableview won't occasionaly
        // bounds back to the top while we don't have enough cells on the screen
        self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.frame.size.height, 0, self.tableView.frame.size.height, 0);

        [self.tableView beginUpdates];

        [self.delegate gestureRecognizer:self needsAddRowAtIndexPath:self.addingIndexPath];

        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:self.addingIndexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        [self.tableView endUpdates];
        }
        else {
            self.state = JTTableViewGestureRecognizerStatePinchingIn;
            self.previousLowerPoint = lowerPoint;
            NSLog(@"$$$$$Pinch OUt Began from :%f",self.previousLowerPoint.y);
            imageCount = 0;
            imageCount =[self createPinchOutViewAndReturnImageCount];
        }
    } 
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        if (self.state == JTTableViewGestureRecognizerStatePinching) {

        CGFloat diffRowHeight = CGRectGetHeight(rect) - CGRectGetHeight(rect)/[recognizer scale];
        
        //NSLog(@"%f %f %f %f",self.addingRowHeight, CGRectGetHeight(rect), CGRectGetHeight(rect)/[recognizer scale], [recognizer scale]);
        if (self.addingRowHeight - diffRowHeight >= 1 || self.addingRowHeight - diffRowHeight <= -1) {
            self.addingRowHeight = diffRowHeight;
            [self.tableView reloadData];
        }
        
        // Scrolls tableview according to the upper touch point to mimic a realistic
        // dragging gesture
        CGPoint newUpperPoint = upperPoint;
        CGFloat diffOffsetY = self.startPinchingUpperPoint.y - newUpperPoint.y;
        CGPoint newOffset   = (CGPoint){self.tableView.contentOffset.x, self.tableView.contentOffset.y+diffOffsetY};
        [self.tableView setContentOffset:newOffset animated:NO];
        }
        else if (self.state == JTTableViewGestureRecognizerStatePinchingIn) {
            float scrollingAmount = 210.0;
            if (recognizer.scale >=0.35) {
                scrollingAmount = 20.0/13.0 * 210.0 * (1.0 - recognizer.scale);
            }
            if (imageCount>0) {
        for (int i = imageCount - 1; i >=0; i--){
                UIImageView *snapShotView = (UIImageView *)[self.tableView viewWithTag:CELL_SNAPSHOT_TAG +i +1];
                [[snapShotView superview] bringSubviewToFront:snapShotView];
            }
        }
    BOOL continuePinching = [self.pinchDelegate animateImageViewsbydistance:scrollingAmount];
    if (continuePinching)
    {
        if (imageCount >0) {
        [self animateSnapShotViews:imageCount withScale:recognizer.scale byDistance:scrollingAmount];
        }
        self.pinchToCloseCompleted = NO;
    }
    else if(continuePinching == NO && scrollingAmount > 0)
    {
        self.pinchToCloseCompleted = YES;
    }
    
    else{
        self.pinchToCloseCompleted = NO;
    }
}}
}

#pragma mark - RESET AFTER PINCH methods 
- (void)resetAfterPinch:(int)imageCount
{
    for (int i = 0; i<imageCount;i++) {
     UIImageView *snapShotView = (UIImageView *)[self.tableView viewWithTag:CELL_SNAPSHOT_TAG+ i+1];
        [snapShotView removeFromSuperview];
        snapShotView = nil;
    }
}

- (void)resetAfterPinchComplete:(int)imageCount
{
    [self resetAfterPinch:imageCount];
    [self.pinchDelegate animateOuterImageViewsAfterCompleteInTime:0.4];
    self.state = JTTableViewGestureRecognizerStateNone;
}

- (void)resetAfterPinchInComplete:(int)imageCount
{
    [UIView animateWithDuration:1.0 animations:^{
    [self animateSnapShotViews:imageCount withScale:1 byDistance:0];
    [self.pinchDelegate animateImageViewsbydistance:0];
    }];
    [self resetAfterPinch:imageCount];  
    [self.pinchDelegate changeBackgroundViewColor:[UIColor clearColor]];
    [self.pinchDelegate hideBackgroundView:YES];
    [self.pinchDelegate resetParentViews];
    self.state = JTTableViewGestureRecognizerStateNone;
}

#pragma mark- PINCH IN
//this method is fired from pinchin state changed
- (void)animateSnapShotViews:(int)imageCount withScale:(float)scale byDistance:(float)scrollAmount
{
    for (int i = 0; i < imageCount; i++){
        UIImageView *snapShotView = (UIImageView *)[[self.tableView superview] viewWithTag:CELL_SNAPSHOT_TAG + i + 1];
        CGRect frame =snapShotView.frame;
        float scrollAmountForImage;
        scrollAmountForImage =  scrollAmount - ((59 * i) * (1- scale) * 20/13);
        if (scale < 0.35) {
            scrollAmountForImage = scrollAmount -(59 *i)  ;
        }
        frame.origin.y = (60 * i) + scrollAmountForImage;
        snapShotView.frame =frame;
         NSLog(@"Pinch out : y :%f",frame.origin.y);
    }
    
}

//this method creates pinch in view when pinch in began
- (int)createPinchOutViewAndReturnImageCount
{
    NSMutableArray *imageArray;
    NSArray *indexPathArray;
    int imageCount = 0;
    if (!imageArray && !indexPathArray) {
    imageArray= [[NSMutableArray alloc] init];
    indexPathArray=[self.tableView indexPathsForRowsInRect:self.tableView.bounds];
    for (NSIndexPath *indexpath in indexPathArray) {
        UIImage *cellImage = [self createSnapShotOfCellAtIndexPath:indexpath];
        [imageArray addObject:cellImage];
    }
        imageCount = [imageArray count];
    }
    // We create an imageView for caching the cell snapshot here
    if (imageCount >0) {
    for (int i = 0; i <imageCount; i++){
    UIImageView *snapShotView = (UIImageView *)[self.tableView viewWithTag:CELL_SNAPSHOT_TAG +i +1];
        if ( ! snapShotView) {
            UIImage *cellImage = [imageArray objectAtIndex:i];
            NSIndexPath *indexPath = [indexPathArray objectAtIndex:i];
            snapShotView = [[UIImageView alloc] initWithImage:cellImage];
            snapShotView.tag = CELL_SNAPSHOT_TAG + i+1;
            CGRect rect = [self.tableView rectForRowAtIndexPath:indexPath];
            snapShotView.frame = CGRectOffset(snapShotView.bounds, rect.origin.x, rect.origin.y);
            [self.pinchDelegate addSnapshotImageView:snapShotView];
        }
    }
    }
    indexPathArray = nil;
    imageArray = nil;
    [self.pinchDelegate changeBackgroundViewColor:[UIColor blackColor]];
    return imageCount;
}

//this method creates a snapshot of row being used for animation while pinch in or long press
-(UIImage *)createSnapShotOfCellAtIndexPath:(NSIndexPath *)indexPath{    
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIGraphicsBeginImageContextWithOptions(cell.bounds.size, NO, 0);
    [cell.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *cellImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return cellImage;
}

- (void)panGestureRecognizer:(UIPanGestureRecognizer *)recognizer {
    if ((recognizer.state == UIGestureRecognizerStateBegan
        || recognizer.state == UIGestureRecognizerStateChanged)
        && [recognizer numberOfTouches] > 0) {

        // TODO: should ask delegate before changing cell's content view

        CGPoint location1 = [recognizer locationOfTouch:0 inView:self.tableView];
        
        NSIndexPath *indexPath = self.addingIndexPath;
        if ( ! indexPath) {
            indexPath = [self.tableView indexPathForRowAtPoint:location1];
            self.addingIndexPath = indexPath;
        }
        
        self.state = JTTableViewGestureRecognizerStatePanning;
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

        CGPoint translation = [recognizer translationInView:self.tableView];
        cell.contentView.frame = CGRectOffset(cell.contentView.bounds, translation.x, 0);

        if ([self.delegate respondsToSelector:@selector(gestureRecognizer:didChangeContentViewTranslation:forRowAtIndexPath:)]) {
            [self.delegate gestureRecognizer:self didChangeContentViewTranslation:translation forRowAtIndexPath:indexPath];
        }
        
        CGFloat commitEditingLength = JTTableViewCommitEditingRowDefaultLength;
        if ([self.delegate respondsToSelector:@selector(gestureRecognizer:lengthForCommitEditingRowAtIndexPath:)]) {
            commitEditingLength = [self.delegate gestureRecognizer:self lengthForCommitEditingRowAtIndexPath:indexPath];
        }
        if (fabsf(translation.x) >= commitEditingLength) {
            if (self.addingCellState == JTTableViewCellEditingStateMiddle) {
                self.addingCellState = translation.x > 0 ? JTTableViewCellEditingStateRight : JTTableViewCellEditingStateLeft;
            }
        } else {
            if (self.addingCellState != JTTableViewCellEditingStateMiddle) {
                self.addingCellState = JTTableViewCellEditingStateMiddle;
            }
        }

        if ([self.delegate respondsToSelector:@selector(gestureRecognizer:didEnterEditingState:forRowAtIndexPath:)]) {
            [self.delegate gestureRecognizer:self didEnterEditingState:self.addingCellState forRowAtIndexPath:indexPath];
        }

    } else if (recognizer.state == UIGestureRecognizerStateEnded) {

        NSIndexPath *indexPath = self.addingIndexPath;

        // Removes addingIndexPath before updating then tableView will be able
        // to determine correct table row height
        self.addingIndexPath = nil;

        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        CGPoint translation = [recognizer translationInView:self.tableView];
        
        CGFloat commitEditingLength = JTTableViewCommitEditingRowDefaultLength;
        if ([self.delegate respondsToSelector:@selector(gestureRecognizer:lengthForCommitEditingRowAtIndexPath:)]) {
            commitEditingLength = [self.delegate gestureRecognizer:self lengthForCommitEditingRowAtIndexPath:indexPath];
        }
        if (fabsf(translation.x) >= commitEditingLength) {
            if ([self.delegate respondsToSelector:@selector(gestureRecognizer:commitEditingState:forRowAtIndexPath:)]) {
                [self.delegate gestureRecognizer:self commitEditingState:self.addingCellState forRowAtIndexPath:indexPath];
            }
        } else {
            [UIView beginAnimations:@"" context:nil];
            cell.contentView.frame = cell.contentView.bounds;
            [UIView commitAnimations];
        }
        
        self.addingCellState = JTTableViewCellEditingStateMiddle;
        self.state = JTTableViewGestureRecognizerStateNone;
    }
}

- (void)longPressGestureRecognizer:(UILongPressGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.state = JTTableViewGestureRecognizerStateMoving;
        
        UIImage *cellImage = [self createSnapShotOfCellAtIndexPath:indexPath];
        
        // We create an imageView for caching the cell snapshot here
        UIImageView *snapShotView = (UIImageView *)[self.tableView viewWithTag:CELL_SNAPSHOT_TAG];
        if ( ! snapShotView) {
            snapShotView = [[UIImageView alloc] initWithImage:cellImage];
            snapShotView.tag = CELL_SNAPSHOT_TAG;
            [self.tableView addSubview:snapShotView];
            CGRect rect = [self.tableView rectForRowAtIndexPath:indexPath];
            snapShotView.frame = CGRectOffset(snapShotView.bounds, rect.origin.x, rect.origin.y);
        }
        // Make a zoom in effect for the cell
        [UIView beginAnimations:@"zoomCell" context:nil];
        snapShotView.transform = CGAffineTransformMakeScale(1.1, 1.1);
        snapShotView.center = CGPointMake(self.tableView.center.x, location.y);
        [UIView commitAnimations];

        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.delegate gestureRecognizer:self needsCreatePlaceholderForRowAtIndexPath:indexPath];
        
        self.addingIndexPath = indexPath;

        [self.tableView endUpdates];

        // Start timer to prepare for auto scrolling
        self.movingTimer = [NSTimer timerWithTimeInterval:1/8 target:self selector:@selector(scrollTable) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.movingTimer forMode:NSDefaultRunLoopMode];

    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        // While long press ends, we remove the snapshot imageView
        
        __block __weak UIImageView *snapShotView = (UIImageView *)[self.tableView viewWithTag:CELL_SNAPSHOT_TAG];
        __block __weak JTTableViewGestureRecognizer *weakSelf = self;
        
        // We use self.addingIndexPath directly to make sure we dropped on a valid indexPath
        // which we've already ensure while UIGestureRecognizerStateChanged
        __block __weak NSIndexPath *indexPath = self.addingIndexPath;
        
        // Stop timer
        [self.movingTimer invalidate]; self.movingTimer = nil;
        self.scrollingRate = 0;

        [UIView animateWithDuration:JTTableViewRowAnimationDuration
                         animations:^{
                             CGRect rect = [weakSelf.tableView rectForRowAtIndexPath:indexPath];
                             snapShotView.transform = CGAffineTransformIdentity;    // restore the transformed value
                             snapShotView.frame = CGRectOffset(snapShotView.bounds, rect.origin.x, rect.origin.y);
                         } completion:^(BOOL finished) {
                             [snapShotView removeFromSuperview];
                             
                             [weakSelf.tableView beginUpdates];
                             [weakSelf.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
                             [weakSelf.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
                             [weakSelf.delegate gestureRecognizer:weakSelf needsReplacePlaceholderForRowAtIndexPath:indexPath];
                             [weakSelf.tableView endUpdates];
                             
                             //[weakSelf.tableView reloadVisibleRowsExceptIndexPath:indexPath];
                             [weakSelf.tableView reloadData];
                             // Update state and clear instance variables
                             weakSelf.cellSnapshot = nil;
                             weakSelf.addingIndexPath = nil;
                             weakSelf.state = JTTableViewGestureRecognizerStateNone;
                         }];


    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        // While our finger moves, we also moves the snapshot imageView
        UIImageView *snapShotView = (UIImageView *)[self.tableView viewWithTag:CELL_SNAPSHOT_TAG];
        snapShotView.center = CGPointMake(self.tableView.center.x, location.y);

        CGRect rect      = self.tableView.bounds;
        CGPoint location = [self.longPressRecognizer locationInView:self.tableView];
        location.y -= self.tableView.contentOffset.y;       // We needed to compensate actual contentOffset.y to get the relative y position of touch.
        
        [self updateAddingIndexPathForCurrentLocation];
        
        CGFloat bottomDropZoneHeight = self.tableView.bounds.size.height / 6;
        CGFloat topDropZoneHeight    = bottomDropZoneHeight;
        CGFloat bottomDiff = location.y - (rect.size.height - bottomDropZoneHeight);
        if (bottomDiff > 0) {
            self.scrollingRate = bottomDiff / (bottomDropZoneHeight / 1);
        } else if (location.y <= topDropZoneHeight) {
            self.scrollingRate = -(topDropZoneHeight - MAX(location.y, 0)) / bottomDropZoneHeight;
        } else {
            self.scrollingRate = 0;
        }
    }
}

#pragma mark UIGestureRecognizer

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {

    if (gestureRecognizer == self.panRecognizer) {
        if ( ! [self.delegate conformsToProtocol:@protocol(JTTableViewGestureEditingRowDelegate)]) {
            return NO;
        }
        
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        
        CGPoint point = [pan translationInView:self.tableView];
        CGPoint location = [pan locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];

        // The pan gesture recognizer will fail the original scrollView scroll
        // gesture, we wants to ensure we are panning left/right to enable the
        // pan gesture.
        if (fabsf(point.y) > fabsf(point.x)) {
            return NO;
        } else if (indexPath == nil) {
            return NO;
        } else if (indexPath) {
            BOOL canEditRow = [self.delegate gestureRecognizer:self canEditRowAtIndexPath:indexPath];
            return canEditRow;
        }
    } else if (gestureRecognizer == self.pinchRecognizer) {
        if ( ! [self.delegate conformsToProtocol:@protocol(JTTableViewGestureAddingRowDelegate)]) {
            NSLog(@"Should not begin pinch");
            return NO;
        }
        if (  [self.pinchDelegate getEditingFlag]) {
            NSLog(@"Should not begin pinch,editing");
            return NO;
        }

        CGPoint location1 = [gestureRecognizer locationOfTouch:0 inView:self.tableView];
        CGPoint location2 = [gestureRecognizer locationOfTouch:1 inView:self.tableView];

        CGRect  rect = (CGRect){location1, location2.x - location1.x, location2.y - location1.y};
        NSArray *indexPaths = [self.tableView indexPathsForRowsInRect:rect];
        if ([indexPaths count] == 0 && [self.pinchRecognizer scale] >1) {
            self.addingIndexPath = nil;
            return NO;
        }
        else if ([indexPaths count] == 0 && [self.pinchRecognizer scale] <= 1){
            return YES;
        }
        NSIndexPath *firstIndexPath = [indexPaths objectAtIndex:0];
        NSIndexPath *lastIndexPath  = [indexPaths lastObject];
        NSInteger    midIndex = ((float)(firstIndexPath.row + lastIndexPath.row) / 2) + 0.5;
        NSIndexPath *midIndexPath = [NSIndexPath indexPathForRow:midIndex inSection:firstIndexPath.section];

        if ([self.delegate respondsToSelector:@selector(gestureRecognizer:willCreateCellAtIndexPath:)]) {
            self.addingIndexPath = [self.delegate gestureRecognizer:self willCreateCellAtIndexPath:midIndexPath];
        } else {
            self.addingIndexPath = midIndexPath;
        }

        if ( ! self.addingIndexPath) {
            NSLog(@"Should not begin pinch");
            return NO;
        }

    } else if (gestureRecognizer == self.longPressRecognizer) {
        
        CGPoint location = [gestureRecognizer locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];

        if (indexPath && [self.delegate conformsToProtocol:@protocol(JTTableViewGestureMoveRowDelegate)]) {
            BOOL canMoveRow = [self.delegate gestureRecognizer:self canMoveRowAtIndexPath:indexPath];
            return canMoveRow;
        }
        return NO;
    }
    return YES;
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath isEqual:self.addingIndexPath]
        && (self.state == JTTableViewGestureRecognizerStatePinching || self.state == JTTableViewGestureRecognizerStateDragging)) {
        // While state is in pinching or dragging mode, we intercept the row height
        // For Moving state, we leave our real delegate to determine the actual height
        return MAX(1, self.addingRowHeight);
    }
    
    CGFloat normalCellHeight = aTableView.rowHeight;
    if ([self.tableViewDelegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
        normalCellHeight = [self.tableViewDelegate tableView:aTableView heightForRowAtIndexPath:indexPath];
    }
    return normalCellHeight;
}

- (void)tableView:(UITableView *)aTableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.tableViewDelegate respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)]) {
        [self.tableViewDelegate tableView:aTableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
    
    if (indexPath.row == [self.tableView numberOfRowsInSection:0] - 1) {
        self.lastRowVisibleFlag = YES;
    }
    else {
             self.lastRowVisibleFlag =NO;
         }
}
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ( ! [self.delegate conformsToProtocol:@protocol(JTTableViewGestureAddingRowDelegate)]) {
        if ([self.tableViewDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
            [self.tableViewDelegate scrollViewDidScroll:scrollView];
        }
        return;
    }
        float contentOffset = scrollView.contentOffset.y;
   
    // We try to create a new cell when the user tries to drag the content to and offset of negative value
    if (contentOffset < 0) {
        // Here we make sure we're not conflicting with the pinch event,
        // ! scrollView.isDecelerating is to detect if user is actually
        // touching on our scrollView, if not, we should assume the scrollView
        // needed not to be adding cell
        if ( ! self.addingIndexPath && self.state == JTTableViewGestureRecognizerStateNone && ! scrollView.isDecelerating) {
            self.state = JTTableViewGestureRecognizerStateDragging;

            self.addingIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            if ([self.delegate respondsToSelector:@selector(gestureRecognizer:willCreateCellAtIndexPath:)]) {
                self.addingIndexPath = [self.delegate gestureRecognizer:self willCreateCellAtIndexPath:self.addingIndexPath];
            }

            [self.tableView beginUpdates];
            [self.delegate gestureRecognizer:self needsAddRowAtIndexPath:self.addingIndexPath];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:self.addingIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            self.addingRowHeight = fabsf(scrollView.contentOffset.y);
            [self.tableView endUpdates];
        }
    }
    else if(contentOffset >0){
        [self scrollViewDidScrollUpForPull:scrollView];
    }
    if (self.state == JTTableViewGestureRecognizerStateDragging) {
        self.addingRowHeight += scrollView.contentOffset.y * -1;
        [self.tableView reloadData];
        [scrollView setContentOffset:CGPointZero];
    }

}

// this method handles when scroll view is pulled up
- (void)scrollViewDidScrollUpForPull:(UIScrollView *)scrollView {

     if (self.rowEditingFlag) {
        return;
    }

    if (([[self.extraPullDelegate getParentName] isEqualToString:@"Menu"] && [[self getSwitchLabelTextForPullUp] isEqualToString:@"Nothing beyond it!!"]) ) {
        return;
    }
    
    float contentOffsetY = scrollView.contentOffset.y;
    float initialContentOffsetY = 0;
    
    if(scrollView.contentSize.height >= scrollView.bounds.size.height)
    {
        initialContentOffsetY =  scrollView.contentSize.height - scrollView.bounds.size.height;

    }
    
    if ( initialContentOffsetY != 0  && (!self.lastRowVisibleFlag  && contentOffsetY < initialContentOffsetY )) {
        return;
    }
    else 
    {
        NSLog(@"lastRowVisibleFlag %i ,content offset %f Required %f,state : %d scroll view decelrating %i",self.lastRowVisibleFlag,contentOffsetY, initialContentOffsetY,self.state,scrollView.decelerating);
      
        // Here we make sure we're not conflicting with scrollview jumping back
        // ! scrollView.isDecelerating is to detect if user is actually
        // touching on our scrollView, if not, we should assume the scrollView
    if (contentOffsetY > initialContentOffsetY  && self.state == JTTableViewGestureRecognizerStateNone && !scrollView.decelerating) {
        [self createViewForPullUp];
    }
    if (![self.extraPullDelegate checkedRowsExist] && [[self.extraPullDelegate getParentName] isEqualToString:@"Lists"]) {
            return;
    }
        
    if(contentOffsetY >= (initialContentOffsetY + 100)  && self.state == JTTableViewGestureRecognizerStateNone && !scrollView.decelerating ) {
        NSLog(@"Pull Up Detected");
         [self.extraPullDelegate playSound];
        if (self.upArrowImageView != nil) [self rotateImage:self.upArrowImageView duration:0.1 curve:1 degrees:180.0];
        [self pullUpToClearComplete];
        self.state = JTTableViewGestureRecognizerStatePullingUp;
    }
    
    else if (contentOffsetY < (initialContentOffsetY + 100)  && self.state == JTTableViewGestureRecognizerStatePullingUp && !scrollView.decelerating){
            NSLog(@"Pull Up Not Detected");
            if (self.upArrowImageView != nil) [self rotateImage:self.upArrowImageView duration:0.1 curve:1 degrees:360.0];
            self.state = JTTableViewGestureRecognizerStateNone;
            [self pullUpToClearNotDetected];
    }
        
    float difference = (contentOffsetY - lastUpdatedContentOffset) * 55/100; 
            [self animateArrowForPullUpbyScrolledDistance:difference];
        
    lastUpdatedContentOffset = contentOffsetY;
    }
    
}
#define DEGREES_TO_RADIANS(angle) (angle / 180.0 * M_PI)
// this metho performed when pull up is detected or not detected
- (void)rotateImage:(UIImageView *)image duration:(NSTimeInterval)duration 
              curve:(int)curve degrees:(CGFloat)degrees
{
    // Setup the animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationRepeatCount:1.0];
    // The transform matrix
    CGAffineTransform transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(degrees));
    image.transform = transform;
    
    // Commit the changes
    [UIView commitAnimations];
}

//this method is called when scroll view stops dragging
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ( ! [self.delegate conformsToProtocol:@protocol(JTTableViewGestureAddingRowDelegate)]) {
        if ([self.tableViewDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
            [self.tableViewDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
        }
        return;
    }

    if (self.state == JTTableViewGestureRecognizerStatePullingUp)
    {
        self.state = JTTableViewGestureRecognizerStateNone;
        [self removePullViews];
        [self actionAfterPulllUpCompleted];
    }
    
    if (self.state == JTTableViewGestureRecognizerStateNone)
    {
        NSLog(@" STATE NONE");
        [self removePullViews];
    }

    if (self.state == JTTableViewGestureRecognizerStateDragging) {
        self.state = JTTableViewGestureRecognizerStateNone;
        [self commitOrDiscardCell];
    }
    lastUpdatedContentOffset = self.tableView.contentOffset.y;
}

- (void)actionAfterPulllUpCompleted
{
    if ([[self.extraPullDelegate getParentName] isEqualToString:@"Lists"])  [self.extraPullDelegate deleteCheckedRows];
    else 
        [self.pullUpToMoveDownDelegate addChildView];
}

- (void)removePullViews{
    if (self.arrowImageView != nil) {
        [self.arrowImageView removeFromSuperview];
        NSLog(@" ARROW REMOVED ");
        self.arrowImageView = nil;
    }
    if (self.boxImageView != nil) {
        [self.boxImageView removeFromSuperview];
        self.boxImageView = nil;
    }
    
    if (self.pullUpView !=nil) {
        [self.pullUpView removeFromSuperview];
        self.pullUpView = nil;
    }
    if (self.switchUpView != nil) {
        [self.switchUpView removeFromSuperview];
        self.switchUpView = nil;
    }
    if (self.upArrowImageView != nil) {
        [self.upArrowImageView removeFromSuperview];
        self.upArrowImageView = nil;
    }
    if (self.smileyImageView != nil) {
        [self.smileyImageView removeFromSuperview];
        self.smileyImageView = nil;
    }
}

//this method is to enable pull up not to get detected while editing
- (void)setEditingFlag:(BOOL)flag
{
    self.editingFlag = flag;
}
# pragma mark - PULL UP METHODS

#define EMPTY_BOX [UIImage imageNamed:@"empty_box.png"]
#define FULL_BOX [UIImage imageNamed:@"full_box.png"]
#define BIG_ARROW_UP @"arrow-up.png"
#define BIG_ARROW_DOWN @"arrow-down.png"
#define SMILEY @"smilie.png"
#define EXTRA_PULL_UP_ORIGINY 485
#define EXTRA_PULL_DOWN_ORIGINY -50

//following methods are to create different views on pull up based on the view which is pulled up
- (void)createViewForPullUp
{
    // check If it is Items view controller,then create pull up view to remove checked items
    
    if ([[self.extraPullDelegate getParentName] isEqualToString:@"Lists"])  [self createPullUpViewToComplete];
    else 
        [self createPullUpViewToMoveDown];
}

-(void)createPullUpViewToMoveDown
{
    if(self.state == JTTableViewGestureRecognizerStatePullingUp  || self.state == JTTableViewGestureRecognizerStateNone)
    {
        if (self.tableView.bounds.size.height > self.tableView.contentSize.height) {
        [self createArrowImageViewWithImageName:BIG_ARROW_UP atHeight:self.tableView.bounds.size.height ];
        [self createSwitchUpViewAtHeight:self.tableView.bounds.size.height ];
        }
        else {
            [self createArrowImageViewWithImageName:BIG_ARROW_UP atHeight:self.tableView.contentSize.height + 20];
            [self createSwitchUpViewAtHeight:self.tableView.contentSize.height + 20];
        }
    }
}

#pragma mark- pull up to clear

- (void)pullUpToClearComplete{
    self.boxImageView.image = FULL_BOX;
    self.arrowImageView.hidden = YES;
   // pullUpDetected = TRUE;
   // NSLog(@"pullUpDetected %i",pullUpDetected);
}

- (void)pullUpToClearNotDetected{
    self.arrowImageView.hidden = NO;
    self.boxImageView.image = EMPTY_BOX;
}

- (void)createPullUpViewToComplete
{   float heightTobeTaken = 0;
    float height = self.tableView.bounds.size.height;
    float contentSizeHeight = self.tableView.contentSize.height;
    heightTobeTaken = height + 10;
    if (height <= contentSizeHeight) {
        heightTobeTaken = contentSizeHeight + 10;
    }
    NSLog(@"height :%f",heightTobeTaken);
    [self createPullUpViewAtHeight:heightTobeTaken + 50];
    if ([self.extraPullDelegate checkedRowsExist]) // checks If already checked rows exists
    {
        [self createArrowImageViewAtHeight: heightTobeTaken];
    }
    else
    {
        self.pullUpView.alpha = 0.2;
        return;
    }
}

- (void)animateArrowForPullUpbyScrolledDistance:(float)deltaY
{
    if (self.arrowImageView && self.state == JTTableViewGestureRecognizerStateNone) {
        CGRect arrowFrame = self.arrowImageView.frame;
        arrowFrame.origin.y += deltaY ;
        [self.arrowImageView setFrame:arrowFrame];
        NSLog(@"difference%f frame %f", deltaY,arrowFrame.origin.y);
    }
}

- (void)createArrowImageViewAtHeight:(float)height
{
    if (self.arrowImageView != nil) {
        return;
    }
    self.arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
    self.arrowImageView.backgroundColor = [UIColor clearColor];
    [self.arrowImageView setFrame:CGRectMake(105, height, 10, 13)];
    [self.tableView addSubview:self.arrowImageView];
}

- (void)createPullUpViewAtHeight:(float)height
{
    if (self.pullUpView != nil) {
        return;
    }
    self.boxImageView = [[UIImageView alloc] initWithImage:EMPTY_BOX];
    self.boxImageView.backgroundColor = [UIColor clearColor];
    [self.boxImageView setFrame:CGRectMake(0, 13, 22, 10)];
    
    UILabel *pullUpLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 100,30)];
    pullUpLabel.text = @"Pull to Clear";
    pullUpLabel.textAlignment = UITextAlignmentCenter;
    pullUpLabel.textColor = [UIColor whiteColor];
    pullUpLabel.backgroundColor = [UIColor clearColor];
    pullUpLabel.font = [UIFont boldSystemFontOfSize:16];
    
    self.pullUpView = [[UIView alloc] initWithFrame:CGRectMake(100, height, 130, 30)];
    self.pullUpView.backgroundColor = [UIColor clearColor];
    [self.pullUpView addSubview:pullUpLabel];
    [self.pullUpView addSubview:self.boxImageView];
    [self.tableView addSubview:self.pullUpView];
}

- (void)createArrowImageViewWithImageName:(NSString *)imageName atHeight:(float)originY
{
    if (self.upArrowImageView != nil) {
        self.upArrowImageView.hidden = NO;
        return;
    }
    else if (self.smileyImageView != nil) {
        self.smileyImageView.hidden = NO;
        return;
    }
    if(self.state == JTTableViewGestureRecognizerStatePullingUp || self.state == JTTableViewGestureRecognizerStateNone){

        if (![[self.extraPullDelegate getParentName] isEqualToString:@"Lists"]) {
            [self createBigArrowImageViewWithImage:imageName atHeight:originY];
        }
        else {
            [self createSmileyImageViewWithImage:imageName atHeight:originY];    
        }
    }
}

- (void)createBigArrowImageViewWithImage:(NSString *)imageName atHeight:(float)originY
{
    self.upArrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    self.upArrowImageView.backgroundColor = [UIColor clearColor];
    [self.upArrowImageView setFrame:CGRectMake(80, originY, 18, 24)];
    [self.tableView addSubview:self.upArrowImageView];   
}

- (void)createSmileyImageViewWithImage:(NSString *)imageName atHeight:(float)originY
{
    self.smileyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    self.smileyImageView.backgroundColor = [UIColor clearColor];
    [self.smileyImageView setFrame:CGRectMake(70, originY -5, 33, 37)];
    [self.tableView addSubview:self.smileyImageView];
}

- (void)createSwitchUpViewAtHeight:(float)originY
{
    if (self.switchUpView != nil) {
        self.switchUpView.hidden = NO;
        return;
    }
    
    UILabel *switchUpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200,30)];
    switchUpLabel.text = [self getSwitchLabelTextForPullUp];
    switchUpLabel.textAlignment = UITextAlignmentLeft;
    switchUpLabel.textColor = [UIColor whiteColor];
    switchUpLabel.backgroundColor = [UIColor clearColor];
    switchUpLabel.font = [UIFont boldSystemFontOfSize:18];
    
    self.switchUpView = [[UIView alloc] initWithFrame:CGRectMake(115, originY, 200, 30)];
    self.switchUpView.backgroundColor = [UIColor clearColor];
    [self.switchUpView addSubview:switchUpLabel];
    [self.tableView addSubview:self.switchUpView];
    if ([[self.extraPullDelegate getParentName] isEqualToString:@"Menu"] && [switchUpLabel.text isEqualToString:@"Nothing beyond it!!"]) {
    self.switchUpView.hidden = YES;
        self.upArrowImageView.hidden = YES;
    }
}

- (NSString *)getSwitchLabelTextForPullDown
{
    NSString *switchLabelText = nil;
    NSString * parent = [self.extraPullDelegate getParentName];
    if (parent!= nil) {
        switchLabelText = [NSString stringWithFormat:@"Switch to %@",parent];
    }
    else {
        switchLabelText = @"Nothing beyond it!!";
    }
    return switchLabelText;
}

- (NSString *)getSwitchLabelTextForPullUp
{
    NSString *switchLabelText = nil;
    NSString * child = [self.extraPullDelegate getChildName];
    if (child!= nil) {
        switchLabelText = child;
    }
    else {
        switchLabelText = @"Nothing beyond it!!";
    }
    return switchLabelText;
}

#pragma mark NSProxy

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    [anInvocation invokeWithTarget:self.tableViewDelegate];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [(NSObject *)self.tableViewDelegate methodSignatureForSelector:aSelector];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    NSAssert(self.tableViewDelegate != nil, @"self.tableViewDelegate should not be nil, assign your tableView.delegate before enabling gestureRecognizer", nil);
    if ([self.tableViewDelegate respondsToSelector:aSelector]) {
        return YES;
    }
    return [[self class] instancesRespondToSelector:aSelector];
}

#pragma mark Class method

+ (JTTableViewGestureRecognizer *)gestureRecognizerWithTableView:(UITableView *)tableView delegate:(id)delegate {
    JTTableViewGestureRecognizer *recognizer = [[JTTableViewGestureRecognizer alloc] init];
    recognizer.delegate             = (id)delegate;
    recognizer.tableView            = tableView;
    recognizer.tableViewDelegate    = tableView.delegate;     // Assign the delegate before chaning the tableView's delegate
    tableView.delegate              = recognizer;
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:recognizer action:@selector(pinchGestureRecognizer:)];
    [tableView addGestureRecognizer:pinch];
    pinch.delegate             = recognizer;
    recognizer.pinchRecognizer = pinch;

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:recognizer action:@selector(panGestureRecognizer:)];
    [tableView addGestureRecognizer:pan];
    pan.delegate             = recognizer;
    recognizer.panRecognizer = pan;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:recognizer action:@selector(longPressGestureRecognizer:)];
    [tableView addGestureRecognizer:longPress];
    longPress.delegate              = recognizer;
    recognizer.longPressRecognizer  = longPress;

    return recognizer;
}

@end


@implementation UITableView (JTTableViewGestureDelegate)

- (JTTableViewGestureRecognizer *)enableGestureTableViewWithDelegate:(id)delegate {
    if ( ! [delegate conformsToProtocol:@protocol(JTTableViewGestureAddingRowDelegate)]
        && ! [delegate conformsToProtocol:@protocol(JTTableViewGestureEditingRowDelegate)]
        && ! [delegate conformsToProtocol:@protocol(JTTableViewGestureMoveRowDelegate)]) {
        [NSException raise:@"delegate should at least conform to one of JTTableViewGestureAddingRowDelegate, JTTableViewGestureEditingRowDelegate or JTTableViewGestureMoveRowDelegate" format:nil];
    }
    JTTableViewGestureRecognizer *recognizer = [JTTableViewGestureRecognizer gestureRecognizerWithTableView:self delegate:delegate];
    recognizer.rowEditingFlag = NO;
    recognizer.lastRowVisibleFlag = NO;
    recognizer.state = JTTableViewGestureRecognizerStateNone;
    return recognizer;
}

#pragma mark Helper methods

- (void)reloadVisibleRowsExceptIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *visibleRows = [[self indexPathsForVisibleRows] mutableCopy];
    [visibleRows removeObject:indexPath];
    [self reloadRowsAtIndexPaths:visibleRows withRowAnimation:UITableViewRowAnimationNone];
}

@end