#import "RectView.h"

@implementation RectView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self == nil) {
        NSLog(@"malloc error");
        return self;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame Color:(UIColor*)c
{
    self = [self initWithFrame:frame];
    //nil check is done in[self initWithFrame]
    self.backgroundColor = c;
    return self;
}

@end
