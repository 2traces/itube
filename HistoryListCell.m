//
//  HistoryListCell.m
//  tube
//
//  Created by sergey on 13.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HistoryListCell.h"

@implementation HistoryListCell

@synthesize fromStation;
@synthesize fromLineCircle;
@synthesize toStation;
@synthesize toLineCircle;
@synthesize arrowImageView;
@synthesize dateLabel;

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

- (void)layoutSubviews
{
    CGSize fromLabelSize;
    CGSize toLabelSize;
    
    static float iconsSize = 25.0;
    static float arrowSize = 15.0;
    
    fromStation.font = [UIFont fontWithName:@"MyriadPro-Regular" size:15.0f];
    fromLabelSize = [[fromStation text] sizeWithFont:[UIFont fontWithName:@"MyriadPro-Regular" size:15.0f]];

    toStation.font = [UIFont fontWithName:@"MyriadPro-Regular" size:15.0f];
    toLabelSize = [[toStation text] sizeWithFont:[UIFont fontWithName:@"MyriadPro-Regular" size:15.0f]];
    
    dateLabel.font = [UIFont fontWithName:@"MyriadPro-Regular" size:12.0f];
    dateLabel.textColor = [UIColor darkGrayColor];

//    fromLineCircle.frame = CGRectMake(0, fromLineCircle.frame.origin.y,iconsSize , fromLineCircle.frame.size.height);

    fromStation.frame = CGRectMake(33, fromStation.frame.origin.y, fromLabelSize.width, fromStation.frame.size.height);
    
    arrowImageView.frame = CGRectMake(fromLabelSize.width+iconsSize+15.0, arrowImageView.frame.origin.y, arrowSize, arrowImageView.frame.size.height);
    
//    toLineCircle.frame = CGRectMake(fromLabelSize.width+iconsSize+arrowSize+15.0, toLineCircle.frame.origin.y,iconsSize , toLineCircle.frame.size.height);
    
    toStation.frame = CGRectMake(33, toStation.frame.origin.y, toLabelSize.width, toStation.frame.size.height);
    
    
}

/*
 - (void)layoutSubviews
 {
 CGSize fromLabelSize;
 CGSize toLabelSize;
 
 static float iconsSize = 29.0;
 static float arrowSize = 15.0;
 
 
 fromStation.font = [UIFont fontWithName:@"MyriadPro-Regular" size:15.0f];
 fromLabelSize = [[fromStation text] sizeWithFont:[UIFont fontWithName:@"MyriadPro-Regular" size:15.0f]];
 
 toStation.font = [UIFont fontWithName:@"MyriadPro-Regular" size:15.0f];
 toLabelSize = [[toStation text] sizeWithFont:[UIFont fontWithName:@"MyriadPro-Regular" size:15.0f]];
 
 dateLabel.font = [UIFont fontWithName:@"MyriadPro-Regular" size:12.0f];
 dateLabel.textColor = [UIColor darkGrayColor];
 
 fromLineCircle.frame = CGRectMake(0, fromLineCircle.frame.origin.y,iconsSize , fromLineCircle.frame.size.height);
 
 fromStation.frame = CGRectMake(iconsSize, fromStation.frame.origin.y, fromLabelSize.width, fromStation.frame.size.height);
 
 arrowImageView.frame = CGRectMake(fromLabelSize.width+iconsSize+10.0, arrowImageView.frame.origin.y, arrowSize, arrowImageView.frame.size.height);
 
 toLineCircle.frame = CGRectMake(fromLabelSize.width+iconsSize+arrowSize+15.0, toLineCircle.frame.origin.y,iconsSize , toLineCircle.frame.size.height);
 
 toStation.frame = CGRectMake(fromLabelSize.width+iconsSize*2+arrowSize+15.0, toStation.frame.origin.y, toLabelSize.width, toStation.frame.size.height);
 
 
 }

 */
@end
