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

@synthesize videoPreview = _videoPreview;
@synthesize lightPanel = _lightPanel;
@synthesize moviePlayer = _moviePlayer;
@synthesize videoPreviewImage = _videoPreviewImage;

- (id)initWithMedia:(MMedia *)media withParent:(UIView*)parent withAppDelegate:(tubeAppDelegate *)appDelegate withVideo:(BOOL)withVideo
{
    self = [super initWithFrame:parent.frame];
    if (self) {
        // Setup video
        // #lightGray color is #f5f4f5
        self.backgroundColor = [ColorFactory lightGrayColor];
        CGFloat videoWidth = parent.bounds.size.width;
        CGFloat videoHeight = videoWidth * 428 / 768;
        CGFloat webViewY = videoHeight;
        CGRect videoFrame = CGRectMake(0, 0, videoWidth, videoHeight);
        NSString *videoPreviewPath = [NSString stringWithFormat:@"%@/%@", appDelegate.mapDirectoryPath, media.previewPath];
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
        NSString *htmlPath = [NSString stringWithFormat:@"%@/%@", appDelegate.mapDirectoryPath, media.filename];
        NSURL* url = [NSURL fileURLWithPath:htmlPath];
        NSURLRequest* request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
        self.webView.backgroundColor = [ColorFactory lightGrayColor];
        self.webView.opaque = NO;
        [self addSubview:self.webView];
    }
    return self;
}

- (void)createMoviePlayer:(MMedia *)media appDelegate:(tubeAppDelegate *)appDelegate videoFrame:(CGRect)videoFrame
{
    NSString *videoPath = [NSString stringWithFormat:@"%@/%@", appDelegate.mapDirectoryPath, media.videoPath];
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

- (id)initWithMedia:(MMedia *)media withParent:(UIView *)parent withAppDelegate:(tubeAppDelegate *)appDelegate{
    self = [self initWithMedia:media withParent:parent withAppDelegate:appDelegate withVideo:YES];
    if (self) {
        
    }
    return self;
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
