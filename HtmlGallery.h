//
//  HtmlGallery.h
//  tube
//
//  Created by alex on 08.04.13.
//
//

#import <UIKit/UIKit.h>
#import "ManagedObjects.h"
#import "tubeAppDelegate.h"

@interface HtmlGallery : UIView <UIWebViewDelegate>

- (id)initWithMedia:(MMedia *)media withParent:(UIView*)parent withAppDelegate:(tubeAppDelegate *)appDelegate;

@property (retain) UIImageView *mainImageView;
@property (retain) NSString *htmlDir;
@property (retain) UIWebView *webView;

@end
