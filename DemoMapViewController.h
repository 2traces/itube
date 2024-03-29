//
//  DemoMapViewController.h
//  tube
//
//  Created by Sergey Mingalev on 21.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageDownloader.h"

@protocol DemoMapProtocol;

@interface DemoMapViewController : UIViewController <ImageDownloaderDelegate>
{
    id <DemoMapProtocol> delegate; 
    
    IBOutlet UIScrollView *scrollView;
    IBOutlet UITextView *text1;
    IBOutlet UITextView *text2;
    IBOutlet UITextView *text3;
    IBOutlet UIImageView *image1;
    IBOutlet UIImageView *image2;
    IBOutlet UIImageView *image3;
    IBOutlet UIButton *buyButton;
    
    NSString *filename;
    NSString *prodID;
    NSString *cityName;
    
    NSMutableDictionary *imageDownloadsInProgress;  
}

@property (nonatomic, assign) id <DemoMapProtocol> delegate;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UITextView *text1;
@property (nonatomic, retain) IBOutlet UITextView *text2;
@property (nonatomic, retain) IBOutlet UITextView *text3;
@property (nonatomic, retain) IBOutlet UIImageView *image1;
@property (nonatomic, retain) IBOutlet UIImageView *image2;
@property (nonatomic, retain) IBOutlet UIImageView *image3;
@property (nonatomic, retain) IBOutlet UIButton *buyButton;
@property (nonatomic, retain) NSString *prodID;
@property (nonatomic, retain) NSString *filename;
@property (nonatomic, retain) NSString *cityName;

@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;

@end

@protocol DemoMapProtocol

-(void)returnWithPurchase:(NSString*)prodID;
-(BOOL)isProductStatusAvailable:(NSString*)prodID;

@end