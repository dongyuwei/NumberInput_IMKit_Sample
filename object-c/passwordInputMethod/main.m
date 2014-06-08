#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>
#import "NDTrie.h"

const NSString* kConnectionName = @"Hallelujah_1_Connection";

IMKServer*      server;
IMKCandidates*  sharedCandidates;
NDMutableTrie*  trie;

int main(int argc, char *argv[])
{
    
    NSString*       identifier;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
    identifier = [[NSBundle mainBundle] bundleIdentifier];
    server = [[IMKServer alloc] initWithName:(NSString*)kConnectionName
                            bundleIdentifier:[[NSBundle mainBundle] bundleIdentifier]];
    
    sharedCandidates = [[IMKCandidates alloc] initWithServer:server
                                                   panelType:kIMKSingleColumnScrollingCandidatePanel];
    if (!sharedCandidates){
        NSLog(@"Fatal error: Cannot initialize shared candidate panel with connection %@.", kConnectionName);
        [server release];
        [pool drain];
        return -1;
    }
    
    NSInputStream *inputStream = [[NSInputStream alloc] initWithFileAtPath:@"/tmp/dict.json"];
    [inputStream open];
    NSArray *wordList = [NSJSONSerialization JSONObjectWithStream:inputStream
                                                          options:nil
                                                            error:nil];
    [inputStream close];
    
    trie =  [NDMutableTrie trieWithArray: wordList];
	
    
    [[NSBundle mainBundle] loadNibNamed:@"MainMenu"
                                  owner:[NSApplication sharedApplication]
                        topLevelObjects:nil];
	
	
	[[NSApplication sharedApplication] run];
	
    [pool release];
    return 0;
}
