#import "LevelBuilderController.h"

@implementation LevelBuilderController

#define randomInterval 0.04
#define saveActionSheetTitle (@"SAVE TO")
#define loadActionSheetTitle (@"LOAD FROM")
#define customSavePrefix (@"customLevel")

@synthesize engine;
@synthesize gameArea;
@synthesize palette;
@synthesize startButton;
@synthesize resetButton;
@synthesize saveButton;
@synthesize loadButton;

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

- (void)loadPalette
{
    //Effect: init elements in the palette
    [self addChildViewController:[[GameWolf alloc] initWithPlatte:palette 
                                                                  gameArea:gameArea engine:engine delegate:self]];
    [self addChildViewController:[[GamePig alloc] initWithPlatte:palette 
                                                                  gameArea:gameArea engine:engine]];
    [self addChildViewController:[[GameBlock alloc] initWithPlatte:palette 
                                                                  gameArea:gameArea engine:engine]];
}

- (IBAction)back
{
    //Effect: return to main menu
    [timer invalidate];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save
{
    //Effect: show save actionsheet
    UIActionSheet *saveSheet = [[UIActionSheet alloc] initWithTitle:saveActionSheetTitle delegate:self 
                                                  cancelButtonTitle:nil destructiveButtonTitle:nil 
                                                  otherButtonTitles:@"Slot 1",@"Slot 2",@"Slot 3",@"Slot 4", nil];
    saveSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    [saveSheet showFromBarButtonItem:saveButton animated:YES];
}

- (IBAction)load
{
    //Effect: show load actionsheet
    UIActionSheet *loadSheet = [[UIActionSheet alloc] initWithTitle:loadActionSheetTitle delegate:self 
                                                  cancelButtonTitle:nil destructiveButtonTitle:nil 
                                                  otherButtonTitles:@"Slot 1",@"Slot 2",@"Slot 3",@"Slot 4", nil];
    loadSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    [loadSheet showFromBarButtonItem:loadButton animated:YES];
    
    startButton.enabled = YES;
}

- (IBAction)resetAndStop:(id)sender
{
    //Effect: button action of Reset/Stop button
    UIBarButtonItem *temp = sender;
    if([temp.title isEqualToString:@"Reset"]){
        engine = [[Engine alloc] initWithDelegate:self];
        [self loadEmptyGame];
        [self loadPalette];
        //enable button
        startButton.enabled = YES;
    }
    else if([temp.title isEqualToString:@"Stop"]){
        [timer invalidate];
        timer = nil;
        [resetButton setTitle:@"Reset"];
    }
    else
        NSLog(@"reset title bugged");
}

- (void) setUpSelection:(GameWolf*) wolf
{
    //Effect: set up the interface for projectile launching
    angleSelection = [[AngleSelection alloc] initWithGameArea:gameArea wolf:wolf];
    breathBar = [[BreathBar alloc] initWithGameArea:gameArea wolf:wolf];
}

-(void)timerStart
{
    //Effect: run the engine loop in another thread
    NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:engine selector:@selector(timeStepping)];
    [link addToRunLoop:runLoop forMode:NSRunLoopCommonModes];/*
    timer = [NSTimer scheduledTimerWithTimeInterval:randomInterval target:engine selector:@selector(timeStepping) userInfo:nil repeats:YES];*/
    [runLoop run];
}

