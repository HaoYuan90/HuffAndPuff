#import "GameWolf.h"

@implementation GameWolf

#define wolfImageName (@"wolfs.png") 
#define wolfInitPositionX 20
#define wolfInitPositionY 10
#define wolfDefaultwidth 225
#define wolfDefaultHeight 150
#define wolfSpriteWidth 225
#define wolfSpriteHeight 150

#define wolfFric 0.95
#define wolfRest 0.3

#define breathXOffset 0.31
#define breathRad 30

#define deadImageName (@"wolfdie.png") 
#define deadSpriteWidth 237
#define deadSpriteHeight 185

@synthesize livingWolf;
@synthesize delegate;

- (id)initWithPlatte:(UIView*)pla gameArea:(UIScrollView*)gam engine:(Engine*)eng delegate:(id<GameWolfDelegate>) del
{
    self = [super initWithPlatte:pla gameArea:gam engine:eng];
    objectType = kGameObjectWolf;
    
    palette_x = wolfInitPositionX;
    palette_y = wolfInitPositionY;
    gameArea_width = wolfDefaultwidth;
    gameArea_height = wolfDefaultHeight;
    model = [[RectModel alloc] initWithOrigin:CGPointMake(palette_x,palette_y) width:palette_size 
                            height:palette_size mass:10 restitution:wolfRest friction:wolfFric collisionType:kWolf];
    delegate = del;
    [palette addSubview:self.view];
    return self;
}

- (id)initWithPlatte:(UIView*)Pal gameArea:(UIScrollView*)gam engine:(Engine*)eng
          dictionary:(NSDictionary*)Dic delegate:(id<GameWolfDelegate>) del
{
    objectType = kGameObjectWolf;
    
    palette_x = wolfInitPositionX;
    palette_y = wolfInitPositionY;
    gameArea_width = wolfDefaultwidth;
    gameArea_height = wolfDefaultHeight;
    delegate = del;
    self = [super initWithPlatte:Pal gameArea:gam engine:eng dictionary:Dic];
    [engine removeObject:self.model];
    model.colType = kWolf;
    
    return self;
}

-(void)reloadView
{
    return;
}

-(void)die
{
    //Effect: change the view to a dead wolf with animation
    [self removeFromParentViewController];
    UIImage *deadsImage = [UIImage imageNamed:deadImageName];
    NSMutableArray *images = [NSMutableArray array];
    CGFloat x=0, y=-deadSpriteHeight;
    for(int i=0; i<16;i++){
        if (i%4 == 0){
            x=0;
            y+=deadSpriteHeight;
        }
        else
            x+=deadSpriteWidth;
        CGImageRef temp = CGImageCreateWithImageInRect([deadsImage CGImage], 
                                                       CGRectMake(x, y, deadSpriteWidth, deadSpriteHeight));
        UIImage *wolfImage = [UIImage imageWithCGImage:temp];
        [images addObject:wolfImage];
    }
    UIImage *defaultDead = (UIImage*)[images lastObject];
    UIImageView *deadWolf = [[UIImageView alloc] initWithImage:defaultDead];
    deadWolf.frame = CGRectMake(model.origin.x, model.origin.y, model.width, model.height);
    [deadWolf setUserInteractionEnabled:YES];
	deadWolf.animationImages = images;
	deadWolf.animationDuration = 1.1;
    deadWolf.animationRepeatCount = 1;
    self.view = deadWolf;
    [deadWolf startAnimating];
}

-(void)startBreathAnimation
{
    //Effect: start breathing animation and invoke intemediate functions with a timer
    livingWolf.userInteractionEnabled = NO;
    [self performSelector:@selector(breath) withObject:nil afterDelay:livingWolf.animationDuration/2];
    [self performSelector:@selector(didFinishAnimation) withObject:nil afterDelay:livingWolf.animationDuration];
    [livingWolf startAnimating];
}

-(void)didFinishAnimation
{
    //Effect: called when animation is finished
    livingWolf.userInteractionEnabled = YES;
    [self.delegate didLaunchProjectile];
}

-(void)breath
{
    //Effect: called when breathing stage of animation is reached, lauch a projectile with data given by delegate 
    //from wolf's mouth
    CGPoint temp = [self mouthPosition];
    temp = CGPointMake(temp.x-breathRad-breathXOffset*livingWolf.frame.size.width, temp.y-breathRad);
    
    Vector2D *velocity = [self.delegate projectileVelocity];
    [self.parentViewController addChildViewController:[[GameBreath alloc] initWithGameArea:gameArea Engine:engine 
                                                                                        At:temp Radius:breathRad Velocity:velocity]];
}

-(void)launchProjectile
{
    //Effect: this is a gesture handler for single tapping added by main view controller when game starts
    [self startBreathAnimation];
}


-(CGPoint)mouthPosition
{
    return CGPointMake(model.origin.x+model.width, model.origin.y+model.height*0.3);
}

#pragma mark - View lifecycle

- (void)loadView
{    
    UIImage *wolfsImage = [UIImage imageNamed:wolfImageName];
    NSMutableArray *images = [NSMutableArray array];
    CGFloat x=0, y=-wolfSpriteHeight;
    for(int i=0; i<15;i++){
        if (i%5 == 0){
            x=0;
            y+=wolfSpriteHeight;
        }
        else
            x+=wolfSpriteWidth;
        CGImageRef temp = CGImageCreateWithImageInRect([wolfsImage CGImage], 
                                                       CGRectMake(x, y, wolfSpriteWidth, wolfSpriteHeight));
        UIImage *wolfImage = [UIImage imageWithCGImage:temp];
        [images addObject:wolfImage];
    }
    UIImage *defaultWolf = (UIImage*)[images objectAtIndex:0];
    livingWolf = [[UIImageView alloc] initWithImage:defaultWolf];
    livingWolf.frame = CGRectMake(model.origin.x, model.origin.y, model.width, model.height);
    [livingWolf setUserInteractionEnabled:YES];
	livingWolf.animationImages = images;
	livingWolf.animationDuration = 1.1;
    livingWolf.animationRepeatCount = 1;
    self.view = livingWolf;
    [self.view setTransform:CGAffineTransformMakeRotation(model.rotation * M_PI / 180 )];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIPanGestureRecognizer *translation = [[UIPanGestureRecognizer alloc]
                                           initWithTarget:self action:@selector(translate:)];
    [self.view addGestureRecognizer:translation];
    UITapGestureRecognizer *doubleTapping = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(doubleTap:)];
    doubleTapping.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTapping];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
