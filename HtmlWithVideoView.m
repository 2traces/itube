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

@synthesize videoFrame;
@synthesize videoPreviewPath;

- (id)initWithMedia:(MMedia *)media withParent:(UIView*)parent withAppDelegate:(tubeAppDelegate *)appDelegate
{
    self = [super initWithFrame:parent.frame];
    if (self) {
        // Setup video
        NSString *videoPath = [NSString stringWithFormat:@"%@/%@", appDelegate.mapDirectoryPath, media.videoPath];
        self.videoPreviewPath = [NSString stringWithFormat:@"%@/%@", appDelegate.mapDirectoryPath, media.previewPath];
        MPMoviePlayerController *moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:videoPath]];
        moviePlayerController.movieSourceType = MPMovieSourceTypeFile;
        moviePlayerController.fullscreen = NO;
        moviePlayerController.controlStyle = MPMovieControlStyleNone;
        moviePlayerController.repeatMode = MPMovieRepeatModeNone;
        moviePlayerController.shouldAutoplay = YES;
        moviePlayerController.scalingMode = MPMovieScalingModeAspectFill;
        [moviePlayerController prepareToPlay];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPlaybackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayerController];
        UIView *movieView = moviePlayerController.view;
        CGFloat videoWidth = [[UIScreen mainScreen] bounds].size.width;
        CGFloat videoHeight = videoWidth * 428 / 768;
        self.videoFrame = CGRectMake(0, 0, videoWidth, videoHeight);
        movieView.frame = self.videoFrame;
        movieView.userInteractionEnabled = NO;
        [self addSubview:movieView];
        
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, videoHeight,
                                                                         videoWidth,
                                                                         parent.frame.size.height-videoHeight)];
        if (IS_IPAD) {
            webView.userInteractionEnabled = NO;
        }
        NSString *htmlPath = [NSString stringWithFormat:@"%@/%@", appDelegate.mapDirectoryPath, media.filename];
        NSURL* url = [NSURL fileURLWithPath:htmlPath];
        NSURLRequest* request = [NSURLRequest requestWithURL:url];
        [webView loadRequest:request];
        [self addSubview:webView];
    }
    return self;
}

- (void) playerPlaybackDidFinish:(NSNotification*)notification{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    UIImageView *videoPreview = [[UIImageView alloc] initWithFrame:self.videoFrame];
    videoPreview.image = [[UIImage alloc] initWithContentsOfFile:self.videoPreviewPath];
    [self addSubview:videoPreview];
}

-(void)dealloc{
    self.videoPreviewPath = nil;
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
