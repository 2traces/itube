//
//  BookmarkViewController.h
//  tube
//
//  Created by sergey on 09.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BookmarkViewProtocol;

@interface BookmarkViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *stationList;

    id <BookmarkViewProtocol> dataSource;
 
    IBOutlet UITableView *mytableView;
    IBOutlet UIImageView *imageView;
}

@property (nonatomic, retain) NSMutableArray *stationList;
@property (nonatomic, assign) id <BookmarkViewProtocol> dataSource;
@property (nonatomic, retain) NSMutableDictionary *colorDictionary;
@property (nonatomic, retain) IBOutlet UITableView *mytableView;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;

-(UIImage*)drawCircleView:(UIColor*)myColor;


@end

@protocol BookmarkViewProtocol

-(NSArray*)getFavoriteStationList;

@end

