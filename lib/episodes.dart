import 'package:meta/meta.dart';

class EpisodePlaylist {

  List<Episode> episodes;

  EpisodePlaylist({
    @required this.episodes,
  });

}

class Episode {

  final String audioUrl;
  final String albumArtUrl;
  final String title;
  final String description;

  Episode({
    @required this.audioUrl,
    @required this.albumArtUrl,
    @required this.title,
    @required this.description,
  });

}