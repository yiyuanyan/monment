import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:io';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:monment/config/service_url.dart';
import 'package:monment/model/ucenter_model.dart';
import 'package:monment/provide/personal_home_provide.dart';
import 'package:monment/provide/ucenter_provide.dart';
import 'package:monment/routers/application.dart';
import 'package:provide/provide.dart';

//随机颜色
Color slRandomColor({int r = 255, int g = 255, int b = 255, a = 255}) {
  if (r == 0 || g == 0 || b == 0) return Colors.black;
  if (a == 0) return Colors.white;
  return Color.fromARGB(
    a,
    r != 255 ? r : Random.secure().nextInt(r),
    g != 255 ? g : Random.secure().nextInt(g),
    b != 255 ? b : Random.secure().nextInt(b),
  );
}

class PersonalHomePage extends StatelessWidget {
  final String userId;
  const PersonalHomePage({Key key, @required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //滚动控制器
    ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      print(scrollController.offset);
      if (scrollController.offset > 110) {
        Provide.value<UcenterProvide>(context).changeOpa(0);
      } else {
        Provide.value<UcenterProvide>(context).changeOpa(1);
      }
    });
    //Tab控制器
    TabController tabController;
    //因为本路由没有使用Scaffold，为了让子级Widget(如Text)使用
    //Material Design 默认的样式风格,我们使用Material作为本路由的根。
    return FutureBuilder(
      future: _getUcenterInfo(context, this.userId),
      builder: (context, snapshot) {
        if (snapshot.data == "OK") {
          return Material(
            child: Provide<UcenterProvide>(
              builder: (context, child, value) {
                return CustomScrollView(
                  controller: scrollController,
                  slivers: <Widget>[
                    //AppBar，包含一个导航栏
                    SliverAppBar(
                      pinned: true,
                      expandedHeight: ScreenUtil().setHeight(223),
                      backgroundColor: Colors.white,
                      elevation: 0,
                      leading: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          Application.router.pop(context);
                        },
                        color: value.opa == 1 ? Colors.white : Colors.black,
                      ),
                      actions: <Widget>[
                        IconButton(
                          icon: Icon(Icons.more_vert),
                          onPressed: () {
                            print("点击了分享按钮");
                          },
                          color: value.opa == 1 ? Colors.white : Colors.black,
                        ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,
                        title: homeTitle(value.opa),
                        background: SliverTopBar(
                          userInfo: value.userInfo,
                        ),
                      ),
                    ),

                    SliverPersistentHeader(
                      //可折叠AppBar底部栏
                      pinned: true, //是否可吸附
                      //自定义代理并且将控制器传入
                      delegate: MySliverPersistentHeaderDelegate(
                          tabController: tabController),
                    ),
                    //内容列表
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return ListItem(
                          index: index, itemInfo: value.userDynamic[index],
                        );
                      }, childCount: value.userDynamic.length),
                    ),
                  ],
                );
              },
            ),
          );
        } else {
          return Container(
            child: Center(
              child: Text(
                "正在加载中.....",
              ),
            ),
          );
        }
      },
    );
  }

  Widget homeTitle(int opa) {
    return Text(
      "Daisy的主页",
      style: TextStyle(
        fontSize: ScreenUtil().setSp(18),
        color: Color.fromRGBO(0, 0, 0, opa == 1 ? 0 : 1),
      ),
    );
  }

  Future<String> _getUcenterInfo(BuildContext context, String user_id) async {
    await Provide.value<UcenterProvide>(context).getUcenter(user_id);
    if (Provide.value<UcenterProvide>(context).code == 200) {
      return "OK";
    } else {
      return "FALSE";
    }
  }
}

//自定义代理Header代理，内附有样式
class MySliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  MySliverPersistentHeaderDelegate({@required this.tabController});
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return HeaderView();
  }

  @override
  double get maxExtent => ScreenUtil().setHeight(48);

  @override
  double get minExtent => ScreenUtil().setHeight(48);

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) =>
      true; // 如果内容需要更新，设置为true
}

