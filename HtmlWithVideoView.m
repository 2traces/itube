//
//  HtmlWithVideoView.m
//  tube
//
//  Created by alex on 01.04.13.
//
//

#import "HtmlWithVideoView.h"
#import "ColorFactory.h"
#import "LCUtil.h"

@implementation HtmlWithVideoView

@synthesize videoPreview = _videoPreview;
@synthesize lightPanel = _lightPanel;
@synthesize moviePlayer = _moviePlayer;
@synthesize videoPreviewImage = _videoPreviewImage;
@synthesize tapGR = _tapGR;
@synthesize webViewRect;
@synthesize fullRect;
@synthesize webviewMaxmized;

- (id)initWithMedia:(MMedia *)media withParent:(UIView*)parent withAppDelegate:(tubeAppDelegate *)appDelegate withVideo:(BOOL)withVideo
{
    self = [super initWithFrame:parent.frame];
    if (self) {
        // Setup video
        // #lightGray color is #f5f4f5
        self.webviewMaxmized = false;
        self.backgroundColor = [ColorFactory lightGrayColor];
        CGFloat videoWidth;
        if(withVideo){
            videoWidth = [[UIScreen mainScreen] bounds].size.width;
        }else{
            videoWidth = parent.frame.size.width;
        }
        CGFloat videoHeight = videoWidth * 428 / 768;
        CGFloat webViewY = videoHeight;
        CGRect videoFrame = CGRectMake(0, 0, videoWidth, videoHeight);
        NSString *videoPreviewPath = [LCUtil getLocalizedPath:[NSString stringWithFormat:@"%@/%@", appDelegate.mapDirectoryPath, media.previewPath]];
        if (withVideo) {
            [self createMoviePlayer:media appDelegate:appDelegate videoFrame:videoFrame];
        }else{
            if(IS_IPAD){
                webViewY = 20;
            }else{
                webViewY = 10;
            }
        }
        self.videoPreviewImage = [[DebugUIImage alloc] initWithContentsOfFile:videoPreviewPath];
        self.videoPreview = [[DebugUIImageView alloc] initWithFrame:videoFrame];
        self.videoPreview.image = self.videoPreviewImage;
    
        self.lightPanel = [[UIView alloc] initWithFrame:videoFrame];
        self.lightPanel.backgroundColor = [ColorFactory lightGrayColor];
        if (withVideo) {
            [self addSubview:self.videoPreview];
            [self addSubview:self.lightPanel];
        }
        self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, webViewY,
                                                                         videoWidth,
                                                                         parent.frame.size.height-webViewY)];
        self.webView.scrollView.bounces = NO;
        NSString *htmlPath = [LCUtil getLocalizedPath:[NSString stringWithFormat:@"%@/%@", appDelegate.mapDirectoryPath, media.filename]];
        NSURL* url = [NSURL fileURLWithPath:htmlPath];
        NSURLRequest* request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
        self.webView.backgroundColor = [ColorFactory lightGrayColor];
        self.webView.opaque = NO;
        [self addSubview:self.webView];
        self.tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(webViewTapped:)];
        self.tapGR.delegate = self;
        [self.webView addGestureRecognizer:self.tapGR];
    }
    return self;
}

- (id)initWithMedia:(MMedia *)media withParent:(UIView *)parent withAppDelegate:(tubeAppDelegate *)appDelegate{
    self = [self initWithMedia:media withParent:parent withAppDelegate:appDelegate withVideo:YES];
    if (self) {
        
    }
    return self;
}

- (void) webViewTapped:(UITapGestureRecognizer*)recognizer{
    NSLog(@"webview tapped");
    if (self.webviewMaxmized){
        [self minimizeWebView];
    }else{
        [self maximizeWebView];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void) maximizeWebView{
    self.webViewRect = self.webView.frame;
    self.fullRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [UIView animateWithDuration:0.7 animations:^{
        self.webView.frame = self.fullRect;
    }];
    self.webviewMaxmized = true;
}

- (void) minimizeWebView{
    [UIView animateWithDuration:0.7 animations:^{
        self.webView.frame = self.webViewRect;
    }];
    self.webviewMaxmized = false;
}

- (void)createMoviePlayer:(MMedia *)media appDelegate:(tubeAppDelegate *)appDelegate videoFrame:(CGRect)videoFrame
{
    NSString *videoPath = [LCUtil getLocalizedPath:[NSString stringWithFormat:@"%@/%@", appDelegate.mapDirectoryPath, media.videoPath]];
    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:videoPath]];
    self.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    self.moviePlayer.fullscreen = NO;
    self.moviePlayer.controlStyle = MPMovieControlStyleNone;
    self.moviePlayer.repeatMode = MPMovieRepeatModeNone;
    self.moviePlayer.shouldAutoplay = YES;
    self.moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
    self.moviePlayer.view.backgroundColor = [ColorFactory lightGrayColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPlaybackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPlaybackStarted:) name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:self.moviePlayer];
    
    UIView *movieView = self.moviePlayer.view;
    
    
    movieView.frame = videoFrame;
    movieView.userInteractionEnabled = YES;
    [self addSubview:movieView];
}

- (void) playerPlaybackDidFinish:(NSNotification*)notification{
    self.videoPreview.hidden = NO;
    self.lightPanel.alpha = 1;
    self.lightPanel.hidden = YES;
}

- (void) playerPlaybackStarted:(NSNotification*)notification{
    self.lightPanel.hidden = NO;
    self.videoPreview.hidden = YES;
    [UIView animateWithDuration:1  animations:^{
        self.lightPanel.alpha = 0;
    }];
}

- (void) restart{
    [self.moviePlayer stop];
    [self.moviePlayer play];
}

- (void) onFocusReceive{
    [self restart];
}

-(void)dealloc{
    NSLog(@"dealloc HtmlWithVideoView");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:self.moviePlayer];
    self.tapGR.delegate = nil;
    [self.webView removeGestureRecognizer:self.tapGR];
    [_tapGR release];
    self.videoPreview.image = nil;
    [self.videoPreview removeFromSuperview];
    [_videoPreview release];
    self.videoPreview = nil;
    
    [self.webView removeFromSuperview];
    [_webView release];
    self.webView = nil;
    
    [_videoPreviewImage release];
    self.videoPreviewImage = nil;
    
    [self.moviePlayer stop];
    [_moviePlayer release];
    self.moviePlayer = nil;
    self.lightPanel = nil;
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
