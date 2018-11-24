import 'package:flutter/material.dart';
import 'package:http/http.dart' show get;
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:collection';
import 'dart:convert';

//----------------------------End Imports-----------------------------------------//

var apiKey = '9bc58c023671b6b55eb4c300b7576121';

class Photo {
  final String id;
  final String owner, server, secret, title;
  final int farm, isfamily, ispublic, isfriend;
  final String url;

  Photo(
      {this.id,
      this.owner,
      this.secret,
      this.server,
      this.farm,
      this.title,
      this.ispublic,
      this.isfriend,
      this.isfamily,
      this.url});

  factory Photo.fromJson(Map<String, dynamic> parsedJson) {
    return new Photo(
        id: parsedJson['id'],
        owner: parsedJson['owner'],
        secret: parsedJson['secret'],
        server: parsedJson['server'],
        farm: parsedJson['farm'],
        title: parsedJson['title'],
        ispublic: parsedJson['ispublic'],
        isfriend: parsedJson['isfriend'],
        isfamily: parsedJson['isfamily'],
        url: parsedJson['url_m']);
  }
} //photo Class

class Photos {
  final int page, pages, perpage;
  final String total;
  final List<Photo> photolist;

  Photos({this.page, this.pages, this.perpage, this.total, this.photolist});

  factory Photos.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['photos']['photo'] as List;
    return new Photos(
        page: parsedJson['page'],
        pages: parsedJson['pages'],
        perpage: parsedJson['perpage'],
        total: parsedJson['total'],
        photolist: list.map((i) => Photo.fromJson(i)).toList());
  }
} //Photos Class

class Group {
  final String nsid;
  final String name, iconserver, members, pool_count, topic_count, privacy;
  final int eighteenplus, iconfarm;

  Group({
    this.nsid,
    this.name,
    this.iconserver,
    this.members,
    this.pool_count,
    this.topic_count,
    this.privacy,
    this.eighteenplus,
    this.iconfarm,
  });

  factory Group.fromJson(Map<String, dynamic> parsedJson) {
    return new Group(
        nsid: parsedJson['nsid'],
        name: parsedJson['name'],
        iconserver: parsedJson['iconserver'],
        members: parsedJson['members'],
        pool_count: parsedJson['pool_count'],
        topic_count: parsedJson['title'],
        privacy: parsedJson['privacy'],
        eighteenplus: parsedJson['eighteenplus'],
        iconfarm: parsedJson['iconfarm']);
  }
} //Group Class

class Groups {
  final int page, pages, perpage;
  final String total;
  final List<Group> group;

  Groups({this.perpage, this.total, this.page, this.pages, this.group});

  factory Groups.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['groups']['group'] as List;
    return new Groups(
        page: parsedJson['page'],
        pages: parsedJson['pages'],
        perpage: parsedJson['perpage'],
        total: parsedJson['total'],
        group: list.map((i) => Group.fromJson(i)).toList());
  }
} //Groups Class

class gPhoto extends Photo {
  final String ownername;
  final String dateadded;

  gPhoto({
    id,
    owner,
    secret,
    server,
    farm,
    title,
    ispublic,
    isfriend,
    isfamily,
    url,
    this.ownername,
    this.dateadded,
  }) : super(
            id: id,
            owner: owner,
            secret: secret,
            server: server,
            farm: farm,
            title: title,
            ispublic: ispublic,
            isfamily: isfamily,
            url: url);

  factory gPhoto.fromJson(Map<String, dynamic> parsedJson) {
    final photo = Photo.fromJson(parsedJson);
    final ownername = parsedJson['ownername'];
    final dateadded = parsedJson['dateadded'];
    return gPhoto(
        dateadded: dateadded,
        ownername: ownername,
        farm: photo.farm,
        id: photo.id,
        isfamily: photo.isfamily,
        isfriend: photo.isfriend,
        ispublic: photo.ispublic,
        owner: photo.owner,
        secret: photo.secret,
        server: photo.server,
        title: photo.title,
        url: photo.url);
  }
} //gPhoto Class

class gPhotos {
  final int page, pages, perpage;
  final String total;
  final List<gPhoto> gphotos;

  gPhotos({this.perpage, this.total, this.page, this.pages, this.gphotos});

