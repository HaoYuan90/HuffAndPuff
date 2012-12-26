//code quality

#import <Foundation/Foundation.h>
#import "Vector2D.h"
#import "ObjectModel.h"

//as oppose to PS1 rotation is clockWise

@interface CircleModel : ObjectModel {
}

@property (nonatomic, readonly) CGFloat radius;

- (id)initWithOrigin:(CGPoint)o radius:(CGFloat)r mass:(CGFloat)m;
- (id)initWithOrigin:(CGPoint)o radius:(CGFloat)r mass:(CGFloat)m 
         restitution:(CGFloat)rest friction:(CGFloat)fric collisionType:(collisionType) ct;

@end
