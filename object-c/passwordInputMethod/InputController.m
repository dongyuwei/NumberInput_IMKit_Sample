#import "InputController.h"
#import "NDTrie.h"
#import <CoreServices/CoreServices.h>

extern IMKCandidates *sharedCandidates;
extern NDMutableTrie*  trie;


typedef NSInteger KeyCode;
static const KeyCode
KEY_RETURN = 36,
KEY_DELETE = 51,
KEY_ESC = 53,
KEY_BACKSPACE = 117,
KEY_MOVE_LEFT = 123,
KEY_MOVE_RIGHT = 124,
KEY_MOVE_DOWN = 125;


@implementation InputController{
    NSMutableString* _buffer;
}

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


-(BOOL)inputText:(NSString*)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender{
    //tail -f /var/log/system.log
    NSLog(@"text:%@, keycode:%ld, flags:%lu, bundleIdentifier: %@",
          string, (long)keyCode,(unsigned long)flags, [sender bundleIdentifier]);
    
    [sender insertText:string replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    
    BOOL handled = NO;
    
    if ([self shouldIgnoreKey:keyCode modifiers:flags]){
        [self resetBuffer];
        return NO;
    }
    
    char ch = string.length > 0 ? [string characterAtIndex:0] : 0;
    if(ch >= 'a' && ch <= 'z'){
        [_buffer appendString: string];
        [sharedCandidates updateCandidates];
        [sharedCandidates show:kIMKLocateCandidatesBelowHint];
        handled = YES;
    }else{
        [self resetBuffer];
        [sharedCandidates hide];
        handled = NO;
    }
    
    return handled;
}

//- (void)commitComposition:(id)sender{
//    [self resetBuffer];
//}

-(void)candidateSelected:(NSAttributedString*)candidateString {
    [[self client] insertText:candidateString replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    [sharedCandidates hide];
}

- (void)candidateSelectionChanged:(NSAttributedString *)candidateString{
    NSLog(@"candidateSelectionChanged, %@", candidateString);
    
    NSMutableAttributedString *definition = (NSMutableAttributedString *)DCSCopyTextDefinition(NULL, (__bridge CFStringRef)candidateString, CFRangeMake(0, [candidateString length]));

    
    [sharedCandidates showAnnotation: definition];
    
}

- (void)resetBuffer{
    _buffer = [NSMutableString stringWithString:@""];
}

- (void) activateServer:(id)client{
    NSLog(@"him activateServer");
    [self resetBuffer];
}

-(void)deactivateServer:(id)sender {
    [self resetBuffer];
    
    [sharedCandidates hide];
}

- (BOOL) shouldIgnoreKey:(NSInteger)keyCode modifiers:(NSUInteger)flags{
    return (_buffer == nil || [_buffer length] == 0) && (keyCode == KEY_RETURN || keyCode == KEY_ESC ||
                               keyCode == KEY_DELETE || keyCode == KEY_BACKSPACE ||
                               keyCode == KEY_MOVE_LEFT || keyCode == KEY_MOVE_RIGHT ||
                               keyCode == KEY_MOVE_DOWN ||
                               (flags & NSCommandKeyMask) || (flags & NSControlKeyMask) ||
                               (flags & NSAlternateKeyMask) || (flags & NSNumericPadKeyMask));
}

- (NSArray*)candidates:(id)sender{
    NSLog(@"buffer: %@",_buffer);
    return [trie everyObjectForKeyWithPrefix:[NSString stringWithString: _buffer]];
}

- (void) dealloc{
    [_buffer release];
    [super dealloc];
}

@end

