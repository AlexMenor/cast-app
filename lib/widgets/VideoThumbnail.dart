import 'package:flutter/material.dart';

class VideoThumbnail extends StatelessWidget {
  final String url;
  String imageUrl;
  VideoThumbnail(this.url);

  void _getImageUrl() {
    RegExp ytRegExp = new RegExp(r"youtu.be\/(.+)");
    RegExp twitchRegExp = new RegExp(r"twitch.tv\/([^?]+)");
    if (ytRegExp.hasMatch(url)) {
      final id = ytRegExp.firstMatch(url).group(1);
      imageUrl = "https://img.youtube.com/vi/$id/maxresdefault.jpg";
    } else if (twitchRegExp.hasMatch(url)) {
      final id = twitchRegExp.firstMatch(url).group(1);
      imageUrl =
          "https://static-cdn.jtvnw.net/previews-ttv/live_user_$id-1080x720.jpg";
    }
  }

  @override
  Widget build(BuildContext context) {
    _getImageUrl();
    return Container(
      margin: EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          if (imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                frameBuilder: (context, child, frame, synchronous) {
                  return AnimatedOpacity(
                    child: child,
                    opacity: frame == null ? 0 : 1,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null)
                    return child;
                  else {
                    final value = loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes
                        : null;
                    return Center(
                      child: LinearProgressIndicator(
                        value: value,
                      ),
                    );
                  }
                },
              ),
            ),
          Container(
            width: 0,
            height: 0,
          )
        ],
      ),
    );
  }
}
