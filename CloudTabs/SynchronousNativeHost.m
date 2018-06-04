// 2018 / Tim Clem / github.com/misterfifths
// Public domain.

#import "SynchronousNativeHost.h"


typedef uint32_t NativeHostMessageByteLengthType;


@interface SynchronousNativeHost () {
    dispatch_queue_t _backgroundQueue;
}

@end


@implementation SynchronousNativeHost

-(instancetype)initWithDelegate:(id<SynchronousNativeHostDelegate>)delegate
{
    self = [super init];
    if(self) {
        NSString *queueName = [NSString stringWithFormat:@"sychronous-native-host.background-queue.%p", (void *)self];
        _backgroundQueue = dispatch_queue_create(queueName.UTF8String, DISPATCH_QUEUE_SERIAL);

        _delegate = delegate;
    }

    return self;
}

-(void)startReadLoop
{
    dispatch_async(_backgroundQueue, ^{
        [self readLoop];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate nativeHostDidExitReadLoop:self];
        });
    });
}

-(nullable id)readJSONObjectFromHandle:(NSFileHandle *)handle
{
    const NSUInteger headerByteLength = sizeof(NativeHostMessageByteLengthType);
    const NSUInteger maxByteLength = 1024 * 1024;  // quoth the docs

    NSData *lengthData = [handle readDataOfLength:headerByteLength];
    if(lengthData.length != headerByteLength) {
        NSLog(@"Read a header fewer than %lu bytes; bailing", headerByteLength);
        return nil;
    }

    NativeHostMessageByteLengthType jsonDataLength;
    // The docs say the header is in native byte-order, so this should be safe:
    [lengthData getBytes:&jsonDataLength length:headerByteLength];

    if(jsonDataLength > maxByteLength) {
        NSLog(@"Incoming message is %u bytes; %lu is the max. Bailing.", jsonDataLength, maxByteLength);
        return nil;
    }

    NSData *jsonData = [handle readDataOfLength:jsonDataLength];
    if(jsonData.length != jsonDataLength) {
        NSLog(@"Read a body of %lu bytes; expected %u. Bailing.", jsonData.length, jsonDataLength);
        return nil;
    }

    NSError *jsonError = nil;
    id json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];

    if(!json) {
        NSLog(@"Read %@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
        NSLog(@"Invalid JSON: %@. Bailing.", jsonError);
        return nil;
    }

    return json;
}

-(BOOL)writeJSONObject:(id)json toHandle:(NSFileHandle *)handle
{
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:&jsonError];

    if(!jsonData) {
        NSLog(@"Couldn't serialize response: %@. Bailing.", jsonError);
        return NO;
    }

    NativeHostMessageByteLengthType jsonLength = (NativeHostMessageByteLengthType)jsonData.length;
    // Again, docs say native byte-order, so...
    NSData *lengthData = [NSData dataWithBytes:&jsonLength length:sizeof(NativeHostMessageByteLengthType)];

    [handle writeData:lengthData];
    [handle writeData:jsonData];

    return YES;
}

-(void)readLoop
{
    NSFileHandle *stdinHandle = [NSFileHandle fileHandleWithStandardInput];
    NSFileHandle *stdoutHandle = [NSFileHandle fileHandleWithStandardOutput];

    do {
        @autoreleasepool {
            id jsonObject = [self readJSONObjectFromHandle:stdinHandle];
            if(!jsonObject) break;

            id message = jsonObject;
            if(self.messageDeserializer) {
                message = [self.messageDeserializer.class nativeHostMessageFromJSONObject:jsonObject];
                if(!message) break;
            }

            id response = [self.delegate nativeHost:self willSendResponseToMessage:message];
            if(!response) break;

            if(![self writeJSONObject:response toHandle:stdoutHandle]) break;
        }
    } while(YES);
}

@end
