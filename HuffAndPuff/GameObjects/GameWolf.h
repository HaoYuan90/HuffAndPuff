#import "GameObject.h"
#import "GameBreath.h"
#import "GameWolfDelegate.h"

@interface GameWolf : GameObject

@property (nonatomic, readonly, strong) UIImageView* livingWolf;
@property (nonatomic, readonly, strong) id<GameWolfDelegate> delegate;

- (id)initWithPlatte:(UIView*)pla gameArea:(UIScrollView*)gam engine:(Engine*)eng delegate:(id<GameWolfDelegate>) del;
- (id)initWithPlatte:(UIView*)Pal gameArea:(UIScrollView*)gam engine:(Engine*)eng
          dictionary:(NSDictionary*)Dic delegate:(id<GameWolfDelegate>) del;

- (void) startBreathAnimation;
- (void) die;
- (CGPoint) mouthPosition;

@end
