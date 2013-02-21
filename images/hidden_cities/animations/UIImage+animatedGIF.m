#import "UIImage+animatedGIF.h"
#import <ImageIO/ImageIO.h>

#if __has_feature(objc_arc)
#define toCF (__bridge CFTypeRef)
#else
#define toCF (CFTypeRef)
#endif

@implementation UIImage (animatedGIF)

static UIImage *animatedImageWithAnimatedGIFImageSource(CGImageSourceRef source, NSTimeInterval duration) {
    if (!source)
        return nil;
    
    size_t count = CGImageSourceGetCount(source);
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:count];
    for (size_t i = 0; i < count; ++i) {
        CGImageRef cgImage = CGImageSourceCreateImageAtIndex(source, i, NULL);
        if (!cgImage)
            return nil;
        [images addObject:[UIImage imageWithCGImage:cgImage]];
        CGImageRelease(cgImage);
    }

    return [UIImage animatedImageWithImages:images duration:duration];
}


static NSArray *imagesArrayWithAnimatedGIFImageSource(CGImageSourceRef source, NSTimeInterval duration) {
    if (!source)
        return nil;
    
    size_t count = CGImageSourceGetCount(source);
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:count];
    for (size_t i = 0; i < count; ++i) {
        CGImageRef cgImage = CGImageSourceCreateImageAtIndex(source, i, NULL);
        if (!cgImage)
            return nil;
        [images addObject:[UIImage imageWithCGImage:cgImage]];
        CGImageRelease(cgImage);
    }
    
    return images;//[UIImage animatedImageWithImages:images duration:duration];
}


static NSArray *imagesArrayWithAnimatedGIFReleasingImageSource(CGImageSourceRef source, NSTimeInterval duration) {
    NSArray *images = imagesArrayWithAnimatedGIFImageSource(source, duration);
    CFRelease(source);
    return images;
}

static UIImage *animatedImageWithAnimatedGIFReleasingImageSource(CGImageSourceRef source, NSTimeInterval duration) {
    UIImage *image = animatedImageWithAnimatedGIFImageSource(source, duration);
    CFRelease(source);
    return image;
}

+ (UIImage *)animatedImageWithAnimatedGIFData:(NSData *)data duration:(NSTimeInterval)duration {
    return animatedImageWithAnimatedGIFReleasingImageSource(CGImageSourceCreateWithData(toCF data, NULL), duration);
}


+ (NSArray *)imagesArrayWithAnimatedGIFData:(NSData *)data duration:(NSTimeInterval)duration {
    return imagesArrayWithAnimatedGIFReleasingImageSource(CGImageSourceCreateWithData(toCF data, NULL), duration);
}

+ (UIImage *)animatedImageWithAnimatedGIFURL:(NSURL *)url duration:(NSTimeInterval)duration {
    return animatedImageWithAnimatedGIFReleasingImageSource(CGImageSourceCreateWithURL(toCF url, NULL), duration);
}

@end
