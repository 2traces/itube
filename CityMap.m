//
//  CityMap.m
//  tube
//
//  Created by Alex 1 on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CityMap.h"
#include "ini.h"
#import "ManagedObjects.h"
#import <CoreLocation/CoreLocation.h>

CGFloat PredrawScale = 2.f;
CGFloat LineWidth = 4.f;
CGFloat StationDiameter = 8.f;
StationKind StKind = LIKE_PARIS;
StationKind TrKind = LIKE_PARIS;

NSMutableArray * Split(NSString* s)
{
    NSMutableArray *res = [[[NSMutableArray alloc] init] autorelease];
    NSRange range = NSMakeRange(0, [s length]);
    while (YES) {
        NSUInteger comma = [s rangeOfString:@"," options:0 range:range].location;
        NSUInteger bracket = [s rangeOfString:@"(" options:0 range:range].location;
        if(comma == NSNotFound) {
            if(bracket != NSNotFound) range.length --;
            [res addObject:[s substringWithRange:range]];
            break;
        } else {
            if(bracket == NSNotFound || bracket > comma) {
                comma -= range.location;
                [res addObject:[s substringWithRange:NSMakeRange(range.location, comma)]];
                range.location += comma+1;
                range.length -= comma+1;
            } else {
                NSUInteger bracket2 = [s rangeOfString:@")" options:0 range:range].location;
                bracket2 -= range.location;
                [res addObject:[s substringWithRange:NSMakeRange(range.location, bracket2)]];
                range.location += bracket2+2;
                range.length -= bracket2+2;
            }
        }
    }
    return res;
}

CGFloat Sql(CGPoint p1, CGPoint p2)
{
    CGFloat dx = p1.x-p2.x;
    CGFloat dy = p1.y-p2.y;
    return dx*dx + dy*dy;
}

// CG Helpres
void drawLine(CGContextRef context, CGFloat x1, CGFloat y1, CGFloat x2, CGFloat y2, int lineWidth) {
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetLineWidth(context, lineWidth);
	CGContextMoveToPoint(context, x1, y1);
	CGContextAddLineToPoint(context, x2, y2);
	CGContextStrokePath(context);
}

void drawFilledCircle(CGContextRef context, CGFloat x, CGFloat y, CGFloat r) {
	// Draw a circle (filled)
	CGContextFillEllipseInRect(context, CGRectMake(x-r, y-r, 2*r, 2*r));
}

@implementation Transfer

@synthesize stations;
@synthesize time;
@synthesize boundingBox;
@synthesize active;

-(id)init
{
    if((self = [super init])) {
        stations = [[NSMutableSet alloc] init];
        boundingBox = CGRectNull;
        time = 0;
        transferLayer = nil;
        active = YES;
    }
    return self;
}

-(void)dealloc
{
    [stations release];
    CGLayerRelease(transferLayer);
}

-(void)addStation:(Station *)station
{
    if(station.transfer == self) return;
    NSAssert(station.transfer == nil, @"Station already in transfer");
    if([stations count] > 0) station.drawName = NO;
    station.transfer = self;
    [stations addObject:station];
    CGRect st = CGRectMake(station.pos.x - StationDiameter, station.pos.y - StationDiameter, StationDiameter*2.f, StationDiameter*2.f);
    if(CGRectIsNull(boundingBox)) boundingBox = st;
    else boundingBox = CGRectUnion(boundingBox, st);
}

+(void) drawTransferLikeLondon:(CGContextRef) context stations:(NSArray*)stations
{
    CGFloat blackW = StationDiameter / 5.f;
    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);				
    for(int i = 0; i<[stations count]; i++) {
        Station *st = [stations objectAtIndex:i];
        CGPoint p1 = st.pos;
        drawFilledCircle(context, p1.x, p1.y, StationDiameter);
        for(int j = i+1; j<[stations count]; j++) {
            Station *st2 = [stations objectAtIndex:j];
            CGPoint p2 = st2.pos;
            drawLine(context, p1.x, p1.y, p2.x, p2.y, StationDiameter*0.5f);
        }
    }
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    for(int i = 0; i<[stations count]; i++) {
        Station *st = [stations objectAtIndex:i];
        CGPoint p1 = st.pos;
        drawFilledCircle(context, p1.x, p1.y, StationDiameter - blackW);
        for(int j = i+1; j<[stations count]; j++) {
            Station *st2 = [stations objectAtIndex:j];
            CGPoint p2 = st2.pos;
            drawLine(context, p1.x, p1.y, p2.x, p2.y, StationDiameter*0.5f - blackW);
        }
    }
}

+(void) drawTransferLikeParis:(CGContextRef)context stations:(NSArray*)stations
{
    CGFloat blackW = LineWidth / 3.f;
    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);				
    for(int i = 0; i<[stations count]; i++) {
        Station *st = [stations objectAtIndex:i];
        CGPoint p1 = st.pos;
        for(int j = i+1; j<[stations count]; j++) {
            Station *st2 = [stations objectAtIndex:j];
            CGPoint p2 = st2.pos;
            CGFloat dx = (p1.x-p2.x);
            CGFloat dy = (p1.y-p2.y);
            CGFloat d2 = dx*dx + dy*dy;
            if(d2 > StationDiameter*StationDiameter*6) {
                drawFilledCircle(context, p1.x, p1.y, LineWidth);
                drawFilledCircle(context, p2.x, p2.y, LineWidth);
                drawLine(context, p1.x, p1.y, p2.x, p2.y, LineWidth);
            } else
                drawLine(context, p1.x, p1.y, p2.x, p2.y, LineWidth*2);
        }
    }
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    for(int i = 0; i<[stations count]; i++) {
        Station *st = [stations objectAtIndex:i];
        CGPoint p1 = st.pos;
        for(int j = i+1; j<[stations count]; j++) {
            Station *st2 = [stations objectAtIndex:j];
            CGPoint p2 = st2.pos;
            CGFloat dx = (p1.x-p2.x);
            CGFloat dy = (p1.y-p2.y);
            CGFloat d2 = dx*dx + dy*dy;
            if(d2 > StationDiameter*StationDiameter*6) {
                drawFilledCircle(context, p1.x, p1.y, LineWidth-blackW/2);
                drawFilledCircle(context, p2.x, p2.y, LineWidth-blackW/2);
                drawLine(context, p1.x, p1.y, p2.x, p2.y, LineWidth-blackW);
            } else 
                drawLine(context, p1.x, p1.y, p2.x, p2.y, LineWidth*2-blackW);
        }
    }
    for (Station *st in stations) {
        if(st.terminal) {
            CGPoint p1 = st.pos;
            CGContextSetFillColorWithColor(context, [st.line.color CGColor]);
            drawFilledCircle(context, p1.x, p1.y, LineWidth/2);
        }
    }
}

