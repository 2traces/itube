//
//  DirectionView.m
//  tube
//
//  Created by Alexey Starovoitov on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DirectionView.h"
#import "UIColor+CategoriesColors.h"

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

- (id)initWithPinCoordinates:(CGPoint)coordinates pinID:(NSInteger)pindId mainView:(MainView*)_mainView colorID:(NSString*)colorID {
    self = [super init];
    if (self) {
        // Initialization code
        mainView = _mainView;
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        CGRect labelFrame = CGRectMake(0, 0, 200, 50);
        CGRect unitsFrame = CGRectMake(0, 4, 20, 50);
        
        
        self.labelDistance = [[[UILabel alloc] initWithFrame:labelFrame] autorelease];

        self.labelDistance.backgroundColor = [UIColor clearColor];
        self.labelDistance.font = [UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:18.0f];
        self.labelDistance.textColor = [UIColor colorWithCategoryID:colorID];

        
        self.labelUnits = [[[UILabel alloc] initWithFrame:unitsFrame] autorelease];
        self.labelUnits.text = @"km";
        self.labelUnits.backgroundColor = [UIColor clearColor];
        self.labelUnits.font = [UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:10.0f];
        self.labelUnits.textColor = [UIColor colorWithCategoryID:colorID];
        
        NSString *bgName = [NSString stringWithFormat:@"direction_bg_%@", colorID];
        UIImage *btBg = [UIImage imageNamed:bgName];
        
        if (!btBg) {
            btBg = [UIImage imageNamed:@"direction_bg_11"];
        }
        
        CGRect frame = CGRectMake(0, 0, btBg.size.width, btBg.size.height);
        self.button.frame = frame;
        [self.button setImage:btBg forState:UIControlStateNormal];
        [self.button addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];
        self.arrow = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"direction_arrow.png"]] autorelease];
        self.arrow.userInteractionEnabled = YES;
        [self addSubview:self.button];
        [self addSubview:self.arrow];
        [self addSubview:self.labelDistance];
        [self addSubview:self.labelUnits];
        self.clipsToBounds = NO;
        //[self bringSubviewToFront:self.button];
        self.userInteractionEnabled = YES;
        self.pinID = pindId;
        self.pinCoordinates = coordinates;
        [self setDistanceLabelPosition:kDistanceLabelPositionRight];
//        UIGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
//                                    initWithTarget:self action:@selector(handleTap:)];
//        [self.button addGestureRecognizer:[tap autorelease]];

    }
    return self;
}


- (void)handleTap:(UILongPressGestureRecognizer *)recognizer {
    NSLog(@"Tap...");
    [mainView centerMapOnItemWithID:pinID];    
}

- (void)setDistanceValue:(CGFloat)distance {
    NSString *distanceString = [NSString stringWithFormat:@"%.1f",distance];
    self.labelDistance.text = distanceString;
    CGSize sizeToMakeLabel = [self.labelDistance.text sizeWithFont:self.labelDistance.font];
    self.labelDistance.frame = CGRectMake(self.labelDistance.frame.origin.x, self.labelDistance.frame.origin.y,
                                          sizeToMakeLabel.width, self.labelDistance.frame.size.height);
    [self setDistanceLabelPosition:position];
}

- (void)setRadialOffset:(CGFloat)offset {
    NSLog(@"Radial offset: %f", offset);
    self.arrow.transform = CGAffineTransformMakeRotation(0);
    self.arrow.transform = CGAffineTransformMakeRotation(offset + M_PI_2);

}

- (void)buttonTapped {
    [mainView centerMapOnItemWithID:pinID];
}

- (void)setDistanceLabelPosition:(DistanceLabelPosition)_position {
    position = _position;
    CGRect labelFrame = self.labelDistance.frame;
    CGRect unitsFrame = self.labelUnits.frame;
    switch (position) {
        case kDistanceLabelPositionLeft:
            labelFrame.origin.x = -labelFrame.size.width - unitsFrame.size.width;
            unitsFrame.origin.x =  -unitsFrame.size.width;
            self.labelDistance.textAlignment = UITextAlignmentRight;
            
            break;
        case kDistanceLabelPositionRight:
            labelFrame.origin.x = 50;
            unitsFrame.origin.x = 50 + labelFrame.size.width;

            self.labelDistance.textAlignment = UITextAlignmentLeft;

            break;
            
        default:
            break;
    }
    self.labelDistance.frame = labelFrame;
    self.labelUnits.frame = unitsFrame;
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
