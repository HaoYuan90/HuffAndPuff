#import "Engine.h"

#define timeInterval 0.02

#define defaultGravity 300
#define constantK 0.005     // max separation allowed
#define constantFactor 0.40   // constant E used to calculate bias
#define Fcoefficient 0.95   // coefficient used to help deduce good reference edge

@implementation Engine

@synthesize objects;
@synthesize ground;
@synthesize gravity;
@synthesize delegate;

-(id) initWithDelegate:(id<EngineDelegate>)del
{
    self = [super init];
    if(self == nil){
        NSLog(@"malloc error");
        return self;
    }
    gravity = [Vector2D vectorWith:0 y:defaultGravity];
    delegate = del;
    objects = [NSMutableArray array];
    ground = [[Ground alloc] init];
    return self;
}

-(void) addObject:(ObjectModel*)object
{
    //Effect: add physics body to engine
    if(object == nil)
        NSLog(@"nil object added to engine");
    [objects addObject:object];
}
-(void) removeObject:(ObjectModel*)object
{
    //Effect: remove physics body from engine
    [objects removeObject:object];
}

-(void) updateGravityEffects
{    
    //Effect: apply effect of gravity to the objects
    for (ObjectModel *temp in objects)
        [temp applyGravity: timeInterval gravity:self.gravity];
}

-(void) updatePositions
{
    //Effect: update physics object's position for a tick
    for (ObjectModel *temp in objects){
        [temp updatePosition:timeInterval];
    }
}

-(void) renderPositions
{
    //Effect: remove objects that should disappear and call delegate method "update"
    for (int i=0;i< objects.count;i++){
        ObjectModel *temp = [objects objectAtIndex:i];
        if(temp.disappear)
            [self removeObject:temp];
    }
    [delegate update];
}

-(void) handleImpulse:(ObjectModel*)two: (ObjectModel*)one :(Vector2D*)contact: (Vector2D*)normal :(double)separation
{
    //REQUIRES: all objects passed in cannot be nil, seperation must be negative. This is ensured by caller
    //EFFECT: apply impulse on contact point according to depth. universal method and apply special collision effects
    if(two.colType == kDefaultType || one.colType == kDefaultType){
        NSLog(@"default collision type for some reason");
    }
    
    if(two.colType == kBreath || one.colType == kBreath){
        ObjectModel *breath, *other;
        if(one.colType == kBreath){
            breath = one;
            other = two;
        }
        else {
            breath = two;
            other = one;
        }
        switch (other.colType) {
            case kStraw:
                breath.velocity = [breath.velocity multiply:0.5];
                other.disappear = YES;
                return;
            case kWood: case kStone:
                breath.disappear = YES;
                break;
            case kIron:
                breath.disappear = YES;
                return;
            case kPig:
                other.disappear = YES;
                return;
            case kGround:
                breath.disappear = YES;
                return;
            default:
                break;
        }
    }
    else if(two.colType == kPig || one.colType == kPig){
        ObjectModel *pig, *other;
        if(one.colType == kPig){
            pig = one;
            other = two;
        }
        else {
            pig = two;
            other = one;
        }
        switch (other.colType) {
            case kStone: case kIron:
                pig.disappear = YES;
                break;
            default:
                break;
        }
    }
    
    //calculate impulse and update velocity
    Vector2D *p1 = [Vector2D vectorWith:one.center.x y:one.center.y];
    Vector2D *p2 = [Vector2D vectorWith:two.center.x y:two.center.y];
    
    Vector2D *tangent;
    tangent = [normal crossZ:1.0];
    
    Vector2D *r1 = [contact subtract:p1];
    Vector2D *r2 = [contact subtract:p2];
    Vector2D *u1 = [one.velocity add:[r1 crossZ:-one.angularVelocity]];
    Vector2D *u2 = [two.velocity add:[r2 crossZ:-two.angularVelocity]];
    Vector2D *u = [u2 subtract:u1];
    
    double un = [u dot:normal];
    double ut = [u dot:tangent];
    
    double massn, masst;
    
    massn = (1/two.mass) + (1/one.mass) + (([r1 dot:r1] - ([r1 dot:normal]*[r1 dot:normal]))/one.momentOfInertia) + (([r2 dot:r2] - ([r2 dot:normal]*[r2 dot:normal]))/two.momentOfInertia);
    masst = (1/two.mass) + (1/one.mass) + (([r1 dot:r1] - ([r1 dot:tangent]*[r1 dot:tangent]))/one.momentOfInertia) + (([r2 dot:r2] - ([r2 dot:tangent]*[r2 dot:tangent]))/two.momentOfInertia);
    
    massn = 1/massn;
    masst = 1/masst;
    
    double bias = abs((constantFactor/timeInterval)*(constantK + separation));
    
    if (constantK > fabs(separation)) {
        bias = 0;
    }
    
    double restitution = sqrt(one.restitution * two.restitution);
    
    double pnFactor = MIN((massn * ((1+restitution)*un-bias)),0);
    Vector2D *pn = [normal multiply:pnFactor];
    double dpt = masst * ut;
    
    double ptmax = one.friction * two.friction * [pn length];
    
    dpt = MAX(-ptmax, MIN(dpt, ptmax));
    
    Vector2D *pt;
    pt = [tangent multiply:dpt];
    
    Vector2D *newV1 = [one.velocity add:[[pn add:pt] multiply:(1/one.mass)]];
    Vector2D *newV2 = [two.velocity subtract:[[pn add:pt] multiply:(1/two.mass)]];
    
    double newW1 = one.angularVelocity + ([r1 cross:[pt add:pn]]/one.momentOfInertia);
    double newW2 = two.angularVelocity - ([r2 cross:[pt add:pn]]/two.momentOfInertia);
    
    [two setVelocity: newV2];
    [two setAngularVelocity: newW2];
    
    [one setVelocity: newV1];
    [one setAngularVelocity: newW1];
}

