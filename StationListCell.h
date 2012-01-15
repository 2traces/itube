//
//  StationListCell.h
//  tube
//
//  Created by sergey on 05.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StationListCell : UITableViewCell {
    
    IBOutlet UIButton *mybutton;
    IBOutlet UILabel *mylabel;
    IBOutlet UIImageView *circleView;
    
}

@property (readonly) IBOutlet UIButton *mybutton;
@property (nonatomic,retain) IBOutlet UILabel *mylabel;
@property (nonatomic,retain) IBOutlet UIImageView *circleView;

@end