+(void) drawTransferLikeMoscow:(CGContextRef)context stations:(NSArray*)stations
{
    CGFloat blackW = LineWidth * 0.5f;
    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 0.6);
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 0.6);				
    for(int i = 0; i<[stations count]; i++) {
        Station *st = [stations objectAtIndex:i];
        CGPoint p1 = st.pos;
        for(int j = i+1; j<[stations count]; j++) {
            Station *st2 = [stations objectAtIndex:j];
            CGPoint p2 = st2.pos;
            drawLine(context, p1.x, p1.y, p2.x, p2.y, LineWidth*2);
        }
    }
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    for(int i = 0; i<[stations count]; i++) {
        Station *st = [stations objectAtIndex:i];
        CGPoint p1 = st.pos;
        for(int j = i+1; j<[stations count]; j++) {
            Station *st2 = [stations objectAtIndex:j];
            CGPoint p2 = st2.pos;
            drawLine(context, p1.x, p1.y, p2.x, p2.y, LineWidth*2-blackW);
        }
    }
    for (Station *st in stations) {
        CGPoint p1 = st.pos;
        CGContextSetFillColorWithColor(context, [st.line.color CGColor]);
        drawFilledCircle(context, p1.x, p1.y, LineWidth/2);
    }
}

-(void)draw:(CGContextRef)context
{
    if(transferLayer != nil) CGContextDrawLayerInRect(context, boundingBox, transferLayer);
    else {
        switch (TrKind) {
            case LIKE_LONDON:
                [Transfer drawTransferLikeLondon:context stations:[stations allObjects]];
                break;
            case LIKE_PARIS:
                [Transfer drawTransferLikeParis:context stations:[stations allObjects]];
                break;
            case LIKE_MOSCOW:
                [Transfer drawTransferLikeMoscow:context stations:[stations allObjects]];
                break;
        }
    }
}

-(void)predraw:(CGContextRef)context
{
    if (transferLayer != nil) CGLayerRelease(transferLayer);
    CGSize size = CGSizeMake(boundingBox.size.width*PredrawScale, boundingBox.size.height*PredrawScale);
    transferLayer = CGLayerCreateWithContext(context, size, NULL);
    CGContextRef ctx = CGLayerGetContext(transferLayer);
    CGContextScaleCTM(ctx, PredrawScale, PredrawScale);
    CGContextTranslateCTM(ctx, -boundingBox.origin.x, -boundingBox.origin.y);
    switch (TrKind) {
        case LIKE_PARIS:
            [Transfer drawTransferLikeParis:ctx stations:[stations allObjects]];
            break;
        case LIKE_LONDON:
            [Transfer drawTransferLikeLondon:ctx stations:[stations allObjects]];
            break;
        case LIKE_MOSCOW:
            [Transfer drawTransferLikeMoscow:ctx stations:[stations allObjects]];
            break;
    }
}

-(void) tuneStations
{
    if([stations count] == 2) {
        Station* s[2];
        int i=0;
        for (Station *st in stations) {
            s[i] = st;
            i++;
        }
        CGPoint A1 = s[0].pos, dA = s[0].tangent;
        CGPoint B1 = s[1].pos, dB = s[1].tangent;
        CGPoint dp = CGPointMake(A1.x - B1.x, A1.y - B1.y);
        CGFloat SD2 = StationDiameter*StationDiameter*4;
        if(SD2 >= (dp.x * dp.x + dp.y * dp.y)) {
            CGFloat d = dA.x * dB.y - dA.y * dB.x;
            if(d == 0.f) {
                NSLog(@"lines are paraleled, %@", s[0].name);
                return; // parallel
            }
            //CGFloat d1 = (dp.x * dB.y - dp.y * dB.x) / d;
            CGFloat d2 = (dA.x * dp.y - dA.y * dp.x) / d;
            //CGPoint C1 = CGPointMake(A1.x + dA.x * d1, A1.y + dA.y * d1);
            CGPoint C2 = CGPointMake(B1.x + dB.x * d2, B1.y + dB.y * d2);
            dA = CGPointMake(C2.x - A1.x, C2.y - A1.y);
            if(SD2 < (dA.x * dA.x + dA.y * dA.y)) {
                return; // too far 
            }
            dB = CGPointMake(C2.x - B1.x, C2.y - B1.y);
            if(SD2 < (dB.x * dB.x + dB.y * dB.y)) {
                return; // too far
            }
            s[0].pos = C2;
            s[1].pos = C2;
            
            boundingBox = CGRectMake(C2.x - StationDiameter, C2.y - StationDiameter, StationDiameter*2.f, StationDiameter*2.f);
        }
    } else {
        //NSLog(@"more than two stations in transfer, %@", [[stations anyObject] name]);
    }
}

@end

@implementation Station

@synthesize relation;
@synthesize relationDriving;
@synthesize segment;
@synthesize backSegment;
@synthesize sibling;
@synthesize pos;
@synthesize boundingBox;
@synthesize textRect;
@synthesize index;
@synthesize name;
@synthesize driving;
@synthesize transfer;
@synthesize line;
@synthesize drawName;
@synthesize active;
@synthesize acceptBackLink;
@synthesize links;
@synthesize tangent;

-(BOOL) terminal { return links == 1; }

-(void) setPos:(CGPoint)_pos
{
    pos = _pos;
    boundingBox = CGRectMake(pos.x-StationDiameter/2, pos.y-StationDiameter/2, StationDiameter, StationDiameter);
}

-(id)initWithName:(NSString*)sname pos:(CGPoint)p index:(int)i rect:(CGRect)r andDriving:(NSString*)dr
{
    if((self = [super init])) {
        pos = p;
        boundingBox = CGRectMake(pos.x-StationDiameter/2, pos.y-StationDiameter/2, StationDiameter, StationDiameter);
        index = i;
        textRect = r;
        segment = [[NSMutableArray alloc] init];
        backSegment = [[NSMutableArray alloc] init];
        relation = [[NSMutableArray alloc] init];
        relationDriving = [[NSMutableArray alloc] init];
        sibling = [[NSMutableArray alloc] init];
        drawName = YES;
        active = YES;
        acceptBackLink = YES;
        predrawedName = nil;
        
        NSUInteger br = [sname rangeOfString:@"("].location;
        if(br == NSNotFound) {
            name = [sname retain];
        } else {
            name = [[sname substringToIndex:br] retain];
            NSArray *components = [[sname substringFromIndex:br+1] componentsSeparatedByString:@","];
            if([components count] > 1) acceptBackLink = NO;
            for (NSString* s in components) {
                if([s length] == 0) continue;
                if([s characterAtIndex:0] == '-')
                    [relation addObject:[s substringFromIndex:1]];
                else
                    [relation addObject:s];
            }
        }
        if(dr == nil) driving = 0;
        else {
            br = [dr rangeOfString:@"("].location;
            if(br == NSNotFound) {
                driving = [dr intValue];
            } else {
                driving = [[dr substringToIndex:br] intValue];
                for (NSString *s in [[dr substringFromIndex:br+1] componentsSeparatedByString:@","]) {
                    if([s length] == 0) continue;
                    int drv = [s intValue];
                    NSAssert(drv > 0, @"zero driving!");
                    [relationDriving addObject:[NSNumber numberWithInt:drv]];
                }
            }
        }
    }
    return self;
}

