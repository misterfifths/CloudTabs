//
//  CloseTabMessage.m
//  CloudTabs
//
//  Created by Timothy Clem on 6/3/18.
//  Copyright © 2018 Misterfifths Heavy Industries. All rights reserved.
//

#import "CloseTabMessage.h"
#import "NativeHostMessageProtected.h"


@interface CloseTabMessage ()

@property (nonatomic, copy, readwrite) NSString *deviceName;
@property (nonatomic, strong, readwrite) NSUUID *tabUUID;

@end


@implementation CloseTabMessage

-(nullable instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super initWithDictionary:dictionary];
    if(self) {
        _deviceName = dictionary[@"deviceName"];
        if(![_deviceName isKindOfClass:[NSString class]]) {
            NSLog(@"Invalid device name: missing or not a string");
            return nil;
        }

        NSString *tabUUIDString = dictionary[@"tabUUID"];
        if(![tabUUIDString isKindOfClass:[NSString class]]) {
            NSLog(@"Invalid tab UUID: missing or not a string");
            return nil;
        }

        _tabUUID = [[NSUUID alloc] initWithUUIDString:tabUUIDString];
        if(!_tabUUID) {
            NSLog(@"Invalid tab UUID: incorrect format");
            return nil;
        }
    }

    return self;
}

@end
