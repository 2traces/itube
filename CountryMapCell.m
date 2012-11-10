//
//  CountryMapCell.m
//  tube
//
//  Created by Alexey Starovoitov on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CountryMapCell.h"

@implementation CountryMapCell

@synthesize mapName;
@synthesize mapStatus;
@synthesize mapDownloaded;
@synthesize cellButton;
@synthesize progress;
@synthesize mapImage;
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
    [mapImage release];
    [mapName release];
    [cellButton release];
    [progress release];
    [mapStatus release];
    [checkView release];
    [super dealloc];
}
@end
