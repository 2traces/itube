//
//  GlViewController.m
//  test
//
//  Created by Vasiliy Makarov on 22.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GlViewController.h"
#import "RasterLayer.h"
#import "SettingsNavController.h"
#import "tubeAppDelegate.h"
#import "SelectingTabBarViewController.h"
#import "GlView.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    //UNIFORM_NORMAL_MATRIX,
    UNIFORM_SAMPLER,
    UNIFORM_COLOR,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

static CGPoint userGeoPosition;

CGFloat calcGeoDistanceFrom(CGPoint p1, CGPoint p2)
{
    static const float cc = M_PI / 180.f;
    float dis = 6371.21f * acosf(sinf(p1.x*cc)*sinf(p2.x*cc) + cosf(p1.x*cc)*cosf(p2.x*cc)*cosf(p1.y*cc+p2.y*cc));
    return dis;
}

CGPoint translateFromGeoToMap(CGPoint pm)
{
    const static double mult = 256.0 / 360.0;
    float y = atanhf(sinf(pm.x * M_PI / 180.f));
    y = y * 256.f / (M_PI*2.f);
    CGPoint p;
    p.x = 128.f + pm.y * mult;
    p.y = 128.f - y;
    return p;
}


@interface GlViewController () {
    GLuint _program;
    
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    //float _rotation;
    
    RasterLayer *rasterLayer;
    CGPoint position, prevPosition, targetPosition;
    CGFloat scale, prevScale, targetScale, targetTimer;
    UIButton *sourceData, *settings, *zones, *cornerButton;
    
    MItem *currentSelection;
    MItem *fromStation;
    MItem *toStation;
    TopRasterView *stationsView;
    
    CGPoint panVelocity;
    CGFloat panTime;
    NSMutableArray *pinsArray;
    int newPinId;
    
    CGPoint userPosition;
}
@property (strong, nonatomic) EAGLContext *context;
//@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;

-(void)drawPins;
@end

@implementation Pin
@synthesize Id = _id;
@synthesize distanceToUser;
@synthesize type;

-(void)setActive:(BOOL)active
{
    if(active) {
        [sp show];
    } else {
        [sp hide];
    }
}

-(BOOL)active
{
    return !sp.closed;
}

-(id)initUserPos
{
    type = PIN_USER;
    size = 1.f;
    if((self = [super init])) {
        _id = 0;
        sprite = [[GlSprite alloc] initWithPicture:@"current_location"];
        sp = [[SmallPanel alloc] initWithText:@"You are here!"];
    }
    return self;
}

-(id)initLocationPos
{
    type = PIN_LOCATION;
    size = 0.5f;
    if((self = [super init])) {
        _id = -1;
        sprite = [[GlSprite alloc] initWithPicture:@"station_mark"];
        sp = [[SmallPanel alloc] initWithText:@"You are gonna be there!"];
    }
    return self;
}

-(id)initWithId:(int)pinId andColor:(int)color
{
    return [self initWithId:pinId color:color andText:@"Hello!"];
}

-(id) initWithId:(int)pinId color:(int)color andText:(NSString*)text
{
    type = PIN_DEFAULT;
    size = 0.5f;
    if((self = [super init])) {
        _id = pinId;
        switch (color%12) {
            case 0:
            default:
                sprite = [[GlSprite alloc] initWithPicture:@"pin-aqua"];
                break;
            case 1:
                sprite = [[GlSprite alloc] initWithPicture:@"pin-blue-aqua"];
                break;
            case 2:
                sprite = [[GlSprite alloc] initWithPicture:@"pin-blue-pink"];
                break;
            case 3:
                sprite = [[GlSprite alloc] initWithPicture:@"pin-blue"];
                break;
            case 4:
                sprite = [[GlSprite alloc] initWithPicture:@"pin-green-yellow"];
                break;
            case 5:
                sprite = [[GlSprite alloc] initWithPicture:@"pin-green"];
                break;
            case 6:
                sprite = [[GlSprite alloc] initWithPicture:@"pin-pink-blue"];
                break;
            case 7:
                sprite = [[GlSprite alloc] initWithPicture:@"pin-pink"];
                break;
            case 8:
                sprite = [[GlSprite alloc] initWithPicture:@"pin-red-pink"];
                break;
            case 9:
                sprite = [[GlSprite alloc] initWithPicture:@"pin-red-yellow"];
                break;
            case 10:
                sprite = [[GlSprite alloc] initWithPicture:@"pin-red"];
                break;
            case 11:
                sprite = [[GlSprite alloc] initWithPicture:@"pin-yell"];
                break;
        }
        sp = [[SmallPanel alloc] initWithText:text];
    }
    return self;
}