  factory gPhotos.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['photos']['photo'] as List;
    return new gPhotos(
        page: parsedJson['page'],
        pages: parsedJson['pages'],
        perpage: parsedJson['perpage'],
        total: parsedJson['total'],
        gphotos: list.map((i) => gPhoto.fromJson(i)).toList());
  }
}

//---------------------Photos Section + main---------------------------------------//

class CustomListView extends StatelessWidget {
  final Photos photols;

  CustomListView(this.photols);

  Widget build(context) {
    return ListView.builder(
      itemCount: photols.perpage,
      itemBuilder: (context, int index) {
        return createViewItem(photols.photolist[index], context);
      },
    );
  }

  Widget createViewItem(Photo photo, BuildContext context) {
    return new ListTile(
      title: new Card(
          elevation: 1.0,
          child: new Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.purple)),
            padding: EdgeInsets.all(10.0),
            margin: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7),
                    child: Padding(
                      child: Image.network(photo.url),
                      padding: EdgeInsets.only(bottom: 8.0),
                    )),
                Row(
                  children: <Widget>[
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7),
                      child: Padding(
                          child: Text(
                            "Photo title: " + photo.title,
                            style: new TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.right,
                          ),
                          padding: EdgeInsets.all(1.0)),
                    )
                  ],
                )
              ],
            ),
          )),
    );
  }
} //PhotoListView

Future<Photos> fetchphotos(String category) async {
  final jsonEndPoint =
      'https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=${apiKey}&text=${category}&extras=url_m&format=json&nojsoncallback=1';
  final response = await get(jsonEndPoint);

  if (response.statusCode == 200) {
    // var photos = json.decode(response.body);
    //  print(response.body);
    //return photos[0];
    return Photos.fromJson(json.decode(response.body));
  } else {
    return throw Exception('we were unable to retreive json data');
  }
} //fetchphotos

void main() {
  runApp(new MaterialApp(
    debugShowCheckedModeBanner: false, //removing debug mode styling
    home: FirstPage(),
  ));
} //main

class FirstPage extends StatelessWidget {
  var _categoryNameController = new TextEditingController();
  int gId;

  //to capture category
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Material(
        color: Colors.white24,
        child: Center(
            child: ListView(children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(30.0),
          ),
          Text(
            'Search For Photos',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                fontStyle: FontStyle.italic,
                color: Colors.purple),
          ),
          new Image.asset('images/camera.png', width: 200.0, height: 200.0),
          new ListTile(
            title: new TextFormField(
              controller: _categoryNameController,
              decoration: new InputDecoration(
                  labelText: 'Enter a Picture Category',
                  hintText: 'example: Food, Cats, Icecream..',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0)),
                  contentPadding:
                      const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0)),
            ),
          ),
          Padding(padding: const EdgeInsets.all(7.0)),
          new ListTile(
              title: new Material(
            color: Colors.purple,
            elevation: 3.0,
            borderRadius: BorderRadius.circular(25.0),
            child: new MaterialButton(
              onPressed: () {
                Navigator.of(context)
                    .push(new MaterialPageRoute(builder: (context) {
                  return new PhotoPage(
                    category: _categoryNameController.text,
                  );
                }));
              },
              height: 48.0,
              child: Text(
                'Search for Photo',
                style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          )),
          new ListTile(
              title: new Material(
            color: Colors.teal,
            elevation: 3.0,
            borderRadius: BorderRadius.circular(25.0),
            child: new MaterialButton(
              onPressed: () {
                Navigator.of(context)
                    .push(new MaterialPageRoute(builder: (context) {
                  return new GroupPage(
                    text: _categoryNameController.text,
                  );
                }));
              },
              height: 48.0,
              child: Text(
                'Search for Group',
                style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ))
        ])),
      ),
    );
  }
} //HomePage

class PhotoPage extends StatefulWidget {
  String category;

  PhotoPage({this.category});

  @override
  _PhotoPageState createState() => _PhotoPageState();
} //PhotoPage

