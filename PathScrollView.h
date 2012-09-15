//
//  PathScrollView.h
//  tube
//
//  Created by sergey on 01.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PathScrollViewProtocol;

@interface PathScrollView : UIView <UIScrollViewDelegate> {
    
}

@property (nonatomic,retain) UIScrollView *scrollView;
@property (nonatomic,assign) id <PathScrollViewProtocol> delegate;
@property (nonatomic,assign) int numberOfPages;

-(void)refreshContent;

@end

@protocol PathScrollViewProtocol

-(void)requestChangeActivePath:(NSNumber*)pathNumb;
-(void)animationDidEnd;

@end