-(id) initStarWithId:(int)pinId color:(int)color andText:(NSString*)text
{
    size = 0.5f;
    type = PIN_STAR;
    if((self = [super init])) {
        _id = pinId;
        switch (color%12) {
            default:
            case 0:
                sprite = [[GlSprite alloc] initWithPicture:@"star-aqua"];
                break;
            case 1:
                sprite = [[GlSprite alloc] initWithPicture:@"star-blue-aqua"];
                break;
            case 2:
                sprite = [[GlSprite alloc] initWithPicture:@"star-blue-pink"];
                break;
            case 3:
                sprite = [[GlSprite alloc] initWithPicture:@"star-blue"];
                break;
            case 4:
                sprite = [[GlSprite alloc] initWithPicture:@"star-green-yellow"];
                break;
            case 5:
                sprite = [[GlSprite alloc] initWithPicture:@"star-green"];
                break;
            case 6:
                sprite = [[GlSprite alloc] initWithPicture:@"star-pink-blue"];
                break;
            case 7:
                sprite = [[GlSprite alloc] initWithPicture:@"star-pink"];
                break;
            case 8:
                sprite = [[GlSprite alloc] initWithPicture:@"star-red-pink"];
                break;
            case 9:
                sprite = [[GlSprite alloc] initWithPicture:@"star-red-yellow"];
                break;
            case 10:
                sprite = [[GlSprite alloc] initWithPicture:@"star-red"];
                break;
            case 11:
                sprite = [[GlSprite alloc] initWithPicture:@"star-yell"];
                break;
        }
        sp = [[SmallPanel alloc] initWithText:text];
    }
    return self;
}

-(id) initFavWithId:(int)pinId color:(int)color andText:(NSString*)text
{
    size = 0.5f;
    constOffset = 20;
    type = PIN_FAVORITE;
    if((self = [super init])) {
        _id = pinId;
        switch (color%12) {
            default:
            case 0:
                sprite = [[GlSprite alloc] initWithPicture:@"fav-aqua"];
                break;
            case 1:
                sprite = [[GlSprite alloc] initWithPicture:@"fav-blue-aqua"];
                break;
            case 2:
                sprite = [[GlSprite alloc] initWithPicture:@"fav-blue-pink"];
                break;
            case 3:
                sprite = [[GlSprite alloc] initWithPicture:@"fav-blue"];
                break;
            case 4:
                sprite = [[GlSprite alloc] initWithPicture:@"fav-green-yellow"];
                break;
            case 5:
                sprite = [[GlSprite alloc] initWithPicture:@"fav-green"];
                break;
            case 6:
                sprite = [[GlSprite alloc] initWithPicture:@"fav-pink-blue"];
                break;
            case 7:
                sprite = [[GlSprite alloc] initWithPicture:@"fav-pink"];
                break;
            case 8:
                sprite = [[GlSprite alloc] initWithPicture:@"fav-red-pink"];
                break;
            case 9:
                sprite = [[GlSprite alloc] initWithPicture:@"fav-red-yellow"];
                break;
            case 10:
                sprite = [[GlSprite alloc] initWithPicture:@"fav-red"];
                break;
            case 11:
                sprite = [[GlSprite alloc] initWithPicture:@"fav-yell"];
                break;
        }
        sp = [[SmallPanel alloc] initWithText:text];
    }
    return self;
}

-(void)setPosition:(CGPoint)point
{
    pos = point;
    sp.position = point;
}

-(void)setGeoPosition:(CGPoint)geoPoint
{
    [self setPosition:translateFromGeoToMap(geoPoint)];
    // distance from user to pin
    distanceToUser = calcGeoDistanceFrom(geoPoint, userGeoPosition);
}

-(CGPoint)position
{
    return pos;
}

-(void)draw
{
    CGSize s;
    s.width = size * sprite.origWidth;
    s.height = size * sprite.origHeight;
    [sprite setRect:CGRectMake(pos.x-s.width*0.5f, pos.y-s.height*0.5f-offset-constOffset, s.width, s.height)];
    [sprite draw];
    [sp drawWithScale:1.f];
}

-(void)drawWithScale:(CGFloat)scale
{
    lastScale = scale;
    CGSize s;
    s.width = size * sprite.origWidth / scale;
    s.height = size * sprite.origHeight / scale;
    [sprite setRect:CGRectMake(pos.x-s.width*0.5f, pos.y-s.height*0.5f-offset-constOffset/scale, s.width, s.height)];
    [sprite draw];
}

-(void)drawPanelWithScale:(CGFloat)scale
{
    [sp drawWithScale:scale];
}

-(void)update:(CGFloat)dTime
{
    if(offset > 0.f) {
        offset -= dTime * speed;
        if(offset < 0.f) offset = 0.f;
    }
    [sp update:dTime];
}

-(void)fallFrom:(CGFloat)distance at:(CGFloat)spd
{
    offset = distance;
    speed = spd;
}

-(CGRect)bounds
{
    size = 32.f / lastScale;
    const CGFloat s2 = size * 0.5f;
    return CGRectMake(pos.x-s2, pos.y-s2-offset, size, size);
}

