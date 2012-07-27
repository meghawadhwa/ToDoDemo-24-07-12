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


@interface JTUnfoldingTableViewCell : TransformableTableViewCell
@end

@interface JTPullDownTableViewCell : TransformableTableViewCell
@end

@interface DefaultTableViewCell : TransformableTableViewCell
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
    NSLog(@"here");
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

#pragma mark -

@implementation TransformableTableViewCell
@synthesize finishedHeight, tintColor,nameTextField,labelTapGestureRecognizer,doneOverlayView;

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


+ (TransformableTableViewCell *)transformableTableViewCellWithStyle:(TransformableTableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    switch (style) {
        case TransformableTableViewCellStylePullDown:
            return [TransformableTableViewCell pullDownTableViewCellWithReuseIdentifier:reuseIdentifier];
            break;
        
        case TransformableTableViewCellStyleDefault:
         return [TransformableTableViewCell defaultTableViewCellWithReuseIdentifier:reuseIdentifier];
        
        case TransformableTableViewCellStyleUnfolding:
        default:
            return [TransformableTableViewCell unfoldingTableViewCellWithReuseIdentifier:reuseIdentifier];
            break;
    }
}
#pragma mark - add text field

- (void)addTapGestureForTextLabel
{
    self.labelTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapped)];
    [self addGestureRecognizer:self.labelTapGestureRecognizer];
}

- (void)labelTapped
{   
    [self createTextField];
        self.textLabel.text = @"";
    [[self superview] addSubview:self.nameTextField];
    [[self superview] bringSubviewToFront:self.nameTextField]; 
    [self.nameTextField becomeFirstResponder];
}

- (void)createTextField
{
    if (self.nameTextField !=nil) {
        self.nameTextField.hidden = NO;
        //self.nameTextField.center = self.center;
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
#pragma mark - text field delegates
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (![self.nameTextField.text isEqualToString:@""]) {
    self.textLabel.text = self.nameTextField.text;
    }
    else {
        //delete
    }
    [self.nameTextField resignFirstResponder];
    [self.nameTextField removeFromSuperview];
    self.nameTextField = nil;
    if (self.doneOverlayView !=nil) {
    [self.doneOverlayView removeFromSuperview];
    self.doneOverlayView = nil;
    }
    UITableView * superView = (UITableView *)[self superview];
    [UIView animateWithDuration:0.3 animations:^{
        [superView setFrame:CGRectMake(0,0, superView.frame.size.width , superView.frame.size.height)];
    }];

return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([self.nameTextField.text isEqualToString:@""]) {
        self.nameTextField.enablesReturnKeyAutomatically= NO;
    }
    else {
        self.nameTextField.enablesReturnKeyAutomatically = YES;
    }
    
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
    [UIView animateWithDuration:0.3 animations:^{
        [superView setFrame:CGRectMake(0,0, 320, superView.frame.size.height)];
    }];
    if (self.nameTextField !=nil) {
        self.textLabel.text = self.nameTextField.text;
        [self.nameTextField removeFromSuperview];
        self.nameTextField = nil;
    }
}


@end
