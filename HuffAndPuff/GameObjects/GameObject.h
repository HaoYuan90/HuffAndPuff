//code quality checked

#import <UIKit/UIKit.h>
#import "RectModel.h"
#import "Engine.h"

typedef enum {
    kGameObjectWolf, 
    kGameObjectPig, 
    kGameObjectBlock
} GameObjectType;

@interface GameObject : UIViewController {
    RectModel *model;
    
    UIView* palette;
    UIScrollView* gameArea;
    Engine* engine;
    
    CGFloat palette_x;
    CGFloat palette_y;
    CGFloat palette_size;
    CGFloat gameArea_width;
    CGFloat gameArea_height;
    GameObjectType objectType;
}
@property (nonatomic, readonly, retain) RectModel* model;
@property (nonatomic, readonly) GameObjectType objectType;

@property (nonatomic, readonly, retain) UIView* palette;
@property (nonatomic, readonly, retain) UIScrollView* gameArea;
@property (nonatomic, readonly, retain) Engine* engine;
//position in platte, size when in game area
@property (nonatomic, readonly) CGFloat palette_x;
@property (nonatomic, readonly) CGFloat palette_y;
@property (nonatomic, readonly) CGFloat palette_size;
@property (nonatomic, readonly) CGFloat gameArea_width;
@property (nonatomic, readonly) CGFloat gameArea_height;

//init and data handlers
- (id)initWithPlatte:(UIView*)Palette gameArea:(UIScrollView*)gameArea engine:(Engine*)engine;
- (id)initWithPlatte:(UIView*)Palette gameArea:(UIScrollView*)gameArea engine:(Engine*)engine
              dictionary:(NSDictionary*)Dic;
- (NSDictionary*)exportAsDictionary;

//gesture handlers
- (void)translationFromPalToGam;

- (void)translate:(UIPanGestureRecognizer *)gesture;
- (void)rotate:(UIRotationGestureRecognizer *)gesture;
- (void)zoom:(UIPinchGestureRecognizer *)gesture;
- (void)doubleTap:(UITapGestureRecognizer *)gesture;

- (void) animatedSelfDestruct;
- (void)reloadView;

@end
