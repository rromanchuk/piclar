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

#import "Vkontakte.h"
#import "Config.h"
@interface Vkontakte (Private)

- (void)storeSession;
- (BOOL)isSessionValid;
- (void)getCaptcha;
- (NSDictionary *)sendRequest:(NSString *)reqURl withCaptcha:(BOOL)captcha;
- (NSDictionary *)sendPOSTRequest:(NSString *)reqURl withImageData:(NSData *)imageData;
- (NSString *)URLEncodedString:(NSString *)str;
@end

@implementation Vkontakte (Private)

- (void)storeSession
{
    // Save authorization information
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.accessToken forKey:@"VKAccessTokenKey"];
    [defaults setObject:self.expirationDate forKey:@"VKExpirationDateKey"];
    [defaults setObject:self.userId forKey:@"VKUserID"];
    [defaults setObject:self.email forKey:@"VKUserEmail"];
    [defaults synchronize];
}

- (BOOL)isSessionValid 
{
    return (self.accessToken != nil && self.expirationDate != nil && self.userId != nil
            && NSOrderedDescending == [self.expirationDate compare:[NSDate date]]);
}

- (void)getCaptcha 
{
    NSString *captcha_img = [[NSUserDefaults standardUserDefaults] objectForKey:@"captcha_img"];
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CAPTCHA", @"enter captcha code")
                                                          message:@"\n" delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", @"Cancel button") otherButtonTitles:@"OK", nil];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0, 45.0, 130.0, 50.0)];
    imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:captcha_img]]];
    [myAlertView addSubview:imageView];
    
    UITextField *myTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 110.0, 260.0, 25.0)];
    [myTextField setBackgroundColor:[UIColor whiteColor]];
    
    myTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    myTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    myTextField.tag = 33;
    
    [myAlertView addSubview:myTextField];
    [myAlertView show];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(_isCaptcha && buttonIndex == 1)
    {
        _isCaptcha = NO;
        
        UITextField *myTextField = (UITextField *)[actionSheet viewWithTag:33];
        [[NSUserDefaults standardUserDefaults] setObject:myTextField.text forKey:@"captcha_user"];
        DLog(@"Captcha entered: %@",myTextField.text);
        
        // Вспоминаем какой был последний запрос и делаем его еще раз
        NSString *request = [[NSUserDefaults standardUserDefaults] objectForKey:@"request"];
        
        NSDictionary *newRequestDict =[self sendRequest:request withCaptcha:YES];
        NSString *errorMsg = [[newRequestDict  objectForKey:@"error"] objectForKey:@"error_msg"];
        if(errorMsg) 
        {
            NSError *error = [NSError errorWithDomain:@"vk.com" 
                                                 code:[[[newRequestDict  objectForKey:@"error"] objectForKey:@"error_code"] intValue] 
                                             userInfo:[newRequestDict  objectForKey:@"error"]];
            if (self.delegate && [self.delegate respondsToSelector:@selector(vkontakteDidFailedWithError:)]) 
            {
                [self.delegate vkontakteDidFailedWithError:error];
            }
            
        } 
        else 
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(vkontakteDidFinishPostingToWall:)]) 
            {
                [self.delegate vkontakteDidFinishPostingToWall:newRequestDict];
            }
            
        }
    }
}

