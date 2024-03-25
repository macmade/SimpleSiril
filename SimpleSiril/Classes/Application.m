/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2023, Jean-David Gadina - www.xs-labs.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the Software), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ******************************************************************************/

#import "Application.h"

@import CoreServices;

@interface Application()

@property( atomic, readwrite, strong ) NSURL    * url;
@property( atomic, readwrite, strong ) NSString * name;
@property( atomic, readwrite, strong ) NSString * bundleID;
@property( atomic, readwrite, strong ) NSString * bundleVersion;
@property( atomic, readwrite, strong ) NSString * version;

@end

@implementation Application

+ ( NSArray< Application * > * )applicationsForBundleID: ( NSString * )bundleID
{
    CFErrorRef           error = nil;
    NSArray< NSURL * > * urls  = CFBridgingRelease( LSCopyApplicationURLsForBundleIdentifier( ( __bridge CFStringRef )( bundleID ), &error ) );

    if( urls == nil || error != nil )
    {
        return @[];
    }

    NSMutableArray< Application * > * applications = [ NSMutableArray new ];

    for( NSURL * url in urls )
    {
        Application * application = [ [ Application alloc ] initWithURL: url ];

        if( application != nil )
        {
            [ applications addObject: application ];
        }
    }

    return [ applications copy ];
}

- ( nullable instancetype )initWithURL: ( NSURL * )url
{
    BOOL       isDir  = NO;
    NSString * path   = url.path;
    NSString * plist  = [ url.path stringByAppendingPathComponent: @"Contents/Info.plist" ];

    if
    (
           path == nil
        || [ [ NSFileManager defaultManager ] fileExistsAtPath: path isDirectory: &isDir ] == NO
        || isDir == NO
        || [ [ NSFileManager defaultManager ] fileExistsAtPath: plist ] == NO
    )
    {
        return nil;
    }

    NSDictionary< NSString *, id > * info = [ NSDictionary dictionaryWithContentsOfFile: plist ];

    if( info == nil || info.count == 0 )
    {
        return nil;
    }

    NSString * bundleID      = [ info objectForKey: @"CFBundleIdentifier" ];
    NSString * bundleVersion = [ info objectForKey: @"CFBundleVersion" ];
    NSString * version       = [ info objectForKey: @"CFBundleShortVersionString" ];

    if( bundleID.length == 0 || version.length == 0 || bundleVersion.length == 0 )
    {
        return nil;
    }

    if( ( self = [ super init ] ) )
    {
        self.url           = url;
        self.name          = [ [ NSFileManager defaultManager ] displayNameAtPath: path ];
        self.bundleID      = bundleID;
        self.bundleVersion = bundleVersion;
        self.version       = version;
    }

    return self;
}

@end
