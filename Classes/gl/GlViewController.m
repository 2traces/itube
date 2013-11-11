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
#import "ZonesButtonConf.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))
#define d2r (M_PI / 180.0)

#define LEVEL_WIFI_POINT 13
#define LEVEL_WIFI_CLUSTER 10

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

float sqr(float x)
{
    return x*x;
}

//calculate haversine distance for linear distance
double haversine_km(double lat1, double long1, double lat2, double long2)
{
    double dlong = (long2 - long1) * d2r;
    double dlat = (lat2 - lat1) * d2r;
    double a = pow(sin(dlat/2.0), 2) + cos(lat1*d2r) * cos(lat2*d2r) * pow(sin(dlong/2.0), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1-a));
    double d = 6367 * c;
    
    return d;
}


CGFloat calcGeoDistanceFrom(CGPoint p1, CGPoint p2)
{
//    static const float cc = M_PI / 180.f;
//    float dis = 6371.21f * acosf(sinf(p1.x*cc)*sinf(p2.x*cc) + cosf(p1.x*cc)*cosf(p2.x*cc)*cosf(p1.y*cc+p2.y*cc));

    double dlong = (p2.y - p1.y) * d2r;
    double dlat = (p2.x - p1.x) * d2r;
    double a = pow(sin(dlat/2.0), 2) + cos(p1.x*d2r) * cos(p2.x*d2r) * pow(sin(dlong/2.0), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1-a));
    float d = 6367 * c;
    
    return d;
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

CGPoint translateFromMapToGeo(CGPoint p)
{
//    const static double mult = 256.0 / 360.0;
//    float y = atanhf(sinf(geoCoords.x * M_PI / 180.f));
//    y = y * 256.f / (M_PI*2.f);
//    if (zoom != -1) {
//        scale = zoom;
//    }
//    position.x = - geoCoords.y * mult;
//    position.y = y + 2.f / scale;
    
    
    const static double mult = 256.0 / 360.0;
    CGPoint pm;
    pm.y = (-p.x) / mult;
    pm.x = asinf(tanhf((p.y) * (M_PI*2.f) / 256.f)) * 180.f / M_PI;
    return pm;
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
    
    CGPoint panVelocity;
    CGFloat panTime;
    int newPinId;
    
    CGPoint userPosition;
    int objectsLOD;
    CLLocationManager *locationManager;
    NSMutableArray *lastSearchResults;
    EAGLContext *secondContext;
    BOOL backgroundThreadShouldFinish;
    int shouldUpdatePinsForLevel;
}
@property (strong, nonatomic) EAGLContext *context;
@property (retain, atomic) NSArray *pinsArray;
@property (strong, nonatomic) NSArray *clusters;
//@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;

-(void)drawPinsInRect:(CGRect)r;
@end

@implementation Object

