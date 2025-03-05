class ArticleSearchParams {
  final String searchQuery;
  final String dateFrom;
  final String dateTo;
  final List<String> selectedSources;
  final List<String> selectedTags;
  final bool searchInText;
  final String searchOption;

  ArticleSearchParams({
    required this.searchQuery,
    required this.dateFrom,
    required this.dateTo,
    required this.selectedSources,
    required this.selectedTags,
    required this.searchInText,
    required this.searchOption,
  });

  factory ArticleSearchParams.fromJson(Map<String, dynamic> json) {
    return ArticleSearchParams(
      searchQuery: json['search_query'],
      dateFrom: json['date_from'],
      dateTo: json['date_to'],
      selectedSources: List<String>.from(json['selected_sources']),
      selectedTags: List<String>.from(json['selected_tags']),
      searchInText: json['search_in_text'],
      searchOption: json['search_option'],
    );
  }

  ArticleSearchParams copyWith({
    String? searchQuery,
    String? dateFrom,
    String? dateTo,
    List<String>? selectedSources,
    List<String>? selectedTags,
    bool? searchInText,
    String? searchOption,
  }) {
    return ArticleSearchParams(
      searchQuery: searchQuery ?? this.searchQuery,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      selectedSources: selectedSources ?? List.from(this.selectedSources),
      selectedTags: selectedTags ?? List.from(this.selectedTags),
      searchInText: searchInText ?? this.searchInText,
      searchOption: searchOption ?? this.searchOption,
    );
  }

  @override
  String toString() {
    return 'SearchParams(searchQuery: $searchQuery, dateFrom: $dateFrom, dateTo: $dateTo, '
        'selectedSources: $selectedSources, selectedTags: $selectedTags, '
        'searchInText: $searchInText, searchOption: $searchOption)';
  }
}