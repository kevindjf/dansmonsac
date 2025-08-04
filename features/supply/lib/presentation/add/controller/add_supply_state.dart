class AddSupplyState {
  final String courseId;
  final String supplyName;
  final bool isLoading;
  final List<String> supplies;
  final String? errorSupplyName;

  AddSupplyState(this.courseId, this.supplyName, this.isLoading, this.supplies,
      this.errorSupplyName);

  factory AddSupplyState.initial(String courseId) {
    return AddSupplyState(courseId, '', false, [], null);
  }

  AddSupplyState copyWith(
      {String? supplyName,
      bool? isLoading,
      List<String>? supplies,
      String? errorSupplyName}) {
    return AddSupplyState(
        courseId,
        supplyName ?? this.supplyName,
        isLoading ?? this.isLoading,
        supplies ?? this.supplies,
        errorSupplyName);
  }
}