- (NSDictionary *)sendRequest:(NSString *)reqURl withCaptcha:(BOOL)captcha 
{
    if(captcha == YES)
    {
        NSString *captcha_sid = [[NSUserDefaults standardUserDefaults] objectForKey:@"captcha_sid"];
        NSString *captcha_user = [[NSUserDefaults standardUserDefaults] objectForKey:@"captcha_user"];
        reqURl = [reqURl stringByAppendingFormat:@"&captcha_sid=%@&captcha_key=%@", captcha_sid, [self URLEncodedString: captcha_user]];
    }
    DLog(@"Sending request: %@", reqURl);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:reqURl] 
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData 
                                                       timeoutInterval:60.0]; 
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    if(responseData)
    {        
        NSError* error;
        NSDictionary* dict = [NSJSONSerialization 
                              JSONObjectWithData:responseData                              
                              options:kNilOptions 
                              error:&error];
        
        NSString *errorMsg = [[dict objectForKey:@"error"] objectForKey:@"error_msg"];
        
        DLog(@"Server response: %@ \nError: %@", dict, errorMsg);
        
        if([errorMsg isEqualToString:@"Captcha needed"])
        {
            _isCaptcha = YES;
            NSString *captcha_sid = [[dict objectForKey:@"error"] objectForKey:@"captcha_sid"];
            NSString *captcha_img = [[dict objectForKey:@"error"] objectForKey:@"captcha_img"];
            [[NSUserDefaults standardUserDefaults] setObject:captcha_img forKey:@"captcha_img"];
            [[NSUserDefaults standardUserDefaults] setObject:captcha_sid forKey:@"captcha_sid"];
            [[NSUserDefaults standardUserDefaults] setObject:reqURl forKey:@"request"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self getCaptcha];
        }
        
        return dict;
    }
    return nil;
}

- (NSDictionary *)sendPOSTRequest:(NSString *)reqURl withImageData:(NSData *)imageData 
{
    DLog(@"Sending request: %@", reqURl);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:reqURl] 
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData 
                                                       timeoutInterval:60.0]; 
    [request setHTTPMethod:@"POST"]; 
    
    [request addValue:@"8bit" forHTTPHeaderField:@"Content-Transfer-Encoding"];
    
    CFUUIDRef uuid = CFUUIDCreate(nil);
    NSString *uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(nil, uuid);
    CFRelease(uuid);
    NSString *stringBoundary = [NSString stringWithFormat:@"0xKhTmLbOuNdArY-%@",uuidString];
    NSString *endItemBoundary = [NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary];
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data;  boundary=%@", stringBoundary];
    
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"photo\"; filename=\"photo.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: image/jpg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:imageData];        
    [body appendData:[[NSString stringWithFormat:@"%@",endItemBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    if(responseData)
    {        
        NSError* error;
        NSDictionary* dict = [NSJSONSerialization 
                              JSONObjectWithData:responseData
                              options:kNilOptions 
                              error:&error];
        
        NSString *errorMsg = [[dict objectForKey:@"error"] objectForKey:@"error_msg"];
        
        DLog(@"Server response: %@ \nError: %@", dict, errorMsg);
        
        return dict;
    }
    return nil;
}

- (NSString *)URLEncodedString:(NSString *)str
{
    NSString *result = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                             (__bridge CFStringRef)str,
                                                                                             NULL,
                                                                                             CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                             kCFStringEncodingUTF8);
	return result;
}

@end

@implementation Vkontakte

@synthesize delegate;
@synthesize accessToken;
@synthesize userId; 
@synthesize email;
@synthesize expirationDate; 
@synthesize bigPhotoUrl;

#pragma mark - Initialize

+ (Vkontakte *)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

- (id)init
{
    self = [super init];
    if (self) 
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"VKAccessTokenKey"] 
            && [defaults objectForKey:@"VKExpirationDateKey"]
            && [defaults objectForKey:@"VKUserID"]
            && [defaults objectForKey:@"VKUserEmail"]) 
        {
            self.accessToken = [defaults objectForKey:@"VKAccessTokenKey"];
            self.expirationDate = [defaults objectForKey:@"VKExpirationDateKey"];
            self.userId = [defaults objectForKey:@"VKUserID"];
            self.email = [defaults objectForKey:@"VKUserEmail"];
        }
    }
    return self;
}

- (BOOL)isAuthorized
{        
    return [self isSessionValid];
}

- (void)authenticate
{
   
    
    NSURL *url = [NSURL URLWithString:[Config sharedConfig].vkUrl];
    VkontakteViewController *vkontakteViewController = [[VkontakteViewController alloc] initWithAuthLink:url];
    vkontakteViewController.delegate = self;
        
    if (self.delegate && [self.delegate respondsToSelector:@selector(showVkontakteAuthController:)]) 
    {
        DLog(@"about to show auth");
        [self.delegate showVkontakteAuthController:vkontakteViewController];
    }
}