-(void)dealloc
{
    [segment release];
    [backSegment release];
    [relation release];
    [relationDriving release];
    [sibling release];
    CGLayerRelease(predrawedName);
}

-(void)addSibling:(Station *)st
{
    for (Station *s in sibling) {
        if(s == st) return;
    }
    [sibling addObject:st];
}

-(void) draw:(CGContextRef)context
{
    for (Segment *s in segment) {
        [s draw:context];
    }
}

-(void) draw:(CGContextRef)context inRect:(CGRect)rect
{
    for (Segment *s in segment) {
        if(CGRectIntersectsRect(rect, s.boundingBox))
            [s draw:context];
    }
}

-(void)drawName:(CGContextRef)context
{
    if(!active) {
        CGContextSaveGState(context);
        CGContextSetAlpha(context, 0.3f);
    }
    if(predrawedName != nil) CGContextDrawLayerInRect(context, textRect, predrawedName);
    else {
        CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
        if(active || (transfer && transfer.active && drawName)) {
            CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor] );
        } else {
            CGContextSetFillColorWithColor(context, [[UIColor lightGrayColor] CGColor] );
        }
        CGContextSetTextDrawingMode (context, kCGTextFill);
        int alignment = UITextAlignmentCenter;
        if(pos.x < textRect.origin.x) alignment = UITextAlignmentLeft;
        else if(pos.x > textRect.origin.x + textRect.size.width) alignment = UITextAlignmentRight;
        CGContextSelectFont(context, "Arial-BoldMT", StationDiameter, kCGEncodingMacRoman);
        CGContextShowTextAtPoint(context, textRect.origin.x, textRect.origin.y+textRect.size.height, [name cStringUsingEncoding:[NSString defaultCStringEncoding]], [name length]);
    }
    if(!active) CGContextRestoreGState(context);
}

-(void)drawStation:(CGContextRef)context
{
    if(StKind == LIKE_LONDON) {
        CGContextSetLineCap(context, kCGLineCapSquare);
        CGFloat lw = LineWidth * 0.5f;
        CGContextSetLineWidth(context, LineWidth);
        CGPoint p = CGPointMake(pos.x + lw*normal.x, pos.y + lw*normal.y);
        CGContextMoveToPoint(context, p.x, p.y);
        CGContextAddLineToPoint(context, p.x + normal.x, p.y + normal.y);
        CGContextStrokePath(context);
    }
}

-(void)predraw:(CGContextRef) context
{
    if(predrawedName != nil) CGLayerRelease(predrawedName);
    CGSize size = textRect.size;
    predrawedName = CGLayerCreateWithContext(context, CGSizeMake(size.width*PredrawScale, size.height*PredrawScale), NULL);
    CGContextRef ctx = CGLayerGetContext(predrawedName);
    UIGraphicsPushContext(ctx);
    CGContextScaleCTM(ctx, PredrawScale, PredrawScale);
    int alignment = UITextAlignmentCenter;
    if(pos.x < textRect.origin.x) alignment = UITextAlignmentLeft;
    else if(pos.x > textRect.origin.x + textRect.size.width) alignment = UITextAlignmentRight;
    CGRect rect = textRect;
    rect.origin = CGPointZero;
    [name drawInRect:rect  withFont: [UIFont fontWithName:@"Arial-BoldMT" size:StationDiameter] lineBreakMode: UILineBreakModeWordWrap alignment: alignment];
    UIGraphicsPopContext();
}

-(void) makeSegments
{
    int drv = [relationDriving count] - [sibling count];
    for(int i=0; i<[sibling count]; i++) {
        Station *st = [sibling objectAtIndex:i];
        int curDrv = driving;
        if(drv >= 0) curDrv = [[relationDriving objectAtIndex:drv] intValue];
        [segment addObject:[[Segment alloc] initFromStation:self toStation:st withDriving:curDrv]];
        drv ++;
    }
    if(!driving && [relationDriving count]) driving = [[relationDriving objectAtIndex:0] intValue];
    [relationDriving release];
    [relation release];
    relationDriving = nil;
    relation = nil;
}

-(void) makeTangent
{
    CGPoint fp = CGPointZero, bp = CGPointZero;
    BOOL preferFrontPoint = NO, preferBackPoint = NO;
    if([segment count] > 0) {
        for (Segment *seg in segment) {
            if([seg.splinePoints count] == 0) {
                fp = seg.end.pos;
                preferFrontPoint = YES;
                break;
            }
        }
        if(!preferFrontPoint) {
            Segment *s = [segment objectAtIndex:0];
            fp = [[s.splinePoints objectAtIndex:0] CGPointValue];
        }
    } 
    if([backSegment count] > 0) {
        for (Segment *seg in backSegment) {
            if([seg.splinePoints count] == 0) {
                bp = seg.start.pos;
                preferBackPoint = YES;
                break;
            }
        }
        if(!preferBackPoint) {
            Segment *s = [backSegment objectAtIndex:0];
            bp = [[s.splinePoints lastObject] CGPointValue];
        }
    } 
    if(preferFrontPoint || CGPointEqualToPoint(bp, CGPointZero)) 
        tangent = CGPointMake(fp.x - pos.x, fp.y - pos.y);
    else
        tangent = CGPointMake(pos.x - bp.x, pos.y - bp.y);
    normal = CGPointMake(tangent.y, -tangent.x);
    CGPoint td = CGPointMake(textRect.origin.x - pos.x, textRect.origin.y - pos.y);
    CGFloat ntd = normal.x * td.x + normal.y * td.y;
    if(ntd < 0.f) {
        normal = CGPointMake(-normal.x, -normal.y);
    }
    ntd = normal.x * normal.x + normal.y * normal.y;
    ntd = sqrtf(ntd);
    normal.x /= ntd;
    normal.y /= ntd;
}

