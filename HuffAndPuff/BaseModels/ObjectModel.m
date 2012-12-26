#import "ObjectModel.h"

@implementation ObjectModel

#define displacementBias 0.1

@synthesize mass;
@synthesize velocity;
@synthesize angularVelocity;

@synthesize origin;
@synthesize rotation;
@synthesize center;

@synthesize disappear;
@synthesize colType;

@synthesize restitution;
@synthesize friction;

- (void)setRotate:(CGFloat)angle 
{
    //Effect: alter the rotation of the object to "angle" trim the angle to -360 to 360 degrees
    rotation = angle;
    if(rotation > 360)
        rotation -= 360;
    if(rotation < -360)
        rotation +=360;
}

- (void)translateX:(CGFloat)dx Y:(CGFloat)dy 
{
    //Effect: translate the object by dx, dy
    origin = CGPointMake(origin.x+dx, origin.y+dy);
}

-(void) applyGravity:(CGFloat)time gravity:(Vector2D*)g
{
    //Effect: apply gravitation to the velocity
    velocity = [velocity add:[g multiply:time]];
}

-(CGFloat) momentOfInertia{
    //must be implemented by subclass
    return 0;
}
-(CGRect) boundingBox{
    //must be implemented by subclass
    return CGRectMake(0, 0, 0, 0);
}

-(void) updatePosition:(CGFloat)time 
{
    //Effect: update the object's position after a time interval
    Vector2D *temp = [velocity multiply:time];
    
    if([temp length]<=displacementBias){
        return;
    }
    rotation = rotation + time*angularVelocity/M_PI * 180;
    origin = CGPointMake(origin.x+temp.x, origin.y+temp.y);
}

@end
