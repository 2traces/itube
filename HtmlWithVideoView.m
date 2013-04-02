//
//  HtmlWithVideoView.m
//  tube
//
//  Created by alex on 01.04.13.
//
//

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
        self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:videoPath]];
        self.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
        self.moviePlayer.fullscreen = NO;
        self.moviePlayer.controlStyle = MPMovieControlStyleNone;
        self.moviePlayer.repeatMode = MPMovieRepeatModeNone;
        self.moviePlayer.shouldAutoplay = YES;
        self.moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
        [self.moviePlayer prepareToPlay];
        UIView *movieView = self.moviePlayer.view;
        CGFloat videoWidth = [[UIScreen mainScreen] bounds].size.width;
        CGFloat videoHeight = videoWidth * 428 / 768;
        self.videoFrame = CGRectMake(0, 0, videoWidth, videoHeight);
        movieView.frame = self.videoFrame;
        movieView.userInteractionEnabled = YES;
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

- (void) restart{
    [self.moviePlayer stop];
    [self.moviePlayer play];
}

-(void)dealloc{
    self.videoPreviewPath = nil;
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
