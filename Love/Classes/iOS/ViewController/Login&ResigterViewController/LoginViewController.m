//
//  LoginViewController.m
//  Love
//
//  Created by lee wei on 14-7-16.
//  Copyright (c) 2014年 李伟. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterStep1ViewController.h"

#import "LOVThirdLogin.h"
#import "UserManager.h"

#import "LoginModel.h"

#import "AppDelegate.h"

NSString *const LoginSuccessNotificationName = @"LoginSuccessNotification";

@interface LoginViewController ()<UITextFieldDelegate, UIAlertViewDelegate, LoginSuccessDelegate, SinaThirdLoginDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *bgScrolleView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

@property (nonatomic ,strong) IBOutlet UITextField *loginNameTextField, *passwordTextField;
@property (nonatomic, strong) IBOutlet UIButton *forgetPasswordButton, *loginButton, *registerButton, *backButton;
@property (nonatomic, strong) IBOutlet UIButton *qqButton, *weixinButton, *alipayButton, *weiboButton;
@property (nonatomic, strong) IBOutlet UILabel *infoLabel;

@property (nonatomic, strong) LOVThirdLogin *thirdLogin;

@property (nonatomic, strong) AppDelegate *myDelegate;

- (IBAction)forgetPasswordAction:(id)sender;

- (IBAction)qqAction:(id)sender;
- (IBAction)weixinAction:(id)sender;
- (IBAction)alipayAction:(id)sender;
- (IBAction)weiboAction:(id)sender;


@end

@implementation LoginViewController

#pragma mark -- LoginSuccessDelegate
- (void)loginSuccess{
    [self.navigationController popViewControllerAnimated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LoginSuccessNotificationName object:nil];
}