-(NSString*)decode:(id)val
{
    if([val isKindOfClass:[NSNull class]]) {
        return @"";
    } else if([val isKindOfClass:[NSString class]]) {
        if ([val stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]) {
            return [val stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        return val;
    } else {
        if ([val description]) {
            return [val description];
        }
        return @"";
    }
}

-(id)initWithDictionary:(NSDictionary *)data
{
    if((self = [super init])) {
//        if (!objectsTypes) {
//            objectsTypes = [[NSMutableArray arrayWithCapacity:5] retain];
//        }
//        if (![objectsTypes containsObject:[data objectForKey:@"kind"]]) {
//            [objectsTypes addObject:[data objectForKey:@"kind"]];
//        }
        self.address = [self decode:[data objectForKey:@"address"]];
        self.city = [self decode:[data objectForKey:@"city"]];
        NSArray *comments = [data objectForKey:@"comment"];
        if ([comments isKindOfClass:[NSArray class]] && [comments count]) {
            NSMutableArray *temp = [NSMutableArray arrayWithCapacity:1];
            for (id comment in comments) {
                if (comment && [comment isKindOfClass:[NSString class]]) {
                    [temp addObject:[self decode:comment]];
                }
            }
            self.comments = [NSArray arrayWithArray:temp];
        }
        self.country = [self decode:[data objectForKey:@"country"]];
        self.hours = [self decode:[data objectForKey:@"hours"]];
        self.ID = [data objectForKey:@"id"];
        self.kind = [self decode:[data objectForKey:@"kind"]];
        self.state = [self decode:[data objectForKey:@"data"]];
        self.street = [self decode:[data objectForKey:@"street"]];
        self.title = [self decode:[data objectForKey:@"title"]];
        CGPoint g;
        g.x = [[data objectForKey:@"lat"] floatValue];
        g.y = [[data objectForKey:@"lng"] floatValue];
        self.geoP = g;
        CGPoint c;
        c.x = 128 - [[data objectForKey:@"x"] floatValue];
        c.y = 128 - [[data objectForKey:@"y"] floatValue];
        self.coords = c;
        self.pinID = -1;
    }
    return self;
}

-(NSString*)description
{
    return [NSString stringWithFormat:@"[Object address: %@ city: %@ comment: %@ country: %@ hours: %@ kind: %@ lat: %f lng: %f state: %@ street: %@ title: %@ x: %f y: %f]",
            self.address, self.city, [self.comments firstObject], self.country, self.hours, self.kind, self.geoP.x, self.geoP.y, self.state, self.street, self.title, self.coords.x, self.coords.y];
}

-(void)dealloc
{
    [_address release];
    [_city release];
    [_comments release];
    [_country release];
    [_hours release];
    [_ID release];
    [_kind release];
    [_state release];
    [_street release];
    [_title release];
    [super dealloc];
}

@end

@implementation Cluster

@synthesize center, objects = _objects, pinID, radius = radius;

-(id)initWithRadius:(CGFloat)r
{
    if((self = [super init])) {
        radius = r;
        _objects = [[NSMutableArray alloc] init];
        center = sumCoord = CGPointZero;
        pinID = -1;
    }
    return self;
}

-(NSString*)title
{
    return [NSString stringWithFormat:@"%d %@", [_objects count], NSLocalizedString(@"wi-fi nearby", @"")];
}

-(BOOL)accept:(id)element
{
    CGPoint el;
    if([element isKindOfClass:[Object class]]) {
        for (id o in _objects) {
            if([o isKindOfClass:Object.class] && [[o ID] isEqualToString:[element ID]]) {
                return YES;
            }
        }
        el = [element coords];
    } else if([element isKindOfClass:[Cluster class]]) el = [(Cluster*)element center];
    else return NO;
    if([_objects count] <= 0) {
        [_objects addObject:element];
        sumCoord = center = el;
    } else {
        CGPoint delta = CGPointMake(el.x - center.x, el.y - center.y);
        delta.x *= delta.x;
        delta.y *= delta.y;
        CGFloat len = sqrtf(delta.x + delta.y);
        if(len > radius) return NO;
        [_objects addObject:element];
        sumCoord.x += el.x;
        sumCoord.y += el.y;
        center.x = sumCoord.x / [_objects count];
        center.y = sumCoord.y / [_objects count];
    }
    return YES;
}

-(void)dealloc
{
    [_objects release];
    [super dealloc];
}

@end


@implementation Pin
@synthesize Id = _id;
@synthesize distanceToUser;
@synthesize type;
@synthesize rotation;

-(void)setActive:(BOOL)active
{
    if(active) {
        [self loadPanel];
        [sp show];
    } else {
        [sp hide];
        [self unloadPanel];
    }
}

-(BOOL)active
{
    return sp != nil && !sp.closed;
}

-(id)initUserPos
{
    type = PIN_USER;
    alpha = 1.f;
    size = 1.f / [UIScreen mainScreen].scale;
    if((self = [super init])) {
        _id = 0;
        if([CLLocationManager headingAvailable]) {
            //sprite = [[GlSprite alloc] initWithPicture:@"current_location-with-direction"];
            pinTexture = @"current_location-with-direction";
        } else {
            //sprite = [[GlSprite alloc] initWithPicture:@"current_location"];
            pinTexture = @"current_location";
        }
        //sp = [[BigPanel alloc] initWithText:@"You are here!"];
        pinText = @"You are here!";
        _loaded = NO;
    }
    return self;
}

-(id)initObjectPos
{
    type = PIN_OBJECT;
    alpha = 1.f;
    size = 1.f / [UIScreen mainScreen].scale;
    if((self = [super init])) {
        _id = -1;
        //sprite = [[GlSprite alloc] initWithPicture:@"station_mark"];
        //sp = [[BigPanel alloc] initWithText:@"You are gonna be there!"];
        pinTexture = @"station_mark";
        pinText = @"You are gonna be there!";
        _loaded = NO;
    }
    return self;
}

-(id)initWithId:(int)pinId andColor:(int)color
{
    return [self initWithId:pinId color:color andText:@"Hello!"];
}

-(id) initWithId:(int)pinId color:(int)color andText:(NSString*)text
{
    return [self initWithId:pinId color:color text:text andSubtitle:nil];
}

-(id) initWithId:(int)pinId color:(int)color text:(NSString*)text andSubtitle:(NSString*)subtitle
{
    type = PIN_DEFAULT;
    alpha = 1.f;
    size = 1.f / [UIScreen mainScreen].scale;
    if((self = [super init])) {
        _id = pinId;
        switch (color%12) {
            case 0:
            default:
                //sprite = [[GlSprite alloc] initWithPicture:@"fav-aqua"];
                pinTexture = @"fav-aqua";
                break;
            case 1:
                //sprite = [[GlSprite alloc] initWithPicture:@"fav-blue-aqua"];
                pinTexture = @"fav-blue-aqua";
                break;
            case 2:
                //sprite = [[GlSprite alloc] initWithPicture:@"fav-blue-pink"];
                pinTexture = @"fav-blue-pink";
                break;
            case 3:
                //sprite = [[GlSprite alloc] initWithPicture:@"fav-blue"];
                pinTexture = @"fav-blue";
                break;
            case 4:
                //sprite = [[GlSprite alloc] initWithPicture:@"fav-green-yellow"];
                pinTexture = @"fav-green-yellow";
                break;
            case 5:
                //sprite = [[GlSprite alloc] initWithPicture:@"fav-green"];
                pinTexture = @"fav-green";
                break;
            case 6:
                //sprite = [[GlSprite alloc] initWithPicture:@"fav-pink-blue"];
                pinTexture = @"fav-pink-blue";
                break;
            case 7:
                //sprite = [[GlSprite alloc] initWithPicture:@"fav-pink"];
                pinTexture = @"fav-pink";
                break;
            case 8:
                //sprite = [[GlSprite alloc] initWithPicture:@"fav-red-pink"];
                pinTexture = @"fav-red-pink";
                break;
            case 9:
                //sprite = [[GlSprite alloc] initWithPicture:@"fav-red-yellow"];
                pinTexture = @"fav-red-yellow";
                break;
            case 10:
                //sprite = [[GlSprite alloc] initWithPicture:@"fav-red"];
                pinTexture = @"fav-red";
                break;
            case 11:
                //sprite = [[GlSprite alloc] initWithPicture:@"fav-yell"];
                pinTexture = @"fav-yell";
                break;
        }
        //sp = [[BigPanel alloc] initWithText:text andSubtitle:subtitle];
        pinText = [text retain];
        pinSubtitle = [subtitle retain];
        _loaded = NO;
    }
    return self;
}

-(id) initClusterWithId:(int)pinId color:(int)color andText:(NSString*)text
{
    size = 1.f / [UIScreen mainScreen].scale;
    alpha = 1.f;
    type = PIN_CLUSTER;
    if((self = [super init])) {
        _id = pinId;
        switch (color%12) {
            default:
            case 0:
                //sprite = [[GlSprite alloc] initWithPicture:@"star-aqua"];
                pinTexture = @"star-aqua";
                break;
            case 1:
                //sprite = [[GlSprite alloc] initWithPicture:@"star-blue-aqua"];
                pinTexture = @"star-blue-aqua";
                break;
            case 2:
                //sprite = [[GlSprite alloc] initWithPicture:@"star-blue-pink"];
                pinTexture = @"star-blue-pink";
                break;
            case 3:
                //sprite = [[GlSprite alloc] initWithPicture:@"star-blue"];
                pinTexture = @"star-blue";
                break;
            case 4:
                //sprite = [[GlSprite alloc] initWithPicture:@"star-green-yellow"];
                pinTexture = @"star-green-yellow";
                break;
            case 5:
                //sprite = [[GlSprite alloc] initWithPicture:@"star-green"];
                pinTexture = @"star-green";
                break;
            case 6:
                //sprite = [[GlSprite alloc] initWithPicture:@"star-pink-blue"];
                pinTexture = @"star-pink-blue";
                break;
            case 7:
                //sprite = [[GlSprite alloc] initWithPicture:@"star-pink"];
                pinTexture = @"star-pink";
                break;
            case 8:
                //sprite = [[GlSprite alloc] initWithPicture:@"star-red-pink"];
                pinTexture = @"star-red-pink";
                break;
            case 9:
                //sprite = [[GlSprite alloc] initWithPicture:@"star-red-yellow"];
                pinTexture = @"star-red-yellow";
                break;
            case 10:
                //sprite = [[GlSprite alloc] initWithPicture:@"star-red"];
                pinTexture = @"star-red";
                break;
            case 11:
                //sprite = [[GlSprite alloc] initWithPicture:@"star-yell"];
                pinTexture = @"star-yell";
                break;
        }
        //sp = [[BigPanel alloc] initWithText:text];
        pinText = [text retain];
        _loaded = NO;
    }
    return self;
}

-(id) initFavWithId:(int)pinId color:(int)color andText:(NSString*)text
{
    size = 1.f / [UIScreen mainScreen].scale;
    alpha = 1.f;
    constOffset = 20;
    type = PIN_FAVORITE;
    if((self = [super init])) {
        _id = pinId;
        switch (color%12) {
            default:
            case 0:
                //sprite = [[GlSprite alloc] initWithPicture:@"fav-aqua"];
                pinTexture = @"fav-aqua";
                break;
            case 1:
                //sprite = [[GlSprite alloc] initWithPicture:@"fav-blue-aqua"];
                pinTexture = @"fav-blue-aqua";
                break;
            case 2:
                //sprite = [[GlSprite alloc] initWithPicture:@"fav-blue-pink"];
                pinTexture = @"fav-blue-pink";
                break;
            case 3:
                //sprite = [[GlSprite alloc] initWithPicture:@"fav-blue"];
                pinTexture = @"fav-blue";
                break;
            case 4:
                //sprite = [[GlSprite alloc] initWithPicture:@"fav-green-yellow"];
                pinTexture = @"fav-green-yellow";
                break;
            case 5:
                //sprite = [[GlSprite alloc] initWithPicture:@"fav-green"];
                pinTexture = @"fav-green";
                break;
            case 6:
                //sprite = [[GlSprite alloc] initWithPicture:@"fav-pink-blue"];
                pinTexture = @"fav-pink-blue";
                break;
            case 7:
                //sprite = [[GlSprite alloc] initWithPicture:@"fav-pink"];
                pinTexture = @"fav-pink";
                break;
            case 8:
                //sprite = [[GlSprite alloc] initWithPicture:@"fav-red-pink"];
                pinTexture = @"fav-red-pink";
                break;
            case 9:
                //sprite = [[GlSprite alloc] initWithPicture:@"fav-red-yellow"];
                pinTexture = @"fav-red-yellow";
                break;
            case 10:
                //sprite = [[GlSprite alloc] initWithPicture:@"fav-red"];
                pinTexture = @"fav-red";
                break;
            case 11:
                //sprite = [[GlSprite alloc] initWithPicture:@"fav-yell"];
                pinTexture = @"fav-yell";
                break;
        }
        //sp = [[BigPanel alloc] initWithText:text];
        pinText = [text retain];
        _loaded = NO;
    }
    return self;
}

-(void)load
{
    if(!_loaded) {
        sprite = [[GlSprite alloc] initWithPicture:pinTexture];
        _loaded = YES;
    }
}

-(void)unload
{
    [sprite release];
    sprite = nil;
    _loaded = NO;
}

-(void)loadPanel
{
    if(nil == sp) {
        if(nil != pinSubtitle) {
            sp = [[BigPanel alloc] initWithText:pinText andSubtitle:pinSubtitle];
        } else {
            sp = [[BigPanel alloc] initWithText:pinText];
        }
    }
}

-(void)unloadPanel
{
    [sp release];
    sp = nil;
}

-(void)setPosition:(CGPoint)point
{
    pos = point;
    sp.position = point;
}

-(void)setGeoPosition:(CGPoint)geoPoint
{
    geoPos = geoPoint;
    [self setPosition:translateFromGeoToMap(geoPoint)];
    [self updateDistanceToUser];
}

-(void)updateDistanceToUser
{
    // distance from user to pin
    if(!CGPointEqualToPoint(geoPos, CGPointZero) && !CGPointEqualToPoint(userGeoPosition, CGPointZero))
        distanceToUser = calcGeoDistanceFrom(geoPos, userGeoPosition);
    else
        distanceToUser = 0;
}

-(CGPoint)position
{
    return pos;
}


-(CGPoint)geoPosition
{
    return geoPos;
}

//-(void)draw
//{
//    if(!_loaded) [self load];
//    CGSize s;
//    s.width = size * sprite.origWidth;
//    s.height = size * sprite.origHeight;
//    if(rotation != 0) {
//        [sprite setRect:CGRectMake(pos.x-s.width*0.5f, pos.y-s.height*0.5f-offset-constOffset, s.width, s.height) withRotation:rotation];
//    } else {
//        [sprite setRect:CGRectMake(pos.x-s.width*0.5f, pos.y-s.height*0.5f-offset-constOffset, s.width, s.height)];
//    }
//    [sprite draw];
//    [sp drawWithScale:1.f];
//}

-(void)drawWithScale:(CGFloat)scale
{
    if(!_loaded) [self load];
    lastScale = scale;
    CGSize s;
    s.width = size * sprite.origWidth / scale;
    s.height = size * sprite.origHeight / scale;
    if(rotation != 0) {
        [sprite setRect:CGRectMake(pos.x-s.width*0.5f, pos.y-s.height*0.5f-offset-constOffset/scale, s.width, s.height) withRotation:rotation];
    } else {
        [sprite setRect:CGRectMake(pos.x-s.width*0.5f, pos.y-s.height*0.5f-offset-constOffset/scale, s.width, s.height)];
    }
    sprite.alpha = alpha;
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
    if(alphaSpeed > 0.f) {
        if(alpha < targetAlpha) {
            alpha += dTime * alphaSpeed;
            if(alpha >= targetAlpha) {
                alpha = targetAlpha;
                alphaSpeed = 0.f;
            }
        } else if(alpha > targetAlpha) {
            alpha -= dTime * alphaSpeed;
            if(alpha <= targetAlpha) {
                alpha = targetAlpha;
                alphaSpeed = 0.f;
            }
        } else {
            alphaSpeed = 0.f;
        }
    }
    [sp update:dTime];
}

-(void)fallFrom:(CGFloat)distance at:(CGFloat)spd
{
    offset = distance;
    speed = spd;
}

-(void)fadeIn:(CGFloat)time
{
    targetAlpha = 1.f;
    alpha = 0.f;
    alphaSpeed = 1.f / time;
}

-(void)fadeOut:(CGFloat)time
{
    targetAlpha = 0.f;
    alphaSpeed = 1.f / time;
}

-(CGRect)bounds
{
    CGFloat ssize = 32.f / lastScale;
    const CGFloat s2 = ssize * 0.5f;
    return CGRectMake(pos.x-s2, pos.y-s2-offset, ssize, ssize);
}

-(void)dealloc
{
    [pinTexture release];
    [pinText release];
    [pinSubtitle release];
    [sp release];
    [sprite release];
    [super dealloc];
}

@end

@implementation GlViewController

@synthesize context = _context;
//@synthesize effect = _effect;
@synthesize currentSelection;
@synthesize navigationViewController;
@synthesize followUserGPS;
@synthesize searchResults = lastSearchResults;
@synthesize glView;


- (CGFloat)distanceToMapCenter {
    return [self calcGeoDistanceFrom:userGeoPosition to:[self getCenterMapGeoCoordinates]];
}

- (CGFloat) radialOffsetToMapCenter {
    return [self radialOffsetToPoint:[self getCenterMapGeoCoordinates]];
}

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
    backgroundThreadShouldFinish = YES;
    [secondContext release];
    self.pinsArray = nil;
    [_context release];
    //[_effect release];
    [rasterLayer release];
    self.clusters = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    shouldUpdatePinsForLevel = -1;
    followUserGPS = YES;
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];

    self.pinsArray = @[];
    self.clusters = @[];
    objectsLOD = -1;

    CGRect settingsRect,zonesRect,cornerRect;
    
    //settingsRect=CGRectMake(285, 420, 27, 27);
    if ([appDelegate isIPHONE5]) {
        zonesRect=CGRectMake(250, 498, 71, 43);
        cornerRect=CGRectMake(0, 489, 36, 60);
    }
    else {
        zonesRect=CGRectMake(250, 410, 71, 43);
        cornerRect=CGRectMake(0, 401, 36, 60);
    }
    
    if (IS_IPAD) {
        //settingsRect=CGRectMake(-285, -420, 27, 27);
        zonesRect=IPAD_CITYMAP_ZONES_RECT;

        //zonesRect=CGRectMake(self.view.bounds.size.width-70, self.view.bounds.size.height-50, 43, 25);
    } else {
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            CGFloat sc = [UIScreen mainScreen].scale;
            result = CGSizeMake(result.width * sc, result.height * sc);
            
            if(result.height == 1136){
                //settingsRect=CGRectMake(285, 508, 27, 27);
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
    
    glView.context = self.context;
    glView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    UIPanGestureRecognizer *rec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [glView addGestureRecognizer:rec];
    UITapGestureRecognizer *rec2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    rec2.numberOfTapsRequired = 2;
    rec2.numberOfTouchesRequired = 1;
    [glView addGestureRecognizer:rec2];
    UIPinchGestureRecognizer *rec3 = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [glView addGestureRecognizer:rec3];
    UITapGestureRecognizer *rec4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    rec4.numberOfTapsRequired = 1;
    rec4.numberOfTouchesRequired = 1;
    [glView addGestureRecognizer:rec4];
    [self setupGL];
    
    rasterLayer = [[RasterLayer alloc] initWithRect:CGRectMake(0, 0, 256, 256) mapName:@"cuba"];
    //[rasterLayer setSignal:self selector:@selector(redrawRect:)];
    
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
    [glView addSubview:sourceData];

//    zones = [UIButton buttonWithType:UIButtonTypeCustom];
//    if(IS_IPAD){
//        [zones setImage:[UIImage imageNamed:@"metro-button"] forState:UIControlStateNormal];
//        [zones setImage:[UIImage imageNamed:@"metro-button"] forState:UIControlStateHighlighted];
//        zones.frame = zonesRect;
//    }else{
//        [zones setImage:[UIImage imageNamed:@"bt_mode_metro_up"] forState:UIControlStateNormal];
//        [zones setImage:[UIImage imageNamed:@"bt_mode_metro"] forState:UIControlStateHighlighted];
//        zones.frame = zonesRect;
//    }
//    
//    [zones addTarget:self action:@selector(changeZones) forControlEvents:UIControlEventTouchUpInside];
//    [glView addSubview:zones];
//    glView.zonesButton = zones;

    
    cornerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cornerButton setImage:[UIImage imageNamed:@"bt_corner"] forState:UIControlStateNormal];
    [cornerButton setFrame:zonesRect];
    [cornerButton addTarget:self action:@selector(showSettings) forControlEvents:UIControlEventTouchUpInside];

    [glView addSubview:cornerButton];
    
    // user geo position
    Pin *p = [[Pin alloc] initUserPos];
    self.pinsArray = [_pinsArray arrayByAddingObject:p];
    [p setPosition:userPosition];
    newPinId = 1;
    
    [self enableUserLocation];
    
    secondContext = [[EAGLContext alloc] initWithAPI:glView.context.API sharegroup:glView.context.sharegroup];
    backgroundThreadShouldFinish = NO;
    [NSThread detachNewThreadSelector:@selector(backgroundThreadWithContext:) toTarget:self withObject:secondContext];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self loadObjectsOnScreen];
}

