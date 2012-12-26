#import "GameObject.h"

@implementation GameObject

#define platIconSize 65
#define angleOffset 5   //adjust rotation's clipping object to a whole degree of 0/90/180/270
#define groundY 480

@synthesize model;
@synthesize objectType;

@synthesize palette;
@synthesize gameArea;
@synthesize engine;

@synthesize palette_x;
@synthesize palette_y;
@synthesize palette_size;
@synthesize gameArea_width;
@synthesize gameArea_height;

-(id)initWithPlatte:(UIView *)Pal gameArea:(UIScrollView *)gam engine:(Engine*)eng
{
    self = [super init];
    if(self == nil){
        NSLog(@"malloc error");
        return self;
    }
    palette = Pal;
    gameArea = gam;
    palette_size = platIconSize;
    engine = eng;
    return self;
}

- (id)initWithPlatte:(UIView*)Pal gameArea:(UIScrollView*)gam engine:(Engine*)eng
              dictionary:(NSDictionary*)Dic
{
    self = [super init];
    if(self == nil){
        NSLog(@"malloc error");
        return self;
    }
    palette = Pal;
    gameArea = gam;
    palette_size = platIconSize;
    engine = eng;
    
    CGFloat origin_x = [[Dic valueForKey:@"origin_x"] doubleValue];
    CGFloat origin_y = [[Dic valueForKey:@"origin_y"] doubleValue];
    CGFloat width = [[Dic valueForKey:@"width"] doubleValue];
    CGFloat height = [[Dic valueForKey:@"height"] doubleValue];
    CGFloat rotation = [[Dic valueForKey:@"rotation"] doubleValue];
    CGFloat mass = [[Dic valueForKey:@"mass"] doubleValue];
    CGFloat restitution = [[Dic valueForKey:@"restituion"] doubleValue];
    CGFloat friction = [[Dic valueForKey:@"friction"] doubleValue];
    
    model = [[RectModel alloc] initWithOrigin:CGPointMake(origin_x, origin_y) width:width 
                                height:height mass:mass restitution:restitution friction:friction 
                                collisionType:kDefaultType];
    model.rotation = rotation;
    
    if ([[Dic valueForKey:@"superview"] isEqual:@"pal"])
        [palette addSubview:self.view];
    else{
        [gameArea addSubview:self.view];
        [engine addObject:self.model];
    }
    
    return self;
}

- (NSDictionary*)exportAsDictionary
{
    //Effect: export data with respect to the view controller as a dictionary
    NSString *superview;
    if(self.view.superview == palette)
        superview = @"pal";
    else if(self.view.superview == gameArea)
        superview = @"gam";
    else
        NSLog(@"no superview? omg omg omg omg");
    return  [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:objectType],@"type",
            [NSNumber numberWithFloat: model.origin.x],@"origin_x",
            [NSNumber numberWithFloat: model.origin.y],@"origin_y",
            [NSNumber numberWithFloat: model.width],@"width",
            [NSNumber numberWithFloat: model.height],@"height",
            [NSNumber numberWithFloat: model.rotation],@"rotation",
            [NSNumber numberWithFloat: model.mass],@"mass",
            [NSNumber numberWithFloat: model.restitution],@"restitution",
            [NSNumber numberWithFloat: model.friction],@"friction",
            superview,@"superview",
            nil];
}

-(void)restoreModel
{
    //Effect: re initialise the model
    model = [[RectModel alloc] initWithOrigin:CGPointMake(palette_x, palette_y)width:palette_size 
                                       height:palette_size mass:0 restitution:model.restitution friction:model.friction collisionType:model.colType];
}

-(void) translationFromGamToPal 
{
    //Effect: alter the vc when it is translated from gameare to palette
    [self.view removeFromSuperview];
    [self restoreModel];
    [self.view setTransform:CGAffineTransformIdentity];
    [self.view setFrame:model.boundingBox];
    [palette addSubview:self.view];
    [engine removeObject:model];
}

-(void) translationFromUnderground 
{
    //Effect: if the view is below ground, issue an animation to bring it up
    CGFloat offset = model.boundingBox.origin.y + model.boundingBox.size.height - groundY;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    model.origin = CGPointMake(model.origin.x, model.origin.y-offset);
    [self.view setCenter:model.center];
    [UIView commitAnimations];
}

-(void) regulateGameareaTransformation
{
    //Effect: check if transformation in game area make it no longer reside in gameArea
    //if so, move it above ground or move it back to pallete
    if(model.boundingBox.origin.y < 0 )
        [self translationFromGamToPal];
    else if(model.boundingBox.origin.y + model.boundingBox.size.height > groundY)
        [self translationFromUnderground];
}

-(void)translationFromPalToGam
{
    //Effect: make changes to vc when view is translated from palette to gamearea
    [self.view removeFromSuperview];
    model.origin = CGPointMake(model.origin.x+gameArea.contentOffset.x, model.origin.y-palette.frame.size.height);
    model.width = gameArea_width;
    model.height = gameArea_height;
    [self.view setFrame:model.boundingBox];
    [gameArea addSubview:self.view];
    [self regulateGameareaTransformation];
    [engine addObject:model];
}

