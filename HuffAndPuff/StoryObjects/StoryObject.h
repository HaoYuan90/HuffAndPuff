//code quality checked

#import <UIKit/UIKit.h>
#import "RectModel.h"

typedef enum {
    StoryObjectWolf, 
    StoryObjectPig, 
    StoryObjectBlock,
    StoryObjectBreath,
    StoryObjectCloud
} StoryObjectType;

@interface StoryObject : UIViewController {
    RectModel *model;
    
    UIView* palette;
    UIScrollView* gameArea;
    
    CGFloat palette_x;
    CGFloat palette_y;
    CGFloat palette_size;
    CGFloat gameArea_width;
    CGFloat gameArea_height;
    StoryObjectType objectType;
}

@property (nonatomic, readonly, retain) RectModel* model;
@property (nonatomic, readonly) StoryObjectType objectType;

@property (nonatomic, readonly, retain) UIView* palette;
@property (nonatomic, readonly, retain) UIScrollView* gameArea;

//position in platte, size when in game area
@property (nonatomic, readonly) CGFloat palette_x;
@property (nonatomic, readonly) CGFloat palette_y;
@property (nonatomic, readonly) CGFloat palette_size;
@property (nonatomic, readonly) CGFloat gameArea_width;
@property (nonatomic, readonly) CGFloat gameArea_height;

//init and data handlers
- (id)initWithPlatte:(UIView*)Palette gameArea:(UIScrollView*)gameArea;
- (id)initWithPlatte:(UIView*)Palette gameArea:(UIScrollView*)gameArea dictionary:(NSDictionary*)Dic;
- (NSDictionary*)exportAsDictionary;

//gesture handlers
- (void)translationFromPalToGam;

- (void)translate:(UIPanGestureRecognizer *)gesture;
- (void)rotate:(UIRotationGestureRecognizer *)gesture;
- (void)zoom:(UIPinchGestureRecognizer *)gesture;
- (void)doubleTap:(UITapGestureRecognizer *)gesture;

@end
