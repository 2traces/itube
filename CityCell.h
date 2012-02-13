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
}

@property (nonatomic, retain) IBOutlet UILabel* cityName;

@end