- (void) moveModeButtonToFullScreen {
    CGRect zonesRect, cornerRect;
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ([appDelegate isIPHONE5]) {
        zonesRect=CGRectMake(250, 498, 71, 43);
        cornerRect=CGRectMake(0, 489, 36, 60);
    } else if (IS_IPAD)  {
        cornerRect=CGRectMake(0, 945, 36, 60);
        zonesRect=IPAD_CITYMAP_ZONES_RECT;
    } else {
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
        cornerRect=CGRectMake(0, 945, 36, 60);
        zonesRect=IPAD_CITYMAP_ZONES_RECT;
        
    }else {
        zonesRect=CGRectMake(250, 410, 71, 43);
        cornerRect=CGRectMake(0, 401, 36, 60);
    }
    
    if ([appDelegate isIPHONE5]) {
        zonesRect.origin.y -= 423;
        cornerRect.origin.y -= 423;
    }else{
    if (IS_IPAD)  {
        zonesRect.origin.y -= 774;
        cornerRect.origin.y -= 774;
    } else {
        zonesRect.origin.y -= 335;
        cornerRect.origin.y -= 335;
    }
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
    [appDelegate showSettings];
}

- (void)showPurchases:(int)index
{
    if (IS_IPAD)
        [self showiPadPurchases:index];
    else
    {
        tubeAppDelegate *appDelegate = (tubeAppDelegate *) [[UIApplication sharedApplication] delegate];
        [appDelegate.navigationViewController showPurchases:index];
    }
}

-(void)showiPadSettingsModalView
{
    if (popover) [popover dismissPopoverAnimated:YES];
    
    SettingsViewController *controller = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:[NSBundle mainBundle]];
    controller.delegate=self;
    UINavigationController *navcontroller = [[UINavigationController alloc] initWithRootViewController:controller];
    navcontroller.modalPresentationStyle=UIModalPresentationFormSheet;
    [self presentViewController:navcontroller animated:YES completion:nil];

    [controller release];
    [navcontroller release];
}


