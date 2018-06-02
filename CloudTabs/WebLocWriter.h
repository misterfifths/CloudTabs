// 2018 / Tim Clem / github.com/misterfifths
// Public domain.

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN


@interface WebLocWriter : NSObject

+(BOOL)writeWebLocForURL:(NSURL *)webURL
                   title:(nullable NSString *)title
             toDirectory:(NSURL *)directoryURL
                   error:(NSError **)error;

@end


NS_ASSUME_NONNULL_END
