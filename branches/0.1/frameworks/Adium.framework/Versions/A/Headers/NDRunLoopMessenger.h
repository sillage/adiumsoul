/*!
	@header NDRunLoopMessenger.h
 * @brief Defines the class <tt>NDRunLoopMessenger</tt>
 *
* <tt>NDRunLoopMessenger</tt> provides a light weight version of distributed objects that only works between threads within the same process. With the advent of Mac OS 10.2 the need for this class has decreased with the introduction of the methods <tt>-[NSObject performSelectorOnMainThread:withObject:waitUntilDone:]</tt> and <tt>-[NSObject performSelectorOnMainThread:withObject:waitUntilDone:modes:]</tt> but it is still useful.
	<p>Created by Nathan Day on Fri Feb 08 2002<br>
	Copyright &copy; 2002-2003 Nathan Day. All rights reserved.</p>
 */

/*!
	@const kSendMessageException
 * @brief <tt>NDRunLoopMessenger</tt> exception
 *
* An exception that can be thrown when sending a message by means of <tt>NDRunLoopMessenger</tt>. This includes any messages forwarded by the proxy returned from the methods <tt>target:</tt> and <tt>target:withResult:</tt>.
 */
extern NSString		* kSendMessageException;

/*!
 	@const kConnectionDoesNotExistsException
 * @brief <tt>NDRunLoopMessenger</tt> exception
 *
* An exception that can be thrown when sending a message by means of <tt>NDRunLoopMessenger</tt>. This includes any messages forwarded by the proxy returned from the methods <tt>target:</tt> and <tt>target:withResult:</tt>.
  */
extern NSString		* kConnectionDoesNotExistsException;

/*!
	@class NDRunLoopMessenger
 * @brief Class to provide thread intercommunication
 *
* A light weight version of distributed objects that only works between threads within the same process. <tt>NDRunLoopMessenger</tt> works by only passing the address of a <tt>NSInvocation</tt>  object through a run loop port, this is all that is needed since the object is already within the same process memory space. This means that all the parameters do not need to be serialized. Results are returned simply by waiting on a lock for a message result to be put into the <tt>NSInvocation</tt>.
 */
@interface NDRunLoopMessenger : NSObject
{
@private
	NSPort			* port;
	NSMutableArray  * queuedPortMessageArray;
	NSTimer			* queuedPortMessageTimer;
	NSRunLoop		* targetRunLoop;
	BOOL			insideMessageInvocation;
	
	NSTimeInterval  messageRetryTimeout;
	NSTimeInterval  messageRetry;
}

/*!
 runLoopMessengerForThread:
 * @brief Get the <tt>NDRunLoopMessenger</tt> for a thread.
 *
* If the thread does not have a <tt>NDRunLoopMessenger</tt> then nil is returned.
	@param thread The thread. 
 * @return The <tt>NDRunLoopMessenger</tt>
  */
+ (NDRunLoopMessenger *)runLoopMessengerForThread:(NSThread *)thread;
/*!
 runLoopMessengerForCurrentRunLoop
 * @brief Returns the <tt>NDRunLoopMessenger</tt> for the current run loop.
 *
* If a <tt>NDRunLoopMessenger</tt> has been created for the current run loop then <tt>runLoopMessengerForCurrentRunLoop</tt> will return it otherwise it will create one.
 * @return A <tt>NDRunLoopMessenger</tt> object.
  */
+ (id)runLoopMessengerForCurrentRunLoop;

/*!
 target:performSelector:
 * @brief Perform a selector.
 *
* Send a message to the suplied target without waiting for the message to be processed.
	@param target The target object.
	@param selector The message selector.
   */
- (void)target:(id)target performSelector:(SEL)selector;

/*!
 target:performSelector:withObject:
 * @brief Perform a selector.
 *
* Send a message with one object paramter to the suplied target without waiting for the message to be processed.
	@param target The target object.
	@param selector The message selector.
	@param object An object to be passed with the message.
   */
- (void)target:(id)target performSelector:(SEL)selector withObject:(id)object;

/*!
 target:performSelector:withObject:withObject:
 * @brief Perform a selector.
 *
* Send a message with two object paramters to the suplied target without waiting for the message to be processed.
	@param target The target object.
	@param selector The message selector.
	@param object The first object to be passed with the message.
	@param anotherObject The second object to be passed with the message.
   */
- (void)target:(id)target performSelector:(SEL)selector withObject:(id)object withObject:(id)anotherObject;

- (void)target:(id)aTarget performSelector:(SEL)aSelector withObject:(id)anObject withObject:(id)anotherObject withObject:(id)aThirdObject;

- (void)target:(id)aTarget performSelector:(SEL)aSelector withObject:(id)anObject withObject:(id)anotherObject withObject:(id)aThirdObject withObject:(id)aFourthObject;