//切换按钮视图
class HeaderView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provide<PersonalHomeProvide>(
      builder: (context, child, value) {
        return Material(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Divider(
                height: 1,
                color: Colors.grey[600],
              ),
              Container(
                height: ScreenUtil().setHeight(45),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              print("点击了动态按钮");
                              Provide.value<PersonalHomeProvide>(context)
                                  .changePersonalListTag(1);
                            },
                            child: Container(
                              height: ScreenUtil().setHeight(43),
                              child: Text(
                                "动态",
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(14),
                                  color: value.personalListTag == 1
                                      ? Colors.blueAccent
                                      : Colors.black,
                                ),
                              ),
                              alignment: Alignment.center,
                            ),
                          ),
                          //动态标记线
                          Container(
                            height: ScreenUtil().setHeight(2),
                            width: ScreenUtil().setWidth(20),
                            color: value.personalListTag == 1
                                ? Colors.blueAccent
                                : Colors.white,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              print("点击了动作品钮");
                              Provide.value<PersonalHomeProvide>(context)
                                  .changePersonalListTag(2);
                            },
                            child: Container(
                              height: ScreenUtil().setHeight(43),
                              child: Text(
                                "作品",
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(14),
                                  color: value.personalListTag == 2
                                      ? Colors.blueAccent
                                      : Colors.black,
                                ),
                              ),
                              alignment: Alignment.center,
                            ),
                          ),
                          //动态标记线
                          Container(
                            height: ScreenUtil().setHeight(2),
                            width: ScreenUtil().setWidth(20),
                            color: value.personalListTag == 2
                                ? Colors.blueAccent
                                : Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: Colors.grey[600],
              ),
            ],
          ),
        );
      },
    );
  }
}

