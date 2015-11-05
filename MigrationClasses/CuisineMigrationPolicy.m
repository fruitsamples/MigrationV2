/*
 
 File: CuisineMigrationPolicy.m
 
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

#import "CuisineMigrationPolicy.h"


@implementation CuisineMigrationPolicy

- (NSArray *)destinationInstancesForSourceInstance:(NSManagedObject *)sInstance entityMapping:(NSEntityMapping *)mapping manager:(NSMigrationManager *)manager error:(NSError **)error {
	NSArray *destinations;
	NSString *cuisineName = [sInstance valueForKey: @"cuisine"];
	if (nil != cuisineName) {
		NSMutableDictionary *userInfo = (NSMutableDictionary *)[manager userInfo];
		if (nil == userInfo) {
			userInfo = [[NSMutableDictionary alloc] init];
			[manager setUserInfo: userInfo];
            [userInfo release];
		}
		NSMutableDictionary *cuisines = [userInfo valueForKey: @"cuisines"];
		if (nil == cuisines) {
			cuisines = [[NSMutableDictionary alloc] init];
			[userInfo setValue: cuisines forKey: @"cuisines"];
		}
		NSManagedObject *cuisine = [cuisines valueForKey: cuisineName];
		if (nil == cuisine) {
			destinations = [super destinationInstancesForSourceInstance:sInstance entityMapping: mapping manager: manager error: error];
			cuisine = [destinations objectAtIndex: 0];
			[cuisine setValue: cuisineName forKey: @"name"];
			[cuisines setValue: cuisine forKey: cuisineName];
		} else {
			destinations = [NSArray arrayWithObject: cuisine];
		}
	}
    return destinations;
}

- (BOOL)createRelationshipsForDestinationInstance:(NSManagedObject *)dInstance entityMapping:(NSEntityMapping *)mapping manager:(NSMigrationManager *)manager error:(NSError **)error {
	// Don't do anything; because this is a bidirectional relationship, and we can skip the work
	// If it wasn't a bidirectional relationship, we would need to do the connecting
	// Why is this here? Because the default policy expects one source per destination, in the case of
	// uniqued cuisines there are multiple sources, and the default policy doesn't know what to do.
	return YES;
}
@end
