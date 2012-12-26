#import "GameController.h"

@implementation GameController

#define randomInterval 0.02
#define levelNumber 4

#define heartImageName (@"heart.png")
#define heartWidth 36
#define heartHeight 31
#define heartXOffset 20
#define heartYOffset 30
#define heartInterval 10

@synthesize engine;
@synthesize gameArea;
@synthesize palette;
@synthesize nextButton;
@synthesize levelLabel;

@synthesize life;

@synthesize angleSelection;
@synthesize breathBar;

@synthesize timer;
//gameobjectcontrollers stored in self.childviewcontrollers

- (void)loadGameArea
{
    //Effect: load gamearea's background
    UIImage *bgImage = [UIImage imageNamed:@"background.png"];
    UIImage *groundImage = [UIImage imageNamed:@"ground.png"];
    CGFloat backgroundWidth = bgImage.size.width;
    CGFloat backgroundHeight = bgImage.size.height;
    CGFloat groundWidth = groundImage.size.width;
    CGFloat groundHeight = groundImage.size.height;
    //total height is 580
    UIImageView *background = [[UIImageView alloc] initWithImage:bgImage];
    UIImageView *ground = [[UIImageView alloc] initWithImage:groundImage];
    CGFloat groundY = gameArea.frame.size.height - groundHeight;
    CGFloat backgroundY = groundY - backgroundHeight;
    background.frame = CGRectMake(0, backgroundY, backgroundWidth, backgroundHeight);
    ground.frame = CGRectMake(0, groundY, groundWidth, groundHeight);
    [gameArea addSubview:background];
    [gameArea addSubview:ground];
    CGFloat gameareaHeight = backgroundHeight + groundHeight;
    CGFloat gameareaWidth = backgroundWidth;
    [gameArea setContentSize:CGSizeMake(gameareaWidth, gameareaHeight)];
}

- (void)loadEmptyGame
{
    //Effect: load the level builder as if it is fresh
    while ([palette.subviews count]!=0)
        [[palette.subviews objectAtIndex:0] removeFromSuperview];
    while ([gameArea.subviews count]!=0)
        [[gameArea.subviews objectAtIndex:0] removeFromSuperview];
    while ([self.childViewControllers count] != 0)
        [[self.childViewControllers objectAtIndex:0] removeFromParentViewController];
    [self loadGameArea];
}

- (void) loadFromFile:(NSString*)name
{ 
    //REQUIRES: name is one of prefix "Level" , ensured by caller
    //EFFECTS: load data from the file name specified and load into the game
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString *documentsDirectory = [paths objectAtIndex:0]; 
    NSString *fileName = [name stringByAppendingString:@".plist"];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName]; 
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: path]) 
    {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:name ofType:@"plist"]; 
        [fileManager copyItemAtPath:bundle toPath: path error:&error];
    }
    
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:path];
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];
    if (!temp)
        NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
    
    NSDictionary *info = [temp objectForKey:@"info"];
    life = [[info objectForKey:@"life"] intValue];
    
    int i=1;
    while (YES) {
        NSDictionary *obj = [temp objectForKey:[NSString stringWithFormat:@"%d",i]];
        if(obj){
            if([[obj valueForKey:@"type"] intValue] == kGameObjectPig)
                [self addChildViewController:[[GamePig alloc] initWithPlatte:palette 
                                                                    gameArea:gameArea 
                                                                      engine:engine dictionary:obj]];
            else if([[obj valueForKey:@"type"] intValue] == kGameObjectWolf)
                [self addChildViewController:[[GameWolf alloc] initWithPlatte:palette 
                                                                     gameArea:gameArea 
                                                                       engine:engine dictionary:obj delegate:self]];
            else if([[obj valueForKey:@"type"] intValue] == kGameObjectBlock)
                [self addChildViewController:[[GameBlock alloc] initWithPlatte:palette 
                                                                      gameArea:gameArea 
                                                                        engine:engine dictionary:obj]];
            else
                NSLog(@"object saved has no type");
            i++;
        }
        else
            break;
    }    
}

- (void)loadLife
{
    //Effect: load hearts in palette
    UIImage *heartImage = [UIImage imageNamed:heartImageName];
    CGFloat heartX = heartXOffset-heartInterval-heartWidth;
    for(int i=0;i<life;i++){
        heartX += heartInterval+heartWidth;
        UIImageView *heart = [[UIImageView alloc] initWithImage:heartImage];
        heart.frame = CGRectMake(heartX, heartYOffset, heartWidth, heartHeight);
        [palette addSubview:heart];
    }
}

- (void) setUpSelection:(GameWolf*) wolf
{
    //Effect: set up the interface for projectile launching
    angleSelection = [[AngleSelection alloc] initWithGameArea:gameArea wolf:wolf];
    breathBar = [[BreathBar alloc] initWithGameArea:gameArea wolf:wolf];
}

