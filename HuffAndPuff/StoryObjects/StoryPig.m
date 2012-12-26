#import "StoryPig.h"

@implementation StoryPig

#define pigImageName (@"pig.png") 
#define pigInitPositionX 95
#define pigInitPositionY 10
#define pigDefaultwidth 90
#define pigDefaultHeight 90

- (id)initWithPlatte:(UIView*)pla gameArea:(UIScrollView*)gam
{
    self = [super initWithPlatte:pla gameArea:gam];
    objectType = StoryObjectPig;
    
    palette_x = pigInitPositionX;
    palette_y = pigInitPositionY;
    gameArea_width = pigDefaultwidth;
    gameArea_height = pigDefaultHeight;
    model = [[RectModel alloc] initWithOrigin:CGPointMake(palette_x, palette_y)
                                        width:palette_size height:palette_size mass:0];
    [palette addSubview:self.view];
    return self;
}

- (id)initWithPlatte:(UIView*)Pal gameArea:(UIScrollView*)gam dictionary:(NSDictionary*)Dic
{
    objectType = StoryObjectPig;
    
    palette_x = pigInitPositionX;
    palette_y = pigInitPositionY;
    gameArea_width = pigDefaultwidth;
    gameArea_height = pigDefaultHeight;
    self = [super initWithPlatte:Pal gameArea:gam dictionary:Dic];
    
    return self;
}

-(void)translationFromPalToGam
{
    //Effect: handle the case when object is translated from pallete to gameArea
    [super translationFromPalToGam];
    StoryPig *newPig = [[StoryPig alloc] initWithPlatte:palette gameArea:gameArea];
    [[self parentViewController] addChildViewController:newPig];
}

#pragma mark - View lifecycle

- (void)loadView
{
    UIImage *pigImage = [UIImage imageNamed:pigImageName];
    UIImageView *pig = [[UIImageView alloc] initWithImage:pigImage];
    [pig setUserInteractionEnabled:YES];
    pig.frame = CGRectMake(model.origin.x, model.origin.y, model.width, model.height);
    self.view = pig;
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
