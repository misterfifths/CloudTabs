// 2018 / Tim Clem / github.com/misterfifths
// Public domain.

#import <Foundation/Foundation.h>

@protocol SynchronousNativeHostDelegate;
@protocol NativeHostMessageDeserializer;


NS_ASSUME_NONNULL_BEGIN

/*
 Naive implementation of a host for https://developer.chrome.com/extensions/nativeMessaging

 This class is strictly synchronous, one-response-per-request. This is the loop:
 1. Read and deserialize incoming JSON from stdin
 2. If messageDeserializer is not nil, pass it the JSON for deserialization.
 3. Pass the message (or the raw JSON, if no messageDeserializer) to the delegate.
 4. Serialize the delegate's response and write it to stdout.
 5. GOTO 1

 On any sort of error, or when the client closes stdin, it bails on its read loop and
 calls the corresponding delegate method.

 All the reading/writing/delegate-informing happens on a background queue; -startReadLoop
 returns immediately.
 */
@interface SynchronousNativeHost : NSObject

@property (nullable, nonatomic, strong) Class<NativeHostMessageDeserializer> messageDeserializer;
@property (nonatomic, weak) id<SynchronousNativeHostDelegate> delegate;

-(void)startReadLoop;

-(instancetype)initWithDelegate:(id<SynchronousNativeHostDelegate>)delegate;


-(instancetype)init NS_UNAVAILABLE;
+(instancetype)new NS_UNAVAILABLE;

@end


@protocol NativeHostMessageDeserializer

/*
 Turn the JSON object into a real message instance. Return nil in case of error.
 If you return nil, the SynchronousNativeHost will exit its read loop.
 */
@required
+(nullable id)nativeHostMessageFromJSONObject:(id)jsonObject;

@end


@protocol SynchronousNativeHostDelegate <NSObject>

@required

/*
 A message was received. Return the response (must be JSON-serializable via NSJSONSerialization),
 or nil in case of an error. If you return nil, the SynchronousNativeHost will exit its read loop.
 Called on a private background queue.
 */
-(nullable id)nativeHost:(SynchronousNativeHost *)host willSendResponseToMessage:(id)message;

/*
 Informs you that the native host is done, for whatever reason. It's probably reasonable to
 terminate the NSApplication at this point.
 Called on the main thread.
 */
-(void)nativeHostDidExitReadLoop:(SynchronousNativeHost *)host;

@end


NS_ASSUME_NONNULL_END
