# Audio Files Directory

This directory contains audio files for notifications and alerts in the Campass application.

## Required Audio Files

The following MP3 files should be placed in this directory:

1. **sos_alarm.mp3** - Emergency SOS alert sound (5-10 seconds, high priority)
2. **geofence_alert.mp3** - Geofence violation alert sound (2-3 seconds, warning priority)
3. **notification.mp3** - General notification sound (1-2 seconds, standard priority)

## Optional Audio Files

- **pass_approved.mp3** - Confirmation sound for pass approval
- **pass_rejected.mp3** - Alert sound for pass rejection

## Audio Specifications

- **Format**: MP3
- **Bit Rate**: 128-256 kbps
- **Sample Rate**: 44100 Hz or 48000 Hz
- **Channels**: Mono or Stereo
- **File Size**: < 500 KB per file

## Adding Audio Files

1. Obtain or create the required audio files
2. Convert to MP3 format if needed
3. Place files in this directory
4. The AudioAssetManager will automatically load them on app startup

## Sources for Free Audio

- Freesound.org - Search for "emergency alarm", "geofence alert", "notification"
- Zapsplat.com - Free sound effects with attribution
- Notificationsounds.com - Free notification sounds
- Incompetech.com - Royalty-free music and effects (CC0 license)

## References

See `AUDIO_CONFIGURATION.md` in the project root for complete audio setup instructions.