-(void) handleCollisionRR: (RectModel*) two with: (RectModel*) one
{	    
    //REQUIRES: all objects passed in cannot be nil. This is ensured by caller
    //EFFECT: find contact points and seperation if one intersects two, and call handleImpulse to resolve collision
    
    Vector2D *h1 = [Vector2D vectorWith:[one width]/2 y:[one height]/2];
	Vector2D *h2 = [Vector2D vectorWith:[two width]/2 y:[two height]/2];
	
    Vector2D* p1 = [Vector2D vectorWith:one.center.x y:one.center.y];
    Vector2D* p2 = [Vector2D vectorWith:two.center.x y:two.center.y];
    
	Vector2D *d = [p2 subtract:p1];
    CGFloat rad1 = one.rotation * M_PI / 180;
    CGFloat rad2 = two.rotation * M_PI / 180;
    
    Matrix2D* R1 = [Matrix2D matrixWithValues:cos(rad1) and:sin(rad1) and:-sin(rad1) and:cos(rad1)];
    Matrix2D* R2 = [Matrix2D matrixWithValues:cos(rad2) and:sin(rad2) and:-sin(rad2) and:cos(rad2)];
    
	Vector2D *d1 = [[R1 transpose] multiplyVector:d];
	Vector2D *d2 = [[R2 transpose] multiplyVector:d];
	
	Matrix2D *c = [[R1 transpose] multiply:R2];
	
	Vector2D *ch2 = [[c abs] multiplyVector:h2];
	Vector2D *cth1 = [[[c transpose] abs] multiplyVector:h1];
	
	Vector2D *f1 = [[[d1 abs] subtract:h1] subtract:ch2];
	Vector2D *f2 = [[[d2 abs] subtract:h2] subtract:cth1];
    
	double ij[4];
	ij[0] = f1.x;
	ij[1] = f1.y;
	ij[2] = f2.x;
	ij[3] = f2.y;
	
	double pref[4];
	pref[0] = f1.x - constantK*(h1.x);
	pref[1] = f1.y - constantK*(h1.y);
	pref[2] = f2.x - constantK*(h2.x);
	pref[3] = f2.y - constantK*(h2.y);
	
	int i,pos, flag;
	double smallest = pref[0];
	pos = 0;
	flag = 0;
	
	//if any of them are positive then they do not collide
	for (i=0; i<4; i++) {
		if (ij[i] > 0) {
			//NSLog(@"Not Colliding prim check");
			return;
		}
	}
	
	//favoring the larger edge for reference edge
	for (i=0; i<4; i++) {
		if (pref[i] > Fcoefficient*ij[i]) {
			smallest = pref[i];
			pos = i;
			flag = 1;
		}
	}
	
	if (flag == 0) {
		smallest = ij[0];
		pos = 0;	
		for (i=0; i<4; i++) {
			if (ij[i] > smallest) 
			{
				smallest = ij[i];
				pos = i;
			}
		}
	}
    
	Vector2D *n;
	Vector2D *nf, *ns;
	Vector2D *ni, *p, *h;
	Matrix2D *r;
	double df, ds, dneg, dpos;
	//df - distance between world origin and reference edge
    
	switch (pos) {
		case 0:
			//NSLog(@"0");
			if (d1.x >= 0)
			{
				//rectangle 2 is on the right hand side of rectangle 1
				n = [R1 col1];
			}
			else 
			{
				//rectangle 1 is on the right hand side of rectangle 2
				n = [[R1 col1] negate];
			}
			
			nf = n;
			df = [p1 dot:nf] + h1.x;
			ns = [R1 col2];
			ds = [p1 dot:ns];
			dneg = h1.y - ds;
			dpos = h1.y + ds;
			
			//incident edge
			ni = [[[R2 transpose] multiplyVector:nf] negate];
			p = p2;
			r = R2;
			h = h2;
			
			break;
            
		case 1:
			//NSLog(@"1");
			if (d1.y >= 0)
			{
				//rectangle 2 is on top of rectangle 1.
				n = [R1 col2];
			}
			else
			{
                //rectangle 2 is on bottom of rectangle 1.
				n = [[R1 col2] negate];
			}
			
			nf = n;
			df = [p1 dot:nf] + h1.y;
			ns = [R1 col1];
			ds = [p1 dot:ns];
			dneg = h1.x - ds;
			dpos = h1.x + ds;
			
			//incident edge
			ni = [[[R2 transpose] multiplyVector:nf] negate];
			p = p2;
			r = R2;
			h = h2;
			
			break;
		case 2:
			//NSLog(@"2");
            
			if (d2.x >= 0) 
			{
				//rectangle 1 is on the right hand side of rectangle 2.
				n = [R2 col1];
			}
			else
			{
				//rectangle 1 is on the left hand side of rectangle 2.
				n = [[R2 col1] negate];
			}
			
			nf = [n negate];
			df = [p2 dot:nf] + h2.x;
			ns = [R2 col2];
			ds = [p2 dot:ns];
			dneg = h2.y - ds;
			dpos = h2.y + ds;
			
			//incident edge
			ni = [[[R1 transpose] multiplyVector:nf]negate];
			p = p1;
			r = R1;
			h = h1;
			
			break;
		case 3:
			//NSLog(@"3");
            
			if (d2.y >= 0)
			{
				//rectangle 1 is on top of rectangle 2.
				n = [R2 col2];
			}
			else
			{
				//rectangle 1 is on bottom of rectangle 2.
				n = [[R2 col2]negate];
			}
			
			nf = [n negate];
			df = [p2 dot:nf] + h2.y;
			ns = [R2 col1];
			ds = [p2 dot:ns];
			dneg = h2.x - ds;
			dpos = h2.x + ds;
			
			//incident edge
			ni = [[[R1 transpose] multiplyVector:nf]negate];
			p = p1;
			r = R1;
			h = h1;
			
			break;
		default:
			break;
	}
	
	Vector2D *v1, *v2;	
	//incident edge with vertices v1 and v2
	if ([[ni abs] x] > [[ni abs] y] && [ni x] > 0) {
		v1 = [p add:[r multiplyVector:[Vector2D vectorWith:h.x y:-h.y]]];
		v2 = [p add:[r multiplyVector:[Vector2D vectorWith:h.x y:h.y]]];
	}
	
	if ([[ni abs] x] > [[ni abs] y] && [ni x] <=0) {
		v1 = [p add:[r multiplyVector:[Vector2D vectorWith:-h.x y:h.y]]];
		v2 = [p add:[r multiplyVector:[Vector2D vectorWith:-h.x y:-h.y]]];
	}
	
	if ([[ni abs] x] <= [[ni abs] y] && [ni y] >0) {
		v1 = [p add:[r multiplyVector:[Vector2D vectorWith:h.x y:h.y]]];
		v2 = [p add:[r multiplyVector:[Vector2D vectorWith:-h.x y:h.y]]];
	}
	
	if ([[ni abs] x] <= [[ni abs] y] && [ni y] <=0) {
		v1 = [p add:[r multiplyVector:[Vector2D vectorWith:-h.x y:-h.y]]];
		v2 = [p add:[r multiplyVector:[Vector2D vectorWith:h.x y:-h.y]]];
	}
	
	//First Clipping
	Vector2D *v1c, *v2c; //points after clipping
	double dist1, dist2;
	dist1 = [[ns negate] dot:v1] - dneg;
	dist2 = [[ns negate] dot:v2] - dneg;
	
	if (dist1 > 0 && dist2 > 0) {
		//NSLog(@"Not Colliding");
		return;
	}
    
	if(dist1 < 0 && dist2 < 0)
	{
		v1c = v1;
		v2c = v2;
	}
	
	if (dist1 < 0 && dist2 > 0) {
		v1c = v1;
		v2c = [v1 add: [[v2 subtract:v1] multiply:(dist1/(dist1-dist2))]];
	}
	
	if (dist1 > 0 && dist2 < 0) {
		v1c = v2;
		v2c = [v1 add: [[v2 subtract:v1] multiply:(dist1/(dist1-dist2))]];
	}
    
	//Second Clipping
	Vector2D *v1cc, *v2cc;
	
	dist1 = [ns dot:v1c] - dpos;
	dist2 = [ns dot:v2c] - dpos;
	
	if (dist1 > 0 && dist2 > 0) {
		//NSLog(@"Not colliding2");
		return;
	}
	
	if (dist1 < 0 && dist2 < 0) {
		v1cc = v1c;
		v2cc = v2c;
	}
	
	if (dist1 < 0 && dist2 > 0) {
		v1cc = v1c;
		v2cc = [v1c add: [[v2c subtract:v1c] multiply:(dist1/(dist1-dist2))]];
    }
	
	if (dist1 > 0 && dist2 < 0) {
		v1cc = v2c;
		v2cc = [v1c add: [[v2c subtract:v1c] multiply:(dist1/(dist1-dist2))]];
	}
	
	//contact points
	Vector2D *c1, *c2;
	double separation;
	
	separation = [nf dot:v1cc] - df;
	
	if (separation < 0) {
		c1 = [v1cc subtract:[nf multiply:separation]];
       // NSLog(@"%f,%f",c1.x,c1.y);
		[self handleImpulse:two : one :c1 :n: separation];
        //[self.delegate showPt:CGPointMake(c1.x, c1.y)];
	}
	
	separation = [nf dot:v2cc] - df;
	
	if (separation < 0) {
		c2 = [v2cc subtract:[nf multiply:separation]];
       // NSLog(@"%f,%f",c2.x,c2.y);
		[self handleImpulse:two : one :c2 :n: separation];
       // [self.delegate showPt:CGPointMake(c2.x, c2.y)];
	}
}

