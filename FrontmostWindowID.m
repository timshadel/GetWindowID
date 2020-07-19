#include <Cocoa/Cocoa.h>
#include <CoreGraphics/CGWindow.h>

NSArray<NSDictionary *> * filterWindows(NSArray<NSDictionary *> *, pid_t);

int main(int argc, char **argv)
{
    NSRunningApplication *mainApp = nil;
    for (NSRunningApplication *app in [[NSWorkspace sharedWorkspace] runningApplications]) {
        if (app.isActive) {
            mainApp = app;
        }
    }

    int windowsAboveCount = 1000;
    NSDictionary *topWindow;
	NSArray *windows = (NSArray *)CGWindowListCopyWindowInfo(kCGWindowListExcludeDesktopElements,kCGNullWindowID);
    for (NSDictionary *window in filterWindows(windows, mainApp.processIdentifier)) {
		NSNumber *windowId = window[(NSString *)kCGWindowNumber];
        NSArray *windowsAbove = (NSArray *)CGWindowListCopyWindowInfo(kCGWindowListExcludeDesktopElements | kCGWindowListOptionOnScreenAboveWindow, windowId.intValue);
        NSArray *appWindowsAbove = filterWindows(windowsAbove, mainApp.processIdentifier);
        if (appWindowsAbove.count < windowsAboveCount) {
            windowsAboveCount = appWindowsAbove.count;
            topWindow = window;
        }
    }
    NSNumber *windowId = topWindow[(NSString *)kCGWindowNumber];
    NSString *windowTitle = topWindow[(NSString *)kCGWindowName];
    printf("%d", windowId.intValue);
}

NSArray<NSDictionary *> * filterWindows(NSArray<NSDictionary *> *windows, pid_t pid) {
    NSMutableArray<NSDictionary *> *result = [NSMutableArray new];
	for(NSDictionary *window in windows) {
        NSNumber *windowPID = window[(NSString *)kCGWindowOwnerPID];
        if (windowPID.intValue != pid) {
            continue;
        }
		CGRect currentBounds;
		CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)window[(NSString *)kCGWindowBounds], &currentBounds);
        if (currentBounds.size.height <= 30.0) {
            continue;
        }
        [result addObject:window];
    }
    return result;
}
