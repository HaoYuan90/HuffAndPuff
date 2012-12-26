//code quality checked

#import <Foundation/Foundation.h>
#import "RectModel.h"
#import "CircleModel.h"
#import "Ground.h"
#import "Vector2D.h"
#import "Matrix2D.h"
#import "EngineDelegate.h"

@interface Engine : NSObject <UIAccelerometerDelegate> {
    NSMutableArray *objects;
    Ground *ground;
}

@property (nonatomic, readonly, retain) NSMutableArray* objects;
@property (nonatomic, readonly, retain) Ground* ground;
@property (nonatomic, readonly, retain) Vector2D* gravity;
@property (nonatomic, readonly, strong) id<EngineDelegate> delegate;

- (id) initWithDelegate: (id<EngineDelegate>)del;

- (void) addObject: (ObjectModel*)object;
- (void) removeObject:(ObjectModel*)object;

- (void) timeStepping;

@end
