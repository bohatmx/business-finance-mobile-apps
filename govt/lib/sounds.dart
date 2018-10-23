import 'package:audioplayer2/audioplayer2.dart';

class Sounds {
  /*
  # To add assets to your application, add an assets section, like this:
  assets:
       - assets/fincash.jpg
       - assets/fin3.jpeg
       - assets/sms1.mp3
       - assets/sms2.mp3
       - assets/sms3.mp3
       - assets/sms4.mp3
       - assets/chime.mp3
   */

  static AudioPlayer audioPlayer = new AudioPlayer();

//  static playSound1() {
//    player.play('sms1.mp3');
//  }
//
//  static playSound2() {
//    player.play('sms2.mp3');
//  }
//
//  static playSound3() {
//    player.play('sms3.mp3');
//  }
//
//  static playSound4() {
//    player.play('sms4.mp3');
//  }

  static playChime() {
    print('Sounds.playChime ###################');
    audioPlayer.play(chime);
  }

  void initAudioPlayer() {
    audioPlayer = new AudioPlayer();
  }

  static Future play() async {
    await audioPlayer.play(chime);
  }

  static Future pause() async {
    await audioPlayer.pause();
  }

  static Future stop() async {
    await audioPlayer.stop();
  }

  static Future mute(bool muted) async {
    await audioPlayer.mute(muted);
  }

  void onComplete() {}
  static const chime =
      'https://firebasestorage.googleapis.com/v0/b/business-finance-dev.appspot.com/o/audio%2Fchime.mp3?alt=media&token=f026808b-31c6-414a-a435-b1929444ca9b';
  static const kUrl2 =
      'https://firebasestorage.googleapis.com/v0/b/business-finance-dev.appspot.com/o/audio%2Fsms1.mp3?alt=media&token=1c8e3df1-15c5-4de7-892b-525f385276bf';
}
