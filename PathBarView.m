//
//  PathBarView.m
//  tube
//
//  Created by sergey on 31.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PathBarView.h"
#import "PathDrawView.h"

@implementation PathBarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
 
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 40.0)];
        bgView.tag=5000;
        bgView.image = [UIImage imageNamed:@"lower_path_bg.png"]; //lower_path_bg toolbar_bg
        [self addSubview:bgView];
        [bgView release];
        
        UIImageView *pathNumberView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pathnumber.png"]];
        pathNumberView.frame = CGRectMake(8,4,24,32);
        [self addSubview:pathNumberView];
        [pathNumberView release];
        
        UIImageView *clockView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clock.png"]];
        clockView.frame = CGRectMake(37, 4, 14, 14);
        [self addSubview:clockView];
        [clockView release];
        
        UIImageView *flagView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flag.png"]];
        flagView.frame = CGRectMake(244,5,14,14);
        flagView.tag=6500;
        [self addSubview:flagView];
        [flagView release];
        
        UILabel *travelTimeLabel = [[UILabel alloc] init];
        travelTimeLabel.backgroundColor = [UIColor clearColor];
        travelTimeLabel.font = [UIFont fontWithName:@"MyriadPro-Regular" size:13.0];
        travelTimeLabel.textColor = [UIColor darkGrayColor];
        travelTimeLabel.shadowColor = [UIColor whiteColor];
        travelTimeLabel.shadowOffset = CGSizeMake(0, 1);
        travelTimeLabel.frame=CGRectMake(52.0, 6, 65, 15); 
        travelTimeLabel.tag=6000;
        [self addSubview:travelTimeLabel];
        [travelTimeLabel release];
        
        UILabel *arrivalTimeLabel = [[UILabel alloc] init];
        arrivalTimeLabel.backgroundColor = [UIColor clearColor];
        arrivalTimeLabel.font = [UIFont fontWithName:@"MyriadPro-Regular" size:13.0];
        arrivalTimeLabel.frame=CGRectMake(256.0, 7, 54, 15); 
        arrivalTimeLabel.shadowOffset = CGSizeMake(0, 1);
        arrivalTimeLabel.shadowColor = [UIColor whiteColor];
        arrivalTimeLabel.tag=7000;
        arrivalTimeLabel.textAlignment=UITextAlignmentRight;
        [self addSubview:arrivalTimeLabel];
        [arrivalTimeLabel release];
        
        PathDrawView *drawView = [[PathDrawView alloc] initWithFrame:frame];
        drawView.tag =10000;
        [self addSubview:drawView];
        [drawView release];
    }

    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
}
 */

@end
