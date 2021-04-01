# Import Statement:	import QtMultimedia 5.13
# Detailed Description
- You can use MediaPlayer by itself to play audio content (like Audio)
- you can use it in conjunction with a `VideoOutput` for rendering video
```javascript
    Text {
        text: "Click Me!";
        font.pointSize: 24;
        width: 150; height: 50;

        MediaPlayer {
            id: playMusic
            source: "music.wav"
        }
        MouseArea {
            id: playArea
            anchors.fill: parent
            onPressed:  { playMusic.play() }
        }
    }
```
```javascript
    Item {
        MediaPlayer {
            id: mediaplayer
            source: "groovy_video.mp4"
        }

        VideoOutput {
            anchors.fill: parent
            source: mediaplayer
        }

        MouseArea {
            id: playArea
            anchors.fill: parent
            onPressed: mediaplayer.play();
        }
    }
```
- See also VideoOutput.

# Property Documentation
1. **`audioRole : enumeration`**
- the role of the audio stream
- 设置播放音频的类型，从而使系统可以在音量，路由或后处理方面设置
- must be set before setting the source property.
- Supported values can be retrieved with `supportedAudioRoles()`.
The value can be one of:

UnknownRole - the role is unknown or undefined.
MusicRole - music.
VideoRole - soundtrack from a movie or a video.
VoiceCommunicationRole - voice communications, such as telephony.
AlarmRole - alarm.
NotificationRole - notification, such as an incoming e-mail or a chat request.
RingtoneRole - ringtone.
AccessibilityRole - for accessibility, such as with a screen reader.
SonificationRole - sonification, such as with user interface sounds.
GameRole - game audio.
CustomRole - The role is specified by customAudioRole.
customAudioRole is cleared when this property is set to anything other than CustomRole.
- 当此属性设置为`CustomRole`以外的任何东西时，将清除`customAudioRole`。

autoLoad : bool

This property indicates if loading of media should begin immediately.

Defaults to true, if false media will not be loaded until playback is started.


autoPlay : bool

This property controls whether the media will begin to play on start up.

Defaults to false. If set to true, the value of autoLoad will be overwritten to true.


availability : enumeration

Returns the availability state of the media player.

This is one of:

Value	Description
Available	The media player is available to use.
Busy	The media player is usually available, but some other process is utilizing the hardware necessary to play media.
Unavailable	There are no supported media playback facilities.
ResourceMissing	There is one or more resources missing, so the media player cannot be used. It may be possible to try again at a later time.

bufferProgress : real

This property holds how much of the data buffer is currently filled, from 0.0 (empty) to 1.0 (full).

Playback can start or resume only when the buffer is entirely filled, in which case the status is MediaPlayer.Buffered or MediaPlayer.Buffering. A value lower than 1.0 implies that the status is MediaPlayer.Stalled.

See also status.


customAudioRole : string

This property holds the role of the audio stream when the backend supports audio roles unknown to Qt. It can be set to specify the type of audio being played, allowing the system to make appropriate decisions when it comes to volume, routing or post-processing.

The audio role must be set before setting the source property.

audioRole is set to CustomRole when this property is set.

This property was introduced in Qt 5.11.


duration : int

This property holds the duration of the media in milliseconds.

If the media doesn't have a fixed duration (a live stream for example) this will be 0.


error : enumeration

This property holds the error state of the audio. It can be one of:

Value	Description
NoError	There is no current error.
ResourceError	The audio cannot be played due to a problem allocating resources.
FormatError	The audio format is not supported.
NetworkError	The audio cannot be played due to network issues.
AccessDenied	The audio cannot be played due to insufficient permissions.
ServiceMissing	The audio cannot be played because the media service could not be instantiated.

errorString : string

This property holds a string describing the current error condition in more detail.


hasAudio : bool

This property holds whether the media contains audio.


hasVideo : bool

This property holds whether the media contains video.


loops : int

