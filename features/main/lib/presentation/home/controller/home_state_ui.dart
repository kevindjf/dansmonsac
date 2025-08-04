enum HomeViewPage {
  supplies,
  calendar,
  courses,
  settings
}

class HomeStateUi {
  final HomeViewPage currentPage;
  final int currentIndex;

  HomeStateUi(this.currentIndex,this.currentPage);
}