//
//  TopTwoStationsView.h
//  tube
//
//  Created by Sergey Mingalev on 20.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MItem;
@class FastAccessTableViewController;
@class StationTextField;

@interface TopRasterView : UIView <UITextFieldDelegate>
{
    UIImageView  *toolbar; 
	StationTextField *firstStation;
	StationTextField *secondStation;	
    BOOL isEditing;
    BOOL shouldEnlarge;
    UIImageView *arrowView;
    
    FastAccessTableViewController *tableView;
}

@property (nonatomic, retain) UIImageView *toolbar;
@property (nonatomic, retain) UITextField *firstStation;
@property (nonatomic, retain) UITextField *secondStation;
@property (nonatomic, retain) UIButton *firstButton;
@property (nonatomic, retain) UIButton *secondButton;
@property (nonatomic, retain) FastAccessTableViewController *tableView;
@property (nonatomic, retain) UIImageView *arrowView;

-(void)drawInitialState;
-(void)setFromStation:(MItem*)fromStation;
-(void)setToStation:(MItem*)toStation;
-(UIImage*)drawCircleView:(UIColor*)myColor;
-(UIImage*)drawBiggerCircleView:(UIColor*)myColor;
-(void)transitToPathView;

-(void)resetFromStation;
-(void)resetToStation;
-(void)resetBothStations;


@end