-(void) handleCollisionCR: (CircleModel*) cir with: (RectModel*) rect
{	
    //REQUIRES: all objects passed in cannot be nil. This is ensured by caller
    //EFFECT: find contact points and seperation if one intersects two, and call handleImpulse to resolve collision
    Vector2D *cirCenter = [Vector2D vectorWith:cir.center.x y:cir.center.y];
    //get the 2 edges that may collide with circle
    NSArray *corners = rect.corners;
    CGFloat minDist = MAXFLOAT;
    int choice = 0;
    for(int i=0;i<4;i++){
        Vector2D *temp = [corners objectAtIndex:i];
        CGFloat tempdist = [[temp subtract:cirCenter] length];
        if(minDist > tempdist){
            minDist = tempdist;
            choice = i;
        }
    }
    Vector2D *edge1, *edge2;
    int node1 = (choice==0)?3:choice-1;
    Vector2D *refPt = [corners objectAtIndex:choice];
    Vector2D *Node1 = [corners objectAtIndex:node1];
    edge1 = [refPt subtract:Node1];
    int node2 = (choice==3)?0:choice+1;
    Vector2D *Node2 = [corners objectAtIndex:node2];
    edge2 = [refPt subtract:Node2];
    
    //get the perpendicular distance
    Vector2D *edge1Unit = [edge1 multiply:1/[edge1 length]];
    Vector2D *edge2Unit = [edge2 multiply:1/[edge2 length]];
	Vector2D *cirCenterToPt = [refPt subtract:cirCenter];
    
	Vector2D *projOnEdge1 = [edge1Unit multiply:[cirCenterToPt dot:edge1Unit]];
    Vector2D *projOnEdge2 = [edge2Unit multiply:[cirCenterToPt dot:edge2Unit]];
    
    //determine if they collides
    CGFloat dist1 = [[cirCenterToPt subtract:projOnEdge1] length];
    CGFloat dist2 = [[cirCenterToPt subtract:projOnEdge2] length];
    if(dist1>cir.radius && dist2>cir.radius){
        //do not collide
        //NSLog(@"do not collide");
        return;
    }
    
    //determine where the perpendicular foot lands
    Vector2D *foot1 = [[cirCenterToPt subtract:projOnEdge1] add:cirCenter];
    Vector2D *foot2 = [[cirCenterToPt subtract:projOnEdge2] add:cirCenter];
    CGFloat leftBound, rightBound, upperBound, lowerBound;
    //foot1 against edge 1
    BOOL foot1OnEdge1 = YES;
    leftBound = MIN(refPt.x,Node1.x);
    rightBound = MAX(refPt.x,Node1.x);
    upperBound = MIN(refPt.y,Node1.y);
    lowerBound = MAX(refPt.y,Node1.y);
    if(foot1.x<leftBound || foot1.x>rightBound || foot1.y<upperBound || foot1.y>lowerBound)
        foot1OnEdge1 = NO;
    //foot2 against edge 2
    BOOL foot2OnEdge2 = YES;
    leftBound = MIN(refPt.x,Node2.x);
    rightBound = MAX(refPt.x,Node2.x);
    upperBound = MIN(refPt.y,Node2.y);
    lowerBound = MAX(refPt.y,Node2.y);
    if(foot2.x<leftBound || foot2.x>rightBound || foot2.y<upperBound || foot2.y>lowerBound)
        foot2OnEdge2 = NO;
    
    //determine contact point
    //normal has problem
    Vector2D *contact;
    CGFloat separation;
    Vector2D *normal;
    if(foot1OnEdge1 && foot2OnEdge2)
        NSLog(@"this should never happen");
    else if(foot1OnEdge1){
        if(dist1 > cir.radius)
            return;
        else{
            contact = foot1;
            separation = dist1-cir.radius;
            normal = [[cirCenter subtract:foot1] multiply:1/dist1];
        }
    }
    else if(foot2OnEdge2){
        if(dist2 > cir.radius)
            return;
        else{
            contact = foot2;
            separation = dist2-cir.radius;
            normal = [[cirCenter subtract:foot2] multiply:1/dist2];
        }
    }
    else{
        CGFloat dist = [[refPt subtract:cirCenter] length];
        if(dist > cir.radius)
            return;
        else{
            contact = refPt;
            separation = dist-cir.radius;
            normal = [[refPt subtract:cirCenter] multiply:-1/dist];
        }
    }
   // [[NSNotificationCenter defaultCenter] postNotificationName:@"showPoint" object:contact];
    [self handleImpulse:cir :rect :contact :normal :separation];
}

