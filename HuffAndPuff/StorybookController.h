//code quality checked

#import <UIKit/UIKit.h>
#import "StoryPig.h"
#import "StoryWolf.h"
#import "StoryBlock.h"
#import "StoryBreath.h"
#import "StoryCloud.h"

@interface StorybookController : UIViewController <UIActionSheetDelegate>{
}

- (IBAction)back;
- (IBAction)save;
- (IBAction)load;
- (IBAction)reset;
- (IBAction)playAndStop;
- (IBAction)next;
- (IBAction)prev;

@property (weak, nonatomic) IBOutlet UIScrollView *gameArea;
@property (weak, nonatomic) IBOutlet UIView *palette;
@property (weak, nonatomic) IBOutlet UITextView *desc;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *loadButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *resetButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *prevButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *playButton;

@property (nonatomic, readonly) int currentFrame;

@end
