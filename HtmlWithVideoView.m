//
//  HtmlWithVideoView.m
//  tube
//
//  Created by alex on 01.04.13.
//
//

#import "HtmlWithVideoView.h"
#import "ColorFactory.h"

@implementation HtmlWithVideoView

@synthesize videoPreview;
@synthesize lightPanel;
@synthesize lightGray;
@synthesize moviePlayer;

- (id)initWithMedia:(MMedia *)media withParent:(UIView*)parent withAppDelegate:(tubeAppDelegate *)appDelegate
{
    self = [super initWithFrame:parent.frame];
    if (self) {
        // Setup video
        // #lightGray color is #f5f4f5
        self.lightGray = [ColorFactory lightGrayColor];
        self.backgroundColor = self.lightGray;
        NSString *videoPath = [NSString stringWithFormat:@"%@/%@", appDelegate.mapDirectoryPath, media.videoPath];
        NSString *videoPreviewPath = [NSString stringWithFormat:@"%@/%@", appDelegate.mapDirectoryPath, media.previewPath];
        self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:videoPath]];
        self.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
        self.moviePlayer.fullscreen = NO;
        self.moviePlayer.controlStyle = MPMovieControlStyleNone;
        self.moviePlayer.repeatMode = MPMovieRepeatModeNone;
        self.moviePlayer.shouldAutoplay = YES;
        self.moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
        self.moviePlayer.view.backgroundColor = lightGray;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPlaybackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPlaybackStarted:) name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:self.moviePlayer];
        
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
        
        self.lightPanel = [[UIView alloc] initWithFrame:videoFrame];
        self.lightPanel.backgroundColor = lightGray;
        [self addSubview:self.lightPanel];
        
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, videoHeight,
                                                                         videoWidth,
                                                                         parent.frame.size.height-videoHeight)];
        webView.scrollView.bounces = NO;
        NSString *htmlPath = [NSString stringWithFormat:@"%@/%@", appDelegate.mapDirectoryPath, media.filename];
        NSURL* url = [NSURL fileURLWithPath:htmlPath];
        NSURLRequest* request = [NSURLRequest requestWithURL:url];
        [webView loadRequest:request];
        webView.backgroundColor = self.lightGray;
        webView.opaque = NO;
        [self addSubview:webView];
    }
    return self;
}

- (void) playerPlaybackDidFinish:(NSNotification*)notification{
    self.videoPreview.hidden = NO;
    self.lightPanel.hidden = YES;
}

- (void) playerPlaybackStarted:(NSNotification*)notification{
    self.lightPanel.hidden = NO;
    self.videoPreview.hidden = YES;
//    [UIView animateWithDuration:1  animations:^{
//        self.lightPanel.alpha = 0;
//    } completion: ^(BOOL finished) {
//        if (finished) {
            self.lightPanel.hidden = YES;
            self.lightPanel.alpha = 1;
//        }
//    }];
}

- (void) restart{
    [self.moviePlayer stop];
    [self.moviePlayer play];
}

- (void) onFocusReceive{
    [self restart];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:self.moviePlayer];
    [self.videoPreview release];
    [self.moviePlayer stop];
    [self.moviePlayer release];
    [self.lightGray release];
    [self.lightPanel release];
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
