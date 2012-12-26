//code quality checked

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GamePig.h"
#import "GameWolf.h"
#import "GameBlock.h"
#import "GameBreath.h"
#import "AngleSelection.h"
#import "BreathBar.h"
#import "Engine.h"
#import "EngineDelegate.h"
#import "GameWolfDelegate.h"

@interface LevelBuilderController : UIViewController <UIActionSheetDelegate,EngineDelegate,GameWolfDelegate>{
    Engine* engine;
}

- (IBAction)back;
- (IBAction)save;
- (IBAction)load;
- (IBAction)resetAndStop:(id)sender;
- (IBAction)start;

@property (weak, nonatomic) IBOutlet UIScrollView *gameArea;
@property (weak, nonatomic) IBOutlet UIView *palette;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *startButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *resetButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *loadButton;

@property (nonatomic, retain) Engine* engine;
@property (nonatomic, retain) NSTimer *timer;

@property (nonatomic, readonly, retain) AngleSelection* angleSelection;
@property (nonatomic, readonly, retain) BreathBar* breathBar;

@end