//顶部用户信息视图
class SliverTopBar extends StatelessWidget {
  final UserInfo userInfo;
  const SliverTopBar({Key key, @required this.userInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            Image.network(
              fileURL + this.userInfo.backgroundImg,
              fit: BoxFit.fitWidth,
              width: ScreenUtil().setWidth(375),
              height: ScreenUtil().setHeight(151),
            ),
            //个人信息
            Container(
              height: ScreenUtil().setHeight(100),
              padding: EdgeInsets.only(
                  left: ScreenUtil().setHeight(20),
                  right: ScreenUtil().setHeight(20),
                  top: ScreenUtil().setHeight(20)),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  //用户名
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Text(
                          this.userInfo.userName,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(16),
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          print("点击了关注按钮");
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: ScreenUtil().setWidth(56),
                          height: ScreenUtil().setHeight(26),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            color: Colors.blueAccent,
                          ),
                          child: Center(
                            child: Text(
                              "+ 关注",
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(13),
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  //用户说明
                  Container(
                    child: Text(
                      this.userInfo.userDesc,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(12),
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                  Container(
                    child: Text(
                      "关注 " +
                          this.userInfo.follow.toString() +
                          "  |  粉丝 " +
                          this.userInfo.fans.toString(),
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(12),
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          top: ScreenUtil().setHeight(110),
          left: ScreenUtil().setWidth(20),
          child: Container(
            width: ScreenUtil().setWidth(50),
            height: ScreenUtil().setHeight(60),
            child: CircleAvatar(
              backgroundImage: NetworkImage(fileURL + this.userInfo.userImgBig),
            ),
          ),
        ),
      ],
    );
  }
}

class ListItem extends StatelessWidget {
  final int index;
  final UserDynamic itemInfo;
  const ListItem({Key key, @required this.index, @required this.itemInfo}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return itemInfo.type == 1 ? _getVideoItem(itemInfo) : _getMusicItem(itemInfo);
  }

  Widget _getMusicItem(UserDynamic itemInfo) {
    return Container(
      padding: EdgeInsets.only(
          left: ScreenUtil().setHeight(20),
          top: ScreenUtil().setHeight(20),
          right: ScreenUtil().setHeight(20)),
      height: ScreenUtil().setHeight(155),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              //头像
              Container(
                width: ScreenUtil().setWidth(40),
                height: ScreenUtil().setHeight(40),
                child: ClipOval(
                  child: Image.network(
                    fileURL + itemInfo.userImgSmall,
                    width: ScreenUtil().setWidth(40),
                    height: ScreenUtil().setHeight(40),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(
                width: 5,
              ),
              //名称&时间
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    itemInfo.userName,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(16),
                      color: Colors.blueAccent,
                    ),
                  ),
                  Text(
                    itemInfo.releaseTime.toString() + " 发布了新音乐",
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(12),
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: ScreenUtil().setHeight(10),
          ),
          Container(
            margin: EdgeInsets.only(left: ScreenUtil().setWidth(44)),
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(5)),
            width: ScreenUtil().setWidth(290),
            height: ScreenUtil().setHeight(60),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: Colors.grey[200],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: ScreenUtil().setWidth(40),
                  height: ScreenUtil().setHeight(40),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    image: DecorationImage(
                        image: NetworkImage(fileURL + itemInfo.thumb)),
                  ),
                ),
                //SizedBox(width: ScreenUtil().setWidth(10),),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        itemInfo.title,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(14),
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        itemInfo.desc,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(12),
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    print("点击了关注");
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: ScreenUtil().setWidth(10)),
                    width: ScreenUtil().setWidth(50),
                    height: ScreenUtil().setHeight(25),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      color: Colors.blueAccent,
                    ),
                    child: Center(
                      child: Text(
                        "+ 关注",
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(12),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: ScreenUtil().setHeight(15),
          ),
          Divider(
            height: 1,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _getVideoItem(UserDynamic itemInfo) {
    return Container(
      padding: EdgeInsets.only(
          left: ScreenUtil().setHeight(20),
          top: ScreenUtil().setHeight(20),
          right: ScreenUtil().setHeight(20)),
      height: ScreenUtil().setHeight(408),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              //头像
              Container(
                width: ScreenUtil().setWidth(40),
                height: ScreenUtil().setHeight(40),
                child: ClipOval(
                  child: Image.network(
                    fileURL + itemInfo.userImgSmall,
                    width: ScreenUtil().setWidth(40),
                    height: ScreenUtil().setHeight(40),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(
                width: 5,
              ),
              //名称&时间
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    itemInfo.userName,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(16),
                      color: Colors.blueAccent,
                    ),
                  ),
                  Text(
                    itemInfo.releaseTime + " 发布了新视频",
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(12),
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: ScreenUtil().setHeight(10),
          ),
          //介绍
          Text(
            itemInfo.desc,
            maxLines: 2,
            overflow: TextOverflow.clip,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(12),
              color: Colors.grey[400],
            ),
          ),
          SizedBox(
            height: ScreenUtil().setHeight(10),
          ),
          //视频图片
          InkWell(
            onTap: () {
              print("点击了视频");
            },
            child: Container(
              child: Stack(
                children: <Widget>[
                  Container(
                    height: ScreenUtil().setHeight(182),
                    width: ScreenUtil().setWidth(335),
                    decoration: BoxDecoration(
                      color: slRandomColor(),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      image: DecorationImage(
                        image: NetworkImage(fileURL + itemInfo.thumb),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  //观看人数
                  Positioned(
                    bottom: ScreenUtil().setHeight(20),
                    left: ScreenUtil().setWidth(20),
                    child: Container(
                      child: Text(
                        itemInfo.watch+"观看",
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(12),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  //视频时长
                  Positioned(
                    bottom: ScreenUtil().setHeight(20),
                    right: ScreenUtil().setWidth(20),
                    child: Container(
                      width: ScreenUtil().setWidth(50),
                      height: ScreenUtil().setHeight(25),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        color: Color.fromRGBO(0, 0, 0, 0.6),
                      ),
                      child: Center(
                        child: Text(
                          itemInfo.playTime,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(12),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: ScreenUtil().setHeight(10),
          ),
          Text(
            itemInfo.title,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(14),
              color: Colors.black,
            ),
          ),
          SizedBox(
            height: ScreenUtil().setHeight(15),
          ),
          Container(
            height: ScreenUtil().setHeight(25),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          print("点击了喜欢");
                        },
                        child: Image(
                          image: AssetImage("assets/images/display/u305.png"),
                          width: ScreenUtil().setWidth(22),
                          height: ScreenUtil().setHeight(22),
                        ),
                      ),
                      Container(
                        width: ScreenUtil().setWidth(5),
                      ),
                      Text(
                        itemInfo.like.toString(),
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(12),
                          color: Colors.black,
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          print("点击了消息");
                        },
                        child: Image(
                          image: AssetImage("assets/images/display/u314.png"),
                          width: ScreenUtil().setWidth(22),
                          height: ScreenUtil().setHeight(22),
                        ),
                      ),
                      Container(
                        width: ScreenUtil().setWidth(5),
                      ),
                      Text(
                        itemInfo.message.toString(),
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(12),
                          color: Colors.black,
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          print("点击了分享");
                        },
                        child: Image(
                          image: AssetImage("assets/images/display/u311.png"),
                          width: ScreenUtil().setWidth(22),
                          height: ScreenUtil().setHeight(22),
                        ),
                      ),
                      Container(
                        width: ScreenUtil().setWidth(5),
                      ),
                      Text(
                        itemInfo.forward.toString(),
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(12),
                          color: Colors.black,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: ScreenUtil().setHeight(14),
          ),
          Divider(
            height: 1,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }
}
