
#import "Ground.h"

#define hugeMass 3000
#define groundY 480

#define GroundFric 0.9
#define GroundRest 0

@implementation Ground

@synthesize width;
@synthesize height;

- (CGFloat) momentOfInertia 
{
    return (width*width + height*height)/12 * mass;
}

-(id) init{
    origin = CGPointMake(0, groundY);
    height = 1000;
    width = 2000;
    rotation = 0;
    velocity = [Vector2D vectorWith:0 y:0];
    angularVelocity = 0;
    mass = hugeMass;
    
    restitution = GroundRest;
    friction = GroundFric;
    
    colType = kGround;
    
    return self;
}

-(void) setVelocity:(Vector2D *)velocity
{
    return;
}
-(void) setAngularVelocity:(CGFloat)angularVelocity
{
    return;
}
-(void) applyGravity:(CGFloat)time gravity:(Vector2D*)g
{
    return;
}
-(void) updatePosition:(CGFloat)time 
{
    return;
}
-(void) applyImpulse:(Vector2D*)imp dv:(Vector2D *)r
{
    return;
}


@end
