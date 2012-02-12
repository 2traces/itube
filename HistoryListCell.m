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

    CGRect fromLabelOriginal = CGRectMake(27, 11, 500, 21);
    CGRect toLableOriginal = CGRectMake(29, 34, 500, 21);
    CGRect arrowViewOriginal = CGRectMake(143, 11, 15, 15);
    CGRect fromDotOriginal = CGRectMake(3, 8, 20, 20);
    CGRect toDotOriginal = CGRectMake(5, 31, 20, 20);
    
    float iconsSize = fromDotOriginal.size.width;
    float arrowSize = arrowViewOriginal.size.width;
    
    float maxLabelWidth = 220.0f;

    fromStation.font = [UIFont fontWithName:@"MyriadPro-Regular" size:16.0f];
    fromLabelSize = [[fromStation text] sizeWithFont:[UIFont fontWithName:@"MyriadPro-Regular" size:16.0f]];
    
    if (fromLabelSize.width>maxLabelWidth) {
        fromLabelSize.width=maxLabelWidth;
    }
    
    toStation.font = [UIFont fontWithName:@"MyriadPro-Regular" size:16.0f];
    toLabelSize = [[toStation text] sizeWithFont:[UIFont fontWithName:@"MyriadPro-Regular" size:16.0f]];
    
    if (toLabelSize.width>maxLabelWidth) {
        toLabelSize.width=maxLabelWidth;
    }
    
    dateLabel.font = [UIFont fontWithName:@"MyriadPro-Regular" size:11.0f];
    dateLabel.textColor = [UIColor darkGrayColor];
    
    fromLineCircle.frame = fromDotOriginal;
    toLineCircle.frame = toDotOriginal;

    fromStation.frame = CGRectMake(fromLabelOriginal.origin.x, fromLabelOriginal.origin.y, fromLabelSize.width, fromLabelOriginal.size.height);
    
    arrowImageView.frame = CGRectMake(fromLabelSize.width+iconsSize+17.0, arrowViewOriginal.origin.y, arrowSize, arrowViewOriginal.size.height);
    
    toStation.frame = CGRectMake(toLableOriginal.origin.x, toLableOriginal.origin.y, toLabelSize.width, toLableOriginal.size.height);
    
    [super layoutSubviews];
}

@end
