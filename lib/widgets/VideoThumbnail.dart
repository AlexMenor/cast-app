import 'package:flutter/material.dart';

class VideoThumbnail extends StatelessWidget {
  final String url;
  String imageUrl;
  VideoThumbnail(this.url);

  void _getImageUrl() {
    RegExp regExp = new RegExp(r"\/\/youtu.be\/(.+)");
    if (regExp.hasMatch(url)) {
      final id = regExp.firstMatch(url).group(1);
      imageUrl = "https://img.youtube.com/vi/$id/maxresdefault.jpg";
    }
  }

  @override
  Widget build(BuildContext context) {
    _getImageUrl();
    return Container(
      margin: EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(child: Text('Now Playing')),
          ),
          if (imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
        ],
      ),
    );
  }
}
