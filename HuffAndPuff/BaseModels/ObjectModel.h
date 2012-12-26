//code quality checked

#import <Foundation/Foundation.h>
#import "Vector2D.h"

typedef enum{
    kBreath,
    kGround,
    kPig,
    kStraw,
    kWood,
    kIron,
    kStone,
    kWolf,
    kDefaultType
} collisionType;

@interface ObjectModel : NSObject{
    CGFloat mass;
    Vector2D *velocity;
    CGFloat angularVelocity;
    
    CGPoint origin;
    CGFloat rotation;
    
    CGFloat restitution;
    CGFloat friction;
    
    BOOL disappear;
    collisionType colType;
}

@property (nonatomic) CGPoint origin;
@property (nonatomic) CGFloat rotation;
@property (nonatomic, readonly) CGPoint center;

@property (nonatomic) CGFloat mass;
@property (nonatomic, readonly) CGFloat momentOfInertia;
@property (nonatomic, retain) Vector2D *velocity;
@property (nonatomic) CGFloat angularVelocity;

@property (nonatomic) CGFloat restitution;
@property (nonatomic) CGFloat friction;

@property (nonatomic) BOOL disappear;
@property (nonatomic) collisionType colType;

- (void)translateX:(CGFloat)dx Y:(CGFloat)dy;
- (CGRect)boundingBox;

- (void) applyGravity: (CGFloat) time gravity:(Vector2D*)g ;
- (void) updatePosition : (CGFloat) time;

@end
