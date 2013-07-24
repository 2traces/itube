//
//  LCUtil.h
//  tube
//
//  Created by alex on 21.06.13.
//
//

#import <Foundation/Foundation.h>

@interface LCUtil : NSObject

+ (NSString*) getLocalizedPath:(NSString*) path;
+ (NSString*) getLocalizedPhotoPathWithMapDirectory:(NSString*) mapDirectoryPath withPath:(NSString*)path;
+ (NSString*) getLocalizedPhotoPathWithMapDirectory:(NSString*) mapDirectoryPath withPath:(NSString*)path iphone5:(BOOL)iphone5;

@end
