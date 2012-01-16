//
//  HistoryListCell.h
//  tube
//
//  Created by sergey on 13.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryListCell : UITableViewCell
{
    IBOutlet UILabel *fromStation;
    IBOutlet UIImageView *fromLineCircle;
    
    IBOutlet UILabel *toStation;
    IBOutlet UIImageView *toLineCircle;
    
    IBOutlet UIImageView *arrowImageView;
    IBOutlet UILabel *dateLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *fromStation;
@property (nonatomic, retain) IBOutlet UIImageView *fromLineCircle;
@property (nonatomic, retain) IBOutlet UILabel *toStation;
@property (nonatomic, retain) IBOutlet UIImageView *toLineCircle;
@property (nonatomic, retain) IBOutlet UIImageView *arrowImageView;
@property (nonatomic, retain) IBOutlet UILabel *dateLabel;

@end
