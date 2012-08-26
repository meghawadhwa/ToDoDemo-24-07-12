

#import <UIKit/UIKit.h>
#import "TDDelegates.h"
#import "TDStrikedLabel.h"

@class TDDelegates;
@class TDStrikedLabel;

typedef enum {
    TransformableTableViewCellStyleUnfolding,
    TransformableTableViewCellStylePullDown,
    TransformableTableViewCellStyleDefault,
    TransformableTableViewCellStyleDefaultWithCount,
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
- (void)makeStrikedLabel;
@property(nonatomic,assign)id<TDCreatingCellDelegate> createDelegate;
@property(nonatomic,assign)id<TDUpdateDbDelegate> updateDelegate;
@property(nonatomic,assign)id<TDDeleteFromDbDelegate> deleteDelegate;
@property(nonatomic,assign)id<TDEditingCellDelegate> editingDelegate;
@property(nonatomic,assign)BOOL addingCellFlag;
@property (nonatomic,retain) UILabel *countLabel;
@property(nonatomic,retain) TDStrikedLabel *strikedLabel;
@end
