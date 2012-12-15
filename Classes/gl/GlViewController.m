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


@interface GlViewController () {
    GLuint _program;
    
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    //float _rotation;
    
    RasterLayer *rasterLayer;
    CGPoint position, prevPosition;
    CGFloat scale, prevScale;
    UIButton *sourceData, *settings, *zones;
    
    MItem *currentSelection;
    MItem *fromStation;
    MItem *toStation;
    TopRasterView *stationsView;
    
    CGPoint panVelocity;
    CGFloat panTime;
    NSMutableArray *pinsArray;
    int newPinId;
    
    CGPoint userPosition, userGeoPosition;
}
@property (strong, nonatomic) EAGLContext *context;
//@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;

-(CGPoint)translateFromGeoToMap:(CGPoint)pm;
-(void)drawPins;
@end

@implementation Pin
@synthesize Id = _id;
@synthesize distanceToUser;

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

-(id)initWithId:(int)pinId andColor:(int)color
{
    if((self = [super init])) {
        _id = pinId;
        switch (color) {
            case 0:
            default:
                sprite = [[GlSprite alloc] initWithPicture:@"user_pos"];
                break;
            case 1:
                sprite = [[GlSprite alloc] initWithPicture:@"pin_aqua"];  // .GB
                break;
            case 2:
                sprite = [[GlSprite alloc] initWithPicture:@"pin_brown"]; // rg.
                break;
            case 3:
                sprite = [[GlSprite alloc] initWithPicture:@"pin_lightblue"];// .gB
                break;
            case 4:
                sprite = [[GlSprite alloc] initWithPicture:@"pin_pink"];  // RgB
                break;
            case 5:
                sprite = [[GlSprite alloc] initWithPicture:@"pin_red"];   // R..
                break;
            case 6:
                sprite = [[GlSprite alloc] initWithPicture:@"pin_blue"];  // ..B
                break;
            case 7:
                sprite = [[GlSprite alloc] initWithPicture:@"pin_green"]; // .G.
                break;
            case 8:
                sprite = [[GlSprite alloc] initWithPicture:@"pin_yellow"];// RG.
                break;
        }
        size = 32;
        sp = [[SmallPanel alloc] initWithText:@"Hello!"];
    }
    return self;
}

-(id) initWithId:(int)pinId color:(int)color andText:(NSString*)text
{
    if((self = [super init])) {
        _id = pinId;
        switch (color) {
            case 0:
            default:
                sprite = [[GlSprite alloc] initWithPicture:@"user_pos"];
                break;
            case 1:
                sprite = [[GlSprite alloc] initWithPicture:@"pin_aqua"];  // .GB
                break;
            case 2:
                sprite = [[GlSprite alloc] initWithPicture:@"pin_brown"]; // rg.
                break;
            case 3:
                sprite = [[GlSprite alloc] initWithPicture:@"pin_lightblue"];// .gB
                break;
            case 4:
                sprite = [[GlSprite alloc] initWithPicture:@"pin_pink"];  // RgB
                break;
            case 5:
                sprite = [[GlSprite alloc] initWithPicture:@"pin_red"];   // R..
                break;
            case 6:
                sprite = [[GlSprite alloc] initWithPicture:@"pin_blue"];  // ..B
                break;
            case 7:
                sprite = [[GlSprite alloc] initWithPicture:@"pin_green"]; // .G.
                break;
            case 8:
                sprite = [[GlSprite alloc] initWithPicture:@"pin_yellow"];// RG.
                break;
            case 9:
                sprite = [[GlSprite alloc] initWithPicture:@"pin_9"];  // .GB
                break;
            case 10:
                sprite = [[GlSprite alloc] initWithPicture:@"pin_10"]; // rg.
                break;
            case 11:
                sprite = [[GlSprite alloc] initWithPicture:@"pin_11"];// .gB
                break;
            case 12:
                sprite = [[GlSprite alloc] initWithPicture:@"pin_12"];  // RgB
                break;
            case 13:
                sprite = [[GlSprite alloc] initWithPicture:@"pin_13"];   // R..
                break;
            case 14:
                sprite = [[GlSprite alloc] initWithPicture:@"pin_14"];  // ..B
                break;
            case 15:
                sprite = [[GlSprite alloc] initWithPicture:@"pin_15"]; // .G.
                break;
            case 16:
                sprite = [[GlSprite alloc] initWithPicture:@"pin_16"];// RG.
                break;
        }
        size = 32;
        sp = [[SmallPanel alloc] initWithText:text];
    }
    return self;
}

-(void)setPosition:(CGPoint)point
{
    pos = point;
    sp.position = point;
}

-(CGPoint)position
{
    return pos;
}

-(void)draw
{
    const CGFloat s2 = size * 0.5f;
    [sprite setRect:CGRectMake(pos.x-s2, pos.y-s2-offset, size, size)];
    [sprite draw];
    [sp drawWithScale:1.f];
}

