#import "StoryBlock.h"

@implementation StoryBlock

#define strawImageName (@"straw.png") 
#define woodImageName (@"wood.png") 
#define ironImageName (@"iron.png") 
#define stoneImageName (@"stone.png") 
#define numBlockType 4
#define blockInitPositionX 170
#define blockInitPositionY 10
#define blockDefaultwidth 30
#define blockDefaultHeight 130

@synthesize blockType;

- (id)initWithPlatte:(UIView*)pla gameArea:(UIScrollView*)gam
{
    self = [super initWithPlatte:pla gameArea:gam];
    objectType = StoryObjectBlock;
    blockType = kBlockStraw;
    
    palette_x = blockInitPositionX;
    palette_y = blockInitPositionY;
    gameArea_width = blockDefaultwidth;
    gameArea_height = blockDefaultHeight;
    model = [[RectModel alloc] initWithOrigin:CGPointMake(palette_x, palette_y)
                                        width:palette_size height:palette_size mass:0];
    [palette addSubview:self.view];
    return self;
}

- (id)initWithPlatte:(UIView*)Pal gameArea:(UIScrollView*)gam dictionary:(NSDictionary*)Dic
{
    objectType = StoryObjectBlock;
    blockType  = [[Dic valueForKey:@"blocktype"] intValue];
    
    palette_x = blockInitPositionX;
    palette_y = blockInitPositionY;
    gameArea_width = blockDefaultwidth;
    gameArea_height = blockDefaultHeight;
    self = [super initWithPlatte:Pal gameArea:gam dictionary:Dic];
    
    return self;
}

- (NSDictionary*)exportAsDictionary
{
    NSMutableDictionary* temp = [NSMutableDictionary dictionaryWithDictionary:[super exportAsDictionary]];
    [temp setObject:[NSNumber numberWithInt:blockType] forKey:@"blocktype"];
    return [NSDictionary dictionaryWithDictionary:temp];
}

-(void)translationFromPalToGam
{
    //Effect: handle the case when object is translated from pallete to gameArea
    [super translationFromPalToGam];
    StoryBlock *newBlock = [[StoryBlock alloc] initWithPlatte:palette gameArea:gameArea];
    [[self parentViewController] addChildViewController:newBlock];
}

-(void)singleTap:(UITapGestureRecognizer *)gesture
{
    if (self.view.superview == gameArea){
        blockType = (blockType+1)%numBlockType;
        [self.view removeFromSuperview];
        [self loadView];
        [self viewDidLoad];
        [gameArea addSubview:self.view];
    }
}

#pragma mark - View lifecycle

- (void)loadView
{
    UIImage *blockImage;
    switch (blockType) {
        case kBlockStraw:
            blockImage = [UIImage imageNamed:strawImageName];
            break;
        case kBlockWood:
            blockImage = [UIImage imageNamed:woodImageName];
            break;
        case kBlockIron:
            blockImage = [UIImage imageNamed:ironImageName];
            break;
        case kBlockStone:
            blockImage = [UIImage imageNamed:stoneImageName];
            break;
        default:
            NSLog(@"wrong block type");
    }
    UIImageView *block = [[UIImageView alloc] initWithImage:blockImage];
    [block setUserInteractionEnabled:YES];
    block.frame = CGRectMake(model.origin.x, model.origin.y, model.width, model.height);
    self.view = block;
    [self.view setTransform:CGAffineTransformMakeRotation(model.rotation * M_PI / 180 )];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(rotate:)];
    [self.view addGestureRecognizer:rotation];
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