-(void)dealloc
{
    [sp release];
    [sprite release];
    [super dealloc];
}

@end

@implementation GlViewController

@synthesize context = _context;
//@synthesize effect = _effect;
@synthesize currentSelection;
@synthesize toStation;
@synthesize fromStation;
@synthesize stationsView;
@synthesize navigationViewController;



- (CGFloat) radialOffsetToPoint:(CGPoint)point
{
    CGPoint off = userGeoPosition;
    return atan2f(point.y - off.y, point.x - off.x);
}

- (CGFloat) radialOffsetFromPoint:(CGPoint)p1 toAnotherPoint:(CGPoint)p2
{
    return atan2f(p2.y - p1.y, p2.x - p1.x);
}

- (void)dealloc
{
    [pinsArray release];
    [stationsView release];
    [_context release];
    //[_effect release];
    [rasterLayer release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];

    pinsArray = [[NSMutableArray alloc] init];

    CGRect scrollSize,settingsRect,shadowRect,zonesRect,cornerRect;
    
    //scrollSize = CGRectMake(0, 44,(320),(480-64));
    //settingsRect=CGRectMake(285, 420, 27, 27);
    //shadowRect = CGRectMake(0, 44, 480, 61);
    if ([appDelegate isIPHONE5]) {
        zonesRect=CGRectMake(250, 498, 71, 43);
        cornerRect=CGRectMake(0, 489, 36, 60);
    }
    else {
        zonesRect=CGRectMake(250, 410, 71, 43);
        cornerRect=CGRectMake(0, 401, 36, 60);
    }
    
    if (IS_IPAD) {
        //scrollSize = CGRectMake(0, 44, 768, (1024-74));
        //settingsRect=CGRectMake(-285, -420, 27, 27);
        //shadowRect = CGRectMake(0, 44, 1024, 61);
        zonesRect=CGRectMake(self.view.bounds.size.width-70, self.view.bounds.size.height-50, 71, 43);

        //zonesRect=CGRectMake(self.view.bounds.size.width-70, self.view.bounds.size.height-50, 43, 25);
    } else {
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            CGFloat scale = [UIScreen mainScreen].scale;
            result = CGSizeMake(result.width * scale, result.height * scale);
            
            if(result.height == 1136){
                //scrollSize = CGRectMake(0,44,(320),(568-64));
                //settingsRect=CGRectMake(285, 508, 27, 27);
                //shadowRect = CGRectMake(0, 44, 568, 61);
                settingsRect=CGRectMake(55, 508, 27, 27);
            }
        }
    }
    
    self.context = [[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2] autorelease];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    position = CGPointZero;
    scale = 1.f;
    
    GlView *view = (GlView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    UIPanGestureRecognizer *rec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [view addGestureRecognizer:rec];
    UITapGestureRecognizer *rec2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    rec2.numberOfTapsRequired = 2;
    rec2.numberOfTouchesRequired = 1;
    [view addGestureRecognizer:rec2];
    UIPinchGestureRecognizer *rec3 = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [view addGestureRecognizer:rec3];
    UILongPressGestureRecognizer *rec4 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [view addGestureRecognizer:rec4];
    [self setupGL];
    
    rasterLayer = [[RasterLayer alloc] initWithRect:CGRectMake(0, 0, 256, 256) mapName:@"cuba"];
    //[rasterLayer setSignal:self selector:@selector(redrawRect:)];
    
    stationsView = [[TopRasterView alloc] initWithFrame:CGRectMake(0,0,320,44)];
    [view addSubview:stationsView];
    
    int adDelta = 0;
    
    settings = [UIButton buttonWithType:UIButtonTypeCustom];
    [settings setImage:[UIImage imageNamed:@"settings_btn_normal"] forState:UIControlStateNormal];
    [settings setImage:[UIImage imageNamed:@"settings_btn"] forState:UIControlStateHighlighted];
    settings.frame = CGRectMake(285, 420 - adDelta, 27, 27);
    [settings addTarget:self action:@selector(showSettings) forControlEvents:UIControlEventTouchUpInside];
    //[view addSubview:settings];
    
    sourceData = [UIButton buttonWithType:UIButtonTypeCustom];
    [sourceData setImage:[UIImage imageNamed:@"vector"] forState:UIControlStateNormal];
    [sourceData setImage:[UIImage imageNamed:@"terrain"] forState:UIControlStateSelected];
    sourceData.frame = CGRectMake(15, 420 - adDelta, 44, 27);
    [sourceData addTarget:self action:@selector(changeSource) forControlEvents:UIControlStateHighlighted];
    [view addSubview:sourceData];

    zones = [UIButton buttonWithType:UIButtonTypeCustom];
    [zones setImage:[UIImage imageNamed:@"bt_mode_metro_up"] forState:UIControlStateNormal];
    [zones setImage:[UIImage imageNamed:@"bt_mode_metro"] forState:UIControlStateHighlighted];
    zones.frame = zonesRect;
    [zones addTarget:self action:@selector(changeZones) forControlEvents:UIControlEventTouchUpInside];
    if (IS_IPAD)
        zones.hidden = YES;
    [view addSubview:zones];
    view.zonesButton = zones;

    
    cornerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cornerButton setImage:[UIImage imageNamed:@"bt_corner"] forState:UIControlStateNormal];
    [cornerButton setFrame:zonesRect];
    [cornerButton addTarget:self action:@selector(showSettings) forControlEvents:UIControlEventTouchUpInside];

    [view addSubview:cornerButton];
    
    // user geo position
    Pin *p = [[Pin alloc] initUserPos];
    [pinsArray addObject:p];
    [p setPosition:userPosition];
    newPinId = 1;
}

