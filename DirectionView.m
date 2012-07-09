//
//  DirectionView.m
//  tube
//
//  Created by Alexey Starovoitov on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DirectionView.h"

#define DegreesToRadians(x) ((x) * M_PI / 180.0)

@implementation DirectionView

@synthesize button;
@synthesize pinCoordinates;
@synthesize arrow;
@synthesize pinID;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithPinCoordinates:(CGPoint)coordinates pinID:(NSInteger)pindId mainView:(MainView*)_mainView {
    self = [super init];
    if (self) {
        // Initialization code
        mainView = _mainView;
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *btBg = [UIImage imageNamed:@"direction_bg.png"];
        CGRect frame = CGRectMake(0, 0, btBg.size.width, btBg.size.height);
        self.button.frame = frame;
        [self.button setImage:btBg forState:UIControlStateNormal];
        [self.button addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];
        self.arrow = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"direction_arrow.png"]] autorelease];
        self.arrow.userInteractionEnabled = YES;
        [self addSubview:self.button];
        [self addSubview:self.arrow];
        [self bringSubviewToFront:self.button];
        self.userInteractionEnabled = YES;
        self.pinID = pindId;
        self.pinCoordinates = coordinates;
    }
    return self;    
}

- (void)setRadialOffset:(CGFloat)offset {
    NSLog(@"Radial offset: %f", offset);
    self.arrow.transform = CGAffineTransformMakeRotation(0);
    self.arrow.transform = CGAffineTransformMakeRotation(offset + M_PI_2);
}

- (void)buttonTapped {
    [mainView centerMapOnItemWithID:pinID];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
