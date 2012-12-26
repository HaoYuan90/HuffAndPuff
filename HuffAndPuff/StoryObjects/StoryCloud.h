//code quality checked

#import "StoryObject.h"

typedef enum{
    cloudType1,
    cloudType2,
    cloudType3
} StoryCloudType;

@interface StoryCloud : StoryObject

@property (nonatomic, readonly) StoryCloudType cloudType;

@end
