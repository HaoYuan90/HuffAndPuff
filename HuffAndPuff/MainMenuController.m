#import "MainMenuController.h"

@implementation MainMenuController

@synthesize backGround;

#define storyboardName (@"MainStoryboard")
#define levelBuiderIdentifier (@"LevelBuilderController")
#define storybookIdentifier (@"StorybookController")
#define gameIdentifier (@"GameController")

#define backGroundImageName (@"background.png")
#define groundImageName (@"ground.png")
#define wolfImageName (@"wolfs.png") 
#define pigImageName (@"pig.png")
#define wolfSpriteWidth 225
#define wolfSpriteHeight 150
#define wolfPositionX 0
#define wolfPositionY 370
#define wolfWidth 450
#define wolfHeight 300
#define pigPositionX 550
#define pigPositionY 576
#define pigWidth 90
#define pigHeight 90

- (IBAction)loadGame
{
    //Effect: load GameController
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    GameController *GC = [storyboard instantiateViewControllerWithIdentifier:gameIdentifier];
    [self presentViewController:GC animated:YES completion:^(void){
    }];
}
- (IBAction)loadLevelBuilder
{
    //Effect: load LevelBuilderController
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    LevelBuilderController *LBC = [storyboard instantiateViewControllerWithIdentifier:levelBuiderIdentifier];
    [self presentViewController:LBC animated:YES completion:^(void){
    }];
}
- (IBAction)loadStorybook
{
    //Effect: load StorybookController
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    StorybookController *SBC = [storyboard instantiateViewControllerWithIdentifier:storybookIdentifier];
    [self presentViewController:SBC animated:YES completion:^(void){
    }];
}

- (void)loadBackground
{
    //Effect: load background of menu page
    //load forest and ground
    UIImage *bgImage = [UIImage imageNamed:backGroundImageName];
    UIImage *groundImage = [UIImage imageNamed:groundImageName];
    CGFloat groundWidth = groundImage.size.width;
    CGFloat groundHeight = groundImage.size.height;
    UIImageView *background = [[UIImageView alloc] initWithImage:bgImage];
    UIImageView *ground = [[UIImageView alloc] initWithImage:groundImage];
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    background.frame = CGRectMake(0, 0, screenHeight, screenWidth);
    ground.frame = CGRectMake(0, screenWidth-groundHeight, groundWidth, groundHeight);
    [backGround addSubview:background];
    [backGround addSubview:ground];
    //load wolf
    UIImage *wolfsImage = [UIImage imageNamed:wolfImageName];
    CGImageRef temp = CGImageCreateWithImageInRect([wolfsImage CGImage], 
                                                   CGRectMake(0, 0, wolfSpriteWidth, wolfSpriteHeight));
    UIImage *wolfImage = [UIImage imageWithCGImage:temp];
    UIImageView *wolf = [[UIImageView alloc] initWithImage:wolfImage];
    wolf.frame = CGRectMake(wolfPositionX, wolfPositionY, wolfWidth, wolfHeight);
    [backGround addSubview:wolf];
    //load pigs
    UIImage *pigImage = [UIImage imageNamed:pigImageName];
    UIImageView *pig1 = [[UIImageView alloc] initWithImage:pigImage];
    UIImageView *pig2 = [[UIImageView alloc] initWithImage:pigImage];
    UIImageView *pig3 = [[UIImageView alloc] initWithImage:pigImage];
    pig1.frame = CGRectMake(pigPositionX, pigPositionY, pigWidth, pigHeight);
    pig2.frame = CGRectMake(pigPositionX+pigWidth, pigPositionY, pigWidth, pigHeight);
    pig3.frame = CGRectMake(pigPositionX+pigWidth+pigWidth, pigPositionY, pigWidth, pigHeight);
    [backGround addSubview:pig1];
    [backGround addSubview:pig2];
    [backGround addSubview:pig3];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadBackground];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    backGround = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
