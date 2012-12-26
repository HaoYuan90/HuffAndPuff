#import "GameBreath.h"

@implementation GameBreath

#define breathImageName (@"windblow.png") 
#define disperseImageName (@"wind-disperse.png")
#define breathSpriteWidth 113
#define breathSpriteHeight 104
#define disperseSpriteWidth 272
#define disperseSpriteHeight 273

#define breathFric 0.3
#define breathRest 1

#define TMC 2

@synthesize model;
@synthesize gameArea;
@synthesize engine;

-(id)initWithGameArea:(UIScrollView *)ga Engine:(Engine *)eng At:(CGPoint)origin 
               Radius:(CGFloat)rad Velocity:(Vector2D*) vel
{
    self = [super init];
    if(self == nil){
        NSLog(@"malloc error");
        return self;
    }
    gameArea = ga;
    engine = eng;
    model = [[CircleModel alloc] initWithOrigin:origin radius:rad mass:10 
                                    restitution:breathRest friction:breathFric collisionType:kBreath];
    model.velocity = vel;
    [engine addObject:model];
    [gameArea addSubview:self.view];
    return self;
}

-(void)animatedSelfDestruct
{
    [self removeFromParentViewController];
    
    UIImage *dispersionImage = [UIImage imageNamed:disperseImageName];
    NSMutableArray *images = [NSMutableArray array];
    CGFloat x=0, y=-disperseSpriteHeight;
    for(int i=0; i<8;i++){
        if(i%4 == 0){
            y+=disperseSpriteHeight;
            x=0;
        }
        else
            x+=disperseSpriteWidth;
        CGImageRef temp = CGImageCreateWithImageInRect([dispersionImage CGImage], 
                                                       CGRectMake(x, y, disperseSpriteWidth, disperseSpriteHeight));
        UIImage *disperseImage = [UIImage imageWithCGImage:temp];
        [images addObject:disperseImage];
    }
    UIImage *defaultDisperse = (UIImage*)[images objectAtIndex:0];
    UIImageView *disperse = [[UIImageView alloc] initWithImage:defaultDisperse];
    disperse.frame = CGRectMake(model.origin.x-model.radius*TMC/2, model.origin.y-model.radius*TMC/2, 
                                model.radius*TMC, model.radius*TMC);
	disperse.animationImages = images;
	disperse.animationDuration = 1;
    disperse.animationRepeatCount = 1;
    self.view = disperse;
    [self performSelector:@selector(removeView) withObject:nil afterDelay:disperse.animationDuration];
    [disperse startAnimating];
}

-(void)removeView
{
    [self.view removeFromSuperview];
}

-(void)reloadView
{
    //Effect: reload the view and add a trajectory behind the breath
    [self.view setCenter:model.center];
    [self.view setTransform : CGAffineTransformMakeRotation(model.rotation * M_PI / 180 )];
    
    //draw a point at the breath's current center
    UIView *traj = [[UIView alloc] initWithFrame:CGRectMake(model.center.x-2.5, model.center.y-2.5, 5, 5)];
    traj.backgroundColor = [UIColor redColor];
    [gameArea addSubview: traj];
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{traj.alpha = 0;}
                     completion:^(BOOL finished) {[traj removeFromSuperview];}];
    
    if(model.disappear)
        [self animatedSelfDestruct];
}

#pragma mark - View lifecycle
- (void)loadView
{
    UIImage *breathsImage = [UIImage imageNamed:breathImageName];
    NSMutableArray *images = [NSMutableArray array];
    CGFloat x=-breathSpriteWidth, y=0;
    for(int i=0; i<4;i++){
        x += breathSpriteWidth;
        CGImageRef temp = CGImageCreateWithImageInRect([breathsImage CGImage], 
                                                       CGRectMake(x, y, breathSpriteWidth, breathSpriteHeight));
        UIImage *breathImage = [UIImage imageWithCGImage:temp];
        [images addObject:breathImage];
    }
    UIImage *defaultBreath = (UIImage*)[images objectAtIndex:0];
    UIImageView *breath = [[UIImageView alloc] initWithImage:defaultBreath];
    breath.frame = CGRectMake(model.origin.x-model.radius*TMC/2, model.origin.y-model.radius*TMC/2,
                              model.radius*TMC, model.radius*TMC);
	breath.animationImages = images;
	breath.animationDuration = 0.5;
    self.view = breath;
    [self.view setTransform:CGAffineTransformMakeRotation(model.rotation * M_PI / 180 )];
    [breath startAnimating];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];; 
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
