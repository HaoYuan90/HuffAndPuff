//code quality checked

#import <Foundation/Foundation.h>
#import "Vector2D.h"
#import "ObjectModel.h"

typedef enum {
    kTopLeftCorner = 1,
    kTopRightCorner = 2,
    kBottomLeftCorner = 3,
    kBottomRightCorner = 4
} CornerType;

//as oppose to PS1 rotation is clockWise

@interface RectModel : ObjectModel {
}

@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic, readonly) NSArray* corners;

- (id)initWithOrigin:(CGPoint)o width:(CGFloat)w height:(CGFloat)h mass:(CGFloat)m; 
- (id)initWithOrigin:(CGPoint)o width:(CGFloat)w height:(CGFloat)h mass:(CGFloat)m 
         restitution:(CGFloat)rest friction:(CGFloat)fric collisionType:(collisionType) ct;

@end
