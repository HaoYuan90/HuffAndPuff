//code quality checked

#import <Foundation/Foundation.h>
#import "Vector2D.h"

@protocol GameWolfDelegate <NSObject>

//Effect: return velocity of projectile
- (Vector2D*) projectileVelocity;
//Effect: fired after projectile is lauched by wolf
- (void) didLaunchProjectile;

@end
