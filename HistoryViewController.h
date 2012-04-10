//
//  HistoryViewController.h
//  tube
//
//  Created by sergey on 13.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HistoryViewProtocol;

@interface HistoryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    id <HistoryViewProtocol> dataSource;
    
    NSMutableArray *historyList;
    
    IBOutlet UITableView *mytableView;
    IBOutlet UIImageView *imageView;
    
    NSDateFormatter *formatter;
}

@property (nonatomic, retain) NSMutableArray *historyList;
@property (nonatomic, retain) id <HistoryViewProtocol> dataSource;
@property (nonatomic, retain) NSMutableDictionary *colorDictionary;
@property (nonatomic, retain) IBOutlet UITableView *mytableView;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;

-(UIImage*)drawCircleView:(UIColor*)myColor;

@end

@protocol HistoryViewProtocol

-(NSArray*)getHistoryList;

@end
