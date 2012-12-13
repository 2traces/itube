//
//  CityCell.h
//  tube
//
//  Created by sergey on 10.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CityCell : UITableViewCell
{
    IBOutlet UILabel *cityName;
    IBOutlet UILabel *cityNameAlt;
    IBOutlet UILabel *priceTag;
    IBOutlet UIButton *cellButton;
    IBOutlet UIProgressView *progress;
    IBOutlet UIImageView *checkView;
    IBOutlet UIImageView *iconView;
    IBOutlet UIImageView *imageView;
}

@property (nonatomic, retain) IBOutlet UILabel* cityName;
@property (nonatomic, retain) IBOutlet UILabel* cityNameAlt;
@property (nonatomic, retain) IBOutlet UILabel* priceTag;
@property (nonatomic, retain) IBOutlet UIButton* cellButton;
@property (nonatomic, retain) IBOutlet UIProgressView* progress;
@property (nonatomic, retain) IBOutlet UIImageView *checkView;
@property (nonatomic, retain) IBOutlet UIImageView *iconView;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;

@end
