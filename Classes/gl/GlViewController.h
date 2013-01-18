//
//  GlViewController.h
//  test
//
//  Created by Vasiliy Makarov on 22.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "FastAccessTableViewController.h"
#import "ManagedObjects.h"
#import "GlSprite.h"
#import "GlPanel.h"
#import "TopTwoStationsView.h"

@interface Pin : NSObject {
    int _id;
    CGPoint pos;
    GlSprite *sprite;
    SmallPanel *sp;
    CGFloat size;
    CGFloat offset, speed;
    float lastScale;
    float distanceToUser;
}

@property (nonatomic, readonly) int Id;
@property (nonatomic, readonly) CGPoint position;
@property (nonatomic, assign) BOOL active;
@property (nonatomic, assign) CGFloat distanceToUser;

-(id)initWithId:(int)pinId andColor:(int)color;
-(void)draw;
-(void)drawWithScale:(CGFloat)scale;
-(void)drawPanelWithScale:(CGFloat)scale;
-(void)fallFrom:(CGFloat)distance at:(CGFloat)speed;
-(CGRect)bounds;
@end

@interface GlViewController : GLKViewController <TwoStationsViewProtocol>

@property (nonatomic, assign) MStation *currentSelection;
@property (nonatomic, retain) MStation *fromStation;
@property (nonatomic, retain) MStation *toStation;
@property (nonatomic, retain) TopTwoStationsView *stationsView;

-(FastAccessTableViewController*)showTableView;
-(void)returnFromSelectionFastAccess:(NSArray *)stations;
-(void)setGeoPosition:(CGRect)rect;
-(void)setGeoPosition:(CGPoint)geoCoords withZoom:(CGFloat)zoom;
-(void)setUserGeoPosition:(CGPoint)point;
-(void)setStationsPosition:(NSArray*)coords withNames:(NSArray*)names andMarks:(BOOL)marks;
-(void)errorWithGeoLocation;
-(int)newPin:(CGPoint)coordinate color:(int)color name:(NSString*)name;
-(void)removePin:(int)pinId;
-(void)removeAllPins;
-(Pin*)getPin:(int)pinId;
-(void) showSettings;

@end
