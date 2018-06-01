// 2018 / Tim Clem / github.com/misterfifths
// Public domain.

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN


// Technically some of these properties are writable, but let's save that for another day, shall we?

@interface WBSCloudTab : NSObject <NSCopying>

@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) NSUUID *uuid;

@property (getter=isPinned, nonatomic, readonly) BOOL pinned;

@property (nonatomic, readonly) BOOL isShowingReader;
@property (nullable, nonatomic, copy, readonly) NSDictionary *readerScrollPositionDictionary;

@property (nonatomic, readonly) NSDictionary *dictionaryRepresentation;
@property (nonatomic, readonly) NSDictionary *dictionaryRepresentationForUserActivityUserInfo;

@end


NS_ASSUME_NONNULL_END
