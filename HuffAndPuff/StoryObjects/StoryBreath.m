#import "StoryBreath.h"

@implementation StoryBreath

#define breathImageName (@"windblow.png") 
#define breathInitPositionX 320
#define breathInitPositionY 10
#define breathDefaultSize 60
#define breathSpriteWidth 110
#define breathSpriteHeight 100

- (id)initWithPlatte:(UIView*)pla gameArea:(UIScrollView*)gam
{
    self = [super initWithPlatte:pla gameArea:gam];
    objectType = StoryObjectBreath;
    
    palette_x = breathInitPositionX;
    palette_y = breathInitPositionY;
    gameArea_width = breathDefaultSize;
    gameArea_height = breathDefaultSize;
    model = [[RectModel alloc] initWithOrigin:CGPointMake(palette_x, palette_y)
                                        width:palette_size height:palette_size mass:0];
    [palette addSubview:self.view];
    return self;
}

- (id)initWithPlatte:(UIView*)Pal gameArea:(UIScrollView*)gam dictionary:(NSDictionary*)Dic
{
    objectType = StoryObjectBreath;
    
    palette_x = breathInitPositionX;
    palette_y = breathInitPositionY;
    gameArea_width = breathDefaultSize;
    gameArea_height = breathDefaultSize;
    self = [super initWithPlatte:Pal gameArea:gam dictionary:Dic];
    
    return self;
}

-(void)translationFromPalToGam
{
    //Effect: handle the case when object is translated from pallete to gameArea
    [super translationFromPalToGam];
    StoryBreath *newBreath = [[StoryBreath alloc] initWithPlatte:palette gameArea:gameArea];
    [[self parentViewController] addChildViewController:newBreath];
}

#pragma mark - View lifecycle

- (void)loadView
{    
    UIImage *breathsImage = [UIImage imageNamed:breathImageName];
    CGImageRef temp = CGImageCreateWithImageInRect([breathsImage CGImage], 
                                                   CGRectMake(0, 0, breathSpriteWidth, breathSpriteHeight));
    UIImage *breathImage = [UIImage imageWithCGImage:temp];
    UIImageView *breath = [[UIImageView alloc] initWithImage:breathImage];
    [breath setUserInteractionEnabled:YES];
    breath.frame = CGRectMake(model.origin.x, model.origin.y, model.width, model.height);
    self.view = breath;
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
