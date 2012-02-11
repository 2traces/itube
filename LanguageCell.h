//
//  LanguageCell.h
//  tube
//
//  Created by sergey on 10.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LanguageCell : UITableViewCell
{
    IBOutlet UILabel *languageLabel;
    IBOutlet UILabel *languageWordLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *languageLabel;
@property (nonatomic, retain) IBOutlet UILabel *languageWordLabel;

@end
