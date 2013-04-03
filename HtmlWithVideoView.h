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


@interface HtmlWithVideoView : UIView <MediaViewEvents>

- (id)initWithMedia:(MMedia *)media withParent:(UIView*)parent withAppDelegate:(tubeAppDelegate *)appDelegate;
- (void) restart;

@property (retain) NSString *videoPreviewPath;
@property CGRect videoFrame;
@property (retain) MPMoviePlayerController *moviePlayer;

@end
