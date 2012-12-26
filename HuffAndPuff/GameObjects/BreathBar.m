#import "BreathBar.h"

@implementation BreathBar

#define breathBarImageName (@"breath-bar.png")
#define breathBarXOffset 20
#define breathBarFrameWidth 3
#define breathBarTopOffset 2 //deal with image do not fit in frame exactly

#define maxStrength 800

@synthesize gameArea;
@synthesize wolf;
@synthesize filler;
@synthesize strength;

- (id)initWithGameArea:(UIScrollView*)ga wolf:(GameWolf*)w
{
    self = [super init];
    if(self == nil){
        NSLog(@"malloc error");
        return self;
    }
    gameArea = ga;
    wolf = w;
    [gameArea addSubview:self.view];
    return self;
}

- (void)selectStrength:(UIPanGestureRecognizer *)gesture
{
    //Effect: move the bar along with user's gesture and change strength of breath accordingly
    CGPoint temp = [gesture locationInView:self.view];
    if (temp.x>=0 && temp.x<= self.view.frame.size.width && 
        temp.y>=breathBarFrameWidth+breathBarTopOffset && temp.y<=self.view.frame.size.height-2*breathBarFrameWidth){
        [filler setFrame:CGRectMake(breathBarFrameWidth,breathBarFrameWidth, 
                                    self.view.frame.size.width - 2*breathBarFrameWidth,
                                    temp.y-2*breathBarFrameWidth)];
        strength = (1-(filler.frame.size.height/(self.view.frame.size.height-2*breathBarFrameWidth)))*maxStrength;
    }
}

#pragma mark - View lifecycle

- (void)loadView
{
    UIImage *breathBarImage = [UIImage imageNamed:breathBarImageName];
    UIImageView *breathBar = [[UIImageView alloc] initWithImage:breathBarImage];
    [breathBar setUserInteractionEnabled:YES];
    breathBar.frame = CGRectMake(wolf.model.origin.x-breathBarImage.size.width-breathBarXOffset, 
                                 wolf.model.origin.y+(wolf.model.height-breathBarImage.size.height), 
                                 breathBarImage.size.width, breathBarImage.size.height);
    self.view = breathBar;
    CGRect fillerFrame = CGRectMake(breathBarFrameWidth,breathBarFrameWidth, 
                                    breathBar.frame.size.width - 2*breathBarFrameWidth,
                                    (breathBar.frame.size.height - 2*breathBarFrameWidth)/2);
    filler = [[RectView alloc] initWithFrame:fillerFrame Color:[UIColor whiteColor]];
    
    strength = (1-(filler.frame.size.height/(self.view.frame.size.height-2*breathBarFrameWidth)))*maxStrength;

    [self.view addSubview:filler];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc]
                                    initWithTarget:self action:@selector(selectStrength:)];
    [self.view addGestureRecognizer:gesture];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