- (IBAction)start
{
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
    //show no wolf alert
    if(hasWolf == NO){
        UIAlertView *noWolfAlert = [[UIAlertView alloc] initWithTitle:@"where is da wolf?" 
                                                              message:@"there should be a wolf in game area"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [noWolfAlert show];
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
    //set up angle selection interface and change button states
    [self setUpSelection:wolf];
    startButton.enabled = NO;
    [resetButton setTitle:@"Stop"];
    //fire timer
    [self performSelectorInBackground:@selector(timerStart) withObject:nil];
}

#pragma mark - engineDelegate methods

- (void) update
{
    for(id temp in self.childViewControllers){
        if([temp respondsToSelector:@selector(reloadView)])
            [temp reloadView];
    }
}

- (void) showPt:(CGPoint) pt
{
    //REQUIRES: accelerometer cannot be used for this to work
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
    //Effect: return the data needed for projectile launching
    return [[angleSelection directionVector] multiply:breathBar.strength];
}

- (void) didLaunchProjectile
{
    //Effect: called after projectile is launched
    NSLog(@"projectile launched");
}

#pragma mark - Actionsheet handling
- (void) saveToFile:(NSString*)name
{
    //REQUIRES: name is one of customLevel1-4
    //EFFECTS: save data into the file name specified
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
    //save
    NSMutableArray* data = [NSMutableArray array];
    
    for(GameObject *temp in self.childViewControllers)
        [data addObject:[temp exportAsDictionary]];
    [data writeToFile:path atomically:YES];
    
    NSString *alertMsg = [NSString stringWithFormat:@"successfully saved to %@", name];
    UIAlertView *saveSuccessAlert = [[UIAlertView alloc] initWithTitle:@"Save Finished" 
                                                          message:alertMsg
                                                         delegate:nil
                                                cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [saveSuccessAlert show];
}

- (void) loadFromFile:(NSString*)name
{ 
    //REQUIRES: name is one of customLevel1-4
    //EFFECTS: load data from the file name specified and put them into a brand new engine
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
    //clear existing objects
    [self loadEmptyGame];
    [timer invalidate];
    [resetButton setTitle:@"Reset"];
    engine = [[Engine alloc] initWithDelegate:self];
    
    NSArray *data = [[NSArray alloc] initWithContentsOfFile:path];
    
    for(NSDictionary *temp in data){
        //deduce type
        if([[temp valueForKey:@"type"] intValue] == kGameObjectPig)
            [self addChildViewController:[[GamePig alloc] initWithPlatte:palette 
                                                                gameArea:gameArea 
                                                                  engine:engine dictionary:temp]];
        else if([[temp valueForKey:@"type"] intValue] == kGameObjectWolf)
            [self addChildViewController:[[GameWolf alloc] initWithPlatte:palette 
                                                                 gameArea:gameArea 
                                                                   engine:engine dictionary:temp delegate:self]];
        else if([[temp valueForKey:@"type"] intValue] == kGameObjectBlock)
            [self addChildViewController:[[GameBlock alloc] initWithPlatte:palette 
                                                                  gameArea:gameArea 
                                                                    engine:engine dictionary:temp]];
        else
            NSLog(@"object saved has no type");
    }
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Effect: invoke actionsheet button action
    if(buttonIndex < 0){
        saveButton.enabled = YES;
        loadButton.enabled = YES;
    }
    NSString *fileName = [NSString stringWithFormat:@"%@%d",customSavePrefix,buttonIndex+1];
    if (saveButton.enabled == NO){
        [self saveToFile:fileName];
        saveButton.enabled = YES;
    }
    else if(loadButton.enabled == NO){
        [self loadFromFile:fileName];
        loadButton.enabled = YES;
    }
    else
        NSLog(@"action sheet button error");
}

- (void) willPresentActionSheet:(UIActionSheet *)actionSheet
{
    //Effect: present save/load actionsheet and make corresponding change to UI
    if ([actionSheet.title isEqualToString:saveActionSheetTitle])
        saveButton.enabled = NO;
    else if([actionSheet.title isEqualToString:loadActionSheetTitle])
        loadButton.enabled = NO;
    else
        NSLog(@"action sheet loading error");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    engine = [[Engine alloc] initWithDelegate:self];
    [super viewDidLoad];
    [self loadGameArea];
    [self loadPalette];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setGameArea:nil];
    [self setPalette:nil];
    [self setStartButton:nil];
    [self setResetButton:nil];
    [self setSaveButton:nil];
    [self setLoadButton:nil];
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
