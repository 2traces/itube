//
// Created by bsideup on 4/6/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "AnswerFileURL.h"


@implementation AnswerFileURL

{
	NSString *title;
}
+ (NSURL *)fileURLWithPath:(NSString *)path previewTitle:(NSString *)title
{
	return [[AnswerFileURL alloc] initWithFileURLWithPath:path previewTitle:title];
}

- (id)initWithFileURLWithPath:(NSString *)path previewTitle:(NSString *)previewTitle
{
	if(self = [super initFileURLWithPath:path isDirectory:NO]) {
		title = previewTitle;
        self.urlPath = path;
	}

	return self;
}

- (NSString *)previewItemTitle
{
	return title;
}


- (NSURL *)previewItemURL
{
	return [NSURL fileURLWithPath:self.urlPath];
}



@end