@end

@implementation TangentPoint

@synthesize base;
@synthesize backTang;
@synthesize frontTang;

-(id)initWithPoint:(CGPoint)p
{
    if((self = [super init])) {
        base = p;
    }
    return self;
}

-(void)calcTangentFrom:(CGPoint)p1 to:(CGPoint)p2
{
    CGFloat x = (1 + (Sql(base, p1) - Sql(base, p2)) / Sql(p1, p2)) / 2;
    CGPoint d = CGPointMake(p1.x + (p2.x-p1.x) * x, p1.y + (p2.y-p1.y) * x);
    
    frontTang = CGPointMake(base.x + (p2.x-d.x)/3, base.y + (p2.y-d.y)/3);
    backTang = CGPointMake(base.x + (p1.x-d.x)/3, base.y + (p1.y-d.y)/3);
}
@end

@implementation Segment

@synthesize start;
@synthesize end;
@synthesize driving;
@synthesize boundingBox;
@synthesize active;

-(NSArray*)splinePoints {
    return splinePoints;
}

-(id)initFromStation:(Station *)from toStation:(Station *)to withDriving:(int)dr
{
    if((self = [super init])) {
        active = YES;
        start = from;
        end = to;
        [end.backSegment addObject:self];
        driving = dr;
        NSAssert(driving > 0, @"illegal driving");
        CGRect s1 = CGRectMake(from.pos.x - 5, from.pos.y - 5, 10, 10);
        CGRect s2 = CGRectMake(to.pos.x - 5, to.pos.y - 5, 10, 10);
        boundingBox = CGRectUnion(s1, s2);
        start.links ++;
        end.links ++;
    }
    return self;
}

-(void)dealloc
{
    [splinePoints release];
    CGPathRelease(path);
}

-(void)appendPoint:(CGPoint)p
{
    if(splinePoints == nil) splinePoints = [[NSMutableArray alloc] initWithObjects:[NSValue valueWithCGPoint:p], nil];
    else [splinePoints addObject:[NSValue valueWithCGPoint:p]];
    CGRect r = CGRectMake(p.x - 5, p.y - 5, 10, 10);
    boundingBox = CGRectUnion(boundingBox, r);
}

-(void)calcSpline
{
    if(splinePoints == nil || [splinePoints count] == 0) return;
    [splinePoints addObject:[NSValue valueWithCGPoint:CGPointMake(end.pos.x, end.pos.y)]];
    [splinePoints insertObject:[NSValue valueWithCGPoint:CGPointMake(start.pos.x, start.pos.y)] atIndex:0];
    NSMutableArray *newSplinePoints = [[NSMutableArray alloc] init];
    for(int i=1; i<[splinePoints count]-1; i++) {
        TangentPoint *p = [[TangentPoint alloc] initWithPoint:[[splinePoints objectAtIndex:i] CGPointValue]];
        [p calcTangentFrom:[[splinePoints objectAtIndex:i-1] CGPointValue] to:[[splinePoints objectAtIndex:i+1] CGPointValue]];
        [newSplinePoints addObject:p];
    }
    [splinePoints release];
    splinePoints = newSplinePoints;
    [self predraw];
}

-(void)draw:(CGContextRef)context fromPoint:(CGPoint)p toTangentPoint:(TangentPoint*)tp
{
    CGContextMoveToPoint(context, tp.base.x, tp.base.y);
    CGContextAddQuadCurveToPoint(context, tp.backTang.x, tp.backTang.y, p.x, p.y);
    CGContextStrokePath(context);
}

-(void)draw:(CGContextRef)context fromTangentPoint:(TangentPoint*)tp toPoint:(CGPoint)p
{
    CGContextMoveToPoint(context, tp.base.x, tp.base.y);
    CGContextAddQuadCurveToPoint(context, tp.frontTang.x, tp.frontTang.y, p.x, p.y);
    CGContextStrokePath(context);
}

-(void)draw:(CGContextRef)context fromTangentPoint:(TangentPoint*)tp1 toTangentPoint:(TangentPoint*)tp2
{
    CGContextMoveToPoint(context, tp1.base.x, tp1.base.y);
    CGContextAddCurveToPoint(context, tp1.frontTang.x, tp1.frontTang.y, tp2.backTang.x, tp2.backTang.y, tp2.base.x, tp2.base.y);
    CGContextStrokePath(context);
}

-(void)draw:(CGContextRef)context
{
    if(!active) {
        CGContextSaveGState(context);
        CGContextSetAlpha(context, 0.3f);
    }
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetLineWidth(context, LineWidth);
	CGContextMoveToPoint(context, start.pos.x, start.pos.y);
    if(splinePoints) {
        CGContextMoveToPoint(context, 0, 0);
        CGContextAddPath(context, path);
        CGContextStrokePath(context);
    } else {
        CGContextAddLineToPoint(context, end.pos.x, end.pos.y);
        CGContextStrokePath(context);
    }
    if(!active) {
        CGContextRestoreGState(context);
    }
}

-(void)predraw
{
    if(splinePoints) {
        if(path != nil) CGPathRelease(path);
        path = CGPathCreateMutable();
        TangentPoint *tp1 = [splinePoints objectAtIndex:0], *tp2 = nil;
        CGPathMoveToPoint(path, nil, tp1.base.x, tp1.base.y);
        CGPathAddQuadCurveToPoint(path, nil, tp1.backTang.x, tp1.backTang.y, start.pos.x, start.pos.y);
        CGPathMoveToPoint(path, nil, tp1.base.x, tp1.base.y);
        for(int i=0; i<[splinePoints count]-1; i++) {
            tp1 = [splinePoints objectAtIndex:i];
            tp2 = [splinePoints objectAtIndex:i+1];
            CGPathAddCurveToPoint(path, nil, tp1.frontTang.x, tp1.frontTang.y, tp2.backTang.x, tp2.backTang.y, tp2.base.x, tp2.base.y);
        }
        tp2 = [splinePoints lastObject];
        CGPathAddQuadCurveToPoint(path, nil, tp2.frontTang.x, tp2.frontTang.y, end.pos.x, end.pos.y);
    }
}

@end

@implementation Line

@synthesize color  = _color;
@synthesize name;
@synthesize stations;
@synthesize index;
@synthesize boundingBox;

