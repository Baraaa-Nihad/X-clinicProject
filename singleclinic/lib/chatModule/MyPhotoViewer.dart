import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class MyPhotoViewer extends StatefulWidget {
  final String url;

   MyPhotoViewer(this.url);

 

  @override
  _MyPhotoViewerState createState() => _MyPhotoViewerState();
}

class _MyPhotoViewerState extends State<MyPhotoViewer> {
  @override
  Widget build(BuildContext context) {
    return  PhotoView(imageProvider: CachedNetworkImageProvider(
        widget.url,
     
    ));
  }
}
