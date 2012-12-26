#import "GamePig.h"

@implementation GamePig

#define pigImageName (@"pig.png")
#define pigInitPositionX 95
#define pigInitPositionY 10
#define pigDefaultwidth 90
#define pigDefaultHeight 90

#define pigFric 0.95
#define pigRest 0
#define pigMass 20

#define pigSmokeImageName (@"pig-die-smoke.png")
#define pigSmokeSpriteWidth 80
#define pigSmokeSpriteHeight 80

- (id)initWithPlatte:(UIView*)pla gameArea:(UIScrollView*)gam engine:(Engine*)eng
{
    self = [super initWithPlatte:pla gameArea:gam engine:eng];
    objectType = kGameObjectPig;
    
    palette_x = pigInitPositionX;
    palette_y = pigInitPositionY;
    gameArea_width = pigDefaultwidth;
    gameArea_height = pigDefaultHeight;
    model = [[RectModel alloc] initWithOrigin:CGPointMake(palette_x, palette_y)width:palette_size 
                                       height:palette_size mass:pigMass 
                                  restitution:pigRest friction:pigFric collisionType:kPig];
    [palette addSubview:self.view];
    return self;
}

- (id)initWithPlatte:(UIView*)Pal gameArea:(UIScrollView*)gam engine:(Engine*)eng
          dictionary:(NSDictionary*)Dic
{
    objectType = kGameObjectPig;
    
    palette_x = pigInitPositionX;
    palette_y = pigInitPositionY;
    gameArea_width = pigDefaultwidth;
    gameArea_height = pigDefaultHeight;
    self = [super initWithPlatte:Pal gameArea:gam engine:eng dictionary:Dic];
    
    model.colType = kPig;
    
    return self;
}

-(void)translationFromPalToGam{
    [super translationFromPalToGam];
    GamePig *newPig = [[GamePig alloc] initWithPlatte:palette gameArea:gameArea engine:engine];
    [[self parentViewController] addChildViewController:newPig];
}

-(void)translationFromGamToPal
{
    [self.view removeFromSuperview];
    [engine removeObject:model];
    [self removeFromParentViewController];
}

- (void) animatedSelfDestruct
{
    [self removeFromParentViewController];
    
    UIImage *smokesImage = [UIImage imageNamed:pigSmokeImageName];
    NSMutableArray *images = [NSMutableArray array];
    CGFloat x=0, y=-pigSmokeSpriteHeight;
    for(int i=0; i<10;i++){
        if(i%5 == 0){
            y+=pigSmokeSpriteHeight;
            x=0;
        }
        else
            x+=pigSmokeSpriteWidth;
        CGImageRef temp = CGImageCreateWithImageInRect([smokesImage CGImage], 
                                                       CGRectMake(x, y, pigSmokeSpriteWidth, pigSmokeSpriteHeight));
        UIImage *smokeImage = [UIImage imageWithCGImage:temp];
        [images addObject:smokeImage];
    }
    UIImage *defaultSmoke = (UIImage*)[images objectAtIndex:0];
    UIImageView *smoke = [[UIImageView alloc] initWithImage:defaultSmoke];
    smoke.frame = model.boundingBox;
	smoke.animationImages = images;
	smoke.animationDuration = 1;
    smoke.animationRepeatCount = 1;
    self.view = smoke;
    [self performSelector:@selector(removeView) withObject:nil afterDelay:smoke.animationDuration];
    [smoke startAnimating];
}

-(void)removeView
{
    [self.view removeFromSuperview];
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