-(id)initWithName:(NSString*)n stations:(NSString *)station driving:(NSString *)driving coordinates:(NSString *)coordinates rects:(NSString *)rects
{
    if((self = [super init])) {
        name = [n retain];
        stations = [[NSMutableArray alloc] init];
        stationLayer = nil;
        boundingBox = CGRectNull;
        NSArray *sts = Split(station);
        NSArray *drs = Split(driving);
        NSArray *crds = [coordinates componentsSeparatedByString:@", "];
        NSArray *rcts = [rects componentsSeparatedByString:@", "];
        int count = MIN( MIN([sts count], [crds count]), [rcts count]);
        for(int i=0; i<count; i++) {
            NSArray *coord_x_y = [[crds objectAtIndex:i] componentsSeparatedByString:@","];
            int x = [[coord_x_y objectAtIndex:0] intValue];
            int y = [[coord_x_y objectAtIndex:1] intValue];
            NSArray *coord_text = [[rcts objectAtIndex:i] componentsSeparatedByString:@","];
            int tx = [[coord_text objectAtIndex:0] intValue];
            int ty = [[coord_text objectAtIndex:1] intValue];
            int tw = [[coord_text objectAtIndex:2] intValue];
            int th = [[coord_text objectAtIndex:3] intValue];
            
            NSString* drv = nil;
            if(i < [drs count]) drv = [drs objectAtIndex:i];
            Station *st = [[Station alloc] initWithName:[sts objectAtIndex:i] pos:CGPointMake(x, y) index:i rect:CGRectMake(tx, ty, tw, th) andDriving:drv];
            st.line = self;
            Station *last = [stations lastObject];
            if([st.relation count] < [st.relationDriving count]) {
                if(last.driving == 0) last.driving = [[st.relationDriving lastObject] intValue];
                [st.relationDriving removeLastObject];
            }
            if(st.acceptBackLink && [stations count]) {
                // создаём простые связи
                [last addSibling:st];
            }
            [stations addObject:st];
        }
        // создаём отложенные связи
        for (Station *st in stations) {
            for(NSString *rel in st.relation) {
                for(Station *st2 in stations) {
                    if([st2.name isEqualToString:rel]) {
                        BOOL alreadyLinked = NO;
                        for (Station *st3 in st2.sibling) {
                            if(st3 == st) {
                                alreadyLinked = YES;
                                break;
                            }
                        }
                        if(!alreadyLinked) [st addSibling:st2];
                        break;
                    }
                }
            }
            [st.relation removeAllObjects];
        }
        for(Station *st in stations) {
            [st makeSegments];
            boundingBox = CGRectUnion(boundingBox, st.boundingBox);
            boundingBox = CGRectUnion(boundingBox, st.textRect);
            for (Segment *seg in st.segment) {
                boundingBox = CGRectUnion(boundingBox, seg.boundingBox);
            }
        }
    }
    return self;
}

-(void)dealloc
{
    [stations release];
    CGLayerRelease(stationLayer);
}

-(void)draw:(CGContextRef)context 
{
	CGContextSetStrokeColorWithColor(context, [_color CGColor]);
    CGContextSetFillColorWithColor(context, [_color CGColor]);
    for (Station *s in stations) {
        [s draw:context];
    }
    for (Station *s in stations) {
        if(s.transfer == nil) {
            if(!s.active) {
                CGContextSaveGState(context);
                CGContextSetAlpha(context, 0.3f);
            }
            CGContextDrawLayerInRect(context, s.boundingBox, stationLayer);
            if(!s.active) CGContextRestoreGState(context);
        }
    }
}

-(void)drawNames:(CGContextRef)context
{
    for (Station *s in stations) {
        if(s.drawName) [s drawName:context];
    }
}

-(void)draw:(CGContextRef)context inRect:(CGRect)rect
{
	CGContextSetStrokeColorWithColor(context, [_color CGColor]);
    CGContextSetFillColorWithColor(context, [_color CGColor]);
    for (Station *s in stations) {
        [s draw:context inRect:rect];
    }
    for (Station *s in stations) {
        if(s.transfer == nil && CGRectIntersectsRect(rect, s.boundingBox)) {
            if(StKind == LIKE_LONDON)
                [s drawStation:context];
            else
                CGContextDrawLayerInRect(context, s.boundingBox, stationLayer);
        }
    }
}

-(void)drawNames:(CGContextRef)context inRect:(CGRect)rect
{
    for (Station *s in stations) {
        if(s.drawName && CGRectIntersectsRect(s.textRect, rect))
            [s drawName:context];
    }
}

-(Segment*)activateSegmentFrom:(NSString *)station1 to:(NSString *)station2
{
    for (Station *s in stations) {
        if([s.name isEqualToString:station1] || [s.name isEqualToString:station2]) {
            s.active = YES;
            if(s.transfer) s.transfer.active = YES;
            for (Segment *seg in s.segment) {
                if([seg.end.name isEqualToString:station1] || [seg.end.name isEqualToString:station2]) {
                    seg.end.active = YES;
                    seg.active = YES;
                    if(seg.end.transfer) seg.end.transfer.active = YES;
                    return seg;
                }
            }
        }
    }
    return nil;
}

-(void)setEnabled:(BOOL)en
{
    for (Station *s in stations) {
        s.active = en;
        for(Segment *seg in s.segment) {
            seg.active = en;
        }
    }
}

-(void)additionalPointsBetween:(NSString *)station1 and:(NSString *)station2 points:(NSArray *)points
{
    Station *ss1 = nil;
    Station *ss2 = nil;
    for (Station *s in stations) {
        BOOL search = NO;
        BOOL rev = NO;
        if([s.name isEqualToString:station1]) {
            search = YES;
            ss1 = s;
        }
        else if([s.name isEqualToString:station2]) {
            search = rev = YES;
            ss2 = s;
        }
        if(search) {
            for (Segment *seg in s.segment) {
                if(([seg.end.name isEqualToString:station1] && rev)
                   || ([seg.end.name isEqualToString:station2] && !rev)) {
                    NSEnumerator *enumer;
                    if(rev) enumer = [points reverseObjectEnumerator];
                    else enumer = [points objectEnumerator];
                    for (NSString *p in enumer) {
                        NSArray *coord = [p componentsSeparatedByString:@","];
                        [seg appendPoint:CGPointMake([[coord objectAtIndex:0] intValue], [[coord objectAtIndex:1] intValue])];
                    }
                    //[seg calcSpline];
                    return;
                }
            }
        }
    }
}

-(Station*)getStation:(NSString *)stName
{
    for (Station *s in stations) {
        if([s.name isEqualToString:stName]) return s;
    }
    return nil;
}

