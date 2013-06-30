//
// Created by Sergey Egorov on 6/30/13.
// Copyright (c) 2013 Trylogic. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "BooksService.h"
#import "NSObject+homeWorksServiceLocator.h"


@implementation BooksService
{

}
- (BOOL)isAvailableOfflineWithTermId:(NSString *)termId withSubjectId:(NSString *)subjectId withBookId:(NSString *)bookId
{
	NSString *offlineFilePath = [NSString stringWithFormat:self.offlineFilePathStringFormat,
														   termId,
														   subjectId,
														   bookId];

	return [[NSFileManager defaultManager] fileExistsAtPath:offlineFilePath];
}

@end