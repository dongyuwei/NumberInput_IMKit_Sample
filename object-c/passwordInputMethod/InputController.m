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


-(BOOL)inputText:(NSString*)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender{
    //tail -f /var/log/system.log
    NSLog(@"text:%@, keycode:%ld, flags:%lu, bundleIdentifier: %@",
          string, (long)keyCode,(unsigned long)flags, [sender bundleIdentifier]);
    
    _currentClient = sender;
    
    BOOL handled = NO;
    
    if ([self shouldIgnoreKey:keyCode modifiers:flags]){
        [self reset];
        return NO;
    }
    
    char ch = [string characterAtIndex:0];
    NSLog(@"char: %c",ch);
    if(ch >= 'a' && ch <= 'z'){
        [self originalBufferAppend:string client:sender];

        [sharedCandidates updateCandidates];
        [sharedCandidates show:kIMKLocateCandidatesBelowHint];
        handled = YES;
    }else{
        [sharedCandidates hide];
        handled = NO;
    }
    
    return handled;
}

-(void)commitComposition:(id)sender
{
    NSString*		text = [self composedBuffer];
    
    if ( text == nil || [text length] == 0 ) {
        text = [self originalBuffer];
    }
    
    NSLog(@"commitComposition: %@",text);
    
    [sender insertText:[text stringByAppendingString:@" "] replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    
    [self reset];
}

-(void)reset{
    [self setComposedBuffer:@""];
    [self setOriginalBuffer:@""];
    
    [sharedCandidates hide];
    
    _insertionIndex = 0;
    _didConvert = NO;
}

// Return the composed buffer.  If it is NIL create it.
-(NSMutableString*)composedBuffer;
{
    if ( _composedBuffer == nil ) {
        _composedBuffer = [[NSMutableString alloc] init];
    }
    return _composedBuffer;
}

// Change the composed buffer.
-(void)setComposedBuffer:(NSString*)string
{
    NSMutableString*		buffer = [self composedBuffer];
    [buffer setString:string];
}


// Get the original buffer.
-(NSMutableString*)originalBuffer
{
    if ( _originalBuffer == nil ) {
        _originalBuffer = [[NSMutableString alloc] init];
    }
    return _originalBuffer;
}

// Add newly input text to the original buffer.
-(void)originalBufferAppend:(NSString*)string client:(id)sender
{
    NSMutableString*		buffer = [self originalBuffer];
    [buffer appendString: string];
    _insertionIndex++;
    [sender setMarkedText:buffer selectionRange:NSMakeRange(0, [buffer length]) replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
}

// Change the original buffer.
-(void)setOriginalBuffer:(NSString*)string
{
    NSMutableString*		buffer = [self originalBuffer];
    [buffer setString:string];
}

- (void) activateServer:(id)client{
    NSLog(@"him activateServer");
}

-(void)deactivateServer:(id)sender {
    [sharedCandidates hide];
}

// This method is called to see if your input method handles an NSResponder action.
-(BOOL)didCommandBySelector:(SEL)aSelector client:(id)sender
{
    if ([self respondsToSelector:aSelector]) {
        // The NSResponder methods like insertNewline: or deleteBackward: are
        // methods that return void. didCommandBySelector method requires
        // that you return YES if the command is handled and NO if you do not.
        // This is necessary so that unhandled commands can be passed on to the
        // client application. For that reason we need to test in the case where
        // we might not handle the command.
        
        // The test here is simple.  Test to see if any text has been aded to the original buffer.
        NSString*		bufferedText = [self originalBuffer];
        
        if ( bufferedText && [bufferedText length] > 0 ) {
            if (aSelector == @selector(insertNewline:) ||
                aSelector == @selector(deleteBackward:) ) {
                [self performSelector:aSelector withObject:sender];
                return YES;
            }
        }
        
    }
    
    return NO;
}

// When a new line is input we commit the composition.
- (void)insertNewline:(id)sender
{
    [self commitComposition:sender];
    
}

// If backspace is entered remove the preceding character and update the marked text.
- (void)deleteBackward:(id)sender
{
    NSMutableString*		originalText = [self originalBuffer];
    NSString*				convertedString;
    
    if ( _insertionIndex > 0 && _insertionIndex <= [originalText length] ) {
        --_insertionIndex;
        [originalText deleteCharactersInRange:NSMakeRange(_insertionIndex,1)];
        convertedString = [originalText substringWithRange:NSMakeRange(0, originalText.length - 1)];
        NSLog(@" deleteBackward convertedString: %@",convertedString);
        [self setComposedBuffer:convertedString];
        [sender setMarkedText:convertedString selectionRange:NSMakeRange(_insertionIndex, 0) replacementRange:NSMakeRange(NSNotFound,NSNotFound)];
        
        if(convertedString && convertedString.length > 3){
            [sharedCandidates updateCandidates];
            [sharedCandidates show:kIMKLocateCandidatesBelowHint];
        }
    }
}

- (BOOL) shouldIgnoreKey:(NSInteger)keyCode modifiers:(NSUInteger)flags{
    return (keyCode == KEY_ESC
            || keyCode == KEY_MOVE_LEFT
            || keyCode == KEY_MOVE_RIGHT
            || keyCode == KEY_MOVE_DOWN
            || (flags & NSCommandKeyMask)
            || (flags & NSControlKeyMask)
            || (flags & NSAlternateKeyMask)
            || (flags & NSNumericPadKeyMask));
}

- (NSArray*)candidates:(id)sender{
    NSMutableString* buffer = [self originalBuffer];
    NSLog(@"buffer: %@",buffer);
    if(buffer != nil && buffer.length >= 3){
        return [trie everyObjectForKeyWithPrefix:[NSString stringWithString: buffer]];
    }else{
        return @[];
    }
}

- (void)candidateSelectionChanged:(NSAttributedString*)candidateString{
    NSLog(@"candidateSelectionChanged, %@", candidateString);
    [_currentClient setMarkedText:[candidateString string] selectionRange:NSMakeRange(_insertionIndex, 0) replacementRange:NSMakeRange(NSNotFound,NSNotFound)];
    _insertionIndex = [candidateString length];
    
//    if(candidateString != nil && candidateString.length >= 3){
//        @try {
//            NSAttributedString *definition = (NSAttributedString *)DCSCopyTextDefinition(NULL, (__bridge CFStringRef)[candidateString string], CFRangeMake(0, [[candidateString string] length]));
//            
//            NSLog(@"definition of %@ is %@",[candidateString string], definition);
//            
//            if(definition && definition.length > 0){
//                [sharedCandidates showAnnotation: [definition substringWithRange:NSMakeRange(0, 20)]];
//            }else{
//                [sharedCandidates showAnnotation: candidateString];
//            }
//            
//        }
//        @catch (NSException *exception) {
//            NSLog(@"%@", exception.reason);
//        }
//    }
}

/*!
 @method
 @abstract   Called when a new candidate has been finally selected.
 @discussion The candidate parameter is the users final choice from the candidate window. The candidate window will have been closed before this method is called.
 */
- (void)candidateSelected:(NSAttributedString*)candidateString
{
    [self setComposedBuffer:[candidateString string]];
    [self commitComposition:_currentClient];
    
    NSLog(@"candidateSelected, %@", candidateString);
}

- (NSArray*) getGoogleSuggestion: (NSString*)word{
    NSString* query = [NSString stringWithFormat: @"http://google.com/complete/search?output=firefox&hl=en&q=%@", word];
    NSURL * url = [[NSURL alloc] initWithString: query];

    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url
                                                cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                            timeoutInterval:30];
    
    NSURLResponse *response;
    NSError *error;
    
    NSData* data = [NSURLConnection sendSynchronousRequest:urlRequest
                                         returningResponse:&response
                                                     error:&error];
    
    
    NSArray* result = @[];
    NSArray* object = [NSJSONSerialization
                       JSONObjectWithData:data
                       options:0
                       error:&error];
    
    if(!error){
        result = object[1];
    }else{
        NSLog(@"getGoogleSuggestion Error: %@",error);
    }
    
    return result;
}

-(void)dealloc
{
    [_composedBuffer release];
    [_originalBuffer release];
    [super dealloc];
}

@end

