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
#import "tubeAppDelegate.h"

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

int StringToWay(NSString* str)
{
    int way = NOWAY;
    for(int i=0; i<[str length]; i++) {
        char ch = [str characterAtIndex:i];
        switch (ch) {
            case 'S':
            case 's':
                way |= WAY_BEGIN;
                break;
            case 'M':
            case 'm':
                way |= WAY_MIDDLE;
                break;
            case 'E':
            case 'e':
                way |= WAY_END;
                break;
        }
    }
    return way;
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

@implementation ComplexText

@synthesize string;
@synthesize boundingBox;

+(NSString*) makePlainString:(NSString*)_str
{
    NSString *str = _str;
    BOOL finish = NO;
    while (!finish) {
        switch([str characterAtIndex:0]) {
            case '/':
            case '\\':
            case '^':
            case '_':
            case '-':
            case '<':
            case '>':
            case '|':
                str = [str substringFromIndex:1];
                break;
            default:
                finish = YES;
                break;
        }
    }
    str = [[str stringByReplacingOccurrencesOfString:@";" withString:@""] retain];
    return str;
}

-(id) initWithString:(NSString *)_string font:(UIFont *)_font andRect:(CGRect)_rect
{
    if((self = [super init])) {
        angle = 0;
        align = 0;
        string = _string;
        font = [_font retain];
        rect = _rect;
        while (true) {
            unichar ch = [string characterAtIndex:0];
            BOOL finish = NO;
            switch (ch) {
                case '/':
                    angle = -M_PI_4;
                    break;
                case '\\':
                    angle = M_PI_4;
                    break;
                case '^':
                    align |= 0x1;
                    break;
                case '_':
                    align |= 0x2;
                    break;
                case '-':
                    align &= 0xc;
                    break;
                case '<':
                    align |= 0x4;
                    break;
                case '>':
                    align |= 0x8;
                    break;
                case '|':
                    align &= 0x3;
                    break;
                default:
                    finish = YES;
                    break;
            }
            if(finish) break;
            else string = [string substringFromIndex:1];
        }
        words = [[string componentsSeparatedByString:@";"] retain];
        string = [[string stringByReplacingOccurrencesOfString:@";" withString:@""] retain];
        if(angle == 0) {
            CGFloat d = rect.size.height * 0.5f;
            boundingBox = rect;
            boundingBox.origin.x -= d;
            boundingBox.origin.y -= d;
            boundingBox.size.width += 2*d;
            boundingBox.size.height += 2*d;
        } else {
            CGPoint rbase = rect.origin;
            switch (align & 0x3) {
                case 0x0:
                    rbase.y = rect.origin.y + rect.size.height/2; break;
                case 0x1:
                    rbase.y = rect.origin.y; break;
                case 0x2:
                    rbase.y = rect.origin.y + rect.size.height; break;
            }
            switch (align & 0xc) {
                case 0x0:
                    rbase.x = rect.origin.x + rect.size.width/2; break;
                case 0x4:
                    rbase.x = rect.origin.x; break;
                case 0x8:
                    rbase.x = rect.origin.x + rect.size.width; break;
            }
            CGAffineTransform tr = CGAffineTransformMakeTranslation(rbase.x, rbase.y);
            tr = CGAffineTransformRotate(tr, angle);
            tr = CGAffineTransformTranslate(tr, -rbase.x, -rbase.y);
            CGRect r1, r2, r3, r4;
            r1.origin = CGPointApplyAffineTransform(rect.origin, tr);
            r2.origin = CGPointApplyAffineTransform(CGPointMake(rect.origin.x + rect.size.width, rect.origin.y), tr);
            r3.origin = CGPointApplyAffineTransform(CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height), tr);
            r4.origin = CGPointApplyAffineTransform(CGPointMake(rect.origin.x, rect.origin.y + rect.size.height), tr);
            r1.size = r2.size = r3.size = r4.size = CGSizeMake(0.01f, 0.01f);
            boundingBox = CGRectUnion(CGRectUnion(r1, r2), CGRectUnion(r3, r4));
        }
    }
    return self;
}

-(void)predraw:(CGContextRef)context scale:(CGFloat)scale
{
    if(predrawedText != nil) CGLayerRelease(predrawedText);
    NSMutableDictionary *heights = [[NSMutableDictionary alloc] initWithCapacity:[words count]];
    CGSize size = CGSizeZero;
    for (NSString *w in words) {
        CGSize s = [w sizeWithFont:font constrainedToSize:rect.size lineBreakMode:UILineBreakModeWordWrap];
        size.height += s.height;
        if(s.width > size.width) size.width = s.width;
        [heights setValue:[NSNumber numberWithInt:s.height] forKey:w];
    }
    predrawedText = CGLayerCreateWithContext(context, CGSizeMake(size.width*scale, size.height*scale), NULL);
    CGContextRef ctx = CGLayerGetContext(predrawedText);
    UIGraphicsPushContext(ctx);
    CGContextScaleCTM(ctx, scale, scale);
    int alignment = UITextAlignmentCenter;
    if(align & 0x4) alignment = UITextAlignmentLeft;
    else if(align & 0x8) alignment = UITextAlignmentRight;
    CGRect r = CGRectZero;
    r.size = size;
    for (NSString *w in words) {
        [w drawInRect:r  withFont: font lineBreakMode: UILineBreakModeWordWrap alignment: alignment];
        int height = [[heights valueForKey:w] intValue];
        r.origin.y += height;
        r.size.height -= height;
    }
    UIGraphicsPopContext();
    switch (align & 0x3) {
        case 0x0:
            base.y = rect.origin.y + rect.size.height/2;
            offset.y = -size.height/2;
            break;
        case 0x1:
            base.y = rect.origin.y;
            offset.y = 0;
            break;
        case 0x2:
            base.y = rect.origin.y + rect.size.height;
            offset.y = -size.height;
            break;
    }
    switch (align & 0xc) {
        case 0x0:
            base.x = rect.origin.x + rect.size.width/2;
            offset.x = -size.width/2;
            break;
        case 0x4:
            base.x = rect.origin.x;
            offset.x = 0;
            break;
        case 0x8:
            base.x = rect.origin.x + rect.size.width;
            offset.x = -size.width;
            break;
    }
    rect.size = size;
    rect.origin = offset;
    [heights release];
}

-(void)draw:(CGContextRef)context
{
    if(predrawedText) {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, base.x, base.y);
        CGContextRotateCTM(context, angle);
        //CGContextTranslateCTM(context, offset.x, offset.y);
        CGContextDrawLayerInRect(context, rect, predrawedText);
        CGContextRestoreGState(context);
    } else {
        // TODO
    }
}

-(void)dealloc
{
    CGLayerRelease(predrawedText);
    [font release];
    [super dealloc];
}

@end

@implementation Transfer

@synthesize stations;
@synthesize time;
@synthesize boundingBox;
@synthesize active;

-(id)initWithMap:(CityMap*)cityMap
{
    if((self = [super init])) {
        map = cityMap;
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
    [super dealloc];
}

-(void)addStation:(Station *)station
{
    if(station.transfer == self) return;
    NSAssert(station.transfer == nil, @"Station already in transfer");
    if([stations count] > 0) station.drawName = NO;
    station.transfer = self;
    [stations addObject:station];
    CGRect st = CGRectMake(station.pos.x - map->StationDiameter, station.pos.y - map->StationDiameter, map->StationDiameter*2.f, map->StationDiameter*2.f);
    if(CGRectIsNull(boundingBox)) boundingBox = st;
    else boundingBox = CGRectUnion(boundingBox, st);
}

-(void) drawTransferLikeLondon:(CGContextRef) context stations:(NSArray*)sts
{
    CGFloat blackW = map->StationDiameter / 5.f;
    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);				
    for(int i = 0; i<[sts count]; i++) {
        Station *st = [sts objectAtIndex:i];
        CGPoint p1 = st.pos;
        drawFilledCircle(context, p1.x, p1.y, map->StationDiameter);
        for(int j = i+1; j<[sts count]; j++) {
            Station *st2 = [sts objectAtIndex:j];
            CGPoint p2 = st2.pos;
            drawLine(context, p1.x, p1.y, p2.x, p2.y, map->StationDiameter*0.5f);
        }
    }
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    for(int i = 0; i<[sts count]; i++) {
        Station *st = [sts objectAtIndex:i];
        CGPoint p1 = st.pos;
        drawFilledCircle(context, p1.x, p1.y, map->StationDiameter - blackW);
        for(int j = i+1; j<[sts count]; j++) {
            Station *st2 = [sts objectAtIndex:j];
            CGPoint p2 = st2.pos;
            drawLine(context, p1.x, p1.y, p2.x, p2.y, map->StationDiameter*0.5f - blackW);
        }
    }
}

