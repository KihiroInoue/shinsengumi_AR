#import "XAuthTwitterStatusPost.h"
#import "XAuthTwitterEngine.h"

#import "OAMutableURLRequest.h"
#import "OAMutableURLRequest+Addisions.h"
#import "TRUtil.h"
#import "Define.h"


#pragma mark Private properties and methods definition
@interface XAuthTwitterStatusPost ()

@property (nonatomic, retain) XAuthTwitterEngine *twitterEngine;

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) TwitterPost* twitterPost;
@property (nonatomic, retain) ASIFormDataRequest* request;
- (void) timeOutAction;
- (void)postToTwitPic;
@end

#pragma mark -
@implementation XAuthTwitterStatusPost
@synthesize twitterEngine = _twitterEngine;

@synthesize username = _username;
@synthesize password = _password;
@synthesize twitterPost = _twitterPost;
@synthesize delegate = _delegate;
@synthesize request = _request;

- (XAuthTwitterStatusPost *) init {
    self = [super init];
    if (self) {
        self.twitterEngine = [[[XAuthTwitterEngine alloc] initXAuthWithDelegate:self] autorelease];
        self.twitterEngine.consumerKey = kOAuthConsumerKey;
        self.twitterEngine.consumerSecret = kOAuthConsumerSecret;
        self.delegate = nil;
    }
    return self;
}

- (void)dealloc {
    //TTDPRINT( @"%@ retainCount=%d", [self.twitterEngine retainCount]);

    [self.request clearDelegatesAndCancel];
    self.request = nil;
    
    self.delegate = nil;
    self.twitterEngine = nil;
    self.twitterPost = nil;
    
    self.username = nil;
    self.password = nil;
    [super dealloc];
}

- (void) setUserName:(NSString *)aUsername password:(NSString *)aPassword {
    self.username = aUsername;
    self.password = aPassword;
}

- (void) postMessage:(TwitterPost*)twitterPost timeoutInterval:(NSTimeInterval)timeoutInterval
{
    self.twitterPost = twitterPost;
    [self.twitterEngine exchangeAccessTokenForUsername:self.username password:self.password];
    if (timeoutInterval != 0.0) {
        [self performSelector:@selector(timeOutAction) withObject:nil afterDelay:timeoutInterval];
    }
}

-(void) authorize:(NSTimeInterval)timeoutInterval
{
    [self.twitterEngine exchangeAccessTokenForUsername:self.username password:self.password];
    
    if( timeoutInterval != 0.0) {
        [self performSelector:@selector(timeOutAction) withObject:nil afterDelay:timeoutInterval];
    }
}

// TODO:メッセージ投稿か、画像投稿をわけている。もっときれいにわけるベキ
- (void) sendUpdateToTwitter:(id)anArgument {
    if( self.twitterPost.image) {
        [self postToTwitPic];
    }
    else {
        if( CLLocationCoordinate2DIsInvalid(self.twitterPost.coordinate)) {
            [self.twitterEngine sendUpdate:self.twitterPost.text];
        }
        else {
            [self.twitterEngine sendUpdate:self.twitterPost.text latitude:self.twitterPost.coordinate.latitude longitude:self.twitterPost.coordinate.longitude];
        }
    }
}

- (void) storeCachedTwitterXAuthAccessTokenString: (NSString *)tokenString forUsername:(NSString *)username {
    //TTDPRINT(@"Access token string returned: %@", tokenString);
    if( self.twitterPost.text) {
        [self performSelector:@selector(sendUpdateToTwitter:) withObject:nil afterDelay:0.1];
    }
    // TODO:    self.message が nil になるので、その場合は、xAuthのチェック(authorize)のときとみなす
    // このへんは、きれいにしないといけない
    else {
        [self.delegate performSelector:@selector( didXAuthTwitterPostSuccess) withObject:nil afterDelay:0.1];
    }
}

- (NSString *) cachedTwitterXAuthAccessTokenStringForUsername: (NSString *)username {
    // NOT cache the xAuthAccess token
    return nil;
}

- (void) twitterXAuthConnectionDidFailWithError: (NSError *)error {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeOutAction) object:nil];
    //TTDPRINT(@"twitterXAuthConnectionDidFailWithError: %@", error);
    
    if (self.delegate) {
        [self.delegate performSelector:@selector( didXAuthTwitterPostAccountFailed:) withObject:error afterDelay:0.1];
    }
}

- (void)requestSucceeded:(NSString *)connectionIdentifier {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeOutAction) object:nil];
    
    
    // callback
    if (self.delegate) {
        [self.delegate performSelector:@selector(didXAuthTwitterPostSuccess) withObject:nil afterDelay:0.1];
    }
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeOutAction) object:nil];
    
    // callback
    if (self.delegate) {
        [self.delegate performSelector:@selector(didXAuthTwitterPostFailed:) withObject:error afterDelay:0.1];
    }
}

