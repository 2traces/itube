//
//  StationTextField.h
//  tube
//
//  Created by Sergey Mingalev on 11.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ManagedObjects.h"
#import "TopTwoStationsView.h"

typedef NS_ENUM(NSInteger, StationTextFieldStyle) {
    StationTextFieldStyleDefault,
    StationTextFieldStyleStation,
    StationTextFieldStyleSearch,
    StationTextFieldStylePath
};

@interface StationTextField : UITextField
{
    NSInteger state;
    MStation *station;
}

@property (nonatomic,assign) int state;
@property (nonatomic, retain) MStation *station;
@property (nonatomic, assign) TopTwoStationsView *parentView;

- (id)initWithFrame:(CGRect)frame andStyle:(StationTextFieldStyle)style;
-(void)changeStyleTo:(StationTextFieldStyle)style withFrame:(CGRect)frame animated:(BOOL)animated;

@end