- (void) moveModeButtonToFullScreen {
    CGRect zonesRect, cornerRect;
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ([appDelegate isIPHONE5]) {
        zonesRect=CGRectMake(250, 498, 71, 43);
        cornerRect=CGRectMake(0, 489, 36, 60);
    } else if (IS_IPAD)  {
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            cornerRect=CGRectMake(0, 945, 36, 60);
            zonesRect=CGRectMake(250, 945, 71, 43);
        } else {
            cornerRect=CGRectMake(0, 689, 36, 60);
            zonesRect=CGRectMake(250, 689, 71, 43);
        }
    }
    else {
        zonesRect=CGRectMake(250, 410, 71, 43);
        cornerRect=CGRectMake(0, 401, 36, 60);
    }
    
    zones.frame = zonesRect;
    // we need to force recreating framebuffer object
    [((GLKView*)(self.view)) deleteDrawable];
    cornerButton.frame = cornerRect;
}

- (void) moveModeButtonToCutScreen {
    CGRect zonesRect, cornerRect;
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ([appDelegate isIPHONE5]) {
        zonesRect=CGRectMake(250, 498, 71, 43);
        cornerRect=CGRectMake(0, 489, 36, 60);

    }
    else if (IS_IPAD)  {
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            cornerRect=CGRectMake(0, 945, 36, 60);
            zonesRect=CGRectMake(250, 945, 71, 43);
        } else {
            cornerRect=CGRectMake(0, 689, 36, 60);
            zonesRect=CGRectMake(250, 689, 71, 43);
        }
    }
    else {
        zonesRect=CGRectMake(250, 410, 71, 43);
        cornerRect=CGRectMake(0, 401, 36, 60);

    }
    
    if (IS_IPAD)  {
        zonesRect.origin.y -= 664;
        cornerRect.origin.y -= 664;
    } else {
        zonesRect.origin.y -= 335;
        cornerRect.origin.y -= 335;
    }
    
    zones.frame = zonesRect;
    cornerButton.frame = cornerRect;

}

-(void) changeSource
{
    //BOOL s = [mapView changeSource];
    //[sourceData setSelected:s];
}

-(void) showSettings
{
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (IS_IPAD)
        [self showiPadSettingsModalView];//[appDelegate.mainViewController showiPadSettingsModalView];
    else
        [appDelegate showSettings];
}


- (void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    // Stop holding onto the popover
    popover = nil;
    [self returnFromSelectionFastAccess:nil];
}

-(void)showiPadSettingsModalView
{
    if (popover) [popover dismissPopoverAnimated:YES];
    
    SettingsViewController *controller = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:[NSBundle mainBundle]];
    controller.delegate=self;
    UINavigationController *navcontroller = [[UINavigationController alloc] initWithRootViewController:controller];
    navcontroller.modalPresentationStyle=UIModalPresentationFormSheet;
    [self presentModalViewController:navcontroller animated:YES];

    [controller release];
    [navcontroller release];
}

-(void)donePressed
{
    [self dismissModalViewControllerAnimated:YES];
}

-(void)handlePanGesture:(UIPanGestureRecognizer*)recognizer
{
    CGPoint p = [recognizer translationInView:self.view];
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            prevPosition = position;
            panTime = 0.f;
            panVelocity = CGPointZero;
            break;
        case UIGestureRecognizerStateChanged:
            panTime += self.timeSinceLastUpdate;
            panVelocity.x = p.x/scale;
            panVelocity.y = p.y/scale;
            position.x = panVelocity.x + prevPosition.x;
            position.y = panVelocity.y + prevPosition.y;
            break;
        case UIGestureRecognizerStateEnded: {
            position.x = p.x/scale + prevPosition.x;
            position.y = p.y/scale + prevPosition.y;
            if(panTime < 0.01f) panTime = 0.1f;
            panVelocity.x /= panTime;
            panVelocity.y /= panTime;
            float maxVel = 860.f / scale;
            if(panVelocity.x > maxVel) panVelocity.x = maxVel;
            if(panVelocity.y > maxVel) panVelocity.y = maxVel;
            panTime = 0.f;
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        default:
            position = prevPosition;
            break;
    }
}