#pragma mark -- SinaSuccessDelegate
- (void)sinaLoginSuccess{
    [self.navigationController popViewControllerAnimated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LoginSuccessNotificationName object:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationController.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = MyLocalizedString(@"登录");
    
    [_registerButton setTitle:MyLocalizedString(@"注册") forState:UIControlStateNormal];
    [_loginButton setTitle:MyLocalizedString(@"登录") forState:UIControlStateNormal];
    [_forgetPasswordButton setTitle:MyLocalizedString(@"忘记密码") forState:UIControlStateNormal];
    if (kScreenWidth > 320) {
        _infoLabel.text = MyLocalizedString(@"------------------------------或使用合作账号登陆----------------------------");
    }else{
        _infoLabel.text = MyLocalizedString(@"-----------------------或使用合作账号登陆------------------------");
    }
    
    
    
    self.view.backgroundColor = [UIColor colorRGBWithRed:235.f green:235.f blue:235.f alpha:1];
    
    _bgScrolleView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    _bgScrolleView.contentSize = CGSizeMake(kScreenWidth, 568);
    _loginNameTextField.frame = CGRectMake(0, 27, kScreenWidth, 44);
    _passwordTextField.frame = CGRectMake(0, 70, kScreenWidth, 44);
    _registerButton.frame = CGRectMake(kScreenWidth/2 - 63, 120, 58, 30);
    _loginButton.frame = CGRectMake(10, CGRectGetMaxY(_passwordTextField.frame) + 33, kScreenWidth - 20, 44);
    _forgetPasswordButton.frame = CGRectMake(kScreenWidth - 63, CGRectGetMaxY(_loginButton.frame) + 20, 53, 20);
    _infoLabel.frame = CGRectMake(0, CGRectGetMaxY(_forgetPasswordButton.frame) + 38, kScreenWidth, 20);
    _infoLabel.font = [UIFont systemFontOfSize:11.f];
    
    if ([WXApi isWXAppInstalled] && ![TencentOAuth iphoneQQInstalled]) {
        _qqButton.hidden = YES;
        _weixinButton.frame = CGRectMake((kScreenWidth - 150)/3, CGRectGetMaxY(_infoLabel.frame) + 50, 75, 95);
        _weiboButton.frame = CGRectMake(CGRectGetMaxX(_weixinButton.frame) + (kScreenWidth - 150)/3, CGRectGetMaxY(_infoLabel.frame) + 50, 75, 95);
    }else if ([TencentOAuth iphoneQQInstalled] && ![WXApi isWXAppInstalled]) {
        _weixinButton.hidden = YES;
        _qqButton.frame = CGRectMake((kScreenWidth - 150)/3, CGRectGetMaxY(_infoLabel.frame) + 50, 75, 95);
        _weiboButton.frame = CGRectMake(CGRectGetMaxX(_qqButton.frame) + (kScreenWidth - 150)/3, CGRectGetMaxY(_infoLabel.frame) + 50, 75, 95);
    }else if ([WXApi isWXAppInstalled] && [TencentOAuth iphoneQQInstalled]){
        _qqButton.frame = CGRectMake((kScreenWidth - 225)/4, CGRectGetMaxY(_infoLabel.frame) + 50, 75, 95);
        _weixinButton.frame = CGRectMake(CGRectGetMaxX(_qqButton.frame) + (kScreenWidth - 225)/4, CGRectGetMaxY(_infoLabel.frame) + 50, 75, 95);
        _weiboButton.frame = CGRectMake(CGRectGetMaxX(_weixinButton.frame) + (kScreenWidth - 225)/4, CGRectGetMaxY(_infoLabel.frame) + 50, 75, 95);
    }else{
        _qqButton.hidden = YES;
        _weixinButton.hidden = YES;
        _weiboButton.frame = CGRectMake((kScreenWidth - 75)/2, CGRectGetMaxY(_infoLabel.frame) + 50, 75, 95);
    }

    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.frame = CGRectMake(0, 0, 60, 36.f);
    nextButton.backgroundColor = [UIColor clearColor];
    [nextButton setTitle:@"快速注册" forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    nextButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
    [nextButton addTarget:self action:@selector(registerAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *nextBarButton = [[UIBarButtonItem alloc] initWithCustomView:nextButton];
    self.navigationItem.rightBarButtonItem = nextBarButton;
    
    
    //------
    _loginNameTextField.layer.borderColor = [[UIColor colorRGBWithRed:204.f green:204.f blue:204.f alpha:1] CGColor];
    _loginNameTextField.layer.borderWidth = 0.8;
    _loginNameTextField.backgroundColor = [UIColor whiteColor];
//    _loginNameTextField.layer.cornerRadius = 10.f;
    _loginNameTextField.placeholder = @"用户名,邮箱,手机号";
    _loginNameTextField.clearButtonMode = UITextFieldViewModeAlways;
    _loginNameTextField.delegate = self;
    UIImageView *loginImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"userName"]];
    _loginNameTextField.leftView = loginImageView;
    _loginNameTextField.leftViewMode = UITextFieldViewModeAlways;
    
    _passwordTextField.layer.borderColor = [[UIColor colorRGBWithRed:204.f green:204.f blue:204.f alpha:1] CGColor];
    _passwordTextField.layer.borderWidth = 0.8;
    _passwordTextField.backgroundColor = [UIColor whiteColor];
//    _passwordTextField.layer.cornerRadius = 10.f;
    _passwordTextField.placeholder = @"请输入密码";
    _passwordTextField.clearButtonMode = UITextFieldViewModeAlways;
    _passwordTextField.secureTextEntry = YES;
    _passwordTextField.delegate = self;
    UIImageView *passImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"passWord"]];
    _passwordTextField.leftView = passImageView;
    _passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    
    //-----
    [_forgetPasswordButton setTitle:@"忘记密码?" forState:UIControlStateNormal];
    [_forgetPasswordButton setTitleColor:[UIColor colorRGBWithRed:244.f green:140.f blue:156.f alpha:1.f] forState:UIControlStateNormal];
    
    _infoLabel.textColor = [UIColor colorRGBWithRed:244.f green:140.f blue:156.f alpha:1.f];
    //----
    _loginButton.backgroundColor = [UIColor colorRGBWithRed:237 green:20 blue:91 alpha:1];
    _loginButton.layer.masksToBounds = YES;
    _loginButton.layer.cornerRadius = 4.f;
    [_loginButton addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    
    _registerButton.hidden = YES;
    [_registerButton addTarget:self action:@selector(registerAction) forControlEvents:UIControlEventTouchUpInside];
    //--------
    
    _thirdLogin = [[LOVThirdLogin alloc] init];
    _thirdLogin.delegate = self;
    
    [AppDelegate shareInstance].deleagte = self;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    _loginNameTextField.text = nil;
    _passwordTextField.text = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_loginNameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    return YES;
}

#pragma mark - button action
/**
 登陆
 */
- (void)loginAction
{
    [LoginModel loginAppWithName:_loginNameTextField.text password:_passwordTextField.text block:^(int code, NSDictionary *dic) {
        if (code == 1) {
            
            NSString *sig = [[dic objectForKey:@"sign"] objectForKey:@"sig"];
            NSString *uid = [[dic objectForKey:@"sign"] objectForKey:@"uid"];
            NSLog(@"sig = %@, uid = %@", sig, uid);
            [UserManager saveAccount:_loginNameTextField.text password:_passwordTextField.text];
            [UserManager saveSig:sig uid:uid];
            
            [self.navigationController popViewControllerAnimated:YES];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:LoginSuccessNotificationName object:nil];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"用户名或密码错误"
                                                               delegate:self
                                                      cancelButtonTitle:MyLocalizedString(@"OK")
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    }];
}


/**
 注册
 */
- (void)registerAction
{
    RegisterStep1ViewController *step1ViewController = [[RegisterStep1ViewController alloc] initWithNibName:@"RegisterStep1View" bundle:nil];
    [self.navigationController pushViewController:step1ViewController animated:YES];
}

/**
 忘记密码
 */
- (IBAction)forgetPasswordAction:(id)sender
{
//    UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:nil
//                                                       message:@"如果重设密码，请输入已绑定的邮箱。"
//                                                      delegate:self
//                                             cancelButtonTitle:MyLocalizedString(@"Cancel")
//                                             otherButtonTitles:MyLocalizedString(@"OK"), nil];
//    alerView.alertViewStyle = UIAlertViewStylePlainTextInput;
//    alerView.delegate = self;
//    [alerView show];
    RegisterStep1ViewController *register1 = [[RegisterStep1ViewController alloc] init];
    register1.isForgetPwd = YES;
    [self.navigationController pushViewController:register1 animated:YES];
    
    
}

- (IBAction)qqAction:(id)sender
{
    [_thirdLogin qqLoginAction];
}
- (IBAction)weixinAction:(id)sender
{
    [_thirdLogin weixinLoginAction];
}
- (IBAction)alipayAction:(id)sender
{
    [_thirdLogin alipayLoginAction];
}
- (IBAction)weiboAction:(id)sender
{
    [_thirdLogin weiboLoginAction];
}

#pragma mark - alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
    }
    if (buttonIndex == 1) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        
        NSLog(@"---------------------- %@", textField.text);
    }
}

@end