-(void)predraw:(CGContextRef)context
{
    for (Station *s in stations) {
        [s predraw:context];
    }
    if(stationLayer != nil) CGLayerRelease(stationLayer);
    // make predrawed staion point
    CGFloat ssize = StationDiameter*PredrawScale;
    CGFloat hsize = ssize/2;
    stationLayer = CGLayerCreateWithContext(context, CGSizeMake(ssize, ssize), NULL);
    CGContextRef ctx = CGLayerGetContext(stationLayer);
    switch(StKind) {
        case LIKE_MOSCOW:
            CGContextSetRGBFillColor(ctx, 0, 0, 0, 1.0);
            CGContextFillEllipseInRect(ctx, CGRectMake(0, 0, ssize, ssize));
            CGContextSetFillColorWithColor(ctx, [_color CGColor]);
            drawFilledCircle(ctx, hsize, hsize, hsize-PredrawScale/2);
            break;
        case LIKE_PARIS:
            CGContextSetFillColorWithColor(ctx, [_color CGColor]);
            drawFilledCircle(ctx, hsize, hsize, hsize);
            break;
        case LIKE_LONDON:
            break;
    }
}

-(void)calcStations
{
    for (Station *st in stations) {
        [st makeTangent];
    }
}

@end

@implementation CityMap

@synthesize graph;
@synthesize gpsCoords;
@synthesize activeExtent;
@synthesize activePath;
@synthesize maxScale;
@synthesize thisMapName;
@synthesize pathStationsList;

-(StationKind) stationKind { return StKind; }
-(void) setStationKind:(StationKind)stationKind { StKind = stationKind; }
-(StationKind) transferKind { return TrKind; }
-(void) setTransferKind:(StationKind)transferKind { TrKind = transferKind; }

-(id) init {
    [super init];
	[self initVars];
    return self;
}

-(void) initVars {
    transfers = [[NSMutableArray alloc] init];
	gpsCoords = [[NSMutableDictionary alloc] init];
	graph = [[Graph graph] retain];
    mapLines = [[NSMutableArray alloc] init];
    activeExtent = CGRectNull;
    activePath = [[NSMutableArray alloc] init];
    pathStationsList = [[NSMutableArray alloc] init];
    maxScale = 4;
}

-(CGSize) size { return CGSizeMake(_w, _h); }
-(NSInteger) w { return _w; }
-(NSInteger) h { return _h; }

-(CGFloat) predrawScale { return PredrawScale; }
-(void) setPredrawScale:(CGFloat)predrawScale {
    PredrawScale = predrawScale;
    [self predraw];
}

-(void) loadMap:(NSString *)mapName {
	INIParser* parserTrp, *parserMap;
	
	parserTrp = [[INIParser alloc] init];
	parserMap = [[INIParser alloc] init];
	
	int err;

    self.thisMapName=mapName;
    
	NSString* strTrp = [[NSBundle mainBundle] pathForResource:mapName ofType:@"trp"]; 
	NSString* strMap = [[NSBundle mainBundle] pathForResource:mapName ofType:@"map"]; 
	
	err = [parserTrp parse:[strTrp UTF8String]];
    err = [parserMap parse:[strMap UTF8String]];

    int val = [[parserMap get:@"LinesWidth" section:@"Options"] intValue];
    if(val != 0) LineWidth = val;
    val = [[parserMap get:@"StationDiameter" section:@"Options"] intValue];
    if(val != 0) StationDiameter = val;
    val = [[parserMap get:@"DisplayTransfers" section:@"Options"] intValue];
    if(val > 0 && val < KINDS_NUM) TrKind = val;
    val = [[parserMap get:@"DisplayStations" section:@"Options"] intValue];
    if(val > 0 && val < KINDS_NUM) StKind = val;
    float sc = [[parserMap get:@"MaxScale" section:@"Options"] floatValue];
    if(sc != 0.f) {
        maxScale = sc;
        PredrawScale = maxScale * 0.5f;
    }
	
	_w = 0;
	_h = 0;
    CGRect boundingBox = CGRectNull;

	for (int i = 1; true; i++) {
		NSString *sectionName = [NSString stringWithFormat:@"Line%d", i ];
		NSString *lineName = [parserTrp get:@"Name" section:sectionName];
        if(lineName == nil) break;

        MLine *newLine = [NSEntityDescription insertNewObjectForEntityForName:@"Line" inManagedObjectContext:[MHelper sharedHelper].managedObjectContext];
        newLine.name=lineName;
        newLine.index = [[NSNumber alloc] initWithInt:i];
 
		NSString *colors = [parserMap get:@"Color" section:lineName];
        newLine.color = [self colorForHex:colors];
		
		NSString *coords = [parserMap get:@"Coordinates" section:lineName];
		NSString *coordsText = [parserMap get:@"Rects" section:lineName];
		NSString *stations = [parserTrp get:@"Stations" section:sectionName];
		[self processLinesStations:stations	:i];
		
		NSString *coordsTime = [parserTrp get:@"Driving" section:sectionName];
        
        Line *l = [[Line alloc] initWithName:lineName stations:stations driving:coordsTime coordinates:coords rects:coordsText];
        l.index = i;
        l.color = newLine.color;
        [mapLines addObject:l];
        boundingBox = CGRectUnion(boundingBox, l.boundingBox);
	}
    [[MHelper sharedHelper] saveContext];
    [[MHelper sharedHelper] readHistoryFile];
    [[MHelper sharedHelper] readBookmarkFile];
    _w = boundingBox.origin.x * 2 + boundingBox.size.width;
    _h = boundingBox.origin.y * 2 + boundingBox.size.height;
		
	INISection *section = [parserMap getSection:@"AdditionalNodes"];
	NSMutableDictionary *as = [section assignments];
	for (NSString* key in as) {
		NSString *value = [parserMap get:key section:@"AdditionalNodes"];
		[self processAddNodes:value];
	}
	INISection *section2 = [parserTrp getSection:@"Transfers"];
	NSMutableDictionary *as2 = [section2 assignments];
	for (NSString* key in as2) {
		NSString *value = [parserTrp get:key section:@"Transfers"];
		[self processTransfers:value];
	}
	
	INISection *section3 = [parserTrp getSection:@"gps"];
	NSMutableDictionary *as3 = [section3 assignments];
	for (NSString* key in as3) {
		NSString *value = [parserTrp get:key section:@"gps"];
		[self processGPS :key :value];
	}
	[parserMap release];
    [parserTrp release];
    
    for (Line *l in mapLines) {
        [l calcStations];
    }
    
    for (Transfer* tr in transfers) {
        [tr tuneStations];
    }
    
    for (Line *l in mapLines) {
        for (Station *st in l.stations) {
            for (Segment *seg in st.segment) {
                [seg calcSpline];
            }
        }
    }
    [self calcGraph];
    [self predraw];
}