-(void)handleDoubleTap:(UITapGestureRecognizer*)recognizer
{
    scale *= 1.5f;
    panVelocity = CGPointZero;
    //[self setGeoPosition:userGeoPosition withZoom:-1];
}

-(void)handleSingleTap:(UITapGestureRecognizer*)recognizer
{
    if(recognizer.state != UIGestureRecognizerStateEnded) return;
    CGPoint p = [recognizer locationInView:self.view];
    float x = (p.x - self.view.bounds.size.width*0.5f)/scale + 128 - position.x, y = (p.y - self.view.bounds.size.height*0.5f)/scale + 128 - position.y;
    NSMutableArray *selected = [NSMutableArray array];
    for (Pin *pin in pinsArray) {
        CGRect r = [pin bounds];
        if(CGRectContainsPoint(r, CGPointMake(x, y))) {
            [selected addObject: pin];
        } else if(pin.active) {
            pin.active = NO;
        }
    }
    if([selected count] > 0) {
        for (Pin *pin in selected) {
            pin.active = NO;
        }
        // select one lucky pin
        [[selected objectAtIndex:0] setActive:YES];
    }
}

-(void)handlePinch:(UIPinchGestureRecognizer*)recognizer
{
    panVelocity = CGPointZero;
    static CGFloat prevRecScale = 0.f;
    CGPoint prevDp = CGPointZero;
    static BOOL started = NO;
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            prevScale = scale;
            prevRecScale = recognizer.scale;
            prevPosition = position;
            break;
        case UIGestureRecognizerStateChanged:
            scale = prevScale * recognizer.scale / prevRecScale;
            if(scale > 100000) {
                scale = 100000;
            }
            CGPoint dp = [recognizer locationInView:self.view];
            dp.x -= self.view.bounds.size.width * 0.5f;
            dp.y -= self.view.bounds.size.height * 0.5f;
            if(!started) {
                prevDp = dp;
                started = YES;
            }
            position.x = prevPosition.x + (dp.x - prevDp.x) / scale;
            position.y = prevPosition.y + (dp.y - prevDp.y) / scale;
            break;
        case UIGestureRecognizerStateEnded:
            if(scale > 100000) {
                scale = 100000;
            }
            prevRecScale = 0.f;
            started = NO;
            break;
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        default:
            scale = prevScale;
            prevRecScale = 0.f;
            position = prevPosition;
            started = NO;
            break;
    }
}

- (void)viewDidUnload
{    
    [super viewDidUnload];
    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    self.context = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc. that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    [self loadShaders];
    
    //self.effect = [[[GLKBaseEffect alloc] init] autorelease];
    //self.effect.light0.enabled = GL_TRUE;
    //self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 0.4f, 0.4f, 1.0f);
    
    glDisable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    //self.effect = nil;
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}

#pragma mark - others methods

