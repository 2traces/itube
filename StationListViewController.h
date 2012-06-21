//
//  StationListViewController.h
//  tube
//
//  Created by sergey on 02.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StationListViewProtocol;

@interface StationListViewController : UIViewController <UISearchDisplayDelegate,UITableViewDataSource, UITableViewDelegate>
{
    NSArray *stationList;
    NSMutableArray *stationIndex;
    NSMutableArray *filteredStation;
    
    NSMutableDictionary *indexDictionary;
    
    id <StationListViewProtocol> dataSource;
    
    IBOutlet UITableView *mytableView;
    IBOutlet UIImageView *imageView;
    
    UISearchDisplayController *mySearchDC;

}

@property (nonatomic,retain) NSArray *stationList;
@property (nonatomic,retain) NSMutableArray *stationIndex;
@property (nonatomic,assign) id <StationListViewProtocol> dataSource;
@property (nonatomic,retain) NSMutableArray *filteredStation;
@property (nonatomic,retain) NSMutableDictionary *colorDictionary;
@property (nonatomic,retain) IBOutlet UITableView *mytableView;
@property (nonatomic,retain) IBOutlet UIImageView *imageView;
@property (nonatomic,retain) NSMutableDictionary *indexDictionary;
@property (nonatomic,retain) UISearchDisplayController *mySearchDC;

-(void)createStationIndex;
-(UIImage*)drawCircleView:(UIColor*)myColor;


@end

@protocol StationListViewProtocol

-(NSArray*)getItemList;

@end

@interface RoundView : UIView {
    UIColor *myColor;
}

- (id)initWithDefaultSize;
- (void) setColor:(UIColor*)circleColor;

@end
