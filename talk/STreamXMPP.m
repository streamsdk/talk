

#import "STreamXMPP.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "NSXMLElement+XMPP.h"
#import <arcstreamsdk/JSONKit.h>

#import "GCDAsyncSocket.h"
#import "XMPP.h"
#import "XMPPReconnect.h"
#import <CommonCrypto/CommonDigest.h>
#import <arcstreamsdk/STreamFile.h>
#import <arcstreamsdk/STreamSession.h>

#import <CFNetwork/CFNetwork.h>

#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

DelegateCall callMethod;
FinishCall finishCall;

@implementation STreamXMPP


@synthesize xmppStream;
@synthesize xmppDelegate;


BOOL allowSelfSignedCertificates = YES;
BOOL allowSSLHostNameMismatch = NO;
BOOL isXmppConnected;
NSString *myPassword = @"";
NSString *uName = @"";
NSMutableString *myJID;
static XMPPReconnect *xmppReconnect;

+ (STreamXMPP *)sharedObject{
    
    static STreamXMPP *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        sharedInstance = [[STreamXMPP alloc] init];
        myJID = [[NSMutableString alloc] init];
    });
    
    return sharedInstance;
}

- (void)setXmppStream{
    xmppStream = [[XMPPStream alloc] init];
    xmppReconnect = [[XMPPReconnect alloc] init];
    [xmppReconnect activate:xmppStream];
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppStream setHostName:@"streamsdk.com"];
    //xmppStream.enableBackgroundingOnSocket = YES;
    //[xmppStream setHostName:@"192.168.1.15"];
    
    [xmppStream setHostPort:5222];
    
}

- (BOOL)connect: (NSString *)userName withPassword:(NSString *)password
{
    [self setXmppStream];
	/*if (![xmppStream isDisconnected]) {
		return YES;
	}*/
    
    myJID = [[NSMutableString alloc] init];
    [myJID appendString:[STreamSession getClientAuthKey]];
    [myJID appendString:userName];
    [myJID appendString:@"@streamsdk.com"];
    
	myPassword = password;
    uName = userName;
    
	if (myJID == nil || myPassword == nil) {
		return NO;
	}
    
	[xmppStream setMyJID:[XMPPJID jidWithString:myJID]];
	
	NSError *error = nil;
  	if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
	{
        DDLogError(@"Error connecting: %@", error);
        return NO;
	}
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        
    });
    
	return YES;
}

- (void)disconnect
{
	[self goOffline];
    [xmppStream disconnect];
}

- (BOOL)connected{
    BOOL isConnected = [xmppStream isAuthenticated];
    return isConnected;
}

- (void)goOnline
{
	XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
	[xmppStream sendElement:presence];
}

- (void)goOffline
{
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
	[xmppStream sendElement:presence];
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	isXmppConnected = YES;
	
	NSError *error = nil;
    
   // NSString *p = [self md5:myPassword];
	
	if (![xmppStream authenticateWithPassword:myPassword error:&error])
	{
		DDLogError(@"Error authenticating: %@", error);
	}
    
}