-(void) handleCollisionCC: (CircleModel*) one with: (CircleModel*) two
{
    //Effect: if 2 circles collide, they should both be removed
    Vector2D *center1 = [Vector2D vectorWith:one.center.x y:one.center.y];
    Vector2D *center2 = [Vector2D vectorWith:two.center.x y:two.center.y];
    double dist = [[center1 subtract:center2] length];
    if (dist < one.radius + two.radius){
        one.disappear = YES;
        two.disappear = YES;
    }
}

-(void) handleCollision: (ObjectModel*) one with: (ObjectModel*) two
{
    //Effect: deduce collision type of one and two, invoke method accordingly
    if ([one isKindOfClass:[RectModel class]] && [two isKindOfClass:[RectModel class]])
        [self handleCollisionRR:(RectModel*)one with:(RectModel*)two];
    else if ([one isKindOfClass:[CircleModel class]] && [two isKindOfClass:[RectModel class]])
        [self handleCollisionCR:(CircleModel*)one with:(RectModel*)two];
    else if ([one isKindOfClass:[RectModel class]] && [two isKindOfClass:[CircleModel class]])
        [self handleCollisionCR:(CircleModel*)two with:(RectModel*)one];
    else if ([one isKindOfClass:[CircleModel class]] && [two isKindOfClass:[CircleModel class]])
        [self handleCollisionCC:(CircleModel*)one with:(CircleModel*)two];
    else
        NSLog(@"error at handle collision");
}

-(void) calcCollision
{
    //Effect: loop through all physics bodies and resolve their collisions
    for (int i=0; i<[objects count]; i++){
        [self handleCollision:[objects objectAtIndex:i] with:ground];
        for (int j=i+1; j<[objects count]; j++){
            if([objects objectAtIndex:i] == [objects objectAtIndex:j])
                continue;
            [self handleCollision:[objects objectAtIndex:i] with:[objects objectAtIndex:j]];
        }
    }
}

-(void) timeStepping
{
    //Effect: perform one step into the physics world
    [self updateGravityEffects];
    [self calcCollision];
    [self updatePositions];
    [self renderPositions];
}

@end
