//
//  LCUtil.m
//  tube
//
//  Created by alex on 21.06.13.
//
//

#import "LCUtil.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)

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

+ (NSString*) getPhotoPathWithMapDirectory:(NSString*) mapDirectoryPath withPath:(NSString*)path iphone5:(BOOL)iphone5{
    NSString *imagePath = [NSString stringWithFormat:@"%@/photos/%@", mapDirectoryPath, path];
    if (iphone5)
    {
        NSString *iPadPath = [NSString stringWithFormat:@"%@/photos_iphone5/%@", mapDirectoryPath, path];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:iPadPath])
            imagePath = iPadPath;
    } else {
        if (IS_IPAD)
        {
            NSString *iPadPath = [NSString stringWithFormat:@"%@/photos_ipad/%@", mapDirectoryPath, path];
            if ([[NSFileManager defaultManager] fileExistsAtPath:iPadPath])
                imagePath = iPadPath;
        }
    }
    return imagePath;
}

+ (NSString*) getLocalizedPhotoPathWithMapDirectory:(NSString *)mapDirectoryPath withPath:(NSString *)path{
    return [LCUtil getLocalizedPath:[LCUtil getPhotoPathWithMapDirectory:mapDirectoryPath withPath:path iphone5:NO]];
}

+ (NSString*) getLocalizedPhotoPathWithMapDirectory:(NSString *)mapDirectoryPath withPath:(NSString *)path iphone5:(BOOL)iphone5{
    return [LCUtil getLocalizedPath:[LCUtil getPhotoPathWithMapDirectory:mapDirectoryPath withPath:path iphone5:iphone5]];
}


@end
