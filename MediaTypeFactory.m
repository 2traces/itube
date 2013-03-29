//
//  MediaTypeFactory.m
//  tube
//
//  Created by alex on 28.03.13.
//
//

#import "MediaTypeFactory.h"
#import "Slide3DImageView.h"
#import "UIImage+animatedGIF.h"

@implementation MediaTypeFactory


+(UIImage*)imageForMedia:(MMedia *)media{
    tubeAppDelegate *appDelegate = 	(tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIImage *image = nil;
    NSArray *images = nil;
    NSString *imagePath = [NSString stringWithFormat:@"%@/photos/%@", appDelegate.mapDirectoryPath, media.filename];
    
    if (IS_IPAD)
    {
        NSString *iPadPath = [NSString stringWithFormat:@"%@/photos_ipad/%@", appDelegate.mapDirectoryPath, media.filename];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:iPadPath])
            imagePath = iPadPath;
    }
    
    if ([[[media.filename pathExtension] lowercaseString] isEqualToString:@"gif"]) {
        images = [UIImage imagesArrayWithAnimatedGIFData:[NSData dataWithContentsOfFile:imagePath] duration:2.5f];
        if (images) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:images[0]];
            imageView.animationImages = images;
            imageView.animationDuration = 2.5f;
            imageView.animationRepeatCount = [media.repeatCount integerValue];
            [imageView startAnimating];
            //...Returning UIImageView instead of declared UIImage...
            //I know that it's a crappy solution, however, the quickest possible,
            //as using animatedImage method of UIImage can't control repeat count —
            //we have to switch to animated UIImageView to be able to control amount
            //of times to repeat the animation.
            
            //Buddy, please don't do this again. Especially if you know what you are doint...
            return [imageView autorelease];
        }
    }
    else if ([[[media.filename pathExtension] lowercaseString] isEqualToString:@"mp4"]) {
        return nil;
    } else {
        image = [UIImage imageWithContentsOfFile:imagePath];
    }
    if (!image) {
        image = [UIImage imageNamed:@"no_image.jpeg"];
    }
    return image;
}

+ (UIView *)htmlWithVideoViewForMedia:(MMedia *)media withParent:(UIView*)parent withAppDelegate:(tubeAppDelegate *)appDelegate {
    UIView *mediaView;
    mediaView = [[UIView alloc] initWithFrame:parent.frame ];
    // Setup video
    NSString *videoPath = [NSString stringWithFormat:@"%@/%@", appDelegate.mapDirectoryPath, media.videoPath];
    MPMoviePlayerController *moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:videoPath]];
    moviePlayerController.movieSourceType = MPMovieSourceTypeFile;
    moviePlayerController.fullscreen = NO;
    moviePlayerController.controlStyle = MPMovieControlStyleNone;
    moviePlayerController.repeatMode = MPMovieRepeatModeOne;
    moviePlayerController.shouldAutoplay = YES;
    moviePlayerController.scalingMode = MPMovieScalingModeAspectFill;
    [moviePlayerController prepareToPlay];
    UIView *movieView = moviePlayerController.view;
    CGFloat videoWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat videoHeight = videoWidth * 428 / 768;
    movieView.frame = CGRectMake(0, 0, videoWidth, videoHeight);
    [mediaView addSubview:movieView];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, videoHeight,
                                                                     videoWidth,
                                                                     parent.frame.size.height-videoHeight)];
    NSString *htmlPath = [NSString stringWithFormat:@"%@/%@", appDelegate.mapDirectoryPath, media.filename];
    NSURL* url = [NSURL fileURLWithPath:htmlPath];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    [mediaView addSubview:webView];
    return mediaView;
}

+(UIView*)viewForMedia:(MMedia *)media withParent:(UIView*)parent withOrientation:(UIInterfaceOrientation)orientation withIndex:(int)index{
    UIImage *image = [self imageForMedia:media];
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIView *mediaView = nil;
    if ([media.mediaType isEqualToString:@"3dview"]) {
        NSString *prefix = [NSString stringWithFormat:@"%@/photos/%@", appDelegate.mapDirectoryPath, media.slide3D.photosPrefix];
        Slide3DImageView *imageView = [[Slide3DImageView alloc]
                                       initWithImage:image
                                       withPrefix:prefix
                                       withExt:media.slide3D.photosExt
                                       withSlidesCount:[media.slide3D.photosCount intValue]];
        mediaView = imageView;
    }else if ([media.mediaType isEqualToString:@"html"]) {
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        mediaView = webView;
        NSString *htmlPath = [NSString stringWithFormat:@"%@/%@", appDelegate.mapDirectoryPath, media.filename];
        NSURL* url = [NSURL fileURLWithPath:htmlPath];
        NSURLRequest* request = [NSURLRequest requestWithURL:url];
        [webView loadRequest:request];
    }else if ([media.mediaType isEqualToString:@"html_with_video"]) {
        mediaView = [self htmlWithVideoViewForMedia:media withParent:parent withAppDelegate:appDelegate];
    }else if (!image) {
        //OMG, it's not an image, it's a... Video!
        NSString *videoPath = [NSString stringWithFormat:@"%@/photos/%@", appDelegate.mapDirectoryPath, media.filename];
        NSLog(@"video path %@", videoPath);
        
        if (IS_IPAD)
        {
            NSString *iPadPath = [NSString stringWithFormat:@"%@/photos_ipad/%@", appDelegate.mapDirectoryPath, media.filename];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:iPadPath])
                videoPath = iPadPath;
        }
        
        MPMoviePlayerController *moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:videoPath]];
        moviePlayerController.movieSourceType = MPMovieSourceTypeFile;
        moviePlayerController.fullscreen = NO;
        moviePlayerController.controlStyle = MPMovieControlStyleNone;
        moviePlayerController.repeatMode = MPMovieRepeatModeNone;
        moviePlayerController.shouldAutoplay = YES;
        [moviePlayerController prepareToPlay];
        [moviePlayerController stop];
        mediaView = [moviePlayerController.view retain];
        //[moviePlayerController autorelease];
        [moviePlayerController autorelease];
        
    }
    else if ([image isKindOfClass:[UIImageView class]]) {
        //...Checking if we got UIImageView instead of expected UIImage...
        //I know that it's a crappy solution, however, the quickest possible,
        //as using animatedImage method of UIImage can't control repeat count —
        //we have to switch to animated UIImageView to be able to control amount
        //of times to repeat the animation.
        mediaView = [(UIImageView*)image retain];
    }
    else {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        mediaView = imageView;
    }
    
    mediaView.contentMode = UIViewContentModeScaleAspectFill;
    mediaView.clipsToBounds = YES;
    if (mediaView.frame.size.width < parent.frame.size.width ||
        mediaView.frame.size.height < parent.frame.size.height ) {
        mediaView.contentMode = UIViewContentModeCenter;
        
    }
    mediaView.frame = parent.frame;
    CGRect imageFrame = mediaView.frame;
    if (IS_IPAD) {
        CGRect windowBounds = [[UIScreen mainScreen] bounds];
        float width = UIInterfaceOrientationIsPortrait(orientation) ? windowBounds.size.width : windowBounds.size.height;
        
        imageFrame.size.width = width;
        imageFrame.origin.y = 0;
        imageFrame.origin.x = (width + 20) * index;
    }
    else
    {
        imageFrame.size.width -= 20;
        imageFrame.origin.x = parent.frame.size.width * index;
        imageFrame.origin.y = 0;
    }
    mediaView.frame = imageFrame;
    //move to user code
    mediaView.tag = index + 1;
    return [mediaView autorelease];
}

@end
