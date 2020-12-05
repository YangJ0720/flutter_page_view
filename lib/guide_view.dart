import 'dart:async';

import 'package:flutter/material.dart';

/// 带视差轮播效果的轮播图组件
class GuideView extends StatefulWidget {
  final List<String> list;
  final double height;

  const GuideView(this.list, this.height);

  @override
  State<StatefulWidget> createState() {
    return _GuideViewState();
  }
}

class _GuideViewState extends State<GuideView> {
  final double _scaleValue = 0.9;

  // 视差轮播的纵向位移距离
  double _scaleHeight;
  PageController _pageController;
  StreamController<_ScaleItem> _streamController;

  /// 创建轮播页面
  Widget _createItemView(int index, _ScaleItem item) {
    var scale = _scaleValue;
    var translation = _scaleHeight;
    if (index == item.index) {
      // 如果是当前选中的轮播页面
      if (item.scale == 0) {
        scale = 1.0;
        translation = 0.0;
      } else {
        scale = 1 - item.scale * (1 - _scaleValue);
        translation = _scaleHeight * item.scale;
      }
    } else if (index == item.index - 1 || index == item.index + 1) {
      // 如果是当前选中的轮播页面的上一页 or 下一页
      if (item.scale == 0) {
        scale = _scaleValue;
        translation = _scaleHeight;
      } else {
        scale = _scaleValue + item.scale * (1 - _scaleValue);
        translation = _scaleHeight * (1 - item.scale);
      }
    }
    var matrix = Matrix4.diagonal3Values(1.0, scale, 1.0);
    matrix.setTranslationRaw(0, translation, 0);
    return Padding(
      child: Transform(
        transform: matrix,
        child: Image.asset(widget.list[index], fit: BoxFit.fill),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20),
    );
  }

  @override
  void initState() {
    super.initState();
    // 计算视差轮播的纵向位移距离
    _scaleHeight = (1 - _scaleValue) * widget.height / 2;
    _pageController = PageController(viewportFraction: 0.8);
    _pageController.addListener(() {
      var page = _pageController.page;
      _streamController.sink.add(_ScaleItem(page.floor(), page - page.floor()));
    });
    _streamController = StreamController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pageController = null;
    _streamController.close();
    _streamController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          children: [
            // 视差轮播组件
            SizedBox(
              child: StreamBuilder<_ScaleItem>(
                builder: (_, snapshot) {
                  var item = snapshot.data ?? _ScaleItem(0, 0);
                  return PageView.builder(
                    controller: _pageController,
                    itemBuilder: (_, index) {
                      return _createItemView(index, item);
                    },
                    itemCount: widget.list.length,
                  );
                },
                stream: _streamController.stream,
              ),
              height: widget.height,
            ),
            // 关闭
            Container(
              child: InkWell(
                child: Icon(Icons.close, color: Colors.white),
                onTap: () => Navigator.pop(context),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Color(0x80000000),
              ),
              margin: EdgeInsets.only(top: 20),
              padding: EdgeInsets.all(5),
            ),
          ],
          mainAxisSize: MainAxisSize.min,
        ),
      ),
      type: MaterialType.transparency,
    );
  }
}

class _ScaleItem {
  final int index;
  final double scale;

  _ScaleItem(this.index, this.scale);
}