-(void)predraw
{
    UIGraphicsBeginImageContext(CGSizeMake(100, 100));
    CGContextRef context = UIGraphicsGetCurrentContext();
    // predraw transfers
    for (Transfer *t in transfers) {
        [t predraw:context];
    };
    // predraw lines & stations
    for (Line *l in mapLines) {
        [l predraw:context];
    }
    UIGraphicsEndImageContext();
}

-(NSArray*) calcPath :(NSString*) firstStation :(NSString*) secondStation :(NSInteger) firstStationLineNum :(NSInteger)secondStationLineNum {

	
	NSString *name1 = [firstStation stringByAppendingString:[NSString stringWithFormat:@"|%d", firstStationLineNum]];
	NSString *name2 = [secondStation stringByAppendingString:[NSString stringWithFormat:@"|%d", secondStationLineNum]];
	DLog(@" %@ %@ ",name1,name2);
	
	NSArray *pp = [graph shortestPath:[GraphNode nodeWithValue:name1] to:[GraphNode nodeWithValue:name2]];
	 
	return pp;
}
-(void) processGPS: (NSString*) station :(NSString*) lineCoord {
	
	NSArray *elements = [lineCoord componentsSeparatedByString:@","];
	
	CLLocation *et = [[[CLLocation alloc] initWithLatitude:[[elements objectAtIndex:0] floatValue] 
												 longitude:[[elements objectAtIndex:1] floatValue]
															] autorelease];
	
	[gpsCoords setObject:et forKey:station];
}
-(void) processTransfers:(NSString*)transferInfo{
	
	NSArray *elements = [transferInfo componentsSeparatedByString:@","];

    NSString *lineStation1 = [elements objectAtIndex:0];
    NSString *station1 = [elements objectAtIndex:1];
    NSString *lineStation2 = [elements objectAtIndex:2];
    NSString *station2 = [elements objectAtIndex:3];

    Station *ss1 = [[mapLines objectAtIndex:[[[MHelper sharedHelper] lineByName:lineStation1].index intValue]-1] getStation:station1];
    Station *ss2 = [[mapLines objectAtIndex:[[[MHelper sharedHelper] lineByName:lineStation2].index intValue]-1] getStation:station2];
    if(ss1.transfer != nil && ss2.transfer != nil) {
        
    } else if(ss1.transfer) {
        [ss1.transfer addStation:ss2];
    } else if(ss2.transfer) {
        [ss2.transfer addStation:ss1];
    } else {
        Transfer *tr = [[Transfer alloc] init];
        tr.time = [[elements objectAtIndex:4] floatValue];
        [tr addStation:ss1];
        [tr addStation:ss2];
        [transfers addObject:tr];
    }
}


-(void) processAddNodes:(NSString*)addNodeInfo{
	
	NSArray *elements = [addNodeInfo componentsSeparatedByString:@", "];

	//expected 3+ elements
	//separate line sations info
	NSArray *stations = [[elements objectAtIndex:0] componentsSeparatedByString:@","];
	
	NSString *lineName = [stations objectAtIndex:0];
	
    for (Line* l in mapLines) {
        if([l.name isEqualToString:lineName]) {
            [l additionalPointsBetween:[stations objectAtIndex:1] and:[stations objectAtIndex:2] points:[elements objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, [elements count]-2)]]];
            break;
        }
    }
}

-(void) processLinesStations:(NSString*) stations :(NSUInteger) line{

	NSUInteger location2=0;
	Boolean endline=false;
	
	NSString *new_s = nil;

	NSString *remained_station = stations;

	int i = 0;
	while ([remained_station length] != 0) {
		if ([remained_station rangeOfString:@","].location!=NSNotFound)
			location2 = [remained_station rangeOfString:@","].location;
		else
		{
			endline = true;
			location2 = [remained_station length];	
		}
		new_s = [remained_station substringToIndex:location2];

		if ([new_s rangeOfString:@"("].location==NSNotFound)
		{

			NSString *newstring = [remained_station substringToIndex:location2];
			
            MStation *station = [NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:[MHelper sharedHelper].managedObjectContext];
            station.name=newstring;
            station.isFavorite=[NSNumber numberWithInt:0];
            station.lines=[[MHelper sharedHelper] lineByIndex:line ];
            station.index = [NSNumber numberWithInt:i];

			i++;
			if (!endline)
			remained_station = [remained_station substringFromIndex:location2+1];			
			else
			remained_station = [remained_station substringFromIndex:location2];							
			continue;
		}
		else
		{
			
			if ([new_s rangeOfString:@")"].location==NSNotFound)
			{
				location2 = [remained_station rangeOfString:@")"].location+1;

			}
			NSString *newstring = [remained_station substringToIndex:location2]; // +1 

			NSUInteger location3 = [newstring rangeOfString:@"("].location;
			NSString *stationname = [newstring substringToIndex:location3];
			
            MStation *station = [NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:[MHelper sharedHelper].managedObjectContext];
                        station.name=stationname;
            station.isFavorite=[NSNumber numberWithInt:0];
            station.lines=[[MHelper sharedHelper] lineByIndex:line ];
            station.index = [NSNumber numberWithInt:i];
            
			i++;
			if(!endline)
			remained_station = [remained_station substringFromIndex:location2+1]; // +2			
			else
			remained_station = [remained_station substringFromIndex:location2];
		}
	}
}


- (UIColor *) colorForHex:(NSString *)hexColor {
	hexColor = [[hexColor stringByTrimmingCharactersInSet:
				 [NSCharacterSet whitespaceAndNewlineCharacterSet]
				 ] uppercaseString];  
	
    // String should be 6 or 7 characters if it includes '#'  
    if ([hexColor length] < 6) 
		return [UIColor blackColor];  
	
    // strip # if it appears  
    if ([hexColor hasPrefix:@"#"]) 
		hexColor = [hexColor substringFromIndex:1];  
	
    // if the value isn't 6 characters at this point return 
    // the color black	
    if ([hexColor length] != 6) 
		return [UIColor blackColor];  
	
    // Separate into r, g, b substrings  
    NSRange range;  
    range.location = 0;  
    range.length = 2; 
	
    NSString *rString = [hexColor substringWithRange:range];  
	
    range.location = 2;  
    NSString *gString = [hexColor substringWithRange:range];  
	
    range.location = 4;  
    NSString *bString = [hexColor substringWithRange:range];  
	
    // Scan values  
    unsigned int r, g, b;  
    [[NSScanner scannerWithString:rString] scanHexInt:&r];  
    [[NSScanner scannerWithString:gString] scanHexInt:&g];  
    [[NSScanner scannerWithString:bString] scanHexInt:&b];  
	
    return [UIColor colorWithRed:((float) r / 255.0f)  
                           green:((float) g / 255.0f)  
                            blue:((float) b / 255.0f)  
                           alpha:1.0f];  
	
}

