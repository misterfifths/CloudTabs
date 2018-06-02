// 2018 / Tim Clem / github.com/misterfifths
// Public domain.

#import "WebLocWriter.h"

@implementation WebLocWriter

+(NSString *)fileNameForTitle:(NSString *)title
{
    const NSUInteger maxLength = 64;

    title = [title stringByReplacingOccurrencesOfString:@":" withString:@"-"];
    title = [title stringByReplacingOccurrencesOfString:@"/" withString:@"-"];

    if(title.length > maxLength) {
        title = [title substringToIndex:maxLength];
    }

    return [title stringByAppendingPathExtension:@"webloc"];
}

+(BOOL)writePlistObject:(id)plistObj toFile:(NSURL *)fileURL error:(NSError **)error
{
    NSOutputStream *outputStream = [NSOutputStream outputStreamWithURL:fileURL append:NO];
    [outputStream open];

    BOOL success = [NSPropertyListSerialization writePropertyList:plistObj
                                                         toStream:outputStream
                                                           format:NSPropertyListXMLFormat_v1_0
                                                          options:0
                                                            error:error];

    [outputStream close];

    return success;
}

+(BOOL)writeWebLocForURL:(NSURL *)webURL
                   title:(NSString *)title
             toDirectory:(NSURL *)directoryURL
                   error:(NSError **)error
{
    NSString *titleToUse = title.length > 0 ? title : webURL.absoluteString;
    NSString *filename = [self fileNameForTitle:titleToUse];
    NSURL *fileURL = [directoryURL URLByAppendingPathComponent:filename isDirectory:NO];

    NSDictionary *documentDict = @{ @"URL": webURL.absoluteString };
    return [self writePlistObject:documentDict toFile:fileURL error:error];
}

@end
