// 2018 / Tim Clem / github.com/misterfifths
// Public domain.

#import "NativeHostMessage.h"


NS_ASSUME_NONNULL_BEGIN


@interface CloseTabMessage : NativeHostMessage

@property (nonatomic, copy, readonly) NSString *deviceName;
@property (nonatomic, strong, readonly) NSUUID *tabUUID;

-(nullable instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end


NS_ASSUME_NONNULL_END