-(void)sendFileInBackground:(NSData *)data toUser:(NSString *)userName finished:(FinishCall)doStaff byteSent:(DelegateCall)call withBodyData:(NSMutableDictionary *)bodyData{
    
    STreamFile *sf = [[STreamFile alloc] init];
   
    [sf postData:data finished:^(NSString *res){
        
        NSMutableString *userJID = [[NSMutableString alloc] init];
        [userJID appendString:[STreamSession getClientAuthKey]];
        [userJID appendString:userName];
        [userJID appendString:@"@streamsdk.com"];
        
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        
        //new media message format
        [bodyData setObject:[sf fileId] forKey:@"fileId"];
        NSString *bodyJsonData = [bodyData JSONString];
        [body setStringValue:bodyJsonData];
        
        NSXMLElement *properties = [NSXMLElement elementWithName:@"properties"];
        NSXMLElement *property = [NSXMLElement elementWithName:@"property"];
        
        NSXMLElement *name = [NSXMLElement elementWithName:@"name"];
        [name setStringValue:@"streamsdk.filetransfer"];
        NSXMLElement *value = [NSXMLElement elementWithName:@"value"];
        [value addAttribute:[NSXMLNode attributeWithName:@"type" stringValue:@"string"]];
        [value setStringValue:[sf fileId]];
        [property addChild:name];
        [property addChild:value];
        [properties addChild:property];
        
         NSXMLElement *m = [NSXMLElement elementWithName:@"message"];
        [m addAttributeWithName:@"to" stringValue:userJID];
        [m addAttributeWithName:@"id" stringValue:@"1111111"];
        [m addAttributeWithName:@"xmlns" stringValue:@"jabber:client"];
        [m addChild:body];
        [m addChild:properties];
        [xmppStream sendElement:m];
        doStaff(res);
    
        
    }byteSent:^(float bytes){
        call(bytes);
    }];
    
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	[self goOnline];
    [xmppDelegate didAuthenticate];
    
}

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    [xmppDelegate didNotAuthenticate:error];
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
    [xmppDelegate didReceivePresence:presence];
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    
    NSString *from = [message fromStr];
    NSArray *array = [from componentsSeparatedByString:@"@streamsdk.com"];
    
    NSString * str = [[STreamSession getClientAuthKey] lowercaseString];
    NSString *fromID = nil;
    if (array && [array count] !=0) {
        array = [[array objectAtIndex:0] componentsSeparatedByString:str];
        if (array && [array count] !=0) {
            fromID = [array objectAtIndex:1];
        }
    }
 	if ([message isMessageWithBody])
	{
		
        NSString *messageBody = [message body];
        NSData *jsonData = [messageBody dataUsingEncoding:NSUTF8StringEncoding];
        JSONDecoder *decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
        NSDictionary *json = [decoder objectWithData:jsonData];
        NSString *type = [json objectForKey:@"type"];
        NSString *chatId = [json objectForKey:@"id"];
        if ([type isEqualToString:@"ack"]){
            NSLog(@"ack received");
            return;
        }
        NSMutableDictionary *ack = [[NSMutableDictionary alloc] init];
        [ack setObject:@"ack" forKey:@"type"];
        [ack setObject:chatId forKey:@"id"];
        NSString *messageSent = [ack JSONString];
        [self sendMessage:fromID withMessage:messageSent];
        
        
        NSString *filetransferId = @"";
        DDXMLElement *pro = [message elementForName:@"properties"];
        if (pro){
            DDXMLElement *p = [pro elementForName:@"property"];
            if (p){
                NSString *name = [[p elementForName:@"name"] stringValue];
                if (name && [name isEqualToString:@"streamsdk.filetransfer"]){
                    filetransferId = [[p elementForName:@"value"] stringValue];
                }
            }
        }
        
        if (filetransferId && ![filetransferId isEqualToString:@""]){
            [xmppDelegate didReceiveFile:filetransferId withBody:messageBody withFrom:fromID];
        }else{
            NSString *receivedMessage = [json objectForKey:@"message"];
            [xmppDelegate didReceiveMessage:receivedMessage withFrom:fromID];
        }
    }
}


- (NSString *) md5:(NSString *) input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
    
}


- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    NSLog(@"I'm in register method");
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement
                                                        *)error{
    NSLog(@"Sorry the registration is failed");
}


- (void)sendMessage:(NSString *)toUser withMessage:(NSString *)message{
    
    NSMutableString *userJID = [[NSMutableString alloc] init];
    [userJID appendString:[STreamSession getClientAuthKey]];
    [userJID appendString:toUser];
    [userJID appendString:@"@streamsdk.com"];
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:message];
    
    NSXMLElement *m = [NSXMLElement elementWithName:@"message"];
    [m addAttributeWithName:@"to" stringValue:userJID];
    [m addChild:body];
    [xmppStream sendElement:m];
    
}


- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings{
    
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    BOOL allowSelfSignedCertificates = YES;
    BOOL	allowSSLHostNameMismatch = NO;
 	
	if (allowSelfSignedCertificates)
	{
		[settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
	}
	
	if (allowSSLHostNameMismatch)
	{
		[settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
	}
	else
	{
        
		NSString *expectedCertName = nil;
		NSString *serverDomain = xmppStream.hostName;
		expectedCertName = serverDomain;
		if (expectedCertName)
		{
			[settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
		}
    }
}

@end
