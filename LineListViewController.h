//
//  LineListViewController.h
//  tube
//
//  Created by sergey on 06.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SectionHeaderView.h"

@class MLine;

@protocol LineListViewProtocol;

@interface LineListViewController : UITableViewController <SectionHeaderViewDelegate> {
    NSArray *lineList;

    id <LineListViewProtocol> dataSource;
}

@property (nonatomic,retain) NSArray *lineList;
@property (nonatomic,assign) id <LineListViewProtocol> dataSource;
@property (nonatomic,retain) NSMutableDictionary *colorDictionary;

@property (nonatomic, retain) NSMutableArray* sectionInfoArray;
@property (nonatomic, assign) NSInteger openSectionIndex;
@property (nonatomic, assign) NSInteger uniformRowHeight;

-(UIImage*)drawCircleView:(UIColor*)myColor;

@end

@protocol LineListViewProtocol

-(NSArray*)getLineList;
-(NSArray*)getStationsForLine:(MLine*)line;

@end