This property holds the number of times the media is played. A value of 0 or 1 means the media will be played only once; set to MediaPlayer.Infinite to enable infinite looping.

The value can be changed while the media is playing, in which case it will update the remaining loops to the new value.

The default is 1.


mediaObject : variant

This property holds the native media object.

It can be used to get a pointer to a QMediaPlayer object in order to integrate with C++ code.


  QObject *qmlMediaPlayer; // The QML MediaPlayer object
  QMediaPlayer *player = qvariant_cast<QMediaPlayer *>(qmlMediaPlayer->property("mediaObject"));

Note: This property is not accessible from QML.


metaData group

metaData.title : variant

metaData.subTitle : variant

metaData.author : variant

metaData.comment : variant

metaData.description : variant

metaData.category : variant

metaData.genre : variant

metaData.year : variant

metaData.date : variant

metaData.userRating : variant

metaData.keywords : variant

metaData.language : variant

metaData.publisher : variant

metaData.copyright : variant

metaData.parentalRating : variant

metaData.ratingOrganization : variant

metaData.size : variant

metaData.mediaType : variant

metaData.audioBitRate : variant

metaData.audioCodec : variant

metaData.averageLevel : variant

metaData.channelCount : variant

metaData.peakValue : variant

metaData.sampleRate : variant

metaData.albumTitle : variant

metaData.albumArtist : variant

metaData.contributingArtist : variant

metaData.composer : variant

metaData.conductor : variant

metaData.lyrics : variant

metaData.mood : variant

metaData.trackNumber : variant

metaData.trackCount : variant

metaData.coverArtUrlSmall : variant

metaData.coverArtUrlLarge : variant

metaData.resolution : variant

metaData.pixelAspectRatio : variant

metaData.videoFrameRate : variant

metaData.videoBitRate : variant

metaData.videoCodec : variant

metaData.posterUrl : variant

metaData.chapterNumber : variant

metaData.director : variant

metaData.leadPerformer : variant

metaData.writer : variant

These properties hold the meta data for the current media.

metaData.title - the title of the media.
metaData.subTitle - the sub-title of the media.
metaData.author - the author of the media.
metaData.comment - a user comment about the media.
metaData.description - a description of the media.
metaData.category - the category of the media.
metaData.genre - the genre of the media.
metaData.year - the year of release of the media.
metaData.date - the date of the media.
metaData.userRating - a user rating of the media in the range of 0 to 100.
metaData.keywords - a list of keywords describing the media.
metaData.language - the language of the media, as an ISO 639-2 code.
metaData.publisher - the publisher of the media.
metaData.copyright - the media's copyright notice.
metaData.parentalRating - the parental rating of the media.
metaData.ratingOrganization - the name of the rating organization responsible for the parental rating of the media.
metaData.size - the size of the media in bytes.
metaData.mediaType - the type of the media.
metaData.audioBitRate - the bit rate of the media's audio stream in bits per second.
metaData.audioCodec - the encoding of the media audio stream.
metaData.averageLevel - the average volume level of the media.
metaData.channelCount - the number of channels in the media's audio stream.
metaData.peakValue - the peak volume of media's audio stream.
metaData.sampleRate - the sample rate of the media's audio stream in hertz.
metaData.albumTitle - the title of the album the media belongs to.
metaData.albumArtist - the name of the principal artist of the album the media belongs to.
metaData.contributingArtist - the names of artists contributing to the media.
metaData.composer - the composer of the media.
metaData.conductor - the conductor of the media.
metaData.lyrics - the lyrics to the media.
metaData.mood - the mood of the media.
metaData.trackNumber - the track number of the media.
metaData.trackCount - the number of tracks on the album containing the media.
metaData.coverArtUrlSmall - the URL of a small cover art image.
metaData.coverArtUrlLarge - the URL of a large cover art image.
metaData.resolution - the dimension of an image or video.
metaData.pixelAspectRatio - the pixel aspect ratio of an image or video.
metaData.videoFrameRate - the frame rate of the media's video stream.
metaData.videoBitRate - the bit rate of the media's video stream in bits per second.
metaData.videoCodec - the encoding of the media's video stream.
metaData.posterUrl - the URL of a poster image.
metaData.chapterNumber - the chapter number of the media.
metaData.director - the director of the media.
metaData.leadPerformer - the lead performer in the media.
metaData.writer - the writer of the media.
See also QMediaMetaData.