-(void) drawTransferLikeParis:(CGContextRef)context stations:(NSArray*)sts drawTerminals:(BOOL)terminals
{
    CGFloat blackW = map->LineWidth / 3.f;
    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);				
    for(int i = 0; i<[sts count]; i++) {
        Station *st = [sts objectAtIndex:i];
        CGPoint p1 = st.pos;
        for(int j = i+1; j<[sts count]; j++) {
            Station *st2 = [sts objectAtIndex:j];
            CGPoint p2 = st2.pos;
            CGFloat dx = (p1.x-p2.x);
            CGFloat dy = (p1.y-p2.y);
            CGFloat d2 = dx*dx + dy*dy;
            if(d2 > map->StationDiameter*map->StationDiameter*6) {
                drawFilledCircle(context, p1.x, p1.y, map->LineWidth);
                drawFilledCircle(context, p2.x, p2.y, map->LineWidth);
                drawLine(context, p1.x, p1.y, p2.x, p2.y, map->LineWidth);
            } else
                drawLine(context, p1.x, p1.y, p2.x, p2.y, map->LineWidth*2);
        }
    }
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    for(int i = 0; i<[sts count]; i++) {
        Station *st = [sts objectAtIndex:i];
        CGPoint p1 = st.pos;
        for(int j = i+1; j<[sts count]; j++) {
            Station *st2 = [sts objectAtIndex:j];
            CGPoint p2 = st2.pos;
            CGFloat dx = (p1.x-p2.x);
            CGFloat dy = (p1.y-p2.y);
            CGFloat d2 = dx*dx + dy*dy;
            if(d2 > map->StationDiameter*map->StationDiameter*6) {
                drawFilledCircle(context, p1.x, p1.y, map->LineWidth-blackW/2);
                drawFilledCircle(context, p2.x, p2.y, map->LineWidth-blackW/2);
                drawLine(context, p1.x, p1.y, p2.x, p2.y, map->LineWidth-blackW);
            } else 
                drawLine(context, p1.x, p1.y, p2.x, p2.y, map->LineWidth*2-blackW);
        }
    }
    if(terminals) for (Station *st in sts) {
        if(st.terminal) {
            CGPoint p1 = st.pos;
            CGContextSetFillColorWithColor(context, [st.line.color CGColor]);
            drawFilledCircle(context, p1.x, p1.y, map->LineWidth/2);
        }
    }
}

-(void) drawTransferLikeMoscow:(CGContextRef)context stations:(NSArray*)sts
{
    CGFloat blackW = map->LineWidth * 0.5f;
    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 0.6);
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 0.6);				
    for(int i = 0; i<[sts count]; i++) {
        Station *st = [sts objectAtIndex:i];
        CGPoint p1 = st.pos;
        for(int j = i+1; j<[sts count]; j++) {
            Station *st2 = [sts objectAtIndex:j];
            CGPoint p2 = st2.pos;
            drawLine(context, p1.x, p1.y, p2.x, p2.y, map->LineWidth*2);
        }
    }
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    for(int i = 0; i<[sts count]; i++) {
        Station *st = [sts objectAtIndex:i];
        CGPoint p1 = st.pos;
        for(int j = i+1; j<[sts count]; j++) {
            Station *st2 = [sts objectAtIndex:j];
            CGPoint p2 = st2.pos;
            drawLine(context, p1.x, p1.y, p2.x, p2.y, map->LineWidth*2-blackW);
        }
    }
    for (Station *st in stations) {
        CGPoint p1 = st.pos;
        CGContextSetFillColorWithColor(context, [st.line.color CGColor]);
        drawFilledCircle(context, p1.x, p1.y, map->LineWidth/2);
    }
}

-(void) drawTransferLikeHamburg:(CGContextRef)context stations:(NSArray*)sts
{
    CGRect r = CGRectZero;
    for (Station *s in sts) {
        CGRect r2 = CGRectMake(s.pos.x, s.pos.y, 0.0001, 0.0001);
        if(r.size.width == 0 && r.size.height == 0) r = r2;
        else r = CGRectUnion(r, r2);
    }
    CGFloat dd = map->StationDiameter - r.size.width;
    if(dd > 0) {
        r.size.width = map->StationDiameter;
        r.origin.x -= dd*0.5f;
    }
    dd = map->StationDiameter - r.size.height;
    if(dd > 0) {
        r.size.height = map->StationDiameter;
        r.origin.y -= dd * 0.5f;
    }
    CGContextSetRGBFillColor(context, 0.0f, 0.0f, 0.0f, 1.0f);
    CGContextFillRect(context, r);
    CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f);
    dd = 0.25f * map->LineWidth;
    r.origin.x += dd;
    r.origin.y += dd;
    r.size.width -= dd*2.f;
    r.size.height -= dd*2.f;
    CGContextFillRect(context, r);
}

-(void) drawTransferLikeVenice:(CGContextRef)context stations:(NSArray*)sts
{
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, map->LineWidth);
    for (Station *s in sts) {
        CGContextSetStrokeColorWithColor(context, [s.line.color CGColor]);
        //CGContextSetFillColorWithColor(context, [s.line.color CGColor]);
        for (Segment *seg in s.segment) {
            [seg draw:context];
        }
        for (Segment *seg in s.backSegment) {
            [seg draw:context];
        }
    }
}

-(void)draw:(CGContextRef)context
{
    if(transferLayer != nil) {
        CGContextDrawLayerInRect(context, boundingBox, transferLayer);
    } else {
        switch (map->TrKind) {
            case LIKE_LONDON:
                [self drawTransferLikeLondon:context stations:[stations allObjects]];
                break;
            case LIKE_PARIS:
                [self drawTransferLikeParis:context stations:[stations allObjects] drawTerminals:YES];
                break;
            case LIKE_MOSCOW:
                [self drawTransferLikeMoscow:context stations:[stations allObjects]];
                break;
            case LIKE_HAMBURG:
                [self drawTransferLikeHamburg:context stations:[stations allObjects]];
                break;
            case LIKE_VENICE:
                [self drawTransferLikeVenice:context stations:[stations allObjects]];
                break;
            case DONT_DRAW:
                break;
            case KINDS_NUM:
                NSAssert(NO, @"something went wrong...");
        }
    }
}

