/*
 * Copyright 2010 Andrey Yastrebov
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "VkontakteViewController.h"

@interface VkontakteViewController (Private)
- (NSString*)stringBetweenString:(NSString*)start 
                       andString:(NSString*)end 
                     innerString:(NSString*)str;
@end

@implementation VkontakteViewController (Private)

- (NSString*)stringBetweenString:(NSString*)start 
                       andString:(NSString*)end 
                     innerString:(NSString*)str 
{
    NSScanner* scanner = [NSScanner scannerWithString:str];
    [scanner setCharactersToBeSkipped:nil];
    [scanner scanUpToString:start intoString:nil];
    if ([scanner scanString:start intoString:nil]) 
    {
        NSString* result = nil;
        if ([scanner scanUpToString:end intoString:&result]) 
        {
            return result;
        }
    }
    return nil;
}

@end

@implementation VkontakteViewController

@synthesize delegate;
@synthesize webView;

- (id)initWithAuthLink:(NSURL *)link
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    self = [storyboard instantiateViewControllerWithIdentifier:@"VkontakteLogin"];
    if (self) 
    {
        _authLink = link;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
//    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
//    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
//        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar.png"]
//                                 forBarMetrics:UIBarMetricsDefault];
//    }

//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Отмена" 
//                                                                              style:UIBarButtonItemStyleBordered 
//                                                                             target:self 
//                                                                             action:@selector(cancelButtonPressed:)];
    self.webView.delegate = self;
    DLog(@"%@", _authLink);
    [self.webView loadRequest:[NSURLRequest requestWithURL:_authLink]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.webView.delegate = nil;
    self.webView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)cancelButtonPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(authorizationDidCanceled)])
    {
        [self.delegate authorizationDidCanceled];
    }
}

#pragma mark - WebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView 
{
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"LOADING", @"loading screen")];
}

- (void)webViewDidFinishLoad:(UIWebView *)_webView 
{
    NSString *cleanup_dialog = @"var nodes=document.getElementsByClassName('apps_access_item');"
    "for (var i=0;i<nodes.length;i++) {"
    "   nodes[i].children[1].children[0].nextSibling.textContent = '';"
    "}"
    "var profile_link=document.getElementsByClassName('prof_panel')[0].removeAttribute('href');";
    [_webView stringByEvaluatingJavaScriptFromString:cleanup_dialog];
    NSString *webViewText = [_webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerText"];
    if ([webViewText caseInsensitiveCompare:@"security breach"] == NSOrderedSame)
    {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SECURITY_ERROR_TITLE", @"title for alert view")
                                                              message:NSLocalizedString(@"SECURITY_ERROR", @"security error description") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [myAlertView show];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(authorizationDidFailedWithError:)]) 
        {
            [self.delegate authorizationDidFailedWithError:nil];
        }
    } 
    else if ([webView.request.URL.absoluteString rangeOfString:@"access_token"].location != NSNotFound) 
    {
        self.webView.hidden = YES;
        NSString *accessToken = [self stringBetweenString:@"access_token="
                                                andString:@"&" 
                                              innerString:[[[webView request] URL] absoluteString]];
        
        // Получаем id пользователя, пригодится нам позднее
        NSArray *userAr = [[[[webView request] URL] absoluteString] componentsSeparatedByString:@"&user_id="];
        NSString *user_id = [userAr lastObject];
        DLog(@"User id: %@", user_id);
        
        NSString *expTime = [self stringBetweenString:@"expires_in=" 
                                            andString:@"&" 
                                          innerString:[[[webView request] URL] absoluteString]];
        NSDate *expirationDate = nil;
        if (expTime != nil) 
        {
            int expVal = [expTime intValue];
            if (expVal == 0) 
            {
                expirationDate = [NSDate distantFuture];
            } 
            else 
            {
                expirationDate = [NSDate dateWithTimeIntervalSinceNow:expVal];
            } 
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(authorizationDidSucceedWithToke:userId:expDate:userEmail:)]) 
        {
            [self.delegate authorizationDidSucceedWithToke:accessToken 
                                                    userId:user_id 
                                                   expDate:expirationDate
                                                 userEmail:_userEmail];
        }
    } 
    else if ([webView.request.URL.absoluteString rangeOfString:@"error"].location != NSNotFound) 
    {
        DLog(@"Error: %@", webView.request.URL.absoluteString);
        if (self.delegate && [self.delegate respondsToSelector:@selector(authorizationDidFailedWithError:)]) 
        {
            [self.delegate authorizationDidFailedWithError:nil];
        }
    }
    
    [[UIApplication sharedApplication] hideNetworkActivityIndicator];
    [SVProgressHUD dismiss];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error 
{    
    [Flurry logError:@"VK_WEBVIEW_FAILED" message:error.localizedDescription error:error];
    if (self.delegate && [self.delegate respondsToSelector:@selector(authorizationDidFailedWithError:)]) 
    {
        [self.delegate authorizationDidFailedWithError:error];
    }
    
    [[UIApplication sharedApplication] hideNetworkActivityIndicator];
    [SVProgressHUD dismiss];
}

- (BOOL)webView:(UIWebView *)_webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType 
{    
    NSString *s = @"var inputs = document.getElementsByTagName('input');"
    "var email = '';"
    "for (var i=0;i<inputs.length; i++) {"
    "    if (inputs[i].name == 'email') { email = inputs[i].value; break; };"
    "}"
    "email;"; 
     
    NSString *email = [_webView stringByEvaluatingJavaScriptFromString:s];
    DLog(@"Caught EMAIL %@", email);
    if (([email length] != 0))
    {
        _userEmail = email;
    }
   
    NSURL *URL = [request URL];
    // Пользователь нажал Отмена в веб-форме
    if ([[URL absoluteString] isEqualToString:@"http://api.vk.com/blank.html#error=access_denied&error_reason=user_denied&error_description=User%20denied%20your%20request"]) 
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(authorizationDidCanceled)]) 
        {
            [self.delegate authorizationDidCanceled];
        }
        return NO;
    }
	DLog(@"Request: %@", [URL absoluteString]); 
	return YES;
}

@end
