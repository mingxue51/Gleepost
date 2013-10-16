//
//  NewMessageViewController.m
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import "NewMessageViewController.h"
#import "SessionManager.h"
#import "MBProgressHUD.h"
#import "WebClient.h"
#import "UIPlaceHolderTextView.h"


@interface NewMessageViewController ()

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UIView *titleLimitView;

@property (strong, nonatomic) NSMutableArray *usersNames;
@property (strong, nonatomic) TITokenFieldView *tokenFieldView;
@property (strong, nonatomic) UIPlaceHolderTextView *messageView;
@property (assign, nonatomic) CGFloat keyboardHeight;



- (IBAction)cancelButtonClick:(id)sender;
- (IBAction)sendButtonClick:(id)sender;

@end

@implementation NewMessageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_bar.png"] forBarMetrics:UIBarMetricsDefault];
    [self setBackgroundToNavigationBar];
    
    
    //TODO: Problem here.
    self.usersNames = [NSArray arrayWithObjects:@"Lukas", @"Patrick", @"Tade", @"Tosh", nil];

    float aboveHeight = self.titleLimitView.frame.origin.y + 1;
    self.tokenFieldView = [[TITokenFieldView alloc] initWithFrame:CGRectMake(0, aboveHeight, self.view.bounds.size.width, self.view.bounds.size.height - aboveHeight)];
	[self.tokenFieldView setSourceArray:self.usersNames];
	[self.view addSubview:self.tokenFieldView];
	
	[self.tokenFieldView.tokenField setDelegate:self];
	[self.tokenFieldView.tokenField addTarget:self action:@selector(tokenFieldFrameDidChange:) forControlEvents:TITokenFieldControlEventFrameDidChange];
	[self.tokenFieldView.tokenField setTokenizingCharacters:[NSCharacterSet characterSetWithCharactersInString:@",;."]]; // Default is a comma
    [self.tokenFieldView.tokenField setPromptText:@"To:"];
	[self.tokenFieldView.tokenField setPlaceholder:@"Type a name"];
	
//	UIButton * addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
//	[addButton addTarget:self action:@selector(showContactsPicker:) forControlEvents:UIControlEventTouchUpInside];
//	[self.tokenFieldView.tokenField setRightView:addButton];
//	[self.tokenFieldView.tokenField addTarget:self action:@selector(tokenFieldChangedEditing:) forControlEvents:UIControlEventEditingDidBegin];
//	[self.tokenFieldView.tokenField addTarget:self action:@selector(tokenFieldChangedEditing:) forControlEvents:UIControlEventEditingDidEnd];
	
    self.messageView = [[UIPlaceHolderTextView alloc] initWithFrame:self.tokenFieldView.contentView.bounds];
	[self.messageView setScrollEnabled:NO];
	[self.messageView setAutoresizingMask:UIViewAutoresizingNone];
	[self.messageView setDelegate:self];
	[self.messageView setFont:[UIFont systemFontOfSize:15]];
    self.messageView.placeholder = @"Your message";
	[self.tokenFieldView.contentView addSubview:self.messageView];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	
    [self.titleTextField becomeFirstResponder];
	// You can call this on either the view on the field.
	// They both do the same thing.
//	[self.tokenFieldView becomeFirstResponder];
}

-(void) setBackgroundToNavigationBar
{
    UIImage *img = [UIImage imageNamed:@"navigationbar_4"];
    UINavigationBar *bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.f, -20.f, 320.f, 65.f)];
    
    
    
    [bar setBackgroundColor:[UIColor clearColor]];
    [bar setBackgroundImage:[UIImage imageNamed:@"navigationbar_4"] forBarMetrics:UIBarMetricsDefault];
    [bar setTranslucent:YES];
    
    
    //Change the format of the navigation bar.
    [self.navigationController.navigationBar setTranslucent:YES];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationbar_trans"] forBarMetrics:UIBarMetricsDefault];
    
    [self.navigationController.navigationBar insertSubview:bar atIndex:1];
}

- (IBAction)titleTextField:(id)sender {
}

