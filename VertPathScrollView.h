//
//  VertPathScrollView.h
//  tube
//
//  Created by Sergey Mingalev on 01.08.12.
//
//

#import <UIKit/UIKit.h>
#import "Classes/MainViewController.h"
#import "PathDrawVertView.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@class MainViewController;

@interface VertPathScrollView : UIScrollView <UIScrollViewDelegate,PathDrawProtocol,MFMailComposeViewControllerDelegate> {
    MainViewController *myMainController;
}

@property (nonatomic,retain) MainViewController *mainController;

-(void)drawPathScrollView;

@end