class _PhotoPageState extends State<PhotoPage> {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: new Scaffold(
        appBar: new AppBar(title: const Text('Images')),
        body: new Center(
          child: new FutureBuilder<Photos>(
            future: fetchphotos(widget.category),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Photos photos = snapshot.data;
                return new CustomListView(photos);
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              return new CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}

//----------------------------Groups Section-----------------------------------------//

Future<Groups> fetchgroups(String text) async {
  final jsonEndPoint =
      'https://api.flickr.com/services/rest/?method=flickr.groups.search&api_key=${apiKey}&text=${text}+&format=json&nojsoncallback=1';
  final response = await get(jsonEndPoint);

  if (response.statusCode == 200) {
    return Groups.fromJson(json.decode(response.body));
  } else {
    return throw Exception('we were unable to retreive groups data');
  }
} //fetchgroups

class GroupPage extends StatefulWidget {
  String text;

  GroupPage({this.text});

  @override
  _GroupPageState createState() => _GroupPageState();
} //GroupPage

class _GroupPageState extends State<GroupPage> {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: new Scaffold(
        appBar: new AppBar(title: const Text('Groups')),
        body: new Center(
          child: new FutureBuilder<Groups>(
            future: fetchgroups(widget.text),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Groups groups = snapshot.data;
                return new CustomGroupView(groups);
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              return new CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}

class CustomGroupView extends StatelessWidget {
  final Groups groupls;

  CustomGroupView(this.groupls);

  Widget build(context) {
    return ListView.builder(
      itemCount: groupls.perpage,
      itemBuilder: (context, int index) {
        return createGroupItem(groupls.group[index], context);
      },
    );
  }

  Widget createGroupItem(Group group, BuildContext context) {
    return new ListTile(
        title: new Card(
      elevation: 1.0,
      child: new Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.purple)),
        padding: EdgeInsets.all(10.0),
        margin: EdgeInsets.all(10.0),
        child: Column(children: <Widget>[
          Padding(
              child: Text(
                "Number of Memebers: " + group.members,
                style: new TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              padding: EdgeInsets.all(1.0)),
          new IconButton(
            icon: new Icon(Icons.add),
            highlightColor: Colors.teal,
            color: Colors.teal,
            iconSize: 30.0,
            onPressed: () {
              Navigator.of(context)
                  .push(new MaterialPageRoute(builder: (context) {
                return new gPhotoPage(
                  gId: group.nsid,
                );
              }));
            },
          ),
          Padding(
            child: Text(
              "Group Name: " + group.name,
            ),
            padding: EdgeInsets.only(bottom: 8.0),
          ),
        ]),
      ),
    ));
  }
}

///--------------------------Group Photos section------------------------------------------------//

Future<gPhotos> fetchGroupPhotos(String gId) async {
  final jsonEndPoint =
      'https://api.flickr.com/services/rest/?method=flickr.groups.pools.getPhotos&api_key=${apiKey}&group_id=${gId}&extras=url_m&format=json&nojsoncallback=1';
  final response = await get(jsonEndPoint);

  if (response.statusCode == 200) {
    return gPhotos.fromJson(json.decode(response.body));
  } else {
    return throw Exception('we were unable to retreive group photo');
  }
} //fetch group photos

class gPhotoListView extends StatelessWidget {
  final gPhotos gphotos;

  gPhotoListView(this.gphotos);

  Widget build(context) {
    return ListView.builder(
      itemCount: gphotos.perpage,
      itemBuilder: (context, int index) {
        return createViewItem(gphotos.gphotos[index], context);
      },
    );
  }

  Widget createViewItem(gPhoto gphoto, BuildContext context) {
    return new ListTile(
      title: new Card(
          elevation: 1.0,
          child: new Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.teal)),
            padding: EdgeInsets.all(10.0),
            margin: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Padding(
                  child: Image.network(gphoto.url),
                  padding: EdgeInsets.only(bottom: 8.0),
                ),
                Row(
                  children: <Widget>[
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7),
                      child: Padding(
                          child: Text(
                            "Photo title: " + gphoto.title,
                            style: new TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.right,
                          ),
                          padding: EdgeInsets.all(1.0)),
                    ),
                  ],
                )
              ],
            ),
          )),
    );
  }
} //gPhoto Listview

class gPhotoPage extends StatefulWidget {
  String gId;

  gPhotoPage({this.gId});

  @override
  _gPhotoPageState createState() => _gPhotoPageState();
}

class _gPhotoPageState extends State<gPhotoPage> {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: new Scaffold(
        appBar: new AppBar(title: const Text('Group Photos'), actions: <Widget>[
          // action button
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ]),
        body: new Center(
          child: new FutureBuilder<gPhotos>(
            future: fetchGroupPhotos(widget.gId.toString()),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                gPhotos gphotos = snapshot.data;
                return new gPhotoListView(gphotos);
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              return new CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
