//
//  FastAccessTableViewController.h
//  tube
//
//  Created by sergey on 21.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FastAccessTableViewProtocol;

@interface FastAccessTableViewController : UITableViewController <UITextFieldDelegate> {

    NSArray *stationList;
    NSMutableArray *stationIndex;
    NSMutableArray *filteredStation;

    id <FastAccessTableViewProtocol> dataSource;
}

@property (nonatomic,retain) NSArray *stationList;
@property (nonatomic,retain) NSMutableArray *stationIndex;
@property (nonatomic,assign) id <FastAccessTableViewProtocol> dataSource;
@property (nonatomic,retain) NSMutableArray *filteredStation;
@property (nonatomic,retain) NSMutableDictionary *colorDictionary;

- (void) filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope;
- (UIImage*) drawCircleView:(UIColor*)myColor;

@end

@protocol FastAccessTableViewProtocol

-(NSArray*)getItemList;

@end
