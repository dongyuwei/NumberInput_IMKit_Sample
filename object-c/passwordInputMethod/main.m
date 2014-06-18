#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>
#import "NDTrie.h"

const NSString* kConnectionName = @"Hallelujah_1_Connection";

IMKServer*      server;
IMKCandidates*  sharedCandidates;
NDMutableTrie*  trie;
NSArray*        frequentWords;

NDMutableTrie* buildTrieFromFile(){
    NSString* path = [[NSBundle mainBundle] pathForResource:@"words"
                                                     ofType:@"json"];
    
    NSInputStream *inputStream = [[NSInputStream alloc] initWithFileAtPath: path];
    [inputStream  open];
    NSMutableArray *wordList = [NSJSONSerialization JSONObjectWithStream:inputStream
                                                                 options:nil
                                                                   error:nil];
    [inputStream close];
    
    return [NDMutableTrie trieWithArray: wordList];
}

NSArray* frequentWordList(){
    NSString* path = [[NSBundle mainBundle] pathForResource:@"google-10000-english"
                                                     ofType:@"txt"];
    
    NSString         * str =[NSString stringWithContentsOfFile:path
                                                            encoding:NSUTF8StringEncoding
                                                               error:nil];
    NSArray   * list = [str componentsSeparatedByString:@"\n"];
    return list;
}

int main(int argc, char *argv[])
{
    NSString*       identifier;
    
    identifier = [[NSBundle mainBundle] bundleIdentifier];
    server = [[IMKServer alloc] initWithName:(NSString*)kConnectionName
                            bundleIdentifier:[[NSBundle mainBundle] bundleIdentifier]];
    
    sharedCandidates = [[IMKCandidates alloc] initWithServer:server
                                                   panelType:kIMKSingleColumnScrollingCandidatePanel];
    if (!sharedCandidates){
        NSLog(@"Fatal error: Cannot initialize shared candidate panel with connection %@.", kConnectionName);
        return -1;
    }
    
    trie =  buildTrieFromFile();
    frequentWords = frequentWordList();
    
    [[NSBundle mainBundle] loadNibNamed:@"MainMenu"
                                  owner:[NSApplication sharedApplication]
                        topLevelObjects:nil];
	
	
	[[NSApplication sharedApplication] run];
	
    return 0;
}
