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
 
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 40.0)];
        imageView.tag=5000;
        imageView.image = [UIImage imageNamed:@"lower_path_bg.png"]; //lower_path_bg toolbar_bg
        [self addSubview:imageView];
        [imageView release];
        
        UIImageView *pathNumberView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pathnumber.png"]];
        pathNumberView.frame = CGRectMake(8,4,24,32);
        [self addSubview:pathNumberView];
        [pathNumberView release];
        
        UIImageView *clockView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clock.png"]];
        clockView.frame = CGRectMake(37, 4, 14, 14);
        [self addSubview:clockView];
        [clockView release];
        
        UIImageView *flagView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flag.png"]];
        flagView.frame = CGRectMake(246,5,14,14);
        [self addSubview:flagView];
        [flagView release];
        
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = [UIFont fontWithName:@"MyriadPro-Regular" size:13.0];
        nameLabel.textColor = [UIColor darkGrayColor];
        nameLabel.shadowColor = [UIColor whiteColor];
        nameLabel.shadowOffset = CGSizeMake(0, 1);
        nameLabel.frame=CGRectMake(52.0, 6, 65, 15); 
        nameLabel.tag=6000;
        [self addSubview:nameLabel];
        [nameLabel release];
        
        UILabel *nameLabel2 = [[UILabel alloc] init];
        nameLabel2.backgroundColor = [UIColor clearColor];
        nameLabel2.font = [UIFont fontWithName:@"MyriadPro-Regular" size:13.0];
        nameLabel2.frame=CGRectMake(263.0, 7, 60, 15); 
        nameLabel2.shadowOffset = CGSizeMake(0, 1);
        nameLabel2.shadowColor = [UIColor whiteColor];
        nameLabel2.tag=7000;
        [self addSubview:nameLabel2];
        [nameLabel2 release];
        
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