- (void) timeOutAction {    
    if (self.delegate) {
        NSError* error = [NSError errorWithDomain:NSURLErrorDomain code:408 userInfo:nil];
        [self.delegate performSelector:@selector( didXAuthTwitterPostFailed:) withObject:error afterDelay:0.1];
    }    
}

- (ASIFormDataRequest*)createOAuthEchoRequest:(NSString*)url format:(NSString*)format {
        
	NSString *authorizeUrl = [NSString stringWithFormat:@"https://api.twitter.com/1/account/verify_credentials.%@", format];
	OAMutableURLRequest *oauthRequest = [[[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:authorizeUrl]
                                                                         consumer:self.twitterEngine.consumer
                                                                            token:self.twitterEngine.accessToken   
                                                                            realm:@"http://api.twitter.com/"
                                                                signatureProvider:nil] autorelease];
    
    
	NSString *oauthHeader = [oauthRequest authorizationString];
    
	TTDPRINT(@"OAuth header : %@\n\n", oauthHeader);
    
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
	request.requestMethod = @"POST";
	request.shouldAttemptPersistentConnection = NO;	
    
	[request addRequestHeader:@"X-Auth-Service-Provider" value:authorizeUrl]; 
	[request addRequestHeader:@"X-Verify-Credentials-Authorization" value:oauthHeader];
    
	return request;
}

-(void)postToTwitPic
{
    NSString *url = @"http://api.twitpic.com/2/upload.json";
	self.request = [self createOAuthEchoRequest:url format:@"json"];
    
	NSData *imageRepresentation = UIImageJPEGRepresentation(self.twitterPost.image, 1.0);
	[self.request setData:imageRepresentation forKey:@"media"];
	[self.request setPostValue:self.twitterPost.text  forKey:@"message"];
	[self.request setPostValue:kTwitPicAPIKey  forKey:@"key"];
    
	[self.request setDelegate:self];
	[self.request setDidFinishSelector:@selector(twitPicRequestFinished:)];
	[self.request setDidFailSelector:@selector(requestFailedAS:)];	
	[self.request startAsynchronous];
}

- (NSString *)extractUploadURL:(NSString *)body
{
    NSString *key = @"url";
    NSArray					*array = [body componentsSeparatedByString: @","];
    if (array.count < 1) return nil;
    
    for (NSString *keyValue in array) {
        NSArray *keyValueArray = [keyValue componentsSeparatedByString: @"\":"];
        
        if (keyValueArray.count == 2) {
            NSString				*aKey = [keyValueArray objectAtIndex: 0];
            NSString				*value = [keyValueArray objectAtIndex: 1];
            
            aKey = [aKey substringWithRange:NSMakeRange(1, aKey.length - 1)];
            value = [value substringWithRange:NSMakeRange(1, value.length - 2)];		   
            TTDPRINT(@"key:%@, value:%@",aKey, value);
            if ([aKey isEqualToString:key]) {
                value = [value stringByReplacingOccurrencesOfString:@"\\" withString:@""];
                value = [value stringByReplacingOccurrencesOfString:@"}" withString:@""];
                value = [value stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                return value;
            }
        }
    }
    return nil;
}

// INFO:TwitPicへの投稿が失敗した場合
- (void)requestFailedAS:(ASIHTTPRequest *)request
{
    if (self.delegate) {
        [self.delegate performSelector:@selector( didXAuthTwitterPostFailed) withObject:nil afterDelay:0.1];
    }
}

- (void)twitPicRequestFinished:(ASIHTTPRequest *)request
{
	NSString *responseString = [request responseString];    
	NSString *url = [self extractUploadURL:responseString];
    
	if (!url) {
		[self requestFailedAS:request];
		return;
	}
    
    //140文字以内に切り捨て
    NSInteger maxLength = 140 - url.length - 1;
    NSString* realMessage = maxLength < self.twitterPost.text.length ? [self.twitterPost.text substringToIndex:maxLength -1] : self.twitterPost.text;
    
    NSString* postMessage = [NSString stringWithFormat:@"%@ %@", realMessage, url];
    
    if( CLLocationCoordinate2DIsInvalid(self.twitterPost.coordinate)) {
        [self.twitterEngine sendUpdate:postMessage];
    }
    else {
        [self.twitterEngine sendUpdate:postMessage latitude:self.twitterPost.coordinate.latitude longitude:self.twitterPost.coordinate.longitude];
    }
    
}


@end






