import 'dart:convert';

import 'package:linkeat/models/store.dart';
import 'package:linkeat/widgets/loadMoreDelegate.dart';
import 'package:flutter/material.dart';

import 'package:loadmore/loadmore.dart';

import 'package:linkeat/config.dart';
import 'package:linkeat/models/cms.dart';
import 'package:linkeat/l10n/localizations.dart';
import 'package:linkeat/service/request.dart';
import 'package:linkeat/widgets/storeCard.dart';

class Search extends StatefulWidget {
  static const routeName = '/search';

  Search({Key? key}) : super(key: key);

  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  List<StoreSummary>? stores;
  late int pageIdx;
  int? storesTotal;
  List<Album>? tags;
  String? currentTag = 'All';
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    pageIdx = -1;
    storesTotal = 0;
    _loadMore();
    _loadTags();
  }

  Future<void> _loadTags() async {
    final dynamic response = await Services.asyncRequest(
        'GET',
        '/cms/media/bundle?source=${Constants.FRANCHISE_STORE_TAGS_MEDIA_BUNDLE}',
        context);
    var data = json.decode(response.toString());
    var bundle = data["bundle"] as List;
    if (bundle.length > 0) {
      var items = bundle[0]['items'] as List?;
      setState(() {
        tags = items!.map<Album>((json) => Album.fromJson(json)).toList();
      });
    }
  }

  Future<bool> _loadMore() async {
    var tagUrlString = currentTag == 'All' ? '' : '&tags=${currentTag}';
    final dynamic response = await Services.asyncRequest(
        'GET',
        '/store/profile/nearby?pageIdx=${pageIdx}&pageSize=20&franchise=${Constants.FRANCHISE_ID}${tagUrlString}',
        context);
//    final dynamic response = await Services.asyncRequest(
//        'GET',
//        '/store/profile/nearby?pageIdx=${pageIdx}&pageSize=20${tagUrlString}',
//        context);
    var data = json.decode(response.toString());
    List<StoreSummary>? newStores = data['records']
        .map<StoreSummary>((json) => StoreSummary.fromSearchJson(json))
        .toList();

    setState(() {
      storesTotal = data['totalCount'];
      pageIdx = pageIdx + 1;
      if (stores == null) {
        stores = newStores;
      } else {
        stores!.addAll(newStores!);
      }
    });
    return true;
  }

  void _changeTag(String? tag) {
    stores!.clear();
    pageIdx = -1;
    currentTag = tag;
    _refresh();
  }

  Future<void> _refresh() async {
    stores!.clear();
    pageIdx = -1;
    _loadMore();
    return;
  }

  void scrollToTop() {
    _scrollController.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          AppLocalizations.of(context)!.search!,
          style: textTheme.headline5,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        // brightness: Theme.of(context).platform == TargetPlatform.android
        //     ? Brightness.dark
        //     : Brightness.light),
      ),
      body: stores != null
          ? RefreshIndicator(
              child: Column(
                children: <Widget>[
                  tags != null
                      ? Container(
                          height: 70.0,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: FilterChip(
                                  backgroundColor: Colors.grey[100],
                                  selectedColor: Colors.grey[300],
                                  labelStyle: textTheme.bodyText2,
                                  label: Text('All'),
                                  selected: currentTag == 'All',
                                  onSelected: (value) {
                                    _changeTag('All');
                                  },
                                ),
                              ),
                              for (final tag in tags!)
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: FilterChip(
                                    backgroundColor: Colors.grey[100],
                                    selectedColor: Colors.grey[300],
                                    labelStyle: textTheme.bodyText2,
                                    label: Text(tag.title!),
                                    selected: tag.title == currentTag,
                                    onSelected: (value) {
                                      _changeTag(tag.title);
                                    },
                                  ),
                                ),
                            ],
                          ),
                        )
                      : SizedBox.shrink(),
                  Expanded(
                    child: LoadMore(
                      isFinish: stores!.length >= storesTotal!,
                      onLoadMore: _loadMore,
                      child: stores!.length > 0
                          ? ListView.builder(
                              controller: _scrollController,
                              // padding: const EdgeInsets.all(8),
                              itemCount: stores!.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Hero(
                                  tag: stores![index].uuid!,
                                  child: SizedBox(
//                                      height: 254.0,
                                    child: StoreCard(store: stores![index]),
                                  ),
                                );
                              })
                          : Center(
                              child: Text(
                                AppLocalizations.of(context)!
                                    .noData!
                                    .toUpperCase(),
                                style: textTheme.caption,
                              ),
                            ),
                      whenEmptyLoad: false,
                      delegate:
                          CustomizedLoadMoreDelegate(context, scrollToTop),
                      textBuilder: DefaultLoadMoreTextBuilder.english,
                    ),
                  ),
                ],
              ),
              onRefresh: _refresh,
            )
          : Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                  strokeWidth: 1.0,
                ),
              ),
            ),
    );
  }
}
