//
//  HtmlWithVideoView.m
//  tube
//
//  Created by alex on 01.04.13.
//
//

#import "HtmlWithVideoView.h"

@implementation HtmlWithVideoView

@synthesize videoPreview;

- (id)initWithMedia:(MMedia *)media withParent:(UIView*)parent withAppDelegate:(tubeAppDelegate *)appDelegate
{
    self = [super initWithFrame:parent.frame];
    if (self) {
        // Setup video
        NSString *videoPath = [NSString stringWithFormat:@"%@/%@", appDelegate.mapDirectoryPath, media.videoPath];
        NSString *videoPreviewPath = [NSString stringWithFormat:@"%@/%@", appDelegate.mapDirectoryPath, media.previewPath];
        self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:videoPath]];
        self.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
        self.moviePlayer.fullscreen = NO;
        self.moviePlayer.controlStyle = MPMovieControlStyleNone;
        self.moviePlayer.repeatMode = MPMovieRepeatModeNone;
        self.moviePlayer.shouldAutoplay = YES;
        self.moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
        
        UIView *movieView = self.moviePlayer.view;
        CGFloat videoWidth = [[UIScreen mainScreen] bounds].size.width;
        CGFloat videoHeight = videoWidth * 428 / 768;
        CGRect videoFrame = CGRectMake(0, 0, videoWidth, videoHeight);
        movieView.frame = videoFrame;
        movieView.userInteractionEnabled = YES;
        [self addSubview:movieView];
        
        self.videoPreview = [[UIImageView alloc] initWithFrame:videoFrame];
        self.videoPreview.image = [[UIImage alloc] initWithContentsOfFile:videoPreviewPath];
        [self addSubview:self.videoPreview];
        
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, videoHeight,
                                                                         videoWidth,
                                                                         parent.frame.size.height-videoHeight)];
        webView.scrollView.bounces = NO;
        NSString *htmlPath = [NSString stringWithFormat:@"%@/%@", appDelegate.mapDirectoryPath, media.filename];
        NSURL* url = [NSURL fileURLWithPath:htmlPath];
        NSURLRequest* request = [NSURLRequest requestWithURL:url];
        [webView loadRequest:request];
        [self addSubview:webView];
    }
    return self;
}

- (void) restart{
    self.videoPreview.hidden =YES;
    [self.moviePlayer stop];
    [self.moviePlayer play];
}

- (void) onFocusReceive{
    [self restart];
}

-(void)dealloc{
    [self.videoPreview release];
    [self.moviePlayer release];
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
