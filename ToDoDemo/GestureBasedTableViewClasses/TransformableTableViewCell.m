/*
 * This file is part of the JTGestureBasedTableView package.
 * (c) James Tang <mystcolor@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "TransformableTableViewCell.h"
#import "UIColor+JTGestureBasedTableViewHelper.h"
#import <QuartzCore/QuartzCore.h>
#import "TDCommon.h"

@interface JTUnfoldingTableViewCell : TransformableTableViewCell
@end

@interface JTPullDownTableViewCell : TransformableTableViewCell
@end

@interface DefaultTableViewCell : TransformableTableViewCell
@end

@interface DefaultWithCountTableViewCell : TransformableTableViewCell
@end
#pragma mark -

@implementation JTUnfoldingTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code

        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = -1/500.f;
        [self.contentView.layer setSublayerTransform:transform];
        
        self.textLabel.layer.anchorPoint = CGPointMake(0.5, 0.0);

        self.detailTextLabel.layer.anchorPoint = CGPointMake(0.5, 1.0);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.detailTextLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;

        self.tintColor = [UIColor whiteColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSLog(@"layout subviews");
    CGFloat fraction = (self.frame.size.height / self.finishedHeight);
    fraction = MAX(MIN(1, fraction), 0);
    
    CGFloat angle = (M_PI / 2) - asinf(fraction);
    CATransform3D transform = CATransform3DMakeRotation(angle, -1, 0, 0);
    [self.textLabel.layer setTransform:transform];
    [self.detailTextLabel.layer setTransform:CATransform3DMakeRotation(angle, 1, 0, 0)];

    self.textLabel.backgroundColor       = [self.tintColor colorWithBrightness:0.3 + 0.7*fraction];
    self.detailTextLabel.backgroundColor = [self.tintColor colorWithBrightness:0.5 + 0.5*fraction];

    CGSize contentViewSize = self.contentView.frame.size;
    CGFloat contentViewMidY = contentViewSize.height / 2;
    CGFloat labelHeight = self.finishedHeight / 2;

    // OPTI: Always accomodate 1 px to the top label to ensure two labels 
    // won't display one px gap in between sometimes for certain angles 
    self.textLabel.frame = CGRectMake(0, (contentViewMidY - (labelHeight * fraction)),
                                      contentViewSize.width, labelHeight + 1);
    self.detailTextLabel.frame = CGRectMake(0, (contentViewMidY - (labelHeight * (1 - fraction))),
                                            contentViewSize.width, labelHeight);
}

@end

@implementation JTPullDownTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code        
        
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = -1/500.f;
        [self.contentView.layer setSublayerTransform:transform];
        
        self.textLabel.layer.anchorPoint = CGPointMake(0.5, 1.0);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;  
        
        self.tintColor = [UIColor whiteColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat fraction = (self.frame.size.height / self.finishedHeight);
    fraction = MAX(MIN(1, fraction), 0);
    
    CGFloat angle = (M_PI / 2) - asinf(fraction);
    CATransform3D transform = CATransform3DMakeRotation(angle, 1, 0, 0);
    [self.textLabel.layer setTransform:transform];
    
    self.textLabel.backgroundColor       = [self.tintColor colorWithBrightness:0.3 + 0.7*fraction];
    
    CGSize contentViewSize = self.contentView.frame.size;
    CGFloat labelHeight = self.finishedHeight;
    
    // 05/07/2012 : Added by SungDong Kim 
    CGSize requiredLabelSize = [self.textLabel.text sizeWithFont:self.textLabel.font
                                               constrainedToSize:contentViewSize
                                                   lineBreakMode:UILineBreakModeClip];
    self.imageView.frame = CGRectMake(((contentViewSize.width - requiredLabelSize.width)/2) - self.imageView.frame.size.width - 8, 
                                      contentViewSize.height - (labelHeight + self.imageView.frame.size.height)/2,
                                      self.imageView.frame.size.width,
                                      self.imageView.frame.size.height);
    // OPTI: Always accomodate 1 px to the top label to ensure two labels 
    // won't display one px gap in between sometimes for certain angles 
    self.textLabel.frame = CGRectMake(0, contentViewSize.height - labelHeight,
                                      contentViewSize.width, labelHeight);
    self.nameTextField.frame = self.textLabel.frame;
}

@end

@implementation DefaultTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //self.textLabel.userInteractionEnabled = YES;
        [self addTapGestureForTextLabel];
        self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.tintColor = [UIColor whiteColor];
    }
    return self;
}


@end 

@implementation DefaultWithCountTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self addTapGestureForTextLabel];
        self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.tintColor = [UIColor whiteColor];
        UILabel *backgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(260, 0, 60, 60)];
        backgroundLabel.backgroundColor = [TDCommon getColorByPriority:-6];
        [self.contentView addSubview:backgroundLabel];
        self.countLabel = [[UILabel alloc] initWithFrame:backgroundLabel.frame];
        self.countLabel.center = backgroundLabel.center;
        self.countLabel.backgroundColor = [UIColor clearColor];
        self.countLabel.text = @" 0 ";
        self.countLabel.textAlignment = UITextAlignmentCenter;
        self.countLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:self.countLabel];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.textColor = [UIColor clearColor];
        self.detailTextLabel.text = @""; 
        self.textLabel.backgroundColor = [UIColor redColor];

    }
    return self;
}

//- (void)layoutSubviews {
//    [super layoutSubviews];  //The default implementation of the layoutSubviews
//    
//    CGRect textLabelFrame = self.textLabel.frame;
//    CGSize textSize = [self.textLabel.text sizeWithFont:[self.textLabel font]];
//
//    textLabelFrame.size.width = textSize.width +5;
//     textLabelFrame.size.height = textSize.height +5;
//    self.textLabel.frame = textLabelFrame;
//}

@end 

#pragma mark -

@implementation TransformableTableViewCell
@synthesize finishedHeight, tintColor,nameTextField,labelTapGestureRecognizer,doneOverlayView,previousLabelText;
@synthesize updateDelegate,deleteDelegate;
@synthesize countLabel;

+ (TransformableTableViewCell *)unfoldingTableViewCellWithReuseIdentifier:(NSString *)reuseIdentifier {
    JTUnfoldingTableViewCell *cell = (id)[[JTUnfoldingTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                                           reuseIdentifier:reuseIdentifier];
    return cell;
}

+ (TransformableTableViewCell *)pullDownTableViewCellWithReuseIdentifier:(NSString *)reuseIdentifier {
    JTPullDownTableViewCell *cell = (id)[[JTPullDownTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                                          reuseIdentifier:reuseIdentifier];
    return cell;
}

+ (TransformableTableViewCell *)defaultTableViewCellWithReuseIdentifier:(NSString *)reuseIdentifier {
    DefaultTableViewCell *cell = (id)[[DefaultTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                                       reuseIdentifier:reuseIdentifier];
    return cell;
}


+ (TransformableTableViewCell *)defaultWithCountTableViewCellWithReuseIdentifier:(NSString *)reuseIdentifier {
    DefaultWithCountTableViewCell *cell = (id)[[DefaultWithCountTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    return cell;
}

+ (TransformableTableViewCell *)transformableTableViewCellWithStyle:(TransformableTableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    switch (style) {
        case TransformableTableViewCellStylePullDown:
            return [TransformableTableViewCell pullDownTableViewCellWithReuseIdentifier:reuseIdentifier];
            break;
        
        case TransformableTableViewCellStyleDefault:
         return [TransformableTableViewCell defaultTableViewCellWithReuseIdentifier:reuseIdentifier];
            break;
            
        case TransformableTableViewCellStyleDefaultWithCount:
            return [TransformableTableViewCell defaultWithCountTableViewCellWithReuseIdentifier:reuseIdentifier];
            break;
            
        case TransformableTableViewCellStyleUnfolding:
        default:
            return [TransformableTableViewCell unfoldingTableViewCellWithReuseIdentifier:reuseIdentifier];
            break;
    }
}
#pragma mark - add text field

- (void)addTapGestureForTextLabel
{
    self.textLabel.userInteractionEnabled = YES;
    self.labelTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapped)];
    [self.textLabel addGestureRecognizer:self.labelTapGestureRecognizer];
}

- (void)labelTapped
{   
    [self createTextField];
    self.previousLabelText = self.textLabel.text;
        self.textLabel.text = @"";
    [[self superview] addSubview:self.nameTextField];
    [[self superview] bringSubviewToFront:self.nameTextField]; 
    [self.nameTextField becomeFirstResponder];
}

- (void)createTextField
{
    if (self.nameTextField !=nil) {
        self.nameTextField.hidden = NO;
        return;
    }
    self.nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 300, 20)];
    self.nameTextField.center = self.center;
    self.nameTextField.text = self.textLabel.text;
    self.nameTextField.textColor = [UIColor whiteColor];
    self.nameTextField.backgroundColor = [UIColor clearColor];
    self.nameTextField.font = [UIFont boldSystemFontOfSize:18];
    self.nameTextField.delegate = self;
    self.nameTextField.returnKeyType = UIReturnKeyDone;
}

- (void)updateOrDeleteCell
{
    UITableView *tableView = (UITableView *)[self superview];
    NSIndexPath *indexpath = [tableView indexPathForCell:self]; 
    if (![self.nameTextField.text isEqualToString:@""]) {
        self.textLabel.text = self.nameTextField.text;
        
        if (![self.previousLabelText isEqualToString:self.nameTextField.text]) {
            NSLog(@"Updating to %@",self.nameTextField.text);
            [self.updateDelegate updateCurrentRowAtIndexpath:indexpath];
        }
        [self removeOverlayAndTextField];
    }
    else {
        //delete
        [self removeOverlayAndTextField];
        NSLog(@"Deleting");
//        [UIView animateWithDuration:0.25 animations:^{
//            CGRect cellFrame = self.frame;
//            cellFrame.origin.x = -320;
//            self.frame = cellFrame;
//        } completion:^(BOOL finished){
//            if (finished) {
                [self.deleteDelegate deleteCurrentRowAtIndexpath:indexpath];
//            }
//        }];
        
    }
}

- (void)removeOverlayAndTextField
{
    if (self.nameTextField !=nil) {
        [self.nameTextField removeFromSuperview];
        self.nameTextField = nil;
        self.previousLabelText = nil;
    }
   
    if (self.doneOverlayView != nil) {
        [self.doneOverlayView removeFromSuperview];
        self.doneOverlayView = nil;
    }
}

#pragma mark - text field delegates
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    UITableView * superView = (UITableView *)[self superview];
    [UIView animateWithDuration:0.2 animations:^{
        [superView setFrame:CGRectMake(0,0, superView.frame.size.width , superView.frame.size.height)];
    }];
    [self performSelector:@selector(updateOrDeleteCell) withObject:nil afterDelay:0.2];    
    [self.nameTextField resignFirstResponder];

return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
   
    self.nameTextField.enablesReturnKeyAutomatically = YES;
    
    UITableView * superView = (UITableView *)[self superview];
    [UIView animateWithDuration:0.3 animations:^{
        [superView setFrame:CGRectMake(0,0 - self.frame.origin.y, superView.frame.size.width, superView.frame.size.height)];}];
    [self createDoneOverlayAtHeight:CGRectGetMaxY(self.frame)];
    [superView addSubview:self.doneOverlayView];
                                 
}

#pragma mark - done overlay methods

- (void)createDoneOverlayAtHeight:(float)height
{
    if (self.doneOverlayView) {
        return;
    }
    self.doneOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0, height, 320, 480)];
    self.doneOverlayView.backgroundColor =[[UIColor blackColor] colorWithAlphaComponent:0.5];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doneOverlayViewTapped)]; 
    [self.doneOverlayView addGestureRecognizer:tapGestureRecognizer];
}

- (void)doneOverlayViewTapped
{
    [self.nameTextField resignFirstResponder];
    [self.doneOverlayView removeFromSuperview];
    self.doneOverlayView = nil;
    
    UITableView * superView = (UITableView *)[self superview];
    [UIView animateWithDuration:0.2 animations:^{
        [superView setFrame:CGRectMake(0,0, 320, superView.frame.size.height)];
    }];
    [self performSelector:@selector(updateOrDeleteCell) withObject:nil afterDelay:0.2];    

}


@end
