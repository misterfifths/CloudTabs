// 2018 / Tim Clem / github.com/misterfifths
// Public domain.

#import <Foundation/Foundation.h>
#import "SynchronousNativeHost.h"


NS_ASSUME_NONNULL_BEGIN


@interface NativeHostMessage : NSObject <NativeHostMessageDeserializer>

@property (nonatomic, readonly) NSUInteger messageID;

// Factory for instances of the subclasses; reads the "message" key of the dictionary
// to decide the appropriate class.
+(nullable __kindof instancetype)messageWithDictionary:(NSDictionary *)dictionary;

+(instancetype)new NS_UNAVAILABLE;
-(instancetype)init NS_UNAVAILABLE;

@end


NS_ASSUME_NONNULL_END
