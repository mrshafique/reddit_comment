class CommentModel {
  String comment;
  bool hasFocus;
  int voteCount;
  int date;
  List<CommentModel> commentList;

  CommentModel({
    required this.comment,
    required this.hasFocus,
    required this.voteCount,
    required this.date,
    required this.commentList,
  });
}