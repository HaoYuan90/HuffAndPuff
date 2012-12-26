//code quality checked

#import <UIKit/UIKit.h>
#import "GameWolf.h"
#import "RectView.h"

@interface BreathBar : UIViewController

@property (nonatomic, readonly, strong) UIScrollView* gameArea;
@property (nonatomic, readonly, strong) GameWolf *wolf;
@property (nonatomic, readonly, strong) UIView *filler;
@property (nonatomic, readonly) double strength;

- (id)initWithGameArea:(UIScrollView*)ga wolf:(GameWolf*)w;

@end
