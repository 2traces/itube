#import <UIKit/UIKit.h>

@interface UIImage (animatedGIF)

+ (UIImage *)animatedImageWithAnimatedGIFData:(NSData *)data duration:(NSTimeInterval)duration;
+ (UIImage *)animatedImageWithAnimatedGIFURL:(NSURL *)url duration:(NSTimeInterval)duration;
+ (NSArray *)imagesArrayWithAnimatedGIFData:(NSData *)data duration:(NSTimeInterval)duration;

@end
