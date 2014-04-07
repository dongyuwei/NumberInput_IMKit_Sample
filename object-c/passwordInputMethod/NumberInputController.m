
#import "NumberInputController.h"


@implementation NumberInputController

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

//dyw have tested `handleEvent` and `inputText` methods as below, they works as expected.

//-(BOOL)handleEvent:(NSEvent*)event client:(id)sender
//{
////    NSInteger keyCode = [event keyCode];
////    unsigned char keyChar = [string UTF8String][0];
//
//    NSString* string = [event characters];
//    
//    NSLog(@"you input string is: %@ ==========>", string);//tail -f /var/log/system.log
//    //see https://github.com/sunpinyin/sunpinyin/blob/master/wrapper/macos/SunPinyinInputController.mm
//    [sender insertText:[NSString stringWithFormat:@"_%@_", string]
//      replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
//    return YES;
//}

-(BOOL)inputText:(NSString*)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender
{
    NSLog(@"you input string is: %@ ==========>", string);//tail -f /var/log/system.log
    NSLog(@"you input key is: %ld ==========>", keyCode);
    NSLog(@"you input flags is: %ld ==========>", flags);
    [sender insertText:[NSString stringWithFormat:@"__%@__", string]
      replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    NSLog(@"sender class: %@", NSStringFromClass([sender class]));
//    IPMDServerClientWrapper
    return YES;
}


@end