- (void)logout
{
    NSString *logout = [NSString stringWithFormat:@"http://api.vk.com/oauth/logout?client_id=%@", [Config sharedConfig].vkAppId];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:logout] 
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData 
                                                       timeoutInterval:60.0]; 
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request 
                                                 returningResponse:nil 
                                                             error:nil];
    if(responseData)
    {
        NSError* error;
        NSDictionary* dict = [NSJSONSerialization 
                              JSONObjectWithData:responseData
                              options:kNilOptions 
                              error:&error];
        DLog(@"Logout: %@", dict);
        
        NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray* cookieUrlsToDelete = [NSArray arrayWithObjects:@"http://api.vk.com", @"http://vk.com", @"http://login.vk.com", @"http://oauth.vk.com",
                                       @"https://api.vk.com", @"https://vk.com", @"https://login.vk.com", @"https://oauth.vk.com",  nil];

        for (NSString* url in cookieUrlsToDelete) {
            NSArray* vkCookies = [cookies cookiesForURL:[NSURL URLWithString:url]];
            for (NSHTTPCookie* cookie in vkCookies)
            {
                [cookies deleteCookie:cookie];
            }
            
        }
             
        // Remove saved authorization information if it exists and it is
        // ok to clear it (logout, session invalid, app unauthorized)
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"VKAccessTokenKey"]) 
        {
            [defaults removeObjectForKey:@"VKAccessTokenKey"];
            [defaults removeObjectForKey:@"VKExpirationDateKey"];
            [defaults removeObjectForKey:@"VKUserID"];
            [defaults removeObjectForKey:@"VKUserEmail"];
            [defaults synchronize];
            
            // Nil out the session variables to prevent
            // the app from thinking there is a valid session
            if (self.accessToken) 
            {
                self.accessToken = nil;
            }
            if (self.expirationDate) 
            {
                self.expirationDate = nil;
            }
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(vkontakteDidFinishLogOut:)]) 
        {
            [self.delegate vkontakteDidFinishLogOut:self];
        }
    }
}

- (void)getUserInfo
{    
    if (![self isAuthorized]) return;
    
    NSMutableString *requestString = [[NSMutableString alloc] init];
	[requestString appendFormat:@"%@/", @"https://api.vk.com/method"];
    [requestString appendFormat:@"%@?", @"getProfiles"];
    [requestString appendFormat:@"uid=%@&", self.userId];
    NSMutableString *fields = [[NSMutableString alloc] init];
    [fields appendString:@"sex,bdate,photo,photo_big"];
    [requestString appendFormat:@"fields=%@&", fields];
    [requestString appendFormat:@"access_token=%@", self.accessToken];
    
	NSURL *url = [NSURL URLWithString:requestString];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	
	NSData *response = [NSURLConnection sendSynchronousRequest:request 
											 returningResponse:nil 
														 error:nil];
	NSString *responseString = [[NSString alloc] initWithData:response 
                                                     encoding:NSUTF8StringEncoding];
	DLog(@"%@",responseString);
    
    NSError* error;
    NSDictionary* parsedDictionary = [NSJSONSerialization 
                                      JSONObjectWithData:response
                                      options:kNilOptions 
                                      error:&error];
    
    NSArray *array = [parsedDictionary objectForKey:@"response"];
    
    if ([parsedDictionary objectForKey:@"response"]) 
    {
        parsedDictionary = [array objectAtIndex:0];
        parsedDictionary = [NSMutableDictionary dictionaryWithDictionary:parsedDictionary];
        [parsedDictionary setValue:self.email forKey:@"email"];
        
        self.bigPhotoUrl = [parsedDictionary objectForKey:@"photo_big"];
        if ([self.delegate respondsToSelector:@selector(vkontakteDidFinishGettinUserInfo:)])
        {
            [self.delegate vkontakteDidFinishGettinUserInfo:parsedDictionary];
        }
    }
    else
    {        
        NSDictionary *errorDict = [parsedDictionary objectForKey:@"error"];
        
        if ([self.delegate respondsToSelector:@selector(vkontakteDidFailedWithError:)])
        {
            NSError *error = [NSError errorWithDomain:@"http://api.vk.com/method" 
                                                 code:[[errorDict objectForKey:@"error_code"] intValue]
                                             userInfo:errorDict];
            
            if (error.code == 5) 
            {
                [self logout];
            }
            
            [self.delegate vkontakteDidFailedWithError:error];
        }
    }
}

