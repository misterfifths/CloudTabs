// 2018 / Tim Clem / github.com/misterfifths
// Public domain.

#import "NativeHostMessage.h"


NS_ASSUME_NONNULL_BEGIN


@interface GetTabsMessage : NativeHostMessage

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end


NS_ASSUME_NONNULL_END
