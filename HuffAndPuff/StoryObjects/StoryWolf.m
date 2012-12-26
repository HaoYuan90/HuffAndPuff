#import "StoryWolf.h"

@implementation StoryWolf

#define wolfImageName (@"wolfs.png") 
#define wolfInitPositionX 20
#define wolfInitPositionY 10
#define wolfDefaultwidth 225
#define wolfDefaultHeight 150
#define wolfSpriteWidth 225
#define wolfSpriteHeight 150

- (id)initWithPlatte:(UIView*)pla gameArea:(UIScrollView*)gam
{
    self = [super initWithPlatte:pla gameArea:gam];
    objectType = StoryObjectWolf;
    
    palette_x = wolfInitPositionX;
    palette_y = wolfInitPositionY;
    gameArea_width = wolfDefaultwidth;
    gameArea_height = wolfDefaultHeight;
    model = [[RectModel alloc] initWithOrigin:CGPointMake(palette_x, palette_y)
                                        width:palette_size height:palette_size mass:0];
    [palette addSubview:self.view];
    return self;
}

- (id)initWithPlatte:(UIView*)Pal gameArea:(UIScrollView*)gam dictionary:(NSDictionary*)Dic
{
    objectType = StoryObjectWolf;
    
    palette_x = wolfInitPositionX;
    palette_y = wolfInitPositionY;
    gameArea_width = wolfDefaultwidth;
    gameArea_height = wolfDefaultHeight;
    self = [super initWithPlatte:Pal gameArea:gam dictionary:Dic];
    
    return self;
}

-(void)translationFromPalToGam
{
    //Effect: handle the case when object is translated from pallete to gameArea
    [super translationFromPalToGam];
    StoryWolf *newWolf = [[StoryWolf alloc] initWithPlatte:palette gameArea:gameArea];
    [[self parentViewController] addChildViewController:newWolf];
}

#pragma mark - View lifecycle

- (void)loadView
{    
    UIImage *wolfsImage = [UIImage imageNamed:wolfImageName];
    CGImageRef temp = CGImageCreateWithImageInRect([wolfsImage CGImage], 
                                                   CGRectMake(0, 0, wolfSpriteWidth, wolfSpriteHeight));
    UIImage *wolfImage = [UIImage imageWithCGImage:temp];
    UIImageView *wolf = [[UIImageView alloc] initWithImage:wolfImage];
    [wolf setUserInteractionEnabled:YES];
    wolf.frame = CGRectMake(model.origin.x, model.origin.y, model.width, model.height);
    self.view = wolf;
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
    
    UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(rotate:)];
    [self.view addGestureRecognizer:rotation];

    UIPinchGestureRecognizer *zooming = [[UIPinchGestureRecognizer alloc]
                                         initWithTarget:self action:@selector(zoom:)];
    [self.view addGestureRecognizer:zooming];
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
