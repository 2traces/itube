//
//  PathScrollView.h
//  tube
//
//  Created by Sergey Mingalev on 01.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetalPageControl.h"

@protocol PathScrollViewProtocol;

@interface PathScrollView : UIView <UIScrollViewDelegate> {
    
}

@property (nonatomic,retain) UIScrollView *scrollView;
@property (nonatomic,assign) id <PathScrollViewProtocol> delegate;
@property (nonatomic,assign) int numberOfPages;
@property (nonatomic,assign) MetalPageControl *helpPageCon;

-(void)refreshContent;

@end

@protocol PathScrollViewProtocol

-(void)requestChangeActivePath:(NSNumber*)pathNumb;
-(void)animationDidEnd;

@end