- (void)postMessageToWall:(NSString *)message
{
    if (![self isAuthorized]) return;
    
    NSString *sendTextMessage = [NSString stringWithFormat:@"https://api.vk.com/method/wall.post?owner_id=%@&access_token=%@&message=%@", 
                                 self.userId, 
                                 self.accessToken, 
                                 [self URLEncodedString:message]];
    DLog(@"sendTextMessage: %@", sendTextMessage);
    
    NSDictionary *result = [self sendRequest:sendTextMessage withCaptcha:NO];
    // Если есть описание ошибки в ответе
    NSString *errorMsg = [[result objectForKey:@"error"] objectForKey:@"error_msg"];
    if(errorMsg) 
    {
        NSDictionary *errorDict = [result objectForKey:@"error"];
        
        if ([self.delegate respondsToSelector:@selector(vkontakteDidFailedWithError:)])
        {
            NSError *error = [NSError errorWithDomain:@"http://api.vk.com/method" 
                                                 code:[[errorDict objectForKey:@"error_code"] intValue]
                                             userInfo:errorDict];
            
            if (error.code == 5) 
            {
                [self logout];
            }
            
            [self.delegate vkontakteDidFailedWithError:error];
        }
    } 
    else 
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(vkontakteDidFinishPostingToWall:)]) 
        {
            [self.delegate vkontakteDidFinishPostingToWall:result];
        }
    }
}

- (void)postMessageToWall:(NSString *)message link:(NSURL *)url
{
    if (![self isAuthorized]) return;
    
    NSString *link = [url absoluteString];
    
    NSString *sendTextAndLinkMessage = [NSString stringWithFormat:@"https://api.vk.com/method/wall.post?owner_id=%@&access_token=%@&message=%@&attachment=%@", 
                                        self.userId, 
                                        self.accessToken, 
                                        [self URLEncodedString:message], 
                                        link];
    
    DLog(@"sendTextAndLinkMessage: %@", sendTextAndLinkMessage);
    
    // Если запрос более сложный мы можем работать дальше с полученным ответом
    NSDictionary *result = [self sendRequest:sendTextAndLinkMessage withCaptcha:NO];
    NSString *errorMsg = [[result objectForKey:@"error"] objectForKey:@"error_msg"];
    if(errorMsg) 
    {
        NSDictionary *errorDict = [result objectForKey:@"error"];
        
        if ([self.delegate respondsToSelector:@selector(vkontakteDidFailedWithError:)])
        {
            NSError *error = [NSError errorWithDomain:@"http://api.vk.com/method" 
                                                 code:[[errorDict objectForKey:@"error_code"] intValue]
                                             userInfo:errorDict];
            
            if (error.code == 5) 
            {
                [self logout];
            }
            
            [self.delegate vkontakteDidFailedWithError:error];
        }
    } 
    else 
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(vkontakteDidFinishPostingToWall:)]) 
        {
            [self.delegate vkontakteDidFinishPostingToWall:result];
        }
    }
}

