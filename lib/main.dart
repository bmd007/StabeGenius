import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html_view/flutter_html_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttery_audio/fluttery_audio.dart';
import 'package:http/http.dart' as http;
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:test123/bottom_controls.dart';
import 'package:test123/episodes.dart';
import 'package:test123/theme.dart';
import 'package:test123/seek_bar.dart';
import 'package:webfeed/webfeed.dart';

void main() => runApp(new MyApp());

Future<EpisodePlaylist> populateUi() async{
  http.Response response = await http.get("http://feeds.stableg.com/zigzagpodcast");
  String body = await response.body;
  List feedItems = await new RssFeed.parse(body).items;
  List episodes = await feedItems.map((feed) {
      return Episode(
          audioUrl: feed.enclosure.url,
          title: feed.title,
          albumArtUrl: "https://zigzagpod.com/wp-content/uploads/sites/11/2018/06/ZigZag-Artwork.png",
          description: feed.description);
    }).toList();
    return new EpisodePlaylist(episodes: episodes);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Stable G',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(primarySwatch: Colors.blue),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}
EpisodePlaylist episodeList = new EpisodePlaylist(episodes: []);

class _MyHomePageState extends State<MyHomePage> {
  PanelController pc = new PanelController();
  @override
  Widget build(BuildContext context) {
    if (episodeList.episodes.isEmpty) {
      populateUi().then((list) {
        setState(() {
          episodeList = list;
        });
      });
      return CircularProgressIndicator(); //todo turn into some beautiful zig
      // zag  loading
    } else {
      return buildUI(episodeList, pc);
    }
//    return FutureBuilder(future: populateUi(),
//      builder: (context, snapshot){
//          if(snapshot.connectionState == ConnectionState.done && snapshot.hasData){
//            return buildUI(snapshot.data);
//          }else{
//            return CircularProgressIndicator();
//          }
//      },
//    );
  }
}

buildUI(EpisodePlaylist episodeList, PanelController pc) {
  Widget bottomControls = BottomControls();

  return new AudioPlaylist(
    playlist: episodeList.episodes.map((episode) {
      return episode.audioUrl;
    }).toList(growable: false),
    playbackState: PlaybackState.paused,
    child: new Scaffold(
      drawer: buildDrawer(),
      appBar: new AppBar(
        backgroundColor: accentColor,
        elevation: 0.0,
        title: new Text('ZigZag'),
      ),
      body: new Column(
        children: <Widget>[
          // Seek bar
          new Expanded(
            child: new AudioPlaylistComponent(
              playlistBuilder: (BuildContext context, Playlist playlist, Widget child) {
                String albumArtUrl = episodeList.episodes[playlist.activeIndex].albumArtUrl;
                return new AudioRadialSeekBar(albumArtUrl: albumArtUrl,);
              },
            ),
          ),
          // Song title, artist name, and controls
          new AudioPlaylistComponent(
              playlistBuilder: (BuildContext context, Playlist playlist, Widget child) {
                return SlidingUpPanel(
                  color: accentColor,
                  controller: pc,
                  collapsed: bottomControls,
                  panel: ListView(children: <Widget>[
                  new IconButton(
                  icon: new Icon(Icons.arrow_downward),
                    color: const Color(0xFFDDDDDD),
                    onPressed: () {pc.close();}
                  ),
//                    bottomControls,
                    HtmlView(
                      data: episodeList.episodes[playlist.activeIndex].description,
                      scrollable: false,
                    )
                  ]),
                  minHeight: 200,
                  maxHeight: 400,
                );
              }),
             ],
      ),
    ),
  );
}

buildDrawer(){
  return Drawer(child: ListView(children: <Widget>[
    FlatButton(
      padding: EdgeInsets.all(0),
        onPressed: (){launchURL("https://www.stableg.com/about");},
        child: Image.network(
      'https://images.squarespace-cdn'
        '.com/content/v1/5c92b1817a1fbd4f736a255e/1555970681103-O1PAADOMCNSVQCRJ4RDK/ke17ZwdGBToddI8pDm48kDMCKPUtgBH6VvrO8EwU6dtZw-zPPgdn4jUwVcJE1ZvWQUxwkmyExglNqGp0IvTJZamWLI2zvYWH8K3-s_4yszcp2ryTI0HqTOaaUohrI8PIfFekrTzKa9BP3SZzqJdCR8SqOxTINkHCh5vhvTpoS9Y/SG_anima00%283%29.gif',
      repeat: ImageRepeat.noRepeat,)
  ),
    FlatButton(
        padding: EdgeInsets.all(0),
        onPressed: (){launchURL("https://zigzagpod.com/about");},
  child: Image.network('https://images.squarespace-cdn'
            '.com/content/v1/5c92b1817a1fbd4f736a255e/1555344817661-8C0CQHC7P726OBEB0EDH/ke17ZwdGBToddI8pDm48kLkXF2pIyv_F2eUT9F60jBl7gQa3H78H3Y0txjaiv_0fDoOvxcdMmMKkDsyUqMSsMWxHk725yiiHCCLfrh8O1z4YTzHvnKhyp6Da-NYroOW3ZGjoBKy3azqku80C789l0iyqMbMesKd95J-X4EagrgU9L3Sa3U8cogeb0tjXbfawd0urKshkc5MgdBeJmALQKw/_WP_5004C.jpg',
      repeat: ImageRepeat.noRepeat)
  ),
  ]));
}

Future launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url, forceSafariVC: false, forceWebView: false);
  } else {
    throw 'Could not launch $url';
  }
}
