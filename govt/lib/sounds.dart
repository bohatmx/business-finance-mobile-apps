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
    audioPlayer.play(kUrl1);
  }

  void initAudioPlayer() {
    audioPlayer = new AudioPlayer();
  }

  static Future play() async {
    await audioPlayer.play(kUrl1);
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
  static const kUrl1 = 'http://www.rxlabz.com/labz/audio.mp3';
  static const kUrl2 = 'http://www.rxlabz.com/labz/audio2.mp3';
}
