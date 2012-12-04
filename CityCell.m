//
//  CityCell.m
//  tube
//
//  Created by Sergey Mingalev on 10.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CityCell.h"

@implementation CityCell

@synthesize cityName;
@synthesize cellButton;
@synthesize progress;
@synthesize checkView;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
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
    [checkView release];
    [cityName release];
    [cellButton release];
    [progress release];
    [super dealloc];
}

@end
