//
//  CityCell.m
//  tube
//
//  Created by sergey on 10.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AdvancedCityCell.h"
#import <QuartzCore/QuartzCore.h>
#import "SSTheme.h"

@implementation AdvancedCityCell

@synthesize cityName;
@synthesize cityNameAlt;
@synthesize priceTag;
@synthesize cellButton;
@synthesize progress;
@synthesize checkView;
@synthesize iconView;
@synthesize imageView;
@synthesize priceContainer;
@synthesize priceBgView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code

    }
    return self;
}

- (void) setupCell {
    id <SSTheme> theme = [SSThemeManager sharedTheme];

    self.imageView.layer.cornerRadius = 10;
    self.imageView.layer.masksToBounds = YES;
    self.priceBgView.image = [theme priceTagImage];
    [self.cellButton setImage:[theme settingsMapItemBackgroundImage] forState:UIControlStateNormal];
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