- (void)target:(id)aTarget performSelector:(SEL)aSelector withObject:(id)anObject withObject:(id)anotherObject withObject:(id)aThirdObject withObject:(id)aFourthObject withObject:(id)aFifthObject;
	/*!
 target:performSelector:withResult:
 * @brief Perform a selector.
 *
* Send a message to the suplied target, the result can be waited for.
	@param target The target object.
	@param selector The message selector.
	@param resultFlag Should the result be waited for and returned.
 * @return The message result if <tt>resultFlag</tt> is <tt>YES</tt>.
   */
- (id)target:(id)target performSelector:(SEL)selector withResult:(BOOL)resultFlag;

/*!
 target:performSelector:withObject:withResult:
 * @brief Perform a selector.
 *
* Send a message with one object paramter to the suplied target, the result can be waited for.
	@param target The target object.
	@param selector The message selector.
	@param object An object to be passed with the message.
	@param resultFlag Should the result be waited for and returned.
 * @return The message result if <tt>resultFlag</tt> is <tt>YES</tt>.
   */
- (id)target:(id)target performSelector:(SEL)selector withObject:(id)object withResult:(BOOL)resultFlag;

/*!
 target:performSelector:withObject:withObject:withResult:
 * @brief Perform a selector.
 *
* Send a message with two object paramters to the suplied target, the result can be waited for.
	@param target The target object.
	@param selector The message selector.
	@param object The first object to be passed with the message.
	@param anotherObject The second object to be passed with the message.
	@param resultFlag Should the result be waited for and returned.
 * @return The message result if <tt>resultFlag</tt> is <tt>YES</tt>.
   */
- (id)target:(id)target performSelector:(SEL)selector withObject:(id)object withObject:(id)anotherObject withResult:(BOOL)resultFlag;

- (id)target:(id)aTarget performSelector:(SEL)aSelector withObject:(id)anObject withObject:(id)anotherObject withObject:(id)aThirdObject withResult:(BOOL)aFlag;

- (id)target:(id)aTarget performSelector:(SEL)aSelector withObject:(id)anObject withObject:(id)anotherObject withObject:(id)aThirdObject withObject:(id)aFourthObject withResult:(BOOL)aFlag;

- (id)target:(id)aTarget performSelector:(SEL)aSelector withObject:(id)anObject withObject:(id)anotherObject withObject:(id)aThirdObject withObject:(id)aFourthObject withObject:(id)aFifthObject withResult:(BOOL)aFlag;
	
/*!
 postNotification:
 * @brief Post a notification.
 *
* Posts the supplied <tt>NSNotification</tt> object within the receivers run loop.
	@param notification A <tt>NSNotification</tt> object to be posted.
   */
- (void)postNotification:(NSNotification *)notification;

/*!
 postNotificationName:object:
 * @brief Post a notification.
 *
* Posts the notification of a supplied name and object within the receivers run loop. See <tt>NSNotification</tt> documentation to get mor information about the parameters.
	@param notificationName The notification name.
	@param object The object to be posted with the notification.
   */
- (void)postNotificationName:(NSString *)notificationName object:(id)object;

/*!
 postNotificationName:object:userInfo:
 * @brief Post a notification.
 *
* Posts the notification of a supplied name, object and uder info within the receivers run loop. See <tt>NSNotification</tt> documentation to get mor information about the parameters.
	@param notificationName The notification name.
	@param object The object to be posted with the notification.
	@param userInfo A <tt>NSDictionary</tt> of user info.
   */
- (void)postNotificationName:(NSString *)notificationName object:(id)object userInfo:(NSDictionary *)userInfo;

/*!
 messageInvocation:withResult:
 * @brief Invoke and invocation.
 *
* Invokes the passed in <tt>NSInvocation</tt> within the receivers run loop.
	@param invocation The <tt>NSInvocation</tt>
	@param resultFlag Should the result be waited for and returned.
 * @return The invocation result if <tt>resultFlag</tt> is <tt>YES</tt>.
   */
- (void)messageInvocation:(NSInvocation *)invocation withResult:(BOOL)resultFlag;

/*!
 target:
 * @brief Get a target proxy.
 *
* Returns a object that acts as a proxy, forwarding all messages it receives to the supplied target. All messages sent to the target return immediately without waiting for the result.
	@param target The target object.
 * @return The proxy object.
   */
- (id)target:(id)target;

/*!
 target:withResult:
 * @brief Get a target proxy.
 *
* Returns a object that acts as a proxy, forwarding all messages it receives to the supplied target.
	@param target The target object.
	@param resultFlag Should all results be waited for and returned.
 * @return The proxy object.
   */
- (id)target:(id)target withResult:(BOOL)resultFlag;

- (id)targetFromNoRunLoop:(id)aTarget;

- (void)setMessageRetryTimeout:(NSTimeInterval)inMessageRetryTimeout;
- (void)setMessageRetry:(NSTimeInterval)inMessageRetry;

- (NSRunLoop *)targetRunLoop;

@end
