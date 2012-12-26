//code quality checked
#import <Foundation/Foundation.h>

@protocol EngineDelegate <NSObject>

//method that renders a point on screen for testing purpose
- (void) showPt:(CGPoint) pt;
//method that updates all the physical objects' views for a "tick"
- (void) update ;

@end