-(FastAccessTableViewController*)showTableView
{
    UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake(0,44,320,440)];
    blackView.backgroundColor  = [UIColor blackColor];
    blackView.alpha=0.4;
    blackView.tag=554;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleTap)];
    [blackView addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    [self.view addSubview:blackView];
    [blackView release];
    
    FastAccessTableViewController *tableViewC=[[[FastAccessTableViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
    tableViewC.view.frame=CGRectMake(0,44,320,200);
    
    tableViewC.tableView.hidden=YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:tableViewC selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    
    tableViewC.tableView.tag=555;
    
    [self.view addSubview:tableViewC.tableView];
    [self.view bringSubviewToFront:tableViewC.tableView];
    
    return tableViewC;
}

-(void)removeTableView
{
    [[self.view viewWithTag:554] removeFromSuperview];
    [[self.view viewWithTag:555] removeFromSuperview];
}

-(void)returnFromSelection:(NSArray*)stations
{
    [self dismissModalViewControllerAnimated:YES];
    [self performSelector:@selector(returnFromSelection2:) withObject:stations afterDelay:0.1];
    //((MainView*)self.view).shouldNotDropPins = NO;
}

-(void)returnFromSelection2:(NSArray*)items
{
    /*MainView *mainView = (MainView*)self.view;
    if ([items count]) {
        self.fromStation = [items objectAtIndex:0];
        [stationsView setFromStation:self.fromStation];
        if(![mainView centerMapOnUserAndItemWithID:[self.fromStation.index integerValue]]) {
#ifdef DEBUG
            NSLog(@"object %@ not found!", self.fromStation.index);
#endif
        }
        else {
            [self setPinForItem:[self.fromStation.index integerValue]];
        }
    }
    else {
        self.fromStation=nil;
    }
    
	mainView.mapView.stationSelected=false;
     */
}


-(void)returnFromSelectionFastAccess:(NSArray *)stations
{
    [self removeTableView];
    if (stations) {
        if (currentSelection==nil) {
            if ([stations objectAtIndex:0]==self.toStation) {
                self.fromStation=nil;
                [stationsView resetFromStation];
            } else {
                [self returnFromSelection:stations];
            }
        } else {
            if ([stations objectAtIndex:0]==self.fromStation) {
                self.toStation=nil;
                [stationsView resetToStation];
            } else {
                [self returnFromSelection:stations];
            }
        }     
        
        //      [self returnFromSelection:stations];
    } else {
        if (currentSelection==nil) {
            [stationsView setFromStation:self.fromStation];
        } else {
            [stationsView setToStation:self.toStation];
        }
    }
}

-(void)showTabBarViewController
{
    SelectingTabBarViewController *controller = [[SelectingTabBarViewController alloc] initWithNibName:@"SelectingTabBarViewController" bundle:[NSBundle mainBundle]];
    controller.delegate = self;
    
    CGRect frame = controller.view.frame;
    frame.origin.y = self.view.frame.size.height;
    controller.view.frame = frame;
    
    [self.view addSubview:controller.view];
    frame.origin.y = 0;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    controller.view.frame = frame;
    
    [UIView commitAnimations];
    
    //(self.view).shouldNotDropPins = YES;
    
    [controller autorelease];
}

-(void) changeZones
{
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showMetroMap];
    //[self dismissModalViewControllerAnimated:YES];
}

-(void)pressedSelectFromStation
{
    currentSelection=fromStation;
    [self showTabBarViewController];
}

-(void)pressedSelectToStation
{
    currentSelection=toStation;
    [self showTabBarViewController];
}

-(void)resetFromStation
{
    currentSelection=fromStation;
    [stationsView setToStation:self.toStation];
    [self returnFromSelection:[NSArray array]];
}

-(void)resetToStation
{
    currentSelection=toStation;
    [stationsView setFromStation:self.fromStation];
    [self returnFromSelection:[NSArray array]];
}

-(void)resetBothStations
{
    MItem *tempSelection = currentSelection;
    
    currentSelection=fromStation;
    [stationsView setToStation:nil];
    [stationsView setFromStation:nil];
    
    self.fromStation=nil;
    self.toStation=nil;
    
    [self returnFromSelection2:[NSArray array]];
    
    currentSelection=tempSelection;
}

- (void) removePinAtPlace:(MPlace*)place {
    NSInteger pinId = [place.index integerValue] + 1000;
    [self removePin:pinId];
}

- (CGFloat) setPinAtPlace:(MPlace*)place color:(int)color {
    CGPoint coordinate = CGPointMake([place.posX floatValue], [place.posY floatValue]);
    int newId = [place.index integerValue] + 1000;
    if ([self getPin:newId]) {
        return [[self getPin:newId] distanceToUser];
    }
    Pin *p = nil;
    if(place.name != nil)
        p = [[Pin alloc] initWithId:newId color:color andText:place.name];
    else
        p = [[Pin alloc] initWithId:newId andColor:color];
    //float dist = 256.f/scale;
    //[p fallFrom:(dist * (1.f+0.05f*(rand()%20))) at: dist*2];
    [pinsArray addObject:p];
    [p setGeoPosition:coordinate];
    return p.distanceToUser;
}

- (CGFloat) setStarAtPlace:(MPlace*)place color:(int)color {
    CGPoint coordinate = CGPointMake([place.posX floatValue], [place.posY floatValue]);
    int newId = [place.index integerValue] + 1000;
    if ([self getPin:newId]) {
        return [[self getPin:newId] distanceToUser];
    }
    Pin *p = nil;
    p = [[Pin alloc] initFavWithId:newId color:color andText:place.name];
    //float dist = 256.f/scale;
    //[p fallFrom:(dist * (1.f+0.05f*(rand()%20))) at: dist*2];
    [pinsArray addObject:p];
    [p setGeoPosition:coordinate];
    return p.distanceToUser;
}

-(int)newPin:(CGPoint)coordinate color:(int)color name:(NSString*)name
{
    int newId = newPinId;
    newPinId ++;
    Pin *p = nil;
    if(name != nil)
        p = [[Pin alloc] initWithId:newId color:color andText:name];
    else
        p = [[Pin alloc] initWithId:newId andColor:color];
    float dist = 256.f/scale;
    [p fallFrom:(dist * (1.f+0.05f*(rand()%20))) at: dist*2];
    [pinsArray addObject:p];
    [p setGeoPosition:coordinate];
    return newId;
}

-(int)newStar:(CGPoint)coordinate color:(int)color name:(NSString*)name
{
    int newId = newPinId;
    newPinId ++;
    Pin *p = [[Pin alloc] initStarWithId:newId color:color andText:name];
    [pinsArray addObject:p];
    [p setGeoPosition:coordinate];
    return newId;
}

-(void)removePin:(int)pinId
{
    Pin *found = nil;
    for (Pin *p in pinsArray) {
        if(p.Id == pinId) {
            found = p;
            break;
        }
    }
    if(found) [pinsArray removeObject:found];
}

-(void)removeAllPins
{
    NSMutableArray *temp = [NSMutableArray array];
    for (Pin *p in pinsArray) {
        if(p.type != PIN_DEFAULT) {
            [temp addObject:p];
        }
    }
    [pinsArray removeAllObjects];
    [pinsArray addObjectsFromArray:temp];
    [temp removeAllObjects];
}

-(int)setLocation:(CGPoint)coordinate
{
    for (Pin *p in pinsArray) {
        if(p.Id == -1) {
            [p setGeoPosition:coordinate];
            return -1;
        }
    }
    Pin *loc = [[[Pin alloc] initLocationPos] autorelease];
    [loc setGeoPosition:coordinate];
    [pinsArray addObject:loc];
    return -1;
}

-(Pin*)getPin:(int)pinId
{
    for (Pin *p in pinsArray) {
        if(p.Id == pinId) {
            return p;
        }
    }
    return nil;
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    if(targetTimer > 0.f) {
        scale = (prevScale - targetScale) * targetTimer + targetScale;
        position.x = (prevPosition.x - targetPosition.x) * targetTimer + targetPosition.x;
        position.y = (prevPosition.y - targetPosition.y) * targetTimer + targetPosition.y;
        targetTimer -= self.timeSinceLastUpdate;
        if(targetTimer <= 0.f) {
            scale = targetScale;
            position = targetPosition;
            targetTimer = 0.f;
        }
    }
    if(panTime == 0.f && (panVelocity.x != 0.f || panVelocity.y != 0.f)) {
        position.x += panVelocity.x * self.timeSinceLastUpdate;
        position.y += panVelocity.y * self.timeSinceLastUpdate;
        CGPoint dv;
        dv.x = 1000.f / scale * self.timeSinceLastUpdate;
        dv.y = 1000.f / scale * self.timeSinceLastUpdate;
        if(fabs(panVelocity.x) < dv.x) panVelocity.x = 0.f;
        else {
            if(panVelocity.x > 0.f) panVelocity.x -= dv.x;
            else panVelocity.x += dv.x;
        }
        if(fabs(panVelocity.y) < dv.y) panVelocity.y = 0.f;
        else {
            if(panVelocity.y > 0.f) panVelocity.y -= dv.y;
            else panVelocity.y += dv.y;
        }
    }
    
    float W2 = self.view.bounds.size.width*0.5f, H2 = self.view.bounds.size.height*0.5f;
    //float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    //GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 1000.0f);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(-W2, W2, H2, -H2, -1000, 1000);
    
    //self.effect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(-128, -128, 0.0f);
    //baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _rotation, -1.0f, 1.0f, 0.0f);
    
    // Compute the model view matrix for the object rendered with GLKit
    //GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -1.5f);
    //modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    //modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    
    //self.effect.transform.modelviewMatrix = modelViewMatrix;
    
    // Compute the model view matrix for the object rendered with ES2
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeScale(scale, scale, scale);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeTranslation(position.x+W2/scale, position.y+H2/scale, 0.f));
    modelViewMatrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(-W2, -H2, 0.f), modelViewMatrix);
    //modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, baseModelViewMatrix);
    
    _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
    
    _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    
    //_rotation += self.timeSinceLastUpdate * 0.5f;
    for (Pin *p in pinsArray) {
        [p update:self.timeSinceLastUpdate];
    }
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    

//    GLint src_rect[4];
//    src_rect[0] = 0; // left
//    src_rect[1] = 0; // bottom
//    src_rect[2] = 256; // width
//    src_rect[3] = 256; // height
//    
//    // these must be disabled
//    glDisableClientState(GL_COLOR_ARRAY);
//    glDisableClientState(GL_VERTEX_ARRAY);
//    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
//    
//    glActiveTexture( GL_TEXTURE0 );
//    glEnable(GL_TEXTURE_2D);
//    glBindTexture( GL_TEXTURE_2D, 1 );
//    glTexParameteriv( GL_TEXTURE_2D, GL_TEXTURE_CROP_RECT_OES, src_rect );
//    glDrawTexfOES( (GLfloat) 0, (GLfloat)0, 1.0f, (GLfloat) 256, (GLfloat) 256 );
//    glDisable(GL_TEXTURE_2D);    
    
//    glEnable(GL_TEXTURE_2D);
//    glDepthMask(GL_FALSE);
//    glBindTexture(GL_TEXTURE_2D, 1);
//    glDrawTexfOES(0, 0, 0, 256, 256);
//    glDepthMask(GL_TRUE);
//    glEnable(GL_DEPTH_TEST);
//    glBindTexture(GL_TEXTURE_2D, 0);
    
    /*glBindVertexArrayOES(_vertexArray);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
    
    // Render the object with GLKit
    [self.effect prepareToDraw];
    
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    // Render the object again with ES2
    glUseProgram(_program);
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);
    
    glDrawArrays(GL_TRIANGLES, 0, 36);
     */
    //[self.effect prepareToDraw];
    glUseProgram(_program);
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
    //glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);
    glUniform1i(uniforms[UNIFORM_SAMPLER], 0);
    float sc = scale;
    //if(sc < 3.f) sc = 3.f;
    //if(sc > 2000.f) sc = 2000.f;
    float W = self.view.bounds.size.width, W2 = W*0.5f, H = self.view.bounds.size.height, H2 = H*0.5f;
    [rasterLayer drawGlInRect:CGRectMake(128 - position.x - W2/scale, 128 - position.y - H2/scale, W/scale, H/scale) withScale:sc];
    
    [self drawPins];
}

