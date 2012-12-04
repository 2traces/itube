//
//  StationListCell.m
//  tube
//
//  Created by Sergey Mingalev on 05.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "StationListCell.h"

@implementation StationListCell

@synthesize mybutton;
@synthesize circleView;
@synthesize mylabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)dealloc
{
    [mybutton release];
    [mylabel release];
    [circleView release];
    [super dealloc];
}


@end
