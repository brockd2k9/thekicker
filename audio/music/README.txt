Music cues (AudioManager, scripts/autoload/audio_manager.gd). One file per cue,
named after the cue, .ogg (best: loops cleanly), .mp3 or .wav:

  menu.ogg              loop      main menu and the other menus
  training.ogg          loop      Career Hub and the week's screens
  hs_game.ogg           loop      high school game
  college_game.ogg      loop      college / junior college game
  pro_game.ogg          loop      pro game
  playoffs.ogg          loop      any postseason game
  clutch_kick.ogg       loop      game-winning / tying kick
  benched.ogg           loop      a game you watch from the bench
  draft_day.ogg         loop      Draft Day
  championship_win.ogg  one-shot won title game or bowl, then back to the music
  win.ogg               one-shot final whistle, a win
  loss.ogg              one-shot final whistle, a loss
  season_end.ogg        one-shot Season Summary

Optional clutch-kick stems (play in sync with clutch_kick.ogg):
  clutch_kick_drums.ogg  clutch_kick_bass.ogg  clutch_kick_lead.ogg  clutch_kick_choir.ogg

A missing file is fine: a warning is logged and the current music keeps playing.