-(void)drawPins
{
    for (Pin *p in pinsArray) {
        [p drawWithScale:scale];
    }
    for (Pin *p in pinsArray) if(p.active) {
        [p drawPanelWithScale:scale];
    }
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, GLKVertexAttribPosition, "position");
    //glBindAttribLocation(_program, GLKVertexAttribColor, "color");
    glBindAttribLocation(_program, GLKVertexAttribTexCoord0, "uv");
    
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    //uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
    uniforms[UNIFORM_SAMPLER] = glGetUniformLocation(_program, "sampler");
    uniforms[UNIFORM_COLOR] = glGetUniformLocation(_program, "color");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

-(void)setGeoPosition:(CGRect)rect
{
    const static double mult = 256.0 / 360.0;
    float y1 = atanhf(sinf(rect.origin.x * M_PI / 180.f));
    y1 = y1 * 256.f / (M_PI*2.f);
    float y2 = atanhf(sinf((rect.origin.x+rect.size.width) * M_PI / 180.f));
    y2 = y2 * 256.f / (M_PI*2.f);
    CGRect r;
    r.origin.y = rect.origin.y * mult;
    r.size.height = rect.size.height * mult;
    position.x = -(r.origin.y + r.size.height * 0.5f);
    position.y = (y1 + y2) * 0.5f;
    scale = 256.f / r.size.height;
    targetTimer = 0.f;
}