-(void)drawWithScale:(CGFloat)scale
{
    lastScale = scale;
    size = 32.f / scale;
    const CGFloat s2 = size * 0.5f;
    [sprite setRect:CGRectMake(pos.x-s2, pos.y-s2-offset, size, size)];
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

    CGRect scrollSize,settingsRect,shadowRect,zonesRect;
    
    //scrollSize = CGRectMake(0, 44,(320),(480-64));
    //settingsRect=CGRectMake(285, 420, 27, 27);
    //shadowRect = CGRectMake(0, 44, 480, 61);
    if ([appDelegate isIPHONE5]) {
        zonesRect=CGRectMake(250, 498, 71, 43);
    }
    else {
        zonesRect=CGRectMake(250, 410, 71, 43);
    }
    
    if (IS_IPAD) {
        //scrollSize = CGRectMake(0, 44, 768, (1024-74));
        //settingsRect=CGRectMake(-285, -420, 27, 27);
        //shadowRect = CGRectMake(0, 44, 1024, 61);
        zonesRect=CGRectMake(self.view.bounds.size.width-70, self.view.bounds.size.height-50, 43, 25);
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
    [zones setImage:[UIImage imageNamed:@"bt_mode_metro"] forState:UIControlStateNormal];
    //[zones setImage:[UIImage imageNamed:@"zones_btn"] forState:UIControlStateHighlighted];
    zones.frame = zonesRect;
    [zones addTarget:self action:@selector(changeZones) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:zones];
    view.zonesButton = zones;

    // user geo position
    Pin *p = [[Pin alloc] initWithId:0 color:0 andText:@"You are here!"];
    [pinsArray addObject:p];
    [p setPosition:userPosition];
    newPinId = 1;
}

-(void) changeSource
{
    //BOOL s = [mapView changeSource];
    //[sourceData setSelected:s];
}

-(void) showSettings
{
    SettingsNavController *controller = [[SettingsNavController alloc] initWithNibName:@"SettingsNavController" bundle:[NSBundle mainBundle]];
    [self.navigationViewController presentModalViewController:controller animated:YES];
    [controller release];
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
        case UIGestureRecognizerStateEnded:
            position.x = p.x/scale + prevPosition.x;
            position.y = p.y/scale + prevPosition.y;
            panVelocity.x /= panTime;
            panVelocity.y /= panTime;
            panTime = 0.f;
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
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            prevScale = scale;
            prevRecScale = recognizer.scale;
            break;
        case UIGestureRecognizerStateChanged:
            scale = prevScale * recognizer.scale / prevRecScale;
            //NSLog(@"scale %f", scale);
            break;
        case UIGestureRecognizerStateEnded:
            prevRecScale = 0.f;
            break;
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        default:
            scale = prevScale;
            prevRecScale = 0.f;
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
    float dist = 256.f/scale;
    [p fallFrom:(dist * (1.f+0.05f*(rand()%20))) at: dist*2];
    [pinsArray addObject:p];
    [p setPosition:[self translateFromGeoToMap:coordinate]];
    
    // distance from user to pin
    p.distanceToUser = [self calcGeoDistanceFrom:coordinate to:userGeoPosition];
    
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
    [p setPosition:[self translateFromGeoToMap:coordinate]];
    
    // distance from user to pin
    p.distanceToUser = [self calcGeoDistanceFrom:coordinate to:userGeoPosition];
    
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
    Pin *usrPin = nil;
    for (Pin *p in pinsArray) {
        if(p.Id == 0) usrPin = [p retain];
    }
    [pinsArray removeAllObjects];
    [pinsArray addObject:usrPin];
    [usrPin release];
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

-(CGPoint)translateFromGeoToMap:(CGPoint)pm
{
    const static double mult = 256.0 / 360.0;
    float y = atanhf(sinf(pm.x * M_PI / 180.f));
    y = y * 256.f / (M_PI*2.f);
    CGPoint p;
    p.x = 128.f + pm.y * mult;
    p.y = 128.f - y;
    return p;
}

-(CGFloat)calcGeoDistanceFrom:(CGPoint)p1 to:(CGPoint)p2
{
    const float cc = M_PI / 180.f;
    float dis = 6371.21f * acosf(sinf(p1.x*cc)*sinf(p2.x*cc) + cosf(p1.x*cc)*cosf(p2.x*cc)*cosf(p1.y*cc+p2.y*cc));
    return dis;
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
}

-(void)setGeoPosition:(CGPoint)geoCoords withZoom:(CGFloat)zoom
{
    const static double mult = 256.0 / 360.0;
    float y = atanhf(sinf(geoCoords.x * M_PI / 180.f));
    y = y * 256.f / (M_PI*2.f);
    position.x = - geoCoords.y * mult;
    position.y = y + 120.f/zoom;
    if (zoom != -1) {
        scale = zoom;
    }
}

-(void)setUserGeoPosition:(CGPoint)point
{
    userGeoPosition = point;
    CGPoint up = [self translateFromGeoToMap:point];
    userPosition = up;
    Pin *p = [pinsArray objectAtIndex:0];
    if(p != nil) [p setPosition:up];
}

-(void)setStationsPosition:(NSArray *)coords withNames:(NSArray*)names andMarks:(BOOL)marks
{
    [self removeAllPins];
    for (int i=0; i<[coords count]; i++) {
        CGRect r = [[coords objectAtIndex:i] CGRectValue];
        if(i < [names count]) {
            [self newPin:r.origin color:r.size.width name:[names objectAtIndex:i]];
        } else {
            [self newPin:r.origin color:r.size.width name:nil];
        }
        if(marks && (i == 0 || i == [coords count]-1)) {
            [[pinsArray lastObject] setActive:YES];
        }
    }
}

-(void)errorWithGeoLocation
{
    
}

@end

void SetColor(float r, float g, float b, float a) {
    glUniform4f(uniforms[UNIFORM_COLOR], r, g, b, a);
}

void ResetColor() {
    glUniform4f(uniforms[UNIFORM_COLOR], 1.f, 1.f, 1.f, 1.f);
}
