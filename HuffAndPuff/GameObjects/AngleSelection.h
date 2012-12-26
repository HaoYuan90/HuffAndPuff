//code quality

#import <UIKit/UIKit.h>
#import "GameWolf.h"

@interface AngleSelection : UIViewController

@property (nonatomic, readonly, strong) UIScrollView* gameArea;
@property (nonatomic, readonly, strong) GameWolf *wolf;
@property (nonatomic, readonly, strong) UIImageView *arrow;
@property (nonatomic, readonly) CGPoint refCenter;
@property (nonatomic, readonly) CGFloat angle;

- (id)initWithGameArea:(UIScrollView*)ga wolf:(GameWolf*)w;

- (Vector2D*) directionVector;

@end