- (void)start
{
    //Effect: start game
    BOOL hasWolf = NO;
    GameWolf *wolf;
    //check for wolf
    for (GameObject *temp in [self childViewControllers]){
        if([temp isKindOfClass:[GameWolf class]]){
            GameWolf *stub = (GameWolf*)temp;
            if([stub.view superview] == gameArea){
                [engine removeObject:stub.model];
                hasWolf = YES;
                wolf = stub; 
            }
        }
    }
    //if level contains no wolf which will never happen...
    if(hasWolf == NO){
        NSLog(@"your level has no wolf");
        return;
    }
    //disable all gestures
    for (GameObject *temp in [self childViewControllers]){
        [temp.view setUserInteractionEnabled:NO];
    }
    //add gesture to allow wolf to fire projectiles.
    for(UIGestureRecognizer *temp in wolf.view.gestureRecognizers)
        [wolf.view removeGestureRecognizer:temp];
    [wolf.view setUserInteractionEnabled:YES];
    UITapGestureRecognizer *singleTapping = [[UITapGestureRecognizer alloc]
                                             initWithTarget:wolf action:@selector(launchProjectile)];
    singleTapping.numberOfTapsRequired = 1;
    [wolf.view addGestureRecognizer:singleTapping];
    //set up angle selection interface
    [self setUpSelection:wolf];
    //fire timer
    [self performSelectorInBackground:@selector(timerStart) withObject:nil];
}

- (void)loadLevel
{
    //Effect: load level as specified by LevelLabel at the btm of the screen
    nextButton.enabled = NO;
    [timer invalidate];
    [self loadEmptyGame];
    engine = [[Engine alloc] initWithDelegate:self];
    [self loadFromFile:levelLabel.title];
    [self loadLife];
    [self start];
}

- (IBAction)back
{
    //Effect: return to main menu
    [timer invalidate];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)next
{
    //Effect: load the next level
    NSString *temp = [levelLabel.title substringToIndex:5];
    int currentLevel = [[levelLabel.title substringFromIndex:5] intValue];
    currentLevel++;
    if(currentLevel == levelNumber+1){
        UIAlertView *noLevelAlert = [[UIAlertView alloc] initWithTitle:@"thats it" 
                                                              message:@"we have only 4 levels :D"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [noLevelAlert show];
        return;
    }
    [levelLabel setTitle:[NSString stringWithFormat:@"%@%d",temp,currentLevel]];
    [self loadLevel];
}

- (IBAction)restart
{
    [self loadLevel];
}

-(void)timerStart
{
    //Effect: run the engine loop in another thread
    
    NSRunLoop* runLoop = [NSRunLoop currentRunLoop];/*
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:engine selector:@selector(timeStepping)];
    [link addToRunLoop:runLoop forMode:NSRunLoopCommonModes];*/
    
    timer = [NSTimer scheduledTimerWithTimeInterval:randomInterval target:engine selector:@selector(timeStepping) userInfo:nil repeats:YES];
    [runLoop run];
}

#pragma mark - engineDelegate methods

- (void) update
{
    //Effect: update the graphics for one stepping and determine if the game is won
    BOOL pigLives = NO;
    for(id temp in self.childViewControllers){
        if([temp respondsToSelector:@selector(reloadView)])
            [temp reloadView];
        if ([temp isKindOfClass:[GamePig class]]) 
            pigLives = YES;
    }
    if (!pigLives){
        nextButton.enabled = YES;
        UIAlertView *winAlert = [[UIAlertView alloc] initWithTitle:@"you won" 
                                                               message:@"move to next level"
                                                              delegate:nil
                                                     cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [winAlert show];
        [timer invalidate];
        return;
    }
}

- (void) showPt:(CGPoint) pt
{
    //REQUIRES: accelerometer cannot be used for this to work
    //Effect: draw a point in game area
    UIView *square = [[UIView alloc] initWithFrame:CGRectMake(pt.x-5, pt.y-5, 10, 10)];
    square.backgroundColor = [UIColor blackColor];
    [gameArea addSubview: square];
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{square.alpha = 0;}
                     completion:^(BOOL finished) {[square removeFromSuperview];}];
}

#pragma mark - wolfDelegate methods

- (Vector2D*) projectileVelocity
{
    //Effect: return the data needed for launching of projectile
    return [[angleSelection directionVector] multiply:breathBar.strength];
}

- (void) didLaunchProjectile
{
    //Effect: reduce life and if life is depleted, make wolf die
    [[palette.subviews lastObject] removeFromSuperview];
    if([palette.subviews count] == 0){
        GameWolf *wolf;
        for (GameObject *temp in [self childViewControllers]){
            if([temp isKindOfClass:[GameWolf class]]){
                wolf = (GameWolf*)temp; 
                break;
            }
        }
        [wolf die];
        [angleSelection.view removeFromSuperview];
        [breathBar.view removeFromSuperview];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadLevel];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setGameArea:nil];
    [self setPalette:nil];
    [self setNextButton:nil];
    [self setLevelLabel:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

@end