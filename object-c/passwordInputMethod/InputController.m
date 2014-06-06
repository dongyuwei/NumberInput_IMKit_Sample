#import "InputController.h"


@implementation InputController

/*
Implement one of the three ways to receive input from the client. 
Here are the three approaches:
                 
                 1.  Support keybinding.  
                        In this approach the system takes each keydown and trys to map the keydown to an action method that the input method has implemented.  If an action is found the system calls didCommandBySelector:client:.  If no action method is found inputText:client: is called.  An input method choosing this approach should implement
                        -(BOOL)inputText:(NSString*)string client:(id)sender;
                        -(BOOL)didCommandBySelector:(SEL)aSelector client:(id)sender;
                        
                2. Receive all key events without the keybinding, but do "unpack" the relevant text data.
                        Key events are broken down into the Unicodes, the key code that generated them, and modifier flags.  This data is then sent to the input method's inputText:key:modifiers:client: method.  For this approach implement:
                        -(BOOL)inputText:(NSString*)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender;
                        
                3. Receive events directly from the Text Services Manager as NSEvent objects.  For this approach implement:
                        -(BOOL)handleEvent:(NSEvent*)event client:(id)sender;
*/


-(BOOL)inputText:(NSString*)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender
{
    //tail -f /var/log/system.log
    NSLog(@"text:%@, keycode:%ld, flags:%lu",string, (long)keyCode,(unsigned long)flags);
    NSLog(@"bundleIdentifier: %@", [sender bundleIdentifier]);
    
    extern IMKCandidates*		candidates;
    if ( candidates ) {
        [candidates updateCandidates];
        [candidates show:kIMKLocateCandidatesBelowHint];
    }
//    [sender insertText:string replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    
    
    return YES;
}

//- (id)initWithServer:(IMKServer*)server delegate:(id)delegate client:(id)inputClient{
//    
//}

- (NSArray*)candidates:(id)sender{
    NSMutableArray* list = @[@"test",@"foo",@"bar"];
    return list;
}
@end

