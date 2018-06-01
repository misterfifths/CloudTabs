// 2018 / Tim Clem / github.com/misterfifths
// Public domain.

#import <Foundation/Foundation.h>

@class WBSCloudTab;


NS_ASSUME_NONNULL_BEGIN


@interface WBSCloudTabDevice : NSObject <NSCopying>

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *uuid;

@property (getter=isCloseRequestSupported, nonatomic, readonly) BOOL closeRequestSupported;

@property (nonatomic, copy, readonly) NSArray<WBSCloudTab *> *tabs;
@property (nonatomic, readonly) NSDate *lastModified;

@property (nonatomic, readonly) NSDictionary *dictionaryRepresentation;

@end


NS_ASSUME_NONNULL_END
