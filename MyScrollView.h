//
//  MyScrollView.h
//  tube
//
//  Created by Alex 1 on 10/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MyScrollView : UIScrollView  {

    UIView *scrolledView;
}

@property (nonatomic, assign) UIView* scrolledView;

@end
