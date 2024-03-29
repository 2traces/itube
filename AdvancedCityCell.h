//
//  CityCell.h
//  tube
//
//  Created by sergey on 10.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdvancedCityCell : UITableViewCell
{
    IBOutlet UILabel *cityName;
    IBOutlet UILabel *cityNameAlt;
    IBOutlet UILabel *priceTag;
    IBOutlet UIButton *cellButton;
    IBOutlet UIButton *priceButton;
    IBOutlet UIProgressView *progress;
    IBOutlet UIImageView *checkView;
    IBOutlet UIImageView *iconView;
    IBOutlet UIImageView *imageView;
    IBOutlet UIImageView *priceBgView;
    IBOutlet UIView *priceContainer;
    
}

@property (nonatomic, retain) IBOutlet UILabel* cityName;
@property (nonatomic, retain) IBOutlet UILabel* cityNameAlt;
@property (nonatomic, retain) IBOutlet UILabel* priceTag;
@property (nonatomic, retain) IBOutlet UIButton* cellButton;
@property (nonatomic, retain) IBOutlet UIProgressView* progress;
@property (nonatomic, retain) IBOutlet UIImageView *checkView;
@property (nonatomic, retain) IBOutlet UIImageView *iconView;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIImageView *priceBgView;
@property (nonatomic, retain) IBOutlet UIView *priceContainer;
@property (retain, nonatomic) IBOutlet UIButton *imageButton;
@property (retain, nonatomic) IBOutlet UIButton *priceButton;

- (void) setupCell;

@end
