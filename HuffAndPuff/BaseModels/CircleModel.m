#import "CircleModel.h"

@implementation CircleModel

@synthesize radius;

- (id)initWithOrigin:(CGPoint)o radius:(CGFloat)r mass:(CGFloat)m
{
    self = [super init];
    if(self == nil){
        NSLog(@"malloc error");
        return self;
    }
    radius = r;
    origin = o;
    rotation = 0;
    mass = m; 
    velocity = [Vector2D vectorWith:0 y:0];
    angularVelocity = 0;
    disappear = NO;
    
    return self;
}

- (id)initWithOrigin:(CGPoint)o radius:(CGFloat)r mass:(CGFloat)m 
         restitution:(CGFloat)rest friction:(CGFloat)fric collisionType:(collisionType) ct
{
    self = [self initWithOrigin:o radius:r mass:m];
    
    friction = fric;
    restitution = rest;
    colType = ct;
    
    return self;
}

- (CGPoint)center {
    return CGPointMake((self.origin.x + self.radius), (self.origin.y + self.radius));
}

- (void)translateX:(CGFloat)dx Y:(CGFloat)dy {
    origin = CGPointMake(origin.x+dx, origin.y+dy);
}

- (CGRect)boundingBox {	
    return CGRectMake(origin.x,origin.y,2*radius,2*radius);
}

- (CGFloat) momentOfInertia 
{
    //check this online
    return (radius*radius*M_PI)/4 * mass;
}

@end
