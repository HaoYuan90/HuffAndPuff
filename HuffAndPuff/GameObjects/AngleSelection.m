#import "AngleSelection.h"

@implementation AngleSelection

#define degreeImageOffsetX 50
#define degreeImageOffsetY -10
#define degreeImageName (@"direction-degree.png")
#define arrowImageOffest 0.7
#define arrowunselectedImageName (@"direction-arrow.png")

#define angleUpperBound 15
#define angleLowerBound 130

@synthesize gameArea;
@synthesize wolf;
@synthesize arrow;
@synthesize refCenter;
@synthesize angle;

- (id)initWithGameArea:(UIScrollView*)ga wolf:(GameWolf*)w
{
    self = [super init];
    if(self == nil){
        NSLog(@"malloc error");
        return self;
    }
    gameArea = ga;
    wolf = w;
    angle = angleUpperBound;
    [gameArea addSubview:self.view];
    return self;
}

- (void)translate:(UIPanGestureRecognizer *)gesture
{
    //Effect: move the arrow with user's gesture and change angle attribute accordingly
    CGPoint touchPt = [gesture locationInView:self.view];
    CGFloat angleRad = atan((touchPt.y-refCenter.y)/(touchPt.x-refCenter.x));
    angleRad += 0.5*M_PI;
    if(angleRad/M_PI*180 < angleUpperBound)
        angleRad = angleUpperBound * M_PI / 180;
    else if(angleRad/M_PI*180 > angleLowerBound)
        angleRad = angleLowerBound * M_PI / 180;
    angle = 90-angleRad*180/M_PI;
    [arrow setTransform:CGAffineTransformMakeRotation(angleRad)];
}

- (Vector2D*) directionVector
{
    //Effect: return directional unit vector of angle
    Vector2D *temp = [Vector2D vectorWith:cos(angle * M_PI / 180) y:-sin(angle * M_PI / 180)];
    return [temp multiply:[temp length]];
}

#pragma mark - View lifecycle
- (void)loadView
{
    CGPoint degreeOrigin = [wolf mouthPosition];
    degreeOrigin = CGPointMake(degreeOrigin.x-wolf.model.width/2+degreeImageOffsetX, 
                               degreeOrigin.y-wolf.model.height+degreeImageOffsetY);
    UIImage *degreeImage = [UIImage imageNamed:degreeImageName];
    UIImageView *degree = [[UIImageView alloc] initWithImage:degreeImage];
    [degree setUserInteractionEnabled:YES];
    degree.frame = CGRectMake(degreeOrigin.x, degreeOrigin.y, degreeImage.size.width, degreeImage.size.height);
    self.view = degree;
    
    UIImage *arrowImage = [UIImage imageNamed:arrowunselectedImageName];
    arrow = [[UIImageView alloc] initWithImage:arrowImage];
    arrow.frame = CGRectMake(-arrowImage.size.width/2, 0, 
                             arrowImage.size.width*arrowImageOffest, arrowImage.size.height*arrowImageOffest);
    [self.view addSubview:arrow];
    refCenter = CGPointMake(0, arrow.frame.size.height/2);
    [arrow setTransform:CGAffineTransformMakeRotation(angle * M_PI / 180)];
    angle = 90-angle;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIPanGestureRecognizer *translation = [[UIPanGestureRecognizer alloc]
                                           initWithTarget:self action:@selector(translate:)];
    [self.view addGestureRecognizer:translation];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    arrow = nil;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
