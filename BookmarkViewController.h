//
//  BookmarkViewController.h
//  tube
//
//  Created by sergey on 09.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BookmarkViewProtocol;

@interface BookmarkViewController : UITableViewController 
{
    NSMutableArray *stationList;

    id <BookmarkViewProtocol> dataSource;
    
}

@property (nonatomic,retain) NSMutableArray *stationList;
@property (nonatomic,retain) id <BookmarkViewProtocol> dataSource;
@property (nonatomic,retain) NSMutableDictionary *colorDictionary;

-(UIImage*)drawCircleView:(UIColor*)myColor;


@end

@protocol BookmarkViewProtocol

-(NSArray*)getFavoriteStationList;

@end

