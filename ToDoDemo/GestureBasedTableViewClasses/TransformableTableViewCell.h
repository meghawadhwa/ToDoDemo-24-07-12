/*
 * This file is part of the JTGestureBasedTableView package.
 * (c) James Tang <mystcolor@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <UIKit/UIKit.h>
@class TDDelegates;

typedef enum {
    TransformableTableViewCellStyleUnfolding,
    TransformableTableViewCellStylePullDown,
    TransformableTableViewCellStyleDefault,
} TransformableTableViewCellStyle;


@protocol TransformableTableViewCell <NSObject>

@property (nonatomic, assign) CGFloat  finishedHeight;
@property (nonatomic, strong) UIColor *tintColor;   // default is white color
@property(nonatomic,retain)UITextField *nameTextField;
@property(nonatomic,retain)UITapGestureRecognizer *labelTapGestureRecognizer;
@property (strong,nonatomic) UIView *doneOverlayView;
@property(nonatomic,retain)NSString *previousLabelText;

@end


@interface TransformableTableViewCell : UITableViewCell <TransformableTableViewCell,UITextFieldDelegate>

// Use this factory method instead of 
// - (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
+ (TransformableTableViewCell *)transformableTableViewCellWithStyle:(TransformableTableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void)addTapGestureForTextLabel;
- (void)labelTapped;
@end