- (IBAction)cancelButtonClick:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sendButtonClick:(id)sender
{
//    Topic *topic = [[Topic alloc] init];
//    topic.title = self.titleTextField.text;
//    topic.date = [NSDate date];
//    
//    NSArray *users = [NSArray array];//  [NSArray arrayWithObjects:[SessionManager sharedInstance].user, nil];
//    topic.users = users;
//    
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    hud.labelText = @"Creating post";
//    hud.detailsLabelText = @"Please wait few seconds";
//
//    WebClient *client = [WebClient sharedInstance];
//    [client createTopic:topic callbackBlock:^(BOOL success) {
//        [hud hide:YES];
//        
//        if(success) {
//            [self dismissViewControllerAnimated:YES completion:nil];
//        } else {
//            
//        }
//    }];
}




- (void)keyboardWillShow:(NSNotification *)notification {
	
	CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	self.keyboardHeight = keyboardRect.size.height > keyboardRect.size.width ? keyboardRect.size.width : keyboardRect.size.height;
	[self resizeViews];
}

- (void)keyboardWillHide:(NSNotification *)notification {
	self.keyboardHeight = 0;
	[self resizeViews];
}

- (void)resizeViews {
    int tabBarOffset = self.tabBarController == nil ?  0 : self.tabBarController.tabBar.frame.size.height;
	[_tokenFieldView setFrame:((CGRect){_tokenFieldView.frame.origin, {self.view.bounds.size.width, self.view.bounds.size.height + tabBarOffset - _keyboardHeight}})];
	[_messageView setFrame:_tokenFieldView.contentView.bounds];
}

- (BOOL)tokenField:(TITokenField *)tokenField willRemoveToken:(TIToken *)token {
	
	if ([token.title isEqualToString:@"Tom Irving"]){
		return NO;
	}
	
	return YES;
}

- (void)tokenFieldChangedEditing:(TITokenField *)tokenField {
	// There's some kind of annoying bug where UITextFieldViewModeWhile/UnlessEditing doesn't do anything.
	[tokenField setRightViewMode:(tokenField.editing ? UITextFieldViewModeAlways : UITextFieldViewModeNever)];
}

- (void)tokenFieldFrameDidChange:(TITokenField *)tokenField {
	[self textViewDidChange:self.messageView];
}

- (void)textViewDidChange:(UITextView *)textView {
	
	CGFloat oldHeight = self.tokenFieldView.frame.size.height - self.tokenFieldView.tokenField.frame.size.height;
	CGFloat newHeight = textView.contentSize.height + textView.font.lineHeight;
	
	CGRect newTextFrame = textView.frame;
	newTextFrame.size = textView.contentSize;
	newTextFrame.size.height = newHeight;
	
	CGRect newFrame = self.tokenFieldView.contentView.frame;
	newFrame.size.height = newHeight;
	
	if (newHeight < oldHeight){
		newTextFrame.size.height = oldHeight;
		newFrame.size.height = oldHeight;
	}
    
	[self.tokenFieldView.contentView setFrame:newFrame];
	[textView setFrame:newTextFrame];
	[self.tokenFieldView updateContentSize];
}

- (void)showContactsPicker:(id)sender {
	
	// Show some kind of contacts picker in here.
	// For now, here's how to add and customize tokens.
	
	NSArray * names = self.usersNames;
	
	TIToken * token = [_tokenFieldView.tokenField addTokenWithTitle:[names objectAtIndex:(arc4random() % names.count)]];
	[token setAccessoryType:TITokenAccessoryTypeDisclosureIndicator];
	// If the size of the token might change, it's a good idea to layout again.
	[_tokenFieldView.tokenField layoutTokensAnimated:YES];
	
	NSUInteger tokenCount = _tokenFieldView.tokenField.tokens.count;
	[token setTintColor:((tokenCount % 3) == 0 ? [TIToken redTintColor] : ((tokenCount % 2) == 0 ? [TIToken greenTintColor] : [TIToken blueTintColor]))];
}

@end
