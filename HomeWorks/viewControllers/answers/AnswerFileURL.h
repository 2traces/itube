//
// Created by bsideup on 4/6/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import <QuickLook/QuickLook.h>


@interface AnswerFileURL : NSURL<QLPreviewItem>

@property(readonly) NSURL * previewItemURL;

+(NSURL *)fileURLWithPath:(NSString *)path previewTitle:(NSString *)title;

- (id)initWithFileURLWithPath:(NSString *)path previewTitle:(NSString *)title;

@end