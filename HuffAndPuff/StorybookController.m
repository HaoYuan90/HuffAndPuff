#import "StorybookController.h"

@implementation StorybookController

#define saveActionSheetTitle (@"SAVE TO")
#define loadActionSheetTitle (@"LOAD FROM")
#define storybookSavePrefix (@"StorybookFrame")
#define frameNumber 6

#define descEditFrame (CGRectMake(400, 46, 644, 76))
#define descPlayFrame (CGRectMake(0, 44, 1024, 80))

@synthesize currentFrame;

@synthesize gameArea;
@synthesize palette;
@synthesize desc;

@synthesize saveButton;
@synthesize loadButton;
@synthesize resetButton;
@synthesize playButton;
@synthesize nextButton;
@synthesize prevButton;
//storyobjectcontrollers stored in self.childviewcontrollers

- (IBAction)back
{
    //Effect: return to main menu
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save
{
    //Effect: call up save action sheet
    UIActionSheet *saveSheet = [[UIActionSheet alloc] initWithTitle:saveActionSheetTitle delegate:self 
                                cancelButtonTitle:nil destructiveButtonTitle:nil 
                                otherButtonTitles:@"Frame 1",@"Frame 2",@"Frame 3",@"Frame 4",
                                @"Frame 5",@"Frame 6",nil];
    saveSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    [saveSheet showFromBarButtonItem:saveButton animated:YES];
}

- (IBAction)load
{
    //Effect: call up load action sheet
    UIActionSheet *loadSheet = [[UIActionSheet alloc] initWithTitle:loadActionSheetTitle delegate:self 
                                cancelButtonTitle:nil destructiveButtonTitle:nil 
                                otherButtonTitles:@"Frame 1",@"Frame 2",@"Frame 3",@"Frame 4",
                                @"Frame 5",@"Frame 6", nil];
    loadSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    [loadSheet showFromBarButtonItem:loadButton animated:YES];
}

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
    //Effect: clear all contents in game area and palette
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
    //Effect: init the objects to be placed in palette
    [self addChildViewController:[[StoryWolf alloc] initWithPlatte:palette 
                                                          gameArea:gameArea]];
    [self addChildViewController:[[StoryPig alloc] initWithPlatte:palette 
                                                         gameArea:gameArea]];
    [self addChildViewController:[[StoryBlock alloc] initWithPlatte:palette 
                                                           gameArea:gameArea]];
    [self addChildViewController:[[StoryBreath alloc] initWithPlatte:palette 
                                                           gameArea:gameArea]];
    [self addChildViewController:[[StoryCloud alloc] initWithPlatte:palette 
                                                            gameArea:gameArea]];
}

- (void) saveToFile:(NSString*)name
{
    //REQUIRES: name is one of StorybookFrame1-6
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
    NSString *description = desc.text;
    [data addObject:description];
    for(StoryObject *temp in self.childViewControllers)
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
    //REQUIRES: name is one of name is one of StorybookFrame1-6
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
    
    NSArray *data = [[NSArray alloc] initWithContentsOfFile:path];
    
    if(data.count >=1){
        NSString *description = [data objectAtIndex:0];
        [desc setText:description];
        for(int i=1; i<data.count;i++){
            NSDictionary *temp = [data objectAtIndex:i];
            if([[temp valueForKey:@"type"] intValue] == StoryObjectPig)
                [self addChildViewController:[[StoryPig alloc] initWithPlatte:palette 
                                                                gameArea:gameArea dictionary:temp]];
            else if([[temp valueForKey:@"type"] intValue] == StoryObjectWolf)
                [self addChildViewController:[[StoryWolf alloc] initWithPlatte:palette 
                                                                gameArea:gameArea dictionary:temp]];
            else if([[temp valueForKey:@"type"] intValue] == StoryObjectBlock)
                [self addChildViewController:[[StoryBlock alloc] initWithPlatte:palette 
                                                                gameArea:gameArea dictionary:temp]];
            else if([[temp valueForKey:@"type"] intValue] == StoryObjectBreath)
                [self addChildViewController:[[StoryBreath alloc] initWithPlatte:palette 
                                                                gameArea:gameArea dictionary:temp]];
            else if([[temp valueForKey:@"type"] intValue] == StoryObjectCloud)
                [self addChildViewController:[[StoryCloud alloc] initWithPlatte:palette 
                                                                        gameArea:gameArea dictionary:temp]];
            else
                NSLog(@"object saved has no type");
        }
    }
    else
        [desc setText:@""];
}