-(void)showiPadPurchases:(int)index
{
    if (popover) [popover dismissPopoverAnimated:YES];
    
    SettingsViewController *controller = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:[NSBundle mainBundle]];
    controller.purchaseIndex = index;
    controller.delegate=self;
    UINavigationController *navcontroller = [[UINavigationController alloc] initWithRootViewController:controller];
    navcontroller.modalPresentationStyle=UIModalPresentationFormSheet;
    [self presentViewController:navcontroller animated:YES completion:nil];
    
    [controller release];
    [navcontroller release];
}

-(void)donePressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
            
            [self loadObjectsOnScreen];
            [self sendMapMovedNotification];
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        default:
            position = prevPosition;
            break;
    }
    followUserGPS = NO;
}

-(void)handleDoubleTap:(UITapGestureRecognizer*)recognizer
{
    scale *= 1.5f;
    panVelocity = CGPointZero;
    //[self setGeoPosition:userGeoPosition withZoom:-1];
    
    [self sendMapMovedNotification];
    shouldUpdatePinsForLevel = [self getLevelForScale:scale];
}

-(void)handleSingleTap:(UITapGestureRecognizer*)recognizer
{
    //NSArray *sorted = [objectsTypes sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    //NSLog(@"%@", sorted);
    [self.view.superview.superview endEditing:YES];
    if(recognizer.state != UIGestureRecognizerStateEnded) return;
    CGPoint p = [recognizer locationInView:self.view];
    float x = (p.x - self.view.bounds.size.width*0.5f)/scale + 128 - position.x, y = (p.y - self.view.bounds.size.height*0.5f)/scale + 128 - position.y;
    NSMutableArray *selected = [NSMutableArray array];
    for (Pin *pin in _pinsArray) {
        CGRect r = [pin bounds];
        if(CGRectContainsPoint(r, CGPointMake(x, y))) {
            [selected addObject: pin];
        } else if(pin.active) {
            pin.active = NO;
        }
    }
    for (Pin *pin in _pinsArray) if(pin.active) {
        pin.active = NO;
    }
    if([selected count] > 0) {
        // select one lucky pin
        [[selected objectAtIndex:0] setActive:YES];
        int pid = [[selected objectAtIndex:0] Id];
        tubeAppDelegate *delegate = (tubeAppDelegate*)[UIApplication sharedApplication].delegate;
        if(objectsLOD == 0) {
            for (Cluster *cl in _clusters) {
                for (Object *ob in cl.objects) {
                    if(ob.pinID == pid) {
                        [delegate selectObject:ob];
                    }
                }
            }
        } else if(objectsLOD == 1) {
            for (Cluster *cl in _clusters) {
                if(cl.pinID == pid) {
                    [delegate selectCluster:cl];
                }
            }
        }
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
        case UIGestureRecognizerStateChanged: {
            CGFloat sc2 = prevScale * recognizer.scale / prevRecScale;
            if([rasterLayer checkLevel:sc2]) scale = sc2;
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
            //position.x = prevPosition.x + (dp.x - prevDp.x) / scale;
            //position.y = prevPosition.y + (dp.y - prevDp.y) / scale;
        }
            break;
        case UIGestureRecognizerStateEnded:
            if(scale > 100000) {
                scale = 100000;
            }
            prevRecScale = 0.f;
            started = NO;
            
            [self sendMapMovedNotification];
            shouldUpdatePinsForLevel = [self getLevelForScale:scale];
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

-(void)sendMapMovedNotification
{
    CGPoint coords = [self getCenterMapGeoCoordinates];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kMapMoved" object:
     [NSArray arrayWithObjects:[NSNumber numberWithFloat:coords.x], [NSNumber numberWithFloat:coords.y],nil]];
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
    [rasterLayer purgeUnusedCache];
    for (Pin *p in self.pinsArray) {
        [p unload];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown;
        
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
    
    -(void)backgroundThreadWithContext:(EAGLContext*)context
    {
        [EAGLContext setCurrentContext:context];
        while (!backgroundThreadShouldFinish) {
            if(shouldUpdatePinsForLevel >= 0) {
                [self updatePinsForLevel:[NSNumber numberWithInt:shouldUpdatePinsForLevel]];
                shouldUpdatePinsForLevel = -1;
            }
            [NSThread sleepForTimeInterval:0.1f];
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
    [self dismissViewControllerAnimated:YES completion:nil];
    [self performSelector:@selector(returnFromSelection2:) withObject:stations afterDelay:0.1];
    //((MainView*)self.view).shouldNotDropPins = NO;
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
    self.pinsArray = [_pinsArray arrayByAddingObject:p];
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
    self.pinsArray = [_pinsArray arrayByAddingObject:p];
    [p setGeoPosition:coordinate];
    return p.distanceToUser;
}

-(int)newPin:(CGPoint)coordinate color:(int)color name:(NSString*)name
{
    return [self newPin:coordinate color:color name:name subtitle:nil];
}

-(int)newPin:(CGPoint)coordinate color:(int)color name:(NSString *)name subtitle:(NSString*)subtitle
{
    int newId = newPinId;
    newPinId ++;
    Pin *p = nil;
    if(nil != subtitle) {
        p = [[Pin alloc] initWithId:newId color:color text:name andSubtitle:subtitle];
    } else if(name != nil) {
        p = [[Pin alloc] initWithId:newId color:color andText:name];
    } else {
        p = [[Pin alloc] initWithId:newId andColor:color];
    }
    //float dist = 256.f/scale;
    //[p fallFrom:(dist * (1.f+0.05f*(rand()%20))) at: dist*2];
    [p fadeIn:0.5f];
    self.pinsArray = [_pinsArray arrayByAddingObject:p];
    [p setPosition:coordinate];
    return newId;
}

-(int)newStar:(CGPoint)coordinate color:(int)color name:(NSString*)name
{
    int newId = newPinId;
    newPinId ++;
    Pin *p = [[Pin alloc] initClusterWithId:newId color:color andText:name];
    [p fadeIn:0.5f];
    self.pinsArray = [_pinsArray arrayByAddingObject:p];
    [p setPosition:coordinate];
    return newId;
}

-(void)removePin:(int)pinId
{
    self.pinsArray = [_pinsArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject Id] != pinId;
    }]];
}

-(void)removeAllPins
{
    Pin *p = [self getPin:0];
    if(nil == p) {
        self.pinsArray = @[];
    } else {
        self.pinsArray = @[p];
    }
}

-(int)setLocation:(CGPoint)coordinate
{
    for (Pin *p in _pinsArray) {
        if(p.Id == -1) {
            [p setGeoPosition:coordinate];
            return -1;
        }
    }
    Pin *loc = [[[Pin alloc] initObjectPos] autorelease];
    [loc setGeoPosition:coordinate];
    self.pinsArray = [_pinsArray arrayByAddingObject:loc];
    return -1;
}

-(Pin*)getPin:(int)pinId
{
    for (Pin *p in _pinsArray) {
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
            [self loadObjectsOnScreen];
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
    for (Pin *p in _pinsArray) {
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
    CGRect r = CGRectMake(128 - position.x - W2/scale, 128 - position.y - H2/scale, W/scale, H/scale);
    [rasterLayer drawGlInRect:r withScale:sc];
    
    [self drawPinsInRect:r];
}

-(void)drawPinsInRect:(CGRect)r
{
    for (Pin *p in _pinsArray) {
        if(CGRectContainsPoint(r, p.position)) [p drawWithScale:scale];
    }
    for (Pin *p in _pinsArray) if(CGRectContainsPoint(r, p.position) && p.active) {
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

#pragma mark - Geo coordinates

-(void)setGeoPosition:(CGRect)rect
{
    if(CGRectEqualToRect(rect, CGRectZero)) {
        position = CGPointZero;
        scale = 1.f;
        return;
    }
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
    scale = MIN(256.f / r.size.height, 256.f / rect.size.width);
    targetTimer = 0.f;

    [self loadObjectsOnScreen];
    [self sendMapMovedNotification];
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

    [self loadObjectsOnScreen];
    [self sendMapMovedNotification];
}

-(void)scrollToGeoPosition:(CGPoint)geoCoords withZoom:(CGFloat)zoom
{
    if(CGPointEqualToPoint(position, CGPointZero)) {
        [self setGeoPosition:geoCoords withZoom:zoom];
        return ;
    }
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
    
    [self sendMapMovedNotification];
}

-(void)setUserGeoPosition:(CGPoint)point
{
    userGeoPosition = point;
    for (Pin *p in _pinsArray) {
        [p updateDistanceToUser];
    }
    CGPoint up = translateFromGeoToMap(point);
    userPosition = up;
    Pin *p = [_pinsArray objectAtIndex:0];
    if(p != nil) [p setPosition:up];
    if(followUserGPS) [self setGeoPosition:userGeoPosition withZoom:1 << LEVEL_WIFI_POINT];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"distanceUpdated" object:nil];

}

-(void)setUserHeading:(double)heading
{
    Pin *p = [_pinsArray objectAtIndex:0];
    if(p != nil) [p setRotation:-(heading / 180.0 * M_PI)];
}

- (void) centerMapOnUser {
    followUserGPS = YES;
    if(CGPointEqualToPoint(position, CGPointZero)) [self setGeoPosition:userGeoPosition withZoom:-1];
    else [self scrollToGeoPosition:userGeoPosition withZoom:-1];
}


-(void)setStationsPosition:(NSArray *)data withMarks:(BOOL)marks
{
    [self removeAllPins];
    for (int i=0; i<[data count]; i++) {
        CGRect r = [[[data objectAtIndex:i] valueForKey:@"coordinate" ] CGRectValue];
        [self newPin:r.origin color:[[[data objectAtIndex:i] valueForKey:@"pinColor"] intValue] name:[[data objectAtIndex:i] valueForKey:@"name"]];
        if([[[data objectAtIndex:i] valueForKey:@"ending" ] length] > 0) {
        //if(marks && (i == 0 || i == [coords count]-1)) {
            [[_pinsArray lastObject] setActive:YES];
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

-(CGPoint)getCenterMapGeoCoordinates
{
    CGPoint gps = translateFromMapToGeo(position);
    return gps;
}

-(void)purgeUnusedCache
{
    [rasterLayer purgeUnusedCache];
}

-(void)loadObjectsOnScreen
{
    if([self getLevelForScale:scale] < LEVEL_WIFI_CLUSTER) return;
    CGRect frame;
    frame.origin = position;
    frame.size = self.view.frame.size;
    frame.size.width /= scale;
    frame.size.height /= scale;
    frame.origin.x -= frame.size.width * 0.5f;
    frame.origin.y -= frame.size.height * 0.5f;
    [self loadObjectsForRect:frame];
    frame.origin.x = 128.f - frame.origin.x;
    frame.origin.y = 128.f - frame.origin.y;
    [self unloadFarObjectsFromRect:frame];
}

-(void)loadObjectsForRect:(CGRect)rect
{
    NSString *url=[NSString stringWithFormat:@"http://5.175.192.184/index.php?x1=%f&y1=%f&x2=%f&y2=%f", rect.origin.x, rect.origin.y, rect.origin.x+rect.size.width, rect.origin.y+rect.size.height];
    
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [NSURLConnection sendAsynchronousRequest:theRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if(nil != error) {
            NSLog(@"Load objects error: %@", error);
        } else {
            NSError *err = nil;
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &err];
            if (!jsonArray) {
                NSLog(@"Error parsing JSON: %@", err);
            } else {
                NSInteger counter = 0;
                for(NSDictionary *item in jsonArray) {
//                    if (counter == 100) {
//                        break;
//                    }
                    counter++;
                    Object *ob = [[Object alloc] initWithDictionary:item];
                    BOOL accepted = NO;
                    for (Cluster* cl in _clusters) {
                        if([cl accept:ob]) {
                            accepted = YES;
                            break;
                        }
                    }
                    if(!accepted) {
                        Cluster *cl = [[Cluster alloc] initWithRadius:0.03f];
                        self.clusters = [self.clusters arrayByAddingObject:cl];
                        [[_clusters lastObject] accept:ob];
                        [cl release];
                    }
                    [ob release];
                    //NSLog(@" %@", ob);
                }
                NSLog(@"Updated spots. %i of them!", counter);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"distanceUpdated" object:nil];
            }
            shouldUpdatePinsForLevel = [self getLevelForScale:scale];
        }
        
    }];
}

-(void)unloadFarObjectsFromRect:(CGRect)rect
{
    CGRect r = rect;
    r.origin.x -= r.size.width;
    r.origin.y -= r.size.height;
    r.size.width *= 3;
    r.size.height *= 3;
    for(Cluster* cl in _clusters) {
        if(!CGRectContainsPoint(r, cl.center)) {
            if(cl.pinID > 0) {
                [self removePin:cl.pinID];
            }
            for (Object *o in cl.objects) {
                if(o.pinID > 0)
                    [self removePin:o.pinID];
            }
        }
    }
    self.clusters = [_clusters filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return CGRectContainsPoint(r,  [((Cluster*)evaluatedObject) center]);
    }]];
}

-(void)updatePinsForLevel:(NSNumber*)nLevel
{
    int level = nLevel.intValue;
    int newObjectsLOD = -1;
    if(level > LEVEL_WIFI_POINT) {
        newObjectsLOD = 0;
    } else if(level > LEVEL_WIFI_CLUSTER) {
        newObjectsLOD = 1;
    } else {
        newObjectsLOD = 2;
    }
    if(objectsLOD == newObjectsLOD) {
        switch (objectsLOD) {
            default:
            case -1:
                break;
            case 0:
                // show objects
                for (Cluster *cl in _clusters) {
                    for (Object *ob in cl.objects) {
                        if(ob.pinID < 0) {
                            ob.pinID = [self newPin:ob.coords color:1 name:ob.title subtitle:[ob.comments firstObject]];
                            Pin *p = [self getPin:ob.pinID];
                            [p setGeoPosition:ob.geoP];
                        }
                    }
                }
                break;
            case 1:
                // show clusters
                for (Cluster *cl in _clusters) {
                    if(cl.pinID < 0)
                        cl.pinID = [self newStar:cl.center color:1 name:cl.title];
                }
                break;
            case 2:
                break;
        }
        return;
    }
    switch (objectsLOD) {
        case -1:
        default:
            // initial state, no any objects
            break;
        case 0:
            // show objects
            [self removeAllPins];
            for (Cluster *cl in _clusters) {
                for (Object *ob in cl.objects) {
                    ob.pinID = -1;
                }
            }
            break;
        case 1:
            // show clusters
            [self removeAllPins];
            for (Cluster *cl in _clusters) {
                cl.pinID = -1;
            }
            break;
        case 2:
            // don't show anything
            break;
    }
    switch (newObjectsLOD) {
        case -1:
        default:
            // initial state, no any objects
            break;
        case 0:
            // show objects
            for (Cluster *cl in _clusters) {
                for (Object *ob in cl.objects) {
                    ob.pinID = [self newPin:ob.coords color:1 name:ob.title subtitle:[ob.comments firstObject]];
                    Pin* p = [self getPin:ob.pinID];
                    [p setGeoPosition:ob.geoP];
                }
            }
            break;
        case 1:
            // show clusters
            for (Cluster *cl in _clusters) {
                cl.pinID = [self newStar:cl.center color:1 name:cl.title];
            }
            break;
        case 2:
            // don't show anything
            break;
    }
    objectsLOD = newObjectsLOD;
}

-(int)getLevelForScale:(CGFloat)sc
{
    int _sc = 1, _lvl = 0;
    while (sc > _sc) {
        _sc *= 2;
        _lvl ++;
    }
    return _lvl;
}

-(NSArray*)getObjectsNear:(CGPoint)center withRadius:(CGFloat)radius
{
    NSMutableArray *result = [NSMutableArray array];
    CGFloat r2 = radius*radius;
    for (Cluster *cl in _clusters) {
        CGFloat len2 = sqr(cl.center.x-center.x) + sqr(cl.center.y-center.y);
        if(len2 <= (cl.radius*cl.radius + r2)) {
            for (Object *ob in cl.objects) {
                CGFloat olen2 = sqr(ob.coords.x-center.x) + sqr(ob.coords.y-center.y);
                if(olen2 <= r2) [result addObject:ob];
            }
        }
    }
    return [NSArray arrayWithArray:result];
}

-(NSArray*)getObjectsNearUserWithRadius:(CGFloat)radius
{
    return [self getObjectsNear:userPosition withRadius:radius];
}

#pragma mark gps stuff
-(BOOL) enableUserLocation
{
    BOOL result = NO;
    [locationManager release];
    locationManager = nil;
    if([CLLocationManager locationServicesEnabled]) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        locationManager.distanceFilter = 500;
        [locationManager startUpdatingLocation];
        result = YES;
    } else result = NO;
    if([CLLocationManager headingAvailable]) {
        locationManager.headingFilter = kCLHeadingFilterNone;
        [locationManager startUpdatingHeading];
#ifdef DEBUG
        NSLog(@"Good news: magnetometer have found!");
#endif
    } else {
#ifdef DEBUG
        NSLog(@"Sorry: there aren't any magnetometer in the device.");
#endif  
    }
    return result;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CGPoint curPos = CGPointMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    [(tubeAppDelegate*)[[UIApplication sharedApplication] delegate] setUserGeoPosition:curPos];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    CLLocationDirection dir = 0;
    if(newHeading.trueHeading >= 0) dir = newHeading.trueHeading;
    else dir = newHeading.magneticHeading;
    switch ([UIApplication sharedApplication].statusBarOrientation) {
        default:
        case UIInterfaceOrientationPortrait:
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            dir -= 190;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            dir -= 90;
            break;
        case UIInterfaceOrientationLandscapeRight:
            dir += 90;
            break;
    }
    
    [(tubeAppDelegate*)[[UIApplication sharedApplication] delegate] setUserHeading:dir];
}

-(void)loadCitiesLikeThis:(NSString*)cityName
{
    NSString *lang = @"en_EN";
    NSArray *langs = [[NSBundle mainBundle] preferredLocalizations];
    if([langs count] > 0) lang = langs[0];
    NSString *url = [NSString stringWithFormat:@"http://nominatim.openstreetmap.org/search?q=%@&format=json&accept-language=%@&email=zuev.sergey@gmail.com", [cityName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],  lang];
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60.0];
    [NSURLConnection sendAsynchronousRequest:theRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if(nil != error) {
            NSLog(@"Error during search a city: %@", error);
        } else {
            NSError *err = nil;
            id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
            if(nil != err) {
                NSLog(@"Error while parsing JSON: %@", err);
            } else {
                if(nil == lastSearchResults) lastSearchResults = [[NSMutableArray alloc] init];
                else [lastSearchResults removeAllObjects];
                for (NSDictionary *pl in result) {
                    if([pl[@"class"] isEqualToString:@"place"]) {
                        [lastSearchResults addObject:@{@"lat": [NSNumber numberWithFloat:[pl[@"lat"] floatValue]],
                         @"lon": [NSNumber numberWithFloat:[pl[@"lon"] floatValue]],
                         @"type": pl[@"type"],
                         @"name": pl[@"display_name"]}];
                    }
                }
//                if([lastSearchResults count] > 0) {
//                    NSDictionary *firstObject = [lastSearchResults objectAtIndex:0];
//                    [self scrollToGeoPosition:CGPointMake([firstObject[@"lat"] floatValue], [firstObject[@"lon"] floatValue]) withZoom:-1];
//                }
#ifdef DEBUG
                NSLog(@"I've got a list of cities: %@", lastSearchResults);
#endif
                [[NSNotificationCenter defaultCenter] postNotificationName:nSEARCH_RESULTS_READY object:lastSearchResults];
            }
        }
    }];
}

-(void)downloadVisibleMap:(NSInteger)depth withOffset:(NSInteger)offset
{
    int _sc = 1, _lvl = 0;
    while (scale > _sc) {
        _sc *= 2;
        _lvl ++;
    }
    float W = self.view.bounds.size.width, W2 = W*0.5f, H = self.view.bounds.size.height, H2 = H*0.5f;
    CGFloat off = offset/scale;
    CGRect frame = CGRectMake(128 - position.x - W2/scale - off, 128 - position.y - H2/scale - off, W/scale + 2.f*off, H/scale + 2.f*off);
    [rasterLayer downloadToCache:frame fromScale:_lvl toScale:_lvl+depth];
}
    
@end

void SetColor(float r, float g, float b, float a) {
    glUniform4f(uniforms[UNIFORM_COLOR], r, g, b, a);
}

void ResetColor() {
    glUniform4f(uniforms[UNIFORM_COLOR], 1.f, 1.f, 1.f, 1.f);
}
