// 2018 / Tim Clem / github.com/misterfifths
// Public domain.

#import "NativeHostMessageProtected.h"
#import "NativeHostMessages.h"
#import "SynchronousNativeHost.h"


@interface NativeHostMessage ()

@property (nonatomic, readwrite) NSUInteger messageID;

@end


@implementation NativeHostMessage

+(nullable instancetype)messageWithDictionary:(NSDictionary *)dictionary
{
    static NSDictionary *classMap;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        classMap = @{ @"getTabs": [GetTabsMessage class],
                      @"closeTab": [CloseTabMessage class],
                      @"closeAllTabs": [CloseAllTabsMessage class] };
    });

    NSString *messageType = dictionary[@"message"];
    Class cls = classMap[messageType];

    return [[cls alloc] initWithDictionary:dictionary];
}

+(id)nativeHostMessageFromJSONObject:(id)jsonObject
{
    if(![jsonObject isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Invalid JSON; expected a dictionary. Bailing.");
        return nil;
    }

    NativeHostMessage *message = [self messageWithDictionary:jsonObject];
    if(!message) {
        NSLog(@"Invalid message JSON! Bailing.");
        return nil;
    }

    return message;
}

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if(self) {
        NSNumber *idNumber = dictionary[@"id"];
        if(![idNumber isKindOfClass:[NSNumber class]]) {
            NSLog(@"Message missing ID. Bailing.");
            return nil;
        }

        _messageID = [idNumber unsignedIntegerValue];
    }
    return self;
}

@end

