/// Model representing a suggested supply item for a course
class SuggestedSupply {
  final String name;
  final bool isChecked;
  final bool isModified;

  const SuggestedSupply({
    required this.name,
    required this.isChecked,
    this.isModified = false,
  });

  SuggestedSupply copyWith({
    String? name,
    bool? isChecked,
    bool? isModified,
  }) {
    return SuggestedSupply(
      name: name ?? this.name,
      isChecked: isChecked ?? this.isChecked,
      isModified: isModified ?? this.isModified,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SuggestedSupply &&
        other.name == name &&
        other.isChecked == isChecked &&
        other.isModified == isModified;
  }

  @override
  int get hashCode => name.hashCode ^ isChecked.hashCode ^ isModified.hashCode;
}
