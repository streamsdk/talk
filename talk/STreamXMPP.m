

#import "STreamXMPP.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "NSXMLElement+XMPP.h"


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
@synthesize userFriends;

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
    [xmppStream setHostName:@"streamsdk.cn"];
 //   [xmppStream setHostName:@"192.168.1.111"];
    
    [xmppStream setHostPort:5222];
    
}

- (BOOL)connect: (NSString *)userName withPassword:(NSString *)password
{
    [self setXmppStream];
	if (![xmppStream isDisconnected]) {
		return YES;
	}
    
    [myJID appendString:[STreamSession getClientAuthKey]];
    [myJID appendString:userName];
    [myJID appendString:@"@streamsdk.cn"];
    
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

-(void)sendFileInBackground:(NSData *)data toUser:(NSString *)userName finished:(FinishCall)doStaff byteSent:(DelegateCall)call withBodyData:(NSString *)bodyData{
    
    STreamFile *sf = [[STreamFile alloc] init];
   
    [sf postData:data finished:^(NSString *res){
        
        NSMutableString *userJID = [[NSMutableString alloc] init];
        [userJID appendString:[STreamSession getClientAuthKey]];
        [userJID appendString:userName];
        [userJID appendString:@"@streamsdk.cn"];
        
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        if (bodyData)
           [body setStringValue:bodyData];
        else
           [body setStringValue:@"test"];
        
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
    userFriends = [[STreamObject alloc] init];
    NSMutableString *userFriendsId = [[NSMutableString alloc] init];
    [userFriendsId appendString:@"streamsdk.reservedid"];
    [userFriendsId appendString:[STreamSession getClientAuthKey]];
    [userFriendsId appendString:uName];
    [userFriends loadAll:userFriendsId];
    
    [self sendRosterRequest];
    
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

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    NSString *from = [message fromStr];
    NSArray *array = [from componentsSeparatedByString:@"@streamsdk.cn"];
    
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
            [xmppDelegate didReceiveFile:filetransferId withBody:[message body] withFrom:fromID];
        }else{
            [xmppDelegate didReceiveMessage:message withFrom:fromID];
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

- (NSArray *)getAllRoster{
    NSArray *friends = [userFriends getAllKeys];
    [friends delete:@"reserved.streamsdktoken"];
    return [userFriends getAllKeys];
}

- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    NSLog(@"I'm in register method");
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement
                                                        *)error{
    NSLog(@"Sorry the registration is failed");
}

- (void)sendRosterRequest{
    
    NSXMLElement *queryElement = [NSXMLElement elementWithName: @"query" xmlns: @"jabber:iq:roster"];
    NSXMLElement *iqStanza = [NSXMLElement elementWithName: @"iq"];
    [iqStanza addAttributeWithName: @"from" stringValue:myJID];
    [iqStanza addAttributeWithName: @"id" stringValue:[[xmppStream myJID] resource]];
    [iqStanza addAttributeWithName: @"type" stringValue: @"get"];
    [iqStanza addChild: queryElement];
    [xmppStream sendElement: iqStanza];
    
}

- (void)acceptRosterRequest:(XMPPPresence *)presence{
    [self sendSubscribed:presence];
    [self sendSubscribe:[presence fromStr]];
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	NSXMLElement *queryElement = [iq elementForName: @"query" xmlns: @"jabber:iq:roster"];
    
    if (queryElement) {
        NSArray *itemElements = [queryElement elementsForName: @"item"];
        NSMutableArray *jids = [[NSMutableArray alloc] init];
        for (int i=0; i<[itemElements count]; i++) {
            NSString *jid=[[[itemElements objectAtIndex:i] attributeForName:@"jid"] stringValue];
            [jids addObject:jid];
            NSLog(@"%@", jid);
        }
        //there might be a problem here with multiple sent. Needs future check
        NSArray *friends = [userFriends getAllKeys];
        for (NSString *f in friends){
            if (![jids containsObject:f] && ![f isEqualToString:@"reserved.streamsdktoken"]){
                [self sendSubscribe:f];
            }
        }
        
    }
	return NO;
}

- (void)sendMessage:(NSString *)toUser withMessage:(NSString *)message{
    
    NSMutableString *userJID = [[NSMutableString alloc] init];
    [userJID appendString:[STreamSession getClientAuthKey]];
    [userJID appendString:toUser];
    [userJID appendString:@"@streamsdk.cn"];
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:message];
    
    NSXMLElement *m = [NSXMLElement elementWithName:@"message"];
    [m addAttributeWithName:@"to" stringValue:userJID];
    [m addChild:body];
    [xmppStream sendElement:m];
    
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
    NSString *presenceType = [presence type];
    if([presenceType isEqualToString:@"subscribe"]){
        NSArray *friends = [userFriends getAllKeys];
        if ([friends containsObject:[presence fromStr]]){
            [self sendSubscribed:presence];
            [self sendSubscribe:[presence fromStr]];
        }
        else
            [xmppDelegate didReceivePresence:presence];
    }
    
    [xmppDelegate didReceivePresence:presence];
}

- (void)sendSubscribed:(XMPPPresence *)p{
    
    NSXMLElement *presence = [NSXMLElement elementWithName:@"presence"];
    [presence addAttributeWithName:@"type" stringValue:@"subscribed"];
    [presence addAttributeWithName:@"to" stringValue:[p fromStr]];
    [presence addAttributeWithName:@"from" stringValue:myJID];
    [[self xmppStream] sendElement:presence];
    [self createRosterEntryIfNeeded:[p fromStr]];
    
}

- (void)createRosterEntryIfNeeded: (NSString *)friendId{
    
    if (userFriends){
        NSArray *keys = [userFriends getAllKeys];
        if (![keys containsObject:friendId]){
            [userFriends addStaff:friendId withObject:@"dummy"];
            [userFriends updateInBackground];
        }
    }
    
}


- (void)sendSubscribe: (NSString *)to{
    
    NSXMLElement *presence = [NSXMLElement elementWithName:@"presence"];
    [presence addAttributeWithName:@"type" stringValue:@"subscribe"];
    [presence addAttributeWithName:@"to" stringValue:to];
    [presence addAttributeWithName:@"from" stringValue:myJID];
    [[self xmppStream] sendElement:presence];
    
}

- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence{
    NSLog(@"");
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