#import "GameBlock.h"

@implementation GameBlock

#define numBlockType 4
#define blockInitPositionX 180
#define blockInitPositionY 10
#define blockDefaultwidth 30
#define blockDefaultHeight 130

#define strawFric 0.95
#define strawRest 0.3
#define strawDen 0.01

#define woodFric 0.95
#define woodRest 0.2
#define woodDen 0.02

#define stoneFric 0.8
#define stoneRest 0
#define stoneDen 0.03

#define ironFric 0.6
#define ironRest 0.1
#define ironDen 0.04

@synthesize blockType;

- (id)initWithPlatte:(UIView*)pla gameArea:(UIScrollView*)gam engine:(Engine*)eng
{
    self = [super initWithPlatte:pla gameArea:gam engine:eng];
    objectType = kGameObjectBlock;
    blockType = kBlockStraw;
    
    palette_x = blockInitPositionX;
    palette_y = blockInitPositionY;
    gameArea_width = blockDefaultwidth;
    gameArea_height = blockDefaultHeight;
    model = [[RectModel alloc] initWithOrigin:CGPointMake(palette_x, palette_y)width:palette_size 
                                       height:palette_size mass:0 restitution:0 friction:0 collisionType:kStraw];
    [palette addSubview:self.view];
    return self;
}

- (id)initWithPlatte:(UIView*)Pal gameArea:(UIScrollView*)gam engine:(Engine*)eng
          dictionary:(NSDictionary*)Dic
{
    objectType = kGameObjectBlock;
    blockType  = [[Dic valueForKey:@"blocktype"] intValue];
    
    palette_x = blockInitPositionX;
    palette_y = blockInitPositionY;
    gameArea_width = blockDefaultwidth;
    gameArea_height = blockDefaultHeight;
    self = [super initWithPlatte:Pal gameArea:gam engine:eng dictionary:Dic];
    
    switch (blockType) {
        case kBlockStraw:
            model.colType = kStraw;
            break;
        case kBlockIron:
            model.colType = kIron;
            break;
        case kBlockStone:
            model.colType = kStone;
            break;
        case kBlockWood:
            model.colType = kWood;
            break;
        default:
            NSLog(@"wrong block type during init from dictionary");
            break;
    }
    
    return self;
}

- (void)setBlockStats :(BlockType) type
{
    //Effect: load block's data according to its type
    switch (blockType) {
        case kBlockStraw:
            model.restitution = strawRest;
            model.mass = strawDen * model.width * model.height;
            model.friction = strawFric;
            model.colType = kStraw;
            break;
        case kBlockWood:
            model.restitution = woodRest;
            model.mass = woodDen * model.width * model.height;
            model.friction = woodFric;
            model.colType = kWood;
            break;
        case kBlockIron:
            model.restitution = ironRest;
            model.mass = ironDen * model.width * model.height;
            model.friction = ironFric;
            model.colType = kIron;
            break;
        case kBlockStone:
            model.restitution = stoneRest;
            model.mass = stoneDen * model.width * model.height;
            model.friction = stoneFric;
            model.colType = kStone;
            break;
        default:
            NSLog(@"wrong block type");
    }
}

- (NSDictionary*)exportAsDictionary
{
    NSMutableDictionary* temp = [NSMutableDictionary dictionaryWithDictionary:[super exportAsDictionary]];
    [temp setObject:[NSNumber numberWithInt:blockType] forKey:@"blocktype"];
    return [NSDictionary dictionaryWithDictionary:temp];
}

-(void)translationFromPalToGam{
    [super translationFromPalToGam];
    GameBlock *newBlock = [[GameBlock alloc] initWithPlatte:palette gameArea:gameArea engine:engine];
    [[self parentViewController] addChildViewController:newBlock];
}

-(void)translationFromGamToPal
{
    [self.view removeFromSuperview];
    [engine removeObject:model];
    [self removeFromParentViewController];
}

-(void)singleTap:(UITapGestureRecognizer *)gesture
{
    //Effect: change the block type in a round-robin manner
    if (self.view.superview == gameArea){
        blockType = (blockType+1)%numBlockType;
        [self.view removeFromSuperview];
        [self loadView];
        [self viewDidLoad];
        [gameArea addSubview:self.view];
    }
}

-(void) animatedSelfDestruct
{
    [self removeFromParentViewController];
    [UIView animateWithDuration:1
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{self.view.alpha = 0;}
                     completion:^(BOOL finished) {[self.view removeFromSuperview];}];
}

#pragma mark - View lifecycle

- (void)loadView
{
    UIImage *blockImage;
    switch (blockType) {
        case kBlockStraw:
            blockImage = [UIImage imageNamed:@"straw.png"];
            break;
        case kBlockWood:
            blockImage = [UIImage imageNamed:@"wood.png"];
            break;
        case kBlockIron:
            blockImage = [UIImage imageNamed:@"iron.png"];
            break;
        case kBlockStone:
            blockImage = [UIImage imageNamed:@"stone.png"];
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
    
    [self setBlockStats:blockType];
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
