/*
 
 File: MigrationUtilities.m
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Computer, Inc. ("Apple") in consideration of your agreement to the
 following terms, and your use, installation, modification or
 redistribution of this Apple software constitutes acceptance of these
 terms.  If you do not agree with these terms, please do not use,
 install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Computer,
 Inc. may be used to endorse or promote products derived from the Apple
 Software without specific prior written permission from Apple.  Except
 as expressly stated in this notice, no other rights or licenses, express
 or implied, are granted by Apple herein, including but not limited to
 any patent rights that may be infringed by your derivative works or by
 other works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright © 2006 Apple Computer, Inc., All Rights Reserved
 
 */

#import "MigrationUtilities.h"


@implementation MigrationUtilities

+ (NSString *)pathForModelNamed:(NSString *)modelName {
	NSString *path = nil;
    NSArray *allBundles = [NSBundle allBundles];
    NSBundle *currentBundle = nil;
    int i= 0 , bundleCount = [allBundles count];
    
    for( ; i < bundleCount ; i++ ){
        currentBundle = [allBundles objectAtIndex: i];
        path =  [currentBundle pathForResource: @"Migration" ofType: @"momd"];
        
        if (nil != path) {
            break;
        }
    }
    
    if (nil == path) {
        @throw [NSException exceptionWithName: @"MissingResourceException" reason: [NSString stringWithFormat: @"Can't find model %@!", modelName] userInfo: nil];
    }
    
    return [NSString stringWithFormat:@"%@/%@.mom", path, modelName];
}

+ (NSManagedObjectModel *)retainedOldManagedObjectModel {
    return [[NSManagedObjectModel alloc] initWithContentsOfURL: [NSURL fileURLWithPath: [self pathForModelNamed: @"Migration_Old"]]];
}

+ (NSManagedObjectModel *)retainedNewManagedObjectModel {
    return [[NSManagedObjectModel alloc] initWithContentsOfURL: [NSURL fileURLWithPath: [self pathForModelNamed: @"Migration_New"]]];
}

+ (BOOL)createPathIfNecessary:(NSString *)storeDirectory {
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    BOOL success = NO;
    
    
    int i, c;
    NSArray* components = [storeDirectory pathComponents];
    NSString* current = @"";
    c = [components count];  
    for (i = 0; i < c; i++) {
        NSString* index = [components objectAtIndex:i];
        NSString* next = [current stringByAppendingPathComponent:index];
        current = next;
        if (![[NSFileManager defaultManager] fileExistsAtPath: next]) {
            success = [defaultManager createDirectoryAtPath: next attributes: nil];
            if (!success) {
                NSError *error = nil;
                error = [NSError errorWithDomain: @"DataGeneratorErrors" code: 0 userInfo: [NSDictionary dictionaryWithObject: [NSString stringWithFormat: @"Can't create directory at path (%@)", next] forKey: NSLocalizedDescriptionKey]];
                [[NSApplication sharedApplication] presentError:error]; 
                return NO;
            }
        } 
    }
    
    return YES;
}

+ (void)presentErrorWithDescription:(NSString *)errorString {
    static NSString *domainString;
    
    if (nil == domainString) {
        NSArray *identifierComponents = [[[NSBundle mainBundle] bundleIdentifier] componentsSeparatedByString: @"."];
        domainString = [identifierComponents objectAtIndex: [identifierComponents count] - 1];
    }
    NSError *error = [NSError errorWithDomain: domainString code: 0 userInfo: [NSDictionary dictionaryWithObject: errorString forKey: NSLocalizedDescriptionKey]];
    [[NSApplication sharedApplication] presentError:error];
}

+ (BOOL)validatePathForNewStore:(NSString *) storePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *storeDir = [storePath stringByDeletingLastPathComponent];
    BOOL isDirectory = NO;
    
    if (nil == storePath || [@"" isEqualToString: storePath]) {
        [self presentErrorWithDescription: @"New store path must not be null"];
        return NO;
    }
    
    if ([fileManager fileExistsAtPath: storePath isDirectory: &isDirectory]) {
        // if there is a file at storePath, can we write a store to it?
        if (isDirectory) {
            // not if it's a directory
            [self presentErrorWithDescription: [NSString stringWithFormat: @"Can't save store to path - that location is a directory (%@)", storePath]];
            return NO;
        } else {
            if (![fileManager removeFileAtPath: storePath handler: nil]) {
                // Fail if we can't get rid of the old file
                [self presentErrorWithDescription: [NSString stringWithFormat: @"Can't remove pre-existing file at path (%@)", storePath]];      
                return NO;
            }
        }
    } else if ([fileManager fileExistsAtPath: storeDir isDirectory: &isDirectory] ) {
        // if there isn't a file, is there a parent
        if (isDirectory) {
            // if there is is it a directory?
            if (![fileManager isWritableFileAtPath: storeDir]) {
                // can we write into the parent directory?
                [self presentErrorWithDescription: [NSString stringWithFormat: @"Can't write file to path - directory is not writable (%@)", storeDir]];       
                return NO;
            }
        } else {
            // we can't write to the store then, because the parent isn't a directory
            [self presentErrorWithDescription: [NSString stringWithFormat: @"Can't write file to path - parent is not a directory (%@)", storeDir]]; 
            return NO;
        }
    } else {
        // We don't have a directory, so create one - this does its own error message presentation
        return [self createPathIfNecessary: storeDir];
    }
    return YES;
}

@end
