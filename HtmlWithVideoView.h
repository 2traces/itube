//
//  HtmlWithVideoView.h
//  tube
//
//  Created by alex on 01.04.13.
//
//

#import <UIKit/UIKit.h>
#import "tubeAppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MediaViewEvents.h"
#import "DebugUIImage.h"
#import "DebugUIImageView.h"


@interface HtmlWithVideoView : UIView <MediaViewEvents, UIGestureRecognizerDelegate>

- (id)initWithMedia:(MMedia *)media withParent:(UIView*)parent withAppDelegate:(tubeAppDelegate *)appDelegate;
- (id)initWithMedia:(MMedia *)media withParent:(UIView*)parent withAppDelegate:(tubeAppDelegate *)appDelegate withVideo:(BOOL)flag;
- (void) restart;

@property (retain) DebugUIImageView *videoPreview;
@property (retain) DebugUIImage *videoPreviewImage;
@property (retain) UIView *lightPanel;
@property (retain) MPMoviePlayerController *moviePlayer;
@property (retain) UIWebView *webView;
@property CGRect webViewRect;
@property CGRect fullRect;
@property BOOL webviewMaxmized;
@property (retain) UITapGestureRecognizer *tapGR;

@end
