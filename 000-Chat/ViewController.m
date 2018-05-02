//
//  ViewController.m
//  000-Chat
//
//  Created by 李晓东 on 2018/4/25.
//  Copyright © 2018年 PeanutXu. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "RosterViewController.h"

#define ScreenWidth self.view.frame.size.width
#define ScreenHeight self.view.frame.size.height

@interface ViewController () <LoginRegistDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameView;
@property (weak, nonatomic) IBOutlet UITextField *passwordView;
@property (weak, nonatomic) IBOutlet UITextField *serverView;
@property (weak, nonatomic) IBOutlet UIButton *btn;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;

@property (weak, nonatomic) IBOutlet UITextField *demoTextView;
@end

@implementation ViewController
{
    AppDelegate *_app;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _app.loginRegistDelegate = self;
    CALayer *layer = self.btn.layer;
    [layer setCornerRadius:5];
    [layer setMasksToBounds:YES];
    [layer setBorderWidth:2];
    [layer setBorderColor:[UIColor redColor].CGColor];
//    [layer setBorderWidth:2];
    
    CALayer *sureBtnLayer = self.sureBtn.layer;
    [sureBtnLayer setCornerRadius:5];
    [sureBtnLayer setMasksToBounds:YES];
    [sureBtnLayer setBorderWidth:2];
    [sureBtnLayer setBorderColor:[UIColor blueColor].CGColor];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(demoMethod:) name:UIKeyboardWillShowNotification object:nil];
    
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(selfInputViewHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)demoMethod:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGFloat duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey]floatValue];
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView animateWithDuration:1 animations:^{
        CGRect inputFrame = _demoTextView.frame;
        inputFrame.origin.y = ScreenHeight - keyboardRect.size.height - 55;
        _demoTextView.frame = inputFrame;
    }];
}

- (IBAction)loginClick:(id)sender {
    NSString *nameText = self.nameView.text;
    NSString *passwordText = self.passwordView.text;
    NSString *serverText = self.serverView.text;
    
    if ((nameText == nil || nameText.length <= 0) && (passwordText == nil || passwordText.length <= 0)
        && (serverText == nil || serverText.length <= 0)) {
        return;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:nameText forKey:USER_KEY];
    [userDefaults setObject:passwordText forKey:PASS_KEY];
    [userDefaults setObject:serverText forKey:SERVER_KEY];
    
    [_app connect:NO];
}

- (IBAction)registorClick:(id)sender {
    NSString *nameText = self.nameView.text;
    NSString *passwordText = self.passwordView.text;
    NSString *serverText = self.serverView.text;
    
    if ((nameText == nil || nameText.length <= 0) && (passwordText == nil || passwordText.length <= 0)
        && (serverText == nil || serverText.length <= 0)) {
        return;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:nameText forKey:USER_KEY];
    [userDefaults setObject:passwordText forKey:PASS_KEY];
    [userDefaults setObject:serverText forKey:SERVER_KEY];
    
    [_app connect:YES];
    
}

- (void)login{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        ViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainScene"];
        [self presentViewController:viewController animated:YES completion:nil];
    });
    
}

@end
