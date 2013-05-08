//
//  HtmlGallery.m
//  tube
//
//  Created by alex on 08.04.13.
//
//

#import "HtmlGallery.h"
#import "ColorFactory.h"

@implementation HtmlGallery

@synthesize mainImageView = _mainImageView;
@synthesize htmlDir = _htmlDir;

- (id)initWithMedia:(MMedia *)media withParent:(UIView *)parent withAppDelegate:(tubeAppDelegate *)appDelegate{
    self = [super initWithFrame:parent.frame];
    if (self) {
        UIWebView *webView = [[UIWebView alloc] initWithFrame:parent.frame];
        [webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        webView.delegate = self;
        NSString *htmlPath = [NSString stringWithFormat:@"%@/%@", appDelegate.mapDirectoryPath, media.filename];
        self.htmlDir = [htmlPath stringByDeletingLastPathComponent];
        NSURL* url = [NSURL fileURLWithPath:htmlPath];
        NSURLRequest* request = [NSURLRequest requestWithURL:url];
        [webView loadRequest:request];
        [self addSubview:webView];
        
        self.mainImageView = [[UIImageView alloc] initWithFrame:parent.frame];
        self.mainImageView.alpha = 0.0;
        self.mainImageView.hidden = NO;
        [self.mainImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        self.mainImageView.userInteractionEnabled = YES;
        [self.mainImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mainImageTapped:)]];
        self.mainImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.mainImageView.backgroundColor = [ColorFactory lightGrayColor];
        [self addSubview:self.mainImageView];
    }
    return self;
}

- (void)mainImageTapped:(UITapGestureRecognizer*)recognizer{
    [self fadeOutMainImage];
}

- (void) fadeInMainImage{
    self.mainImageView.hidden = NO;
    [UIView animateWithDuration:0.7 animations:^{
        self.mainImageView.alpha = 1.0;
    }];
}

- (void) fadeOutMainImage{
    [UIView animateWithDuration:0.7 animations:^{
        self.mainImageView.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.mainImageView.hidden = YES;
    }];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if([request.URL.absoluteString hasPrefix:@"preview"]){
        NSString *filename = [request.URL.absoluteString substringFromIndex:10];
        NSString *fullPath = [NSString stringWithFormat:@"%@/%@", self.htmlDir, filename];
        [self showImageWithPath:fullPath];
    }
    return YES;
}

- (void)showImageWithPath:(NSString*)path{
    self.mainImageView.image = [UIImage imageWithContentsOfFile:path];
    [self fadeInMainImage];
}

- (void)dealloc{
    [_mainImageView release];
    self.mainImageView = nil;
    [_htmlDir release];
    self.htmlDir = nil;
    [super dealloc];
}

@end