- (IBAction)reset
{
    //Effect: start a new instance of builder
    [self loadEmptyGame];
    [self loadPalette];
    [desc setText:@""];
}

- (void) disableInteractions
{
    for(StoryObject *temp in self.childViewControllers)
        temp.view.userInteractionEnabled = NO;
}
- (void) enableInteractions
{
    for(StoryObject *temp in self.childViewControllers)
        temp.view.userInteractionEnabled = YES;
}

- (void) setUIPlayStyle
{
    //Effect: change ui element style for playing.
    prevButton.enabled = NO;
    nextButton.enabled = YES;
    saveButton.enabled = NO;
    loadButton.enabled = NO;
    resetButton.enabled = NO;
    [playButton setTitle:@"Stop"];
    
    [desc setFrame:descPlayFrame];
    [desc setEditable:NO];
    [desc setBackgroundColor:palette.backgroundColor];
    [desc setEditable:NO];
    [desc setFont:[UIFont fontWithName:@"Chalkboard SE" size:20]];
    desc.textColor = [UIColor purpleColor];
    desc.textAlignment = UITextAlignmentCenter;
    
    [self disableInteractions];
}

- (void) setUIEditStyle
{
    //Effect: change ui element style for editing.
    prevButton.enabled = NO;
    nextButton.enabled = NO;
    saveButton.enabled = YES;
    loadButton.enabled = YES;
    resetButton.enabled = YES;
    [playButton setTitle:@"Play"];
    
    [desc setFrame:descEditFrame];
    [desc setEditable:YES];
    [desc setBackgroundColor:[UIColor whiteColor]];
    [desc setEditable:YES];
    [desc setFont:[UIFont fontWithName:@"Chalkboard SE" size:14]];
    desc.textColor = [UIColor blackColor];
    desc.textAlignment = UITextAlignmentLeft;
    
    [self enableInteractions];
}

- (IBAction)playAndStop
{
    //Effect: toggle between play mode and edit mode
    if([playButton.title isEqualToString:@"Play"]){
        currentFrame = 1;
        NSString *fileName = [NSString stringWithFormat:@"%@%d",storybookSavePrefix,currentFrame];
        [self loadFromFile:fileName];
        //make change to components
        [self setUIPlayStyle];
    }
    else if([playButton.title isEqualToString:@"Stop"]){
        currentFrame = 1;
        [self setUIEditStyle];
    }
    else
        NSLog(@"playbutton error");
}

- (IBAction)next
{
    //Effect: display next frame saved
    prevButton.enabled = YES;
    currentFrame ++;
    if(currentFrame == frameNumber)
        nextButton.enabled = NO;
    NSString *fileName = [NSString stringWithFormat:@"%@%d",storybookSavePrefix,currentFrame];
    [self loadFromFile:fileName];
}

- (IBAction)prev
{
    //Effect: display previous frame saved
    nextButton.enabled = YES;
    currentFrame --;
    if(currentFrame == 1)
        prevButton.enabled = NO;
    NSString *fileName = [NSString stringWithFormat:@"%@%d",storybookSavePrefix,currentFrame];
    [self loadFromFile:fileName];
}

#pragma mark - Actionsheet handling

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex < 0){
        saveButton.enabled = YES;
        loadButton.enabled = YES;
        return;
    }
    NSString *fileName = [NSString stringWithFormat:@"%@%d",storybookSavePrefix,buttonIndex+1];
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
    [super viewDidLoad];
    [self loadGameArea];
    [self loadPalette];
    nextButton.enabled = NO;
    prevButton.enabled = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setGameArea:nil];
    [self setPalette:nil];
    [self setDesc:nil];
    
    [self setSaveButton:nil];
    [self setLoadButton:nil];
    [self setResetButton:nil];
    [self setPlayButton:nil];
    [self setNextButton:nil];
    [self setPrevButton:nil];
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
