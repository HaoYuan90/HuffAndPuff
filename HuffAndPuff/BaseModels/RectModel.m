#import "RectModel.h"

@implementation RectModel

@synthesize width;
@synthesize height;

- (id)initWithOrigin:(CGPoint)o width:(CGFloat)w height:(CGFloat)h mass:(CGFloat)m 
{
    self = [super init];
    if(self == nil){
        NSLog(@"malloc error");
        return self;
    }

    width = w;
    height = h;
    origin = o;
    rotation = 0;
    mass = m; 
    velocity = [Vector2D vectorWith:0 y:0];
    angularVelocity = 0;
    
    disappear = NO;
    return self;
}


- (id)initWithOrigin:(CGPoint)o width:(CGFloat)w height:(CGFloat)h mass:(CGFloat)m 
         restitution:(CGFloat)rest friction:(CGFloat)fric collisionType:(collisionType) ct
{
    self = [self initWithOrigin:o width:w height:h mass:m];    
    restitution = rest;
    friction = fric;
    colType = ct;
    
    return self;
}

- (CGPoint)center 
{
    return CGPointMake((self.origin.x + self.width/2), (self.origin.y + self.height/2));
}

+ (CGPoint)rotatePoint: (CGPoint)pt ClockwiseWithBase: (CGPoint)base Degree:(CGFloat)dg 
{
    //Effect: rotate a point clockwise wrt another point
    CGFloat rotationRad = dg * M_PI /180;
    CGFloat x,y;
    x = (pt.x-base.x) * cos(rotationRad) - (pt.y-base.y) * sin(rotationRad) + base.x;
    y = (pt.y-base.y) * cos(rotationRad) + (pt.x-base.x) * sin(rotationRad) + base.y;
    return CGPointMake(x,y);
}

- (CGPoint)cornerFrom:(CornerType)corner {
    switch(corner){
        case kTopLeftCorner:
            return [RectModel rotatePoint: self.origin ClockwiseWithBase: self.center Degree: self.rotation];
        case kTopRightCorner:
            return [RectModel rotatePoint: CGPointMake(self.origin.x+self.width, self.origin.y) ClockwiseWithBase: self.center Degree: self.rotation];
        case kBottomLeftCorner:
            return [RectModel rotatePoint: CGPointMake(self.origin.x, self.origin.y+self.height) ClockwiseWithBase: self.center Degree: self.rotation];
        case kBottomRightCorner:
            return [RectModel rotatePoint: CGPointMake(self.origin.x+self.width, self.origin.y+self.height) ClockwiseWithBase: self.center Degree: self.rotation];
        default:
            NSLog(@"error");
            return self.origin;
    }
}

- (NSArray*)corners {
    CGPoint c0 = [self cornerFrom: kTopLeftCorner];
    CGPoint c1 = [self cornerFrom: kTopRightCorner];
    CGPoint c2 = [self cornerFrom: kBottomRightCorner];
    CGPoint c3 = [self cornerFrom: kBottomLeftCorner];
    Vector2D *c00 = [Vector2D vectorWith:c0.x y:c0.y]; 
    Vector2D *c11 = [Vector2D vectorWith:c1.x y:c1.y]; 
    Vector2D *c22 = [Vector2D vectorWith:c2.x y:c2.y]; 
    Vector2D *c33 = [Vector2D vectorWith:c3.x y:c3.y]; 
    return [NSArray arrayWithObjects:c00,c11,c22,c33, nil];
}

- (void)translateX:(CGFloat)dx Y:(CGFloat)dy {
    origin = CGPointMake(origin.x+dx, origin.y+dy);
}

- (CGRect)boundingBox {	
    NSArray *cor = self.corners;
    Vector2D *c0 = [cor objectAtIndex:0];
    CGFloat smallestX =c0.x;
    CGFloat biggestX = c0.x;
    CGFloat smallestY = c0.y;
    CGFloat biggestY = c0.y;
    for(int i=1;i<4;i++){
        Vector2D *temp = [cor objectAtIndex:i];
        biggestX = MAX(temp.x,biggestX);
        smallestX = MIN(temp.x,smallestX);
        biggestY = MAX(temp.y,biggestY);
        smallestY = MIN(temp.y,smallestY);
    }
    return CGRectMake(smallestX,smallestY,biggestX-smallestX,biggestY-smallestY);
}

- (CGFloat) momentOfInertia 
{
    return (width*width + height*height)/12 * mass;
}

@end
