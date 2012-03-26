//
//  LanguageViewController.h
//  tube
//
//  Created by sergey on 26.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LanguageViewController : UIViewController {
    IBOutlet UITableView *mytableView;
    IBOutlet UIImageView *imageView;
    
    NSArray *languages;
}

@property (nonatomic,retain) IBOutlet UITableView *mytableView;
@property (nonatomic,retain) IBOutlet UIImageView *imageView;
@property (nonatomic,retain) NSArray *languages;

@end
