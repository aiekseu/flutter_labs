import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Lab9 Kudashkin Aleksey 8K81'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _query = '', _tempQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search in all GitHub...',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (String value) {
                        setState(() {
                          _tempQuery = value;
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.search_rounded,
                      color: Colors.black54,
                    ),
                    iconSize: 36,
                    onPressed: () {
                      setState(() {
                        _query = _tempQuery;
                      });
                    },
                  ),
                ],
              ),
            ),
            Divider(),
            if (_query != '')
              FutureBuilder<List<GitHubRepository>>(
                future: fetchRepositories(http.Client(), _query),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print(snapshot.error);
                    return const Center(
                      child: Text('An error has occurred!'),
                    );
                  } else if (snapshot.hasData) {
                    return snapshot.data!.length != 0
                        ? RepositoriesList(repositories: snapshot.data!)
                        : Center(
                            child: Text('Ничего не найдено'),
                          );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
          ],
        ));
  }
}

class RepositoriesList extends StatelessWidget {
  const RepositoriesList({Key? key, required this.repositories})
      : super(key: key);

  final List<GitHubRepository> repositories;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.separated(
        separatorBuilder: (context, index) => Divider(),
        itemCount: repositories.length,
        itemBuilder: (context, index) => ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(repositories[index].fullName, softWrap: true,),
              Text(
                repositories[index].language,
                style: TextStyle(fontWeight: FontWeight.w400),
              )
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(repositories[index].description),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    Icon(Icons.star),
                    Text(
                      '${repositories[index].starsCount} stars     ',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Icon(Icons.circle_outlined),
                    Text('${repositories[index].issuesCount} issues',
                        style: TextStyle(fontWeight: FontWeight.w500))
                  ],
                ),
              )
            ],
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AboutRepositoryPage(
                          repository: repositories[index],
                        )));
          },
        ),
      ),
    );
  }
}

Future<List<GitHubRepository>> fetchRepositories(
    http.Client client, String searchValue) async {
  final response = await client.get(
      Uri.parse('https://api.github.com/search/repositories?q=$searchValue'));

  return compute(parseRepositories, response.body);
}

List<GitHubRepository> parseRepositories(String responseBody) {
  final parsed = jsonDecode(responseBody)['items'];

  return parsed
      .map<GitHubRepository>(
          (json) => GitHubRepository.fromJson(json.cast<String, dynamic>()))
      .toList();
}

class AboutRepository extends StatelessWidget {
  const AboutRepository({Key? key, required  this.repository})
      : super(key: key);

  final GitHubRepository repository;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Center(
              child: CircleAvatar(
                backgroundImage: NetworkImage(repository.ownerAvatarUrl),
                radius: 36,
              )),
        ),
        Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              '${repository.ownerLogin}',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
            )),
        Padding(
          padding: const EdgeInsets.only(top: 22.0),
          child: Text(repository.fullName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),),
        ),
        Text.rich(
          TextSpan(
            style: TextStyle(fontWeight: FontWeight.w400),
            children: <InlineSpan>[
              WidgetSpan(
                child: Icon(Icons.star),
              ),
              TextSpan(text: '${repository.starsCount} stars'),
              WidgetSpan(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Icon(Icons.download),
                ),
              ),
              TextSpan(text: '${repository.forksCount} forks'),
              WidgetSpan(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 2),
                  child: Icon(Icons.circle_outlined),
                ),
              ),
              TextSpan(text: '${repository.issuesCount} issues'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 4),
          child: Text('DESCRIPTION.md', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(repository.description, maxLines: 3,),
        )
      ],
    );
  }
}

class AboutRepositoryPage extends StatelessWidget {
  const AboutRepositoryPage({Key? key, required this.repository})
      : super(key: key);

  final GitHubRepository repository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${repository.fullName}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Назад',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: AboutRepository(repository: repository,)
    );
  }
}

class GitHubRepository {
  final String name,
      fullName,
      htmlUrl,
      description,
      language,
      ownerLogin,
      ownerAvatarUrl;
  final int issuesCount, starsCount, forksCount;

  GitHubRepository(
      {required this.name,
      required this.fullName,
      required this.htmlUrl,
      required this.description,
      required this.ownerLogin,
      required this.ownerAvatarUrl,
      required this.issuesCount,
      required this.starsCount,
      required this.forksCount,
      required this.language});

  factory GitHubRepository.fromJson(Map<String, dynamic> json) {
    return GitHubRepository(
        name: json['name'] ?? 'shit',
        fullName: json['full_name'] ?? 'shit',
        htmlUrl: json['html_url'] ?? 'shit',
        description: json['description'] ?? '',
        ownerLogin: json['owner'].cast<String, dynamic>()['login'] ?? 'shit',
        ownerAvatarUrl:
            json['owner'].cast<String, dynamic>()['avatar_url'] ?? 'shit',
        issuesCount: json['size'] ?? 'shit',
        starsCount: json['stargazers_count'] ?? 'shit',
        forksCount: json['forks_count'] ?? 'shit',
        language: json['language'] ?? 'shit');
  }
}
