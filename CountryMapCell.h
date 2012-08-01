//
//  CountryMapCell.h
//  tube
//
//  Created by Alexey Starovoitov on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CountryMapCell : UITableViewCell
{
    IBOutlet UILabel *mapName;
    IBOutlet UILabel *mapStatus;
    IBOutlet UILabel *mapDownloaded;
    IBOutlet UIButton *cellButton;
    IBOutlet UIProgressView *progress;
    IBOutlet UIImageView *mapImage;
    IBOutlet UIImageView *checkView;
    
}

@property (nonatomic, retain) IBOutlet UILabel* mapName;
@property (nonatomic, retain) IBOutlet UILabel* mapStatus;
@property (nonatomic, retain) IBOutlet UILabel* mapDownloaded;
@property (nonatomic, retain) IBOutlet UIButton* cellButton;
@property (nonatomic, retain) IBOutlet UIProgressView* progress;
@property (nonatomic, retain) IBOutlet UIImageView *mapImage;
@property (nonatomic, retain) IBOutlet UIImageView *checkView;

@end
