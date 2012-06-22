//
//  LineListViewController.h
//  tube
//
//  Created by sergey on 06.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SectionHeaderView.h"

@class MCategory;

@protocol CategoryListViewProtocol;

@interface LineListViewController : UIViewController <UISearchDisplayDelegate,UITableViewDataSource, UITableViewDelegate,SectionHeaderViewDelegate> {
    NSArray *lineList;

    id <CategoryListViewProtocol> dataSource;
    
    IBOutlet UITableView *mytableView;
    IBOutlet UIImageView *imageView;

}

@property (nonatomic, retain) NSArray *lineList;
@property (nonatomic, assign) id <CategoryListViewProtocol> dataSource;
@property (nonatomic, retain) NSMutableDictionary *colorDictionary;

@property (nonatomic, retain) NSMutableArray* sectionInfoArray;
@property (nonatomic, assign) NSInteger openSectionIndex;
@property (nonatomic, assign) NSInteger uniformRowHeight;

@property (nonatomic, retain) NSArray* stationsList;

@property (nonatomic, retain) IBOutlet UITableView *mytableView;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;

-(UIImage*)drawCircleView:(UIColor*)myColor;

@end

@protocol CategoryListViewProtocol

-(NSArray*)getCategoryList;
-(NSArray*)getItemsForCategory:(MCategory*)category;


@end

