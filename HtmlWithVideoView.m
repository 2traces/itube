//
//  HtmlWithVideoView.m
//  tube
//
//  Created by alex on 01.04.13.
//
//
#import <MediaPlayer/MediaPlayer.h>

#import "HtmlWithVideoView.h"

@implementation HtmlWithVideoView

- (id)initWithMedia:(MMedia *)media withParent:(UIView*)parent withAppDelegate:(tubeAppDelegate *)appDelegate
{
    NSLog(@"html with video %@", media.description);
    self = [super initWithFrame:parent.frame];
    if (self) {
        // Setup video
        NSString *videoPath = [NSString stringWithFormat:@"%@/%@", appDelegate.mapDirectoryPath, media.videoPath];
        NSString *videoPreviewPath = [NSString stringWithFormat:@"%@/%@", appDelegate.mapDirectoryPath, media.previewPath];
        NSLog(@"preview path exists %i", [[NSFileManager defaultManager] fileExistsAtPath:videoPreviewPath]);
        MPMoviePlayerController *moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:videoPath]];
        moviePlayerController.movieSourceType = MPMovieSourceTypeFile;
        moviePlayerController.fullscreen = NO;
        moviePlayerController.controlStyle = MPMovieControlStyleNone;
        moviePlayerController.repeatMode = MPMovieRepeatModeNone;
        moviePlayerController.shouldAutoplay = YES;
        moviePlayerController.scalingMode = MPMovieScalingModeAspectFill;
        [moviePlayerController prepareToPlay];
        UIView *movieView = moviePlayerController.view;
        CGFloat videoWidth = [[UIScreen mainScreen] bounds].size.width;
        CGFloat videoHeight = videoWidth * 428 / 768;
        CGRect videoRect = CGRectMake(0, 0, videoWidth, videoHeight);
        UIImageView *videoPreview = [[UIImageView alloc] initWithFrame:videoRect];
        videoPreview.image = [[UIImage alloc] initWithContentsOfFile:videoPreviewPath];
        [self addSubview:videoPreview];
        
        movieView.frame = videoRect;
        movieView.userInteractionEnabled = NO;
        [self addSubview:movieView];
        
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, videoHeight,
                                                                         videoWidth,
                                                                         parent.frame.size.height-videoHeight)];
        NSString *htmlPath = [NSString stringWithFormat:@"%@/%@", appDelegate.mapDirectoryPath, media.filename];
        NSURL* url = [NSURL fileURLWithPath:htmlPath];
        NSURLRequest* request = [NSURLRequest requestWithURL:url];
        [webView loadRequest:request];
        [self addSubview:webView];
    }
    return self;
}

- (void) playerPlaybackDidFinish:(NSNotification*)notification{
    
}

-(void)dealloc{
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
