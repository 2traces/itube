//
//  LCUtil.m
//  tube
//
//  Created by alex on 21.06.13.
//
//

#import "LCUtil.h"

@implementation LCUtil

+ (NSString*) getLocalizedPath:(NSString *)path{
    NSString *lang = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString *basePath = [path stringByDeletingPathExtension];
    NSString *ext = [path pathExtension];
    
    NSString *tryPath = [NSString stringWithFormat:@"%@-%@.%@", basePath, lang, ext];
    if ([[NSFileManager defaultManager] fileExistsAtPath:tryPath] ) {
        return tryPath;
    }
    return path;
}

@end
