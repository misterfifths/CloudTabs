// 2018 / Tim Clem / github.com/misterfifths
// Public domain.

#import <AppKit/AppKit.h>


NS_ASSUME_NONNULL_BEGIN


@interface AppDelegate : NSObject <NSApplicationDelegate>

+(instancetype)new NS_UNAVAILABLE;
-(instancetype)init NS_UNAVAILABLE;

-(instancetype)initWithDumpDirectoryURL:(NSURL *)dumpDirectoryURL;

@end


NS_ASSUME_NONNULL_END
