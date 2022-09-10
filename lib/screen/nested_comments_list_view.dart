import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reddit_comment/model/comment.dart';

class NestedCommentsListView extends StatefulWidget {
  const NestedCommentsListView({Key? key}) : super(key: key);

  @override
  State<NestedCommentsListView> createState() => _NestedCommentsListViewState();
}

class _NestedCommentsListViewState extends State<NestedCommentsListView> {
  late FocusNode focusNode;
  bool mainListFocus = false;
  late TextEditingController textEditingController;
  List<CommentModel> commentHistory = <CommentModel>[];

  void addComment(CommentModel model) {
    setState(() {
      disableAllFocus(commentHistory);
      mainListFocus = false;
      model.hasFocus = true;
      focusNode.requestFocus();
    });
  }

  void disableAllFocus(List<CommentModel> list) {
    textEditingController.clear();
    for (var element in list) {
      element.hasFocus = false;
      disableAllFocus(element.commentList);
    }
  }

  void submitComment(List<CommentModel> list) {
    if (textEditingController.text.isNotEmpty) {
      setState(() {
        list.add(
          CommentModel(
            comment: textEditingController.text,
            voteCount: 0,
            date: currentTimeEpoch(),
            hasFocus: false,
            commentList: [],
          ),
        );
      });
    } else {
      disableAllFocus(commentHistory);
    }
    focusNode.unfocus();
    textEditingController.clear();
  }

  void deleteComment(List<CommentModel> list, CommentModel model) {
    setState(() {
      list.remove(model);
    });
  }

  int currentTimeEpoch() {
    var secondsSinceEpoch =
        DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
    return secondsSinceEpoch;
  }

  String timeStampToDateTime(
      {required int second, String dateFormat = 'dd-MMM-yyyy hh:mma'}) {
    return DateFormat(dateFormat)
        .format(DateTime.fromMillisecondsSinceEpoch(second * 1000));
  }

  Widget listView(List<CommentModel> list, CommentModel model) {
    return Card(
      elevation: 5.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        model.voteCount++;
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Icon(Icons.arrow_drop_up,
                          size: 30, color: Colors.grey),
                    ),
                  ),
                  Text(model.voteCount.toString()),
                  InkWell(
                    onTap: () {
                      setState(() {
                        model.voteCount--;
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Icon(Icons.arrow_drop_down,
                          size: 30, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.comment,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          timeStampToDateTime(second: model.date),
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      model.hasFocus
                          ? TextField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            onSubmitted: (value) {
                              setState(() {
                                disableAllFocus(commentHistory);
                              });
                            },
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              suffixIcon: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: TextButton(
                                  onPressed: () {
                                    submitComment(model.commentList);
                                    setState(() {
                                      model.hasFocus = false;
                                    });
                                  },
                                  child: const Text('Submit'),
                                ),
                              ),
                            ),
                          )
                          : Row(
                              children: [
                                InkWell(
                                  onTap: () => addComment(model),
                                  child: const Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: Text(
                                      'Reply',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => deleteComment(list, model),
                                  child: const Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          listViewBuild(model.commentList),
        ],
      ),
    );
  }

  Widget listViewBuild(List<CommentModel> modelList) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      primary: false,
      padding: const EdgeInsets.all(8.0),
      itemCount: modelList.length,
      itemBuilder: (ctx, index) => listView(modelList, modelList[index]),
    );
  }

  @override
  void initState() {
    focusNode = FocusNode();
    textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Nested Comments ListView',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        titleSpacing: 0,
      ),
      body: commentHistory.isEmpty
          ? Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Center(child: Text('Comments are not available')),
                mainListFocus
                    ? SizedBox(
                        width: 350,
                        child: TextField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          onSubmitted: (value) {
                            setState(() {
                              disableAllFocus(commentHistory);
                            });
                          },
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: TextButton(
                                onPressed: () {
                                  submitComment(commentHistory);
                                  setState(() {
                                    commentHistory[0].hasFocus = false;
                                    mainListFocus = false;
                                  });
                                },
                                child: const Text('Submit'),
                              ),
                            ),
                          ),
                        ),
                      )
                    : TextButton(
                        onPressed: () => setState(() {
                          mainListFocus = true;
                        }),
                        child: const Text('+ Add Comment'),
                      )
              ],
            )
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    primary: false,
                    padding: const EdgeInsets.all(4.0),
                    itemCount: commentHistory.length,
                    itemBuilder: (ctx, index) =>
                        listView(commentHistory, commentHistory[index]),
                  ),
                  mainListFocus
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              suffixIcon: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: TextButton(
                                  onPressed: () {
                                    submitComment(commentHistory);
                                    setState(() {
                                      mainListFocus = false;
                                    });
                                  },
                                  child: const Text('Submit'),
                                ),
                              ),
                            ),
                          ),
                        )
                      : InkWell(
                          onTap: () {
                            setState(() {
                              disableAllFocus(commentHistory);
                              mainListFocus = true;
                              focusNode.requestFocus();
                            });
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('+ Add Comment',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue)),
                          ),
                        )
                ],
              ),
            ),
    );
  }
}
