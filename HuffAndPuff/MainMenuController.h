//code quality checked

#import <UIKit/UIKit.h>
#import "LevelBuilderController.h"
#import "StorybookController.h"
#import "GameController.h"

@interface MainMenuController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *backGround;

- (IBAction)loadGame;
- (IBAction)loadLevelBuilder;
- (IBAction)loadStorybook;

@end
