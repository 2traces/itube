//
//  CityCell.h
//  tube
//
//  Created by Sergey Mingalev on 10.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CityCell : UITableViewCell
{
    IBOutlet UILabel *cityName;
    IBOutlet UIButton *cellButton;
    IBOutlet UIProgressView *progress;
    IBOutlet UIImageView *checkView;
}

@property (nonatomic, retain) IBOutlet UILabel* cityName;
@property (nonatomic, retain) IBOutlet UIButton* cellButton;
@property (nonatomic, retain) IBOutlet UIProgressView* progress;
@property (nonatomic, retain) IBOutlet UIImageView *checkView;

@end
