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

@interface GameController : UIViewController <EngineDelegate,GameWolfDelegate>{
    Engine* engine;
}

- (IBAction)back;
- (IBAction)next;
- (IBAction)restart;

@property (weak, nonatomic) IBOutlet UIScrollView *gameArea;
@property (weak, nonatomic) IBOutlet UIView *palette;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *levelLabel;

@property (nonatomic, readonly) int life;

@property (nonatomic, retain) Engine* engine;
@property (nonatomic, retain) NSTimer *timer;

@property (nonatomic, readonly, retain) AngleSelection* angleSelection;
@property (nonatomic, readonly, retain) BreathBar* breathBar;

@end