-(void) testPointPositions{
    //Effect: function for testng purpose
    UIView *test1 = [[UIView alloc] initWithFrame:CGRectMake(model.center.x - 2.5, model.center.y-2.5, 5, 5)];
    test1.backgroundColor = [UIColor blackColor];
    [gameArea addSubview:test1];
    UIView *test2 = [[UIView alloc] initWithFrame:CGRectMake(model.origin.x - 2.5, model.origin.y-2.5, 5, 5)];
    test2.backgroundColor = [UIColor redColor];
    [gameArea addSubview:test2];
    UIView *test3 = [[UIView alloc] initWithFrame:CGRectMake(model.center.x - 2.5, model.center.y-2.5, 5, 5)];
    test1.backgroundColor = [UIColor blackColor];
    [gameArea addSubview:test3];
    UIView *test4 = [[UIView alloc] initWithFrame:CGRectMake(model.origin.x - 2.5, model.origin.y-2.5, 5, 5)];
    test2.backgroundColor = [UIColor redColor];
    [gameArea addSubview:test4];
}

-(void)translate:(UIPanGestureRecognizer *)gesture
{
    //Effect: handle translation gesture
    [self.view setTransform:CGAffineTransformIdentity];
    CGPoint translation = [gesture translationInView:self.view];
    [model translateX:translation.x Y:translation.y];
    [self.view setCenter:model.center];
    [self.view setTransform:CGAffineTransformMakeRotation(model.rotation * M_PI / 180 )];
    [gesture setTranslation:CGPointMake(0, 0) inView:self.view];
    
    if(gesture.state == UIGestureRecognizerStateEnded){
        //object initially in palette
        if([self.view superview] == palette){
            if(model.origin.y > palette.frame.size.height)
                //object being dragged out of palette
                [self translationFromPalToGam];
            else{
                //object bounces back
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.5];
                [self restoreModel];
                [self.view setFrame:model.boundingBox];
                [UIView commitAnimations];
            }
        }
        //object initally in game area
        else if([self.view superview] == gameArea){
            [self regulateGameareaTransformation];
        }
        else{
            NSLog(@"WTF you no superview wtf you doing?");
        }
    }
}

-(void)trimAndRotate
{
    //Effect: if rotation of an object is close to a multiple of 90 degrees, bring the rotation to that multiple of 90
    CGFloat temp = fabs(model.rotation);
    if((int)temp%90 > 90-angleOffset || (int)temp%90 < angleOffset)
        temp = (int)(temp+45)/90*90;
    if(model.rotation<0)
        temp *= -1;
    model.rotation += (temp - model.rotation);
    [self.view setTransform : CGAffineTransformMakeRotation(model.rotation * M_PI / 180 )];
}

-(void)rotate:(UIRotationGestureRecognizer *)gesture
{
    //Effect: handle rotation gesture
    if([self.view superview] == gameArea){
        model.rotation += gesture.rotation * (180 / M_PI);
        [self.view setTransform : CGAffineTransformMakeRotation(model.rotation * M_PI / 180 )];
        [gesture setRotation:0];
        if(gesture.state == UIGestureRecognizerStateEnded){
            [self trimAndRotate];
            [self regulateGameareaTransformation];
        }
    }
}

-(void)zoom:(UIPinchGestureRecognizer *)gesture
{
    //Effect: handle zoom gesture
    if([self.view superview] == gameArea){
        [self.view setTransform:CGAffineTransformIdentity];
        CGPoint center = model.center;
        model.width *= gesture.scale;
        model.height *= gesture.scale;
        model.origin = CGPointMake(center.x- model.width/2, center.y-model.height/2);
        [self.view setFrame:CGRectMake(model.origin.x, model.origin.y, model.width, model.height)];
        [self.view setTransform:CGAffineTransformMakeRotation(model.rotation * M_PI / 180 )];
        [gesture setScale:1];
        if(gesture.state == UIGestureRecognizerStateEnded)
            [self regulateGameareaTransformation];
    }
}

-(void)doubleTap:(UITapGestureRecognizer *)gesture
{
    //Effect: handle touble tap gesture, move the object back to palette
    if (self.view.superview == gameArea){
        [self translationFromGamToPal];
    }
}

-(void)singleTap:(UITapGestureRecognizer *)gesture
{
    //to be implemented by subclasses
    return;
}

-(void) animatedSelfDestruct
{
    NSLog(@"has to be implemented by child class if child will disappear");
}

-(void)reloadView
{
    //Effect: reload its view, if it should disappear, call the disappear function
    [self.view setCenter:model.center];
    [self.view setTransform : CGAffineTransformMakeRotation(model.rotation * M_PI / 180 )];
    if(model.disappear)
        [self animatedSelfDestruct];
}

#pragma mark - View lifecycle

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];; 
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
   return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