muted : bool

This property holds whether the audio output is muted.

Defaults to false.


notifyInterval : int

The interval at which notifiable properties will update.

The notifiable properties are position and bufferProgress.

The interval is expressed in milliseconds, the default value is 1000.

This property was introduced in Qt 5.9.


playbackRate : real

This property holds the rate at which audio is played at as a multiple of the normal rate.

Defaults to 1.0.


playbackState : enumeration

This property holds the state of media playback. It can be one of:

PlayingState - the media is currently playing.
PausedState - playback of the media has been suspended.
StoppedState - playback of the media is yet to begin.

playlist : Playlist

This property holds the playlist used by the media player.

Setting the playlist property resets the source to an empty string.

This property was introduced in Qt 5.6.


position : int

This property holds the current playback position in milliseconds.

To change this position, use the seek() method.

See also seek().


seekable : bool

This property holds whether position of the audio can be changed.

If true, calling the seek() method will cause playback to seek to the new position.


source : url

This property holds the source URL of the media.

Setting the source property clears the current playlist, if any.


status : enumeration

This property holds the status of media loading. It can be one of:

NoMedia - no media has been set.
Loading - the media is currently being loaded.
Loaded - the media has been loaded.
Buffering - the media is buffering data.
Stalled - playback has been interrupted while the media is buffering data.
Buffered - the media has buffered data.
EndOfMedia - the media has played to the end.
InvalidMedia - the media cannot be played.
UnknownStatus - the status of the media is unknown.

volume : real

This property holds the audio volume of the media player.

The volume is scaled linearly from 0.0 (silence) to 1.0 (full volume). Values outside this range will be clamped.

The default volume is 1.0.

UI volume controls should usually be scaled nonlinearly. For example, using a logarithmic scale will produce linear changes in perceived loudness, which is what a user would normally expect from a volume control. See QtMultimedia.convertVolume() for more details.


Signal Documentation
error(error, errorString)

This signal is emitted when an error has occurred. The errorString parameter may contain more detailed information about the error.

The corresponding handler is onError.

See also QMediaPlayer::Error.


paused()

This signal is emitted when playback is paused.

The corresponding handler is onPaused.


playbackStateChanged()

This signal is emitted when the playbackState property is altered.

The corresponding handler is onPlaybackStateChanged.


playing()

This signal is emitted when playback is started or resumed.

The corresponding handler is onPlaying.


stopped()

This signal is emitted when playback is stopped.

The corresponding handler is onStopped.


Method Documentation
pause()

Pauses playback of the media.

Sets the playbackState property to PausedState.


play()

Starts playback of the media.

Sets the playbackState property to PlayingState.


seek(offset)

If the seekable property is true, seeks the current playback position to offset.

Seeking may be asynchronous, so the position property may not be updated immediately.

See also seekable and position.


stop()

Stops playback of the media.

Sets the playbackState property to StoppedState.


list<int> supportedAudioRoles()

Returns a list of supported audio roles.

If setting the audio role is not supported, an empty list is returned.

This method was introduced in Qt 5.6.

See also audioRole.


© 2019 The Qt Company Ltd. Documentation contributions included herein are the copyrights of their respective owners.
The documentation provided herein is licensed under the terms of the GNU Free Documentation License version 1.3 as published by the Free Software Foundation.
Qt and respective logos are trademarks of The Qt Company Ltd. in Finland and/or other countries worldwide. All other trademarks are property of their respective owners.