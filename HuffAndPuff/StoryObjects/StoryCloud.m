#import "StoryCloud.h"

@implementation StoryCloud

#define cloud1ImageName (@"cloud1.png") 
#define cloud2ImageName (@"cloud2.png") 
#define cloud3ImageName (@"cloud3.png") 
#define numCloudType 3
#define cloudInitPositionX 245
#define cloudInitPositionY 10
#define cloudDefaultwidth 125
#define cloudDefaultHeight 65

@synthesize cloudType;

- (id)initWithPlatte:(UIView*)pla gameArea:(UIScrollView*)gam
{
    self = [super initWithPlatte:pla gameArea:gam];
    objectType = StoryObjectCloud;
    cloudType = cloudType1;
    
    palette_x = cloudInitPositionX;
    palette_y = cloudInitPositionY;
    gameArea_width = cloudDefaultwidth;
    gameArea_height = cloudDefaultHeight;
    model = [[RectModel alloc] initWithOrigin:CGPointMake(palette_x, palette_y)
                                        width:palette_size height:palette_size mass:0];
    [palette addSubview:self.view];
    return self;
}

- (id)initWithPlatte:(UIView*)Pal gameArea:(UIScrollView*)gam dictionary:(NSDictionary*)Dic
{
    objectType = StoryObjectCloud;
    cloudType  = [[Dic valueForKey:@"cloudtype"] intValue];
    
    palette_x = cloudInitPositionX;
    palette_y = cloudInitPositionY;
    gameArea_width = cloudDefaultwidth;
    gameArea_height = cloudDefaultHeight;
    self = [super initWithPlatte:Pal gameArea:gam dictionary:Dic];
    
    return self;
}

- (NSDictionary*)exportAsDictionary
{
    NSMutableDictionary* temp = [NSMutableDictionary dictionaryWithDictionary:[super exportAsDictionary]];
    [temp setObject:[NSNumber numberWithInt:cloudType] forKey:@"cloudtype"];
    return [NSDictionary dictionaryWithDictionary:temp];
}

-(void)translationFromPalToGam
{
    //Effect: handle the case when object is translated from pallete to gameArea
    [super translationFromPalToGam];
    StoryCloud *newBlock = [[StoryCloud alloc] initWithPlatte:palette gameArea:gameArea];
    [[self parentViewController] addChildViewController:newBlock];
}

-(void)singleTap:(UITapGestureRecognizer *)gesture
{
    if (self.view.superview == gameArea){
        cloudType = (cloudType+1)%numCloudType;
        [self.view removeFromSuperview];
        [self loadView];
        [self viewDidLoad];
        [gameArea addSubview:self.view];
    }
}

#pragma mark - View lifecycle

- (void)loadView
{
    UIImage *cloudImage;
    switch (cloudType) {
        case cloudType1:
            cloudImage = [UIImage imageNamed:cloud1ImageName];
            break;
        case cloudType2:
            cloudImage = [UIImage imageNamed:cloud2ImageName];
            break;
        case cloudType3:
            cloudImage = [UIImage imageNamed:cloud3ImageName];
            break;
        default:
            NSLog(@"wrong cloud type");
    }
    UIImageView *cloud = [[UIImageView alloc] initWithImage:cloudImage];
    [cloud setUserInteractionEnabled:YES];
    cloud.frame = CGRectMake(model.origin.x, model.origin.y, model.width, model.height);
    self.view = cloud;
    [self.view setTransform:CGAffineTransformMakeRotation(model.rotation * M_PI / 180 )];
}

- (void)viewDidLoad
{
    UIPanGestureRecognizer *translation = [[UIPanGestureRecognizer alloc]
                                           initWithTarget:self action:@selector(translate:)];
    [self.view addGestureRecognizer:translation];
    UIPinchGestureRecognizer *zooming = [[UIPinchGestureRecognizer alloc]
                                         initWithTarget:self action:@selector(zoom:)];
    [self.view addGestureRecognizer:zooming];
    UITapGestureRecognizer *doubleTapping = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(doubleTap:)];
    doubleTapping.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTapping];
    //for blocks to respond to both
    UITapGestureRecognizer *singleTapping = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(singleTap:)];
    singleTapping.numberOfTapsRequired = 1;
    [singleTapping requireGestureRecognizerToFail: doubleTapping];
    [self.view addGestureRecognizer:singleTapping];
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
