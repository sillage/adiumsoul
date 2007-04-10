//
//  QTSoundFilePlayer.h
//  PlayBufferedSoundFile
//
/*
 Copyright (c) 2002-2003, Kurt Revis.  All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the name of Snoize nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*!
 * @class QTSoundFilePlayer
 * @brief Sound playing with volume control and output device selection
 * 
 * QTSoundFilePlayer takes a path to an audio file, and plays it through the desired audio output.  It uses QuickTime to decode the file, but plays the samples using CoreAudio. It also uses a buffering scheme to avoid dropouts in the audio playback.
*/

#import <Foundation/Foundation.h>
#import <AudioUnit/AudioUnit.h>
#import <QuickTime/QuickTime.h>
#import <mach/mach.h>


@class VirtualRingBuffer;

@interface QTSoundFilePlayer : NSObject
{
    NSString *fileName;
	
    Movie movie;
    Media media;
	
    TimeValue mediaDuration;	// in arbitrary 'units'
    TimeScale mediaTimeScale;	// units per second
    TimeValue currentMediaTime;	// in 'units'
    NSLock *mediaTimeLock;
	
    SoundConverter soundConverter;
    SoundConverterFillBufferDataUPP soundConverterBufferFillerUPP;
    ExtendedSoundComponentData converterSourceSoundComponentData;
    BOOL isSourceVBR;
    Handle converterSourceSampleDataHandle;
	
    AudioUnit outputAudioUnit;
    
    VirtualRingBuffer *ringBuffer;
    int playbackStatus;
    semaphore_t semaphore;
	
    NSPort *signalFinishPort;
    NSPortMessage *signalFinishPortMessage;
    NSArray *signalFinishRunLoopModes;
    NSRunLoop *controllingRunLoop;
	
    struct {
        unsigned int shouldLoop:1;
        unsigned int currentMediaTimeWasChanged:1;
        unsigned int isStopping:1;
    } flags;
	
    id nonretainedDelegate;
	
	BOOL	deallocing;
}

// Designated initializer
- (id)initWithContentsOfURL:(NSURL *)url usingSystemAlertDevice:(BOOL)useSystemAlertDevice;
	// Only file URLs are currently supported

- (id)initWithContentsOfFile:(NSString *)path usingSystemAlertDevice:(BOOL)useSystemAlertDevice;

- (BOOL)play;
- (BOOL)pause;
- (BOOL)resume;
- (BOOL)stop;
    // -play, -pause, -resume, and -stop must all be called in the same thread. They will return NO if that is not the case.
    // Normally you should call them from the main thread of your application.
    // The other methods may be called from any thread.

- (BOOL)isPlaying;
- (BOOL)isPaused;

- (id)delegate;
- (void)setDelegate:(id)aDelegate;

- (float)volume;
- (void)setVolume:(float)value;
    // Volume ranges from 0.0 to 1.0

- (BOOL)shouldLoop;
- (void)setShouldLoop:(BOOL)value;

- (float)duration;
- (float)playbackPosition;
- (void)setPlaybackPosition:(float)value;
    // in seconds

@end


@interface NSObject (QTSoundFilePlayerDelegateMethods)

// The QTSoundFilePlayer's delegate may implement any of these methods. None of them are required.

- (void)qtSoundFilePlayer:(QTSoundFilePlayer *)player didFinishPlaying:(BOOL)aBool;
				  // NOTE: This method will always be called in the same thread that called -play.
				  // didFinishPlaying: will be YES if the sound was played all the way to the end.

- (void)qtSoundFilePlayer:(QTSoundFilePlayer *)aPlayer didPlayAudioBuffer:(AudioBuffer *)buffer;
				  // NOTE: This method will be called in CoreAudio's high-priority time-constraint thread.
				  // It is very important that it return quickly, and that it doesn't do anything that could
				  // potentially block (like allocating memory, locking a lock, writing to a file, etc.).
				  // Check the archives of the CoreAudio-API mailing list at www.lists.apple.com for more information.

@end
