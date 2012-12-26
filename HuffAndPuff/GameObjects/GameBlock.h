//code quality checked

#import "GameObject.h"

typedef enum {
    kBlockStraw, 
    kBlockWood, 
    kBlockIron,
    kBlockStone,
} BlockType;

@interface GameBlock : GameObject

@property (nonatomic, readonly) BlockType blockType;

@end