-(void) calcGraph {
	//for each line
    for (int i=0; i<[mapLines count]; i++) {
        Line *l = [mapLines objectAtIndex:i];
        for (Station *s in l.stations) {
            NSString *st1Name = [NSString stringWithFormat:@"%@|%d",s.name,i+1];
            for (Segment *seg in s.segment) {
                NSString *st2Name = [NSString stringWithFormat:@"%@|%d",seg.end.name,i+1];
				[graph addEdgeFromNode:[GraphNode nodeWithValue:st1Name] toNode:[GraphNode nodeWithValue:st2Name] withWeight:seg.driving];
				[graph addEdgeFromNode:[GraphNode nodeWithValue:st2Name] toNode:[GraphNode nodeWithValue:st1Name] withWeight:seg.driving];
            }
        }
    }
	[self processTransfersForGraph];
}

-(void) processTransfersForGraph{
    for (Transfer *t in transfers) {
        for (Station *s1 in t.stations) {
            NSString *station1 = [NSString stringWithFormat:@"%@|%@", s1.name, [NSNumber numberWithInt:s1.line.index]];
            for (Station *s2 in t.stations) {
                if(s1 != s2) {
                    NSString *station2 = [NSString stringWithFormat:@"%@|%@", s2.name, [NSNumber numberWithInt:s2.line.index]];
                    [graph addEdgeFromNode:[GraphNode nodeWithValue:station1]
                                    toNode:[GraphNode nodeWithValue:station2]
                                withWeight:t.time];
                }
            }
        }
    }
}

- (void)dealloc {
    [super dealloc];
	[gpsCoords release];
    [mapLines release];
	[graph release];
    [transfers release];
    [activePath release];
    [pathStationsList release];
}

// drawing

-(void) drawMap:(CGContextRef) context 
{
    CGContextSaveGState(context);
    for (Line* l in mapLines) {
        [l draw:context];
    }
    CGContextRestoreGState(context);
}

-(void) drawMap:(CGContextRef) context inRect:(CGRect)rect
{
    //printf("rect x=%d y=%d w=%d h=%d\n", (int)rect.origin.x, (int)rect.origin.y, (int)rect.size.width, (int)rect.size.height);
    CGContextSaveGState(context);
    for (Line* l in mapLines) {
        [l draw:context inRect:(CGRect)rect];
    }
    CGContextRestoreGState(context);
}

-(void) drawStations:(CGContextRef) context
{
    CGContextSaveGState(context);

    for (Line* l in mapLines) {
        [l drawNames:context];
    }
    CGContextRestoreGState(context);
}

-(void) drawStations:(CGContextRef) context inRect:(CGRect)rect
{
    CGContextSaveGState(context);
    for (Line* l in mapLines) {
        [l drawNames:context inRect:rect];
    }
    CGContextRestoreGState(context);
}

// рисует часть карты
-(void) activatePath:(NSArray*)pathMap {
    for (Line *l in mapLines) {
        for (Station *s in l.stations) {
            s.active = NO;
            for (Segment *seg in s.segment) {
                seg.active = NO;
            }
        }
    }
    for (Transfer *t in transfers) {
        t.active = NO;
    }
    activeExtent = CGRectNull;
    [activePath removeAllObjects];
    [pathStationsList removeAllObjects];
	int count_ = [pathMap count];
    
	for (int i=0; i< count_-1; i++) {
		NSString *rawString1 = (NSString*)[[pathMap objectAtIndex:i] value];
		NSArray *el1  = [rawString1 componentsSeparatedByString:@"|"];
		NSString *stationName1 = [el1 objectAtIndex:0];
		NSInteger lineNum1 = [[el1 objectAtIndex:1] intValue];
        
        NSString *rawString2 = (NSString*)[[pathMap objectAtIndex:i+1] value];
        NSArray *el2  = [rawString2 componentsSeparatedByString:@"|"];
        NSString *stationName2 = [el2 objectAtIndex:0];
        NSInteger lineNum2 = [[el2 objectAtIndex:1] intValue]; 
        
        Line* l = [mapLines objectAtIndex:lineNum1-1];
        
        if (lineNum1==lineNum2) {
            [activePath addObject:[l activateSegmentFrom:stationName1 to:stationName2]];
            [pathStationsList addObject:stationName1];
        } 

        Station *s = [l getStation:stationName1];
        activeExtent = CGRectUnion(activeExtent, s.textRect);
        activeExtent = CGRectUnion(activeExtent, s.boundingBox);

        if(lineNum1 != lineNum2 && [activePath count] > 0) {
            [activePath addObject:s.transfer];
            [pathStationsList addObject:stationName1];
            [pathStationsList addObject:@"---"]; //временно до обновления модели
        }
        
        if(i == count_ - 2) {
            s = [l getStation:stationName2];
            activeExtent = CGRectUnion(activeExtent, s.textRect);
            activeExtent = CGRectUnion(activeExtent, s.boundingBox);
            [pathStationsList addObject:stationName2];
        }
	}
    activeExtent.origin.x -= activeExtent.size.width * 0.1f;
    activeExtent.origin.y -= activeExtent.size.height * 0.1f;
    activeExtent.size.width *= 1.2f;
    activeExtent.size.height *= 1.2f;
}

-(void) resetPath
{
    for (Line *l in mapLines) {
        [l setEnabled:YES];
    }
    for (Transfer *t in transfers) {
        t.active = YES;
    }
    activeExtent = CGRectNull;
    [activePath removeAllObjects];
}

-(void) drawTransfers:(CGContextRef) context 
{
    CGContextSaveGState(context);
    for (Transfer *tr in transfers) {
        [tr draw:context];
    }
    CGContextRestoreGState(context);
}

-(void) drawTransfers:(CGContextRef) context inRect:(CGRect)rect
{
    CGContextSaveGState(context);
    for (Transfer *tr in transfers) {
        if(CGRectIntersectsRect(rect, tr.boundingBox)) {
            [tr draw:context];
        }
    }
    CGContextRestoreGState(context);
}

-(NSInteger) checkPoint:(CGPoint)point Station:(NSMutableString *)stationName
{
    for (Line *l in mapLines) {
        for (Station *s in l.stations) {
            if(CGRectContainsPoint(s.textRect, point)) {
                [stationName setString:s.name];
                return l.index;
            }
        }
    }
    return -1;
}

@end
