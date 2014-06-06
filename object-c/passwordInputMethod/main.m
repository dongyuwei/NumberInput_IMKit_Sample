#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>


const NSString* kConnectionName = @"Hallelujah_1_Connection";

//let this be a global so our application controller delegate can access it easily
IMKServer*       server;
IMKCandidates* candidates;

int main(int argc, char *argv[])
{
    
    NSString*       identifier;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	//find the bundle identifier and then initialize the input method server
    identifier = [[NSBundle mainBundle] bundleIdentifier];
    server = [[IMKServer alloc] initWithName:(NSString*)kConnectionName bundleIdentifier:[[NSBundle mainBundle] bundleIdentifier]];
    
    candidates = [[IMKCandidates alloc] initWithServer:server panelType:kIMKSingleColumnScrollingCandidatePanel];
	
    //load the bundle explicitly because in this case the input method is a background only application 
//	[NSBundle loadNibNamed:@"MainMenu" owner:[NSApplication sharedApplication]];
    
    [[NSBundle mainBundle] loadNibNamed:@"MainMenu"
                                  owner:[NSApplication sharedApplication]
                        topLevelObjects:nil];
	
	//finally run everything
	[[NSApplication sharedApplication] run];
	
    [pool release];
    return 0;
}
