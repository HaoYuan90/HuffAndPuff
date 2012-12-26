//code quality checked

#import <UIKit/UIKit.h>
#import "CircleModel.h"
#import "Engine.h"

@interface GameBreath: UIViewController {
    CircleModel *model;
    UIScrollView* gameArea;
    Engine* engine;
}

@property (nonatomic, readonly, retain) CircleModel* model;
@property (nonatomic, readonly, retain) UIScrollView* gameArea;
@property (nonatomic, readonly, retain) Engine* engine;

- (id)initWithGameArea:(UIScrollView*)ga Engine:(Engine*)eng At:(CGPoint)origin 
                Radius:(CGFloat)rad Velocity:(Vector2D*) vel;
- (void)reloadView;

@end