-(void)predraw:(CGContextRef)context
{
    if (transferLayer != nil) CGLayerRelease(transferLayer);
    CGSize size = CGSizeMake(boundingBox.size.width*map->PredrawScale, boundingBox.size.height*map->PredrawScale);
    transferLayer = CGLayerCreateWithContext(context, size, NULL);
    CGContextRef ctx = CGLayerGetContext(transferLayer);
    CGContextScaleCTM(ctx, map->PredrawScale, map->PredrawScale);
    CGContextTranslateCTM(ctx, -boundingBox.origin.x, -boundingBox.origin.y);
    switch (map->TrKind) {
        case LIKE_PARIS:
            [self drawTransferLikeParis:ctx stations:[stations allObjects] drawTerminals:YES];
            break;
        case LIKE_LONDON:
            [self drawTransferLikeLondon:ctx stations:[stations allObjects]];
            break;
        case LIKE_MOSCOW:
            [self drawTransferLikeMoscow:ctx stations:[stations allObjects]];
            break;
        case LIKE_HAMBURG:
            [self drawTransferLikeHamburg:ctx stations:[stations allObjects]];
            break;
        case LIKE_VENICE:
            [self drawTransferLikeVenice:ctx stations:[stations allObjects]];
            break;
        case DONT_DRAW:
            break;
        case KINDS_NUM:
            NSAssert(NO, @"something went wrong...");
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
        CGFloat SD2 = map->StationDiameter*map->StationDiameter*4;
        if(SD2 >= (dp.x * dp.x + dp.y * dp.y)) {
            CGFloat d = dA.x * dB.y - dA.y * dB.x;
            if(d == 0.f) {
                //NSLog(@"lines are paraleled, %@", s[0].name);
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
            
            boundingBox = CGRectMake(C2.x - map->StationDiameter, C2.y - map->StationDiameter, map->StationDiameter*2.f, map->StationDiameter*2.f);
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
@synthesize tapArea;
@synthesize tapTextArea;
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
@synthesize way1;
@synthesize way2;
@synthesize gpsCoords;
@synthesize forwardWay;
@synthesize backwardWay;

-(id)copyWithZone:(NSZone*)zone
{
    return [self retain];
}
-(BOOL) terminal { return links == 1; }

-(void) setPos:(CGPoint)_pos
{
    pos = _pos;
    boundingBox = CGRectMake(pos.x-map->StationDiameter/2, pos.y-map->StationDiameter/2, map->StationDiameter, map->StationDiameter);
}

-(id)initWithMap:(CityMap*)cityMap name:(NSString*)sname pos:(CGPoint)p index:(int)i rect:(CGRect)r andDriving:(NSString*)dr
{
    if((self = [super init])) {
        pos = p;
        map = cityMap;
        int SD = map->StationDiameter;
        boundingBox = CGRectMake(pos.x-SD/2, pos.y-SD/2, SD, SD);
        tapArea = CGRectMake(pos.x-SD, pos.y-SD, SD*2, SD*2);
        index = i;
        textRect = r;
        gpsCoords = CGPointZero;
        segment = [[NSMutableArray alloc] init];
        backSegment = [[NSMutableArray alloc] init];
        relation = [[NSMutableArray alloc] init];
        relationDriving = [[NSMutableArray alloc] init];
        sibling = [[NSMutableArray alloc] init];
        drawName = YES;
        active = YES;
        acceptBackLink = YES;
        transferDriving = [[NSMutableDictionary alloc] init];
        defaultTransferDriving = 0;
        transferWay = [[NSMutableDictionary alloc] init];
        reverseTransferWay = [[NSMutableDictionary alloc] init];
        defaultTransferWay = NOWAY;
        forwardWay = [[NSMutableArray alloc] init];
        backwardWay = [[NSMutableArray alloc] init];
        
        NSUInteger br = [sname rangeOfString:@"("].location;
        if(br == NSNotFound) {
            text = [[ComplexText alloc] initWithString:sname font:[UIFont fontWithName:map->TEXT_FONT size:map->FontSize] andRect:textRect];
            name = [text.string retain];
            tapTextArea = text.boundingBox;
        } else {
            text = [[ComplexText alloc] initWithString:[sname substringToIndex:br] font:[UIFont fontWithName:map->TEXT_FONT size:map->FontSize] andRect:textRect];
            name = [text.string retain];
            tapTextArea = text.boundingBox;
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
        
        CGSize s = [name sizeWithFont:[UIFont fontWithName:map->TEXT_FONT size:map->FontSize] constrainedToSize:textRect.size lineBreakMode:UILineBreakModeWordWrap];
        if(textRect.size.width < s.width) textRect.size.width = s.width;
        if(textRect.size.height < s.height) textRect.size.height = s.height;
    }
    return self;
}

-(void)dealloc
{
    [text release];
    [segment release];
    [backSegment release];
    [relation release];
    [relationDriving release];
    [sibling release];
    [transferDriving release];
    [transferWay release];
    [reverseTransferWay release];
    [forwardWay release];
    [backwardWay release];
    [super dealloc];
}

-(BOOL)addSibling:(Station *)st
{
    for (Station *s in sibling) {
        if(s == st) return NO;
    }
    [sibling addObject:st];
    return YES;
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
    [text draw:context];
}

-(void)drawStation:(CGContextRef)context
{
    if(map->StKind == LIKE_LONDON) {
        CGContextSetLineCap(context, kCGLineCapSquare);
        CGFloat lw = map->LineWidth * 0.5f;
        CGContextSetLineWidth(context, map->LineWidth);
        CGPoint p = CGPointMake(pos.x + lw*normal.x, pos.y + lw*normal.y);
        CGContextMoveToPoint(context, p.x, p.y);
        CGContextAddLineToPoint(context, p.x + normal.x, p.y + normal.y);
        CGContextStrokePath(context);
    } else if(map->StKind == LIKE_HAMBURG) {
        CGContextSaveGState(context);
        CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
        CGContextSetLineCap(context, kCGLineCapSquare);
        CGFloat lw = map->LineWidth * 0.5f;
        CGContextSetLineWidth(context, lw);
        CGPoint p = CGPointMake(pos.x + lw*normal.x, pos.y + lw*normal.y);
        CGContextMoveToPoint(context, pos.x, pos.y);
        CGContextAddLineToPoint(context, p.x, p.y);
        CGContextStrokePath(context);
        CGContextRestoreGState(context);
    }
}

-(void)predraw:(CGContextRef) context
{
    [text predraw:context scale:map->PredrawScale];
}

-(void) makeSegments
{
    int drv = -1;
    if([relationDriving count] > 0) drv = 0;
    for(int i=0; i<[sibling count]; i++) {
        Station *st = [sibling objectAtIndex:i];
        int curDrv = driving;
        if(drv >= 0) curDrv = [[relationDriving objectAtIndex:drv] intValue];
        [segment addObject:[[[Segment alloc] initFromStation:self toStation:st withDriving:curDrv] autorelease]];
        if(drv < [relationDriving count]-1) drv ++;
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

-(void)setTransferDriving:(CGFloat)_driving to:(Station *)target
{
    if(defaultTransferDriving == 0) defaultTransferDriving = _driving;
    [transferDriving setObject:[NSNumber numberWithFloat:_driving] forKey:target];
}

-(void)setTransferWay:(int)way to:(Station *)target
{
    if(defaultTransferWay == NOWAY) defaultTransferWay = way;
    [transferWay setObject:[NSNumber numberWithInt:way] forKey:target];
}

-(void)setTransferWay:(int)way from:(Station *)target
{
    [reverseTransferWay setObject:[NSNumber numberWithInt:way] forKey:target];
}

-(void)setTransferWays:(NSArray *)ways to:(Station *)target
{
    [transferWay setObject:ways forKey:target];
}

-(CGFloat)transferDrivingTo:(Station *)target
{
    NSNumber *dr = [transferDriving objectForKey:target];
    if(dr != nil) return [dr floatValue];
    return defaultTransferDriving;
}

-(int)transferWayTo:(Station *)target
{
    id w = [transferWay objectForKey:target];
    if(w == nil) return defaultTransferWay;
    if([w isKindOfClass:[NSArray class]]) return [[w objectAtIndex:0] intValue];
    else if ([w isKindOfClass:[NSNumber class]]) return [w intValue];
    return defaultTransferWay;
}

-(int)transferWayFrom:(Station *)target
{
    NSNumber *w = [reverseTransferWay objectForKey:target];
    if(w != nil) return [w intValue];
    return NOWAY;
}

-(BOOL)checkForwardWay:(Station *)st
{
    if([forwardWay containsObject:st]) return true;
    if([backwardWay containsObject:st]) return false;
    // unknown way!
    NSLog(@"Warning: unknown way from %@ to %@", name, st.name);
    return false;
}

-(int)megaTransferWayFrom:(Station *)prevStation to:(Station *)transferStation
{
    NSArray *ways = [transferWay objectForKey:transferStation];
    if(ways == nil) {
        NSLog(@"no way from %@ to %@", name, transferStation.name);
        return NOWAY;
    }
    BOOL prevForwardWay = [prevStation checkForwardWay:self];
    if(prevForwardWay) {
        // we should choose one from first and second transfer ways
        return [[ways objectAtIndex:0] intValue];  // or 1
    } else {
        // choose from third and fourth ways
        return [[ways objectAtIndex:2] intValue]; // or 3
    }
}

-(int) megaTransferWayFrom:(Station *)prevStation to:(Station *)transferStation andNextStation:(Station *)nextStation
{
    NSArray *ways = [transferWay objectForKey:transferStation];
    if(ways == nil) {
        NSLog(@"no way from %@ to %@", name, transferStation.name);
        return NOWAY;
    }
    BOOL prevForwardWay = [prevStation checkForwardWay:self];
    BOOL nextForwardWay = [transferStation checkForwardWay:nextStation];
    if(prevForwardWay && nextForwardWay) return [[ways objectAtIndex:0] intValue];
    else if(prevForwardWay && !nextForwardWay) return [[ways objectAtIndex:1] intValue];
    else if(!prevForwardWay && nextForwardWay) return [[ways objectAtIndex:2] intValue];
    else if(!prevForwardWay && !nextForwardWay) return [[ways objectAtIndex:3] intValue];
    return [[ways lastObject] intValue];
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
@synthesize isSpline;

-(NSArray*)splinePoints {
    return splinePoints;
}

-(id)initFromStation:(Station *)from toStation:(Station *)to withDriving:(int)dr
{
    if((self = [super init])) {
        active = YES;
        isSpline = NO;
        start = from;
        end = to;
        [end.backSegment addObject:self];
        driving = dr;
        //NSAssert(driving > 0, @"illegal driving");
        if(driving <= 0) NSLog(@"zero driving from %@ to %@", from.name, to.name);
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
    [super dealloc];
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
    if(!isSpline) {
        [self predrawMultiline];
        return;
    }
    [splinePoints addObject:[NSValue valueWithCGPoint:CGPointMake(end.pos.x, end.pos.y)]];
    [splinePoints insertObject:[NSValue valueWithCGPoint:CGPointMake(start.pos.x, start.pos.y)] atIndex:0];
    NSMutableArray *newSplinePoints = [[NSMutableArray alloc] init];
    for(int i=1; i<[splinePoints count]-1; i++) {
        TangentPoint *p = [[[TangentPoint alloc] initWithPoint:[[splinePoints objectAtIndex:i] CGPointValue]] autorelease];
        [p calcTangentFrom:[[splinePoints objectAtIndex:i-1] CGPointValue] to:[[splinePoints objectAtIndex:i+1] CGPointValue]];
        [newSplinePoints addObject:p];
    }
    [splinePoints release];
    splinePoints = newSplinePoints;
    [self predrawSpline];
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
    if(splinePoints) {
        CGContextMoveToPoint(context, 0, 0);
        CGContextAddPath(context, path);
        CGContextStrokePath(context);
    } else {
        CGContextMoveToPoint(context, start.pos.x, start.pos.y);
        CGContextAddLineToPoint(context, end.pos.x, end.pos.y);
        CGContextStrokePath(context);
    }
}

-(void)predraw
{
    if(isSpline) [self predrawSpline];
    else [self predrawMultiline];
}

-(void)predrawMultiline
{
    if(splinePoints) {
        if(path != nil) CGPathRelease(path);
        path = CGPathCreateMutable();
        CGPathMoveToPoint(path, nil, start.pos.x, start.pos.y);
        for (int i=0; i < [splinePoints count]; i++) {
            CGPoint p = [[splinePoints objectAtIndex:i] CGPointValue];
            CGPathAddLineToPoint(path, nil, p.x, p.y);
        }
        CGPathAddLineToPoint(path, nil, end.pos.x, end.pos.y);
    }
}

-(void)predrawSpline
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

@synthesize name;
@synthesize stations;
@synthesize index;
@synthesize boundingBox;
@synthesize shortName;
@synthesize stationLayer;
@synthesize disabledStationLayer;

-(UIColor*) color {
    return _color;
}

-(void) setColor:(UIColor *)color
{
    [_color release];
    [_disabledColor release];
    _color = [color retain];
    CGFloat r, g, b, M, m, sd;
    const CGFloat* rgba = CGColorGetComponents([color CGColor]);
    r = rgba[0];
    g = rgba[1];
    b = rgba[2];

    // set brightness to 90%
    M = MAX(r, MAX(g, b));
    sd = 0.9f / M;
    r *= sd;
    g *= sd;
    b *= sd;
    M = 0.9f;
    
    // set saturation to 10%
    m = MIN(r, MIN(g, b));
    sd = (0.1f * M) / (M-m);
    r = M - (M-r)*sd;
    g = M - (M-g)*sd;
    b = M - (M-b)*sd;
    
    _disabledColor = [[UIColor colorWithRed:r green:g blue:b alpha:1.0f] retain];
    
}

-(void)postInit
{
    for(Station *st in stations) {
        [st makeSegments];
        boundingBox = CGRectUnion(boundingBox, st.boundingBox);
        boundingBox = CGRectUnion(boundingBox, st.textRect);
        for (Segment *seg in st.segment) {
            boundingBox = CGRectUnion(boundingBox, seg.boundingBox);
        }
    }
}

-(id)initWithMap:(CityMap*)cityMap andName:(NSString*)n
{
    if((self = [super init])) {
        map = cityMap;
        name = [n retain];
        shortName = [[[n componentsSeparatedByString:@" "] lastObject] retain];
        stations = [[NSMutableArray alloc] init];
        stationLayer = nil;
        boundingBox = CGRectNull;
        twoStepsDraw = NO;
    }
    return self;
}

-(id)initWithMap:(CityMap*)cityMap name:(NSString*)n stations:(NSString *)station driving:(NSString *)driving coordinates:(NSString *)coordinates rects:(NSString *)rects
{
    if((self = [super init])) {
        map = cityMap;
        name = [n retain];
        shortName = [[[n componentsSeparatedByString:@" "] lastObject] retain];
        stations = [[NSMutableArray alloc] init];
        stationLayer = nil;
        boundingBox = CGRectNull;
        twoStepsDraw = NO;
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
            Station *st = [[[Station alloc] initWithMap:map name:[sts objectAtIndex:i] pos:CGPointMake(x, y) index:i rect:CGRectMake(tx, ty, tw, th) andDriving:drv] autorelease];
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
            NSLog(@"read station: %@", st.name);

            MStation *station = [NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:[MHelper sharedHelper].managedObjectContext];
            station.name=st.name;
            station.isFavorite=[NSNumber numberWithInt:0];
            station.lines=[[MHelper sharedHelper] lineByName:name ];
            station.index = [NSNumber numberWithInt:i];
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
        [self postInit];
    }
    return self;
}

-(void)dealloc
{
    [stations release];
    [_color release];
    [_disabledColor release];
    [name release];
    [shortName release];
    CGLayerRelease(stationLayer);
    CGLayerRelease(disabledStationLayer);
    [super dealloc];
}

-(void)draw:(CGContextRef)context inRect:(CGRect)rect
{
    CGContextSetLineCap(context, kCGLineCapRound);

    // all line is active
    CGContextSetStrokeColorWithColor(context, [_color CGColor]);
    //CGContextSetFillColorWithColor(context, [_color CGColor]);
    CGContextSetLineWidth(context, map->LineWidth);
    for (Station *s in stations) {
        [s draw:context inRect:rect];
    }
    for (Station *s in stations) {
        if(s.transfer == nil && CGRectIntersectsRect(rect, s.boundingBox)) {
            if(map->StKind == LIKE_LONDON || map->StKind == LIKE_HAMBURG)
                [s drawStation:context];
            else
                CGContextDrawLayerInRect(context, s.boundingBox, stationLayer);
        }
    }
}

-(void)drawActive:(CGContextRef)context inRect:(CGRect)rect
{
    CGContextSetStrokeColorWithColor(context, [_color CGColor]);
    CGContextSetLineWidth(context, map->LineWidth);
    for (Station *s in stations) {
        for (Segment *seg in s.segment) {
            if(seg.active && CGRectIntersectsRect(rect, seg.boundingBox))
                [seg draw:context];
        }
    }
    CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.f] CGColor]);
    CGContextSetLineWidth(context, map->LineWidth*0.25f);
    for (Station *s in stations) {
        for (Segment *seg in s.segment) {
            if(seg.active && CGRectIntersectsRect(rect, seg.boundingBox))
                [seg draw:context];
        }
    }
    for (Station *s in stations) {
        if(s.active && s.transfer == nil && CGRectIntersectsRect(rect, s.boundingBox)) {
            if(map->StKind == LIKE_LONDON || map->StKind == LIKE_HAMBURG)
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
    NSLog(@"Error: no segment between %@ and %@ on line %@", station1, station2, name);
    return nil;
}

-(Segment*)getSegmentFrom:(NSString *)station1 to:(NSString *)station2
{
    for (Station *s in stations) {
        if([s.name isEqualToString:station1] || [s.name isEqualToString:station2]) {
            for (Segment *seg in s.segment) {
                if([seg.end.name isEqualToString:station1] || [seg.end.name isEqualToString:station2]) {
                    return seg;
                }
            }
        }
    }
    return nil;
}


-(void)setEnabled:(BOOL)en
{
    twoStepsDraw = !en;
    for (Station *s in stations) {
        s.active = en;
        for(Segment *seg in s.segment) {
            seg.active = en;
        }
    }
}

-(void)additionalPointsBetween:(NSString *)station1 and:(NSString *)station2 points:(NSArray *)points
{
    NSString *st1 = [[ComplexText makePlainString:station1] uppercaseString];
    NSString *st2 = [[ComplexText makePlainString:station2] uppercaseString];
    for (Station *s in stations) {
        BOOL search = NO;
        BOOL rev = NO;
        if([[s.name uppercaseString] isEqualToString:st1]) {
            search = YES;
        }
        else if([[s.name uppercaseString] isEqualToString:st2]) {
            search = rev = YES;
        }
        if(search) {
            NSMutableArray *allseg = [NSMutableArray arrayWithArray:s.segment];
            [allseg addObjectsFromArray:s.backSegment];
            for (Segment *seg in allseg) {
                if(([[seg.end.name uppercaseString] isEqualToString:st1] && rev)
                   || ([[seg.end.name uppercaseString] isEqualToString:st2] && !rev)) {
                    NSEnumerator *enumer;
                    if(rev) enumer = [points reverseObjectEnumerator];
                    else enumer = [points objectEnumerator];
                    for (NSString *p in enumer) {
                        if([p isEqualToString:@"spline"]) {
                            seg.isSpline = YES;
                            continue;
                        }
                        NSArray *coord = [p componentsSeparatedByString:@","];
                        [seg appendPoint:CGPointMake([[coord objectAtIndex:0] intValue], [[coord objectAtIndex:1] intValue])];
                    }
                    //[seg calcSpline];
                    return;
                }
            }
        }
    }
    NSLog(@"can't add point between '%@' and '%@' in line '%@'", station1, station2, name);
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
    if(map->StKind == LIKE_LONDON || map->StKind == LIKE_HAMBURG || map->StKind == LIKE_VENICE) return;
    if(stationLayer != nil) CGLayerRelease(stationLayer);
    // make predrawed staion point
    CGFloat ssize = map->StationDiameter*map->PredrawScale;
    CGFloat hsize = ssize/2;
    stationLayer = CGLayerCreateWithContext(context, CGSizeMake(ssize, ssize), NULL);
    CGContextRef ctx = CGLayerGetContext(stationLayer);
    switch(map->StKind) {
        case LIKE_MOSCOW:
            CGContextSetRGBFillColor(ctx, 0, 0, 0, 1.0);
            CGContextFillEllipseInRect(ctx, CGRectMake(0, 0, ssize, ssize));
            CGContextSetFillColorWithColor(ctx, [_color CGColor]);
            drawFilledCircle(ctx, hsize, hsize, hsize-map->PredrawScale/2);
            break;
        case LIKE_PARIS:
            CGContextSetFillColorWithColor(ctx, [_color CGColor]);
            drawFilledCircle(ctx, hsize, hsize, hsize);
            break;
        case LIKE_LONDON:
        case LIKE_HAMBURG:
        case LIKE_VENICE:
            break;
    }

    if(disabledStationLayer != nil) CGLayerRelease(disabledStationLayer);
    // make predrawed staion point
    disabledStationLayer = CGLayerCreateWithContext(context, CGSizeMake(ssize, ssize), NULL);
    ctx = CGLayerGetContext(disabledStationLayer);
    switch(map->StKind) {
        case LIKE_MOSCOW:
            CGContextSetRGBFillColor(ctx, 0, 0, 0, 1.0);
            CGContextFillEllipseInRect(ctx, CGRectMake(0, 0, ssize, ssize));
            CGContextSetFillColorWithColor(ctx, [_disabledColor CGColor]);
            drawFilledCircle(ctx, hsize, hsize, hsize-map->PredrawScale/2);
            break;
        case LIKE_PARIS:
            CGContextSetFillColorWithColor(ctx, [_disabledColor CGColor]);
            drawFilledCircle(ctx, hsize, hsize, hsize);
            break;
        case LIKE_LONDON:
        case LIKE_HAMBURG:
        case LIKE_VENICE:
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
@synthesize activeExtent;
@synthesize activePath;
@synthesize maxScale;
@synthesize thisMapName;
@synthesize pathToMap;
@synthesize pathStationsList;
@synthesize mapLines;
@synthesize currentScale;
@synthesize backgroundImageFile;
@synthesize foregroundImageFile;

-(StationKind) stationKind { return StKind; }
-(void) setStationKind:(StationKind)stationKind { StKind = stationKind; }
-(StationKind) transferKind { return TrKind; }
-(void) setTransferKind:(StationKind)transferKind { TrKind = transferKind; }

-(id) init {
    self = [super init];
	[self initVars];
    return self;
}

-(void) initVars {

    PredrawScale = 2.f;
    LineWidth = 4.f;
    StationDiameter = 8.f;
    FontSize = 7.f;
    StKind = LIKE_PARIS;
    TrKind = LIKE_PARIS;
    TEXT_FONT = @"Arial-BoldMT";
   
    transfers = [[NSMutableArray alloc] init];
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

    self.thisMapName=mapName;
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *mapDirPath = [cacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",[mapName lowercaseString]]];
    
    NSString *mapFile = [NSString stringWithString:@""];
    NSString *trpFile = [NSString stringWithString:@""];
    NSString *trpNewFile =  [NSString stringWithString:@""];
    BOOL useTrpNew=NO;
    
    if ([[manager contentsOfDirectoryAtPath:mapDirPath error:nil] count]>0) {
        NSDirectoryEnumerator *dirEnum = [manager enumeratorAtPath:mapDirPath];
        NSString *file;
        
        while (file = [dirEnum nextObject]) {
            if ([[file pathExtension] isEqualToString: @"map"]) {
                mapFile=[mapDirPath stringByAppendingPathComponent:file];
            } else if ([[file pathExtension] isEqualToString: @"trp"]) {
                trpFile=[mapDirPath stringByAppendingPathComponent:file];
            } else if ([[file pathExtension] isEqualToString: @"trpnew"]) {
                trpNewFile=[mapDirPath stringByAppendingPathComponent:file];
                useTrpNew=YES;
            }
        }
    } 
    
    if (useTrpNew) {
        trpFile=trpNewFile;
    }
    
    NSArray *files;
    
    // если не получается взять файлы из директории cache - то пытаемся найти их в бандле
    if ([mapFile isEqual:@""] || [trpFile isEqual:@""]) {
        
        files = [[NSBundle mainBundle] pathsForResourcesOfType:@"map" inDirectory:[NSString stringWithFormat:@"maps/%@", mapName]];
        if([files count] <= 0) {
            NSLog(@"map file not found: %@", mapName);
            return;
        }
        mapFile = [files objectAtIndex:0];
        
        files = [[NSBundle mainBundle] pathsForResourcesOfType:@"trpnew" inDirectory:[NSString stringWithFormat:@"maps/%@", mapName]];
        if([files count] <= 0) {
            files = [[NSBundle mainBundle] pathsForResourcesOfType:@"trp" inDirectory:[NSString stringWithFormat:@"maps/%@", mapName]];
            if([files count] <= 0) {
                NSLog(@"trp file not found: %@", mapName);
                return;
            } else {
                NSString *trpFile = [files objectAtIndex:0];
                [self loadOldMap:mapFile trp:trpFile];
            }
        } else {
            NSString *trpFile = [files objectAtIndex:0];
            [self loadNewMap:mapFile trp:trpFile];
        }

    } else {
        if (useTrpNew) {
            [self loadNewMap:mapFile trp:trpFile];
        } else {
            [self loadOldMap:mapFile trp:trpFile];
        }
    }   
    
    self.pathToMap = [mapFile stringByDeletingLastPathComponent];
    NSString *routePath = [NSString stringWithFormat:@"%@/route", self.pathToMap];
    
    [[MHelper sharedHelper] readHistoryFile:mapName];
    [[MHelper sharedHelper] readBookmarkFile:mapName];
    
    if([mapName isEqualToString:@"venice"] ||
       [mapName isEqualToString:@"hamburg"]) {
        schedule = [[Schedule alloc] initSchedule:@"routes" path:routePath];
        for (Line *l in mapLines) {
            if([schedule setIndex:l.index forLine:l.name]) {
                for (Station *s in l.stations) {
                    [schedule checkStation:s.name line:l.name];
                }
            }
        }
    }
}

-(void) loadOldMap:(NSString *)mapFile trp:(NSString *)trpFile {

	int err;
	INIParser* parserTrp, *parserMap;

	parserTrp = [[INIParser alloc] init];
	parserMap = [[INIParser alloc] init];
	err = [parserTrp parse:[trpFile UTF8String]];
    err = [parserMap parse:[mapFile UTF8String]];

    NSString *bgfile = [parserMap get:@"ImageFileName" section:@"Options"];
    if([bgfile length] > 0) backgroundImageFile = [bgfile retain];
    else backgroundImageFile = nil;
    bgfile = [parserMap get:@"UpperImageFileName" section:@"Options"];
    if([bgfile length] > 0) foregroundImageFile = [bgfile retain];
    else foregroundImageFile = nil;
    int val = [[parserMap get:@"LinesWidth" section:@"Options"] intValue];
    if(val != 0) LineWidth = val;
    val = [[parserMap get:@"StationDiameter" section:@"Options"] intValue];
    if(val != 0) StationDiameter = val;
    FontSize = StationDiameter;
    val = [[parserMap get:@"DisplayTransfers" section:@"Options"] intValue];
    if(val >= 0 && val < KINDS_NUM) TrKind = val;
    val = [[parserMap get:@"DisplayStations" section:@"Options"] intValue];
    if(val >= 0 && val < KINDS_NUM) StKind = val;
    val = [[parserMap get:@"FontSize" section:@"Options"] intValue];
    if(val > 0) FontSize = val;
    float sc = [[parserMap get:@"MaxScale" section:@"Options"] floatValue];
    if(sc != 0.f) {
        maxScale = sc;
        PredrawScale = maxScale;
    }
    BOOL tuneEnabled = [[parserMap get:@"TuneTransfers" section:@"Options"] boolValue];
	
	_w = 0;
	_h = 0;
    CGRect boundingBox = CGRectNull;
    int index = 1;
	for (int i = 1; true; i++) {
		NSString *sectionName = [NSString stringWithFormat:@"Line%d", i ];
        if([parserTrp getSection:sectionName] == nil) break;
		NSString *lineName = [parserTrp get:@"Name" section:sectionName];
        if(lineName == nil) continue;
        NSLog(@"read line: %@", lineName);

		NSString *colors = [parserMap get:@"Color" section:lineName];
		NSString *coords = [parserMap get:@"Coordinates" section:lineName];
		NSString *coordsText = [parserMap get:@"Rects" section:lineName];
		NSString *stations = [parserTrp get:@"Stations" section:sectionName];
		NSString *coordsTime = [parserTrp get:@"Driving" section:sectionName];
        if([coords length] == 0 || [coordsText length] == 0 || [stations length] == 0 || [coordsTime length] == 0) continue;
		
        MLine *newLine = [NSEntityDescription insertNewObjectForEntityForName:@"Line" inManagedObjectContext:[MHelper sharedHelper].managedObjectContext];
        newLine.name=lineName;
        newLine.index = [[[NSNumber alloc] initWithInt:index] autorelease];
        newLine.color = [self colorForHex:colors];

        // [self processLinesStations:stations	:i];
        
        Line *l = [[[Line alloc] initWithMap:self name:lineName stations:stations driving:coordsTime coordinates:coords rects:coordsText] autorelease];
        l.index = index;
        l.color = [self colorForHex:colors];
        [mapLines addObject:l];
        boundingBox = CGRectUnion(boundingBox, l.boundingBox);
        index ++;
	}
    [[MHelper sharedHelper] saveContext];
    _w = boundingBox.origin.x * 2 + boundingBox.size.width;
    _h = boundingBox.origin.y * 2 + boundingBox.size.height;
		
	INISection *section = [parserMap getSection:@"AdditionalNodes"];
	for (NSString* key in section.allKeys) {
		NSString *value = [section retrieve:key];
		[self processAddNodes:value];
	}
	INISection *section2 = [parserTrp getSection:@"Transfers"];
	for (NSString* key in section2.allKeys) {
		NSString *value = [section2 retrieve:key];
		[self processTransfers:value];
	}
	
	[parserMap release];
    [parserTrp release];
    
    for (Line *l in mapLines) {
        [l calcStations];
    }
    
    if(tuneEnabled) {
        for (Transfer* tr in transfers) {
            [tr tuneStations];
        }
    }
    
    for (Line *l in mapLines) {
        for (Station *st in l.stations) {
            for (Segment *seg in st.segment) {
                [seg calcSpline];
            }
        }
    }
    // для ретиновских устройств генерируем предварительно отрисованные данные в двойном размере
    int scale = [[UIScreen mainScreen] scale];
    if(scale > 1) PredrawScale *= scale;

    [self calcGraph];
    [self predraw];
}

-(void) loadNewMap:(NSString *)mapFile trp:(NSString *)trpFile {

	INIParser* parserTrp, *parserMap;
	
	int err;
	parserTrp = [[INIParser alloc] init];
	parserMap = [[INIParser alloc] init];
	err = [parserTrp parse:[trpFile UTF8String]];
    err = [parserMap parse:[mapFile UTF8String]];
    
    NSString *bgfile = [parserMap get:@"ImageFileName" section:@"Options"];
    if([bgfile length] > 0) backgroundImageFile = [bgfile retain];
    else backgroundImageFile = nil;
    bgfile = [parserMap get:@"UpperImageFileName" section:@"Options"];
    if([bgfile length] > 0) foregroundImageFile = [bgfile retain];
    else foregroundImageFile = nil;
    int val = [[parserMap get:@"LinesWidth" section:@"Options"] intValue];
    if(val != 0) LineWidth = val;
    val = [[parserMap get:@"StationDiameter" section:@"Options"] intValue];
    if(val != 0) StationDiameter = val;
    FontSize = StationDiameter;
    val = [[parserMap get:@"DisplayTransfers" section:@"Options"] intValue];
    if(val >= 0 && val < KINDS_NUM) TrKind = val;
    val = [[parserMap get:@"DisplayStations" section:@"Options"] intValue];
    if(val >= 0 && val < KINDS_NUM) StKind = val;
    val = [[parserMap get:@"FontSize" section:@"Options"] intValue];
    if(val > 0) FontSize = val;
    float sc = [[parserMap get:@"MaxScale" section:@"Options"] floatValue];
    if(sc != 0.f) {
        maxScale = sc;
        PredrawScale = maxScale;
    }
    BOOL tuneEnabled = [[parserMap get:@"TuneTransfers" section:@"Options"] boolValue];
	
	_w = 0;
	_h = 0;
    CGRect boundingBox = CGRectNull;
    int index = 1;
	for (int i = 1; true; i++) {
		NSString *sectionName = [NSString stringWithFormat:@"Line%d", i ];
		NSString *lineName = [parserTrp get:@"Name" section:sectionName];
        if(lineName == nil) break;
        NSLog(@"read line: %@", lineName);
        
		NSString *colors = [parserMap get:@"Color" section:lineName];
        NSArray *coords = [[parserMap get:@"Coordinates" section:lineName] componentsSeparatedByString:@", "];
        NSArray *coordsText = [[parserMap get:@"Rects" section:lineName] componentsSeparatedByString:@", "];
        if([coords count] == 0 || [coordsText count] == 0) break;

        INISection *sect = [parserTrp getSection:sectionName];
        Line *l = [[[Line alloc] initWithMap:self andName:lineName] autorelease];
        l.index = index;
        l.color = [self colorForHex:colors];
        [mapLines addObject:l];
        MLine *newLine = [NSEntityDescription insertNewObjectForEntityForName:@"Line" inManagedObjectContext:[MHelper sharedHelper].managedObjectContext];
        newLine.name=lineName;
        newLine.index = [NSNumber numberWithInt:index];
        newLine.color = [self colorForHex:colors];
        
        int si = 0;
        //NSArray *keys = [[sect.assignments allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        NSArray *keys = [sect allKeys];
        NSMutableArray *branches = [[[NSMutableArray alloc] init] autorelease];
        NSMutableArray *drivings = [[[NSMutableArray alloc] init] autorelease];
        NSMutableDictionary *stations = [[[NSMutableDictionary alloc] init] autorelease];
        for (NSString* key in keys) {
            NSString *value = [sect.assignments objectForKey:key];
            if([value length] <= 0) continue;
            if([key isEqualToString:@"NAME"]) {
                // skip
            } else if ([key rangeOfString:@"BRANCH"].location != NSNotFound) {
                // branch
                //NSLog(@"Branch %@", value);
                [branches addObject:value];
            } else if ([key rangeOfString:@"DRIVING"].location != NSNotFound) {
                // driving
                //NSLog(@"Driving %@", value);
                [drivings addObject:value];
            } else {
                // station
                if(si >= [coords count]) {
                    NSLog(@"ERROR: Station %@ doesn't have coordinates!", value);
                    continue;
                }
                NSArray *stn = [value componentsSeparatedByString:@"\t"];
                NSString *sncr = [stn objectAtIndex:0];
                NSInteger sp = [sncr rangeOfString:@" " options:NSBackwardsSearch].location;
                NSString *stationName = [[sncr substringToIndex:sp] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ];
                NSArray *gpsCoords = [[sncr substringFromIndex:sp] componentsSeparatedByString:@","];
                Station *st = nil;
                for (Station *ss in l.stations) {
                    if([ss.name isEqualToString:stationName]) {
                        st = ss;
                        break;
                    }
                }
                if(st == nil) {
                    NSArray *coord_x_y = [[coords objectAtIndex:si] componentsSeparatedByString:@","];
                    int x = [[coord_x_y objectAtIndex:0] intValue];
                    int y = [[coord_x_y objectAtIndex:1] intValue];
                    NSArray *coord_text = [[coordsText objectAtIndex:si] componentsSeparatedByString:@","];
                    int tx = [[coord_text objectAtIndex:0] intValue];
                    int ty = [[coord_text objectAtIndex:1] intValue];
                    int tw = [[coord_text objectAtIndex:2] intValue];
                    int th = [[coord_text objectAtIndex:3] intValue];
                    st = [[[Station alloc] initWithMap:self name:stationName pos:CGPointMake(x, y) index:si rect:CGRectMake(tx, ty, tw, th) andDriving:0] autorelease];
                    st.line = l;
                    st.gpsCoords = CGPointMake([[gpsCoords objectAtIndex:0] floatValue], [[gpsCoords objectAtIndex:1] floatValue]);
                    [l.stations addObject:st];
                    MStation *station = [NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:[MHelper sharedHelper].managedObjectContext];
                    station.name=st.name;
                    station.isFavorite=[NSNumber numberWithInt:0];
                    station.lines=newLine;
                    station.index = [NSNumber numberWithInt:si];
                    si ++;
                    NSLog(@"read station %@", st.name);
                }
                [stations setValue:st forKey:key];
                if([stn count] >= 3) st.way1 = StringToWay([stn objectAtIndex:[stn count]-2]);
                if([stn count] >= 2) st.way2 = StringToWay([stn lastObject]);
            }
        }
        int brn = MIN([branches count], [drivings count]);
        for(int bi=0; bi<brn; bi++) {
            int direction = 0; // none
            NSString *br = [branches objectAtIndex:bi];
            NSArray *dr = [[drivings objectAtIndex:bi] componentsSeparatedByString:@","];
            NSString *brdir = [br substringToIndex:2];
            if([brdir isEqualToString:@"<>"] || [brdir isEqualToString:@"><"]) {
                direction = 3;
                br = [br substringFromIndex:2];
            } else {
                if([brdir characterAtIndex:0] == '<') {
                    // backward
                    direction = 1; 
                    br = [br substringFromIndex:1];
                } else if([brdir characterAtIndex:0] == '>') {
                    // forward
                    direction = 2; 
                    br = [br substringFromIndex:1];
                } else {
                    direction = 3; // both
                }
            }
            NSArray *br1 = [br componentsSeparatedByString:@","];
            int dri = 0;
            Station *st = nil;
            for (NSString *br2 in br1) {
                NSArray *br3 = [br2 componentsSeparatedByString:@"."];
                int first = [[br3 objectAtIndex:0] intValue];
                int last = [[br3 lastObject] intValue];
                for(int sti = first; sti<=last; sti ++, dri++) {
                    Station *st2 = [stations objectForKey:[NSString stringWithFormat:@"%d", sti]];
                    if(st != nil && st2 != nil) {
                        if([st addSibling:st2]) {
                            NSString *driving = nil;
                            if(dri <= [dr count]) driving = [dr objectAtIndex:dri-1];
                            else {
                                driving = @"0";
                                NSLog(@"ERROR: No driving for station %@!", st.name);
                            }
                            [st.relationDriving addObject:driving];
                            if(direction & 0x2) {  // forward
                                [graph addEdgeFromNode:[GraphNode nodeWithName:st.name andLine:i] toNode:[GraphNode nodeWithName:st2.name andLine:i] withWeight:[driving floatValue]];
                                [st setTransferWay:st.way1 to:st2];
                                [st2 setTransferWay:st2.way1 from:st];
                            }
                            if(direction & 0x1) {  // backward
                                [graph addEdgeFromNode:[GraphNode nodeWithName:st2.name andLine:i] toNode:[GraphNode nodeWithName:st.name andLine:i] withWeight:[driving floatValue]];
                                [st setTransferWay:st.way2 from:st2];
                                [st2 setTransferWay:st2.way2 to:st];
                            }
                            [st.forwardWay addObject:st2];
                            [st2.backwardWay addObject:st];
                        }
                    }
                    st = st2;
                }
            }
        }
        [l postInit];
		
        boundingBox = CGRectUnion(boundingBox, l.boundingBox);
        index ++;
	}
    [[MHelper sharedHelper] saveContext];
    _w = boundingBox.origin.x * 2 + boundingBox.size.width;
    _h = boundingBox.origin.y * 2 + boundingBox.size.height;
    
	INISection *section = [parserMap getSection:@"AdditionalNodes"];
	for (NSString* key in section.allKeys) {
		NSString *value = [section retrieve:key];
		[self processAddNodes:value];
	}
	INISection *section2 = [parserTrp getSection:@"Transfers"];
	for (NSString* key in section2.allKeys) {
		NSString *value = [section2 retrieve:key];
		[self processTransfers2:value];
	}
	
	[parserMap release];
    [parserTrp release];
    
    for (Line *l in mapLines) {
        [l calcStations];
    }
    
    if(tuneEnabled) {
        for (Transfer* tr in transfers) {
            [tr tuneStations];
        }
    }
    
    for (Line *l in mapLines) {
        for (Station *st in l.stations) {
            for (Segment *seg in st.segment) {
                [seg calcSpline];
            }
        }
    }
    // для ретиновских устройств генерируем предварительно отрисованные данные в двойном размере
    int scale = [[UIScreen mainScreen] scale];
    if(scale > 1) PredrawScale *= scale;
    
    [self processTransfersForGraph2];
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

-(NSDictionary*) calcPath :(NSString*) firstStation :(NSString*) secondStation :(NSInteger) firstStationLineNum :(NSInteger)secondStationLineNum {

    if(schedule != nil) {
        NSArray *path = [schedule findPathFrom:firstStation to:secondStation];
        NSLog(@"schedule path is %@", path);
        return [NSDictionary dictionaryWithObject:path forKey:[NSNumber numberWithDouble:[[path lastObject] weight]]];
    }
	//NSArray *pp = [graph shortestPath:[GraphNode nodeWithName:firstStation andLine:firstStationLineNum] to:[GraphNode nodeWithName:secondStation andLine:secondStationLineNum]];
    NSDictionary *paths = [graph getPaths:[GraphNode nodeWithName:firstStation andLine:firstStationLineNum] to:[GraphNode nodeWithName:secondStation andLine:secondStationLineNum]];
    NSArray *keys = [[paths allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (NSNumber *weight in keys) {
        NSLog(@"weight is %@", weight);
        NSLog(@"path is %@", [paths objectForKey:weight]);
    }
	 
	return paths;
}

-(void) processTransfers:(NSString*)transferInfo{
	
	NSArray *elements = [transferInfo componentsSeparatedByString:@","];

    NSString *lineStation1 = [elements objectAtIndex:0];
    NSString *station1 = [ComplexText makePlainString:[elements objectAtIndex:1]];
    NSString *lineStation2 = [elements objectAtIndex:2];
    NSString *station2 = [ComplexText makePlainString:[elements objectAtIndex:3]];

    Station *ss1 = [[mapLines objectAtIndex:[[[MHelper sharedHelper] lineByName:lineStation1].index intValue]-1] getStation:station1];
    Station *ss2 = [[mapLines objectAtIndex:[[[MHelper sharedHelper] lineByName:lineStation2].index intValue]-1] getStation:station2];
    if(ss1 == nil) NSLog(@"Error: station %@ from line %@ not found", station1, lineStation1);
    if(ss2 == nil) NSLog(@"Error: station %@ from line %@ not found", station2, lineStation2);
    if(ss1.transfer != nil && ss2.transfer != nil) {
        
    } else if(ss1.transfer) {
        [ss1.transfer addStation:ss2];
    } else if(ss2.transfer) {
        [ss2.transfer addStation:ss1];
    } else {
        Transfer *tr = [[[Transfer alloc] initWithMap:self] autorelease];
        tr.time = [[elements objectAtIndex:4] floatValue];
        [tr addStation:ss1];
        [tr addStation:ss2];
        [transfers addObject:tr];
    }
}

-(void) processTransfers2:(NSString*)transferInfo{
	
	NSArray *elements = [transferInfo componentsSeparatedByString:@","];
    
    NSString *lineStation1 = [elements objectAtIndex:0];
    NSString *station1 = [ComplexText makePlainString:[elements objectAtIndex:1]];
    NSString *lineStation2 = [elements objectAtIndex:2];
    NSString *station2 = [ComplexText makePlainString:[elements objectAtIndex:3]];
    
    Station *ss1 = [[mapLines objectAtIndex:[[[MHelper sharedHelper] lineByName:lineStation1].index intValue]-1] getStation:station1];
    Station *ss2 = [[mapLines objectAtIndex:[[[MHelper sharedHelper] lineByName:lineStation2].index intValue]-1] getStation:station2];
    if(ss1 == nil || ss2 == nil) {
        NSLog(@"Error: stations for transfer not found! %@ at %@ and %@ at %@", station1, lineStation1, station2, lineStation2);
        return;
    }
    if([elements count] >= 5) {
        int drv = [[elements objectAtIndex:4] floatValue];
        [ss1 setTransferDriving:drv to:ss2];
        [ss2 setTransferDriving:drv to:ss1];
    }
    NSMutableArray *ways = [NSMutableArray array];
    if([elements count] >= 6) {
        [ways addObject:[NSNumber numberWithInt:StringToWay([elements objectAtIndex:5])]];
    } else [ways addObject:[NSNumber numberWithInt:NOWAY]];
    if([elements count] >= 7) {
        [ways addObject:[NSNumber numberWithInt:StringToWay([elements objectAtIndex:6])]];
    } else [ways addObject:[NSNumber numberWithInt:NOWAY]];
    if([elements count] >= 8) {
        [ways addObject:[NSNumber numberWithInt:StringToWay([elements objectAtIndex:7])]];
    } else [ways addObject:[NSNumber numberWithInt:NOWAY]];
    if([elements count] >= 9) {
        [ways addObject:[NSNumber numberWithInt:StringToWay([elements objectAtIndex:8])]];
    } else [ways addObject:[NSNumber numberWithInt:NOWAY]];
    [ss1 setTransferWays:ways to:ss2];
    if(ss1.transfer != nil && ss2.transfer != nil) {
        
    } else if(ss1.transfer) {
        [ss1.transfer addStation:ss2];
    } else if(ss2.transfer) {
        [ss2.transfer addStation:ss1];
    } else {
        Transfer *tr = [[[Transfer alloc] initWithMap:self] autorelease];
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
            [l additionalPointsBetween:[stations objectAtIndex:1] and:[stations objectAtIndex:2] points:[elements objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, [elements count]-1)]]];
            return;
        }
    }
    NSLog(@"Error (additional point): line %@ and stations %@,%@ not found", lineName, [stations objectAtIndex:1], [stations objectAtIndex:2]);
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
            for (Segment *seg in s.segment) {
				[graph addEdgeFromNode:[GraphNode nodeWithName:s.name andLine:i+1] toNode:[GraphNode nodeWithName:seg.end.name andLine:i+1] withWeight:seg.driving];
				[graph addEdgeFromNode:[GraphNode nodeWithName:seg.end.name andLine:i+1] toNode:[GraphNode nodeWithName:s.name andLine:i+1] withWeight:seg.driving];
            }
        }
    }
	[self processTransfersForGraph];
}

-(void) processTransfersForGraph{
    for (Transfer *t in transfers) {
        for (Station *s1 in t.stations) {
            for (Station *s2 in t.stations) {
                if(s1 != s2) {
                    [graph addEdgeFromNode:[GraphNode nodeWithName:s1.name andLine:s1.line.index]
                                    toNode:[GraphNode nodeWithName:s2.name andLine:s2.line.index]
                                withWeight:t.time];
                }
            }
        }
    }
}

-(void) processTransfersForGraph2{
    for (Transfer *t in transfers) {
        for (Station *s1 in t.stations) {
            for (Station *s2 in t.stations) {
                if(s1 != s2) {
                    CGFloat dr = [s1 transferDrivingTo:s2];
                    [graph addEdgeFromNode:[GraphNode nodeWithName:s1.name andLine:s1.line.index]
                                    toNode:[GraphNode nodeWithName:s2.name andLine:s2.line.index]
                                withWeight:dr];
                }
            }
        }
    }
}


- (void)dealloc {
    /*for (Line* l in mapLines) {
        NSError *error = nil;
        [[MHelper sharedHelper].managedObjectContext deleteObject:[[MHelper sharedHelper] lineByName:l.name]];
        [[MHelper sharedHelper].managedObjectContext save:&error];
        if(error != nil) 
            NSLog(@"%@", error);
    }*/
    [mapLines release];
	[graph release];
    [transfers release];
    [activePath release];
    [pathStationsList release];
    [schedule release];
    [super dealloc];
}

// drawing

-(void) drawMap:(CGContextRef) context inRect:(CGRect)rect
{
    CGContextSaveGState(context);
    for (Line* l in mapLines) {
        [l draw:context inRect:(CGRect)rect];
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
        [l setEnabled:NO];
    }
    for (Transfer *t in transfers) {
        t.active = NO;
    }
    activeExtent = CGRectNull;
    [activePath removeAllObjects];
    [pathStationsList removeAllObjects];
	int count_ = [pathMap count];
    
    Station *prevStation = nil;
	for (int i=0; i< count_; i++) {
        GraphNode *n1 = [pathMap objectAtIndex:i];
        Line* l = [mapLines objectAtIndex:n1.line-1];
        Station *s = [l getStation:n1.name];
        if(prevStation != nil) {
            NSLog(@"forward way is %d", [prevStation transferWayTo:s]);
            NSLog(@"backward way is %d", [s transferWayFrom:prevStation]);
        }
        activeExtent = CGRectUnion(activeExtent, s.textRect);
        activeExtent = CGRectUnion(activeExtent, s.boundingBox);
        
        if(i == count_ - 1) {
            // the last station
            activeExtent = CGRectUnion(activeExtent, s.textRect);
            activeExtent = CGRectUnion(activeExtent, s.boundingBox);
            [pathStationsList addObject:n1.name];
        } else {
            GraphNode *n2 = [pathMap objectAtIndex:i+1];
            
            if(n1.line == n2.line && [n1.name isEqualToString:n2.name]) {
                // the same station on the same line
                // strange, but sometimes it's possible
            } else
            if (n1.line==n2.line) {
                [activePath addObject:[l activateSegmentFrom:n1.name to:n2.name]];
                [pathStationsList addObject:n1.name];
            } else
            if(n1.line != n2.line) {
                [activePath addObject:s.transfer];
                [pathStationsList addObject:n1.name];
                [pathStationsList addObject:@"---"]; //временно до обновления модели
            }
        }
        prevStation = s;
	}
    float offset = (25 - (int)[pathStationsList count]) * 0.005f;
    if(offset < 0.02f) offset = 0.02f;
    activeExtent.origin.x -= activeExtent.size.width * offset;
    activeExtent.origin.y -= activeExtent.size.height * offset;
    activeExtent.size.width *= (1.f + offset * 2.f);
    activeExtent.size.height *= (1.f + offset * 2.f);
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

-(void) drawTransfers:(CGContextRef) context inRect:(CGRect)rect
{
    CGContextSaveGState(context);
    for (Transfer *tr in transfers) {
        if(CGRectIntersectsRect(rect, tr.boundingBox)) {
            /*if(!tr.active) {
                CGContextSaveGState(context);
                CGContextSetAlpha(context, 0.7f);
            }*/
            [tr draw:context];
            //if(!tr.active) CGContextRestoreGState(context);
        }
    }
    CGContextRestoreGState(context);
}

-(NSInteger) checkPoint:(CGPoint*)point Station:(NSMutableString *)stationName
{
    for (Line *l in mapLines) {
        for (Station *s in l.stations) {
            if(CGRectContainsPoint(s.tapArea, *point) || CGRectContainsPoint(s.tapTextArea, *point)) {
                [stationName setString:s.name];
                *point = CGPointMake(s.pos.x, s.pos.y);
                return l.index;
            }
        }
    }
    return -1;
}

-(void) drawActive:(CGContextRef)context inRect:(CGRect)rect
{
    CGContextSaveGState(context);
    for (Line* l in mapLines) {
        [l drawActive:context inRect:(CGRect)rect];
    }
    for (Line* l in mapLines) {
        for (Station *s in l.stations) {
            if((s.active || (s.transfer && s.transfer.active)) && s.drawName && CGRectIntersectsRect(s.textRect, rect))
                [s drawName:context];
        }
    }
    for (Transfer *tr in transfers) {
        if(CGRectIntersectsRect(rect, tr.boundingBox)) {
            if(tr.active) 
                [tr draw:context];
        }
    }
    CGContextRestoreGState(context);
}

-(Station*)findNearestStationTo:(CGPoint)gpsCoord
{
    CGFloat sqDist = INFINITY;
    Station *nearest = nil;
    for(Line *l in mapLines) {
        for (Station *s in l.stations) {
            CGPoint dp = CGPointMake(s.gpsCoords.x - gpsCoord.x, s.gpsCoords.y - gpsCoord.y);
            CGFloat d = dp.x * dp.x + dp.y * dp.y;
            if(d < sqDist) {
                sqDist = d;
                nearest = s;
            }
        }
    }
    return nearest;
}



-(NSMutableArray*) describePath:(NSArray*)pathMap {
 
    NSMutableArray *path = [[NSMutableArray alloc] init];
    
    [path removeAllObjects];
	int count_ = [pathMap count];
    
    Station *prevStation = nil;
	for (int i=0; i< count_; i++) {
        GraphNode *n1 = [pathMap objectAtIndex:i];
        Line* l = [mapLines objectAtIndex:n1.line-1];
        Station *s = [l getStation:n1.name];
        
        if(i == count_ - 1) {
            
        } else {
            GraphNode *n2 = [pathMap objectAtIndex:i+1];
            
            if (n1.line==n2.line) {
                [path addObject:[l getSegmentFrom:n1.name to:n2.name]];
            } 
            
            if(n1.line != n2.line) {
                [path addObject:s.transfer];
            }
        }
        
        prevStation = s;
        
    }
    
    return path;
}


@end
