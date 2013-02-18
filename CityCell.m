//
//  CityCell.m
//  tube
//
//  Created by sergey on 10.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CityCell.h"

@implementation CityCell

@synthesize cityName;
@synthesize cityNameAlt;
@synthesize priceTag;
@synthesize cellButton;
@synthesize progress;
@synthesize checkView;
@synthesize iconView;
@synthesize imageView;
@synthesize priceContainer;

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
    [_imageButton release];
    [super dealloc];
}

@end