- (void)postImageToWall:(UIImage *)image text:(NSString *)message link:(NSURL *)url
{
    if (![self isAuthorized]) return;
    
    NSString *getWallUploadServer = [NSString stringWithFormat:@"https://api.vk.com/method/photos.getWallUploadServer?owner_id=%@&access_token=%@", self.userId, self.accessToken];
    
    NSDictionary *uploadServer = [self sendRequest:getWallUploadServer withCaptcha:NO];
    
    NSString *upload_url = [[uploadServer objectForKey:@"response"] objectForKey:@"upload_url"];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
    
    NSDictionary *postDictionary = [self sendPOSTRequest:upload_url withImageData:imageData];
    
    NSString *hash = [postDictionary objectForKey:@"hash"];
    NSString *photo = [postDictionary objectForKey:@"photo"];
    NSString *server = [postDictionary objectForKey:@"server"];
    
    NSString *saveWallPhoto = [NSString stringWithFormat:@"https://api.vk.com/method/photos.saveWallPhoto?owner_id=%@&access_token=%@&server=%@&photo=%@&hash=%@", 
                               self.userId, 
                               self.accessToken,
                               server,
                               photo,
                               hash];
    
    saveWallPhoto = [saveWallPhoto stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *saveWallPhotoDict = [self sendRequest:saveWallPhoto withCaptcha:NO];
    
    NSDictionary *photoDict = [[saveWallPhotoDict objectForKey:@"response"] lastObject];
    NSString *photoId = [photoDict objectForKey:@"id"];
    
    NSString *postToWallLink;
    
    if (url) 
    {
        postToWallLink = [NSString stringWithFormat:@"https://api.vk.com/method/wall.post?owner_id=%@&access_token=%@&message=%@&attachments=%@,%@", 
                          self.userId, 
                          self.accessToken, 
                          [self URLEncodedString:message], 
                          photoId,
                          [url absoluteURL]];
    } 
    else 
    {
        postToWallLink = [NSString stringWithFormat:@"https://api.vk.com/method/wall.post?owner_id=%@&access_token=%@&message=%@&attachment=%@", 
                          self.userId, 
                          self.accessToken, 
                          [self URLEncodedString:message], 
                          photoId];
    }
    
    NSDictionary *postToWallDict = [self sendRequest:postToWallLink withCaptcha:NO];
    NSString *errorMsg = [[postToWallDict  objectForKey:@"error"] objectForKey:@"error_msg"];
    if(errorMsg) 
    {
        NSDictionary *errorDict = [postToWallDict objectForKey:@"error"];
        
        if ([self.delegate respondsToSelector:@selector(vkontakteDidFailedWithError:)])
        {
            NSError *error = [NSError errorWithDomain:@"http://api.vk.com/method" 
                                                 code:[[errorDict objectForKey:@"error_code"] intValue]
                                             userInfo:errorDict];
            
            if (error.code == 5) 
            {
                [self logout];
            }
            
            [self.delegate vkontakteDidFailedWithError:error];
        }
    } 
    else 
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(vkontakteDidFinishPostingToWall:)]) 
        {
            [self.delegate vkontakteDidFinishPostingToWall:postToWallDict];
        }
    }
}

- (void)postImageToWall:(UIImage *)image
{   
    [self postImageToWall:image text:@""];
}

- (void)postImageToWall:(UIImage *)image text:(NSString *)message
{
    [self postImageToWall:image text:message link:nil];
}

#pragma mark - VkontakteViewControllerDelegate

- (void)authorizationDidSucceedWithToke:(NSString *)_accessToken 
                                 userId:(NSString *)_userId 
                                expDate:(NSDate *)_expDate
                              userEmail:(NSString *)_email

{
    self.accessToken = _accessToken;
    self.userId = _userId;
    self.expirationDate = _expDate;
    self.email = _email;
    
    [self storeSession];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(vkontakteDidFinishLogin:)]) 
    {
        [self.delegate vkontakteDidFinishLogin:self];
    }
}

- (void)authorizationDidFailedWithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(vkontakteDidFailedWithError:)]) 
    {
        [self.delegate vkontakteDidFailedWithError:error];
    }
}

- (void)authorizationDidCanceled
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(vkontakteAuthControllerDidCancelled)]) 
    {
        [self.delegate vkontakteAuthControllerDidCancelled];
    }
}

- (void)didFinishGettingUserEmail:(NSString *)_email
{
    self.email = _email;
}

@end