-(void)setGeoPosition:(CGPoint)geoCoords withZoom:(CGFloat)zoom
{
    const static double mult = 256.0 / 360.0;
    float y = atanhf(sinf(geoCoords.x * M_PI / 180.f));
    y = y * 256.f / (M_PI*2.f);
    if (zoom != -1) {
        scale = zoom;
    }
    position.x = - geoCoords.y * mult;
    position.y = y + 2.f / scale;
    targetTimer = 0.f;
}

-(void)scrollToGeoPosition:(CGPoint)geoCoords withZoom:(CGFloat)zoom
{
    const static double mult = 256.0 / 360.0;
    float y = atanhf(sinf(geoCoords.x * M_PI / 180.f));
    y = y * 256.f / (M_PI*2.f);
    prevScale = scale;
    if (zoom != -1) {
        targetScale = zoom;
    } else {
        targetScale = scale;
    }
    prevPosition = position;
    targetPosition.x = - geoCoords.y * mult;
    targetPosition.y = y + 2.f / scale;
    targetTimer = 1.f;
}

-(void)setUserGeoPosition:(CGPoint)point
{
    userGeoPosition = point;
    CGPoint up = translateFromGeoToMap(point);
    userPosition = up;
    Pin *p = [pinsArray objectAtIndex:0];
    if(p != nil) [p setPosition:up];
    [self setGeoPosition:userGeoPosition withZoom:-1];
}

- (void) centerMapOnUser {
    [self scrollToGeoPosition:userGeoPosition withZoom:-1];
}


-(void)setStationsPosition:(NSArray *)data withMarks:(BOOL)marks
{
    [self removeAllPins];
    for (int i=0; i<[data count]; i++) {
        CGRect r = [[[data objectAtIndex:i] valueForKey:@"coordinate" ] CGRectValue];
        [self newPin:r.origin color:[[[data objectAtIndex:i] valueForKey:@"pinColor"] intValue] name:[[data objectAtIndex:i] valueForKey:@"name"]];
        if([[[data objectAtIndex:i] valueForKey:@"ending" ] length] > 0) {
        //if(marks && (i == 0 || i == [coords count]-1)) {
            [[pinsArray lastObject] setActive:YES];
        }
    }
}

-(void)errorWithGeoLocation
{
    
}

-(CGFloat)calcGeoDistanceFrom:(CGPoint)p1 to:(CGPoint)p2
{
    return calcGeoDistanceFrom(p1, p2);
}

-(void)purgeUnusedCache
{
    [rasterLayer purgeUnusedCache];
}

@end

void SetColor(float r, float g, float b, float a) {
    glUniform4f(uniforms[UNIFORM_COLOR], r, g, b, a);
}

void ResetColor() {
    glUniform4f(uniforms[UNIFORM_COLOR], 1.f, 1.f, 1.f, 1.f);
}
