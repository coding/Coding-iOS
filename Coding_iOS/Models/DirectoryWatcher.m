/*
     File: DirectoryWatcher.m 
 Abstract: 
 Object used to monitor the contents of a given directory by using
 "kqueue": a kernel event notification mechanism.
  
  Version: 1.6 
  
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple 
 Inc. ("Apple") in consideration of your agreement to the following 
 terms, and your use, installation, modification or redistribution of 
 this Apple software constitutes acceptance of these terms.  If you do 
 not agree with these terms, please do not use, install, modify or 
 redistribute this Apple software. 
  
 In consideration of your agreement to abide by the following terms, and 
 subject to these terms, Apple grants you a personal, non-exclusive 
 license, under Apple's copyrights in this original Apple software (the 
 "Apple Software"), to use, reproduce, modify and redistribute the Apple 
 Software, with or without modifications, in source and/or binary forms; 
 provided that if you redistribute the Apple Software in its entirety and 
 without modifications, you must retain this notice and the following 
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. may 
 be used to endorse or promote products derived from the Apple Software 
 without specific prior written permission from Apple.  Except as 
 expressly stated in this notice, no other rights or licenses, express or 
 implied, are granted by Apple herein, including but not limited to any 
 patent rights that may be infringed by your derivative works or by other 
 works in which the Apple Software may be incorporated. 
  
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
  
 Copyright (C) 2014 Apple Inc. All Rights Reserved. 
  
 */ 

#import "DirectoryWatcher.h"

#include <sys/types.h>
#include <sys/event.h>
#include <sys/time.h>
#include <fcntl.h>
#include <unistd.h>

#import <CoreFoundation/CoreFoundation.h>

@interface DirectoryWatcher (DirectoryWatcherPrivate)
- (BOOL)startMonitoringDirectory:(NSString *)dirPath;
- (void)kqueueFired;
@end


#pragma mark -

@implementation DirectoryWatcher

@synthesize delegate;

- (instancetype)init
{
	self = [super init];
	delegate = NULL;

	dirFD = -1;
    kq = -1;
	dirKQRef = NULL;
	
	return self;
}

- (void)dealloc
{
	[self invalidate];
}

+ (DirectoryWatcher *)watchFolderWithPath:(NSString *)watchPath delegate:(id)watchDelegate
{
	DirectoryWatcher *retVal = NULL;
	if ((watchDelegate != NULL) && (watchPath != NULL))
	{
		DirectoryWatcher *tempManager = [[DirectoryWatcher alloc] init];
		tempManager.delegate = watchDelegate;		
		if ([tempManager startMonitoringDirectory: watchPath])
		{
			// Everything appears to be in order, so return the DirectoryWatcher.  
			// Otherwise we'll fall through and return NULL.
			retVal = tempManager;
		}
	}
	return retVal;
}

- (void)invalidate
{
	if (dirKQRef != NULL)
	{
		CFFileDescriptorInvalidate(dirKQRef);
		CFRelease(dirKQRef);
		dirKQRef = NULL;
		// We don't need to close the kq, CFFileDescriptorInvalidate closed it instead.
		// Change the value so no one thinks it's still live.
		kq = -1;
	}
	
	if(dirFD != -1)
	{
		close(dirFD);
		dirFD = -1;
	}
}

@end


#pragma mark -

@implementation DirectoryWatcher (DirectoryWatcherPrivate)

- (void)kqueueFired
{
    assert(kq >= 0);

    struct kevent   event;
    struct timespec timeout = {0, 0};
    int             eventCount;
	
    eventCount = kevent(kq, NULL, 0, &event, 1, &timeout);
    assert((eventCount >= 0) && (eventCount < 2));
    
	// call our delegate of the directory change
    [delegate directoryDidChange:self];

    CFFileDescriptorEnableCallBacks(dirKQRef, kCFFileDescriptorReadCallBack);
}

static void KQCallback(CFFileDescriptorRef kqRef, CFOptionFlags callBackTypes, void *info)
{
    DirectoryWatcher *obj;
	
    obj = (__bridge DirectoryWatcher *)info;
    assert([obj isKindOfClass:[DirectoryWatcher class]]);
    assert(kqRef == obj->dirKQRef);
    assert(callBackTypes == kCFFileDescriptorReadCallBack);
	
    [obj kqueueFired];
}

- (BOOL)startMonitoringDirectory:(NSString *)dirPath
{
	// Double initializing is not going to work...
	if ((dirKQRef == NULL) && (dirFD == -1) && (kq == -1))
	{
		// Open the directory we're going to watch
		dirFD = open([dirPath fileSystemRepresentation], O_EVTONLY);
		if (dirFD >= 0)
		{
			// Create a kqueue for our event messages...
			kq = kqueue();
			if (kq >= 0)
			{
				struct kevent eventToAdd;
				eventToAdd.ident  = dirFD;
				eventToAdd.filter = EVFILT_VNODE;
				eventToAdd.flags  = EV_ADD | EV_CLEAR;
				eventToAdd.fflags = NOTE_WRITE;
				eventToAdd.data   = 0;
				eventToAdd.udata  = NULL;
				
				int errNum = kevent(kq, &eventToAdd, 1, NULL, 0, NULL);
				if (errNum == 0)
				{
					CFFileDescriptorContext context = { 0, (__bridge void *)(self), NULL, NULL, NULL };
					CFRunLoopSourceRef      rls;

					// Passing true in the third argument so CFFileDescriptorInvalidate will close kq.
					dirKQRef = CFFileDescriptorCreate(NULL, kq, true, KQCallback, &context);
					if (dirKQRef != NULL)
					{
						rls = CFFileDescriptorCreateRunLoopSource(NULL, dirKQRef, 0);
						if (rls != NULL)
						{
							CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, kCFRunLoopDefaultMode);
							CFRelease(rls);
							CFFileDescriptorEnableCallBacks(dirKQRef, kCFFileDescriptorReadCallBack);
							
							// If everything worked, return early and bypass shutting things down
							return YES;
						}
						// Couldn't create a runloop source, invalidate and release the CFFileDescriptorRef
						CFFileDescriptorInvalidate(dirKQRef);
                        CFRelease(dirKQRef);
						dirKQRef = NULL;
					}
				}
				// kq is active, but something failed, close the handle...
				close(kq);
				kq = -1;
			}
			// file handle is open, but something failed, close the handle...
			close(dirFD);
			dirFD = -1;
		}
	}
	return NO;
}

@end
